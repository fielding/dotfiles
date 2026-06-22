// mouse-tap — passive global mouse-event logger for the mouseless audit.
//
// A listen-only CGEventTap that records mouse-DOWN events (and, optionally, a
// throttled keyboard-activity heartbeat) to a JSONL file. It NEVER records
// keystroke content or mouse movement — only that a button went down, where,
// and when. That's the minimum needed to answer "when did you reach for the
// mouse, and what were you on" without being a keylogger.
//
// Pairs with log-focus (window focus ground truth) and skl's usage.log
// (keyboard actions); mouse-report joins the three.
//
// Requires Input Monitoring permission (System Settings > Privacy & Security >
// Input Monitoring). Without it, tapCreate returns nil and we exit non-zero so
// launchd's KeepAlive retries once the grant lands.
//
// Usage: mouse-tap [--out PATH] [--heartbeat]
//   --out PATH    output JSONL file (default ~/.local/share/mouseless/mouse.jsonl)
//   --heartbeat   also emit a 1/sec "keyboard active" tick (no keycodes)

import Foundation
import CoreGraphics

// ── output ───────────────────────────────────────────────────────────────────
final class Log {
    private let fd: Int32
    init(path: String) {
        let dir = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(
            atPath: dir, withIntermediateDirectories: true)
        fd = open(path, O_WRONLY | O_APPEND | O_CREAT, 0o644)
        if fd < 0 { FileHandle.standardError.write("mouse-tap: cannot open \(path)\n".data(using: .utf8)!); exit(1) }
    }
    func write(_ line: String) {
        var s = line; s += "\n"
        _ = s.withCString { Darwin.write(fd, $0, strlen($0)) }
    }
}

// ── state (C callbacks can't capture, so this lives globally) ─────────────────
final class State {
    let log: Log
    let heartbeat: Bool
    var lastKeyTick: Double = 0
    init(log: Log, heartbeat: Bool) { self.log = log; self.heartbeat = heartbeat }

    func record(_ type: CGEventType, _ event: CGEvent) {
        let now = Date().timeIntervalSince1970
        let p = event.location
        switch type {
        case .leftMouseDown:  emit("left",  now, p)
        case .rightMouseDown: emit("right", now, p)
        case .otherMouseDown: emit("other", now, p)
        case .scrollWheel:    emit("scroll", now, p)
        case .keyDown:
            guard heartbeat, now - lastKeyTick >= 1.0 else { return }
            lastKeyTick = now
            log.write(String(format: "{\"t\":%.3f,\"ev\":\"key\"}", now))
        default: break
        }
    }
    private func emit(_ ev: String, _ t: Double, _ p: CGPoint) {
        log.write(String(format: "{\"t\":%.3f,\"ev\":\"%@\",\"x\":%.0f,\"y\":%.0f}",
                         t, ev, p.x, p.y))
    }
}

var state: State! = nil

let tapCallback: CGEventTapCallBack = { _, type, event, _ in
    // System can disable the tap (timeout / user input); re-enable and move on.
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let t = gTap { CGEvent.tapEnable(tap: t, enable: true) }
        return Unmanaged.passUnretained(event)
    }
    state.record(type, event)
    return Unmanaged.passUnretained(event)
}

var gTap: CFMachPort? = nil

// ── args ──────────────────────────────────────────────────────────────────────
func parseArgs() -> (out: String, heartbeat: Bool) {
    let home = FileManager.default.homeDirectoryForCurrentUser.path
    var out = "\(home)/.local/share/mouseless/mouse.jsonl"
    var hb = false
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let a = it.next() {
        switch a {
        case "--out": if let v = it.next() { out = v }
        case "--heartbeat": hb = true
        default: break
        }
    }
    return (out, hb)
}

// ── main ──────────────────────────────────────────────────────────────────────
let (outPath, heartbeat) = parseArgs()
state = State(log: Log(path: outPath), heartbeat: heartbeat)

var mask: CGEventMask =
    (1 << CGEventType.leftMouseDown.rawValue)  |
    (1 << CGEventType.rightMouseDown.rawValue) |
    (1 << CGEventType.otherMouseDown.rawValue) |
    (1 << CGEventType.scrollWheel.rawValue)
if heartbeat { mask |= (1 << CGEventType.keyDown.rawValue) }

guard let tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .listenOnly,
    eventsOfInterest: mask,
    callback: tapCallback,
    userInfo: nil)
else {
    FileHandle.standardError.write(
        "mouse-tap: failed to create event tap — grant Input Monitoring in System Settings.\n"
        .data(using: .utf8)!)
    exit(2)
}
gTap = tap

let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
state.log.write(String(format: "{\"t\":%.3f,\"ev\":\"start\"}", Date().timeIntervalSince1970))
CFRunLoopRun()

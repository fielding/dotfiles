// holdpeek — run a command while a modifier is held (which-key style), via a
// passive, listen-only CGEventTap.
//
// Watches modifier flags + keystrokes but NEVER rewrites them, so the real
// modifier flows straight through to skhd/apps — every chord (ctrl+1, …) keeps
// working while the peek is up. That's the whole reason this exists instead of
// skhd (no modifier-hold/release events) or a Karabiner rule (consumes the key).
//
// Logic: hold the modifier `--hold-ms` → run `--on`; release it → run `--off`.
// It watches ONLY modifier flags, never keystrokes, so it stays entirely out of
// the keypress path and cannot interfere with hotkey daemons like skhd (an
// earlier keyDown tap here was breaking skhd's repeated ctrl+N window-cycling).
//
// Robustness: event taps can be briefly disabled by the system under load,
// dropping the release event and leaving the peek stuck "on". So a poll
// (`--poll-ms`) reads the REAL modifier state via CGEventSource and force-hides
// if the map is up while the modifier isn't actually held. Self-healing.
//
// Usage: holdpeek --mod control --hold-ms 350 --poll-ms 200 --on CMD --off CMD [--debug]
//
// Requires Input Monitoring. Shipped as a .app bundle (build.sh) for a stable
// TCC identity. --debug logs transitions to stderr (the launchd err log).

import Foundation
import CoreGraphics

// ── args ──────────────────────────────────────────────────────────────────────
var modMask: CGEventFlags = .maskControl
var holdMs = 350
var pollMs = 200
var onCmd = ""
var offCmd = ""
var debug = false
do {
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let a = it.next() {
        switch a {
        case "--mod":
            switch it.next() ?? "" {
            case "control", "ctrl": modMask = .maskControl
            case "command", "cmd":  modMask = .maskCommand
            case "option", "alt":   modMask = .maskAlternate
            case "shift":           modMask = .maskShift
            default: break
            }
        case "--hold-ms": holdMs = Int(it.next() ?? "") ?? 350
        case "--poll-ms": pollMs = Int(it.next() ?? "") ?? 200
        case "--on":      onCmd = it.next() ?? ""
        case "--off":     offCmd = it.next() ?? ""
        case "--debug":   debug = true
        default: break
        }
    }
}

func logd(_ s: String) {
    guard debug else { return }
    let t = ProcessInfo.processInfo.systemUptime
    FileHandle.standardError.write(String(format: "[%.3f] %@\n", t, s).data(using: .utf8)!)
}

func runShell(_ cmd: String) {
    guard !cmd.isEmpty else { return }
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/sh")
    p.arguments = ["-c", cmd]
    try? p.run()
}

// ── state (single-threaded: tap callback + timers all on the main run loop) ───
final class Watcher {
    var modDown = false
    var showing = false
    var pending: DispatchWorkItem?

    func show(_ why: String) {
        if showing { return }
        showing = true; runShell(onCmd); logd("show (\(why))")
    }
    func hide(_ why: String) {
        pending?.cancel(); pending = nil
        if showing { showing = false; runShell(offCmd); logd("hide (\(why))") }
    }

    func setDown(_ down: Bool, _ why: String) {
        if down == modDown { return }
        modDown = down
        if down {
            pending?.cancel()
            let w = DispatchWorkItem { if watcher.modDown { watcher.show("held") } }
            pending = w
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(holdMs), execute: w)
            logd("down (\(why))")
        } else {
            hide("up (\(why))")
        }
    }

    func onFlags(_ flags: CGEventFlags) { setDown(flags.contains(modMask), "flags") }

    // the backstop: reconcile against the real hardware modifier state.
    func poll() {
        let real = CGEventSource.flagsState(.combinedSessionState).contains(modMask)
        if showing && !real { modDown = false; hide("poll-heal") ; return }
        setDown(real, "poll")
    }
}
let watcher = Watcher()

var gTap: CFMachPort?
let callback: CGEventTapCallBack = { _, type, event, _ in
    switch type {
    case .flagsChanged: watcher.onFlags(event.flags)
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        logd("tap disabled -> re-enable + resync")
        if let t = gTap { CGEvent.tapEnable(tap: t, enable: true) }
        watcher.poll()
    default: break
    }
    return Unmanaged.passUnretained(event)
}

// ── main ──────────────────────────────────────────────────────────────────────
let mask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)

guard let tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap, place: .headInsertEventTap, options: .listenOnly,
    eventsOfInterest: mask, callback: callback, userInfo: nil)
else {
    FileHandle.standardError.write(
        "holdpeek: failed to create event tap — grant Input Monitoring.\n".data(using: .utf8)!)
    exit(2)
}
gTap = tap
let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)

// self-healing poll
let poll = DispatchSource.makeTimerSource(queue: .main)
poll.schedule(deadline: .now() + .milliseconds(pollMs), repeating: .milliseconds(pollMs))
poll.setEventHandler { watcher.poll() }
poll.resume()

logd("holdpeek started (hold=\(holdMs)ms poll=\(pollMs)ms)")
CFRunLoopRun()

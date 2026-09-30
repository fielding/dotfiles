"""Decision-logic tests for bin/bin/yabai-organize.

Everything runs against in-memory fixtures: a fake Folio, fake git probe and stub oracles. No yabai,
folio, herdr or network is touched.

    python3 -m unittest discover -s tests/yabai_organize -v
"""
from __future__ import annotations

import importlib.machinery
import importlib.util
import json
import os
import pathlib
import sys
import tempfile
import time
import unittest
from unittest import mock

ROOT = pathlib.Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "bin" / "bin" / "yabai-organize"
FIXTURES = pathlib.Path(__file__).resolve().parent / "fixtures"


def load_module():
    loader = importlib.machinery.SourceFileLoader("yabai_organize", str(SCRIPT))
    spec = importlib.util.spec_from_loader("yabai_organize", loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = mod        # dataclasses resolve annotations through sys.modules
    loader.exec_module(mod)
    return mod


yo = load_module()
HOME = yo.HOME
RULES = yo.load_rules("/nonexistent/yabai-organize-config.json")

# ── Folio fixtures ────────────────────────────────────────────────────────────

def entry(reference, status="active", location="active", title=None, category=None):
    domain, slug = reference.split("/", 1)
    return {"kind": "project", "id": f"proj_{slug}", "reference": reference, "slug": slug,
            "title": title or slug.replace("-", " ").title(), "realm": domain, "domain": domain,
            "status": status, "category": category, "location": location}


ENTRIES = [
    entry("venice/inference-proxy", title="Inference Proxy"),
    entry("venice/anon-email", title="Anonymous Email"),
    entry("venice/identity-guard", title="Identity Guard"),
    entry("fielding/review-crew", title="Review Crew"),
    entry("fielding/ripguard"),
    entry("fielding/nwallet"),
    entry("fielding/dotfiles"),
    entry("fielding/fite", status="maintained"),
    entry("fielding/box", status="maintained"),
    entry("fielding/resume", status="paused"),
    entry("fielding/apprentice", status="dormant"),
    entry("fielding/pilot", status="paused"),
    entry("fielding/justfielding.com", title="justfielding.com"),
    entry("fielding/website", status="completed", location="archived"),
    entry("venice/website"),
]

SHOWS = {
    "venice/inference-proxy": {"routes": [{"repository": "github.com/veniceai/outerface", "prefix": "rust/src/inference/proxy"}]},
    "venice/anon-email": {"routes": [{"repository": "github.com/veniceai/outerface", "prefix": "rust/src/anon_email"},
                                     {"repository": "github.com/veniceai/cloudflare", "prefix": "workers/anon-email-receiver"}]},
    "venice/identity-guard": {"routes": [{"repository": "github.com/veniceai/interface", "prefix": "lib/identity-guard"}]},
}

INVALID = {"status": "invalid", "reason": {"type": "invalid-evidence", "message": "not a git worktree"}}


def resolved_project(reference, repo=None, rel=None, kind="repository-full-project"):
    reason = {"type": kind}
    if repo:
        reason["repository"] = repo
    if rel is not None:
        reason["relative_path"] = rel
    return {"status": "resolved", "owner": {"kind": "project", "id": "proj_x", "reference": reference}, "reason": reason}


def resolved_domain(reference, repo=None, rel=None):
    reason = {"type": "repository-full", "repository": repo}
    if rel is not None:
        reason["relative_path"] = rel
    return {"status": "resolved", "owner": {"kind": "domain", "id": "dom_x", "reference": reference}, "reason": reason}


def unresolved(repo):
    return {"status": "unresolved", "reason": {"type": "repository", "repository": repo}}


def canon(path):
    return yo.ProjectResolver.canonical(path)


class FakeFolio:
    """In-memory stand-in for the folio CLI: canned answers keyed by canonical path/repository."""

    available = True

    def __init__(self, entries=ENTRIES, shows=SHOWS, paths=None, vault=None, repos=None, git=None):
        self.entries = entries
        self.shows = shows
        self.paths = {canon(k): v for k, v in (paths or {}).items()}
        self.vault = {canon(k): v for k, v in (vault or {}).items()}
        self.repos = repos or {}
        self._git = {canon(k): v for k, v in (git or {}).items()}
        self.calls = []

    def list_all(self):
        return self.entries

    def show(self, reference):
        return self.shows.get(reference, {"routes": []})

    def resolve_path(self, path):
        self.calls.append(("path", path))
        return self.paths.get(path, INVALID)

    def resolve_vault_path(self, path):
        self.calls.append(("vault-path", path))
        return self.vault.get(path, INVALID)

    def resolve_repository(self, repository):
        self.calls.append(("repository", repository))
        return self.repos.get(repository, unresolved(repository))

    def git(self, path):
        for top, remotes in self._git.items():
            if path == top or path.startswith(top + "/"):
                return yo.GitInfo(top, remotes)
        return None


# Paths that behave like the real machine: Folio routes ripguard/review-crew/fite by remote, the notes
# vault by anchor directory; Nwallet and dotfiles have unrouted repositories; outerface has a bundle origin.
PATHS = {
    f"{HOME}/src/hack/ripguard": resolved_project("fielding/ripguard", "github.com/fielding/ripguard"),
    f"{HOME}/src/hack/review-crew": resolved_project("fielding/review-crew", "github.com/fielding/review-crew"),
    f"{HOME}/src/hack/fite": resolved_project("fielding/fite", "github.com/fielding/fite"),
    f"{HOME}/src/hack/Nwallet": unresolved("github.com/SelvWallet/Nwallet"),
    f"{HOME}/etc": unresolved("github.com/fielding/dotfiles"),
    f"{HOME}/etc/bin/bin": unresolved("github.com/fielding/dotfiles"),
    f"{HOME}/src/hack/folio": unresolved("github.com/fielding/folio"),
}
VAULT = {
    f"{HOME}/notes/Projects/inference-proxy": resolved_project("venice/inference-proxy", kind="vault-path"),
    f"{HOME}/notes/Projects/apprentice": resolved_project("fielding/apprentice", kind="vault-path"),
    f"{HOME}/notes/Domains/venice": resolved_domain("venice"),
}
REPOS = {
    "github.com/veniceai/outerface": resolved_domain("venice", "github.com/veniceai/outerface"),
    "github.com/fielding/ripguard": resolved_project("fielding/ripguard", "github.com/fielding/ripguard"),
}
GIT = {
    f"{HOME}/src/work/venice/outerface": {"github": "github.com/veniceai/outerface"},
    f"{HOME}/src/hack/colors/fite": {},
}


def folio(**overrides):
    kw = {"paths": PATHS, "vault": VAULT, "repos": REPOS, "git": GIT}
    kw.update(overrides)
    return FakeFolio(**kw)


# ── Desktop fixtures ──────────────────────────────────────────────────────────

def spaces(labels=None):
    """Ten spaces with yabairc's fixed labels in place and empty slot labels unless overridden."""
    labels = {**yo.FIXED_LABELS, **(labels or {})}
    return [yo.Space(i, labels.get(i, "")) for i in range(1, 11)]


def win(wid, app, title, space, **kw):
    return yo.Window(id=wid, pid=100 + wid, app=app, title=title, space=space, **kw)


def sess(sid, cwd, command="-/bin/zsh", agent=None, **kw):
    return yo.Session(id=sid, cwd=cwd, command=command, source="ghostty", agent=agent, **kw)


def desktop(windows, labels=None, sessions=(), ports=(), herdr=(), repo_dirs=()):
    return yo.DesktopState(list(windows), spaces(labels), list(sessions), list(ports),
                           ["m5", "m5.local"], list(herdr), list(repo_dirs))


class StubOracle:
    def __init__(self, answers, name="jev", fail=None):
        self.answers = answers
        self.name = name
        self.fail = fail
        self.questions = []

    def ask(self, state, questions):
        self.questions.append((state, questions))
        if self.fail:
            raise yo.OracleError(self.fail)
        return {n: a for n, a in self.answers.items() if n in questions}, {"model": "stub", "input_tokens": 10, "output_tokens": 1}


def choice(label, confidence, **others):
    probs = {label: confidence, **others}
    return yo.ChoiceResult(label, confidence, probs)


def context(folio_, rules=RULES):
    registry = yo.Registry.from_entries(folio_.entries)
    resolver = yo.ProjectResolver(folio_, registry, rules["vault_roots"], git=folio_.git,
                                  description_chars=rules["description_chars"],
                                  description_disclosures=rules["description_disclosures"])
    return registry, resolver


def run(state, folio_, oracles=(), threshold=0.7, stored=None, rules=RULES):
    registry, resolver = context(folio_, rules)
    plan, runs = yo.organize(state, registry, resolver, rules, list(oracles), threshold, stored or {})
    errors = yo.validate_plan(plan, state, rules, registry)
    return plan, runs, errors


def shadow_run(plan, folio_, oracle, threshold=0.7):
    registry, resolver = context(folio_)
    return yo.observe(plan, oracle, registry, resolver, threshold)


def moves(plan):
    return {m.window_id: m.to_space for m in plan.moves}


# ── Fixed routing ─────────────────────────────────────────────────────────────

class FixedRouting(unittest.TestCase):
    def test_slack_always_goes_to_comms(self):
        st = desktop([win(1, "Slack", "Danny (DM) - Venice.ai - Slack", 3), win(2, "Discord", "general", 9)])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {1: 10, 2: 10})
        self.assertEqual(plan.decisions[1].resolution, "fixed:comms")

    def test_obsidian_always_goes_to_notes(self):
        st = desktop([win(1, "Obsidian", "ripguard - notes - Obsidian 1.13.7", 7)])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {1: 6})
        self.assertIsNone(plan.decisions[1].project, "a project name in the note title must not override notes")

    def test_hub_terminal_goes_to_main(self):
        hub = sess("ghostty:ttys002", f"{HOME}/src/hack/Nwallet", command="herdr", is_hub=True)
        st = desktop([win(1, "Ghostty", "m5.local: Nwallet", 4), win(2, "Ghostty", "tmux:3 [ nvim ]", 5),
                      win(3, "Ghostty", "m5.local: ~", 6)],
                     sessions=[hub], herdr=["Nwallet", "etc"])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {1: 1, 2: 1, 3: 1})
        for wid in (1, 2, 3):
            self.assertEqual(plan.decisions[wid].resolution, "fixed:hub")

    def test_hostname_prefixed_title_without_herdr_is_not_a_hub(self):
        st = desktop([win(1, "Ghostty", "m5.local: Nwallet", 4)])
        plan, _, _ = run(st, folio())
        self.assertNotIn(1, moves(plan))
        self.assertEqual(plan.decisions[1].outcome, "unresolved")

    def test_ignored_vpn_window_never_moves(self):
        st = desktop([win(1, "NordVPN", "NordVPN", 4, can_move=False, role=""),
                      win(2, "Problem Reporter", "", 9, can_move=False, role=""),
                      win(3, "Tailscale", "Tailscale", 2)])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {})
        for wid in (1, 2, 3):
            self.assertEqual(plan.decisions[wid].outcome, "ignored")

    def test_misplaced_windows_on_purpose_spaces_are_evicted_to_inbox(self):
        st = desktop([win(1, "Google Chrome", "Policy Wording - Google Chrome", 10),   # comms
                      win(2, "Google Chrome", "wttr.in - Google Chrome", 9),           # media
                      win(3, "Ghostty", "~", 6),                                       # notes
                      win(4, "Google Chrome", "New Tab - Google Chrome", 2),           # project slot: stays
                      win(5, "1Password", "All Accounts", 7),                          # scratch: stays
                      win(6, "Google Chrome", "Mail - Google Chrome", 1),              # main: stays
                      win(7, "Notion", "Roadmap", 6)])                                 # notes app on notes: stays
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {1: 8, 2: 8, 3: 8})
        self.assertEqual(plan.decisions[1].resolution, "evict:comms")
        self.assertEqual(plan.decisions[3].detail["was"], "title-path")
        for wid in (4, 5, 6):
            self.assertEqual(plan.decisions[wid].outcome, "unresolved")
        self.assertEqual(plan.decisions[7].target, 6)

    def test_browser_showing_media_belongs_on_media(self):
        st = desktop([win(1, "Google Chrome", "Lo-fi beats radio - YouTube - Google Chrome - Fielding (justfielding.com)", 9),
                      win(2, "Google Chrome", "ThePrimeagen Stream - Watch Live on Kick - Google Chrome", 3),
                      win(3, "Google Chrome", "Docs - Google Chrome", 9)])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(plan.decisions[1].resolution, "media:title")
        self.assertNotIn(1, moves(plan), "YouTube on media stays put")
        self.assertEqual(moves(plan)[2], 9, "a live stream elsewhere is routed to media")
        self.assertEqual(moves(plan)[3], 1, "the one browser window left unresolved is the general-purpose one and lives on main")
        st = desktop([win(1, "Google Chrome", "Lo-fi beats radio - YouTube - Google Chrome", 9),
                      win(2, "Google Chrome", "Docs - Google Chrome", 9), win(3, "Google Chrome", "Mail - Google Chrome", 9)])
        plan, _, _ = run(st, folio())
        self.assertEqual(moves(plan), {2: 8, 3: 8}, "with several general browsers none is special, so misplaced ones go to inbox")

    def test_eviction_never_touches_resolved_or_ignored_windows(self):
        st = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 10), win(2, "Problem Reporter", "", 9, can_move=False, role="")])
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].project, "fielding/ripguard")
        self.assertEqual(plan.decisions[2].outcome, "ignored")

    def test_terminal_in_vault_outside_projects_goes_to_notes(self):
        st = desktop([win(1, "Ghostty", "~/notes", 4), win(2, "Ghostty", "~/notes/Domains/venice", 1)])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {1: 6, 2: 6})
        self.assertEqual(plan.decisions[1].resolution, "notes:vault-path")

    def test_single_browser_window_lives_on_main(self):
        st = desktop([win(1, "Google Chrome", "ripguard dashboard - Google Chrome", 4)])
        plan, _, _ = run(st, folio())
        self.assertEqual(moves(plan), {1: 1})
        self.assertEqual(plan.decisions[1].resolution, "fixed:browser-single")


# ── Project resolution ────────────────────────────────────────────────────────

class ProjectResolution(unittest.TestCase):
    def test_exact_folio_path_match_from_terminal_title(self):
        st = desktop([win(1, "Ghostty", "…/src/hack/ripguard", 1)], sessions=[sess("ghostty:ttys010", f"{HOME}/src/hack/ripguard")])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        d = plan.decisions[1]
        self.assertEqual((d.outcome, d.project, d.resolution), ("project", "fielding/ripguard", "title-path"))
        self.assertEqual(moves(plan), {1: 2})
        self.assertEqual(plan.labels, {2: "ripguard"})

    def test_bracketed_claude_code_title_resolves(self):
        st = desktop([win(1, "Ghostty", "[~/src/hack/review-crew]", 1)])
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].project, "fielding/review-crew")

    def test_vault_path_resolves_through_folio_vault_path(self):
        f = folio()
        st = desktop([win(1, "Ghostty", "…/notes/Projects/inference-proxy", 1)],
                     sessions=[sess("ghostty:ttys016", f"{HOME}/notes/Projects/inference-proxy")])
        plan, _, _ = run(st, f)
        self.assertEqual(plan.decisions[1].project, "venice/inference-proxy")
        self.assertIn(("vault-path", canon(f"{HOME}/notes/Projects/inference-proxy")), f.calls)
        self.assertEqual(plan.labels[2], "inference-proxy", "display label is the Folio slug, identity is the reference")

    def test_unrouted_repository_falls_back_to_repo_name(self):
        st = desktop([win(1, "Ghostty", "~/src/hack/Nwallet", 1), win(2, "Ghostty", "~/etc/bin/bin", 1)])
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].project, "fielding/nwallet")
        self.assertEqual(plan.decisions[1].detail["method"], "repo-name")
        self.assertEqual(plan.decisions[2].project, "fielding/dotfiles")

    def test_unrouted_repository_with_no_matching_slug_stays_put(self):
        st = desktop([win(1, "Ghostty", "~/src/hack/folio", 4)])
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].outcome, "unresolved")
        self.assertEqual(moves(plan), {})

    def test_invalid_origin_uses_other_remote_and_route_prefix(self):
        st = desktop([win(1, "Ghostty", "~/src/work/venice/outerface/rust/src/inference/proxy", 1)])
        plan, _, _ = run(st, folio())
        d = plan.decisions[1]
        self.assertEqual((d.project, d.detail["method"]), ("venice/inference-proxy", "route-prefix"))

    def test_repository_root_of_a_domain_asks_only_its_routed_projects(self):
        oracle = StubOracle({})
        st = desktop([win(1, "Ghostty", "~/src/work/venice/outerface", 1)])
        run(st, folio(), oracles=[oracle])
        _, questions = oracle.questions[0]
        self.assertEqual(set(questions["w1"]["criteria"]), {"anon-email", "inference-proxy", "unknown"})

    def test_paused_project_still_wins_on_exact_cwd(self):
        paths = dict(PATHS, **{f"{HOME}/src/hack/pilot": resolved_project("fielding/pilot", "github.com/fielding/pilot")})
        st = desktop([win(1, "Ghostty", "~/src/hack/pilot", 1)])
        plan, _, _ = run(st, folio(paths=paths))
        self.assertEqual(plan.decisions[1].project, "fielding/pilot")

    def test_localhost_port_resolves_browser_window(self):
        port = yo.ListeningPort(5173, 4242, "node", f"{HOME}/src/hack/ripguard")
        st = desktop([win(1, "Google Chrome", "localhost:5173/settings - Google Chrome - Fielding (justfielding.com)", 1),
                      win(2, "Google Chrome", "Hacker News - Google Chrome - Fielding (justfielding.com)", 3)], ports=[port])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        d = plan.decisions[1]
        self.assertEqual((d.project, d.resolution, d.detail["port"]), ("fielding/ripguard", "port", 5173))
        self.assertEqual(moves(plan)[1], 2)
        self.assertEqual(moves(plan)[2], 1, "the remaining unresolved browser window is the general-purpose one")
        self.assertEqual(plan.decisions[2].resolution, "browser:general")

    def test_chrome_title_with_unambiguous_project_identity(self):
        st = desktop([win(1, "Google Chrome", "review-crew · Pull Request #12 - Google Chrome - Fielding (justfielding.com)", 1),
                      win(2, "Google Chrome", "Hacker News - Google Chrome - Fielding (justfielding.com)", 1)])
        plan, _, _ = run(st, folio())
        d = plan.decisions[1]
        self.assertEqual((d.project, d.resolution), ("fielding/review-crew", "title:lexical"))
        self.assertNotEqual(plan.decisions[2].project, "fielding/justfielding.com", "profile suffix must be stripped")

    def test_single_word_slug_in_title_is_a_candidate_not_a_decision(self):
        oracle = StubOracle({})
        st = desktop([win(1, "Google Chrome", "Resume your subscription - Google Chrome", 4),
                      win(2, "Google Chrome", "Mail - Google Chrome", 1)])
        plan, _, _ = run(st, folio(), oracles=[oracle])
        self.assertEqual(plan.decisions[1].outcome, "unresolved")
        self.assertNotIn(1, moves(plan))
        _, questions = oracle.questions[0]
        self.assertIn("resume", questions["w1"]["criteria"])

    def test_spinner_with_one_agent_session_resolves_deterministically(self):
        st = desktop([win(1, "Ghostty", "✳ Fix streaming reconnect logic", 1)],
                     sessions=[sess("ghostty:ttys012", f"{HOME}/src/hack/ripguard", command="claude", agent="claude"),
                               sess("ghostty:ttys014", f"{HOME}/src/hack/review-crew")])
        plan, _, _ = run(st, folio())
        d = plan.decisions[1]
        self.assertEqual((d.project, d.resolution), ("fielding/ripguard", "session:unique"))

    def test_spinner_whose_only_agent_session_has_no_project_stays(self):
        st = desktop([win(1, "Ghostty", "✳ Seeking.min.js analysis preparation", 1)],
                     sessions=[sess("ghostty:ttys012", f"{HOME}/Downloads", command="claude", agent="claude")])
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].outcome, "unresolved")
        self.assertEqual(moves(plan), {})

    def test_remote_session_title_is_left_alone(self):
        st = desktop([win(1, "Ghostty", "fielding@mandy: ~/src/ripguard", 4)])
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].resolution, "remote")
        self.assertEqual(moves(plan), {})


# ── Jev ───────────────────────────────────────────────────────────────────────

def two_agent_sessions():
    return [sess("ghostty:ttys012", f"{HOME}/src/hack/ripguard", command="claude", agent="claude"),
            sess("ghostty:ttys014", f"{HOME}/src/hack/review-crew", command="claude", agent="claude")]


class JevResolution(unittest.TestCase):
    def test_ambiguous_spinner_resolved_through_live_sessions(self):
        oracle = StubOracle({"w1": choice("session_2", 0.91, session_1=0.07, unknown=0.02)})
        st = desktop([win(1, "Ghostty", "✳ Fix websocket fallback behavior", 1)], sessions=two_agent_sessions())
        plan, runs, errors = run(st, folio(), oracles=[oracle])
        self.assertEqual(errors, [])
        d = plan.decisions[1]
        self.assertEqual((d.outcome, d.project, d.resolution, d.accepted), ("project", "fielding/review-crew", "jev", True))
        self.assertEqual((d.selected, d.confidence), ("session_2", 0.91))
        self.assertEqual(d.candidates, ["session_1", "session_2"])
        self.assertEqual(moves(plan), {1: 2})
        self.assertEqual(runs[0].questions, 1)
        _, questions = oracle.questions[0]
        crit = questions["w1"]["criteria"]
        self.assertEqual(set(crit), {"session_1", "session_2", "unknown"})
        self.assertEqual(crit["session_1"]["project"], "fielding/ripguard")
        self.assertNotIn("space", questions["w1"]["instructions"].lower(), "Jev is asked about sessions, never workspaces")

    def test_low_confidence_decision_leaves_window_unchanged(self):
        oracle = StubOracle({"w1": choice("session_1", 0.54, session_2=0.40)})
        st = desktop([win(1, "Ghostty", "✳ Refactor something", 4)], sessions=two_agent_sessions())
        plan, _, errors = run(st, folio(), oracles=[oracle])
        self.assertEqual(errors, [])
        d = plan.decisions[1]
        self.assertEqual((d.outcome, d.accepted, d.selected, d.confidence), ("unresolved", False, "session_1", 0.54))
        self.assertEqual(moves(plan), {})

    def test_threshold_is_configurable(self):
        oracle = StubOracle({"w1": choice("session_1", 0.54, session_2=0.40)})
        st = desktop([win(1, "Ghostty", "✳ Refactor something", 4)], sessions=two_agent_sessions())
        plan, _, _ = run(st, folio(), oracles=[oracle], threshold=0.5)
        self.assertEqual(plan.decisions[1].project, "fielding/ripguard")

    def test_unknown_choice_leaves_window_unchanged(self):
        oracle = StubOracle({"w1": choice("unknown", 0.95)})
        st = desktop([win(1, "Ghostty", "✳ Refactor something", 4)], sessions=two_agent_sessions())
        plan, _, _ = run(st, folio(), oracles=[oracle])
        self.assertEqual(plan.decisions[1].outcome, "unresolved")
        self.assertEqual(moves(plan), {})

    def test_no_oracle_fails_closed(self):
        st = desktop([win(1, "Ghostty", "✳ Refactor something", 4)], sessions=two_agent_sessions())
        plan, runs, _ = run(st, folio())
        self.assertEqual((plan.decisions[1].outcome, plan.decisions[1].resolution), ("unresolved", "no-oracle"))
        self.assertEqual(moves(plan), {})
        self.assertEqual(runs, [])

    def test_oracle_error_is_logged_and_nothing_moves(self):
        oracle = StubOracle({}, fail="HTTP 500")
        st = desktop([win(1, "Ghostty", "✳ Refactor something", 4)], sessions=two_agent_sessions())
        plan, runs, errors = run(st, folio(), oracles=[oracle])
        self.assertEqual(errors, [])
        self.assertEqual(runs[0].error, "HTTP 500")
        self.assertEqual(moves(plan), {})

    def test_browser_project_question_maps_slug_back_to_reference(self):
        oracle = StubOracle({"w1": choice("ripguard", 0.88)})
        st = desktop([win(1, "Google Chrome", "Dashboard · settings - Google Chrome", 1),
                      win(2, "Google Chrome", "Mail - Google Chrome", 1)],
                     sessions=[sess("ghostty:ttys010", f"{HOME}/src/hack/ripguard")])
        plan, _, _ = run(st, folio(), oracles=[oracle])
        self.assertEqual(plan.decisions[1].project, "fielding/ripguard")
        self.assertEqual(plan.decisions[2].resolution, "browser:general")

    def test_candidates_are_bounded_to_live_desktop(self):
        oracle = StubOracle({})
        st = desktop([win(1, "Google Chrome", "Dashboard - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)],
                     labels={3: "nwallet"},
                     sessions=[sess("ghostty:ttys010", f"{HOME}/src/hack/ripguard"),
                               sess("ghostty:ttys011", f"{HOME}/notes/Projects/inference-proxy")],
                     herdr=["etc", "fite"])
        run(st, folio(), oracles=[oracle])
        _, questions = oracle.questions[0]
        crit = questions["w1"]["criteria"]
        self.assertEqual(set(crit), {"ripguard", "inference-proxy", "nwallet", "fite", "unknown"})
        self.assertIn("live session in ~/src/hack/ripguard", crit["ripguard"]["evidence"])
        self.assertIn("occupies slot 3", crit["nwallet"]["evidence"])
        self.assertNotIn("box", crit, "projects with no connection to the desktop are not offered")

    def test_candidate_count_is_capped(self):
        oracle = StubOracle({})
        sessions = [sess(f"ghostty:ttys{i:03d}", f"{HOME}/src/hack/p{i}") for i in range(12)]
        paths = {f"{HOME}/src/hack/p{i}": resolved_project(f"fielding/p{i}", f"github.com/fielding/p{i}") for i in range(12)}
        entries = ENTRIES + [entry(f"fielding/p{i}") for i in range(12)]
        st = desktop([win(1, "Google Chrome", "Dashboard - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)],
                     sessions=sessions)
        run(st, folio(entries=entries, paths=paths), oracles=[oracle])
        _, questions = oracle.questions[0]
        self.assertEqual(len(questions["w1"]["criteria"]), RULES["max_candidates"] + 1)

    def test_window_with_no_candidates_asks_nothing(self):
        oracle = StubOracle({})
        st = desktop([win(1, "Google Chrome", "Dashboard - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)])
        plan, runs, _ = run(st, folio(), oracles=[oracle])
        self.assertEqual(oracle.questions, [])
        self.assertEqual(runs, [])
        self.assertEqual(plan.decisions[1].resolution, "no-candidates")

    def test_shadow_mode_logs_jev_without_moving(self):
        shadow = StubOracle({"w1": choice("session_2", 0.95)})
        st = desktop([win(1, "Ghostty", "✳ Fix websocket fallback behavior", 1)], sessions=two_agent_sessions())
        plan, runs, _ = run(st, folio(), oracles=[])
        run_ = shadow_run(plan, folio(), shadow)
        self.assertEqual(moves(plan), {})
        self.assertEqual(plan.decisions[1].outcome, "unresolved")
        self.assertEqual(len(plan.shadow), 1)
        self.assertEqual((plan.shadow[0].project, plan.shadow[0].accepted, plan.shadow[0].resolution),
                         ("fielding/review-crew", True, "jev"))
        self.assertTrue(run_.shadow)
        self.assertEqual(runs, [])

    def test_legacy_model_shadows_every_question_and_never_acts(self):
        jev = StubOracle({"w1": choice("session_2", 0.9), "w2": choice("unknown", 0.9)})
        legacy = StubOracle({"w1": choice("session_1", 0.8), "w2": choice("session_2", 0.95)}, name="legacy:gpt-5.5")
        st = desktop([win(1, "Ghostty", "✳ Fix websocket fallback behavior", 1), win(2, "Ghostty", "◐ Card API rollout", 4)],
                     sessions=two_agent_sessions())
        plan, runs, errors = run(st, folio(), oracles=[jev])
        run_ = shadow_run(plan, folio(), legacy)
        self.assertEqual(errors, [])
        self.assertEqual(plan.decisions[1].project, "fielding/review-crew")
        self.assertEqual(plan.decisions[2].outcome, "unresolved", "only Jev acts; a confident legacy answer changes nothing")
        self.assertEqual(moves(plan), {1: 2})
        self.assertEqual([len(q) for _, q in legacy.questions], [2], "the legacy model sees every question, not just rejects")
        by_window = {d.window_id: d for d in plan.shadow}
        self.assertEqual((by_window[1].selected, by_window[1].detail["implied_project"]), ("session_1", "fielding/ripguard"))
        self.assertEqual((by_window[2].selected, by_window[2].accepted, by_window[2].resolution), ("session_2", True, "legacy:gpt-5.5"))
        self.assertEqual((run_.name, run_.shadow, run_.questions), ("legacy:gpt-5.5", True, 2))

    def test_rejected_answers_still_record_the_implied_project(self):
        jev = StubOracle({"w1": choice("session_2", 0.4, session_1=0.35)})
        st = desktop([win(1, "Ghostty", "✳ Fix websocket fallback behavior", 1)], sessions=two_agent_sessions())
        plan, _, _ = run(st, folio(), oracles=[jev])
        d = plan.decisions[1]
        self.assertEqual((d.accepted, d.detail["implied_project"]), (False, "fielding/review-crew"))

    def test_jev_request_matches_typesafe_wire_format(self):
        captured = {}

        def transport(url, body, headers, timeout):
            captured.update(url=url, body=body, headers=headers)
            return {"model": "jev-1.13.0", "usage": {"input_tokens": 300, "output_tokens": 12},
                    "answers": {"w1": {"type": "choice", "choice": "session_1", "confidence": 0.9,
                                       "probabilities": {"session_1": 0.9, "unknown": 0.1}}}}

        oracle = yo.JevOracle("sk-test", model="jev-latest", transport=transport)
        structured = {"cwd": "~/x", "project": "a/b", "evidence": ["p", "q"], "about": None}
        results, meta = oracle.ask({"windows": {}}, {"w1": {"instructions": "which?", "criteria": {"session_1": structured, "unknown": "none"}}})
        self.assertEqual(captured["url"], "https://api.typesafe.ai/v1/systemone")
        self.assertEqual(captured["headers"]["Authorization"], "Bearer sk-test")
        self.assertEqual(captured["body"]["model"], "jev-latest")
        self.assertEqual(captured["body"]["questions"]["w1"]["type"], "choice")
        self.assertEqual(captured["body"]["questions"]["w1"]["criteria"]["session_1"], structured, "TypeSafe takes structured criteria as-is")
        self.assertEqual(set(captured["body"]), {"state", "model", "questions"})
        self.assertEqual((results["w1"].choice, results["w1"].confidence), ("session_1", 0.9))
        self.assertEqual(meta, {"model": "jev-1.13.0", "input_tokens": 300, "output_tokens": 12, "endpoint": "api.typesafe.ai"})

    def test_jev_via_venice_renders_criteria_as_strings(self):
        captured = {}

        def transport(url, body, headers, timeout):
            captured.update(url=url, body=body, headers=headers)
            return {"model": "jev-latest", "usage": {"input_tokens": 438, "output_tokens": 45},
                    "answers": {"w1": {"type": "choice", "choice": "session_1", "confidence": 1.0,
                                       "probabilities": {"session_1": 1.0, "session_2": 0.0, "unknown": 0.0}}}}

        oracle = yo.JevOracle("vk", url="https://api.venice.ai/api/v1/decisions", transport=transport)
        self.assertTrue(oracle.string_criteria)
        criteria = {"session_1": {"cwd": "~/src/hack/Nwallet", "project": "fielding/nwallet", "evidence": ["live session", "slot 3"], "about": ""},
                    "unknown": "No listed session clearly matches."}
        results, meta = oracle.ask({"windows": {"w1": {"title": "t"}}}, {"w1": {"instructions": "which?", "criteria": criteria}})
        sent = captured["body"]["questions"]["w1"]["criteria"]
        self.assertEqual(sent["session_1"], "cwd: ~/src/hack/Nwallet; project: fielding/nwallet; evidence: live session, slot 3")
        self.assertEqual(sent["unknown"], "No listed session clearly matches.")
        self.assertTrue(all(isinstance(v, str) for v in sent.values()))
        self.assertIsInstance(captured["body"]["state"], dict, "Venice accepts object state")
        self.assertEqual((results["w1"].choice, results["w1"].confidence, meta["endpoint"]), ("session_1", 1.0, "api.venice.ai"))

    def test_jev_from_config_picks_endpoint_and_key(self):
        rules = dict(RULES, jev_url="https://api.venice.ai/api/v1/decisions", jev_api_key_keychain="VENICE_API_KEY")
        with mock.patch.object(yo, "keychain_secret", side_effect=lambda item: {"VENICE_API_KEY": "vk"}.get(item)), \
             mock.patch.dict(os.environ, {"JEV_API_KEY": "", "TYPESAFE_API_KEY": "ts"}):
            oracle = yo.JevOracle.from_config(rules)
            self.assertEqual((oracle.url, oracle.api_key, oracle.string_criteria), (rules["jev_url"], "vk", True))
            self.assertIsNone(yo.JevOracle.from_config(dict(rules, jev_api_key_keychain="MISSING")), "a TypeSafe env key never leaks to Venice")
            default = yo.JevOracle.from_config(dict(RULES, jev_api_key_keychain="MISSING"))
            self.assertEqual((default.url, default.api_key, default.string_criteria), (yo.JevOracle.DEFAULT_URL, "ts", False))


class GenerativeFallback(unittest.TestCase):
    QUESTIONS = {"w1": {"instructions": "which?", "criteria": {"session_1": {"cwd": "~/x"}, "session_2": None, "unknown": "none"}}}

    def test_openai_compatible_backend_parses_json_answers(self):
        captured = {}

        def transport(url, body, headers, timeout):
            captured.update(url=url, body=body, headers=headers)
            content = json.dumps({"answers": {"w1": {"choice": "session_2", "confidence": 0.8}}})
            return {"model": "gpt-5.5", "usage": {"prompt_tokens": 500, "completion_tokens": 20},
                    "choices": [{"message": {"content": "```json\n" + content + "\n```"}}]}

        oracle = yo.GenerativeOracle("gpt-5.5", openai_url="http://localhost:8317/v1", api_key="k", transport=transport)
        results, meta = oracle.ask({"windows": {}}, self.QUESTIONS)
        self.assertEqual(captured["url"], "http://localhost:8317/v1/chat/completions")
        self.assertEqual(captured["headers"]["Authorization"], "Bearer k")
        self.assertEqual(captured["body"]["response_format"], {"type": "json_object"})
        self.assertEqual(captured["body"]["reasoning_effort"], "low")
        self.assertEqual((results["w1"].choice, results["w1"].confidence), ("session_2", 0.8))
        self.assertEqual(meta["input_tokens"], 500)

    def test_choice_outside_the_options_is_dropped(self):
        def transport(url, body, headers, timeout):
            return {"choices": [{"message": {"content": json.dumps({"answers": {"w1": {"choice": "session_9", "confidence": 0.99}}})}}]}

        oracle = yo.GenerativeOracle("qwen2.5:7b", openai_url="http://localhost:11434/v1", transport=transport)
        self.assertEqual((oracle.backend, oracle.api_key), ("openai", "ollama"))
        results, _ = oracle.ask({}, self.QUESTIONS)
        self.assertEqual(results, {})

    def test_venice_style_endpoint_uses_keychain_key_and_no_reasoning_param(self):
        captured = {}

        def transport(url, body, headers, timeout):
            captured.update(url=url, body=body, headers=headers)
            return {"choices": [{"message": {"content": json.dumps({"answers": {"w1": {"choice": "unknown", "confidence": 0.7}}})}}],
                    "usage": {"prompt_tokens": 100, "completion_tokens": 9}}

        with mock.patch.object(yo, "keychain_secret", side_effect=lambda item: "vk" if item == "VENICE_API_KEY" else None):
            oracle = yo.GenerativeOracle("llama-3.3-70b", openai_url="https://api.venice.ai/api/v1",
                                         keychain_item="VENICE_API_KEY", transport=transport)
        self.assertEqual(oracle.api_key, "vk")
        oracle.ask({}, self.QUESTIONS)
        self.assertEqual(captured["url"], "https://api.venice.ai/api/v1/chat/completions")
        self.assertEqual(captured["headers"]["Authorization"], "Bearer vk")
        self.assertNotIn("reasoning_effort", captured["body"], "only gpt/o-series models get reasoning_effort")
        self.assertEqual(captured["body"]["response_format"], {"type": "json_object"})
        self.assertEqual(captured["body"]["venice_parameters"]["include_venice_system_prompt"], False)
        quiet = yo.GenerativeOracle("llama-3.3-70b", openai_url="https://api.venice.ai/api/v1", api_key="k", json_mode=False, transport=transport)
        quiet.ask({}, self.QUESTIONS)
        self.assertNotIn("response_format", captured["body"])

    def test_claude_model_name_goes_through_the_configured_endpoint_by_default(self):
        captured = {}

        def transport(url, body, headers, timeout):
            captured.update(url=url, body=body, headers=headers)
            return {"choices": [{"message": {"content": json.dumps({"answers": {}})}}]}

        oracle = yo.GenerativeOracle("claude-opus-4-8", openai_url="https://api.venice.ai/api/v1", api_key="vk", transport=transport)
        oracle.ask({}, self.QUESTIONS)
        self.assertEqual(oracle.backend, "openai")
        self.assertEqual(captured["url"], "https://api.venice.ai/api/v1/chat/completions")
        self.assertEqual(captured["headers"]["Authorization"], "Bearer vk")
        self.assertNotIn("reasoning_effort", captured["body"])

    def test_anthropic_backend(self):
        captured = {}

        def transport(url, body, headers, timeout):
            captured.update(url=url, body=body, headers=headers)
            return {"model": "claude-sonnet-5", "usage": {"input_tokens": 300, "output_tokens": 15},
                    "content": [{"type": "text", "text": json.dumps({"answers": {"w1": {"choice": "unknown", "confidence": 0.6}}})}]}

        oracle = yo.GenerativeOracle("claude-sonnet-5", api_key="sk", backend="anthropic", transport=transport)
        results, meta = oracle.ask({}, self.QUESTIONS)
        self.assertEqual(captured["url"], "https://api.anthropic.com/v1/messages")
        self.assertEqual(captured["headers"]["x-api-key"], "sk")
        self.assertEqual(captured["body"]["temperature"], 0)
        self.assertEqual(results["w1"].choice, "unknown")
        self.assertEqual(meta["model"], "claude-sonnet-5")

    def test_non_json_reply_is_an_oracle_error(self):
        oracle = yo.GenerativeOracle("gpt-5.5", api_key="k", transport=lambda *a: {"choices": [{"message": {"content": "nope"}}]})
        with self.assertRaises(yo.OracleError):
            oracle.ask({}, self.QUESTIONS)


# ── Candidate descriptions and hints ──────────────────────────────────────────

ANCHOR_NOTE = """---
folio_id: proj_x
title: Nwallet
---

# Nwallet

## Overview
- Self-custody crypto wallet with a card-issuing API (`src/app/api/cards`) and a staging deploy.
- Related planning lives in [[Projects/nwallet/plans/staging|the staging plan]].

## Current State
- Staging rollout in progress.
"""


class Descriptions(unittest.TestCase):
    def test_anchor_overview_extracts_and_cleans_the_overview(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "nwallet.md")
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(ANCHOR_NOTE)
            text = yo.anchor_overview(path, 400)
            self.assertTrue(text.startswith("Self-custody crypto wallet with a card-issuing API (src/app/api/cards)"))
            self.assertIn("the staging plan", text)
            self.assertNotIn("[[", text)
            self.assertNotIn("Staging rollout", text, "only the Overview section is used")
            short = yo.anchor_overview(path, 40)
            self.assertTrue(short.endswith("…") and len(short) <= 41)
            self.assertEqual(yo.anchor_overview(os.path.join(tmp, "missing.md"), 400), "")

    def test_descriptions_reach_jev_criteria_and_respect_disclosure(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "nwallet.md")
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(ANCHOR_NOTE)
            shows = dict(SHOWS)
            shows["fielding/nwallet"] = {"routes": [], "anchor": path, "effective": {"disclosure": "private"}}
            shows["fielding/ripguard"] = {"routes": [], "anchor": path, "effective": {"disclosure": "restricted"}}
            f = folio(shows=shows)
            oracle = StubOracle({})
            st = desktop([win(1, "Google Chrome", "Card issuing dashboard - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)],
                         sessions=[sess("a", f"{HOME}/src/hack/Nwallet"), sess("b", f"{HOME}/src/hack/ripguard")])
            rules = dict(RULES, description_disclosures=["public", "private"])
            run(st, f, oracles=[oracle], rules=rules)
            _, questions = oracle.questions[0]
            crit = questions["w1"]["criteria"]
            self.assertIn("card-issuing API", crit["nwallet"]["about"])
            self.assertNotIn("about", crit["ripguard"], "restricted projects send no prose when not allowed")
            # session questions carry the session project's description too
            oracle = StubOracle({})
            st = desktop([win(1, "Ghostty", "◐ Card API staging rollout", 1)],
                         sessions=[sess("a", f"{HOME}/src/hack/Nwallet", command="claude", agent="claude"),
                                   sess("b", f"{HOME}/src/hack/review-crew", command="claude", agent="claude")])
            run(st, f, oracles=[oracle])
            _, questions = oracle.questions[0]
            self.assertIn("card-issuing", questions["w1"]["criteria"]["session_1"]["about"])
            self.assertNotIn("about", questions["w1"]["criteria"]["session_2"])


class ProfileHint(unittest.TestCase):
    def test_profile_domain_is_parsed_from_chrome_titles(self):
        self.assertEqual(yo.browser_profile_domain("API Keys - Venice - Google Chrome - Fielding (venice.ai)"), "venice.ai")
        self.assertEqual(yo.browser_profile_domain("Docs - Google Chrome - Work (me@justfielding.com)"), "justfielding.com")
        self.assertIsNone(yo.browser_profile_domain("Docs - Google Chrome"))
        self.assertIsNone(yo.browser_profile_domain("Policy (draft) - Google Chrome"))

    def test_profile_realm_ranks_candidates_but_never_decides(self):
        oracle = StubOracle({})
        rules = dict(RULES, browser_profile_realms={"venice.ai": "venice", "justfielding.com": "fielding"})
        st = desktop([win(1, "Google Chrome", "API Dashboard - Google Chrome - Fielding (venice.ai)", 1),
                      win(2, "Google Chrome", "Mail - Google Chrome - Fielding (justfielding.com)", 4)],
                     sessions=[sess("a", f"{HOME}/src/hack/ripguard"), sess("b", f"{HOME}/notes/Projects/inference-proxy")])
        plan, _, _ = run(st, folio(), oracles=[oracle], rules=rules)
        _, questions = oracle.questions[0]
        crit = questions["w1"]["criteria"]
        self.assertEqual(list(crit)[:2], ["inference-proxy", "ripguard"], "same-realm candidate ranks first")
        self.assertIn("browser profile venice.ai", crit["inference-proxy"]["evidence"])
        self.assertIn("ripguard", crit, "other realms are still offered")
        self.assertEqual(questions["w1"]["criteria"]["unknown"], crit["unknown"])
        self.assertEqual(plan.decisions[1].outcome, "unresolved", "a profile alone moves nothing")
        state, _ = oracle.questions[0]
        self.assertEqual(state["windows"]["w1"]["profile"], "venice.ai")


# ── Browser tabs ──────────────────────────────────────────────────────────────

def tab(title, url):
    return yo.Tab(title, url)


def browser_state(windows, tabs, **kw):
    st = desktop(windows, **kw)
    st.tabs = tabs
    return st


class BrowserTabs(unittest.TestCase):
    def test_resolve_url(self):
        registry, resolver = context(folio())
        ports = {5173: yo.ListeningPort(5173, 1, "node", f"{HOME}/src/hack/ripguard")}
        cases = {
            "http://localhost:5173/settings": "fielding/ripguard",
            "https://github.com/fielding/ripguard/pull/12": "fielding/ripguard",
            "https://github.com/veniceai/outerface/tree/main/rust/src/inference/proxy/mod.rs": "venice/inference-proxy",
            "https://github.com/veniceai/outerface/pull/10543": None,          # domain-level, no project
            "https://github.com/SelvWallet/Nwallet": "fielding/nwallet",       # unrouted repo, name match
            "https://news.ycombinator.com/": None,
            "not a url": None,
        }
        for url, expected in cases.items():
            self.assertEqual(yo.resolve_url(url, ports, resolver, RULES).project, expected, url)

    def test_tab_share_owner(self):
        self.assertEqual(yo.tab_share_owner({"a": 1}, 3, 0.25), "a")
        self.assertIsNone(yo.tab_share_owner({"a": 1}, 5, 0.25), "1 of 5 is under a quarter")
        self.assertIsNone(yo.tab_share_owner({"a": 2, "b": 2}, 4, 0.25), "ties prove nothing")
        self.assertEqual(yo.tab_share_owner({"a": 3, "b": 1}, 8, 0.25), "a")
        self.assertIsNone(yo.tab_share_owner({}, 4, 0.25))

    def test_small_window_with_a_project_tab_goes_to_the_project(self):
        tabs = {1: [tab("Hacker News", "https://news.ycombinator.com/"),
                    tab("PR #12 · fielding/ripguard", "https://github.com/fielding/ripguard/pull/12"),
                    tab("Rust docs", "https://doc.rust-lang.org/")]}
        st = browser_state([win(1, "Google Chrome", "Hacker News - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)], tabs)
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        d = plan.decisions[1]
        self.assertEqual((d.project, d.resolution, d.detail["matched"], d.detail["tabs"]), ("fielding/ripguard", "tabs:share", 1, 3))
        self.assertEqual(moves(plan)[1], 2)

    def test_generic_window_is_left_alone_everywhere(self):
        many = [tab(f"Thing {i}", f"https://example.com/{i}") for i in range(19)] + [tab("ripguard PR", "https://github.com/fielding/ripguard/pull/1")]
        st = browser_state([win(1, "Google Chrome", "Thing 0 - Google Chrome", 10),        # on comms: would be evicted if not generic
                            win(2, "Google Chrome", "Mail - Google Chrome", 4)], {1: many})
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual((plan.decisions[1].outcome, plan.decisions[1].resolution), ("unresolved", "browser:generic"))
        self.assertNotIn(1, moves(plan), "a 20-tab window is a workspace of its own, even on comms")
        self.assertEqual(moves(plan)[2], 1, "the other window is the only loose one and becomes the general browser")

    def test_generic_window_with_a_quarter_of_project_tabs_still_goes_to_the_project(self):
        many = [tab(f"Thing {i}", f"https://example.com/{i}") for i in range(14)] + \
               [tab(f"ripguard {i}", f"https://github.com/fielding/ripguard/issues/{i}") for i in range(6)]
        st = browser_state([win(1, "Google Chrome", "Thing 0 - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)], {1: many})
        plan, _, _ = run(st, folio())
        self.assertEqual((plan.decisions[1].project, plan.decisions[1].detail["matched"]), ("fielding/ripguard", 6))

    def test_generic_window_showing_youtube_is_not_dragged_to_media(self):
        many = [tab("Lo-fi - YouTube", "https://www.youtube.com/watch?v=x")] + [tab(f"Thing {i}", f"https://example.com/{i}") for i in range(9)]
        st = browser_state([win(1, "Google Chrome", "Lo-fi - YouTube - Google Chrome", 3), win(2, "Google Chrome", "Mail - Google Chrome", 1)], {1: many})
        plan, _, _ = run(st, folio())
        self.assertEqual(plan.decisions[1].resolution, "browser:generic")
        self.assertNotIn(1, moves(plan))

    def test_small_window_without_proof_asks_jev_with_its_tabs(self):
        oracle = StubOracle({})
        tabs = {1: [tab("Card issuing dashboard", "https://staging.nwallet.example/cards"), tab("Docs", "https://docs.example/")]}
        st = browser_state([win(1, "Google Chrome", "Card issuing dashboard - Google Chrome", 1), win(2, "Google Chrome", "Mail - Google Chrome", 1)],
                           tabs, sessions=[sess("a", f"{HOME}/src/hack/Nwallet")])
        run(st, folio(), oracles=[oracle])
        state, questions = oracle.questions[0]
        self.assertEqual(state["windows"]["w1"]["tabs"][0]["site"], "staging.nwallet.example/cards")
        self.assertIn("nwallet", questions["w1"]["criteria"])

    def test_chrome_tabs_matching_uses_active_tab_and_skips_ambiguity(self):
        jxa = json.dumps([
            {"name": "DHH: Future… - YouTube 🔊", "active": 1, "titles": ["DHH: Future of Programming - YouTube"], "urls": ["https://youtube.com/w"]},
            {"name": "New Tab", "active": 2, "titles": ["A", "New Tab"], "urls": ["https://a", "chrome://newtab/"]},
            {"name": "New Tab", "active": 1, "titles": ["New Tab"], "urls": ["chrome://newtab/"]},
        ])
        windows = [win(1, "Google Chrome", "DHH: Future of Programming - YouTube - Google Chrome - Fielding (x.com)", 9),
                   win(2, "Google Chrome", "New Tab - Google Chrome - Fielding (x.com)", 1),
                   win(3, "Google Chrome", "New Tab - Google Chrome - Fielding (x.com)", 2),
                   win(4, "Slack", "Slack", 10)]
        with mock.patch.object(yo, "run_out", return_value=jxa):
            tabs = yo.chrome_tabs(windows)
        self.assertEqual(set(tabs), {1}, "the two New Tab windows cannot be told apart, so neither gets tab evidence")
        self.assertEqual(tabs[1][0].url, "https://youtube.com/w")
        with mock.patch.object(yo, "run_out", return_value=""):
            self.assertEqual(yo.chrome_tabs(windows), {}, "no Automation grant → no evidence, no error")

    def test_state_round_trip_keeps_tabs(self):
        st = browser_state([win(1, "Google Chrome", "x - Google Chrome", 1)], {1: [tab("x", "https://x")]})
        again = yo.DesktopState.from_dict(json.loads(json.dumps(st.to_dict())))
        self.assertEqual(again.tabs, st.tabs)


# ── App hints and defaults ────────────────────────────────────────────────────

HINT_RULES = dict(RULES, app_hints={"Prism Launcher": {"hint": "Minecraft launcher", "default_space": 9},
                                    "1Password": {"default_space": 8}},
                  title_hints=[{"pattern": r"^Minecraft\*? ", "hint": "Minecraft game client", "default_space": 9}],
                  home_terminal_space=1)


class AppHints(unittest.TestCase):
    def test_hinted_app_is_asked_about_with_its_hint_and_falls_back_to_its_default(self):
        entries = ENTRIES + [entry("fielding/minecraft-agents", title="Minecraft Agents")]
        paths = dict(PATHS, **{f"{HOME}/src/hack/minecraft-agents": resolved_project("fielding/minecraft-agents", "github.com/fielding/minecraft-agents")})
        oracle = StubOracle({"w1": choice("unknown", 0.8)})
        st = desktop([win(1, "Prism Launcher", "Prism Launcher 11.1.0", 1)], sessions=[sess("a", f"{HOME}/src/hack/minecraft-agents")])
        plan, _, errors = run(st, folio(entries=entries, paths=paths), oracles=[oracle], rules=HINT_RULES)
        self.assertEqual(errors, [])
        state, questions = oracle.questions[0]
        self.assertEqual(state["windows"]["w1"]["hint"], "Minecraft launcher")
        self.assertIn("minecraft-agents", questions["w1"]["criteria"])
        d = plan.decisions[1]
        self.assertEqual((d.outcome, d.target, d.resolution, d.detail["was"]), ("fixed", 9, "default:Prism Launcher", "jev"))
        self.assertEqual(moves(plan), {1: 9})

    def test_hinted_app_goes_to_the_project_when_the_model_is_confident(self):
        entries = ENTRIES + [entry("fielding/minecraft-agents", title="Minecraft Agents")]
        paths = dict(PATHS, **{f"{HOME}/src/hack/minecraft-agents": resolved_project("fielding/minecraft-agents", "github.com/fielding/minecraft-agents")})
        oracle = StubOracle({"w1": choice("minecraft-agents", 0.93)})
        st = desktop([win(1, "Prism Launcher", "Prism Launcher 11.1.0", 1)], sessions=[sess("a", f"{HOME}/src/hack/minecraft-agents")])
        plan, _, _ = run(st, folio(entries=entries, paths=paths), oracles=[oracle], rules=HINT_RULES)
        self.assertEqual(plan.decisions[1].project, "fielding/minecraft-agents")
        self.assertEqual(moves(plan), {1: 2})

    def test_default_without_hint_and_without_live_projects(self):
        oracle = StubOracle({})
        st = desktop([win(1, "1Password", "All Accounts", 2), win(2, "Prism Launcher", "Prism Launcher", 3)])
        plan, _, errors = run(st, folio(), oracles=[oracle], rules=HINT_RULES)
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {1: 8, 2: 9})
        self.assertEqual(plan.decisions[2].detail["was"], "no-candidates")
        self.assertEqual(plan.decisions[1].detail["was"], "other-app")
        self.assertEqual(oracle.questions, [], "an app with only a default_space is never put to the model")

    def test_title_hint_covers_apps_with_generic_names(self):
        oracle = StubOracle({"w1": choice("unknown", 0.9)})
        st = desktop([win(1, "java", "Minecraft* 26.2 - Multiplayer (3rd-party Server)", 6)],   # on notes
                     sessions=[sess("a", f"{HOME}/src/hack/ripguard")])
        plan, _, errors = run(st, folio(), oracles=[oracle], rules=HINT_RULES)
        self.assertEqual(errors, [])
        state, _ = oracle.questions[0]
        self.assertEqual(state["windows"]["w1"]["hint"], "Minecraft game client")
        self.assertEqual((moves(plan)[1], plan.decisions[1].resolution), (9, "default:java"), "default wins over eviction")

    def test_unhinted_apps_are_unchanged(self):
        st = desktop([win(1, "Prism Launcher", "Prism Launcher", 3)])
        plan, _, _ = run(st, folio())
        self.assertEqual((plan.decisions[1].outcome, plan.decisions[1].resolution), ("unresolved", "other-app"))

    def test_home_terminal_goes_where_configured(self):
        st = desktop([win(1, "Ghostty", "~", 4)])
        plan, _, _ = run(st, folio(), rules=HINT_RULES)
        self.assertEqual((moves(plan), plan.decisions[1].resolution), ({1: 1}, "default:home-terminal"))
        plan, _, _ = run(st, folio())
        self.assertEqual(moves(plan), {})


# ── Report ────────────────────────────────────────────────────────────────────

class Report(unittest.TestCase):
    def runs(self):
        def dec(wid, resolution, outcome="project", selected=None, confidence=None, accepted=None, implied=None, app="Ghostty", title="t"):
            d = {"window_id": wid, "app": app, "title": title, "space": 1, "outcome": outcome, "resolution": resolution}
            if selected is not None:
                d.update(selected=selected, confidence=confidence, accepted=accepted, detail={"implied_project": implied})
            return d
        return [
            {"ts": "2026-09-01T10:00:00Z", "mode": "live", "moves": [{}, {}], "validation": {"ok": True},
             "oracles": [{"name": "jev", "error": None}, {"name": "legacy:x", "error": "HTTP 404"}],
             "decisions": [dec(1, "fixed:comms", "fixed", app="Slack"), dec(2, "title-path"),
                           dec(3, "jev", "unresolved", "session_1", 0.6, False, "fielding/ripguard"),
                           dec(4, "jev", "unresolved", "unknown", 0.95, False, None, app="Google Chrome", title="Mail")],
             "shadow": [dec(3, "legacy:x", "unresolved", "session_1", 0.9, True, "fielding/ripguard"),
                        dec(4, "legacy:x", "unresolved", "unknown", 0.7, False, None)],
             "corrections": []},
            {"ts": "2026-09-01T11:00:00Z", "mode": "live", "moves": [], "validation": {"ok": True}, "oracles": [],
             "decisions": [dec(3, "jev", "project", "session_1", 0.8, True, "fielding/ripguard"),
                           dec(4, "jev", "unresolved", "unknown", 0.9, False, None, app="Google Chrome", title="Mail")],
             "shadow": [],
             "corrections": [{"window_id": 3, "kind": "user-placed", "from_space": 1, "to_space": 2, "now_project": "fielding/ripguard",
                              "previous": {"resolution": "jev", "confidence": 0.6}, "agreed": {"jev": True, "legacy:x": True}},
                             {"window_id": 9, "kind": "moved-away", "from_space": 2, "to_space": 7, "previous": {"resolution": "jev", "confidence": 0.75},
                              "agreed": {"jev": False}}]},
        ]

    def test_report_shows_latency_per_path(self):
        runs = self.runs()
        runs[0]["timings"] = {"gather": 300, "gather.tabs": 120, "folio": 80, "folio_calls": 9, "deterministic": 40,
                              "execute": 60, "desktop_ready": 900, "total": 3400}
        runs[0]["oracles"] = [{"name": "jev", "error": None, "elapsed_ms": 450, "meta": {"input_tokens": 3000, "output_tokens": 300}},
                              {"name": "legacy:x", "error": None, "elapsed_ms": 2500, "meta": {"input_tokens": 3100, "output_tokens": 100}}]
        text = yo.report(runs)
        self.assertIn("latency per path:", text)
        self.assertRegex(text, r"desktop organized \(everything the user waits for\)\s+median 900ms, p95 900ms, n=1")
        self.assertIn("of which Chrome tabs", text)
        self.assertIn("jev", text.split("latency per path:")[1])
        self.assertIn("median 2500ms", text)
        self.assertIn("avg 3300 tokens/call", text)
        self.assertNotIn("latency per path", yo.report(self.runs()), "old records without timings add no section")

    def test_report_summarises_models_and_thresholds(self):
        text = yo.report(self.runs())
        self.assertIn("runs: 2 (live 2); moves: 2; validation failures: 0", text)
        self.assertIn("oracle errors: legacy:x 1", text)
        self.assertIn("jev: 4 answers, 2 unknown, 2 named, 1 accepted", text)
        self.assertIn("legacy:x: 2 answers, 1 unknown, 1 named, 1 accepted", text)
        self.assertIn("vs jev: same project 1, both unknown 1", text)
        self.assertIn("jev: 1 right, 1 wrong", text)
        self.assertIn("0.7: accepted 1 → 0 right, 1 wrong", text)
        self.assertIn("0.5: accepted 2 → 1 right, 1 wrong", text)
        self.assertIn("Google Chrome: Mail", text)
        self.assertEqual(yo.report([]), "no runs logged")

    def test_load_runs_filters_by_age_and_skips_garbage(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "runs.jsonl")
            with open(path, "w", encoding="utf-8") as fh:
                fh.write("not json\n")
                for r in self.runs():
                    fh.write(json.dumps(r) + "\n")
                fh.write(json.dumps({"ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "mode": "live"}) + "\n")
            self.assertEqual(len(yo.load_runs(path, None)), 3)
            self.assertEqual(len(yo.load_runs(path, 1)), 1, "only the fresh record is within a day")
            self.assertEqual(yo.load_runs(os.path.join(tmp, "missing.jsonl"), None), [])


# ── Allocation ────────────────────────────────────────────────────────────────

def project_windows(*specs):
    """specs: (window id, project dir basename, space). Returns windows + sessions resolving each."""
    windows, sessions = [], []
    for wid, name, space in specs:
        windows.append(win(wid, "Ghostty", f"~/src/hack/{name}", space))
    return windows, sessions


class Allocation(unittest.TestCase):
    def setUp(self):
        self.paths = dict(PATHS, **{
            f"{HOME}/src/hack/box": resolved_project("fielding/box", "github.com/fielding/box"),
            f"{HOME}/src/hack/pilot": resolved_project("fielding/pilot", "github.com/fielding/pilot"),
            f"{HOME}/src/hack/resume": resolved_project("fielding/resume", "github.com/fielding/resume"),
            f"{HOME}/src/hack/dotfiles": resolved_project("fielding/dotfiles", "github.com/fielding/dotfiles"),
        })

    def run_alloc(self, specs, labels=None, stored=None):
        windows, _ = project_windows(*specs)
        st = desktop(windows, labels=labels)
        plan, _, errors = run(st, folio(paths=self.paths), stored=stored)
        self.assertEqual(errors, [])
        return plan

    def test_existing_slot_assignment_is_preserved(self):
        plan = self.run_alloc([(1, "ripguard", 1), (2, "Nwallet", 1), (3, "review-crew", 1)], labels={2: "ripguard", 3: "nwallet"})
        self.assertEqual(plan.slots.assignments, {2: "fielding/ripguard", 3: "fielding/nwallet", 4: "fielding/review-crew", 5: None})
        self.assertEqual(plan.labels, {4: "review-crew"}, "untouched slots keep their current label")
        self.assertEqual(moves(plan), {1: 2, 2: 3, 3: 4})

    def test_new_project_gets_first_available_slot(self):
        plan = self.run_alloc([(1, "ripguard", 1)])
        self.assertEqual(plan.slots.assignments[2], "fielding/ripguard")
        self.assertEqual(moves(plan), {1: 2})

    def test_stored_reference_disambiguates_duplicate_slugs(self):
        paths = dict(self.paths, **{f"{HOME}/src/hack/website": resolved_project("venice/website", "github.com/veniceai/website")})
        windows, _ = project_windows((1, "website", 1))
        st = desktop(windows, labels={3: "website"})
        plan, _, _ = run(st, folio(paths=paths), stored={3: "venice/website"})
        self.assertEqual(plan.slots.assignments[3], "venice/website")

    def test_separate_projects_never_share_and_same_project_shares(self):
        plan = self.run_alloc([(1, "ripguard", 1), (2, "ripguard", 6), (3, "review-crew", 1), (4, "review-crew", 9)])
        targets = {ref: {plan.decisions[w].target for w in ids} for ref, ids in
                   {"fielding/ripguard": (1, 2), "fielding/review-crew": (3, 4)}.items()}
        self.assertEqual(len(targets["fielding/ripguard"]), 1)
        self.assertEqual(len(targets["fielding/review-crew"]), 1)
        self.assertNotEqual(targets["fielding/ripguard"], targets["fielding/review-crew"])

    def test_more_than_four_projects_overflow_deterministically(self):
        specs = [(1, "ripguard", 1), (2, "ripguard", 1), (3, "ripguard", 1),          # 3 windows, active
                 (4, "review-crew", 1), (5, "review-crew", 1),                        # 2 windows, active
                 (6, "Nwallet", 1), (7, "Nwallet", 1),                                # 2 windows, active
                 (8, "fite", 1),                                                      # 1 window, maintained
                 (9, "box", 1),                                                       # 1 window, maintained
                 (10, "dotfiles", 1)]                                                 # 1 window, active
        plan = self.run_alloc(specs)
        self.assertEqual(plan.slots.assignments, {2: "fielding/ripguard", 3: "fielding/nwallet", 4: "fielding/review-crew", 5: "fielding/dotfiles"})
        self.assertEqual(plan.slots.overflow, ["fielding/box", "fielding/fite"])
        self.assertEqual(moves(plan)[8], yo.SPACE_SCRATCH)
        self.assertEqual(moves(plan)[9], yo.SPACE_SCRATCH)
        again = self.run_alloc(specs)
        self.assertEqual(again.slots.assignments, plan.slots.assignments, "allocation is a pure function of state")

    def test_dead_project_slot_is_reclaimed_when_needed(self):
        plan = self.run_alloc([(1, "ripguard", 1), (2, "review-crew", 1), (3, "Nwallet", 1), (4, "fite", 1)],
                              labels={2: "pilot", 3: "ripguard"})
        self.assertEqual(plan.slots.assignments[3], "fielding/ripguard")
        self.assertNotIn("fielding/pilot", plan.slots.assignments.values())
        self.assertEqual(set(plan.slots.assignments.values()), {"fielding/ripguard", "fielding/review-crew", "fielding/nwallet", "fielding/fite"})
        self.assertEqual(plan.slots.assignments[2], "fielding/fite", "the stale slot is the last free slot taken")
        self.assertEqual(plan.slots.overflow, [])

    def test_stale_label_is_kept_until_the_slot_is_needed(self):
        plan = self.run_alloc([(1, "ripguard", 1)], labels={2: "pilot"})
        self.assertEqual(plan.slots.assignments[3], "fielding/ripguard")
        self.assertEqual(plan.slots.labels[2], "pilot")
        self.assertNotIn(2, plan.labels)

    def test_prefers_the_slot_where_windows_already_sit(self):
        plan = self.run_alloc([(1, "ripguard", 4), (2, "ripguard", 4), (3, "review-crew", 1)])
        self.assertEqual(plan.slots.assignments[4], "fielding/ripguard")
        self.assertEqual(plan.slots.assignments[2], "fielding/review-crew")
        self.assertNotIn(1, moves(plan))

    def test_slot_holding_unresolved_windows_is_used_last(self):
        windows, _ = project_windows((1, "ripguard", 1))
        windows.append(win(9, "Google Chrome", "Something - Google Chrome", 2))
        windows.append(win(10, "Google Chrome", "Else - Google Chrome", 3))
        st = desktop(windows)
        plan, _, _ = run(st, folio(paths=self.paths))
        self.assertEqual(plan.slots.assignments[4], "fielding/ripguard")


# ── Safety ────────────────────────────────────────────────────────────────────

class Safety(unittest.TestCase):
    def base(self):
        st = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 1), win(2, "Slack", "Slack", 2)])
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        return st, plan

    def test_nonexistent_window_id_fails_validation(self):
        st, plan = self.base()
        plan.moves.append(yo.Move(999, "Ghost", "?", 1, 2))
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("unknown window 999" in e for e in errors))

    def test_conflicting_project_assignments_are_rejected(self):
        st, plan = self.base()
        plan.slots.assignments[3] = "fielding/ripguard"
        plan.slots.labels[3] = "ripguard"
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("assigned to slots 2 and 3" in e for e in errors))

    def test_two_projects_in_one_slot_are_rejected(self):
        st = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 1), win(2, "Ghostty", "~/src/hack/review-crew", 1)])
        plan, _, _ = run(st, folio())
        plan.decisions[2].target = plan.decisions[1].target
        plan.moves = [yo.Move(2, "Ghostty", "x", 1, plan.decisions[1].target), yo.Move(1, "Ghostty", "x", 1, plan.decisions[1].target)]
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("belongs on" in e for e in errors))

    def test_label_must_match_occupying_project(self):
        st, plan = self.base()
        plan.slots.labels[2] = "nwallet"
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("label 'nwallet' does not match fielding/ripguard" in e for e in errors))

    def test_jev_cannot_override_fixed_routing(self):
        oracle = StubOracle({"w2": choice("ripguard", 0.99)})
        st = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 1), win(2, "Slack", "ripguard - Slack", 2),
                      win(3, "Ghostty", "✳ Work", 1)],
                     sessions=two_agent_sessions())
        plan, _, errors = run(st, folio(), oracles=[oracle])
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan)[2], yo.SPACE_COMMS)
        _, questions = oracle.questions[0]
        self.assertNotIn("w2", questions, "fixed windows are never put to the model")
        plan.decisions[2] = yo.decision_for(st.window(2), "project", project="fielding/ripguard", resolution="jev", accepted=True)
        plan.decisions[2].target = 2
        plan.moves = [yo.Move(2, "Slack", "ripguard - Slack", 2, 2)]
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("fixed to 10" in e for e in errors))

    def test_unresolved_and_rejected_windows_never_move(self):
        st, plan = self.base()
        plan.decisions[1].outcome = "unresolved"
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("unresolved window must not move" in e for e in errors))
        plan.decisions[1].outcome = "project"
        plan.decisions[1].accepted = False
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("must not move" in e for e in errors))

    def test_moves_only_when_space_differs(self):
        st = desktop([win(1, "Slack", "Slack", 10), win(2, "Ghostty", "~/src/hack/ripguard", 2)], labels={2: "ripguard"})
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(plan.moves, [])
        self.assertEqual(plan.labels, {})

    def test_missing_target_space_skips_those_windows_only(self):
        st = desktop([win(1, "Slack", "Slack", 2), win(2, "Obsidian", "notes", 2), win(3, "Ghostty", "~/src/hack/ripguard", 1)])
        st.spaces = [sp for sp in st.spaces if sp.index != 10]
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(moves(plan), {2: 6, 3: 2}, "comms window is skipped, everything else proceeds")
        self.assertEqual(plan.decisions[1].detail["skipped"], "space 10 does not exist")
        self.assertIsNone(plan.decisions[1].target)

    def test_fixed_space_labels_are_reasserted(self):
        st = desktop([win(1, "Slack", "Slack", 10)])
        st.spaces = [yo.Space(i, "main" if i == 1 else "") for i in range(1, 11)]
        plan, _, errors = run(st, folio())
        self.assertEqual(errors, [])
        self.assertEqual(plan.labels, {6: "notes", 7: "scratch", 8: "inbox", 9: "media", 10: "comms"})
        plan.labels[6] = "todo"
        errors = yo.validate_plan(plan, st, RULES, yo.Registry.from_entries(ENTRIES))
        self.assertTrue(any("may only be labelled 'notes'" in e for e in errors))

    def test_dry_run_performs_no_mutations(self):
        _, plan = self.base()
        with mock.patch.object(yo.subprocess, "run", side_effect=AssertionError("desktop touched")):
            self.assertEqual(yo.execute_plan(plan, dry_run=True), [])

    def test_live_execution_issues_yabai_commands(self):
        _, plan = self.base()
        calls = []
        with mock.patch.object(yo.subprocess, "run", side_effect=lambda cmd, **kw: calls.append(cmd) or mock.Mock(returncode=0)), \
             mock.patch.object(yo, "which", return_value="/usr/bin/true"):
            self.assertEqual(yo.execute_plan(plan, dry_run=False), [])
        self.assertIn(["/usr/bin/true", "-m", "space", "2", "--label", "ripguard"], calls)
        self.assertIn(["/usr/bin/true", "-m", "window", "1", "--space", "2"], calls)
        self.assertIn(["/usr/bin/true", "-m", "window", "2", "--space", "10"], calls)

    def test_main_dry_run_from_state_file_touches_nothing(self):
        with tempfile.TemporaryDirectory() as tmp:
            state_file = os.path.join(tmp, "state.json")
            st = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 1), win(2, "Slack", "Slack", 2)])
            with open(state_file, "w", encoding="utf-8") as fh:
                json.dump(st.to_dict(), fh)
            fake = folio()
            with mock.patch.object(yo, "FolioCLI", return_value=fake), \
                 mock.patch.object(yo, "LOG_DIR", os.path.join(tmp, "log")), \
                 mock.patch.object(yo, "STATE_DIR", os.path.join(tmp, "state")), \
                 mock.patch.object(yo, "git_probe", fake.git), \
                 mock.patch.object(yo.subprocess, "run", side_effect=AssertionError("desktop touched")), \
                 mock.patch("sys.stdout"):
                self.assertEqual(yo.main(["--state", state_file, "--no-jev", "--no-legacy", "--json"]), 0)
            with open(os.path.join(tmp, "log", "runs.jsonl"), encoding="utf-8") as fh:
                record = json.loads(fh.readline())
            self.assertEqual(record["mode"], "state-file")
            self.assertEqual({m["window_id"]: m["to_space"] for m in record["moves"]}, {1: 2, 2: 10})
            self.assertEqual(set(record["timings"]) >= {"decide", "deterministic", "desktop_ready", "total", "folio", "folio_calls"}, True)
            self.assertTrue(record["validation"]["ok"])
            self.assertFalse(os.path.exists(os.path.join(tmp, "state", "slots.json")), "dry runs must not persist slot state")
            self.assertFalse(os.path.exists(os.path.join(tmp, "state", "last-run.json")), "dry runs must not snapshot placements")


# ── Corrections ───────────────────────────────────────────────────────────────

class Corrections(unittest.TestCase):
    def placed(self):
        """A live run that placed a ripguard terminal on slot 2 and left a spinner unresolved with a rejected Jev answer."""
        jev = StubOracle({"w2": choice("session_2", 0.5, session_1=0.4)})
        legacy = StubOracle({"w2": choice("session_1", 0.9)}, name="legacy:gpt-5.5")
        st = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 1), win(2, "Ghostty", "✳ Fix websocket fallback", 1)],
                     sessions=two_agent_sessions())
        plan, _, _ = run(st, folio(), oracles=[jev])
        shadow_run(plan, folio(), legacy)
        return st, yo.snapshot_windows(st, plan, "2026-09-18T13:00:00Z")

    def test_snapshot_records_placement_and_every_answer(self):
        _, snap = self.placed()
        self.assertEqual(snap["windows"]["1"]["space"], 2, "snapshot stores where the window was put, not where it was")
        w2 = snap["windows"]["2"]
        self.assertEqual((w2["outcome"], w2["selected"], w2["accepted"], w2["implied_project"]),
                         ("unresolved", "session_2", False, "fielding/review-crew"))
        self.assertEqual(w2["shadow"]["legacy:gpt-5.5"]["implied_project"], "fielding/ripguard")
        json.dumps(snap)

    def test_no_change_means_no_corrections(self):
        st, snap = self.placed()
        after = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 2), win(2, "Ghostty", "✳ Fix websocket fallback", 1)],
                        labels={2: "ripguard"})
        self.assertEqual(yo.detect_corrections(after, snap, context(folio())[0]), [])
        self.assertEqual(yo.detect_corrections(after, None, context(folio())[0]), [])

    def test_user_placing_an_unresolved_window_grades_both_models(self):
        _, snap = self.placed()
        after = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 2), win(2, "Ghostty", "✳ Fix websocket fallback", 3)],
                        labels={2: "ripguard", 3: "review-crew"})
        [c] = yo.detect_corrections(after, snap, context(folio())[0])
        self.assertEqual((c["kind"], c["from_space"], c["to_space"], c["now_project"]), ("user-placed", 1, 3, "fielding/review-crew"))
        self.assertEqual(c["agreed"], {"jev": True, "legacy:gpt-5.5": False})
        self.assertEqual(c["previous"]["confidence"], 0.5)

    def test_window_moved_away_from_our_placement(self):
        _, snap = self.placed()
        after = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 7), win(2, "Ghostty", "✳ Fix websocket fallback", 1)],
                        labels={2: "ripguard"})
        [c] = yo.detect_corrections(after, snap, context(folio())[0])
        self.assertEqual((c["kind"], c["from_space"], c["to_space"], c["previous"]["project"]),
                         ("moved-away", 2, 7, "fielding/ripguard"))
        self.assertNotIn("agreed", c, "scratch is not a project slot, so nothing can be graded")

    def test_space_reorder_is_not_a_correction(self):
        st, snap = self.placed()
        snap["spaces"] = {"2": "uuid-two", "3": "uuid-three"}
        # Mission Control swapped the two slots: the space that was index 2 is now index 3 and kept its windows.
        after = desktop([win(1, "Ghostty", "~/src/hack/ripguard", 3), win(2, "Ghostty", "✳ Fix websocket fallback", 1)],
                        labels={2: "review-crew", 3: "ripguard"})
        after.spaces = [yo.Space(sp.index, sp.label, {2: "uuid-three", 3: "uuid-two"}.get(sp.index, "")) for sp in after.spaces]
        self.assertEqual(yo.detect_corrections(after, snap, context(folio())[0]), [])
        # ...but a window that really did move to the other space is still reported, with remapped indices.
        after.windows[0] = win(1, "Ghostty", "~/src/hack/ripguard", 2)
        [c] = yo.detect_corrections(after, snap, context(folio())[0])
        self.assertEqual((c["from_space"], c["to_space"], c["now_project"]), (3, 2, "fielding/review-crew"))

    def test_last_run_round_trip(self):
        _, snap = self.placed()
        with tempfile.TemporaryDirectory() as tmp, mock.patch.object(yo, "STATE_DIR", tmp):
            yo.save_last_run(snap)
            self.assertEqual(yo.load_last_run(), snap)


# ── Helpers and parsing ───────────────────────────────────────────────────────

class Helpers(unittest.TestCase):
    def test_normalize_remote(self):
        cases = {
            "git@github.com:fielding/ripguard.git": "github.com/fielding/ripguard",
            "https://github.com/veniceai/outerface": "github.com/veniceai/outerface",
            "ssh://git@github.com/veniceai/outerface.git": "github.com/veniceai/outerface",
            "github.com/fielding/nested/ns/repo": "github.com/fielding/nested/ns/repo",
            "/Users/fielding/src/work/venice/.incoming/outerface-all-refs.bundle": None,
            "file:///tmp/x.git": None,
        }
        for url, expected in cases.items():
            self.assertEqual(yo.normalize_remote(url), expected, url)

    def test_title_path_recovers_elided_prefix_only_when_unique(self):
        st = desktop([], sessions=[sess("a", f"{HOME}/src/hack/fite"), sess("b", f"{HOME}/src/oss/hack/fite")],
                     repo_dirs=[f"{HOME}/src/hack/ripguard"])
        self.assertIsNone(yo.title_path("…/hack/fite", st), "two live cwds end in /hack/fite")
        self.assertEqual(yo.title_path("…/src/hack/fite", st), f"{HOME}/src/hack/fite")
        self.assertEqual(yo.title_path("…/oss/hack/fite", st), f"{HOME}/src/oss/hack/fite")
        self.assertEqual(yo.title_path("…/hack/ripguard", st), f"{HOME}/src/hack/ripguard")
        self.assertEqual(yo.title_path("~/etc", st), f"{HOME}/etc")
        self.assertEqual(yo.title_path("[~/src/hack/review]", st), f"{HOME}/src/hack/review")
        self.assertIsNone(yo.title_path("✳ Fix things", st))
        self.assertIsNone(yo.title_path("m5.local: ~", st))

    def test_lexical_strength(self):
        registry = yo.Registry.from_entries(ENTRIES)
        strong, weak = yo.lexical_matches("Inference proxy PR review", registry)
        self.assertEqual([p.reference for p in strong], ["venice/inference-proxy"])
        strong, weak = yo.lexical_matches("Please resume the box upload", registry)
        self.assertEqual(strong, [])
        self.assertEqual(sorted(p.reference for p in weak), ["fielding/box", "fielding/resume"])
        strong, _ = yo.lexical_matches("venice/anon-email handoff", registry)
        self.assertEqual([p.reference for p in strong], ["venice/anon-email"])
        strong, _ = yo.lexical_matches("Dropbox settings", registry)
        self.assertEqual(strong, [])

    def test_unique_slug_prefers_unarchived(self):
        registry = yo.Registry.from_entries(ENTRIES)
        self.assertEqual(registry.unique_slug("website").reference, "venice/website")
        self.assertEqual(registry.unique_slug("RIPGUARD").reference, "fielding/ripguard")
        self.assertIsNone(registry.unique_slug("nope"))

    def test_herdr_title_regex_from_format(self):
        rx = yo.herdr_title_regex(["m5", "m5.local"], "{hostname}: {workspace}")
        self.assertEqual(rx.match("m5.local: Nwallet").group("workspace"), "Nwallet")
        self.assertIsNone(rx.match("fielding@m5: ~"))
        rx = yo.herdr_title_regex(["m5"], "[{workspace}] {terminal_title}")
        self.assertEqual(rx.match("[etc] ✳ refactor").group("workspace"), "etc")

    def test_ghostty_sessions_from_process_snapshot(self):
        procs = [
            yo.Proc(1104, 1, 1104, -1, "??", "/Applications/Ghostty.app/Contents/MacOS/ghostty"),
            yo.Proc(57787, 1104, 57787, 65750, "ttys012", "/usr/bin/login -q -flp fielding /bin/bash --noprofile --norc -c exec -l /bin/zsh"),
            yo.Proc(57788, 57787, 57788, 65750, "ttys012", "-/bin/zsh"),
            yo.Proc(65750, 57788, 65750, 65750, "ttys012", "/bin/sh /usr/bin/command claude --dangerously-skip-permissions"),
            yo.Proc(65754, 65750, 65750, 65750, "ttys012", "claude --dangerously-skip-permissions"),
            yo.Proc(64732, 1104, 64732, 26802, "ttys002", "/usr/bin/login -q -flp fielding /bin/bash --noprofile --norc -c exec -l /bin/zsh"),
            yo.Proc(64733, 64732, 64733, 26802, "ttys002", "-/bin/zsh"),
            yo.Proc(26802, 64733, 26802, 26802, "ttys002", "herdr"),
            yo.Proc(53906, 1104, 53906, 53925, "ttys010", "/usr/bin/login -q -flp fielding /bin/bash --noprofile --norc -c exec -l /bin/zsh"),
            yo.Proc(53925, 53906, 53925, 53925, "ttys010", "-/bin/zsh"),
        ]
        cwds = {65754: f"{HOME}/Downloads", 26802: f"{HOME}/src/hack/Nwallet", 53925: f"{HOME}/src/hack/fite"}
        with mock.patch.object(yo, "cwd_of_pids", return_value=cwds):
            sessions = {s.id: s for s in yo.ghostty_sessions(procs, RULES)}
        self.assertEqual(sessions["ghostty:ttys012"].agent, "claude")
        self.assertEqual(sessions["ghostty:ttys012"].cwd, f"{HOME}/Downloads")
        self.assertTrue(sessions["ghostty:ttys002"].is_hub)
        self.assertIsNone(sessions["ghostty:ttys010"].agent)
        self.assertEqual(sessions["ghostty:ttys010"].cwd, f"{HOME}/src/hack/fite")

    def test_state_round_trips_through_json(self):
        st = desktop([win(1, "Ghostty", "~/etc", 1)], labels={2: "ripguard"}, sessions=two_agent_sessions(),
                     ports=[yo.ListeningPort(5173, 1, "node", f"{HOME}/src/hack/ripguard")], herdr=["etc"])
        again = yo.DesktopState.from_dict(json.loads(json.dumps(st.to_dict())))
        self.assertEqual(again.to_dict(), st.to_dict())


# ── Replay of a real desktop snapshot ─────────────────────────────────────────

class LiveDesktopReplay(unittest.TestCase):
    """The fixture is a `--dump-state` of the real desktop (2026-09-18). Folio answers are the ones the real
    registry gave for those paths."""

    def test_replay(self):
        with open(FIXTURES / "live-desktop.json", encoding="utf-8") as fh:
            st = yo.DesktopState.from_dict(json.load(fh))
        plan, runs, errors = run(st, folio())
        self.assertEqual(errors, [])
        by_app = {(d.app, d.title): d for d in plan.decisions.values()}
        hubs = [d for d in plan.decisions.values() if d.app == "Ghostty" and d.title.startswith("m5.local: ")]
        self.assertEqual([(d.outcome, d.target, d.resolution) for d in hubs], [("fixed", 1, "fixed:hub")])
        self.assertEqual(by_app[("Ghostty", "…/src/hack/fite")].project, "fielding/fite")
        self.assertEqual(by_app[("Ghostty", "…/etc/bin/bin")].project, "fielding/dotfiles")
        self.assertEqual(by_app[("Ghostty", "…/notes/Projects/apprentice")].project, "fielding/apprentice")
        self.assertEqual(by_app[("Ghostty", "✳ Seeking.min.js analysis preparation")].outcome, "unresolved")
        self.assertEqual(by_app[("Problem Reporter", "")].outcome, "ignored")
        chrome = {d.title[:12]: d for d in plan.decisions.values() if d.app == "Google Chrome"}
        weather = chrome.pop("wttr.in — We")
        self.assertEqual((weather.resolution, weather.target), ("evict:media", 8), "a weather page has no business on media")
        self.assertTrue(all(d.outcome == "unresolved" for d in chrome.values()), "the other four are unprovable and stay")
        targets = moves(plan)
        self.assertEqual(targets[327], 10)      # Slack
        self.assertEqual(targets[2726], 6)      # Obsidian
        self.assertEqual(targets[13041], 10)    # Messages
        self.assertEqual(len({plan.slots.slot_of(r) for r in ("fielding/fite", "fielding/dotfiles", "fielding/apprentice")}), 3)
        self.assertEqual(runs, [])


if __name__ == "__main__":
    unittest.main()

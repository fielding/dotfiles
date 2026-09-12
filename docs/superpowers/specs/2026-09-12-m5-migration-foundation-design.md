# M5 Migration Foundation Design

## Context

The M5 Max will become the only daily-driver Mac. The current M4 must remain a
recoverable fallback until the M5 has passed acceptance checks, but it must stop
writing notes after cutover. Time Machine is intentionally out of scope. The
external 5 TB device will hold an organized, independently verified backup rather
than a bootable clone. The existing volume is intentionally accepted without
encryption.

The migration foundation has two coupled responsibilities:

1. Make the configuration needed to rebuild a working environment portable and
   trustworthy.
2. Move the notes and Glean workflow without creating two writable authorities or
   placing the private vault on GitHub.

Bulk project migration and the final full-machine archival pass depend on this
foundation but will be designed and executed as later workstreams.

## Goals

- Turn the reviewed state of `~/etc` into a clean sequence of meaningful,
  independently valid commits.
- Make the dotfiles bootstrap safe on a fresh Mac, including homes where
  `.codex` and `.claude` already contain local state.
- Preserve private notes with local history and an external backup, without using
  GitHub as a notes remote.
- Establish the M5 as the only writable notes/Glean machine after cutover.
- Preserve an additive, hash-verifiable rollback path on the M4 and external
  device until acceptance is complete.
- Separate portable configuration from credentials, histories, caches, and
  machine-specific state.

## Non-goals

- Time Machine, a bootable clone, encrypting, or erasing/repartitioning the
  existing external device.
- Making the M4 and M5 simultaneous notes writers.
- Publishing the notes vault to GitHub, including a private GitHub repository.
- Copying entire application state directories as configuration.
- Repairing or migrating every project, large cache, VM image, or archived custom
  service in this workstream.
- Redesigning Bridge, Syncthing, mouse capture, or other retired/deprioritized
  services.

## Safety invariants

1. No source is deleted, overwritten, or cleaned before two verified copies exist
   and the M5 passes acceptance.
2. Migration transfers and snapshot creation are additive. An existing
   destination is inventoried and compared before any write. The only mutable
   backup object is the small `LATEST` pointer for a verified current-mirror
   generation; replacing that pointer is permitted only after the new generation
   is complete and verified.
3. Verification uses manifests and cryptographic hashes for irreplaceable data;
   a successful copy command alone is not acceptance.
4. Secrets, auth tokens, private keys, machine identities, sockets, and caches are
   never committed to Git.
5. Notes have exactly one writable authority. The M4 becomes read-only/frozen
   before the M5 begins normal note capture.
6. The external volume's lack of encryption is an accepted user decision. The
   migration does not duplicate existing credential exports into the new backup
   tree, and credentials are re-provisioned rather than copied as general machine
   state.
7. Existing dirty work is preserved and factored; broad staging and destructive
   Git commands are prohibited.

## Target state

### M5 active state

- `~/etc`: Git-tracked portable configuration, bootstrapping, and diagnostics.
- `~/.agents`: its own reviewed repository for portable agent assets.
- Notes vault: a normal local directory with a local Git repository and no
  network remote.
- Agent histories: only explicitly allowlisted history/session data copied from
  `.claude`, `.cursor`, and `.codex`; configuration is rebuilt separately.
- Credentials and auth: re-established through the owning applications or secure
  credential stores, not copied wholesale.

### External backup state

Use the existing APFS volume mounted at `/Volumes/5teeb`. Create the new backup
only below `/Volumes/5teeb/M4-to-M5/`; do not move, rename, merge, or reorganize
the volume's existing loose contents during this migration. Before every backup,
verify the destination by APFS volume UUID rather than trusting the mount name
alone. The approved volume UUID is
`A2E8D7B4-C1D1-4BEA-952E-799EC77F4C3D`, observed during the M4 inventory.

Before the first write, record that value in the local-only file
`~/.config/m5-migration/external-volume-uuid` on the M4. Copy and verify that
identity file independently on the M5; do not derive it from the currently
mounted volume. Backup jobs read the expected value only from this local file and
compare it with `diskutil info` for the actual mount. A copy also appears in
`M4-to-M5/00-manifests/storage/5teeb.json` for audit, but the external copy is not
the job's trust source. Use this stable organization below the new root:

```text
00-manifests/       machine inventories, transfer manifests, and verification logs
10-current/         browsable current mirrors of irreplaceable user data
20-snapshots/       dated, immutable-by-convention snapshots
30-machine-state/   package lists, service definitions, and system diagnostics
40-archives/        intentionally retired data and applications
90-quarantine/      ambiguous material pending a keep/archive/delete decision
```

The notes vault appears in an immutable generation below `10-current/notes/` and
a dated entry below `20-snapshots/notes/`. Generation directory names use a UTC
timestamp followed by the first 12 hexadecimal characters of the manifest hash,
for example `20260912T180000Z-a1b2c3d4e5f6`. `10-current/notes/LATEST` contains
the relative name of the most recent fully verified generation. A backup creates
and verifies a new generation before atomically replacing `LATEST`; it never
updates a generation in place. The generation is directly browsable whenever the
verified external volume is mounted. A snapshot is also never updated in place.

### M4 fallback state

- Source data remains intact.
- Note-writing jobs and interactive note capture are disabled after the final
  transfer.
- A cutover marker at `~/.local/state/m5-migration/cutover.json` records the
  timestamp, source and final manifest identifiers, and final notes commit. The
  same record is copied to the M5 path and to
  `00-manifests/m5-migration/cutover.json` on the external volume.
- The machine is retained unchanged until the explicit post-acceptance cleanup
  phase.

## Workstream A: dotfiles cleanup and portability

### Review and factor the current worktree

Every current change in `~/etc` must be reviewed for intent, sensitivity, and
portability before it is staged. Changes that are sound are split into atomic
commits by purpose. The expected groups are:

- Mouse-report filtering and focus reporting.
- Gate knowledge-base path and trusted-reviewer configuration.
- Ghostty font/shader configuration.
- Shell aliases and environment configuration.
- Global Git ignore additions.
- Claude settings and themes.
- Herdr controls and SketchyBar mode display.
- The `paywat` spelling correction.

This list is an audit checklist, not permission to commit blindly. In particular,
duplicate NVM initialization and hard-coded machine paths must be corrected or
excluded rather than memorialized.

### Reconcile live configuration

- Compare the live Codex configuration with the tracked candidate and classify
  each difference as portable configuration, local-only preference, credential,
  or obsolete state.
- Review Cursor MCP configuration for credentials and machine-local endpoints.
- Review dirty `.agents` lock/bundle metadata in its own repository; do not mix it
  into `~/etc` commits.
- Confirm that Claude themes and settings contain no credentials or generated
  state before tracking them.

### Harden bootstrap behavior

The bootstrap must use Stow without directory folding so it can link managed
files into existing `.codex`, `.claude`, and similar state directories instead of
replacing those directories with repository symlinks. Existing directory
symlinks on the M5 must be detected and reported before restowing.

Add a read-only doctor/preflight mode that reports:

- incorrect whole-directory symlink topology;
- missing required commands;
- broken LaunchAgent program targets;
- hard-coded paths tied to the source username, Homebrew prefix, or package
  version;
- collisions where a destination file already exists and differs from the
  tracked source;
- which optional service groups are present, absent, or intentionally retired.

The doctor must not repair, delete, unlink, or overwrite anything. Repairs happen
only in explicit later commands after the report is reviewed.

### Service policy

The portable foundation must preserve Cadence, the CLI proxy, yabai, borders,
skhd, Karabiner, and the active note/Glean workflow. Version-pinned executable
paths, such as a Homebrew Cellar path in `yabairc`, must resolve dynamically or
through a stable prefix.

Bridge, Syncthing, and mouse capture must not be enabled automatically on the M5.
Their configurations and accumulated data can be archived later. Existing service
definitions may remain documented or tracked when useful, but bootstrap must mark
them retired/optional rather than active defaults.

### Commit and validation policy

Each commit performs one coherent transformation and uses the repository's
atomic action vocabulary. Stage exact paths only. Before and after each commit,
run the narrowest relevant syntax/config parser and smoke check. At minimum:

- `bash -n` for shell scripts;
- configuration-specific parsers where available;
- `git diff --check`;
- bootstrap listing and doctor checks;
- a Stow simulation against a disposable home containing pre-existing `.codex`
  and `.claude` directories.

The full reviewed stack is pushed only after all commits pass their checks and a
secret scan finds no credential material.

## Workstream B: notes and Glean cutover

### Prepare the source vault

1. Inventory ignore rules, untracked/generated content, plugins, attachments,
   local Git state, and existing sync-conflict files.
2. Classify old conflict files without deleting them; unresolved or ambiguous
   conflicts remain preserved and are called out in the manifest.
3. Pause every writer: Obsidian, Glean capture/summary jobs, `sync-tix-to-vault`,
   and any agent capture hooks that write into the vault.
4. Confirm the vault is quiescent by comparing two inventories separated by a
   short observation window.
5. Record a local Git snapshot of the intended vault state. The repository has no
   remote.

### Transfer and verify

1. Produce source manifest M0 containing relative path, type, size, modification
   time, and SHA-256 for each regular file.
2. Copy the complete vault, including `.git`, to the M5 without overwriting any
   pre-existing destination.
3. Produce the same manifest on the M5 and compare path set, size, and hashes to
   M0.
4. Copy the verified vault into a new, uniquely named generation below the
   external `M4-to-M5/10-current/notes/` tree.
5. Create a separately dated external snapshot and verify both external copies
   against M0. Replace `10-current/notes/LATEST` only after both comparisons
   succeed.
6. Record all commands, tool versions, timestamps, mount identity, and comparison
   results in `00-manifests/` without recording secrets.

A mismatch stops cutover. The source stays paused while the mismatch is explained
and the destination is repaired additively.

### Activate the M5

1. Rebuild the note/Glean configuration from reviewed repositories and local
   machine configuration; do not copy credentials blindly.
2. Open the vault in Obsidian and verify representative links, attachments,
   searches, and plugins.
3. Exercise one controlled capture through each active path: direct note edit,
   daily capture, Glean capture/summary, and tix synchronization.
4. Confirm captured files appear in Git status and contain the expected content.
5. Run a manual local Git snapshot and produce final M5 manifest M1. M1 supersedes
   M0 as the current-state authority but does not invalidate the preserved M0
   transfer evidence.
6. Create a new external current generation and dated snapshot, verify both
   exactly against M1, and then update `LATEST`.
7. Disable M4 note writers and write the cutover marker containing both M0 and M1
   identifiers before resuming normal M5 capture.

### Ongoing notes protection

- A quiet-time job on the M5 creates local Git snapshots only when the vault has
  meaningful changes. It must avoid racing active writers and must log failures.
- An external backup job creates a new immutable generation below
  `10-current/notes/`, verifies it, atomically updates `LATEST`, and creates a
  dated snapshot according to a retention policy defined in the implementation
  plan.
- Jobs fail closed when the expected APFS volume UUID is absent: they report the
  missed backup and never redirect data to another volume with a coincidental
  name.
- Optional offsite backup is deferred until the local migration is accepted.

## Failure handling and rollback

- **M5 unavailable or updating:** stop remote actions and continue only safe M4
  review/documentation work.
- **External volume unavailable or UUID mismatch:** do not copy data; keep source
  data unchanged.
- **Existing destination collision:** inventory and compare; move neither copy
  until a human-reviewed merge decision exists.
- **Hash mismatch:** preserve both copies, record the mismatch, retry only the
  affected additive transfer, and regenerate manifests.
- **Glean/capture test failure:** keep the M4 frozen but available, repair the M5,
  and do not permit concurrent writers.
- **Dotfiles regression:** revert the offending atomic commit or restow the prior
  revision; do not restore whole application-state directories.

## Acceptance criteria

The foundation is complete only when:

- `~/etc` has no unexplained dirty changes and its reviewed commits pass all
  relevant checks.
- A disposable-home Stow test proves managed files coexist with pre-existing
  `.codex` and `.claude` directories.
- The M5 doctor report has no unexplained required-service failures or unsafe
  hard-coded paths.
- Initial M5 and external M0 manifests exactly match the paused M4 source
  manifest, proving the frozen transfer.
- After controlled M5 captures, both final external notes copies exactly match M1
  and reside below the dedicated backup root; `LATEST` names the verified M1
  generation.
- Obsidian, daily capture, Glean, and tix synchronization each pass a controlled
  end-to-end test on the M5.
- M4 note writers are disabled and an identical cutover marker exists at the
  canonical M4, M5, and external paths.
- The user can locate a representative note, attachment, dotfile, manifest, and
  rollback instruction without relying on this chat history.

## Implementation-plan boundaries

Planning should break this design into reversible phases: dotfiles factoring,
bootstrap hardening, external backup-root preparation, source-vault
quiescence, verified transfer, M5 activation, and final freeze. Each phase must
name its verification and rollback point.

The later bulk migration plan will separately classify projects, agent histories,
large application data, services, caches, and archives. It must consume the
bootstrap diagnostics and external organization defined here rather than expanding
this foundation spec during implementation.

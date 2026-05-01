#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
#  NEXUS CONCRETE — GIT & GITHUB MASTERCLASS
#  Modules 1–5 | Segments 1.1 → 5.1 | 20 Segments Total
#  Principal Instructor : Mike (Toptal Elite DevOps Architect)
#  Student              : Jesse Chijioke | FUTO, Nigeria
# =============================================================================

# ─── SANDBOX WORKSPACE ───────────────────────────────────────────────────────

# [COMMAND MEANING] mktemp = Make Temporary — a system utility that creates a
#   uniquely named, collision-safe temporary directory on the filesystem.
# [FLAG MEANING] -d = directory — creates a directory instead of a file.
# [FLAG MEANING] -t <template> = template — provides a naming prefix for the
#   temp dir; the trailing X's are replaced with random characters at runtime
#   to guarantee a unique, never-colliding directory name.
WORKSPACE=$(mktemp -d -t nexus-concrete-git-XXXX)

# [COMMAND MEANING] trap = trap — a shell built-in that registers a command to
#   fire automatically when a specific signal or shell EXIT event occurs.
# [WHAT]: Guarantees the sandbox is always cleaned up on exit — whether the
#   script finishes normally, errors out, or is killed with Ctrl+C. Zero orphan
#   directories ever left in /tmp after a lesson run.
trap 'rm -rf "$WORKSPACE"' EXIT

# [COMMAND MEANING] cd = Change Directory — moves the shell's working directory.
cd "$WORKSPACE"

echo "=================================================================="
echo "  NEXUS CONCRETE — Git & GitHub Masterclass"
echo "  Sandbox: $WORKSPACE"
echo "=================================================================="
echo ""

# ─── SANDBOX-WIDE GIT IDENTITY ───────────────────────────────────────────────
# These ensure every git commit in the script works in a clean environment
# without depending on your real ~/.gitconfig being pre-configured.

# [COMMAND MEANING] git = Base command (executable) — the entry point that tells
#   the OS to run the Git software and pass subsequent tokens as instructions.
# [SUBCOMMAND MEANING] config = configuration — the sub-command that reads or
#   writes a Git configuration value.
# [FLAG MEANING] --global = Universal Scope — modifies ~/.gitconfig, applying
#   the setting to every repository owned by the current OS user on this machine.
# [KEY MEANING] user.name = User Name — the display name string embedded in the
#   author and committer fields of every commit object.
# [VALUE MEANING] "Jesse Chijioke" = the identity string written into commits.
git config --global user.name  "Jesse Chijioke"

# [KEY MEANING] user.email = User Email — the email address embedded in every
#   commit; GitHub uses this to link commits to a contributor account and paint
#   the green squares on the contribution graph.
# [VALUE MEANING] "jesse@nexusconcrete.ng" = the email string written into commits.
git config --global user.email "jesse@nexusconcrete.ng"

# [KEY MEANING] init.defaultBranch = Initialize Default Branch — sets the name
#   of the first branch created by `git init`, replacing the legacy "master".
# [VALUE MEANING] main = the branch name used by GitHub's current default.
git config --global init.defaultBranch main

# [KEY MEANING] core.editor = Core Editor — the text editor Git opens for
#   commit messages, rebase to-do lists, and any interactive text prompts.
# [VALUE MEANING] nano = lightweight terminal editor; no config file required.
git config --global core.editor nano


# =============================================================================
#  MODULE 1: GIT FOUNDATIONS & MENTAL MODEL
# =============================================================================

echo "=================================================================="
echo "  MODULE 1: Git Foundations & Mental Model"
echo "=================================================================="
echo ""


# ─── SEGMENT 1.1 ─────────────────────────────────────────────────────────────

echo "── Segment 1.1: What Git Is and Is Not ─────────────────────────"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 1.1: Create Account, Init Repo, Observe .git ║
╠══════════════════════════════════════════════════════════════════════╣
║  STEP 1: Go to https://github.com → Sign up for a free account.     ║
║                                                                      ║
║  STEP 2: Click "+" (top-right) → "New repository"                   ║
║          Name    : nexus-concrete                                    ║
║          Visibility: Public                                          ║
║          ✅ "Add a README file"                                       ║
║          Click "Create repository"                                   ║
║                                                                      ║
║  STEP 3: On your LOCAL terminal (outside this script), clone it:    ║
║          git clone https://github.com/<your-username>/nexus-concrete.git ║
║          cd nexus-concrete                                           ║
║                                                                      ║
║  STEP 4: Observe the .git/ anatomy:                                  ║
║          ls -lA .git/                                                ║
║          Look for: HEAD, config, objects/, refs/, hooks/             ║
║          These are the three-tree architecture in raw form.          ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

# ── Initialize the Nexus Concrete repo that all remaining modules use ─────────

# [COMMAND MEANING] mkdir = Make Directory — creates a new filesystem directory.
# [FLAG MEANING] -p = parents — creates parent directories as needed; no error
#   if the target already exists.
mkdir -p nexus-concrete
cd nexus-concrete

# [SUBCOMMAND MEANING] init = initialize — creates a fresh .git/ skeleton
#   (HEAD, config, objects/, refs/) in the current directory, turning it into
#   an empty Git repository. No files are tracked yet.
git init

echo "[1.1] Repository initialized. Observing .git/ anatomy..."
echo ""
echo "── .git/ Directory Anatomy ──────────────────────────────────────"

# [COMMAND MEANING] ls = List — displays directory contents.
# [FLAG MEANING] -l = long format — shows permissions, owner, size, timestamp.
# [FLAG MEANING] -A = almost-all — includes hidden dotfiles but excludes . and ..
ls -lA .git/

echo ""
echo "  HEAD       → symbolic ref → refs/heads/main (your active branch)"
echo "  config     → repo-local config (overrides global ~/.gitconfig)"
echo "  objects/   → content-addressable store (blobs, trees, commits, tags)"
echo "  refs/      → branch, remote, and tag pointers (just 40-byte SHA files)"
echo "  hooks/     → lifecycle event scripts (pre-commit, commit-msg, pre-push…)"
echo ""

echo "── Raw content of .git/HEAD ─────────────────────────────────────"
# [COMMAND MEANING] cat = Concatenate — reads and prints file contents to stdout.
cat .git/HEAD
echo ""

echo "  GIT IS NOT a delta-based VCS (SVN stores 'what changed')."
echo "  GIT IS a content-addressable filesystem — it stores SNAPSHOTS, each"
echo "  identified by the SHA hash of its content. Objects are IMMUTABLE."
echo "  That immutability is a safety guarantee, not a constraint."
echo ""
echo "  Three-tree architecture:"
echo "  Working Tree  →  Index (Staging Area)  →  HEAD (last commit)"
echo "  (your disk)       (what will commit)      (the .git/refs/ graph)"
echo ""


# ─── SEGMENT 1.2 ─────────────────────────────────────────────────────────────

echo "── Segment 1.2: Installing, Configuring, and Validating Git ────"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 1.2: Verify Identity Matches GitHub Email     ║
╠══════════════════════════════════════════════════════════════════════╣
║  After the config commands below, run:                               ║
║    git config --global --list | grep user                            ║
║                                                                      ║
║  The email shown MUST match the primary email in:                    ║
║    GitHub → Settings → Emails                                        ║
║                                                                      ║
║  If they don't match → your commits won't appear on your GitHub     ║
║  contribution graph (the green squares). Fix it with:               ║
║    git config --global user.email "your-github-email@example.com"   ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

# ── Config scope demonstration ────────────────────────────────────────────────

# [KEY MEANING] core.autocrlf = Core Auto CRLF — controls automatic LF ↔ CRLF
#   line-ending conversion on checkout and commit for cross-platform teams.
# [VALUE MEANING] input = On Linux/macOS: normalizes CRLF → LF on commit but
#   never converts on checkout. Prevents Windows CRLF from polluting the repo.
git config --global core.autocrlf input

# [KEY MEANING] core.eol = Core End Of Line — explicitly sets the line-ending
#   style used in the working tree, working alongside .gitattributes rules.
# [VALUE MEANING] lf = Line Feed — UNIX-style line endings. Correct for Ubuntu.
git config --global core.eol lf

# [KEY MEANING] credential.helper = Credential Helper — the mechanism Git uses
#   to store and retrieve HTTPS authentication credentials.
# [VALUE MEANING] cache = In-Memory Cache — holds credentials in memory for a
#   short TTL (default 15 min). Nothing written to disk. Safe on shared machines.
git config --global credential.helper cache

echo "── git config --list: All active values across all scopes ──────"
# [FLAG MEANING] --list = List All — dumps every active key=value pair from all
#   scopes (system → global → local), showing the winning value for each key.
git config --list
echo ""

echo "── git config --show-origin: Trace a key to its config file ────"
# [FLAG MEANING] --show-origin = Show Origin — prints the exact filesystem path
#   of the config file that currently defines the specified key.
git config --show-origin user.email
echo ""

# ── Local scope override ──────────────────────────────────────────────────────
# [FLAG MEANING] --local = Local Scope — writes to the CURRENT repository's
#   .git/config only, overriding any global or system value for this repo alone.
git config --local user.email "nexus-ops@nexusconcrete.ng"
echo "  [1.2] Repo-local email set → nexus-ops@nexusconcrete.ng"
echo "        (Overrides global jesse@nexusconcrete.ng for this repo only)"
git config --show-origin user.email
echo ""

# [FLAG MEANING] --system = System Scope — writes to the system-wide config
#   (e.g., /etc/gitconfig), affecting EVERY user on the machine. Requires sudo.
echo "  Scopes in order of precedence (highest wins):"
echo "  --local  (.git/config)          > narrowest, repo-specific"
echo "  --global (~/.gitconfig)         > per-user, all repos"
echo "  --system (/etc/gitconfig)       > all users on this machine"
echo ""

# ── includeIf: Conditional identity switching ─────────────────────────────────
echo "── includeIf: Per-directory identity switching ──────────────────"
# [KEY MEANING] includeIf "gitdir:<path>" = Include If gitdir — conditionally
#   includes a separate .gitconfig file only when Git is operating inside
#   repositories that live under the specified path.
echo '  Add this to ~/.gitconfig to switch identities per project root:'
echo '  [includeIf "gitdir:~/work/"]'
echo '    path = ~/.gitconfig-work        # work email for ~/work/ repos'
echo '  [includeIf "gitdir:~/personal/"]'
echo '    path = ~/.gitconfig-personal    # personal email for ~/personal/ repos'
echo ""

# ── Wrong author correction ───────────────────────────────────────────────────
echo "── git commit --amend --reset-author: Fix wrong identity ────────"
# [SUBCOMMAND MEANING] commit = commit — records the staged snapshot as a new
#   permanent commit object in the repository's history.
# [FLAG MEANING] --amend = Amend — rewrites the MOST RECENT commit by replacing
#   it with a new commit object; incorporates current index and/or a new message.
# [FLAG MEANING] --reset-author = Reset Author — resets the amended commit's
#   author field to the CURRENTLY active user.name and user.email, correcting
#   a commit made with the wrong identity before it is pushed.
echo "  Usage: git commit --amend --reset-author --no-edit"
echo "  Safe ONLY before pushing. Rewrites the commit SHA."
echo ""


# ─── SEGMENT 1.3 ─────────────────────────────────────────────────────────────

echo "── Segment 1.3: Git's Object Model — The Four Object Types ─────"
echo ""

# Build the first real commit so we have live objects to inspect.
echo "Project: Nexus Concrete Block Manufacturing" >  README.md
echo "Location: Enugu, Nigeria"                    >> README.md
echo "Products: 9-inch hollow blocks, 6-inch hollow blocks" >> README.md

echo "Plant: Main Plant Alpha"              > plant-config.txt
echo "Capacity: 2000 blocks per day"       >> plant-config.txt
echo "Diesel Budget: 50 litres/day"        >> plant-config.txt

# [FLAG MEANING] -A (git add) = All — stages ALL new files, modifications, and
#   deletions across the ENTIRE working tree regardless of current directory.
git add -A

# [FLAG MEANING] -m = message — supplies the commit message inline from the CLI,
#   bypassing the editor prompt.
git commit -m "feat: initialize Nexus Concrete plant configuration"

echo ""
COMMIT_SHA=$(git rev-parse HEAD)
echo "  First commit SHA: $COMMIT_SHA"
echo ""

# ── cat-file: Inspect the raw object graph ────────────────────────────────────
echo "── git cat-file: Inspect raw Git objects ───────────────────────"

# [SUBCOMMAND MEANING] cat-file = Concatenate File — a plumbing command that
#   reads and outputs the raw content of any Git object by its SHA hash.
# [FLAG MEANING] -t = type — prints only the OBJECT TYPE (blob/tree/commit/tag)
#   of the object stored at the given SHA.
echo "  Type of HEAD commit object:"
git cat-file -t "$COMMIT_SHA"

# [FLAG MEANING] -p = pretty-print — formats and displays the full human-readable
#   content of the object, exposing the raw data structure Git stores internally.
echo ""
echo "  Full commit object content:"
git cat-file -p "$COMMIT_SHA"
echo ""

# Drill down: extract the tree SHA from the commit object.
TREE_SHA=$(git cat-file -p "$COMMIT_SHA" | grep "^tree" | awk '{print $2}')
echo "── Tree object (directory snapshot): ───────────────────────────"
echo "  Tree SHA: $TREE_SHA"
git cat-file -p "$TREE_SHA"
echo ""

# Drill further: extract the blob SHA for README.md and inspect it.
BLOB_SHA=$(git cat-file -p "$TREE_SHA" | grep "README.md" | awk '{print $3}')
echo "── Blob object (README.md file content): ────────────────────────"
echo "  Blob SHA: $BLOB_SHA"
git cat-file -p "$BLOB_SHA"
echo ""

# [FLAG MEANING] -s = size — prints the BYTE SIZE of the object without printing
#   its content. Useful for disk-usage analysis on large repos.
echo "── Blob byte size: ──────────────────────────────────────────────"
git cat-file -s "$BLOB_SHA"
echo "  bytes (no filename, no permissions stored — just pure content)"
echo ""

# ── hash-object: Content-addressing demonstration ────────────────────────────
echo "── git hash-object: Write objects directly to the store ─────────"

# [SUBCOMMAND MEANING] hash-object = Hash Object — computes the SHA hash for a
#   given file (or stdin input) using Git's internal format and optionally stores
#   the resulting object in the .git/objects/ directory.
# [FLAG MEANING] -w = write — writes the hashed object INTO .git/objects/ in
#   addition to printing the resulting SHA. Without -w, it's a dry-run hash.
echo "Diesel consumption report: Day 1 = 48L" > diesel-report.txt
DIESEL_BLOB=$(git hash-object -w diesel-report.txt)
echo "  diesel-report.txt hashed and stored → $DIESEL_BLOB"
echo "  (File is in .git/objects/ but NOT yet in the index — not staged)"
echo ""

# [FLAG MEANING] --stdin = Standard Input — reads object content from stdin
#   instead of a file path, enabling pipeline-based object creation in scripts.
echo "Block Quality Report: Batch #001 PASS" | git hash-object --stdin
echo "  (stdout only — -w omitted so no store write this time)"
echo ""

echo "── Manual SHA-1 verification (Git blob header format): ─────────"
echo "  Git hashes as: 'blob <byte_count>\\0<content>'"
echo "  For the 5-byte string 'hello':"
# [COMMAND MEANING] printf = Print Formatted — prints a formatted string to
#   stdout; handles escape sequences like \\0 (NUL byte) correctly, unlike echo.
printf "blob 5\0hello" | sha1sum
echo "  This matches what git hash-object would compute for 'hello'."
echo ""


# ─── SEGMENT 1.4 ─────────────────────────────────────────────────────────────

echo "── Segment 1.4: The .git/ Directory — Anatomy of a Repository ──"
echo ""

echo "── git ls-files: Inspect the staging area (index) ──────────────"
# [SUBCOMMAND MEANING] ls-files = List Files — a plumbing command that queries
#   and lists files currently registered in Git's index (the staging area).
# [FLAG MEANING] --stage = Stage — shows mode bits, blob SHA, and stage number
#   for every file currently tracked in the index, exposing its raw binary state.
git ls-files --stage
echo ""

# diesel-report.txt was hashed above but never staged — show it as untracked.
echo "── Untracked files in working tree: ─────────────────────────────"
# [FLAG MEANING] --others = Others — lists files in the working tree that are
#   NOT currently tracked in the index (untracked files).
# [FLAG MEANING] --exclude-standard = Exclude Standard — applies all standard
#   ignore rules (.gitignore, .git/info/exclude, global gitignore) to the listing.
git ls-files --others --exclude-standard
echo ""

echo "── git rev-parse: Resolve refs to their canonical SHA ───────────"
# [SUBCOMMAND MEANING] rev-parse = Revision Parse — resolves any ref, symbolic
#   name, or revision expression to its canonical full 40-character SHA.
# [FLAG MEANING] HEAD = current commit — resolves the HEAD symbolic ref to the
#   SHA of the commit currently checked out.
echo "  HEAD resolves to:"
git rev-parse HEAD

# [FLAG MEANING] --symbolic-full-name = Symbolic Full Name — prints the FULL
#   ref path that HEAD points to (e.g., refs/heads/main) rather than the SHA.
echo "  HEAD is a symbolic ref pointing at:"
git rev-parse --symbolic-full-name HEAD
echo ""

echo "── Raw .git/refs/heads/main (a branch is just a 41-byte file): ─"
cat .git/refs/heads/main
echo "  ← That's it. 40-char SHA + newline. Zero overhead."
echo ""

echo "── git for-each-ref: Iterate all refs with custom output ────────"
# [SUBCOMMAND MEANING] for-each-ref = For Each Ref — iterates over all refs in
#   the repository with a fully customizable output format. The essential
#   plumbing tool for scripting ref queries and automation.
# [FLAG MEANING] --format=<format> = Format — a printf-style template that
#   specifies which fields to print (refname, objecttype, objectname, etc.).
git for-each-ref \
  --format='%(refname:short)  →  %(objecttype)  %(objectname:short)' \
  refs/
echo ""

echo "── Transient state files (ORIG_HEAD, MERGE_HEAD, CHERRY_PICK_HEAD): ──"
echo "  ORIG_HEAD         → Saved by: rebase, reset, merge"
echo "                      Used for: git reset --hard ORIG_HEAD (1-step undo)"
echo "  MERGE_HEAD        → Set during an in-progress merge"
echo "  CHERRY_PICK_HEAD  → Set during an in-progress cherry-pick"
echo "  COMMIT_EDITMSG    → Contains the last commit message; useful in hooks"
echo ""

echo "── Edge case: corrupted index recovery ──────────────────────────"
echo "  Symptom: ALL files suddenly show as modified/deleted after an abrupt"
echo "           power cut or disk error mid-operation."
# [SUBCOMMAND MEANING] read-tree = Read Tree — a plumbing command that reads a
#   tree object into the index; the recovery tool when the index is corrupted.
# [VALUE MEANING] HEAD (with read-tree) = reads HEAD's tree into the index,
#   restoring the staging area to a clean, correct state without touching the
#   working tree.
echo "  Recovery: git read-tree HEAD"
echo "  This rebuilds the index from HEAD's tree — no data loss."
echo ""


# ─── SEGMENT 1.5 ─────────────────────────────────────────────────────────────

echo "── Segment 1.5: Initializing and Cloning Repositories ──────────"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 1.5: SSH Key Pair Setup & Clone via SSH       ║
╠══════════════════════════════════════════════════════════════════════╣
║  STEP 1 — Generate Ed25519 SSH key (fastest, most secure):          ║
║    ssh-keygen -t ed25519 -C "jesse@nexusconcrete.ng"                ║
║    Press ENTER for default path (~/.ssh/id_ed25519)                 ║
║    Set a strong passphrase when prompted.                            ║
║                                                                      ║
║  STEP 2 — Copy your public key:                                      ║
║    cat ~/.ssh/id_ed25519.pub                                         ║
║    (copy the entire output line)                                     ║
║                                                                      ║
║  STEP 3 — Add to GitHub:                                             ║
║    GitHub → Settings → SSH and GPG Keys → New SSH Key               ║
║    Title: "FUTO Laptop"  |  Paste the public key  |  Save           ║
║                                                                      ║
║  STEP 4 — Validate the handshake:                                    ║
║    ssh -T git@github.com                                             ║
║    Expected: "Hi <username>! You've successfully authenticated..."   ║
║                                                                      ║
║  STEP 5 — Clone via SSH:                                             ║
║    git clone git@github.com:<username>/nexus-concrete.git           ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

# ── git init --bare ────────────────────────────────────────────────────────────
cd "$WORKSPACE"

# [FLAG MEANING] --bare = Bare Repository — creates a repository with NO working
#   tree; only the raw .git/ internals exist at the root. Used as a server-side
#   push target, CI mirror, or authoritative remote. Nobody edits files here.
mkdir -p nexus-concrete-bare.git
git init --bare nexus-concrete-bare.git
echo ""
echo "── Bare repo structure (object store at root, no working tree): ─"
ls -lA nexus-concrete-bare.git/
echo ""

# ── Push to bare repo to have something to clone from ─────────────────────────
cd "$WORKSPACE/nexus-concrete"

# [SUBCOMMAND MEANING] remote = Remote — manages the set of tracked remote
#   repository URLs associated with the local repository.
# [VALUE MEANING] add origin <url> = Add Origin — registers a new remote named
#   "origin" pointing to the given URL; stored as [remote "origin"] in .git/config.
git remote add origin "$WORKSPACE/nexus-concrete-bare.git"
git push origin main
echo ""

# ── Shallow clone ─────────────────────────────────────────────────────────────
cd "$WORKSPACE"

# [SUBCOMMAND MEANING] clone = Clone — downloads a full (or filtered) copy of a
#   remote repository, creates remote-tracking branches, and checks out HEAD.
# [FLAG MEANING] --depth=<N> = Depth — creates a SHALLOW clone with only the
#   last N commits of history, dramatically reducing clone time and disk usage.
#   The go-to flag for CI pipelines that don't need full project history.
git clone --depth=1 nexus-concrete-bare.git nexus-concrete-shallow
echo "  Shallow clone commit count (should be 1):"
git -C nexus-concrete-shallow log --oneline | wc -l
echo ""

# ── Blobless partial clone ────────────────────────────────────────────────────
# [FLAG MEANING] --filter=blob:none = Blobless Partial Clone — fetches all
#   commit and tree objects upfront but downloads file blobs LAZILY, only when
#   a specific file's content is actually accessed. Ideal for large monorepos
#   where CI only reads a subset of files.
git clone --filter=blob:none nexus-concrete-bare.git nexus-concrete-blobless
echo "  Blobless clone done. Blobs download on first file access."
echo ""

# ── Treeless partial clone ────────────────────────────────────────────────────
# [FLAG MEANING] --filter=tree:0 = Treeless Partial Clone — fetches ONLY commit
#   objects upfront; trees and blobs are fetched on demand. Maximizes initial
#   clone speed for enormous monorepos where you only need commit metadata.
git clone --filter=tree:0 nexus-concrete-bare.git nexus-concrete-treeless
echo "  Treeless clone done. Trees and blobs download on demand."
echo ""

# ── Branch-specific clone ─────────────────────────────────────────────────────
# [FLAG MEANING] -b <branch> = Branch (clone) — checks out the specified branch
#   immediately after cloning instead of the remote's default HEAD branch.
# [FLAG MEANING] --single-branch = Single Branch — limits the clone to fetching
#   ONLY the history of the specified branch, skipping all other remote branches.
git clone -b main --single-branch \
  nexus-concrete-bare.git nexus-concrete-single-branch
echo "  Single-branch clone of 'main' complete (no other branches fetched)."
echo ""

# ── Mirror clone ─────────────────────────────────────────────────────────────
# [FLAG MEANING] --mirror = Mirror — clones ALL refs exactly as they exist on
#   the remote (branches, tags, notes, stash refs), preserving the full ref
#   namespace. Used for disaster recovery mirrors and repository migrations.
git clone --mirror \
  nexus-concrete-bare.git nexus-concrete-mirror.git
echo "  Mirror clone complete (all refs preserved, bare repo, no working tree)."
echo ""

echo "── ssh -T git@github.com (validation command reference): ───────"
# [COMMAND MEANING] ssh = Secure Shell — initiates an encrypted connection to a
#   remote host using the SSH protocol.
# [FLAG MEANING] -T = No TTY — disables pseudo-terminal allocation, telling SSH
#   not to open an interactive shell. Just validate the key handshake and exit.
echo "  ssh -T git@github.com"
echo "  Expected output: 'Hi <username>! You've successfully authenticated'"
echo "  This validates your SSH key is correctly registered with GitHub."
echo ""

# Return to main repo.
cd "$WORKSPACE/nexus-concrete"


# =============================================================================
#  MODULE 2: CORE WORKFLOW — STAGING, COMMITTING, AND HISTORY
# =============================================================================

echo "=================================================================="
echo "  MODULE 2: Core Workflow — Staging, Committing, History"
echo "=================================================================="
echo ""


# ─── SEGMENT 2.1 ─────────────────────────────────────────────────────────────

echo "── Segment 2.1: The Staging Area (Index) in Depth ──────────────"
echo ""

# Create the Nexus Concrete operational files.
echo "Labour roster: [Emeka, Chioma, Tunde, Amara, Kelechi]" > labour-roster.txt
echo "Equipment: 2x Vibrating Machine, 1x Concrete Mixer"    > equipment-log.txt
echo "Raw Materials: Cement 200 bags, Sand 10 tonnes"        > materials.txt
mkdir -p reports
echo "QC Report: Batch #001 — PASS" > reports/qc-001.txt
echo "QC Report: Batch #002 — PASS" > reports/qc-002.txt
echo "debug run output"              > debug.log

# ── git add <file>: Stage a single file ───────────────────────────────────────
echo "── git add <file>: Stage ONE specific file ──────────────────────"
# [SUBCOMMAND MEANING] add = Add — stages file content snapshots from the
#   working tree INTO the index, queueing them for inclusion in the next commit.
# [VALUE MEANING] labour-roster.txt = the specific file whose current on-disk
#   snapshot is captured and placed into the index at this exact moment.
git add labour-roster.txt
echo "  Staged: labour-roster.txt"
echo ""

# ── git diff (unstaged) ───────────────────────────────────────────────────────
echo "── git diff: Working tree vs. Index (what's NOT yet staged) ─────"
# [SUBCOMMAND MEANING] diff = Difference — computes and displays the diff between
#   two states (working tree vs. index, index vs. HEAD, or between commits).
# [WHAT]: With NO arguments, shows changes in the WORKING TREE that have NOT
#   been staged yet — the gap between disk and the index snapshot.
git diff
echo ""

# Stage another file so we can show --staged.
git add equipment-log.txt

# ── git diff --staged ─────────────────────────────────────────────────────────
echo "── git diff --staged: Index vs. HEAD (what WILL be committed) ───"
# [FLAG MEANING] --staged = Staged (alias: --cached) — compares the INDEX
#   against HEAD, showing exactly what will land in the very next commit.
git diff --staged
echo ""

# ── git add -A ────────────────────────────────────────────────────────────────
echo "── git add -A: Stage ALL changes across the entire working tree ─"
# Already explained above ↑ — using without repeating the tag block.
git add -A

# ── git status -s ─────────────────────────────────────────────────────────────
echo "── git status -s: Compact machine-readable status ───────────────"
# [SUBCOMMAND MEANING] status = Status — reports the state of the working tree
#   and index: which files are tracked, staged, modified, or untracked.
# [FLAG MEANING] -s = short — outputs a compact two-column XY format.
#   Left column (X) = index status | Right column (Y) = working tree status
#   'A'=added, 'M'=modified, '?'=untracked, 'D'=deleted
git status -s
echo ""

# ── Demonstrate git add -u vs -A ──────────────────────────────────────────────
git restore --staged materials.txt           # unstage one file
echo "Updated: Cement stock low — reorder 100 bags" >> materials.txt  # modify tracked file

echo "── git add -u: Stage only tracked-file changes (no new files) ──"
# [FLAG MEANING] -u = update — stages ONLY modifications and deletions to files
#   ALREADY tracked in the index. Does NOT stage new, untracked files.
git add -u
git status -s
echo "  (debug.log is untracked — -u ignored it. -A would have staged it.)"
echo ""

# ── git add -p: Interactive hunk staging (non-TTY explanation) ────────────────
echo "── git add -p: Interactive hunk-level staging ───────────────────"
# [FLAG MEANING] -p = patch — opens an interactive hunk-selection loop, letting
#   the engineer review each diff chunk and choose: stage (y), skip (n), split
#   (s), edit (e), or quit (q). The professional's atomic commit workflow.
echo "  Usage: git add -p plant-config.txt"
echo "  This is how senior engineers commit ONE logical change at a time,"
echo "  even when two unrelated edits landed in the same file."
echo ""

# ── git add -e: Edit the patch before staging ─────────────────────────────────
echo "── git add -e: Edit diff before staging (surgical staging) ──────"
# [FLAG MEANING] -e = edit — opens the FULL diff in the configured text editor,
#   allowing surgical line-level removal from the patch before staging it.
echo "  Usage: git add -e plant-config.txt"
echo "  Lets you manually delete '+' lines from the diff to exclude specific"
echo "  lines from the staged snapshot."
echo ""

# ── Edge case: staging then modifying again ────────────────────────────────────
echo "── Edge Case: git add snapshots the file AT THAT MOMENT ─────────"
echo "Plant Alpha diesel log: 48L consumed" > diesel-log.txt
git add diesel-log.txt
echo "  [Staged diesel-log.txt with 48L entry]"
echo "Plant Alpha diesel log: 52L consumed (correction)" > diesel-log.txt
echo "  [Modified diesel-log.txt ON DISK after staging — common accident]"
echo ""
git status -s
echo "  diesel-log.txt appears in BOTH columns:"
echo "  Left 'M' = index has a version (48L staged snapshot)"
echo "  Right 'M' = working tree has a NEWER version (52L)"
echo "  git diff          → shows 48L vs 52L (unstaged gap)"
echo "  git diff --staged → shows HEAD vs 48L (staged snapshot)"
echo ""


# ─── SEGMENT 2.2 ─────────────────────────────────────────────────────────────

echo "── Segment 2.2: Committing — Anatomy and Best Practices ────────"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 2.2: Push Conventional Commits to GitHub      ║
╠══════════════════════════════════════════════════════════════════════╣
║  After the script builds the commit history below, push it:         ║
║    git remote add origin https://github.com/<user>/nexus-concrete.git ║
║    git push -u origin main                                           ║
║                                                                      ║
║  Then on GitHub:                                                     ║
║  1. Click "X commits" on the repo homepage                           ║
║  2. Click any individual commit → view the full detail page          ║
║  3. Observe: short SHA, full SHA, author, committer, date, body      ║
║  4. A multi-line commit shows subject as headline, body as paragraph  ║
║  5. Find a commit with a Co-authored-by trailer → GitHub shows both  ║
║     contributors' avatars on that commit                             ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

# Commit the files already staged in Seg 2.1.
echo "── Conventional Commits format: ────────────────────────────────"
echo "  <type>(<optional scope>): <short subject>"
echo ""
echo "  feat      → new feature           → MINOR SemVer bump"
echo "  fix       → bug fix               → PATCH SemVer bump"
echo "  chore     → maintenance, no prod change"
echo "  docs      → documentation change"
echo "  refactor  → code restructure, no behavior change"
echo "  BREAKING CHANGE: in the commit footer → MAJOR SemVer bump"
echo ""

git commit -m "feat(plant): add labour roster, equipment log, materials, and QC reports"
echo ""

# ── fix commit ────────────────────────────────────────────────────────────────
echo "Plant Alpha diesel log: 48L consumed (verified)" > diesel-log.txt
git add diesel-log.txt
git commit -m "fix(diesel): correct Day-1 consumption entry to verified 48L figure"
echo ""

# ── Multi-line commit message (subject + blank line + body + trailer) ──────────
echo "Daily production target: 2000 blocks" > production-targets.txt
git add production-targets.txt

# [WHAT]: Commit message anatomy:
#   Line 1 = SUBJECT (72 chars max, imperative mood, no trailing period)
#   Line 2 = BLANK LINE (required separator — git log --oneline shows only line 1)
#   Line 3+ = BODY (explain the WHY, not the what; wrap at 72 chars)
#   Final lines = TRAILERS (Reviewed-by:, Co-authored-by:, Closes:, etc.)
git commit -m "docs(targets): document daily production targets for Plant Alpha

This sets the baseline production expectation for Nexus Concrete Plant Alpha.
Targets will be reviewed monthly based on diesel cost and labour availability.
Initial target of 2000 blocks/day is conservative; Phase 2 target is 3000.

Reviewed-by: Emeka Okonkwo <emeka@nexusconcrete.ng>"
echo ""

# ── git commit --amend ────────────────────────────────────────────────────────
echo "── git commit --amend: Rewrite the last commit ──────────────────"
# Amend explanation already noted above in Seg 1.2 config context.
# Demonstrating the behavior here. Adding QC reports to the last commit.
git add reports/
# [FLAG MEANING] --no-edit = No Edit — reuses the existing commit message
#   verbatim, suppressing the editor prompt entirely. Useful in scripts
#   and automation pipelines where a message change isn't needed.
git commit --amend --no-edit
echo "  Reports/ folder folded into the last commit via --amend."
echo "  WATCH OUT: This creates a NEW commit SHA. Safe ONLY pre-push."
echo ""

# ── git commit --allow-empty ──────────────────────────────────────────────────
echo "── git commit --allow-empty: CI trigger / deployment marker ─────"
# [FLAG MEANING] --allow-empty = Allow Empty — creates a commit with NO staged
#   file changes. Used for triggering CI pipelines, marking deployment events,
#   or sending workflow signals without any code change.
git commit --allow-empty \
  -m "chore(ci): trigger deployment pipeline for Plant Alpha go-live [skip-cache]"
echo ""

# ── Co-author trailer ─────────────────────────────────────────────────────────
echo "── Co-authored-by trailer: GitHub contribution credit ───────────"
echo "Shift schedule: Morning 06:00-14:00, Afternoon 14:00-22:00" > shift-schedule.txt
git add shift-schedule.txt

# [FLAG MEANING] --trailer "<key>: <value>" = Trailer — appends a structured
#   metadata key:value footer to the commit message. GitHub parses the
#   Co-authored-by trailer specifically to credit multiple contributors on
#   the contribution graph.
git commit -m "feat(hr): add Plant Alpha shift schedule" \
  --trailer "Co-authored-by: Chioma Nwosu <chioma@nexusconcrete.ng>"
echo ""

# ── git commit --author ───────────────────────────────────────────────────────
echo "── git commit --author: Single-commit identity override ─────────"
echo "Monthly safety audit: All equipment cleared" > safety-audit.txt
git add safety-audit.txt

# [FLAG MEANING] --author "Name <email>" = Author Override — sets the AUTHOR
#   identity for THIS commit only, without touching any config file. Useful
#   when applying a patch contributed by someone else.
git commit --author "Tunde Adeyemi <tunde@nexusconcrete.ng>" \
  -m "chore(safety): record monthly safety audit clearance — Plant Alpha"
echo ""

# ── Wrong identity fix ────────────────────────────────────────────────────────
echo "── Demonstrating: git commit --amend --reset-author ────────────"
# --reset-author already explained in Seg 1.2 config section above.
git commit --amend --reset-author --no-edit
echo "  Author reset to currently active: $(git config user.email)"
echo ""


# ─── SEGMENT 2.3 ─────────────────────────────────────────────────────────────

echo "── Segment 2.3: Viewing and Navigating History ──────────────────"
echo ""

echo "── git log: Full history (last 3 commits shown) ─────────────────"
# [SUBCOMMAND MEANING] log = Log — displays commit history in reverse-
#   chronological order with full SHA, author, date, and message metadata.
# [FLAG MEANING] -n <number> = Number Limit — limits log output to the N most
#   recent commits.
git log -n 3
echo ""

echo "── The power alias: --oneline --graph --decorate --all ──────────"
# [FLAG MEANING] --oneline = One Line — condenses each commit to a single line
#   showing the short SHA and commit subject. Ideal for scanning history fast.
# [FLAG MEANING] --graph = Graph — renders a text-based ASCII branch-and-merge
#   diagram alongside the log, visualizing the full repository topology.
# [FLAG MEANING] --decorate = Decorate — annotates each commit with all refs
#   (branch names, tags, HEAD) that currently point to it.
# [FLAG MEANING] --all = All (log context) — includes commits reachable from
#   ALL refs (local branches, remote-tracking branches, tags), not just HEAD.
git log --oneline --graph --decorate --all
echo ""

echo "── git log --since / --until / --author / --grep ────────────────"
# [FLAG MEANING] --since=<date> = Since Date — filters to commits authored AFTER
#   the given date. Accepts relative ("2 weeks ago") or absolute ("2024-01-01").
# [FLAG MEANING] --until=<date> = Until Date — filters to commits authored BEFORE
#   the given date.
# [FLAG MEANING] --author=<pattern> = Author Filter — shows only commits whose
#   author name or email matches the given string or regex.
# [FLAG MEANING] --grep=<pattern> = Grep Filter — filters to commits whose
#   message body contains the given text or regex pattern.
git log --since="1 hour ago" --author="Jesse" --grep="feat" --oneline
echo ""

echo "── git log -S: Pickaxe — forensic audit for string changes ──────"
# [FLAG MEANING] -S "string" = Pickaxe Search — finds commits where the given
#   string was ADDED OR REMOVED from the diff. The forensic tool for tracking
#   when a specific value (API key, config setting, credential) entered the repo.
git log -S "2000 blocks" --oneline
echo ""

echo "── git log -G: Regex pickaxe ─────────────────────────────────────"
# [FLAG MEANING] -G "regex" = Regex Pickaxe — finds commits where the patch
#   text MATCHES the given regex, offering richer pattern matching than -S.
git log -G ".*diesel.*" --oneline
echo ""

echo "── git log --follow: Track history across renames ───────────────"
# [FLAG MEANING] --follow = Follow — tracks a file's commit history across
#   renames by following rename events, so history doesn't stop at a rename.
git log --follow -- README.md
echo ""

echo "── git log --diff-filter=D: Find the commit that deleted a file ─"
# [FLAG MEANING] --diff-filter=D = Diff Filter Deleted — limits log output to
#   commits where at least one file was DELETED.
git log --diff-filter=D --summary --oneline
echo ""

echo "── git show <sha>: Inspect ONE specific commit in full ──────────"
# [SUBCOMMAND MEANING] show = Show — displays the full diff, author, date, and
#   commit message of a SPECIFIC commit. The go-to for single-commit inspection.
git show HEAD --stat
echo ""

echo "── git shortlog -sn: Contributor summary ────────────────────────"
# [SUBCOMMAND MEANING] shortlog = Short Log — aggregates commit history grouped
#   by author, producing a contributor summary table.
# [FLAG MEANING] -s = suppress (shortlog context) — suppresses individual commit
#   messages, displaying only the commit count per author.
# [FLAG MEANING] -n = numeric sort (shortlog context) — sorts output by commit
#   count in descending order, NOT alphabetically by author name.
git shortlog -sn
echo ""

echo "── CI environment: Preventing pager from blocking pipelines ─────"
# [VALUE MEANING] GIT_PAGER=cat = Overrides Git's pager to 'cat', preventing
#   output from being piped to less/more which hangs CI pipelines that have
#   no TTY (terminal) attached.
echo "  export GIT_PAGER=cat"
# [FLAG MEANING] --no-pager = No Pager — instructs Git to print output directly
#   to stdout without invoking any pager. The canonical CI/scripting flag.
echo "  git --no-pager log --oneline"
echo "  Always use one of these two approaches in CI scripts."
echo ""


# ─── SEGMENT 2.4 ─────────────────────────────────────────────────────────────

echo "── Segment 2.4: .gitignore — Patterns, Precedence, and Pitfalls ─"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 2.4: .gitignore Template & git rm --cached    ║
╠══════════════════════════════════════════════════════════════════════╣
║  STEP 1: When creating a NEW GitHub repo, click "Add .gitignore"    ║
║          and pick the "Node" or "Python" template. Observe what      ║
║          patterns GitHub pre-populates for that tech stack.          ║
║                                                                      ║
║  STEP 2: To stop tracking a previously committed file:               ║
║    echo "diesel-log.txt" >> .gitignore                               ║
║    git rm --cached diesel-log.txt                                    ║
║    git add .gitignore                                                ║
║    git commit -m "chore: untrack diesel-log.txt"                    ║
║                                                                      ║
║  STEP 3: git push origin main                                        ║
║    Observe: diesel-log.txt disappears from the GitHub repo view      ║
║    but still exists on your local filesystem.                        ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

# Write a production-grade .gitignore for Nexus Concrete.
cat > .gitignore << 'GITIGNORE_EOF'
# ── OS artifacts ─────────────────────────────────────────────────────
.DS_Store
Thumbs.db

# ── Editor artifacts ─────────────────────────────────────────────────
.idea/
.vscode/
*.swp
*.swo

# ── Nexus Concrete secrets ────────────────────────────────────────────
secrets.txt
.env
*.key
*.pem

# ── Log files ─────────────────────────────────────────────────────────
logs/
*.log

# ── Build artifacts ───────────────────────────────────────────────────
build/
dist/

# ── Ignore a whole directory, EXCEPT one important file ───────────────
# NOTE: The negation below ONLY works if you DON'T ignore the parent dir.
# If "logs/" is ignored above, "!logs/production.log" has NO effect.
# Remove "logs/" from the list above first, then this negation will work.
# !logs/production.log
GITIGNORE_EOF

git add .gitignore

# Create some files that SHOULD be ignored.
mkdir -p logs
echo "debug output line 1" > logs/debug.log
echo "Nexus Concrete DB password: hunter2" > secrets.txt
touch .DS_Store

echo "── git check-ignore -v: Debug why a file is being ignored ──────"
# [SUBCOMMAND MEANING] check-ignore = Check Ignore — evaluates a file against
#   all active ignore rules and reports whether and why it is being ignored.
# [FLAG MEANING] -v = verbose (check-ignore context) — prints the EXACT
#   .gitignore file path, line number, and pattern responsible for ignoring it.
git check-ignore -v secrets.txt
git check-ignore -v .DS_Store
git check-ignore -v logs/debug.log
echo ""

# ── Edge case: untrack an already-tracked file ───────────────────────────────
echo "── Edge Case: diesel-log.txt is tracked but should be ignored ───"
echo "  Problem: diesel-log.txt was committed earlier (it's IN the index)."
echo "  Adding it to .gitignore alone does NOTHING — Git keeps tracking it."
echo "  You MUST remove it from the index first."
echo ""

echo "diesel-log.txt" >> .gitignore
# [SUBCOMMAND MEANING] rm = Remove — removes a file from both the working tree
#   AND the index, staging the deletion for the next commit.
# [FLAG MEANING] --cached = Cached (rm context) — removes the file from the
#   INDEX ONLY, stops tracking it in Git, but leaves the physical file on disk
#   completely untouched. The essential "untrack without delete" operation.
git rm --cached diesel-log.txt
echo "  diesel-log.txt is now untracked. Verify it still exists on disk:"
ls -la diesel-log.txt
echo ""
git status -s
echo ""

git add .gitignore
git commit -m "chore(ignore): add .gitignore and untrack diesel-log.txt"
echo ""

echo "── .gitattributes: Per-path behaviour control (reference) ──────"
# [VALUE MEANING] .gitattributes = A repository-tracked file that defines
#   per-path attributes: merge strategies, diff drivers, line endings (eol),
#   and binary file handling. Goes in the repo root, unlike .gitignore.
echo '  Force LF for all shell scripts:   *.sh text eol=lf'
echo '  Mark PNG images as binary:        *.png binary'
echo '  Custom merge strategy for JSON:   *.json merge=ours'
echo ""

echo "── core.excludesFile: Global gitignore (reference) ──────────────"
# [KEY MEANING] core.excludesFile = Core Excludes File — a global config key
#   pointing to a file (e.g., ~/.gitignore_global) whose ignore patterns apply
#   to ALL repositories for the current user, without being committed to any repo.
echo "  git config --global core.excludesFile ~/.gitignore_global"
echo "  Add .DS_Store, .idea/, Thumbs.db here — OS/editor junk that"
echo "  should NEVER appear in any repo, ever."
echo ""


# ─── SEGMENT 2.5 ─────────────────────────────────────────────────────────────

echo "── Segment 2.5: Undoing Changes — The Full Spectrum ─────────────"
echo ""

echo "Stock report: Cement 200 bags, Sand 50 tonnes" > stock-report.txt
git add stock-report.txt
git commit -m "feat(stock): add initial stock report for Plant Alpha"
echo "ACCIDENTAL LINE: debug garbage added by mistake" >> stock-report.txt

echo "── git restore <file>: Discard working tree changes ────────────"
# [SUBCOMMAND MEANING] restore = Restore — discards working-tree changes or
#   unstages index entries; the modern replacement for the old
#   'git checkout -- <file>' and 'git reset HEAD <file>' workflows.
# [VALUE MEANING] stock-report.txt = the file whose working-tree changes are
#   discarded, restoring it to the last STAGED (index) version.
git restore stock-report.txt
echo "  Accidental line discarded. stock-report.txt is clean."
git status -s
echo ""

echo "── git restore --staged: Unstage without discarding changes ─────"
echo "Wrong staged file content" > wrong-file.txt
git add wrong-file.txt
# [FLAG MEANING] --staged = Staged (restore context) — moves the specified file
#   OUT of the index (unstages it) while leaving its working-tree content intact.
git restore --staged wrong-file.txt
echo "  wrong-file.txt unstaged. Still exists on disk:"
git status -s
echo ""

echo "── git restore --source=<sha>: Restore a file from any commit ───"
# [FLAG MEANING] --source=<sha> = Source SHA — restores a file's working-tree
#   content to its state at the specified commit, without switching branches.
FIRST_SHA=$(git log --oneline | tail -1 | awk '{print $1}')
git restore --source="$FIRST_SHA" README.md
echo "  README.md restored to its version at the very first commit."
git restore README.md    # undo the restore to keep the lesson state clean
echo ""

echo "── git reset --soft HEAD~1: Undo commit, keep index staged ──────"
# [SUBCOMMAND MEANING] reset = Reset — moves the HEAD pointer (and optionally
#   the index and working tree) to a target commit, with scope set by the mode.
# [FLAG MEANING] --soft = Soft Reset — moves HEAD to the target commit, leaving
#   the index FULLY STAGED and working tree untouched. Perfect for collapsing
#   the last commit back to staging for message editing or splitting.
git reset --soft HEAD~1
echo "  Last commit undone. Changes are back in index (staged):"
git status -s
git commit -m "chore(safety): record monthly safety audit clearance"
echo ""

echo "── git reset --mixed HEAD~1: Undo commit, reset index ───────────"
# [FLAG MEANING] --mixed = Mixed Reset (default mode) — moves HEAD to the target
#   commit and resets the INDEX to match it, but leaves working-tree files
#   untouched. Changes appear as UNSTAGED modifications. Git's default.
git reset --mixed HEAD~1
echo "  Last commit undone. Changes in working tree (unstaged):"
git status -s
git add -A
git commit -m "chore(safety): record monthly safety audit clearance (re-committed)"
echo ""

echo "── git reset --hard HEAD~1: DESTRUCTIVE ─────────────────────────"
# [FLAG MEANING] --hard = Hard Reset — moves HEAD, resets the INDEX, AND
#   OVERWRITES the working tree to match the target commit. All uncommitted
#   changes are PERMANENTLY LOST. Cannot be undone without reflog.
# [WATCH OUT]: --hard on a SHARED remote branch followed by force-push
#   DESTROYS teammates' commits. This is the most dangerous Git operation.
echo "Throwaway content to demo --hard reset" > throwaway.txt
git add throwaway.txt
git commit -m "WIP: throwaway commit — safe to nuke"
git reset --hard HEAD~1
ls throwaway.txt 2>/dev/null || echo "  Confirmed: throwaway.txt is GONE."
echo ""

echo "── git revert <sha>: The safe, public-history-friendly undo ─────"
# [SUBCOMMAND MEANING] revert = Revert — creates a new INVERSE commit that
#   mathematically undoes the changes of the specified commit, WITHOUT rewriting
#   history. The only safe undo operation on shared/protected branches.
REVERT_TARGET=$(git log --oneline | sed -n '3p' | awk '{print $1}')
git revert "$REVERT_TARGET" --no-edit
echo ""

echo "── git revert -n: Batch multiple reversions into one commit ─────"
# [FLAG MEANING] -n = no-commit (revert context) — applies the revert's changes
#   to the index and working tree but does NOT auto-commit, allowing multiple
#   reversions to be combined into a single clean commit.
git revert HEAD --no-edit -n
git commit -m "revert: undo last two problematic commits as a single revert"
echo ""

echo "── git clean: Remove untracked files and directories ────────────"
echo "temp junk 1" > temp1.txt
echo "temp junk 2" > temp2.txt
mkdir -p build && echo "artifact" > build/output.bin

# [SUBCOMMAND MEANING] clean = Clean — removes untracked files and/or
#   directories from the working tree that Git is not currently tracking.
# [FLAG MEANING] -n = dry-run (clean context) — SIMULATES the clean and prints
#   exactly what WOULD be deleted without removing anything. Run this FIRST.
echo "  DRY RUN (safe preview of what would be deleted):"
git clean -nfd
echo ""
# [FLAG MEANING] -f = force (clean context) — required execution gate; without
#   it git clean deliberately refuses to delete anything as a safety guard.
# [FLAG MEANING] -d = directory — extends the clean to also remove untracked
#   DIRECTORIES recursively, not just loose files.
# [WATCH OUT]: git clean -fd permanently deletes files. They are NOT in the
#   recycling bin. Always run -nfd first to preview. No undo.
echo "  Executing the real clean:"
git clean -fd
echo ""
# [FLAG MEANING] -x = ignored files — additionally removes files that are
#   ignored by .gitignore, fully nuking the working tree back to pristine state.
echo "  git clean -fdx  → also removes .gitignore'd files (build artifacts, etc.)"
echo ""


# =============================================================================
#  MODULE 3: BRANCHING — STRATEGY, INTERNALS, AND MASTERY
# =============================================================================

echo "=================================================================="
echo "  MODULE 3: Branching — Strategy, Internals, Mastery"
echo "=================================================================="
echo ""


# ─── SEGMENT 3.1 ─────────────────────────────────────────────────────────────

echo "── Segment 3.1: Branch Internals — What a Branch Really Is ─────"
echo ""

echo "── A branch is a 41-byte file — see for yourself: ───────────────"
cat .git/refs/heads/main
echo "  ← One 40-character SHA + newline. That's a branch."
echo "  No copy of files. No duplication. Zero cost."
echo "  In SVN, branching COPIES the entire directory tree. Here: one file."
echo ""

# [SUBCOMMAND MEANING] branch = Branch — lists local branches, or creates,
#   deletes, or renames branches depending on the flags and arguments supplied.
echo "── Current branches: ───────────────────────────────────────────"
git branch
echo ""

# ── Create branches: three equivalent methods ─────────────────────────────────
echo "── Creating branches — three equivalent syntaxes: ───────────────"

# [VALUE MEANING] feature/NEXUS-001-second-plant = branch name following the
#   CI/CD naming convention (type/TICKET-description). Automation pipelines
#   parse this pattern for routing, build triggering, and auto PR creation.
git branch feature/NEXUS-001-second-plant
echo "  git branch <name>         → created at HEAD, no switch"

# [SUBCOMMAND MEANING] switch = Switch — changes the current branch or commit.
#   The modern, explicit replacement for the dual-purpose legacy git checkout.
# [FLAG MEANING] -c = create — creates the new branch AND switches to it in one
#   atomic step. The modern preferred syntax over git checkout -b.
git switch -c feature/NEXUS-002-qc-pipeline
echo "  git switch -c <name>      → created + switched (modern)"
git switch main

# [SUBCOMMAND MEANING] checkout = Checkout — the legacy multi-purpose command
#   that handled both branch switching AND file restoration; superseded by
#   git switch and git restore but still present in all older documentation.
# [FLAG MEANING] -b = branch (checkout context) — legacy shorthand that creates
#   and switches to a new branch in one step.
git checkout -b hotfix/NEXUS-HOT-001-diesel-calc
echo "  git checkout -b <name>    → created + switched (legacy)"
git switch main
echo ""

echo "── git branch -v: Branches with last commit ─────────────────────"
# [FLAG MEANING] -v = verbose (branch context) — lists all local branches
#   alongside the short SHA and subject of their most recent commit.
git branch -v
echo ""

echo "── git branch -vv: With upstream tracking configuration ─────────"
# [FLAG MEANING] -vv = very verbose (branch context) — extends -v to also show
#   the upstream tracking configuration and the ahead/behind commit count.
git branch -vv
echo ""

echo "── git branch --merged / --no-merged: Stale branch detection ────"
# [FLAG MEANING] --merged = Merged — lists branches whose tip commits are
#   FULLY REACHABLE from the current HEAD (already integrated; safe to delete).
git branch --merged
echo ""
# [FLAG MEANING] --no-merged = Not Merged — lists branches whose tip commits
#   are NOT reachable from HEAD (contain unintegrated, live work).
git branch --no-merged
echo ""

echo "── git branch -m: Rename a branch ──────────────────────────────"
# [FLAG MEANING] -m = move/rename (branch context) — renames a local branch,
#   updating its reflog and any upstream tracking configuration to match.
git branch -m hotfix/NEXUS-HOT-001-diesel-calc hotfix/NEXUS-HOT-001-diesel-fix
echo "  Renamed to: hotfix/NEXUS-HOT-001-diesel-fix"
echo ""

echo "── git branch -d: Safe delete (merged branches only) ────────────"
# [FLAG MEANING] -d = delete (safe) — deletes a branch ONLY if it has been
#   fully merged into the current branch or its configured upstream.
git branch -d hotfix/NEXUS-HOT-001-diesel-fix
echo "  Deleted. Was already merged into main."
echo ""

echo "── git branch -D: Force-delete (regardless of merge status) ─────"
# [FLAG MEANING] -D = Delete Force — deletes a branch regardless of merge
#   status, permanently discarding any unmerged commits it contains.
# [WATCH OUT]: -D makes commits dangling objects — they're recoverable via
#   git reflog for up to 30 days but then garbage-collected forever.
git branch -D feature/NEXUS-001-second-plant
echo "  Force-deleted. Those commits are now dangling objects."
echo ""


# ─── SEGMENT 3.2 ─────────────────────────────────────────────────────────────

echo "── Segment 3.2: Switching Branches and Detached HEAD State ─────"
echo ""

echo "── git switch: The modern branch switch command ─────────────────"
git switch feature/NEXUS-002-qc-pipeline
echo "  Switched to: feature/NEXUS-002-qc-pipeline"

# [VALUE MEANING] - (dash, with switch) = Previous Branch — switches back to
#   the previously checked-out branch, identical in concept to 'cd -' for dirs.
git switch -
echo "  Switched back using 'git switch -'  (returned to main)"
echo ""

echo "── Detached HEAD: Intentional inspection of a historical commit ─"
FIRST_SHA=$(git log --oneline | tail -1 | awk '{print $1}')
# [FLAG MEANING] --detach = Detach — intentionally enters detached HEAD state
#   at the specified commit or tag for read-only inspection, without creating
#   or switching to a named branch.
git switch --detach "$FIRST_SHA"
echo ""
echo "  .git/HEAD now contains a raw SHA (not a symbolic ref to a branch):"
cat .git/HEAD
echo ""
echo "  WHY DANGEROUS: commits made in detached HEAD have NO branch pointer."
echo "  They become dangling objects and get garbage-collected after 30 days."
echo "  RESCUE: git switch -c rescue-branch-name  (save them to a named branch)"
echo ""

git switch main
echo ""

echo "── git switch -m: Merge uncommitted changes during switch ───────"
# [FLAG MEANING] -m = merge (switch context) — merges uncommitted local changes
#   INTO the target branch during the switch, resolving the conflict that would
#   otherwise make Git refuse the switch.
echo "  Usage: git switch -m <target-branch>"
echo "  Use when: You have uncommitted changes and switching would normally fail."
echo "  Alternative: git stash then git switch (cleaner, no merge risk)"
echo ""

echo "── git stash: Shelve uncommitted work for a clean context switch ─"
echo "Partial: Plant Beta Nsukka site survey notes" > site-survey.txt

# [SUBCOMMAND MEANING] stash = Stash — temporarily shelves ALL uncommitted
#   working-tree and index changes onto a LIFO stack, giving you a clean
#   working tree for safe branch switching or pulling.
# [FLAG MEANING] push = Push (stash subcommand) — explicit push to the stack.
# [FLAG MEANING] -m = message (stash context) — attaches a descriptive label
#   to the stash entry so you can identify it later in 'git stash list'.
git stash push -m "WIP: Plant Beta Nsukka site survey notes"
echo "  Working tree clean after stash:"
git status -s
echo "  Stash stack:"
git stash list
echo ""

# [FLAG MEANING] pop = Pop (stash context) — restores the most recent stash
#   entry AND removes it from the stash stack. Opposite of stash push.
git stash pop
echo "  Stash popped. site-survey.txt is back in working tree."
echo ""


# ─── SEGMENT 3.3 ─────────────────────────────────────────────────────────────

echo "── Segment 3.3: Branching Strategies for Production Teams ──────"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 3.3: Configure GitHub Flow Branch Protection  ║
╠══════════════════════════════════════════════════════════════════════╣
║  GitHub Flow is the right strategy for Nexus Concrete (lean team,   ║
║  continuous deployments, single production environment).             ║
║                                                                      ║
║  STEP 1: Your repo on GitHub → Settings → Branches                  ║
║  STEP 2: "Add branch protection rule" for pattern: main             ║
║  STEP 3: Enable:                                                     ║
║    ✅ Require a pull request before merging                           ║
║    ✅ Require approvals: 1                                            ║
║    ✅ Require status checks to pass before merging                   ║
║    ✅ Include administrators                                          ║
║    ✅ Do not allow force pushes                                       ║
║  STEP 4: Click "Create"                                              ║
║                                                                      ║
║  STEP 5: Locally, create and push a feature branch:                  ║
║    git switch -c feature/NEXUS-003-plant-beta                        ║
║    echo "Plant Beta: Nsukka" >> README.md                            ║
║    git add README.md                                                 ║
║    git commit -m "feat(plant): begin Plant Beta Nsukka planning"     ║
║    git push -u origin feature/NEXUS-003-plant-beta                  ║
║  STEP 6: GitHub → Open a DRAFT Pull Request to main                 ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

echo "── Branching strategy comparison: ───────────────────────────────"
echo ""
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │ TRUNK-BASED DEVELOPMENT (TBD)                               │"
echo "  │  All devs commit to main/trunk DAILY.                       │"
echo "  │  Feature branches live < 2 days.                            │"
echo "  │  Unfinished work hidden behind feature flags.               │"
echo "  │  Best for: High-velocity CI/CD teams. Nexus Concrete DevOps.│"
echo "  ├─────────────────────────────────────────────────────────────┤"
echo "  │ GITHUB FLOW                                                  │"
echo "  │  main is ALWAYS deployable.                                  │"
echo "  │  feature/ branches → PRs → merge to main.                   │"
echo "  │  Best for: SaaS products, continuous deployment.             │"
echo "  ├─────────────────────────────────────────────────────────────┤"
echo "  │ GIT FLOW (Nvie model)                                        │"
echo "  │  main, develop, feature/*, release/*, hotfix/*               │"
echo "  │  Overhead justifiable ONLY for: versioned software, SDKs,    │"
echo "  │  mobile apps, firmware with quarterly release cycles.        │"
echo "  └─────────────────────────────────────────────────────────────┘"
echo ""

# Pull rebase policy already configured in global setup, shown here for context.
# [KEY MEANING] branch.<name>.rebase = Branch Rebase Policy — configures a
#   specific named branch to always rebase (not merge) on git pull.
# [VALUE MEANING] true = enabled — enforces linear history on this branch.
git config branch.main.rebase true
echo "  [3.3] main branch configured: git pull will rebase, not merge."

# [KEY MEANING] pull.rebase = Pull Rebase Global — sets the global policy to
#   rebase instead of merge on ALL git pull operations across all branches.
git config pull.rebase true
echo "  [3.3] Global pull.rebase=true — clean history across all branches."
echo ""

echo "── CI/CD branch naming: The automation contract ─────────────────"
echo "  feature/NEXUS-001-second-plant  → triggers feature build pipeline"
echo "  fix/NEXUS-042-diesel-overflow   → triggers fix validation pipeline"
echo "  release/v1.2.0                  → triggers release staging pipeline"
echo "  hotfix/NEXUS-HOT-007-fire       → triggers emergency deploy pipeline"
echo ""

echo "── Merge-hell prevention strategies: ────────────────────────────"
echo "  1. Keep feature branches SHORT-LIVED (< 2 days)"
echo "  2. Rebase feature branch onto main DAILY"
echo "  3. Use feature flags for incomplete work"
echo "  4. Define CODEOWNERS so no one accidentally edits shared infra"
echo ""


# ─── SEGMENT 3.4 ─────────────────────────────────────────────────────────────

echo "── Segment 3.4: Merging — Types, Internals, When to Use Each ───"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 3.4: Merge a PR with All Three Strategies     ║
╠══════════════════════════════════════════════════════════════════════╣
║  Create 3 small PRs from 3 feature branches. Merge each one using   ║
║  a different button to observe how each shapes the commit graph.     ║
║                                                                      ║
║  PR #1 → "Create a merge commit"   → git merge --no-ff              ║
║    Result: explicit merge commit, branch topology preserved          ║
║                                                                      ║
║  PR #2 → "Squash and merge"        → git merge --squash             ║
║    Result: all PR commits collapse into ONE commit on main           ║
║                                                                      ║
║  PR #3 → "Rebase and merge"        → git rebase + fast-forward      ║
║    Result: PR commits land individually, no merge commit             ║
║                                                                      ║
║  After merging all three, run:                                       ║
║    git fetch origin                                                  ║
║    git log --oneline --graph --decorate --all                       ║
║  Compare how each strategy shaped the graph differently.             ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

# ── Find the merge base ────────────────────────────────────────────────────────
git switch -c feature/NEXUS-004-plant-beta-init
echo "Plant Beta: Nsukka confirmed" > plant-beta.txt
echo "Capacity: 1500 blocks per day" >> plant-beta.txt
git add plant-beta.txt
git commit -m "feat(plant-beta): add Plant Beta Nsukka initial config"
echo "Diesel budget Plant Beta: 35L/day" >> plant-beta.txt
git add plant-beta.txt
git commit -m "feat(plant-beta): add Plant Beta diesel budget allocation"

git switch main
echo ""
echo "── git merge-base: Finding the common ancestor ──────────────────"
# [SUBCOMMAND MEANING] merge-base = Merge Base — finds and prints the SHA of
#   the most recent COMMON ANCESTOR commit shared between two branches. This is
#   the "pivot point" that Git uses for three-way merge computation.
MERGE_BASE=$(git merge-base main feature/NEXUS-004-plant-beta-init)
echo "  Common ancestor of main and feature/NEXUS-004-plant-beta-init:"
echo "  $MERGE_BASE"
echo ""

echo "── Fast-forward merge (--ff-only): Linear path, no merge commit ─"
# [SUBCOMMAND MEANING] merge = Merge — integrates commits from the specified
#   branch into the current branch using fast-forward or three-way merge.
# [FLAG MEANING] --ff-only = Fast-Forward Only — ABORTS if fast-forward is not
#   possible (i.e., branches diverged). Enforces strictly linear history policy.
git merge --ff-only feature/NEXUS-004-plant-beta-init
echo ""
git log --oneline --graph --decorate -5
echo ""

# ── Create divergence for three-way merge demo ────────────────────────────────
echo "Executive summary: Plant Alpha 6-month milestone achieved" >> README.md
git add README.md
git commit -m "docs(readme): add Plant Alpha 6-month production milestone"

git switch -c feature/NEXUS-005-block-specs
echo "Block spec: 9-inch hollow (structural grade)" > block-specs.txt
echo "Block spec: 6-inch hollow (partition grade)"  >> block-specs.txt
git add block-specs.txt
git commit -m "feat(specs): define 9-inch and 6-inch hollow block specifications"
git switch main

echo "── Three-way merge --no-ff: Preserves branch topology ──────────"
# [FLAG MEANING] --no-ff = No Fast-Forward — forces the creation of a MERGE
#   COMMIT even when a fast-forward would be possible. Preserves a clear visual
#   record of when and what was integrated into the shared branch. Preferred
#   in Git Flow for auditable integration history.
git merge --no-ff feature/NEXUS-005-block-specs \
  -m "Merge feature/NEXUS-005-block-specs: add hollow block specifications"
echo ""
git log --oneline --graph --decorate -7
echo ""

# ── Squash merge ──────────────────────────────────────────────────────────────
git switch -c feature/NEXUS-006-pricing
echo "Price: 9-inch block = NGN 650"    > pricing.txt
git add pricing.txt
git commit -m "WIP: 9-inch block price draft"
echo "Price: 6-inch block = NGN 450"   >> pricing.txt
git add pricing.txt
git commit -m "WIP: 6-inch block price draft"
echo "Delivery: NGN 15,000 per truck"  >> pricing.txt
git add pricing.txt
git commit -m "WIP: add delivery charge"
git switch main

echo "── Squash merge: Collapse multiple WIP commits into ONE ─────────"
# [FLAG MEANING] --squash = Squash — collapses ALL commits from the source
#   branch into a SINGLE staged changeset WITHOUT creating a merge commit.
#   The source branch history is discarded. Requires a manual follow-up commit.
git merge --squash feature/NEXUS-006-pricing
git commit -m "feat(pricing): add block price list and delivery charges for Plant Alpha"
echo ""
git log --oneline --graph -5
echo ""

echo "── git log --merges / --no-merges ───────────────────────────────"
# --merges and --no-merges already explained in Seg 2.3; using without repeating tags.
git log --merges --oneline
echo "  (merge commits only)"
echo ""
git log --no-merges --oneline
echo "  (direct development commits only)"
echo ""


# ─── SEGMENT 3.5 ─────────────────────────────────────────────────────────────

echo "── Segment 3.5: Merge Conflicts — Detection, Resolution, Prevention ─"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 3.5: Create and Resolve a Conflict            ║
╠══════════════════════════════════════════════════════════════════════╣
║  STEP 1: On GitHub, edit README.md DIRECTLY on the main branch:     ║
║    Click README.md → pencil icon → add at bottom:                   ║
║    "GitHub edit: Plant Alpha status = OPERATIONAL"                   ║
║    Commit message: "docs: update status from GitHub web editor"      ║
║                                                                      ║
║  STEP 2: On your LOCAL machine (before pulling), also edit:          ║
║    echo "Local edit: Plant Alpha status = COMMISSIONING" >> README.md ║
║    git add README.md                                                 ║
║    git commit -m "docs: update status locally"                       ║
║                                                                      ║
║  STEP 3: git pull  →  CONFLICT on README.md                         ║
║                                                                      ║
║  STEP 4: Resolve via CLI:                                            ║
║    Open README.md, remove the <<<<<<< / ======= / >>>>>>> markers,  ║
║    keep the line you want, then:                                     ║
║    git add README.md && git merge --continue                         ║
║                                                                      ║
║  STEP 5: Resolve via GitHub web editor:                              ║
║    Go to a CONFLICTED Pull Request → "Resolve conflicts" button →    ║
║    edit in the browser → "Mark as resolved" → "Commit merge"         ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

echo "── Enabling diff3 conflict style ────────────────────────────────"
# [KEY MEANING] merge.conflictstyle = Merge Conflict Style — controls how Git
#   formats conflict markers in the file during a merge conflict.
# [VALUE MEANING] diff3 = Three-way diff — adds a THIRD section between the
#   markers showing the COMMON ANCESTOR version. You now see all three:
#   your version, the original, AND the incoming. Full context to resolve well.
git config merge.conflictstyle diff3
echo "  diff3 enabled. Conflict markers now show 3 sections:"
echo "  <<<<<<< HEAD              ← your version (current branch)"
echo "  ||||||| common ancestor   ← what it was before EITHER branch changed it"
echo "  =======                   ← separator"
echo "  >>>>>>> incoming-branch   ← their version"
echo ""

# ── Manufacture a merge conflict ──────────────────────────────────────────────
echo "── Manufacturing a merge conflict: ──────────────────────────────"

git switch -c conflict-branch-a
echo "Plant Alpha: Main Plant"                             > plant-config.txt
echo "Capacity: 2500 blocks per day (Branch A upgrade)"  >> plant-config.txt
echo "Diesel Budget: 50 litres/day"                       >> plant-config.txt
git add plant-config.txt
git commit -m "feat(plant): Branch A upgrades capacity to 2500 blocks"

git switch main
echo "Plant Alpha: Main Plant"                             > plant-config.txt
echo "Capacity: 3000 blocks per day (Phase 2 upgrade)"   >> plant-config.txt
echo "Diesel Budget: 55 litres/day"                       >> plant-config.txt
git add plant-config.txt
git commit -m "feat(plant): main branch Phase 2 capacity upgrade to 3000 blocks"

echo "  Triggering the merge conflict..."
git merge conflict-branch-a || true
echo ""

echo "── Conflict markers in plant-config.txt: ────────────────────────"
cat plant-config.txt
echo ""

echo "── git status during a conflict: ───────────────────────────────"
git status
echo ""

echo "── Resolving: Accept HEAD (--ours) ──────────────────────────────"
# [FLAG MEANING] --ours = Ours — resolves the conflict by accepting the CURRENT
#   branch's (HEAD's) version of the file wholesale, discarding incoming changes.
git checkout --ours plant-config.txt
git add plant-config.txt
# [FLAG MEANING] --continue = Continue (merge context) — resumes the paused
#   three-way merge after ALL conflicts have been resolved and re-staged.
git merge --continue --no-edit
echo "  Conflict resolved: accepted main's version (3000 blocks)."
echo ""

echo "── git checkout --theirs (reference): ───────────────────────────"
# [FLAG MEANING] --theirs = Theirs — resolves the conflict by accepting the
#   INCOMING branch's version wholesale, discarding HEAD's version.
echo "  Usage: git checkout --theirs <file>"
echo "  Use when: the incoming change is definitively correct for this file."
echo ""

echo "── git merge --abort: Cancel a conflict mid-resolution ──────────"
# Build a second conflict to demo abort.
git switch -c conflict-branch-b
echo "Abort bait content from branch B" > abort-bait.txt
git add abort-bait.txt
git commit -m "WIP: abort bait for demo"
git switch main
echo "Different abort bait from main" > abort-bait.txt
git add abort-bait.txt
git commit -m "WIP: conflicting abort bait on main"

git merge conflict-branch-b || true
echo ""
echo "  Merge paused at conflict. Aborting cleanly..."
# [FLAG MEANING] --abort = Abort (merge context) — cancels the in-progress merge
#   and restores the working tree and index to the EXACT pre-merge clean state.
git merge --abort
echo "  Repository fully restored. git status shows clean:"
git status -s
echo ""

echo "── git mergetool configuration: ─────────────────────────────────"
# [SUBCOMMAND MEANING] mergetool = Merge Tool — launches the configured visual
#   merge resolution tool to assist in resolving conflicts file by file.
# [KEY MEANING] merge.tool = Merge Tool Default — sets the GUI/CLI merge tool
#   that git mergetool will invoke for conflict resolution.
# [VALUE MEANING] vimdiff = the vimdiff visual diff/merge tool.
git config merge.tool vimdiff
# [FLAG MEANING] --tool=<toolname> = Tool Override — specifies which merge tool
#   to launch for THIS invocation, overriding the merge.tool config setting.
echo "  git mergetool --tool=code     → VS Code merge editor"
echo "  git mergetool --tool=meld     → Meld visual merge tool"
echo "  git mergetool --tool=vimdiff  → vimdiff terminal merge tool"
echo ""
# [KEY MEANING] mergetool.keepBackup = Merge Tool Keep Backup — controls whether
#   git mergetool leaves .orig backup files in the working tree after resolution.
# [VALUE MEANING] false = do NOT leave .orig files (keeps the directory clean).
git config mergetool.keepBackup false
echo "  mergetool.keepBackup=false → no .orig clutter after conflict resolution."
echo ""


# =============================================================================
#  MODULE 4: REBASING — LINEAR HISTORY MASTERY
# =============================================================================

echo "=================================================================="
echo "  MODULE 4: Rebasing — Linear History Mastery"
echo "=================================================================="
echo ""


# ─── SEGMENT 4.1 ─────────────────────────────────────────────────────────────

echo "── Segment 4.1: Rebase Fundamentals — How It Works Internally ──"
echo ""

# ── Build diverged branch for rebase demo ─────────────────────────────────────
echo "  Building a diverged scenario..."
git switch -c feature/NEXUS-007-logistics
echo "Logistics: truck delivery schedule — 5-tonne trucks" > logistics.txt
git add logistics.txt
git commit -m "feat(logistics): initial truck delivery schedule"

git switch main
echo "Executive report: Q1 production targets met" > exec-report.txt
git add exec-report.txt
git commit -m "docs(report): Q1 executive production report"
echo "Board decision: Southeast Nigeria expansion approved" >> exec-report.txt
git add exec-report.txt
git commit -m "docs(report): board approves Southeast Nigeria expansion"

echo ""
echo "── BEFORE rebase (main is 2 commits ahead, branches diverged): ─"
git log --oneline --graph --decorate --all -8
echo ""

# ── git rebase <base> ─────────────────────────────────────────────────────────
git switch feature/NEXUS-007-logistics

echo "── git rebase main: Replay commits on top of the new base ──────"
# [SUBCOMMAND MEANING] rebase = Rebase — replays commits from the current branch
#   on top of the specified base commit ONE BY ONE, creating NEW commits with new
#   SHAs (same diff content, completely new commit identity). The result is a
#   perfectly linear history with no merge commits.
# [VALUE MEANING] main = The new base — the feature branch's commits will be
#   detached from their old base and replayed on top of main's latest commit.
git rebase main
echo ""
echo "── AFTER rebase (linear history — no merge commit): ────────────"
git log --oneline --graph --decorate --all -8
echo ""

echo "── The Golden Rule of Rebasing: ────────────────────────────────"
echo "  NEVER rebase commits that have been pushed to a SHARED remote branch."
echo "  Rebasing rewrites SHAs. If a teammate has pulled your old SHAs,"
echo "  your force-push will create a fork in their history that breaks"
echo "  git pull, git merge, and every open PR based on that branch."
echo ""

echo "── Fast-forward after rebase: ───────────────────────────────────"
git switch main
git merge --ff-only feature/NEXUS-007-logistics
echo "  After rebase, main can fast-forward — clean, linear, no merge commit."
echo ""
git log --oneline --graph --decorate -5
echo ""

echo "── git pull --rebase (reference): ──────────────────────────────"
# [FLAG MEANING] --rebase = Rebase on Pull — fetches remote changes and REPLAYS
#   local commits on top of them instead of merging. Keeps local branch linear.
echo "  git pull --rebase origin main"
echo "  This fetches origin/main and replays your local commits on top."
echo ""

echo "── git rebase --rebase-merges (reference): ──────────────────────"
# [FLAG MEANING] --rebase-merges = Rebase Merges — preserves merge commits
#   within the rebased branch rather than flattening them into a linear sequence.
#   Required when replaying branches that have intentional complex topology.
echo "  git rebase --rebase-merges main"
echo "  Use when your feature branch itself has intentional merge commits inside it."
echo ""


# ─── SEGMENT 4.2 ─────────────────────────────────────────────────────────────

echo "── Segment 4.2: Interactive Rebase — History Surgery ────────────"
echo ""

: <<'GITHUB_OPS'
╔══════════════════════════════════════════════════════════════════════╗
║  GITHUB OPS — Segment 4.2: Clean Up a PR with Interactive Rebase    ║
╠══════════════════════════════════════════════════════════════════════╣
║  After the script creates 5 WIP commits, clean them up manually:    ║
║                                                                      ║
║  STEP 1: git log --oneline  (see the 5 WIP commits)                 ║
║                                                                      ║
║  STEP 2: git rebase -i HEAD~5                                        ║
║          Your editor opens with 5 "pick" lines.                      ║
║                                                                      ║
║  STEP 3: Edit the todo list to:                                      ║
║          pick   <sha1> WIP: start Plant Gamma Onitsha config         ║
║          squash <sha2> WIP: add capacity                             ║
║          squash <sha3> WIP: add diesel budget                        ║
║          fixup  <sha4> WIP: add labour headcount                     ║
║          reword <sha5> WIP: finalize Plant Gamma draft               ║
║                                                                      ║
║  STEP 4: Save → editor opens for squash message. Write:             ║
║          "feat(plant-gamma): add Plant Gamma Onitsha initial config" ║
║                                                                      ║
║  STEP 5: Force-push to update the PR on GitHub:                     ║
║          git push --force-with-lease origin feature/NEXUS-008-...   ║
║                                                                      ║
║  STEP 6: On GitHub: the PR now shows 2 clean commits instead of 5.  ║
╚══════════════════════════════════════════════════════════════════════╝
GITHUB_OPS

echo "  Building 5 WIP commits on feature/NEXUS-008-plant-gamma..."
git switch -c feature/NEXUS-008-plant-gamma

echo "Plant Gamma: Onitsha site"          > plant-gamma.txt
git add plant-gamma.txt
git commit -m "WIP: start Plant Gamma Onitsha config"

echo "Capacity: 1800 blocks per day"     >> plant-gamma.txt
git add plant-gamma.txt
git commit -m "WIP: add capacity line"

echo "Diesel budget: 40L/day"            >> plant-gamma.txt
git add plant-gamma.txt
git commit -m "WIP: add diesel budget"

echo "Labour: 12 workers per shift"      >> plant-gamma.txt
git add plant-gamma.txt
git commit -m "WIP: add labour headcount"

echo "Status: PLANNED"                   >> plant-gamma.txt
git add plant-gamma.txt
git commit -m "WIP: finalize Plant Gamma draft"

echo "── BEFORE interactive rebase (5 messy WIP commits): ────────────"
git log --oneline -6
echo ""

# ── Automate the interactive rebase via GIT_SEQUENCE_EDITOR ──────────────────
echo "── git rebase -i HEAD~5: Squashing 4 WIP into 1 clean commit ───"
# [FLAG MEANING] -i = interactive — opens a to-do list in the configured editor
#   where each commit is listed as a "pick" line. Engineer edits the commands
#   to pick, squash, fixup, reword, drop, exec, or break before execution.
# [VALUE MEANING] HEAD~5 = last 5 commits — the range of commits that will
#   appear in the interactive to-do list.

# We automate the editor steps here using GIT_SEQUENCE_EDITOR and GIT_EDITOR
# so the script runs non-interactively while still demonstrating real rebase.

REBASE_TODO_EDITOR="$WORKSPACE/rebase-todo.sh"
cat > "$REBASE_TODO_EDITOR" << 'TODO_EOF'
#!/usr/bin/env bash
# Keep commit 1 as 'pick'. Squash commits 2+3, fixup commits 4+5.
sed -i '2s/^pick/squash/' "$1"
sed -i '3s/^pick/squash/' "$1"
sed -i '4s/^pick/fixup/'  "$1"
sed -i '5s/^pick/fixup/'  "$1"
TODO_EOF
chmod +x "$REBASE_TODO_EDITOR"

REBASE_MSG_EDITOR="$WORKSPACE/rebase-msg.sh"
cat > "$REBASE_MSG_EDITOR" << 'MSG_EOF'
#!/usr/bin/env bash
# Supply the clean squash commit message programmatically.
printf "feat(plant-gamma): add Plant Gamma Onitsha initial configuration\n\nCombines: site confirmation, capacity, diesel budget, and labour headcount\ninto a single clean commit ready for PR review.\n" > "$1"
MSG_EOF
chmod +x "$REBASE_MSG_EDITOR"

GIT_SEQUENCE_EDITOR="$REBASE_TODO_EDITOR" \
  GIT_EDITOR="$REBASE_MSG_EDITOR" \
  git rebase -i HEAD~5

echo ""
echo "── AFTER interactive rebase (5 WIP → 1 clean commit): ─────────"
git log --oneline -4
echo ""

echo "── Interactive rebase todo commands reference: ───────────────────"
# [VALUE MEANING] pick = Keep commit — includes the commit in the rewritten
#   history exactly as-is, with no changes.
echo "  pick    → keep the commit unchanged"
# [VALUE MEANING] reword = Reword — keeps the commit's changes but pauses to
#   let the engineer edit the commit message before continuing.
echo "  reword  → keep changes, edit the message"
# [VALUE MEANING] edit = Edit — pauses the rebase at this commit; the engineer
#   can amend the commit, add new files, or split it into multiple commits.
echo "  edit    → pause here: amend or split this commit"
# [VALUE MEANING] squash = Squash — folds the commit's changes INTO the
#   preceding commit and opens an editor to combine both commit messages.
echo "  squash  → fold into previous commit, combine messages"
# [VALUE MEANING] fixup = Fixup — folds the commit's changes into the preceding
#   commit and SILENTLY DISCARDS this commit's message. The 'quiet squash'.
echo "  fixup   → fold into previous commit, discard THIS message"
# [VALUE MEANING] drop = Drop — completely removes the commit and ALL its
#   changes from the rewritten history. Permanently gone.
echo "  drop    → delete this commit from history entirely"
# [VALUE MEANING] exec = Execute — runs the specified shell command after the
#   preceding commit is applied, enabling per-commit test validation mid-rebase.
echo "  exec    → run a shell command after this commit (e.g., exec make test)"
# [VALUE MEANING] break = Break — pauses the rebase unconditionally at this
#   point in the to-do list for manual inspection before continuing.
echo "  break   → pause here for manual inspection"
echo ""

echo "── git push --force-with-lease: Safe rewrite push to update PR ─"
# [FLAG MEANING] --force-with-lease = Force With Lease — pushes a rewritten
#   branch ONLY if no teammate has pushed to the remote since your last fetch.
#   Uses the remote-tracking ref (origin/branch) as a lease/lock check.
#   If someone else pushed since your fetch, this REFUSES to overwrite them.
echo "  git push --force-with-lease origin feature/NEXUS-008-plant-gamma"
echo "  GitHub PR will automatically update with the rewritten history."
echo ""

echo "── Splitting a commit (walkthrough): ───────────────────────────"
# [SUBCOMMAND MEANING] reset = Reset (see Seg 2.5 — --hard already explained).
# [VALUE MEANING] HEAD~ (with reset in rebase context) = Undoes the commit that
#   the rebase paused on, leaving all its changes in the working tree as
#   unstaged modifications so you can re-stage them in smaller, logical chunks.
echo "  1. git rebase -i HEAD~N   (mark target as 'edit')"
echo "  2. git reset HEAD~        (undo commit, keep changes unstaged)"
echo "  3. git add -p <file>      (stage first logical chunk)"
echo "  4. git commit -m 'Part 1'"
echo "  5. git add -p <file>      (stage second logical chunk)"
echo "  6. git commit -m 'Part 2'"
echo "  7. git rebase --continue"
echo ""

echo "── git rebase --continue: Resume after an edit/conflict pause ───"
# [FLAG MEANING] --continue = Continue (rebase context) — resumes the rebase
#   after a conflict has been resolved and re-staged, or after an edit/break
#   pause has been completed with a git commit or git amend.
echo "  Always run after: resolving a conflict + git add <file>"
echo "  Always run after: completing an 'edit' pause with git commit"
echo ""


# ─── SEGMENT 4.3 ─────────────────────────────────────────────────────────────

echo "── Segment 4.3: Rebase Conflicts and Advanced Recovery ──────────"
echo ""

echo "── Demonstrating git rebase --abort ─────────────────────────────"
# Add a conflicting commit to main before attempting the rebase.
git switch main
echo "Main override of Plant Gamma config" > plant-gamma.txt
git add plant-gamma.txt
git commit -m "chore(config): main branch overrides Plant Gamma config"

git switch feature/NEXUS-008-plant-gamma
echo "  Attempting a rebase that will conflict with main..."
git rebase main || true
echo ""
echo "  Rebase paused at conflict. Choosing to abort cleanly..."
# --abort already explained in Seg 3.4 (merge --abort). Same concept for rebase:
# restores the branch to its EXACT state before the rebase was invoked.
git rebase --abort
echo "  Branch fully restored to pre-rebase state."
git log --oneline -3
echo ""

echo "── git rebase --skip: DANGEROUS — only when safe ────────────────"
# [FLAG MEANING] --skip = Skip (rebase context) — discards the currently
#   conflicting commit ENTIRELY and advances to the next commit in the rebase
#   plan. This PERMANENTLY LOSES that commit's changes.
# [WATCH OUT]: Only use --skip when Git's patch-ID deduplication has confirmed
#   the conflicting commit's changes are ALREADY present in the target branch
#   (e.g., applied via cherry-pick). Otherwise you lose work silently.
echo "  git rebase --skip"
echo "  WATCH OUT: This discards the conflicting commit's changes FOREVER."
echo "  Only safe when the commit's changes already exist in the target branch."
echo ""

echo "── ORIG_HEAD: The one-step rebase undo ──────────────────────────"
echo "  Before ANY rebase/reset/merge, Git saves the current HEAD to ORIG_HEAD."
echo "  To undo a COMPLETED rebase:"
# --hard already explained in Seg 2.5. ORIG_HEAD here is the key reference:
echo "  git reset --hard ORIG_HEAD"
echo "  This is your immediate escape hatch right after a bad rebase."
echo "  Only works BEFORE git gc prunes ORIG_HEAD (typically ~90 days)."
echo ""

echo "── git rerere: Reuse Recorded Resolution ────────────────────────"
# [KEY MEANING] rerere.enabled = Rerere Enabled — activates the "Reuse Recorded
#   Resolution" engine. When you resolve a merge/rebase conflict, rerere records
#   HOW you resolved it in .git/rr-cache/. Next time the identical conflict
#   appears (common in long-running rebase loops), rerere replays the resolution
#   AUTOMATICALLY. A major productivity multiplier for complex rebasing.
git config rerere.enabled true
echo "  rerere enabled. Resolution cache: .git/rr-cache/"
echo ""

# [SUBCOMMAND MEANING] rerere = Reuse Recorded Resolution — manually invokes
#   the rerere engine to record the current conflict state or replay a saved one.
echo "── rerere commands: ─────────────────────────────────────────────"
echo "  git rerere              → record or replay a conflict resolution"
# [VALUE MEANING] diff (with rerere) = shows the current conflict being processed
#   by rerere, so you can verify what resolution will be cached before accepting.
echo "  git rerere diff         → show what resolution will be recorded"
# [VALUE MEANING] forget <path> (with rerere) = deletes the cached resolution
#   for the specified file from .git/rr-cache/, forcing a fresh manual resolution.
echo "  git rerere forget <file>  → delete cached resolution for that file"
echo ""


# ─── SEGMENT 4.4 ─────────────────────────────────────────────────────────────

echo "── Segment 4.4: Rebase vs. Merge — Production Decision Framework ─"
echo ""

echo "── THE DECISION FRAMEWORK ───────────────────────────────────────"
echo ""
echo "  ✅ USE REBASE WHEN:"
echo "     - Cleaning up a personal/feature branch BEFORE submitting a PR"
echo "     - Integrating upstream main changes INTO your feature branch"
echo "     - Squashing WIP commits before code review"
echo ""
echo "  ✅ USE MERGE WHEN:"
echo "     - Integrating a feature branch INTO a protected shared branch (main)"
echo "     - Preserving documented history of WHEN work was integrated"
echo "     - Creating a release commit with an explicit integration record"
echo ""
echo "  🚫 NEVER REBASE WHEN:"
echo "     - Commits have been pushed to a SHARED remote branch"
echo "     - Multiple teammates are working on the SAME branch simultaneously"
echo "     - The branch is protected (main, develop, release/*)"
echo ""

echo "── git push -f: The nuclear option — reference only ─────────────"
# [FLAG
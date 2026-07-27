# FASRC VS Code Workflow

This package installs a `fasrc` command for opening VS Code on live FASRC SLURM
compute jobs and applying a shared VS Code workflow.

## Who This Is For

This is a macOS workflow for FASRC users who want VS Code Remote-SSH windows on
allocated Cannon compute nodes. FASRC documents direct Remote-SSH compute-node
connections as macOS-only; Windows users should use the
[FASRC Remote Tunnel workflow](https://docs.rc.fas.harvard.edu/kb/vscode-remote-development-via-ssh-or-tunnel/)
instead. The utility is not for FASSE compute nodes, where FASRC does not permit
this Remote-SSH allocation pattern.

FASRC recommends its Remote Tunnel batch workflow for maximum resilience to
network interruptions. Use this utility when direct macOS Remote-SSH sessions,
including multiple independent windows, fit your workflow.

## Install

Prerequisites:

- VS Code with the `code` shell command available on `PATH`
- `ssh`, `ssh-keygen`, `awk`, `perl`, and `jq`
- FASRC login access and your FASRC username

```sh
./install.sh --user YOUR_FASRC_USERNAME
```

Then open a new terminal, or run:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## First Run

This is the complete first-use workflow. Run these commands in a Terminal on
your own Mac, not in an agent sandbox:

```sh
# Establish the FASRC password/2FA session that VS Code will reuse.
fasrc login

# Apply local VS Code settings and inspect any existing fasrc-vscode jobs.
fasrc setup --local-only --no-local-update
fasrc status

# Allocate one 70-hour shared-partition session with 8 CPUs and 16G, then open it.
fasrc new
```

The first remote connection installs the VS Code server and extensions under
your FASRC home directory, so it can take longer than later connections. The
utility also installs its pinned `latexmk` into the shared FASRC home on the
first full setup or launch.

## Three-Window Demo

For three independent compute sessions, allocate them without trying to control
the desktop from a script or agent:

```sh
fasrc new -n 3 --no-open
fasrc status
```

Copy the three job IDs printed by `fasrc status`, then open one folder per job:

```sh
fasrc open JOB_ID_1 project-a
fasrc open JOB_ID_2 project-b
fasrc open JOB_ID_3 project-c
```

When you are done, cancel only these utility-managed jobs:

```sh
fasrc stop --all
```

## Commands

```sh
fasrc status
fasrc --job JOB_ID
fasrc open JOB_ID
fasrc new
fasrc new -n 3
fasrc new -n 3 --no-open
fasrc update
fasrc setup
fasrc extensions list
fasrc paths
fasrc login
fasrc help
```

`fasrc new` defaults to a 70-hour job with 8 CPUs and 16G memory on FASRC's
`shared` partition. New job wall times are capped at 72 hours by default:

```sh
fasrc new
```

To submit three jobs one second apart, respecting FASRC scheduler guidance, and
then request three VS Code windows:

```sh
fasrc new -n 3
```

To allocate three jobs concurrently without opening VS Code windows immediately:

```sh
fasrc new -n 3 --no-open
```

## Opening VS Code From An Agent

`fasrc open JOB_ID [remote-path]` launches the local VS Code application. Run
that command in a Terminal on the Mac whose desktop should receive the window.

An AI coding agent can allocate jobs, refresh SSH aliases, and run the command,
but its command environment may not own the user's macOS GUI session. An exit
code from `fasrc open` is therefore not proof that a visible VS Code window was
created. When an agent cannot inspect or control the desktop, it should give the
user the exact commands to paste into their own Terminal, for example:

```sh
fasrc open 12345678 project-a
fasrc open 12345679 project-b
```

The agent should report those commands as launched only after the user confirms
the windows appeared.

## Personal Defaults

Local personal defaults can live in:

```text
~/.config/fasrc/defaults.env
```

That file is parsed as data before defaults are computed; it is never executed as
shell code. Only the documented `FASRC_DEFAULT_*`, `FASRC_MAX_SLURM_TIME`, and
`FASRC_SUBMIT_INTERVAL` keys are accepted. Command-line flags still win. Useful
entries include:

```sh
FASRC_DEFAULT_NEW_COUNT=3
FASRC_DEFAULT_REMOTE_PATH="my-project"
FASRC_DEFAULT_TIME=70:00:00
FASRC_DEFAULT_CPUS=8
FASRC_DEFAULT_MEM=16G
FASRC_DEFAULT_PARTITION=shared
FASRC_DEFAULT_ACCOUNT=my_lab
FASRC_SUBMIT_INTERVAL=1
FASRC_VSCODE_SERVER_INSTALL_ROOT="/scratch/YOUR_USERNAME/vscode-server-fasrc"
```

For multi-job launches, `FASRC_SUBMIT_INTERVAL` must be at least `0.5` seconds.
The server-root override is optional; see [Persistence](#persistence) before
using a node-local path.

With `FASRC_DEFAULT_NEW_COUNT=3`, `fasrc new` behaves like `fasrc new -n 3`.
The plain `fasrc` command still reuses one existing job, and if no job exists it
allocates one job unless you explicitly run `fasrc new`.

`shared` is the default because a Remote-SSH session is disrupted when a job is
requeued. FASRC notes in its
[cluster responsibilities guidance](https://docs.rc.fas.harvard.edu/kb/responsibilities/)
that `serial_requeue` can be more available, but jobs there may be stopped and
restarted; use it only for work that handles requeue safely:

```sh
FASRC_DEFAULT_PARTITION=serial_requeue
```

## Path Aliases

Local remote path aliases can live in:

```text
~/.config/fasrc/paths.env
```

Format:

```sh
name=/remote/path
```

Then use the alias anywhere a remote path is accepted:

```sh
fasrc open JOB_ID name
fasrc new -n 3 name
fasrc open JOB_ID name/subdir
```

## Cached Login

If VS Code starts asking for a FASRC password again, recreate the local SSH
master socket once:

```sh
fasrc login
```

Then reload or reopen the VS Code Remote-SSH windows. You can verify the socket
with:

```sh
ssh -O check fasrc
```

Expected output includes `Master running`.

## What Installation Changes

The installer is idempotent and only manages the FASRC workflow files:

- `~/.local/bin/fasrc`
- `~/.config/fasrc/login-alias`
- `~/.config/fasrc/extensions.txt`
- `~/.ssh/config`
- `~/.ssh/fasrc_compute_config`
- `~/.ssh/id_ed25519` if no SSH key exists yet
- your shell rc file, to add `~/.local/bin` to `PATH`

`fasrc setup` also updates VS Code user `settings.json` with Remote-SSH,
extension, and LaTeX Workshop defaults. Before its first change, it preserves the
original file as `settings.json.fasrc-backup`. JSON-with-comments (JSONC) is
accepted; comments remain in the backup while the updated settings are written as
strict JSON. Existing LaTeX recipes, tools, viewer choice, and PDF association are
preserved.

On the FASRC login host, the utility also maintains
`~/.local/bin/fasrc-alloc`, a small helper used to submit and wait for the
utility's SLURM jobs, and `~/.local/share/fasrc/bin/latexmk`, the pinned LaTeX
Workshop build tool. The latter is downloaded from the latexmk author's
versioned HTTPS archive and verified against both archive and script SHA-256
checksums before installation.

## VS Code Setup

The default extension list is in:

```text
~/.config/fasrc/extensions.txt
```

Current defaults:

```text
james-yu.latex-workshop
anthropic.claude-code
oscarphysics.claudetex
openai.chatgpt
```

`openai.chatgpt` is the Marketplace ID for the OpenAI Codex extension.

Add more extensions with:

```sh
fasrc extensions add publisher.extension-id
fasrc setup
```

## LaTeX Defaults

`fasrc setup` configures LaTeX Workshop to:

- build PDFs with `latexmk -pdf`
- emit SyncTeX data with `-synctex=1`
- write outputs to `build/`
- auto-build on save
- open PDFs in the LaTeX Workshop tab viewer on the right
- jump source to PDF after build
- jump PDF back to source with double-click

The recipe is path-safe: it runs `latexmk` from the TeX file's directory and
passes only the file basename, which avoids issues with spaces in parent paths.
It invokes the managed executable at
`~/.local/share/fasrc/bin/latexmk` explicitly instead of relying on the VS Code
server's `PATH`. On a local, non-FASRC VS Code window where that managed path is
absent, the recipe falls back to a locally installed `latexmk` on `PATH`.

`fasrc setup` (without `--local-only`) and all `fasrc` launch/open/new commands
verify the managed executable and install pinned latexmk 4.88 when it is absent
or differs from the expected checksum. The FASRC login host must provide
`curl`, `unzip`, `perl`, and either `sha256sum` or `shasum`; setup stops with a
specific error if any prerequisite or integrity check fails.

## Persistence

VS Code Remote-SSH normally installs a server under the remote home directory.
This workflow pins FASRC compute aliases to:

```text
REMOTE_HOME/.vscode-server-fasrc
```

FASRC home directories are shared across compute nodes, so one VS Code server
and one remote extension setup can be reused by multiple live compute jobs.
That is the part that avoids repeatedly downloading the VS Code server and
extensions into per-node `/tmp`.

If the shared home filesystem makes the initial server extraction stall, set
`FASRC_VSCODE_SERVER_INSTALL_ROOT` in `~/.config/fasrc/defaults.env` to a
private, user-owned directory on node-local storage. This makes startup faster,
but each compute node needs its own server installation. Do not use a
world-writable directory directly; use a private subdirectory owned by your
account.

The `fasrc-compute` alias points to the current preferred job after `fasrc status`
or a launch command. It uses that node's real host-key identity with
`StrictHostKeyChecking accept-new`; host-key verification is never disabled.

If a multi-job allocation fails partway through, `fasrc` cancels the jobs created
by that failed batch. It does not cancel older jobs or unrelated SLURM work.

## Security Notes

- CLI and configuration values are encoded before they cross SSH, so they are not
  reinterpreted as remote shell syntax.
- The saved-current-job file is parsed as numeric data and is never sourced.
- Personal configuration, state, and generated SSH files are restricted to the
  owning user (`700` directories and `600` files).
- `ControlPersist 96h` intentionally leaves a reusable authenticated SSH socket
  for up to four days. The socket directory is mode `700`; run
  `ssh -O exit fasrc` to close it early.
- If no local Ed25519 key exists, the installer creates a passwordless key so
  unattended compute-node connections work. Protect the Mac account and private
  key; users who require a passphrase should create and load their own
  `~/.ssh/id_ed25519` before installation.

## Troubleshooting

- VS Code asks for your password again: run `fasrc login`, confirm
  `ssh -O check fasrc` reports `Master running`, then reconnect.
- A new job is running but VS Code cannot connect: run `fasrc status` to refresh
  aliases, then use `fasrc open JOB_ID PATH` from your local Terminal.
- An agent says it opened a window but no window appears: paste the reported
  `fasrc open` command into your own Terminal. Agent shells may not own the
  macOS desktop session.
- A connection fails after a network change: run `fasrc login` again, then
  retry the `fasrc open` command.
- The first connection is slow: wait for the remote VS Code server and
  extensions to install. Later sessions reuse the persistent server path.
- FASRC job allocation is pending: this reflects the scheduler queue. Avoid
  repeatedly running `fasrc status`; FASRC asks users not to poll scheduler
  commands more often than once per minute.

## Username Handling

The installer writes an SSH host block like:

```sshconfig
Host fasrc
  HostName login.rc.fas.harvard.edu
  User YOUR_FASRC_USERNAME
```

Nothing in the scripts hard-codes a specific user. `fasrc` reads the remote user
from SSH config through the configured login alias (`fasrc` by default).

The installer stores its validated login alias in
`~/.config/fasrc/login-alias`, so a custom `FASRC_ALIAS` remains effective after
the installer process exits. `FASRC_LOGIN_HOST` can still override it for an
individual command.

## Command Name

The only user-facing command installed by this package is:

```sh
fasrc
```

## Verify

After installing:

```sh
command -v fasrc
fasrc extensions list
fasrc setup --local-only --no-local-update
bash tests/run.sh
```

Only `fasrc` should be a public command. Old prerelease names such as
`fasrc-code` and `fasrc-workspace` are removed by the installer when present.

## Cleanup

To remove the installed command files:

```sh
rm -f ~/.local/bin/fasrc
```

Optionally remove the remote allocator after closing all `fasrc-vscode` jobs:

```sh
ssh fasrc 'rm -f ~/.local/bin/fasrc-alloc ~/.local/share/fasrc/bin/latexmk'
```

Then remove the FASRC include line and generated `Host fasrc` block from
`~/.ssh/config` if you no longer want this SSH setup. The generated compute
aliases live in:

```text
~/.ssh/fasrc_compute_config
```

VS Code settings are ordinary JSON settings. Remove the `remote.SSH.*`,
`latex-workshop.*`, and `workbench.editorAssociations["*.pdf"]` entries added by
`fasrc setup` if you want to revert the editor workflow.

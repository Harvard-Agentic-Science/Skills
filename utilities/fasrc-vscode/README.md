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
your FASRC home directory, so it can take longer than later connections.

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

That file is sourced by `fasrc` before defaults are computed. Command-line flags
still win. Useful entries include:

```sh
FASRC_DEFAULT_NEW_COUNT=3
FASRC_DEFAULT_REMOTE_PATH="my-project"
FASRC_DEFAULT_TIME=70:00:00
FASRC_DEFAULT_CPUS=8
FASRC_DEFAULT_MEM=16G
FASRC_DEFAULT_PARTITION=shared
FASRC_DEFAULT_ACCOUNT=my_lab
FASRC_SUBMIT_INTERVAL=1
```

For multi-job launches, `FASRC_SUBMIT_INTERVAL` must be at least `0.5` seconds.

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
- `~/.local/bin/fasrc-proxy`
- `~/.config/fasrc/extensions.txt`
- `~/.ssh/config`
- `~/.ssh/fasrc_compute_config`
- `~/.ssh/id_ed25519` if no SSH key exists yet
- your shell rc file, to add `~/.local/bin` to `PATH`

`fasrc setup` also updates VS Code user `settings.json` with Remote-SSH,
extension, and LaTeX Workshop defaults.

On the FASRC login host, the utility also maintains
`~/.local/bin/fasrc-alloc`, a small helper used to submit and wait for the
utility's SLURM jobs.

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
from SSH config with `ssh -G fasrc`.

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
bash tests/smoke.sh
```

Only `fasrc` should be a public command. Old prerelease names such as
`fasrc-code` and `fasrc-workspace` are removed by the installer when present.

## Cleanup

To remove the installed command files:

```sh
rm -f ~/.local/bin/fasrc ~/.local/bin/fasrc-proxy
```

Optionally remove the remote allocator after closing all `fasrc-vscode` jobs:

```sh
ssh fasrc 'rm -f ~/.local/bin/fasrc-alloc'
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

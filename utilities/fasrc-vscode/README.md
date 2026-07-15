# FASRC VS Code Workflow

This package installs a `fasrc` command for opening VS Code on live FASRC SLURM
compute jobs and applying a shared VS Code workflow.

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

`fasrc new` defaults to a 70-hour job with 8 CPUs and 16G memory. New job
wall times are capped at 72 hours by default:

```sh
fasrc new
```

To allocate three of those jobs concurrently and open three VS Code windows:

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
```

With `FASRC_DEFAULT_NEW_COUNT=3`, `fasrc new` behaves like `fasrc new -n 3`.
The plain `fasrc` command still reuses one existing job, and if no job exists it
allocates one job unless you explicitly run `fasrc new`.

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

## TODO

- Investigate the delay between `Allocated new job ...` and the VS Code window
  becoming usable. This likely needs live FASRC trial and error, so it is
  intentionally not part of the current parallel allocation change.

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
```

Only `fasrc` should be a public command. Old prerelease names such as
`fasrc-code` and `fasrc-workspace` are removed by the installer when present.

## Cleanup

To remove the installed command files:

```sh
rm -f ~/.local/bin/fasrc ~/.local/bin/fasrc-proxy
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

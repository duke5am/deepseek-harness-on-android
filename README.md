# DeepSeek Harness (dsh) on Android — Termux + proot-distro + Ubuntu Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![dsh](https://img.shields.io/badge/dsh-0.1.1--rc.2-4D6BFE.svg)](https://github.com/deepseek-ai/deepseek-harness)
[![Termux](https://img.shields.io/badge/Termux-ready-21b352.svg)](https://f-droid.org/en/packages/com.termux/)
[![PRoot](https://img.shields.io/badge/PRoot-supported-green.svg)](https://github.com/termux/proot-distro)
[![Ubuntu 26.04 LTS](https://img.shields.io/badge/Ubuntu-26.04%20LTS-E95420.svg)](https://ubuntu.com)

> A complete, copy-paste guide to **install** and **run DeepSeek Harness (dsh)** — the CLI + browser-web-UI **agent harness** — on an **Android** phone with **Termux**, **proot-distro**, and **Ubuntu**. Covers **Node.js/npm**, **dsh installation**, first-run configuration, the **environment skills**, and **Python dependencies**. Verified on **Ubuntu 26.04 LTS "Resolute Raccoon" (aarch64) under PRoot** — no root required.

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) is an open-source **agent harness** (a CLI + browser **web UI**) that boots a *profile* — an ordered stack of plugin layers — to run an **LLM agent** with tools. This repository is a step-by-step **tutorial** for running it on an **Android** phone with **Termux** + **proot-distro** (Ubuntu under PRoot, no root), plus the companion environment skills from [`duke5am/skills-for-proot-distro-ubuntu`](https://github.com/duke5am/skills-for-proot-distro-ubuntu).

## Quick start (TL;DR)

The entire setup, condensed to two copy-paste blocks:

```bash
# --- 1. In Termux ---
pkg update && pkg upgrade
pkg install proot-distro
proot-distro install ubuntu
proot-distro login ubuntu
```

```bash
# --- 2. Inside Ubuntu (as root) ---
apt update && apt install -y curl git
curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/setup_node.sh && bash /tmp/setup_node.sh
apt install -y nodejs
npm install -g @deepseek-ai/dsh
git clone --depth 1 https://github.com/duke5am/skills-for-proot-distro-ubuntu.git /tmp/dsh-skills && cp -r /tmp/dsh-skills/{package-installation,python-usage,shell-usage,writing-skills} ~/.dsh/skills/ && rm -rf /tmp/dsh-skills
dsh web   # browser UI at http://127.0.0.1:3080
```

Read on for the detailed walkthrough (configuration, Python dependencies, and troubleshooting).

## What's inside

- `README.md` — this step-by-step setup guide
- `setup.sh` — automates steps 4–7 (dsh install, skills clone, core apt packages)
- `requirements.txt` — a full `pip3 freeze` snapshot of the verified Python environment
- `LICENSE` — MIT

## Verified environment

This guide was written and tested against the exact versions below — the same box the `requirements.txt` snapshot was generated from:

| Component | Version |
|---|---|
| Host | Android (arm64) + Termux (F-Droid) |
| Distro | Ubuntu 26.04 LTS "Resolute Raccoon" via proot-distro |
| Node.js | 22.23.2 (NodeSource `node_22.x`) |
| npm | 10.9.8 |
| dsh | 0.1.1-rc.2 (`@deepseek-ai/dsh`) |
| Python | 3.14.4 |
| pip | 25.1.1 (PEP 668 — externally managed) |
| DSH_HOME | `/root/.dsh` |

## Step 1 — Install Termux

Install the **F-Droid** build (the Play Store build is deprecated and outdated):

- [Termux on F-Droid](https://f-droid.org/en/packages/com.termux/)

```bash
pkg update && pkg upgrade
```

## Step 2 — Install proot-distro + Ubuntu

```bash
pkg install proot-distro
proot-distro install ubuntu
proot-distro login ubuntu
```

`proot-distro install ubuntu` pulls the current Ubuntu LTS into a rootless container. From here on, every command runs **inside** the Ubuntu distro as root (no `sudo` needed).

## Step 3 — Install Node.js + npm (inside Ubuntu)

Use the NodeSource `node_22.x` repository (matches the verified build):

```bash
apt update
apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/setup_node.sh
bash /tmp/setup_node.sh
apt install -y nodejs
node --version   # v22.23.2
npm --version    # 10.9.8
```

> Download the setup script to a file and `bash` it instead of `curl … | bash`.
> Under PRoot, piping forked/threaded processes can hang — see the shell gotchas in the skills repo.

## Step 4 — Install dsh via npm

```bash
npm install -g @deepseek-ai/dsh
dsh --version   # 0.1.1-rc.2
```

With npm's global prefix at `/usr`, the binary lands at `/usr/bin/dsh`.

## Step 5 — First run & configuration

```bash
dsh --help              # list subcommands
dsh web                 # boot the browser UI (default: http://127.0.0.1:3080)
dsh --profile tui       # terminal UI
dsh --profile headless "answer one task and exit"
```

On first boot dsh creates `~/.dsh` (i.e. `$DSH_HOME`, which is `/root/.dsh` under PRoot):

- `.credentials.yaml` — provider API credentials (set during web onboarding)
- `settings.yaml` — default model, permission preset, shell timeout
- `skills/` — user skills root (where the environment skills go)
- `profiles/`, `sessions/`, `storages/` — profile layers and session state

Open the web UI in your phone's browser at `http://127.0.0.1:3080` (or forward the port over `ssh`/`adb` to reach it from a desktop).

## Step 6 — Install the environment skills

These four skills teach the model the PRoot/Termux-specific rules (apt-not-pip, the pipe-hang, the FUSE write EPERM, etc.) so sub-agents stop hitting execution and path errors:

```bash
git clone --depth 1 https://github.com/duke5am/skills-for-proot-distro-ubuntu.git /tmp/dsh-skills
cp -r /tmp/dsh-skills/{package-installation,python-usage,shell-usage,writing-skills} ~/.dsh/skills/
rm -rf /tmp/dsh-skills
```

Restart the dsh session so the skill catalog rescans, then confirm the four skill names appear in the session's available-skills list.

## Step 7 — Python dependencies

`requirements.txt` is a full `pip3 freeze` snapshot of the verified environment. Two ways to use it:

**Recommended — apt (no venv, no pip):** Ubuntu packages the scientific stack as `python3-<name>`:

```bash
apt install -y python3-pandas python3-numpy python3-scipy python3-matplotlib \
  python3-requests python3-pypdf python3-bs4 python3-openpyxl \
  python3-lxml python3-httpx python3-yaml python3-dotenv \
  python3-cryptography python3-tqdm python3-pil
```

**Exact reproduction — venv + requirements.txt:** `pip` is blocked system-wide by PEP 668, but a venv's pip is not:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Automation

`setup.sh` runs steps 4–7 in one shot (dsh install → skills clone → core apt packages):

```bash
chmod +x setup.sh
./setup.sh
```

## Troubleshooting

- `pip install` refused with `externally-managed-environment` → use `apt install python3-<module>` (PEP 668).
- A command "hangs" → don't pipe to `tail`/`head`; redirect to a file, then read it in a separate command.
- The harness `write` tool fails with `EPERM` on `/sdcard` → write via a bash heredoc or Python (FUSE lacks atomic rename).
- A copied skill doesn't load → check `SKILL.md` frontmatter (`name`/`description`) against the `writing-skills` checklist.

Full details for every item above: [duke5am/skills-for-proot-distro-ubuntu](https://github.com/duke5am/skills-for-proot-distro-ubuntu).

## License

MIT — see [LICENSE](LICENSE).

#!/usr/bin/env bash
# deepseek-harness-on-android — one-shot setup for PRoot Ubuntu (Termux + proot-distro).
# Run INSIDE the Ubuntu distro as root. Covers: dsh install, skills, core Python deps.
set -euo pipefail

SKILLS_REPO="https://github.com/duke5am/skills-for-proot-distro-ubuntu.git"
DSH_SKILLS_DIR="${DSH_HOME:-$HOME/.dsh}/skills"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

log "[1/4] Installing dsh (npm)"
npm install -g @deepseek-ai/dsh
echo "    dsh $(dsh --version)"

log "[2/4] Installing dsh environment skills"
mkdir -p "$DSH_SKILLS_DIR"
rm -rf /tmp/dsh-skills
git clone --depth 1 "$SKILLS_REPO" /tmp/dsh-skills
cp -r /tmp/dsh-skills/{package-installation,python-usage,shell-usage,writing-skills} "$DSH_SKILLS_DIR/"
rm -rf /tmp/dsh-skills
echo "    installed into $DSH_SKILLS_DIR"

log "[3/4] Installing core Python packages (apt)"
apt-get update
apt-get install -y \
  python3-pandas python3-numpy python3-scipy python3-matplotlib \
  python3-requests python3-pypdf python3-bs4 python3-openpyxl \
  python3-lxml python3-httpx python3-yaml python3-dotenv \
  python3-cryptography python3-tqdm python3-pil

log "[4/4] Done. Restart dsh so the skill catalog rescans, then verify:"
echo "    dsh --version"
echo "    ls \"$DSH_SKILLS_DIR\""

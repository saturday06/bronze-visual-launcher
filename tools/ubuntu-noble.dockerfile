# SPDX-License-Identifier: MIT OR GPL-3.0-or-later
#
# サーバーとして動作するわけではないのでHEALTHCHECKは不要
# checkov:skip=CKV_DOCKER_2: "Ensure that HEALTHCHECK instructions have been added to container images"

FROM ubuntu:noble

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN --mount=type=bind,source=.,target=/root/src/tools <<'INSTALL_PACKAGES'
  set -eu

  /root/src/tools/install_ubuntu_packages.sh

  # https://github.com/cli/cli/blob/v2.65.0/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
  curl --fail --show-error --location --output /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg
  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install "gh=*" -y --no-install-recommends

  # https://learn.microsoft.com/ja-jp/powershell/scripting/install/install-ubuntu?view=powershell-7.4
  curl --fail --show-error --location --output packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb
  dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install "powershell=*" -y --no-install-recommends

  apt-get dist-clean
  rm -rf /var/lib/apt/lists/*
INSTALL_PACKAGES

RUN <<'SETUP_USER'
  set -eu
  useradd --create-home --user-group --shell /bin/bash xyzzy
  echo "xyzzy ALL=(root) NOPASSWD:ALL" | tee /etc/sudoers.d/xyzzy
  mkdir -p /workspace
  chown xyzzy:xyzzy /workspace
SETUP_USER

USER xyzzy
WORKDIR /home/xyzzy

RUN <<'SETUP_USER_LOCAL_ENVIRONMENT'
  set -eu

  cat <<'SHELL_PROFILE_SCRIPT' >>~/.profile
export BLENDER_VRM_LOGGING_LEVEL_DEBUG=yes
export UV_LINK_MODE=copy
SHELL_PROFILE_SCRIPT

  # https://docs.astral.sh/uv/getting-started/installation/
  curl --fail --show-error --location https://astral.sh/uv/install.sh | sh

  # https://github.com/denoland/deno/issues/25931#issuecomment-2406073767
  curl --fail --show-error --location https://deno.land/install.sh | sh -s -- --yes
  # denoはシェルの設定の最終行に改行を追加しないので自前で追加する。
  echo | tee -a ~/.profile ~/.bashrc ~/.zshrc
SETUP_USER_LOCAL_ENVIRONMENT

COPY --chown=xyzzy:xyzzy --chmod=755 ./ubuntu-noble-entrypoint.sh /home/xyzzy/ubuntu-noble-entrypoint.sh
ENTRYPOINT ["/home/xyzzy/ubuntu-noble-entrypoint.sh"]

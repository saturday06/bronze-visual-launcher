#!/bin/bash
# SPDX-License-Identifier: MIT OR GPL-3.0-or-later

set -eux -o pipefail

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install \
  advancecomp \
  blender \
  curl \
  dbus \
  dotnet-sdk-8.0 \
  diffutils \
  ffmpeg \
  file \
  fvwm \
  git \
  git-lfs \
  gnupg \
  imagemagick \
  less \
  libsm6 \
  libxi6 \
  libxkbcommon0 \
  lxterminal \
  mesa-utils \
  moreutils \
  netcat-openbsd \
  nkf \
  patchutils \
  procps \
  python3-pygit2 \
  python3-numpy \
  python3-tqdm \
  python3-typing-extensions \
  recordmydesktop \
  ruby \
  shellcheck \
  shfmt \
  sudo \
  uchardet \
  unzip \
  x11-xserver-utils \
  x11vnc \
  xvfb \
  xz-utils \
  zopfli \
  -y --no-install-recommends

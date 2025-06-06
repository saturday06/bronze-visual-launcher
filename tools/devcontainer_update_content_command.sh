#!/bin/bash
# SPDX-License-Identifier: MIT OR GPL-3.0-or-later

set -eu -o pipefail

cd "$(dirname "$0")/.."

sudo chown -R "$(id -u):$(id -g)" .
sudo find . -type d -exec chmod 755 {} +
sudo find . -type f -exec chmod 644 {} +

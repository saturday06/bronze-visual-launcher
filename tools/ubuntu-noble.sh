#!/bin/sh
# SPDX-License-Identifier: MIT OR GPL-3.0-or-later

set -eux

cd "$(dirname "$0")"
source_path="$PWD"
dockerfile_path="$PWD/ubuntu-noble.dockerfile"

# 別のフォルダや別のシステムで作業中のdockerイメージと重複しないように
# それらをまとめたハッシュ値をdockerのタグ名としてビルドをする
pwd_and_system="$(pwd):$(uname --machine --operating-system)"
case "$(uname -s)" in
"Linux")
  pwd_and_system_hash=$(echo "$pwd_and_system" | md5sum | cut -d" " -f 1)
  ;;
"Darwin")
  pwd_and_system_hash=$(echo "$pwd_and_system" | md5)
  ;;
*)
  exit 0
  ;;
esac

tag_name="ubuntu-noble-local-tag-${pwd_and_system_hash}"
container_name="ubuntu-noble-local-container-${pwd_and_system_hash}"

mkdir -p "$HOME/visual-workspace/ubuntu-noble"
cd "$HOME/visual-workspace/ubuntu-noble"

if ! docker container inspect "$container_name"; then
  docker build --tag "$tag_name" --file "$dockerfile_path" "$source_path"
  docker run -d -it -v "$PWD:/workspace" --name "$container_name" "$tag_name" /bin/bash
fi

docker cp "$source_path/ubuntu-noble-entrypoint.sh" "$container_name:/home/xyzzy/ubuntu-noble-entrypoint.sh"
docker start -i "$container_name"

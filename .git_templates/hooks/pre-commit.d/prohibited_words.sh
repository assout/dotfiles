#!/bin/sh
# Refs: http://qiita.com/niku4i/items/f39eb7d4d5c4f5c0775c
# TODO: "===..."の誤検知
# TODO: 引っ掛かった場所の表示

# This prevents pushing prohibited words e.g in-house information to
# github.com by mistake.
#
# Usage:
#
# Add words you do not want to publish to the internet as follow,
#   $ echo "secretword" >> ~/.git_prohibited_words
#

check() {
  word=$*
  # Skip comment or blank lines
  echo "${word}" | grep ^# > /dev/null && return
  echo "${word}" | grep '^\s*$' > /dev/null && return

  git diff --cached -U0 | grep -i "$word" > /dev/null
  if [ $? -eq 0 ]; then
    echo "Can't commit because of including the prohibited word '$word'" >&2
    exit 1
  fi
}
here=$(cd "$(dirname "$0")" || exit 1; pwd)
while read word; do
  check "${word}"
done < "${here}/git_prohibited_words"

if [ -e ~/.git_prohibited_words ]; then
  while read word; do
    check "${word}"
  done < ~/.git_prohibited_words
fi

#!/bin/bash

readonly target_dir="${WORKSPACE:-.}/target"
mkdir -p "${target_dir}"

readonly result_file="${target_dir}"/result.csv
readonly MYBASHRC="${WORKSPACE:-${HOME}/dotfiles}/.bashrc"

echo "startuptime(seconds)" > "${result_file}"
(time source "${MYBASHRC}") 2>&1 | grep -o -P "(?<=real\t.m)\d\.\d\d\d(?=s)" >> "${result_file}"


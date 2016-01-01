#!/bin/bash

# Functions #

# Write Header.
# Globals(Used and modified):
#   HEADERS
#   result_file
#   filetype
# Arguments:
#   None
# Returns:
#   None
function add_header {
  for header in "${HEADERS[@]}" ; do
    echo -n "${filetype}(${header})," >> "${result_file}" # Jenkins Plot Pluginの都合で全ファイルタイプでユニークにしておいたほうがよい
  done
  sed -i -e 's/,$//' "${result_file}"
  echo "" >> "${result_file}"
}

# Write mesure
# Globals(Used and modified):
#   VIM_OPTIONS
#   filetype
#   result_file
# Arguments:
#   None
# Returns:
#   None
function mesure {
  for option in "${VIM_OPTIONS[@]}" ; do
    if [ "${filetype}" != 'boot' ] ; then
      local openfile=${SAMPLE_FILE_PREFIX}.${filetype}
    fi
    temp=$(mktemp)

    min=999999999
    for _ in $(seq 0 2) ; do
      # shellcheck disable=SC2086
      vim ${option} --startuptime ${temp} -e -c 'visual | quit' ${openfile}
      time="$(tail -1 "${temp}" | cut -d ' ' -f 1)"
      if [[ "${time}" < "${min}" ]] ; then
        min=${time}
      fi
    done
    echo -n "${min}," >> "${result_file}"
  done
  sed -i -e 's/,$//' "${result_file}"
  echo "" >> "${result_file}"
}

readonly target_dir="${WORKSPACE:-.}/target"
mkdir -p "${target_dir}"

readonly SAMPLE_FILE_PREFIX=sample
readonly MYVIMRC="${WORKSPACE:-~/dotfiles}/vim/.vimrc"
readonly FILE_TYPES=('boot' 'markdown' 'sh')

readonly HEADERS=('default' 'noplugin' 'none')
readonly VIM_OPTIONS=("-u ${MYVIMRC}" "-u ${MYVIMRC} --noplugin" "-u NONE")

for filetype in "${FILE_TYPES[@]}" ; do
  result_file="${target_dir}"/${filetype}.csv
  echo -n "" > "${result_file}"

  add_header
  mesure

  cat "${result_file}"
done


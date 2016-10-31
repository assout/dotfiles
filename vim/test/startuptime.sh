#!/bin/bash

# Functions #

# Write Header.
# Globals(Used and modified):
#   result_file
#   result_details_file
#   filetype
# Arguments:
#   None
# Returns:
#   None
function add_header {
  for header in 'default' 'noplugin' 'none' ; do # Jenkins Plot Pluginの都合で全ファイルタイプでユニークにしておいたほうがよい
    echo -n "${filetype}(${header})," >> "${result_file}"
  done

  for header in 'source_vimrc' 'other' ; do
    echo -n "${filetype}(${header})," >> "${result_details_file}"
  done

  sed -i -e 's/,$//' "${result_file}"
  sed -i -e 's/,$//' "${result_details_file}"
  echo "" >> "${result_file}"
  echo "" >> "${result_details_file}"
  echo "" >> "${result_raw_file}"
}

# Write mesure
# Globals(Used and modified):
#   filetype
#   result_file
# Arguments:
#   None
# Returns:
#   None
function mesure {
  readonly OPTIONS=("-u ${MYVIMRC}" "-u ${MYVIMRC} --noplugin" "-u NONE")
  for option in "${OPTIONS[@]}" ; do
    if [ "${filetype}" != 'boot' ] ; then
      local openfile=${SAMPLE_FILE_PREFIX}.${filetype}
    fi
    echo ${option} >> ${result_raw_file}
    # shellcheck disable=SC2086
    vim ${option} --startuptime ${result_raw_file} -e -c 'quit' ${openfile}
    time="$(tail -1 "${result_raw_file}" | cut -d ' ' -f 1)"
    echo -n "${time}," >> "${result_file}"

    if [ "${option}" == "${OPTIONS[0]}" ] ; then
      vimrc_time="$(grep "sourcing.*vimrc$" "${result_raw_file}" | cut -d ' ' -f 3)"
      echo -n "${vimrc_time}," >> "${result_details_file}"

      other_time=$(echo "${time}" - "${vimrc_time}" | bc)
      echo -n "${other_time}," >> "${result_details_file}"
    fi
  done

  sed -i -e 's/,$//' "${result_file}"
  sed -i -e 's/,$//' "${result_details_file}"
  echo "" >> "${result_file}"
  echo "" >> "${result_details_file}"
  echo "" >> "${result_raw_file}"
}

readonly here=$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)
readonly target_dir="${WORKSPACE:-.}/target"
mkdir -p "${target_dir}"

readonly SAMPLE_FILE_PREFIX=sample
readonly MYVIMRC="${WORKSPACE:-${here}/../..}/vim/.vimrc"
readonly FILE_TYPES=('boot' 'markdown' 'sh')

for filetype in "${FILE_TYPES[@]}" ; do
  result_file="${target_dir}"/${filetype}.csv
  result_details_file="${target_dir}"/${filetype}_details.csv
  result_raw_file="${target_dir}"/${filetype}_raw.log
  echo -n "" > "${result_file}"
  echo -n "" > "${result_details_file}"
  echo -n "" > "${result_raw_file}"

  add_header
  mesure

  cat "${result_file}"
  cat "${result_details_file}"
  echo ""
done


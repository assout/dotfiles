#!/bin/bash

readonly target_dir="${WORKSPACE:-.}/target"
mkdir -p "${target_dir}"
result_file=${target_dir}/result_source.csv

readonly MYVIMRC="${WORKSPACE:-~/dotfiles}/vim/.vimrc"

temp_raw=$(mktemp)
vim -u "${MYVIMRC}" -e -c "BenchVimrc ${MYVIMRC} ${temp_raw} | qa!"

temp_sorted=$(mktemp)
sed -e '/^        .*/d' "${temp_raw}" | sort -r > "${temp_sorted}"

cat "${temp_sorted}"

temp_filterd=$(mktemp)
head -10 "${temp_sorted}" > "${temp_filterd}"

temp_time=$(mktemp)
temp_proc=$(mktemp)

cut "${temp_filterd}" -c 3-11 > "${temp_time}"
cut "${temp_filterd}" -c 19- | sed -e 's/,/、/g' > "${temp_proc}"

echo "${temp_time}"

echo "${temp_proc}"

echo "1, 2, 3, 4, 5, 6, 7, 8, 9, 10" > "${result_file}"
paste -d ',' -s "${temp_time}" >> "${result_file}"

# paste -d ',' -s "${temp_proc}" "${temp_time}" > "${result_file}"

# echo "time, proc" > "${result_file}"
# paste -d ',' "${temp_time}" "${temp_proc}" >> "${result_file}"

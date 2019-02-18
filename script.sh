#!/bin/bash
FROM=$1
TO=$2
FROM_SNAKE_CASE=$(echo $1 | gsed -r 's/([A-Z])/_\L\1/g' | gsed 's/^_//')
TO_SNAKE_CASE=$(echo $2 | gsed -r 's/([A-Z])/_\L\1/g' | gsed 's/^_//')

rails g migration rename_${FROM_SNAKE_CASE}_to_${TO_SNAKE_CASE} \
  | awk '{print $2; }' \
  | tail -n 1 \
  | xargs gsed "3i\\ \ \ \ rename_table :${FROM_SNAKE_CASE}s, :${TO_SNAKE_CASE}" \
  | rails db:migrate

rg ${FROM} --files-with-matches | xargs gsed -i `s/${FROM}/${TO}/g`
rg ${FROM_SNAKE_CASE} --files-with-matches | xargs gsed -i `s/${FROM_SNAKE_CASE}/${TO_SNAKE_CASE}/g`

find . -name `*${FROM_SNAKE_CASE}*` -exec bash -c `mv $0 ${0/${FROM_SNAKE_CASE}/${TO_SNAKE_CASE}}` {} \;

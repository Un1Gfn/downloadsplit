#!/bin/bash
# This script does not run on CI
# This script collects splited artifacts from CI

# https://stackoverflow.com/a/12298757/8243991
# https://stackoverflow.com/a/5920355/8243991

URIPREFIX="https://18-220739498-gh.circle-artifacts.com/0/split/"
SEGMENTS=(xa{a..d})
SZ0=$((1024*1024*1024))
SZ0_TXT="1GiB"

function wget_with_timestamp {
  printf "\e[7m %s \e[0m\n" "$(date)"
  wget "$1"
  printf "\e[7m %s \e[0m\n" "$(date)"
}

[ -e sha1sum.txt ] || wget_with_timestamp "${URIPREFIX}sha1sum.txt"

for i in "${SEGMENTS[@]}"; do
  echo
  if [ ! -e "$i" ]; then
    wget_with_timestamp "${URIPREFIX}${i}"
  else
    SZ=$(wc -c <"$i")
    if [ "$SZ" -eq "$SZ0" ]; then
      echo "$i is $SZ0_TXT"
    else
      if [ "$i" = "${SEGMENTS[-1]}" ]; then
        echo "$i is the last segment"
      else
        echo "$i is $(numfmt --to=iec-i "$SZ") ($SZ bytes)"
        read -r -e -p "Delete $i and download again? [yn] " -r YN
        if [ "$YN" = y ]; then
          rm -v "$i"
          wget_with_timestamp "${URIPREFIX}${i}"
        fi
      fi
    fi
  fi
done

echo

sha1sum -c sha1sum.txt

echo

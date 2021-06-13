#!/bin/bash
# This script does not run on CI
# This script collects splited artifacts from CI

# https://stackoverflow.com/a/12298757/8243991
# https://stackoverflow.com/a/5920355/8243991

URIPREFIX="https://8-220739498-gh.circle-artifacts.com/0/split/"
SEGMENTS=(x{a{a..z},ba})

# for i in "${SEGMENTS[@]}"; do
#   echo "$i"
# done

function trapf {
  echo
  echo SIGINT
  echo
  exit 1
}
 
trap trapf SIGINT

echo
ls -l

for i in "${SEGMENTS[@]}"; do
  echo
  if [ ! -e "$i" ]; then
    echo -e "\033[7m $(date) \033[0m";wget "${URIPREFIX}${i}";echo -e "\033[7m $(date) \033[0m"
  else
    SZ=$(wc -c <"$i")
    if [ "$SZ" -eq $((1024*1024*1024)) ]; then
      echo "$i is 1GiB"
    else
      if [ "$i" == "${SEGMENTS[-1]}" ]; then
        echo "$i is the last segment"
      else
        echo "$i is $(numfmt --to=iec-i "$SZ") ($SZ bytes)"
        # echo -n "Delete $i and download again?..."
        # read -r
        read -e -p "Delete $i and download again? [yn] " -r YN
        if [ "$YN" == y ]; then
          rm -v "$i"
          echo -e "\033[7m $(date) \033[0m";wget "${URIPREFIX}${i}";echo -e "\033[7m $(date) \033[0m"
        fi
      fi
    fi
  fi
done

echo

# md5sum -c md5.txt.onespace
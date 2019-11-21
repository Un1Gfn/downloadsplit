#!/bin/bash

# https://stackoverflow.com/a/12298757/8243991
# https://stackoverflow.com/a/5920355/8243991

URIPREFIX="https://8-220739498-gh.circle-artifacts.com/0/split/"
SEGMENTS=(md5.txt x{a{a..z},ba})

# for i in "${SEGMENTS[@]}"; do
#   echo "$i"
# done

function trapf {
  echo
  echo SIGINT
  exit 1
}
 
trap trapf SIGINT

ls -l

for i in "${SEGMENTS[@]}"; do
  if [ ! -e "$i" ]; then
    echo -e "\033[7m $(date) \033[0m";proxychains wget "${URIPREFIX}${i}";echo -e "\033[7m $(date) \033[0m"
  else
    SZ=$(wc -c <"$i")
    if [ "$SZ" -eq $((1024*1024*1024)) ]; then
      echo "$i is 1GiB"
    else
      if [ "$i" == "${SEGMENTS[-1]}" ]; then
        echo "$i is the last segment"
      else
        echo "$i is $(numfmt --to=iec-i "$SZ") ($SZ bytes)"
        echo -n "Delete $i and download again?..."
        read -r
        rm -v "$i"
        echo -e "\033[7m $(date) \033[0m";proxychains wget "${URIPREFIX}${i}";echo -e "\033[7m $(date) \033[0m"
      fi
    fi
  fi
done
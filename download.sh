#!/bin/bash

# https://stackoverflow.com/a/12298757/8243991
# https://stackoverflow.com/a/5920355/8243991

exit 1

URIPREFIX="https://lsdjfskdf.xcvx.iwmjefms/"
# SEGMENTS=$(echo x{a..z}{a..z})
SEGMENTS=(x{a..b}{1..2})

function trapf {
  echo
  echo SIGINT
  exit 1
}
 
trap trapf SIGINT

ls -l

for i in "${SEGMENTS[@]}"; do
  if [ ! -e "$i" ]; then
    proxychains wget "${URIPREFIX}${i}"
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
        proxychains wget "${URIPREFIX}${i}"
      fi
    fi
  fi
done
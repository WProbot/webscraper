#!/bin/bash

  for (( ; ; ))
  do
    test -f exit.flag && exit
    ./html.sh
    sleep $((1 + $RANDOM % 6))s
  done
#! /bin/bash

CONTIKI=$1
TARGET=$2

DIR=$(pwd)/$TARGET
PREPARE=$DIR/prepare_framac.c

cat $DIR/framac.c $CONTIKI/prepare_memory.c $CONTIKI/jnimain.c > $PREPARE

IO_LOCK_B=$(grep -n "typedef void _IO_lock" $PREPARE | cut -d: -f1)
IO_LOCK_E=$(( $IO_LOCK_B + 31 ))
sed -i -e "$IO_LOCK_B,$IO_LOCK_E{s/^/\/\//g}" $PREPARE

sed -i -e 's/\(void __gen_e_acsl___builtin_va.*;\)/\/\/ \1/'      $PREPARE
sed -i -e 's/\(__e_acsl_.*__gen_e_acsl___builtin_va.*\)/\/\/ \1/' $PREPARE
sed -i -e 's/\(^ *\)__gen_e_acsl_\(__builtin_va.*;\)/\1\2/'       $PREPARE
sed -i -e 's/\(^ *__builtin_va_start(ap\)/\1, fmt/'            $PREPARE

for i in $(cat $PREPARE | grep -n "void __gen_e_acsl___builtin_va.*) *$" | cut -d: -f1) ; do
  END=$(( $i + 6 ))
  sed -i -e "$i,$END{s/^/\/\//g}" $PREPARE
done
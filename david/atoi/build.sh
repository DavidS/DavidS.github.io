#! /bin/sh

CC=gcc
NOOPT=-O0
OPT="-O2 -funroll-loops"

unset DEBIAN_BUILDARCH
$CC $NOOPT -DOPTIM=0 -o null_nop_0 null.c
$CC $NOOPT -DOPTIM=1 -o null_nop_1 null.c
$CC $NOOPT -DOPTIM=0 -o test_nop_0 test.c
$CC $NOOPT -DOPTIM=1 -o test_nop_1 test.c
$CC $OPT -DOPTIM=0 -o null_opt_0 null.c
$CC $OPT -DOPTIM=1 -o null_opt_1 null.c
$CC $OPT -DOPTIM=0 -o test_opt_0 test.c
$CC $OPT -DOPTIM=1 -o test_opt_1 test.c


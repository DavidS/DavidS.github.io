#! /bin/sh

set -e 

PATH=".:$PATH"
BINS="lib_optim optim_optim lib_normal optim_normal"

cat test.in > /dev/null
for j in 1 2; do
for i in $BINS; do
for k in 1 2 3; do
	/usr/bin/time -f "$i,%e,%U,%S" $i < test.in 2>&1
done
done
done

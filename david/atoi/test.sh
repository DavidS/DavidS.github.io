#! /bin/sh

/usr/bin/time -f 'null_nop_0,%U,%M' ./null_nop_0 < test.in
/usr/bin/time -f 'null_nop_1,%U,%M' ./null_nop_1 < test.in
/usr/bin/time -f 'test_nop_0,%U,%M' ./test_nop_0 < test.in
/usr/bin/time -f 'test_nop_1,%U,%M' ./test_nop_1 < test.in
/usr/bin/time -f 'null_opt_0,%U,%M' ./null_opt_0 < test.in
/usr/bin/time -f 'null_opt_1,%U,%M' ./null_opt_1 < test.in
/usr/bin/time -f 'test_opt_0,%U,%M' ./test_opt_0 < test.in
/usr/bin/time -f 'test_opt_1,%U,%M' ./test_opt_1 < test.in




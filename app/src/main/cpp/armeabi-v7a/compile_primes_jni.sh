clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_locks.nim.c.o stdlib_locks.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_sharedlist.nim.c.o stdlib_sharedlist.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_io.nim.c.o stdlib_io.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_system.nim.c.o stdlib_system.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_times.nim.c.o stdlib_times.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_os.nim.c.o stdlib_os.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o @mjni_wrapper.nim.c.o @mjni_wrapper.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o stdlib_sugar.nim.c.o stdlib_sugar.nim.c
clang -c  -w -pthread -O3  -ID:\AndroidStudioProjects\SieveofEratosthenesBenchmark\app\src\main\nim -o @mprimes_jni.nim.c.o @mprimes_jni.nim.c
clang.exe   -o primes_jni  stdlib_locks.nim.c.o stdlib_sharedlist.nim.c.o stdlib_io.nim.c.o stdlib_system.nim.c.o stdlib_times.nim.c.o stdlib_os.nim.c.o @mjni_wrapper.nim.c.o stdlib_sugar.nim.c.o @mprimes_jni.nim.c.o  -pthread -lm   -ldl

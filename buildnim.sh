# I'm not sure this is correct and don't have a Bash shell to check it...

# the androidNDK define as used below turns on the ability so that echo text is
# output to the Android Logcat logging facilities, which could be handy in assisting debugging...

# remove all the results of older bulid's...
rm -f -d -r app/src/main/cpp/armeabi-v7a
rm -f -d -r app/src/main/cpp/arm64-v8a
rm -f -d -r app/src/main/cpp/x86
rm -f -d -r app/src/main/cpp/x86_64

# compile for each of the ANDROID_ABI's...
nim c --genScript:on -d:noSignalHandler -d:danger -d:release -d:androidNDK \
--cpu:arm --os:android --noMain:on --threads:on \
--nimcache:app/src/main/cpp/armeabi-v7a app/src/main/nim/primes_jni
nim c --genScript:on -d:noSignalHandler -d:danger -d:release -d:androidNDK \
--cpu:arm64 --os:android --noMain:on --threads:on \
--nimcache:app/src/main/cpp/arm64-v8a app/src/main/nim/primes_jni
nim c --genScript:on -d:noSignalHandler -d:danger -d:release -d:androidNDK \
--cpu:i386 --os:android --noMain:on --threads:on \
--nimcache:app/src/main/cpp/x86 app/src/main/nim/primes_jni
nim c --genScript:on -d:noSignalHandler -d:danger -d:release -d:androidNDK \
--cpu:amd64 --os:android --noMain:on --threads:on \
--nimcache:app/src/main/cpp/x86_64 app/src/main/nim/primes_jni

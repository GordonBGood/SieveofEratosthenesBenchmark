#
#
#     example of native Nim code callable through JNI...
#
#    (c) Copyright 2020 W. Gordon Goodsman (GordonBGood)
#
#    See the file "copying.txt", included at the root of
#    this distribution, for details about the copyright.
#

# translation of the Android sample C file from:  https://github.com/android/ndk-samples/blob/master/hello-jniCallback/app/src/main/cpp/hello-jnicallback.c

# The following have been opied from jnim via the jni_wrapper import file:
# Specifically, from: https://github.com/yglukhov/jnim/blob/ec889fd4f58a8f587b53ee3b726de8189cc59769/src/private/jni_wrapper.nim
# type
#   jobject_base {.inheritable, pure.} = object
#   jobject* = ptr jobject_base
#   JClass* = ptr object of jobject
#   jstring* = ptr object of jobject
#   JNIEnv* = ptr JNINativeInterface
#   JNIEnvPtr* = ptr JNIEnv
#   JavaVM* = ptr JNIInvokeInterface
#   JavaVMPtr* = ptr JavaVM
import jni_wrapper

from times import epochTime
from math import ceil
from os import sleep

# Android log function wrappers
const ANDROID_LOG_INFO = 4.cint
const ANDROID_LOG_WARN = 5.cint
const ANDROID_LOG_ERROR = 6.cint
proc android_log_print(prio: cint; tag: cstring; fmt: cstring): cint
  {.importc: "__android_log_print", header: "<android/log.h>", varargs, discardable.}

const kTAG = "nim-hello-jniCallback".cstring
template LOGI(args: varargs[untyped]) =
  android_log_print(ANDROID_LOG_INFO, kTAG, args)
template LOGW(args: varargs[untyped]) =
  android_log_print(ANDROID_LOG_WARN, kTAG, args)
template LOGE(args: varargs[untyped]) =
  android_log_print(ANDROID_LOG_ERROR, kTAG, args)

## processing callback to handler class
type
  TickContext = object
    javaVM: JavaVMPtr
    jniHelperClz: JClass
    jniHelperObj: jobject
    mainActivityClz: JClass
    mainActivityObj: jobject
    thrd: Thread[ptr TickContext]
    done: int
var g_ctx: TickContext

## This is a trivial JNI example where we use a native method to return a new VM String...
# changed the package name to reflect the Nim version...
proc Java_com_example_nimhellojnicallback_MainActivity_stringFromJNI*(env: JNIEnvPtr, thiz: jobject): jstring {.cdecl,exportc,dynlib.} =
  when defined(i386):
    let ABI = "x86"
  elif defined(amd64):
    let ABI = "x86_64"
  elif defined(arm):
    let ABI = "armeabi-v7a"
  elif defined(arm64):
    let ABI = "arm64-v8a"
  else:
    let ABI = "unknown"
  return env.NewStringUTF(env, "Hello from Nim native JNI! compiled for " & ABI & " .")

## a template to produce the source line number at the point it's called...
template SRCLNNUM(): jint = instantiationInfo().line.jint

##  A helper function to show how to call
##    java static functions JniHelper::getBuildVersion()
##    java non-static function JniHelper::getRuntimeMemorySize()
##  The trivial implementation for these functions are inside file
##    JniHelper.java
proc queryRuntimeInfo(envp: JNIEnvPtr; instance: jobject) =
  # Find out which OS we are running on. It does not matter for this app
  # just to demo how to call static functions.
  # Our java JniHelper class id and instance are initialized when this
  # shared lib got loaded, we just directly use them
  #    static function does not need instance, so we just need to feed
  #    class and method id to JNI
  let versionFunc = envp.GetStaticMethodID(envp, g_ctx.jniHelperClz,
                                           "getBuildVersion", "()Ljava/lang/String;")
  if versionFunc == nil:
    LOGE("Failed to retrieve getBuildVersion() methodID @ line %d", SRCLNNUM())
    return
  let buildVersion = envp.CallStaticObjectMethod(envp, g_ctx.jniHelperClz, versionFunc).jstring
  let version = envp.GetStringUTFChars(envp, buildVersion, cast[ptr jboolean](nil))
  if version == nil:
    LOGE("Unable to get version string @ line %d", SRCLNNUM())
    return
  LOGI("Android Version - %s", version)
  envp.ReleaseStringUTFChars(envp, buildVersion, version)

  # we are called from JNI_OnLoad, so got to release LocalRef to avoid leaking
  envp.DeleteLocalRef(envp, buildVersion)
  # Query available memory size from a non-static public function
  # we need use an instance of JniHelper class to call JNI
  let memFunc = envp.GetMethodID(envp, g_ctx.jniHelperClz, "getRuntimeMemorySize", "()J")
  if memFunc == nil:
    LOGE("Failed to retrieve getRuntimeMemorySize() methodID @ line %d", SRCLNNUM())
    return
  let result = envp.CallLongMethod(envp, instance, memFunc)
  LOGI("Runtime free memory size: %s", $result)

proc NimMain() {.importc.} # needed to initialize the GC, memory, and stack, etc.

## Automaticalled called just after the library is loaded...
##
## processing one time initialization:
##     Cache the javaVM into our context
##     Find class ID for JniHelper
##     Create an instance of JniHelper
##     Make global reference since we are using them from a native thread
## Note:
##     All resources allocated here are never released by application
##     we rely on system to free all global refs when it goes away;
##     the pairing function JNI_OnUnload() never gets called at all.
proc JNI_OnLoad*(vmp: JavaVMPtr; reserved: pointer): jint {.cdecl,exportc,dynlib.} =
  NimMain() # won't hurt even when not needed for non-GC memory management!
#  echo "Testing the answer to life:  ", 42, " !"
#  LOGI(r"Testing number of threads:  %d !", countProcessors())
  var envp: JNIEnvPtr
  g_ctx = TickContext() # zero's it!
  g_ctx.javaVM = vmp
  if vmp.GetEnv(vmp, cast[ptr pointer](envp.addr), JNI_VERSION_1_6) != JNI_OK:
    return JNI_ERR # JNI version not supported.

  let clz = envp.FindClass(envp, "com/example/nimhellojnicallback/JniHandler")
  g_ctx.jniHelperClz = cast[JClass](envp.NewGlobalRef(envp, clz))

  let jniHelperCtor = envp.GetMethodID(envp, g_ctx.jniHelperClz, "<init>", "()V")
  let handler = envp.NewObject(envp, g_ctx.jniHelperClz, jniHelperCtor)
  g_ctx.jniHelperObj = envp.NewGlobalRef(envp, handler)
  queryRuntimeInfo(envp, g_ctx.jniHelperObj)

  g_ctx.done = 0
  g_ctx.mainActivityObj = nil
  return JNI_VERSION_1_6

##
## A helper function to wrap java JniHelper::updateStatus(String msg)
## JNI allow us to call this function via an instance even it is
## private function.
##
proc sendJavaMsg(envp: JNIEnvPtr; instance: jobject; fnc: jmethodID; msg: cstring) =
  let javaMsg = envp.NewStringUTF(envp, msg)
  envp.CallVoidMethod(envp, instance, fnc, javaMsg)
  envp.DeleteLocalRef(envp, javaMsg)

##
## Main working thread function. From a pthread,
##     calling back to MainActivity::updateTimer() to display ticks on UI
##     calling back to JniHelper::updateStatus(String msg) for msg
##
proc updateTicks(pctx: ptr TickContext) {.thread, nimcall.} =
  {.gcsafe.}:
    let javaVM = pctx.javaVM
    var envp: JNIEnvPtr
    var res = javaVM.GetEnv(javaVM, cast[ptr pointer](envp.addr), JNI_VERSION_1_6)
    if res != JNI_OK:
      res = javaVM.AttachCurrentThread(javaVM, cast[ptr pointer](envp.addr), nil)
      if res != JNI_OK:
        LOGE("Failed to AttachCurrentThread, ErrorCode = %d", res)
        return

    let statusId = envp.GetMethodID(envp, pctx.jniHelperClz, "updateStatus", "(Ljava/lang/String;)V")
    sendJavaMsg(envp, pctx.jniHelperObj, statusId, "TickerThread status: initializing...")

    # get mainActivity updateTimer function
    let timerId = envp.GetMethodID(envp, pctx.mainActivityClz, "updateTimer", "()V")
    sendJavaMsg(envp, pctx.jniHelperObj, statusId, "TickerThread status: start ticking ...")

    var nextTime = epochTime() + 1
    while true:
      if pctx.done != 0: break
#      if cas(pctx.done.addr, 1, 0): break
      envp.CallVoidMethod(envp, pctx.mainActivityObj, timerId)

      let leftTime = nextTime - epochTime(); nextTime += 1
      if leftTime >= 0: sleep (lefttime * 1000).ceil.int
      else:
        sendJavaMsg(envp, pctx.jniHelperObj, statusId, "TickerThread error: processing too long!")
        break

    sendJavaMsg(envp, pctx.jniHelperObj, statusId, "TickerThread status: ticking stopped")
    discard javaVM.DetachCurrentThread(javaVM)

##
## Interface to Java side to start ticks, caller is from onResume()
##
# changed the package name to reflect the Nim version...
proc Java_com_example_nimhellojnicallback_MainActivity_startTicks(envp: JNIEnvPtr; instance: jobject) {.cdecl,exportc,dynlib.} =
  let clz = envp.GetObjectClass(envp, instance)
  g_ctx.mainActivityClz = cast[JClass](envp.NewGlobalRef(envp, clz))
  g_ctx.mainActivityObj = envp.NewGlobalRef(envp, instance)

  g_ctx.done = 0 # ensure that flag is cleared from previous runs!
  createThread(g_ctx.thrd, updateTicks, g_ctx.addr)
  doAssert g_ctx.thrd.running

##
## Interface to Java side to stop ticks:
##    we need to hold and make sure our native thread has finished before return
##    for a clean shutdown. The caller is from onPause
##
# changed the package name to reflect the Nim version...
proc Java_com_example_nimhellojnicallback_MainActivity_StopTicks(envp: JNIEnvPtr; instance: jobject) {.cdecl,exportc,dynlib.} =
  g_ctx.done = 1 # this is the only place that ever changes it while thread is running!

  # waiting for ticking thread to flip the done flag back to zero...
#  while g_ctx.done == 1: sleep 100
  
  # Nim threads are not PTHREAD_CREATE_DETACHED but default PTHREAD_CREATE_JOINABLE
  g_ctx.thrd.joinThread # they should should be joined with no need for the above flim flammery!

  # release object we allocated from StartTicks() function
  envp.DeleteGlobalRef(envp, g_ctx.mainActivityClz)
  envp.DeleteGlobalRef(envp, g_ctx.mainActivityObj)
  g_ctx.mainActivityClz = nil; g_ctx.mainActivityObj = nil # mark deleted ref's as cleared!


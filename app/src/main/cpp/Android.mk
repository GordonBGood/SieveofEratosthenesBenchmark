LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := primes-jni
LOCAL_SRC_FILES := $(wildcard $(LOCAL_PATH)/$(TARGET_ARCH_ABI)/*.c)

LOCAL_LDLIBS := -landroid -llog
include $(BUILD_SHARED_LIBRARY)

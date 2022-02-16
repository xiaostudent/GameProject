LOCAL_PATH := $(call my-dir)

#include $(CLEAR_VARS)
#LOCAL_PREBUILT_LIBS :=libMyGame:libs/armeabi-v7a/libMyGame.so  
#LOCAL_MODULE_TAGS := eng  
#include $(BUILD_MULTI_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libGCloudVoice
LOCAL_SRC_FILES := ../libs/armeabi-v7a/libMyGame.so  
include $(PREBUILT_SHARED_LIBRARY)


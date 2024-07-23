#
# GNUmakefile
#
# Copyright (C) 2023 McLaren Labs

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = \
  SampleToy

COMMON_OBJC_FILES = \
  NSObject+MLBlocks.m \
  MLInputView.m \
  MLExpressiveButton.m \
  MLPiano.m \
  LabelWithValue.m \
  NSColor+ColorExtensions.m \
  MLSampleView.m 

SampleToy_OBJC_FILES = \
  $(COMMON_OBJC_FILES) \
  SampleToy_main.m \
  SampleToy_AppDelegate.m

SampleToy_RESOURCE_FILES = \
  Resources/Info-gnustep.plist

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc
ADDITIONAL_LDFLAGS = -ldispatch -lStepTalk

ifeq ($(localdev),yes)
ADDITIONAL_CPPFLAGS += -I../../../Libraries/
ADDITIONAL_LIB_DIRS += -L ../../../Libraries/McLarenSynthKit/obj -L../../../Libraries/AlsaSoundKit/obj  
ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../../Libraries/McLarenSynthKit/obj' -l:libMcLarenSynthKit.so -Wl,-rpath='$$ORIGIN/../../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so
else
ADDITIONAL_LDFLAGS += -lMcLarenSynthKit -lAlsaSoundKit
endif

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUMakefile.postamble

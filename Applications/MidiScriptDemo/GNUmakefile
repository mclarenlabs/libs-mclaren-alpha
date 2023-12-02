#
# GNUmakefile
#
# Copyright (C) 2023 McLaren Labs

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = \
  MidiScriptDemo

COMMON_OBJC_FILES = \
  MLGauge.m \
  MLInputView.m \
  MLExpressiveButton.m \
  MLPad.m \
  MLPiano.m \
  LabelWithValue.m \
  NSColor+ColorExtensions.m \
  NSObject+additions.m \
  ToneGenerator.m  \
  ASKSeqEvent+additions.m \
  ASKSeqDispatcher.m \
  NSErrorPtr.m

MidiScriptDemo_OBJC_FILES = \
  $(COMMON_OBJC_FILES) \
  STScriptingSupport.m \
  MidiScriptDemo_main.m \
  MidiScriptDemo_AppDelegate.m

MidiScriptDemo_RESOURCE_FILES = ScriptingInfo.plist Scripts

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc
ADDITIONAL_LDFLAGS = -ldispatch -lStepTalk

ifeq ($(localdev),yes)
ADDITIONAL_CPPFLAGS += -I../../Libraries/
ADDITIONAL_LIB_DIRS += -L../../Libraries/AlsaSoundKit/obj  
ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so
endif

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUMakefile.postamble

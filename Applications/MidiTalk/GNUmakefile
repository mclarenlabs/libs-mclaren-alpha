#
# GNUmakefile
#
# Copyright (C) 2024 McLaren Labs

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = \
  MidiTalk

COMMON_OBJC_FILES = \
  apply.m \
  MLInputView.m \
  MLExpressiveButton.m \
  MLGauge.m \
  MLPiano.m \
  MLPianoController.m \
  MLButtonsController.m \
  MLGaugesController.m \
  MLContextController.m \
  MLFilterController.m \
  MLReverbController.m \
  MLVUMeterView.m \
  MLActivity.m \
  MLLamp.m \
  LabelWithValue.m \
  NSScrollSlider.m \
  NSColor+ColorExtensions.m \
  NSObject+additions.m \
  ASKSeqEvent+additions.m \
  ASKSeqDispatcher.m \
  Pattern.m \
  NSErrorPtr.m \
  MSKSample+additions.m

SYNTH80 = ../McLarenSynthKit/Synth80

ADDITIONAL_CPPFLAGS += -I$(SYNTH80)

SYNTH80_OBJC_Files = \
  Synth80Synth.m \
  Synth80PatchManager.m \
  $(SYNTH80)/Synth80AlgorithmModel.m \
  $(SYNTH80)/Synth80AlgorithmEngine.m \
  $(SYNTH80)/Synth80Model.m

MidiTalk_OBJC_FILES = \
  $(COMMON_OBJC_FILES) \
  $(SYNTH80_OBJC_Files) \
  STScriptingSupport.m \
  MidiTalk_ASKSeq.m \
  MidiTalk_main.m \
  MidiTalk_AppDelegate.m

MidiTalk_RESOURCE_FILES = \
  Resources/Info-gnustep.plist \
  ScriptingInfo.plist \
  Scripts

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc
ADDITIONAL_LDFLAGS = -ldispatch -lStepTalk

ifeq ($(localdev),yes)
ADDITIONAL_CPPFLAGS += -I../../Libraries/
ADDITIONAL_LIB_DIRS += -L../../Libraries/AlsaSoundKit/obj  
ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so

ADDITIONAL_LIB_DIRS += -L../../Libraries/McLarenSynthKit/obj  
ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../Libraries/McLarenSynthKit/obj' -l:libMcLarenSynthKit.so
else
ADDITIONAL_LDFLAGS += -lAlsaSoundKit -lMcLarenSynthKit
endif

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUMakefile.postamble

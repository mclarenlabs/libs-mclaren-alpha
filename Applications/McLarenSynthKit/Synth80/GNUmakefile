#
# GNUmakefile
#
# Copyright (C) 2023 McLaren Labs

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = \
  Synth80

COMMON_OBJC_FILES = 

Synth80_OBJC_FILES = \
  Synth80_main.m \
  NSScrollSlider.m \
  LabelWithValue.m \
  MLInputView.m \
  MLCircularSliderWithValue.m \
  MLVerticalSliderWithValue.m \
  MLStepperWithValue.m \
  MLOscillatorController.m \
  MLEnvelopeController.m \
  MLDrawbarController.m \
  MLModulationController.m \
  MLFilterController.m \
  MLReverbController.m \
  MLPianoController.m \
  MLPiano.m \
  MLSampleController.m \
  MLExpressiveButton.m \
  MLSampleView.m \
  MLContextBufferView.m \
  NSColor+ColorExtensions.m \
  NSObject+MLBlocks.m \
  Synth80Model.m \
  Synth80WindowController.m \
  Synth80Document.m \
  Synth80AlgorithmModel.m \
  Synth80AlgorithmEngine.m \
  Synth80AlgorithmController.m \
  Synth80AppDelegate.m

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc
ADDITIONAL_LDFLAGS = -ldispatch

# Run makefiles with "localdev=yes" to add addl flags that find
# libraries in this package rather than in global installed locations

ifeq ($(localdev),yes)
ADDITIONAL_CPPFLAGS += -I../../../Libraries/
ADDITIONAL_LIB_DIRS += -L ../../../Libraries/McLarenSynthKit/obj -L../../../Libraries/AlsaSoundKit/obj  
ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../../Libraries/McLarenSynthKit/obj' -l:libMcLarenSynthKit.so -Wl,-rpath='$$ORIGIN/../../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so
else
ADDITIONAL_LDFLAGS += -lAlsaSoundKit -lMcLarenSynthKit
endif

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUMakefile.postamble

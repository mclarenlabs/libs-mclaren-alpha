#
#  GNUmakefile
#
#  Copyright (C) 2023 McLaren Labs
#

include $(GNUSTEP_MAKEFILES)/common.make

# include ../../Version # TOM: this is very clever

LIBRARY_NAME = McLarenSynthKit

McLarenSynthKit_OBJC_FILES = \
  MSKError.m \
  MSKMetronome.m \
  MSKContext.m \
  model/MSKEnvelopeModel.m \
  env/MSKEnvelopeFanout.m \
  model/MSKOscillatorModel.m \
  model/MSKModulationModel.m \
  model/MSKDrawbarModel.m \
  model/MSKSampleModel.m \
  voice/MSKSinFixedOscillator.m \
  voice/MSKDrawbarOscillator.m \
  voice/MSKFMPhaseEnvelopeOscillator.m \
  model/MSKFilterModel.m \
  model/MSKReverbModel.m \
  fifo/MSKOFifo.m \
  sample/MSKSample.m \
  sample/MSKSampleManager.m \
  sample/MSKSamplePlayer.m \
  sample/MSKSampleRecorder.m \
  MSKPattern.m

McLarenSynthKit_OBJCC_FILES = \
  voice/MSKGeneralOscillator.mm \
  voice/MSKPhaseDistortionOscillator.mm\
  env/MSKLinEnvelope.mm \
  env/MSKExpEnvelope.mm \
  filt/MSKGeneralFilter.mm \
  fx/MSKFreeverbReverb.mm

McLarenSynthKit_CC_FILES = \
  filt/Biquad.cpp

#  MSKMetronome.h \
#  model/MSKValuesModel.h \

McLarenSynthKit_HEADER_FILES = \
  MSKError.h \
  MSKMetronome.h \
  MSKContext.h \
  model/MSKEnvelopeModel.h \
  env/MSKLinEnvelope.h \
  env/MSKExpEnvelope.h \
  env/MSKEnvelopeFanout.h \
  model/MSKOscillatorModel.h \
  model/MSKModulationModel.h \
  model/MSKDrawbarModel.h \
  voice/MSKSinFixedOscillator.h \
  voice/MSKGeneralOscillator.h \
  voice/MSKDrawbarOscillator.h \
  voice/MSKPhaseDistortionOscillator.h \
  voice/MSKFMPhaseEnvelopeOscillator.h \
  filt/MSKGeneralFilter.h \
  model/MSKFilterModel.h \
  model/MSKReverbModel.h \
  fx/MSKFreeverbReverb.h \
  fifo/MSKOFifo.h \
  sample/MSKSample.h \
  sample/MSKSampleManager.h \
  sample/MSKSamplePlayer.h \
  sample/MSKSampleRecorder.h \
  MSKPattern.h

McLarenSynthKit_HEADER_FILES += McLarenSynthKit.h



ADDITIONAL_CPPFLAGS += -I..
ADDITIONAL_OBJCFLAGS = -fblocks -fobjc-arc
ADDITIONAL_OBJCCFLAGS = -fblocks -fobjc-arc

McLarenSynthKit_HEADER_FILES_DIR = $(HEADER_DIR)

McLarenSynthKit_LIBRARIES_DEPEND_UPON += -lasound -lsndfile -lresample -lgnustep-base -lobjc -ldispatch

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble

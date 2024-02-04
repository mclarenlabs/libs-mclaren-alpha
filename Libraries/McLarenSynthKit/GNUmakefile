#
#  GNUmakefile
#
#  Copyright (C) 2023 McLaren Labs
#

include $(GNUSTEP_MAKEFILES)/common.make

# include ../../Version # TOM: this is very clever

LIBRARY_NAME = McLarenSynthKit

#  MSKMetronome.m \
#  model/MSKValuesModel.m \

McLarenSynthKit_OBJC_FILES = \
  MSKError.m \
  model/MSKModelBase.m \
  MSKContext.m \
  model/MSKEnvelopeModel.m \
  env/MSKEnvelopeFanout.m \
  model/MSKOscillatorModel.m \
  model/MSKModulatedOscillatorModel.m \
  model/MSKDrawbarOscillatorModel.m \
  voice/MSKSinFixedOscillator.m \
  voice/MSKDrawbarOscillator.m \
  voice/MSKFMPhaseEnvelopeOscillator.m \
  model/MSKFilterModel.m \
  model/MSKReverbModel.m \
  fifo/MSKOFifo.m

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
  model/MSKModelBase.h model/MSKModelProtocol.h \
  MSKContext.h \
  model/MSKEnvelopeModel.h \
  env/MSKLinEnvelope.h \
  env/MSKExpEnvelope.h \
  env/MSKEnvelopeFanout.h \
  model/MSKOscillatorModel.h \
  model/MSKModulatedOscillatorModel.h \
  model/MSKDrawbarOscillatorModel.h \
  voice/MSKSinFixedOscillator.h \
  voice/MSKGeneralOscillator.h \
  voice/MSKDrawbarOscillator.h \
  voice/MSKPhaseDistortionOscillator.h \
  voice/MSKFMPhaseEnvelopeOscillator.h \
  filt/MSKGeneralFilter.h \
  model/MSKFilterModel.h \
  model/MSKReverbModel.h \
  fx/MSKFreeverbReverb.h \
  fifo/MSKOFifo.h

McLarenSynthKit_HEADER_FILES += McLarenSynthKit.h



ADDITIONAL_CPPFLAGS += -I..
ADDITIONAL_OBJCFLAGS = -fblocks -fobjc-arc
ADDITIONAL_OBJCCFLAGS = -fblocks -fobjc-arc

McLarenSynthKit_HEADER_FILES_DIR = $(HEADER_DIR)

McLarenSynthKit_LIBRARIES_DEPEND_UPON += -lasound -lgnustep-base -lobjc -ldispatch

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble

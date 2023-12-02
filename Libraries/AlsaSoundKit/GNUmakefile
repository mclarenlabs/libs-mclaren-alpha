#
#  GNUmakefile
#
#  Copyright (C) 2023 McLaren Labs
#

include $(GNUSTEP_MAKEFILES)/common.make

# include ../../Version # TOM: this is very clever

LIBRARY_NAME = AlsaSoundKit

AlsaSoundKit_OBJC_FILES = \
  ASKError.m \
  ASKPcm.m \
  ASKPcmList.m \
  ASKPcmSystem.m \
  ASKSeqEvent.m \
  ASKSeq.m \
  ASKSeqList.m \
  ASKSeqSystem.m 

AlsaSoundKit_HEADER_FILES = \
  ASKError.h \
  ASKPcm.h \
  ASKPcmList.h \
  ASKPcmSystem.h \
  ASKSeqEvent.h \
  ASKSeq.h \
  ASKSeqList.h \
  ASKSeqSystem.h


AlsaSoundKit_HEADER_FILES += AlsaSoundKit.h



ADDITIONAL_CPPFLAGS += -I..
ADDITIONAL_OBJCFLAGS = -fblocks -fobjc-arc

AlsaSoundKit_HEADER_FILES_DIR = $(HEADER_DIR)

AlsaSoundKit_LIBRARIES_DEPEND_UPON += -lasound -lgnustep-base -lobjc -ldispatch

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble

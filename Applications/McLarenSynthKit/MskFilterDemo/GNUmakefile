#
# GNUmakefile
#
# Copyright (C) 2023 McLaren Labs

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = \
  MskFilterDemo

COMMON_OBJC_FILES = 

MskFilterDemo_OBJC_FILES = \
  MskFilterDemo_main.m \
  NSObject+MLBlocks.m \
  MskFilterDemo_AppDelegate.m

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc
ADDITIONAL_LDFLAGS = -ldispatch

# Run makefiles with "localdev=yes" to add addl flags that find
# libraries in this package rather than in global installed locations

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

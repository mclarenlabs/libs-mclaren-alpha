#
# GNUmakefile
#
# Copyright (C) 2023 McLaren Labs

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = \
  MskMetroDemo \
  MskPatternDemo

COMMON_OBJC_FILES = 

MskMetroDemo_OBJC_FILES = \
  MskMetroDemo_main.m \
  NSObject+MLBlocks.m \
  MskMetroDemo_AppDelegate.m

MskPatternDemo_OBJC_FILES = \
  PrettyScheduler.m \
  MskPatternDemo_main.m \
  NSObject+MLBlocks.m \
  MskPatternDemo_AppDelegate.m

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc
ADDITIONAL_LDFLAGS = -ldispatch

# Run makefiles with "localdev=yes" to add addl flags that find
# libraries in this package rather than in global installed locations

ifeq ($(localdev),yes)
ADDITIONAL_CPPFLAGS += -I../../../Libraries/
ADDITIONAL_LIB_DIRS += -L ../../../Libraries/McLarenSynthKit/obj -L../../../Libraries/AlsaSoundKit/obj  
ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../../Libraries/McLarenSynthKit/obj' -l:libMcLarenSynthKit.so -Wl,-rpath='$$ORIGIN/../../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so
endif

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUMakefile.postamble

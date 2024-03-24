#
#  AlsaSoundKit tools
#
#

include $(GNUSTEP_MAKEFILES)/common.make

#  metronome \

TOOL_NAME = \
  scaleplayer \
  pdscaleplayer \
  tiny \
  playsample \
  capturesample \

COMMON_OBJC_FILES = 

metronome_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        metronome.m

scaleplayer_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        scaleplayer.m

pdscaleplayer_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
	NSObject+MLBlocks.m \
        pdscaleplayer.m

tiny_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        tiny.m

playsample_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        playsample.m

capturesample_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        capturesample.m

ADDITIONAL_TOOL_LIBS = -lMcLarenSynthKit -lAlsaSoundKit -ldispatch 


# Run makefiles with "localdev=yes" to add addl flags that find
# libraries in this package rather than in global installed locations

ifeq ($(localdev),yes)
  ADDITIONAL_INCLUDE_DIRS += -I../../Libraries/
  ADDITIONAL_LIB_DIRS += -L../../Libraries/McLarenSynthKit/obj/ -L../../Libraries/AlsaSoundKit/obj/
  ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../Libraries/McLarenSynthKit/obj' -l:libMcLarenSynthKit.so -Wl,-rpath='$$ORIGIN/../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so
endif 

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUMakefile.postamble

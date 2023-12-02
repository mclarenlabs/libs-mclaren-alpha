#
#  AlsaSoundKit tools
#
#

include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = \
  askpcmlist \
  askseqdump \
  askseqlist \
  miniosc1 \
  minisynth1

COMMON_OBJC_FILES = 

askpcmlist_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        askpcmlist.m

askseqdump_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        askseqdump.m

askseqlist_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        askseqlist.m

miniosc1_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        miniosc1.m

minisynth1_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        minisynth1.m

ADDITIONAL_TOOL_LIBS = -lAlsaSoundKit -ldispatch


# Run makefiles with "localdev=yes" to add addl flags that find
# libraries in this package rather than in global installed locations

ifeq ($(localdev),yes)
  ADDITIONAL_INCLUDE_DIRS += -I../../Libraries/
  ADDITIONAL_LIB_DIRS += -L../../Libraries/AlsaSoundKit/obj/
  ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so
endif 

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUMakefile.postamble

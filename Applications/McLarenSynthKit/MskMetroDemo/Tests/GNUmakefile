#
#  AlsaSoundKit tools
#
#

include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = \
  test1 \
  test2 \
  test3 \
  test4 \
  test5 \
  test6 \
  test7 \
  test8 \
  test9

COMMON_OBJC_FILES = \
  ../Pattern.m

test1_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test1.m

test2_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test2.m

test3_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test3.m

test4_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test4.m

test5_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test5.m

test6_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test6.m

test7_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test7.m

test8_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test8.m

test9_OBJC_FILES = \
        $(COMMON_OBJC_FILES) \
        $(DEBUG_FILES) \
        test9.m

ADDITIONAL_TOOL_LIBS = -lAlsaSoundKit -lMcLarenSynthKit -ldispatch


# Run makefiles with "localdev=yes" to add addl flags that find
# libraries in this package rather than in global installed locations

ifeq ($(localdev),yes)
  ADDITIONAL_INCLUDE_DIRS += -I.. -I../../../../Libraries -I$(GNUSTEP_MAKEFILES)/TestFramework
  ADDITIONAL_LIB_DIRS += -L../../../../Libraries/AlsaSoundKit/obj/ -L../../../../Libraries/McLarenSynthKit/obj/
  ADDITIONAL_LDFLAGS += -Wl,-rpath='$$ORIGIN/../../../../../Libraries/AlsaSoundKit/obj' -l:libAlsaSoundKit.so -Wl,-rpath='$$ORIGIN/../../../../../Libraries/McLarenSynthKit/obj' -l:libMcLarenSynthKit.so
endif 

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import -fblocks -fobjc-arc

ifeq ($(check),yes)
    ADDITIONAL_OBJCFLAGS += -Werror
endif


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUMakefile.postamble

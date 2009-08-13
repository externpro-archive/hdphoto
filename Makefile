################################################################################
# hdphoto Makefile
# This script uses the multi-architecture build concept borrowed from the 
# website http://make.paulandlesley.org/multi-arch.html.
#
# Version: $Id: Makefile 9695 2008-07-30 23:34:36Z pete $
#
################################################################################

# This make script is first called from the main source directory and then one 
# directory level down in the build directory. The variable SRCDIR, defined in 
# target.mk and is passed in to the second invocation of this makefile and is 
# used to detect the current directory level. 
ifdef SRCDIR
  SOLUTION_DIR := ../..
else
  SOLUTION_DIR := ..
endif

SHARED_DIR := $(SOLUTION_DIR)/../Shared
MAKE_DIR := $(SHARED_DIR)/make
ifeq ($(SDL_EXTERN),)
  SDL_EXTERN := $(SOLUTION_DIR)/../sdlExtern
endif

include $(MAKE_DIR)/exports.mk

# OUTPUT_DIR is used in this file and in target.mk
OUTPUT_DIR := $(strip $(SOLUTION_DIR)/$(LIB_DIR))

# If the current directory does not have an underscore then include target.mk.
ifeq (,$(filter _%,$(notdir $(CURDIR))))

  include $(MAKE_DIR)/target.mk

else

  include $(OUTPUT_DIR)/locals.mk

  # This is the portion of the script which will be run in the build 
  # directory. It uses VPATH to find the source files.

  .SUFFIXES:

  INC := -I$(SRCDIR)/image/sys -I$(SRCDIR)/common/include \
         -I$(SRCDIR)/systems/tools/wmpgluelib \
         -I$(SRCDIR)/systems/tools/wmpmetalib
  LIB := $(OUTPUT_DIR)/libhdphoto$(BLD_LTR).a
  CPPFLAGS += -D__ANSI__ -DDISABLE_PERF_MEASUREMENT
  ifeq ($(ENDIAN),BIG_ENDIAN_CODE)
  CPPFLAGS += -D_BIG__ENDIAN_
  endif
  USER_SPECIALS := $(INC)

  # Common
  VPATH := $(SRCDIR)/image/sys
  C_SRC := adapthuff.c \
           image.c \
           perfTimerANSI.c \
           strcodec.c \
           strPredQuant.c \
           strTransform.c

  # Decode
  VPATH += $(SRCDIR)/image/decode
  C_SRC += decode.c \
           huffman.c \
           postprocess.c \
           segdec.c \
           strdec.c \
           strInvTransform.c \
           strPredQuantDec.c \
           WMPTranscode.c

  # Encode
  VPATH += $(SRCDIR)/image/encode
  C_SRC += encode.c \
           segenc.c \
           strenc.c \
           strFwdTransform.c \
           strPredQuantEnc.c

  # WMPGlue
  VPATH += $(SRCDIR)/systems/tools/wmpgluelib
  C_SRC += WMPGlue.c \
           WMPGlueBmp.c \
           WMPGlueHdr.c \
           WMPGluePFC.c \
           WMPGluePnm.c \
           WMPGlueTif.c \
           WMPGlueWmp.c \
           WMPGlueYUV.c

  # WMPMeta
  VPATH += $(SRCDIR)/systems/tools/wmpmetalib
  C_SRC += WMPMeta.c

  include $(MAKE_DIR)/obj_dep.mk

  # Create the library
  $(LIB): $(C_OBJS) $(CPP_OBJS)
	  @echo Creating library $(LIB).
	  $(AR) $(LIB) $(C_OBJS) $(CPP_OBJS)

  include $(MAKE_DIR)/rules.mk

endif

VERBOSE ?= 0
# echo suspend
ifeq ($(VERBOSE),1)
  NO_ECHO :=
else
  NO_ECHO := @
endif
# $1 path
GNU_PREFIX       := arm-none-eabi
# https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
GNU_INSTALL_PATH := /opt/arm/gcc-arm-none-eabi-9/bin/
# Toolchain commands
CC      := $(GNU_INSTALL_PATH)$(GNU_PREFIX)-gcc
OBJDUMP := $(GNU_INSTALL_PATH)$(GNU_PREFIX)-objdump
#$(info $$CC is $(CC))
#$(info $$OBJDUMP is $(OBJDUMP))
# Optimization flags
OPT = -O0 -g0
# C flags common to all targets
CFLAGS += $(OPT)
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs
CFLAGS += -Wall -Werror -fstack-usage
CFLAGS += -mfloat-abi=soft
# keep every function in a separate section, this allows linker to discard unused ones
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin -fshort-enums -Wno-unused-function -Wno-unused-variable
.PHONY: clean default
# Default target - first one defined
SOURCES=$(wildcard *.c)
OBJECTS=$(SOURCES:.c=.o)
ASSEMBLY=$(OBJECTS:.o=.S)
default: $(OBJECTS) $(ASSEMBLY)
$(ASSEMBLY): $(OBJECTS)
$(OBJECTS): $(SOURCES)
	$(NO_ECHO)$(CC) -std=c99 $(CFLAGS) -c -o $@ $<
$(ASSEMBLY): $(OBJECTS)
	$(NO_ECHO)$(OBJDUMP) -dr $< > $@
clean:
	$(NO_ECHO)rm -f *.o *.S *.su

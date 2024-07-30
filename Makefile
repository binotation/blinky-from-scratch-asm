# Compiler and flags
CC = arm-none-eabi-gcc
CFLAGS = -nostdlib -g -mcpu=cortex-m4 -mthumb
LDFLAGS = -T gcc.ld -Wl,-Map=output.map

# Source files
SOURCES = startup_ARMCM4.S blinky.s

# Output files
TARGET = blinky.elf
MAP = output.map

# Default target
all: $(TARGET)

# Compile and link
$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

# Clean up
clean:
	rm $(TARGET) $(MAP)

# Phony targets
.PHONY: all clean

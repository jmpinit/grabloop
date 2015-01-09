NAME := grabloop

ifeq ($(OS),Windows_NT)
S := \\
else
S := /
endif

SRCDIR := src
OBJDIR := obj
BINDIR := bin

HEX := $(BINDIR)$(S)$(NAME).hex
OUT := $(OBJDIR)$(S)$(NAME).out
MAP := $(OBJDIR)$(S)$(NAME).map

SOURCES =	main.c \
		Nokia3310.c
			
#HEADERS := src/inc/$(wildcard *.h)
INCLUDES = -Isrc$(S)inc -Ires
OBJECTS = $(patsubst %,$(OBJDIR)$(S)%,$(SOURCES:.c=.o))
MCU := atmega32u4
MCU_AVRDUDE := m32u4
MCU_FREQ := 16000000UL

CC := avr-gcc
OBJCOPY := avr-objcopy
SIZE := avr-size -C --mcu=$(MCU)

CFLAGS := -Wall -pedantic -mmcu=$(MCU) -std=c99 -g -Os -DF_CPU=$(MCU_FREQ) -gstabs

all: $(HEX)

clean:
ifeq ($(OS),Windows_NT)
	del $(HEX) $(OUT) $(MAP) $(OBJECTS)
else
	rm $(HEX) $(OUT) $(MAP) $(OBJECTS)
endif

flash: $(HEX)
	sudo python reset.py /dev/ttyACM0
	sleep 2
	sudo avrdude -y -c avr109 -P /dev/ttyACM0 -b 57600 -p $(MCU_AVRDUDE) -D -U flash:w:$(HEX):i

$(HEX): $(OUT)
	$(OBJCOPY) -R .eeprom -O ihex $< $@

$(OUT): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ -Wl,-Map,$(MAP) $^
	@echo = = = = = = = = =
	$(SIZE) $@

$(OBJDIR)$(S)%.o: $(SRCDIR)$(S)%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<
	
$(OBJDIR):
	mkdir $(OBJDIR)

.PHONY: all clean flash


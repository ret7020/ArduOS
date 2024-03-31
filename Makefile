# Toolchain setup
CC=~/.arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/bin/avr-g++
AVR_TOOLCHAIN=~/.arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/bin
AVR_DUDE=~/.arduino15/packages/arduino/tools/avrdude/6.3.0-arduino17
CTAGS=/usr/bin/arduino-ctags
ARDUINO_AVR=~/.arduino15/packages/arduino/hardware/avr/1.8.6
FLAGS=-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing
SOURCE=sheduler_test.cpp
LIBS=arduos.h

# Board Setup
FLASH_PORT=/dev/ttyUSB0
MCU=atmega328p

wsc:
	rm -rf build
	mkdir build


core:
	echo "Core"

sheduler:
	$(CC) $(FLAGS) -flto -w -x c++ -E -CC -mmcu=$(MCU) -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_AVR_NANO -DARDUINO_ARCH_AVR -I$(ARDUINO_AVR)/cores/arduino -I$(ARDUINO_AVR)/variants/eightanaloginputs -I$(LIBS) sheduler.cpp -o ./build/sheduler_prepoc.cpp
	$(CTAGS) -u --language-force=c++ -f - --c++-kinds=svpf --fields=KSTtzns --line-directives ./build/sheduler_prepoc.cpp
	$(CC) $(FLAGS) -MMD -flto -mmcu=$(MCU) -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_рнAVR_NANO -DARDUINO_ARCH_AVR -I$(ARDUINO_AVR)/cores/arduino -I$(ARDUINO_AVR)/variants/eightanaloginputs sheduler.cpp -o ./build/sheduler.o

flash:
	
	# Build User Source
	$(CC) $(FLAGS) -flto -w -x c++ -E -CC -mmcu=$(MCU) -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_AVR_NANO -DARDUINO_ARCH_AVR -I$(ARDUINO_AVR)/cores/arduino -I$(ARDUINO_AVR)/variants/eightanaloginputs -I$(LIBS) $(SOURCE) -o ./build/$(SOURCE)_prepoc.cpp
	$(CTAGS) -u --language-force=c++ -f - --c++-kinds=svpf --fields=KSTtzns --line-directives ./build/$(SOURCE)_prepoc.cpp
	$(CC) $(FLAGS) -MMD -flto -mmcu=$(MCU) -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_рнAVR_NANO -DARDUINO_ARCH_AVR -I$(ARDUINO_AVR)/cores/arduino -I$(ARDUINO_AVR)/variants/eightanaloginputs $(SOURCE) -o ./build/$(SOURCE).o

	# Build OS parts
	## Sheduler
	$(CC) $(FLAGS) -flto -w -x c++ -E -CC -mmcu=$(MCU) -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_AVR_NANO -DARDUINO_ARCH_AVR -I$(ARDUINO_AVR)/cores/arduino -I$(ARDUINO_AVR)/variants/eightanaloginputs -I$(LIBS) sheduler.cpp -o ./build/sheduler_prepoc.cpp
	$(CTAGS) -u --language-force=c++ -f - --c++-kinds=svpf --fields=KSTtzns --line-directives ./build/sheduler_prepoc.cpp
	$(CC) $(FLAGS) -MMD -flto -mmcu=$(MCU) -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_рнAVR_NANO -DARDUINO_ARCH_AVR -I$(ARDUINO_AVR)/cores/arduino -I$(ARDUINO_AVR)/variants/eightanaloginputs sheduler.cpp -o ./build/sheduler.o


	# Link
	$(AVR_TOOLCHAIN)/avr-gcc -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=$(MCU) -o ./build/$(SOURCE).elf ./build/$(SOURCE).o ./build/sheduler.o core.a -L./ -lm
	$(AVR_TOOLCHAIN)/avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 ./build/$(SOURCE).elf ./build/$(SOURCE).eep
	$(AVR_TOOLCHAIN)/avr-objcopy -O ihex -R .eeprom ./build/$(SOURCE).elf ./build/$(SOURCE).hex
	$(AVR_TOOLCHAIN)/avr-size -A ./build/$(SOURCE).elf

	# Flash it
	$(AVR_DUDE)/bin/avrdude -C$(AVR_DUDE)/etc/avrdude.conf -v -p$(MCU) -carduino -P$(FLASH_PORT) -b57600 -D -Uflash:w:./build/$(SOURCE).hex:i 



# 430465816

Hello fans of CMSC 430. Imagine we took the wonderful language designed in that class and changed the target language from a86 (a fine architecture) to 65816 (a bad old architecture) and made it work for the SNES.

Each version includes some incremental gains both in implementing the features of that language and the runtime system and other organizational things.

To compile you will need racket and to assemble the code you will need the `asar` assembler (hit up google for that). I just rely on the makefile so just do what it says.

Also, to run the assembled `.sfc` file, pick your favorite Super Nintendo emulator. I recommend Mesen2 (also hit up google). It is a fully-featured (master-)cycle-accurate emulator with enough debugging tools to leave even the least error-prone programmer jumping for joy. For Windows and Linux there should be executables already created. For MacOS (like me) you would have to build it from source (a nightmare). Or just use a worse crappy emulator.

LANG = fraud
ASM = comp
SRC = 42

$(LANG).sfc: *.asm *.rkt *.bin
	./asar --symbols=wla init.asm $(LANG).sfc 

$(ASM).asm: *.rkt
	racket -t compile-stdin.rkt -m < $(SRC).rkt > comp.asm


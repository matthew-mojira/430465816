LANG = dodger
ASM = comp
SRC = 42

$(LANG).sfc: $(ASM).asm 42.rkt
	./asar --symbols=wla init.asm $(LANG).sfc 

$(ASM).asm: $(SRC).rkt
	racket -t compile-stdin.rkt -m < $(SRC).rkt >! comp.asm


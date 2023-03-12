ASAR = asar

libs = \
  init.asm \
  main.asm \
  err.asm \
  io.asm \
  ram.asm \
  registers.asm \
  types.asm

%.sfc: %.asm $(libs)
	./$(ASAR) --symbols=wla init.asm $@

%.asm: *.rkt
	cat $< | racket -t compile-stdin.rkt -m > $@

clean:
	rm *.sfc *.sym

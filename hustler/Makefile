ASAR = asar

libs = \
  init.asm \
  main.asm \
  err.asm \
  io.asm \
  ram.asm \
  registers.asm \
  types.asm

racket = \
	65816.rkt \
	ast.rkt \
	compile-ops.rkt \
	compile-stdin.rkt \
	compile.rkt \
	parse.rkt

%.sfc: %.asm $(libs)
	./$(ASAR) --symbols=wla init.asm $@

%.asm: %.rkt $(racket)
	cat $< | racket -t compile-stdin.rkt -m > $@

clean:
	rm *.sfc *.sym

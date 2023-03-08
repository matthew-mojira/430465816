ORG $C20000
entry:
  LDA.W #1
  CMP.W #0
  BEQ iftrue4081
  LDA.W #0
  CMP.W #0
  BEQ iftrue4083
  LDA.W #2048
  BRA endif4084
iftrue4083:
  LDA.W #1024
endif4084:
  BRA endif4082
iftrue4081:
  LDA.W #43
  DEC
endif4082:
  RTL

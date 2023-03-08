ORG $C20000
entry:
    LDA.W #200
    CMP.W #0
    BEQ iftrue4817
    LDA.W #3
    BRA endif4818
iftrue4817:
    LDA.W #1
endif4818:
    CMP.W #3
    BEQ iftrue4815
    LDA.W #3
    BRA endif4816
iftrue4815:
    LDA.W #10000
    DEC
    DEC
    INC
    INC
    DEC
    DEC
endif4816:
    RTL

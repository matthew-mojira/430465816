ORG $C20000
entry:
    LDA.W #2<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int4248
    BRK #$00
assert_int4248:
    PHA
    LDA.W #1<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int4249
    BRK #$00
assert_int4249:
    CLC
    ADC 1,S
    PLY
    PHA
    LDA 1,S
    BIT.W #!int_type_mask
    BEQ assert_int4250
    BRK #$00
assert_int4250:
    PHA
    LDA.W #4<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int4251
    BRK #$00
assert_int4251:
    SEC
    SBC 1,S
    PLY
    PHA
    LDA 1,S
    BIT.W #!int_type_mask
    BEQ assert_int4252
    BRK #$00
assert_int4252:
    PHA
    LDA 5,S
    BIT.W #!int_type_mask
    BEQ assert_int4253
    BRK #$00
assert_int4253:
    PHA
    LDA 7,S
    BIT.W #!int_type_mask
    BEQ assert_int4254
    BRK #$00
assert_int4254:
    CLC
    ADC 1,S
    PLY
    BIT.W #!int_type_mask
    BEQ assert_int4255
    BRK #$00
assert_int4255:
    CLC
    ADC 1,S
    PLY
    PLY
    PLY
    RTL

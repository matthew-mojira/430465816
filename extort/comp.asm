ORG $C20000
entry:
    LDA.W #97<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int4183
    BRK #$00
assert_int4183:
    CMP.W #255
    BCC assert_ascii4182
    BRK #$00
assert_ascii4182:
    LSR #!int_shift
    ASL #!char_shift
    EOR.W #!char_type_tag
    LDA.W #98<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int4185
    BRK #$00
assert_int4185:
    CMP.W #255
    BCC assert_ascii4184
    BRK #$00
assert_ascii4184:
    LSR #!int_shift
    ASL #!char_shift
    EOR.W #!char_type_tag
    RTL

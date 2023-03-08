entry:
    JSL read_byte
    JSL peek_byte
    BIT.W #!int_type_mask
    BEQ assert_int4248
    BRK #$00
assert_int4248:
    INC
    INC
    RTL

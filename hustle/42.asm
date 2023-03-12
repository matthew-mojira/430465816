entry:
    LDA.W #!val_empty
    PHA
    LDA.W #69<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5063
    BRK #$00
assert_int5063:
    CMP.W #0
    BEQ iftrue5064
    LDA.W #!val_false
    BRA endif5065
iftrue5064:
    LDA.W #!val_true
endif5065:
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    PHA
    LDA.W #170<<!int_shift
    STA [!HEAP]
    LDA !HEAP
    ASL #1
    ORA.W #!box_type_tag
    INC !HEAP
    INC !HEAP
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    PHA
    LDA.W #107<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5067
    BRK #$00
assert_int5067:
    CMP.W #2047
    BCC assert_byte5066
    BRK #$00
assert_byte5066:
    JSL write_byte
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    PHA
    JSL peek_byte
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    PHA
    LDA.W #42<<!int_shift
    PHA
    LDA.W #41<<!int_shift
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    PHA
    LDA.W #((101<<!char_shift)|!char_type_tag)
    STA [!HEAP]
    PLA
    LDY.W #2
    STA [!HEAP],Y
    LDA !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC !HEAP
    INC !HEAP
    INC !HEAP
    INC !HEAP
    RTL

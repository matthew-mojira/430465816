entry:
    LDA.W #!val_empty
    PHA
    LDA.W #20<<!int_shift
    PHA
    LDA.W #10<<!int_shift
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    BIT.W #%10
    BNE assert_box5390
    BRK.B #0
assert_box5390:
    BIT.W #%01
    BEQ assert_box5391
    BRK.B #0
assert_box5391:
    SEC
    ROR #!imm_shift
    ASL #!imm_shift-1
    STA.B !DEREF
    LDY.W #2
    LDA.B [!DEREF],Y
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    PHA
    LDA.W #69<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5392
    BRK.B #0
assert_int5392:
    CMP.W #0
    BEQ iftrue5393
    LDA.W #!val_false
    BRA endif5394
iftrue5393:
    LDA.W #!val_true
endif5394:
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    PHA
    LDA.W #5<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5395
    BRK.B #0
assert_int5395:
    PHA
    LDA.W #5<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5396
    BRK.B #0
assert_int5396:
    CMP.B 1,S
    BEQ iftrue5397
    LDA.W #!val_false
    BRA endif5398
iftrue5397:
    LDA.W #!val_true
endif5398:
    PLY
    STA.B [!HEAP]
    LDA.B !HEAP
    ASL #1
    ORA.W #!box_type_tag
    INC.B !HEAP
    INC.B !HEAP
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    PHA
    LDA.W #107<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5400
    BRK.B #0
assert_int5400:
    CMP.W #2047
    BCC assert_byte5399
    BRK.B #0
assert_byte5399:
    JSL write_byte
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    PHA
    JSL peek_byte
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    PHA
    LDA.W #42<<!int_shift
    STA.B [!HEAP]
    LDA.B !HEAP
    ASL #1
    ORA.W #!box_type_tag
    INC.B !HEAP
    INC.B !HEAP
    BIT.W #%10
    BEQ assert_box5401
    BRK.B #0
assert_box5401:
    BIT.W #%01
    BNE assert_box5402
    BRK.B #0
assert_box5402:
    SEC
    ROR #!imm_shift
    ASL #!imm_shift-1
    STA.B !DEREF
    LDA.B [!DEREF]
    PHA
    LDA.W #2<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5403
    BRK.B #0
assert_int5403:
    PHA
    LDA.W #20<<!int_shift
    BIT.W #!int_type_mask
    BEQ assert_int5404
    BRK.B #0
assert_int5404:
    CLC
    ADC.B 1,S
    PLY
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    PHA
    LDA.W #((101<<!char_shift)|!char_type_tag)
    STA.B [!HEAP]
    PLA
    LDY.W #2
    STA.B [!HEAP],Y
    LDA.B !HEAP
    ASL #1
    ORA.W #!cons_type_tag
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    INC.B !HEAP
    RTL

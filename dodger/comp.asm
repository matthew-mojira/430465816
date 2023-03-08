ORG $C20000
entry:
    LDA.W #((98<<!char_shift)|!char_type_tag)
    AND.W #!char_type_mask
    CMP.W #!char_type_tag
    BEQ iftrue4129
    LDA.W #!val_false
    BRA endif4130
iftrue4129:
    LDA.W #!val_true
endif4130:
    CMP.W #!val_false
    BEQ iftrue4127
    LDA.W #75<<!int_shift
    LSR #!int_shift
    ASL #!char_shift
    EOR.W #!char_type_tag
    BRA endif4128
iftrue4127:
    LDA.W #12<<!int_shift
    LSR #!int_shift
    ASL #!char_shift
    EOR.W #!char_type_tag
endif4128:
    RTL

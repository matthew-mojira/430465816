ORG $C20000
entry:
    LDA.W #((108<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((109<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((110<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((111<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((112<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((113<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((114<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((115<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((116<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((117<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    LDA.W #((118<<!char_shift)|!char_type_tag)
    LSR #!char_shift
    ASL #!int_shift
    JSL write_byte
    RTL

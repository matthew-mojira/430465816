;  Bit layout of values
;
;  Values are either:
;  - Immediates: end in #b00
;  - Pointers:
;
;  Pointers are either:
;  - Box:  01
;  - Cons: 10
;
;  Immediates are either
;  - Integers:   end in  #b0 00
;  - Characters: end in #b01 00
;  - True:              #b11 00
;  - False:           #b1 11 00
;  - Eof:            #b10 11 00
;  - Void:           #b11 11 00
;  - Empty:         #b100 11 00

!imm_shift #= 2

!ptr_type_mask #= ((1<<!imm_shift)-1)

!box_type_tag   #= 1
!cons_type_tag  #= 2

!int_shift #= (1+!imm_shift)
!int_type_mask #= ((1<<!int_shift)-1)

!int_type_tag    #= (0<<(!int_shift-1))
!nonint_type_tag #= (1<<(!int_shift-1))

!char_shift #= (!int_shift+1)
!char_type_mask #= ((1<<!char_shift)-1)

!char_type_tag    #= ((0<<(!char_shift-1))|!nonint_type_tag)
!nonchar_type_tag #= ((1<<(!char_shift-1))|!nonint_type_tag)

!val_true  #= ((0<<!char_shift)|!nonchar_type_tag)
!val_false #= ((1<<!char_shift)|!nonchar_type_tag)
!val_eof   #= ((2<<!char_shift)|!nonchar_type_tag)
!val_void  #= ((3<<!char_shift)|!nonchar_type_tag)
!val_empty #= ((4<<!char_shift)|!nonchar_type_tag)

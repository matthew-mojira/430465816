;  Bit layout of values
;
;  Values are either:
;  - Integers:   end in  #b0
;  - Characters: end in #b01
;  - True:              #b11
;  - False:            #b111
;  - Eof:             #b1011
;  - Void:            #b1111

!int_shift #= 1
!int_type_mask #= ((1<<!int_shift)-1)
!int_type_tag #= (0<<(!int_shift-1))
!nonint_type_tag #= (1<<(!int_shift-1))

!char_shift #= (!int_shift+1)
!char_type_mask #= ((1<<!char_shift)-1)
!char_type_tag #= ((0<<(!char_shift-1))|!nonint_type_tag)
!nonchar_type_tag #= ((1<<(!char_shift-1))|!nonint_type_tag)

!val_true #= ((0<<!char_shift)|!nonchar_type_tag)
!val_false #= ((1<<!char_shift)|!nonchar_type_tag)

!val_eof #= ((2<<!char_shift)|!nonchar_type_tag)
!val_void #= ((3<<!char_shift)|!nonchar_type_tag)

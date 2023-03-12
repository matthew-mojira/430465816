;; ZERO PAGE ALLOCATION
;; 10,20 - I/O
;; 30 - HUSTLE

!draw_pointer = $12   ; long
!read_pointer = $15  ; long
!cursor_timer = $18

!con1 = $20   ;word
!con1ff = $22 ;word
!con2 = $24   ;word
!con2ff = $26 ;word
!con3 = $28   ;word
!con3ff = $2A ;word
!con4 = $2C   ;word
!con4ff = $2E ;word

!HEAP = $30   ; long pointer
!DEREF = $33  ; word/long (provided)

!tilemap = $7E2000    ; huge

!GraphicsData = "ascii.bin"
!GraphicsSize = filesize("ascii.bin")
!CGData = "pal.pal"
!CGSize = filesize("pal.pal")
!TilemapData = "tilemap.bin"
!TilemapSize = filesize("tilemap.bin")

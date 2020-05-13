.model tiny
.code
org 100h

extrn frame: proc

OUTPUT 		           equ 21h
OUTPUT_CODE_AX       equ 4C00h
FRAME_COLOUR 	       equ 07F7eh
SYMBOLS_ONE_LINE     equ 80
VIDEO_MEMORY	       equ 0b800h
LINES  		           equ 5
WIDTH		             equ 60
LEFT_CORNER_X	       equ 21
LEFT_CORNER_Y        equ 15

Start:


        mov ax, VIDEO_MEMORY
        mov es, ax

        mov cx, FRAME_COLOUR
        mov bl, LINES
        mov bh, WIDTH
        mov dl, LEFT_CORNER_X
        mov dh, LEFT_CORNER_Y

        call frame


end Start

.model tiny
.code
org 100h

public End_label
public frame

;===============================================================================
;In: es - VIDEO_MEMORY (ob800h)
;    cx - FRAME COLOUR
;    bl - LINES
;    bh - WIDTH
;    dx - LEFT CORNER of THE FRAME(dl - LINE, dh - coloumn)
;===============================================================================

EndStart:
frame		proc

		xor di, di
		xor ax, ax
		mov al, dl
		mov di, 80

		push dx
		mul di
		pop dx

		add al, dh
		adc ah, 0

		mov di, 2
		mul di

		mov di, ax
		mov ax, cx

first:
		xor	cx, cx
		mov	cl, bh

		rep	stosw

		push ax
		mov ax, 80
		sub al, bh
		mov dx, 2
		mul dx
		add	di, ax
		pop ax

		mov cx, 0FFFFh
		call pause

		dec	bl
		cmp	bl, 0
		je skip

		jmp	first
skip:
		ret
		endp

pause:
		loop pause
		ret

End_label:
end

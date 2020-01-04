
Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik
start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt
				mov ax,6200h
				int 21h
				mov es,bx
				xor si,si
				mov al,es:[80h]
				cmp al,2
				jbe brak_parametru
				pisz_do_zmiennej:
				mov al,es:[82h+si]
				cmp al,0Dh
				je idz_dalej
				mov parametry[si],al
				inc si
				jmp pisz_do_zmiennej
				idz_dalej:
				;lea dx,informacja
				;call wypisz
				mov dx,offset parametry
				mov ax,3D00h
				int 21h
				jc brak_parametru
				mov wskaznik,ax
				graj:
				call czytaj_trojki
				mov dl,trojka[0]
				cmp dl,'Z'
				je koniec
				mov ax,0B00h
				int 21h
				cmp al,0
				jne koniec
				call sprawdz
				;jmp graj
				brak_parametru:
				lea dx,blad
				call wypisz
				call koniec
				koniec:
				in al,61h
				and al,11111100b
				out 61h,al
				mov bx,wskaznik
				mov ax,3E00h
				int 21h
				mov ax,4c00h
				int	21h
				wypisz:
				mov ah,09h
				int 21h
				ret
				czytaj_trojki:
				xor dx,dx
				mov bx,wskaznik
				mov cx,3
				mov ax,3F00h
				int 21h
				ret
				sprawdz:
				mov ax,36060 ;C
				cmp dl,'C'
				je oktawa
				mov ax,34000 ;C#
				cmp dl,'c'
				je oktawa
				mov ax,32162 ;D
				cmp dl,'D'
				je oktawa
				mov ax,30512 ;D#
				cmp dl,'d'
				je oktawa
				mov ax,29024 ;E
				cmp dl,'E'
				je oktawa
				mov ax,27045 ;F
				cmp dl,'F'
				je oktawa
				mov ax,25869 ;F#
				cmp dl,'f'
				je oktawa
				mov ax,24286 ;G
				cmp dl,'G'
				je oktawa
				mov ax,22885 ;G#
				cmp dl,'g'
				je oktawa
				mov ax,21636 ;A
				cmp dl,'A'
				je oktawa
				mov ax,20517 ;A#
				cmp dl,'a'
				je oktawa
				mov ax,19193 ;H
				cmp dl,'H'
				je oktawa
				xor ax,ax 	;PAUZA
				cmp dl,'P'	;Dla pauzy nie dzielimy czestotliwosci oscylatora, czyli dzwiek bedzie nieslyszalny dla czlowieka
				je oktawa
				call koniec
				oktawa:
				mov cl,trojka[1]
				sub cl,2Fh
				shr ax,cl
				xor cx,cx
				out 42h,al
				mov al,ah
				out 42h,al
				in al,61h
				or al,00000011b
				out 61h,al
				mov cl,trojka[2]
				sub cl,30h
				xor dx,dx
				mov ah,86h
				int 15h
				jmp graj
Progr           ends

dane            segment
	trojka db 0,0,0
	wskaznik dw 0
	parametry db 127 dup(0)
	blad db 10,13,"Brak parametrow pliku!$"
	informacja db 10,13,"Odtwarzanie muzyki z pliku w parametrze programu$"
dane            ends


stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends


end start
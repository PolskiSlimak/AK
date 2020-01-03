Progr           segment ;dyrektywa służąca do deklaracji segmentów logicznych
                assume  cs:Progr, ds:dane, ss:stosik ;asume - przypisuje etykietę do (części) wskazanego rejestru segmentowego (segment logiczny), 
													 ;nie zmiania zawartości rejestrów segmentowych, dlatego trzeba ustawić ich wartości samemu.
													 ;Dzięki assume można używać offsetu
start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt
				poczatek:
					mov si, 0
					lea dx, poczatkowa_wiad
					mov ah, 9
					int 21h
					mov ah, 1
					int 21H
					mov znak,al
					cmp al,2DH
					je liczba_minusowa
					cmp al,2BH
					je liczba_dodatnia
					lea dx, error
					mov ah, 9
					int 21h
					jmp poczatek
				liczba_minusowa:
					mov znak,31H
					lea dx, wiad_dla_min
					mov ah, 9
					int 21h
					call wczytywanie
					mov dl,enterr
					mov ah,02H
					int 21h
					lea dx, wypisz_info_zm
					mov ah, 9
					int 21h
					call wypisywanie_bin
					mov dl,enterr
					mov ah,02H
					int 21h
					;cmp cyfry,0
					;je jesli_minus_zero
					lea dx, wypisz_info_zu1
					mov ah, 9
					int 21h
					call wypisywanie_ZU1
					mov dl,enterr
					mov ah,02H
					int 21h
					lea dx, wypisz_info_zu2
					mov ah, 9
					int 21h
					call wypisywanie_ZU2
					mov ah, 4ch
					int 21h
				liczba_dodatnia:
					mov znak,30H
					lea dx, wiad_dla_dod
					mov ah, 9
					int 21h
					call wczytywanie
					mov dl,enterr
					mov ah,02H
					int 21h
					lea dx, wypisz_info_zm
					mov ah, 9
					int 21h
					call wypisywanie_bin
					mov dl,enterr
					mov ah,02H
					int 21h
					jesli_minus_zero:
					;cmp cyfry,0
					;call zmiana_znaku
					lea dx, wypisz_info_zu1
					mov ah, 9
					int 21h
					call wypisywanie_bin
					mov dl,enterr
					mov ah,02H
					int 21h
					lea dx, wypisz_info_zu2
					mov ah, 9
					int 21h
					call wypisywanie_bin
					mov ah, 4ch
					int 21h
				wczytywanie:
					mov ah, 1
					int 21H
					cmp al, 13
					je koniec1
					sub al, 30H 
					cmp al, 10
					jns info_error
					mov bl, al
					mov ax, 10
					mul si
					add ax, bx
					mov si, ax
					jmp wczytywanie
				koniec1:
					mov ax, si
					;cmp ax,0
					;js info_error
					cmp ax,129
					jns info_error
					cmp ax,128
					je sprawdzanie_znaku
				powrot:
					mov cyfry, al
					mov cx,4
					lea dx, wypisz_info_hex
					mov ah, 9
					int 21h
					xor dx,dx
				wypisywanie_hex:
					mov dl,cyfry
					shr dl,cl;dokladne dzialanie shra trzeba ogarnac
					and dl,0FH
					cmp dl,9
					jbe wyp
					add dl,7
				wyp:
					add dl,'0'
					mov ah,02H;sprawdzic przerwania 
					int 21H
					sub cx,4
					jns wypisywanie_hex
					ret
				info_error:
					lea dx, wiad_error
					mov ah, 9
					int 21h
					call poczatek
				sprawdzanie_znaku:
					cmp znak,31H
					jne zly_znak
					jmp powrot
				zly_znak:
					lea dx, wiad_znak
					mov ah, 9
					int 21h
					call poczatek
				wypisywanie_bin:
					mov bl,cyfry		
					mov cx,8
					mov dl,znak
					mov ah,02H
					int 21h
					mov dl,'.'
					mov ah,02H
					int 21h	
				loopBin:
					xor dx,dx			 
					shl bl,1			
					jnc wpisywanie_do_zmiennej			 
					mov dx,1			
				wpisywanie_do_zmiennej:	
					add dx,'0'
					mov ah, 02H
					int 21h
					loop loopBin
					ret
				wypisywanie_ZU1:
					not cyfry;jak dziala not
					call wypisywanie_bin
					ret
				wypisywanie_ZU2:
					add cyfry,1
					call wypisywanie_bin
					ret
				zmiana_znaku:
					mov znak,30H
					ret
					;problem z minus zerem, trzeba zrobic warunek albo cos innego wymyslic
Progr           ends ;kończy obszar danego segmentu logicznego

dane            segment
	   poczatkowa_wiad db 10,13,"Wpisz minus albo plus:$"
	   error db 10,13,"Wpisales zly znak. Musisz podac - albo +$"
	   wiad_dla_dod db 10,13,"Wpisz liczbe dla obliczen dodatnich:$"
	   wiad_dla_min db 10,13,"Wpisz liczbe dla obliczen minusowych:$"
	   wiad_error db 10,13,"Wpisales zla wartosc$"
	   wiad_znak db 10,13,"Nie mozesz wpisac 128$"
	   wypisz_info_hex db 10,13,"Twoja liczba hexadecymalnie: $"
	   wypisz_info_zm db 10,13,"Twoja liczba w ZM: $"
	   wypisz_info_zu1 db 10,13,"Twoja liczba w ZU1: $"
	   wypisz_info_zu2 db 10,13,"Twoja liczba w ZU2: $"
	   cyfry db 0
	   znak db 0
	   enterr db 10,13
dane            ends

stosik          segment
                dw 100h dup(0) ;declare word, 256 decymalnie 
szczyt          Label word  ;dyrektywa label służy do tworzenia etykiet, przyporządkowuje im aktualną wartość adresu
							;jest ona użyteczna przy nadawaniu zmiennym pamięciowym już nazwanym, innej nazwy z innym kodem
stosik          ends

end start


;Dyrektywa - zbiór instrukcji asemblera. Dyrektywy nie modyfikują bezpośrednio zawartości danych, 
;ale są dla asemblera czymś co definiuje jak czytać kod., definiują jezyk, skłądnię. 

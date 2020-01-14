
Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik
start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt
				mov ax,6200h ;kod obsługi przerwania 21h, tworzy program segment prefix w bx, czyli strukturę
					     ;w DOSie, która przechowuje stan programu (w es)
				int 21h
				mov es,bx ;przenosimy adres pierwszego bajtu do es
				xor si,si
				mov al,es:[80h] ;ładujemy bajt 80 komórki do al, jest to bajt, który przechowuje informacje ile jest
						;bajtów w command line, pamięta ilość znaków wpisanych parametrów
				cmp al,2 ;sprawdzamy, czy jest więcej niż 1, bo wtedy to jest sama spacja
				jbe brak_parametru
					pisz_do_zmiennej:
				mov al,es:[82h+si]
				cmp al,0Dh ;sprawdzamy czy nie enter
				je idz_dalej
				mov parametry[si],al ;z al znak do tablicy parametry
				inc si
				jmp pisz_do_zmiennej
					idz_dalej:
				;lea dx,informacja
				;call wypisz
				mov dx,offset parametry ;do dx adres tablicy parametry (6 komórka ds)
				mov ax,3D00h ;kod obsługi przerwania 21h, sprawdza czy ciąg parametrów jest plikiem, jeśli plik nie 
					     ;istnieje to C=1, jeśli istnieje to C=0, tworzy uchwyt (dojście) do plików, który ustawia
					     ;się na 1 linijce i pokazuje na 1 bajt, wrzuca go do ax
				int 21h
				jc brak_parametru
				mov wskaznik,ax ;inicjujemy wskaźnik adrsem na który wskazuje ten uchwyt
					graj:
				call czytaj_trojki
				mov dl,trojka[0] ;pierwszy znak do dl
				cmp dl,'Z';sprawdzamy czy nie z, bo z jest końcem pliku
				je koniec
				mov ax,0B00h ;sprawdza czy użytkownik nie wcisnął dowolnego klawisza, jeśli tak to al=1, nie - al=0
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
				in al,61h ;pobieramy bajt odpowiedzialny za stan głośnika
				and al,11111100b ;wyłączamy głośnik, 11 na 00
				out 61h,al ;odsyłamy
				mov bx,wskaznik
				mov ax,3E00h ;zamyka plik, którego uchwyt jest w bx
				int 21h
				mov ax,4c00h ; <3
				int	21h
					wypisz:
				mov ah,09h
				int 21h
				ret
					czytaj_trojki:
				xor dx,dx
				mov bx,wskaznik ;adres pierwszego znaku do bx
				mov cx,3
				mov ax,3F00h ;potrzebuje 3 parametry oraz miejsce do zapisu chara (trójki[] - adres 0 w ds), czyta z bx,
					     ;w cx ile ma czytać charów i o ile przesunąć wskaźnik
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
				sub cl,2Fh ;odejmujemy 29h żeby uzyskać decymalną, nie 30h żeby był wyższy dzwięk
				shr ax,cl ;dzielimy pierwszą wartość przez drugą
				xor cx,cx
				out 42h,al ;wysyłamy wartośc al do portu 42h
				mov al,ah ;ah do al żeby wysłać drugą część liczby
				out 42h,al ;wysyłamy drugą część liczby do portu 42h
				in al,61h ;port 61h odpowiada za włączenie i wyłączenie głośnika, pobieramy wartość portu do al
				or al,00000011b ;włączamy, zmieniamy ostatnie dwa bity z 00 na 11
				out 61h,al ;odsyłamy
				mov cl,trojka[2] 
				sub cl,30h
				xor dx,dx
				mov ah,86h ;bezwarunkowe oczekiwanie przez liczbę mikrosekund z cx i dx
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

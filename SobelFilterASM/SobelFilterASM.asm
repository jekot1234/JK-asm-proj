;
;Projekt JA Filtr Sobela
;Algorytm do wyznaczania kraw�dzi w obrazie. Warto�� piksela wyznaczana jest na podstawie
;przemno�enia masek z pikselami s�siaduj�cymi i obliczenie pierwiastka sumy kwadrat�w 
;z sumy wynik�w otrzymanych z mno�enia ka�dej maski.
;10.02.2021
;Jeremi Kot, semestr V, SSI
;
.data
data QWORD ?
result QWORD ?
.const
mask_G1 DD -1, 0, 1, -2, 2, -1, 0, 1
mask_G2 DD -2, -1, 0, -1, 1, 0, 1, 2
mask_G3 DD 1, 2, 1, 0, 0, -1, -2, -1
mask_G4 DD 0, 1, 2, -1, 1, -2, -1, 0
.code
fnSobelFilter proc EXPORT 

; zapisywanie adres�w rejestr�w RBP,RBX, RDI,RSP, w celu zachowania sp�jno�ci pami�ci po wykonaniu procedury
push RSP 
push RBP 
push RBX
push RDI

;pobranie i zaiasnie argument�w
mov R11, qword ptr [RSP + 40]	;sci�gniecie ze stosu i zachowanie d�ugo�ci wiersza
mov qword ptr[data], RCX		;zachowanie adresu tablicy z danymi wej�ciowymi w pami�ci
mov qword ptr[result], RDX		;zachowanie adresu tablicy z danymi wyj�ciowymi w pami�ci

;ustawienie iteratora p�tli pikseli
mov R10, 1

;p�tla iteruj�ca po wierszach
loop_row:

	;oblicznie adresu w danych wej�ciowych
	mov RAX, R11				;pobranie d�ugo�ci wiersza
	mul R8						;wymno�enie przez iterator wierasza - wyznaczenia indeksu piksela
	add RAX, qword ptr[data]	;wyznaczenie adresu w tablicy danych wej�ciowych
	mov RBX, RAX				;zapisanie aktualnego adresu w RBX

	;p�tla iteruj�ca po pikselach w wierszu
	loop_pixel:		
		inc RBX						;inkrementacja adresu przetwarzanego piksela
		
		;�adowanie pikseli s�siaduj�cych z obecnie przetwarzanym
		mov R14, RBX				;przes�anie dresu przetwarzanego piksela do R14
		sub R14, R11				;odj�cie d�ugo�ci wiersza
		dec R14						;dekrementacja adresu piksela

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		;poni�sza cz�� kodu ma na celu dwie rzeczy - konwersj� z 8-bitowego na 32-bitowe
		;s�owo oraz za�adowanie dw�ch pikseli jednocze�nie na stos

		mov CL, byte ptr[R14]		;pobranie warto�ci piksela [0, 0] do CL						
		inc R14						;inkrementacja adresu piksela
		mov AL, byte ptr[R14]		;pobranie warto�ci piksela [0, 1] do AL
		rol RCX, 32					;przesuniecie warto�ci piksela [0, 0] do g�rnej cz�scie rejestru RCX - przesuni�cie w lewo o 32
		add RAX, RCX				;dodanie obu rejestr�w - g�rna cz�� RAX - piksel [0, 0], EAX - [0, 1]		
		push RAX					;wys�anie na stos
		
		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		inc R14						;inkrementacja adresu piksela
		mov CL, byte ptr[R14]		;pobranie warto�ci piksela [0, 2] do CL

		sub R14, 2					;zmiana adresu do odczytu dancyh wej�ciowych
		add R14, R11				;jeden wiersz dalej, dwa piksele wcze�niej

		mov AL, byte ptr[R14]		;pobranie warto�ci piksela [1, 0] do AL
		rol RCX, 32					;przesuniecie warto�ci piksela [0, 2] do g�rnej cz�scie rejestru RCX
		add RAX, RCX				;dodanie obu rejestr�w - g�rna cz�� RAX - piksel [0, 2], EAX - [1, 0]
		push RAX					;wys�anie na stos

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		add R14, 2					;dwukrotna inkrementacja adresu piksela - piksel [1, 1] jest pomijany, poniewa� zawsze jest mno�ony przez 0
		mov CL, byte ptr[R14]		;pobranie warto�ci piksela [1, 2] do CL
		sub R14, 2					;zmiana adresu do odczytu dancyh wej�ciowych
		add R14, R11				;jeden wiersz dalej, dwa piksele wcze�niej

		mov AL, byte ptr[R14]		;pobranie warto�ci piksela [2, 0] do AL
		rol RCX, 32					;przesuniecie warto�ci piksela [1, 2] do g�rnej cz�scie rejestru RCX
		add RAX, RCX				;dodanie obu rejestr�w - g�rna cz�� RAX - piksel [1, 2], EAX - [2, 0]
		push RAX								

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		inc R14						;inkrementacja adresu piksela
		mov CL, byte ptr[R14]		;pobranie warto�ci piksela [2, 1] do CL
		inc R14						;inkrementacja adresu piksela
		mov AL, byte ptr[R14]		;pobranie warto�ci piksela [2, 2] do AL
		rol RCX, 32					;przesuniecie warto�ci piksela [2, 1] do g�rnej cz�scie rejestru RCX
		add RAX, RCX				;dodanie obu rejestr�w - g�rna cz�� RAX - piksel [2, 1], EAX - [2, 2]
		push RAX					;wys�anie na stos

		;�adowanie danych masek do rejestr�w XMM

		movups XMM0, xmmword ptr[mask_G1]		;pobranie dolnej po�owy sta�ych odpowiadaj�cym masce G1 do rejestru XMM0 - 4 razy s�owo 32 bitowa liczba sta�oprzecinkowa
		movups XMM1, xmmword ptr[mask_G1 + 16]	;pobranie g�rnej po�owy sta�ych odpowiadaj�cym masce G1 do rejestru XMM1
		movups XMM2, xmmword ptr[mask_G2]		;pobranie dolnej po�owy sta�ych odpowiadaj�cym masce G2 do rejestru XMM2
		movups XMM3, xmmword ptr[mask_G2 + 16]	;pobranie g�rnej po�owy sta�ych odpowiadaj�cym masce G2 do rejestru XMM3
		movups XMM4, xmmword ptr[mask_G3]		;pobranie dolnej po�owy sta�ych odpowiadaj�cym masce G3 do rejestru XMM4
		movups XMM5, xmmword ptr[mask_G3 + 16]	;pobranie g�rnej po�owy sta�ych odpowiadaj�cym masce G3 do rejestru XMM5
		movups XMM6, xmmword ptr[mask_G4]		;pobranie dolnej po�owy sta�ych odpowiadaj�cym masce G4 do rejestru XMM6
		movups XMM7, xmmword ptr[mask_G4 + 16]	;pobranie g�rnej po�owy sta�ych odpowiadaj�cym masce G4 do rejestru XMM7
		
		;sciaganie ze stosu warto�ci pikseli do rejestr�w XMM - maski odpowiednio dostosowane do kolejki LIFO!

		movups XMM9, xmmword ptr[RSP]		;sci�gni�cie ze stosu dolnej po�owy warto�ci pikseli do rejestru XMM9
		add RSP, 16							;korekta wska�nika stosu - 16 bajt�w sci�gniete ze stosu
		movups XMM8, xmmword ptr[RSP]		;sci�gni�cie ze stosu dolnej po�owy warto�ci pikseli do rejestru XMM9
		add RSP, 16							;korekta wska�nika stosu - 16 bajt�w sci�gniete ze stosu

		;wektorowe mno�enie masek i warto�ci pikseli przy uzyciu rozkaz�w z roszerzenia SSE 4.1

		PMULLD XMM0, XMM8		;dolna po�owa maski G1 razy dolna po�owa pikseli
		PMULLD XMM1, XMM9		;g�ra po�owa maski G1 razy g�ra po�owa pikseli
		PMULLD XMM2, XMM8		;dolna po�owa maski G2 razy dolna po�owa pikseli
		PMULLD XMM3, XMM9		;g�ra po�owa maski G2 razy g�ra po�owa pikseli
		PMULLD XMM4, XMM8		;dolna po�owa maski G3 razy dolna po�owa pikseli
		PMULLD XMM5, XMM9		;g�ra po�owa maski G3 razy g�ra po�owa pikseli
		PMULLD XMM6, XMM8		;dolna po�owa maski G4 razy dolna po�owa pikseli
		PMULLD XMM7, XMM9		;g�ra po�owa maski G4 razy g�ra po�owa pikseli


		xor RCX, RCX			;zerowanie rejestru RCX - tutaj przechowywana bedzie suma kwadrat�w

		;wys�anie na stos wynik�w mno�enia maski G1

		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM0		;wys�anie na stos dolnej po�owy wyniku
		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM1		;wys�anie na stos g�rnej po�owy wyniku

		;sumowanie kolejnych wynik�w mno�enia z mask� G1

		xor EAX, EAX						;zerowanie rejestru EAX
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 2. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 3. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 4. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 5. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 6. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 7. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 			
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 8. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 					

		mul RAX								;kwadrat sumy wynik�w - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys�anie na stos wynik�w mno�enia maski G2

		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM2		;wys�anie na stos dolnej po�owy wyniku
		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM3		;wys�anie na stos g�rnej po�owy wyniku

		;sumowanie kolejnych wynik�w mno�enia z mask� G2

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 2. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 3. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 4. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 5. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 6. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 7. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 8. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 

		mul RAX								;kwadrat sumy wynik�w - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys�anie na stos wynik�w mno�enia maski G3

		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM4		;wys�anie na stos dolnej po�owy wyniku
		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM5		;wys�anie na stos g�rnej po�owy wyniku

		;sumowanie kolejnych wynik�w mno�enia z mask� G3

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 2. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 3. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 4. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 5. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 6. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 7. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 8. wyniku mno�enia i dodanie go do EAX
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 

		mul RAX								;kwadrat sumy wynik�w - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys�anie na stos wynik�w mno�enia maski G4

		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM6		;wys�anie na stos dolnej po�owy wyniku
		sub RSP, 16							;korekta wska�nika stosu - 16 bajt�w wys�ane na stos
		movups  xmmword ptr[RSP], XMM7		;wys�anie na stos g�rnej po�owy wyniku

		;sumowanie kolejnych wynik�w mno�enia z mask� G4

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci�gniecie ze stosu 1. wyniku mno�enia i dodanie go do EAX	
		add RSP, 4							;korekta wska�nika stosu - 4 bajty sci�gniete ze stosu 

		mul RAX								;kwadrat sumy wynik�w - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		push RCX							;wys�anie wyniku na stos

		;obliczanie pierwiastka sumy kwadrat�w wynik�w mno�enia przez maski

		xor RAX, RAX					;zerowanie rejestru RAX
		movsd XMM4, qword ptr[RSP]		;sci�gni�cie ze stosu wyniku do rejestru XMM4
		add RSP, 8						;korekta stosu - 8 bajt�w sci�gni�tych ze stosu
		
		VCVTQQ2PD XMM4, XMM4			;konwersja liczb sta�oprzecinkowych na zmiennoprzecinkowe (rozkaz AVX512)
		sqrtsd XMM4, XMM4				;obliczenie pierwiastka kwadratowego
		cvttsd2si  RCX, XMM4			;zamiana wyniku na liczb� zmiennoprzecinkow� i wys�anie do RCX

		cmp RCX, 255					;oor�wnanie z 255 w celu dokonania ewentualnej korekty
		jg correction_too_high			;je�li wi�ksze - korekta
		cmp RCX, 0						;por�wnanie z 0 w celu dokonania ewentualnej korekty
		jl correction_too_low			;je�li mniejsze - korekta
		jmp save						;je�li w zakresie skok do zapisu

		;korekta w razie przepe�nienia
		correction_too_high:			
		MOV RCX, 255					;korekta wyniku na warto�� 255
		jmp save						;skok do zapisu
		;korekrta w razie niedope�nienia
		correction_too_low:				;korekta wyniku na warto�� 0
		MOV RCX, 0

		;zapisanie wyniku

		save:
		;obliczenie adresu zapisu
		mov RAX, R8			;przes�anie do RAX indeksu wiersza
		mul R11				;przemno�enie indeksu wiersza przez d�ugo�� wiersza
		add RAX, R10		;dodanie indeksu piksela
		mov R15, 3			;za�adowanie 3 do R15
		mul R15				;przemno�enie indeksu w tablicy wej�ciowej razy 3 w celu otrzymania indeksu w tablicy wy�ciowej (pikselowi w tablicy wej�ciowej odpowiadaj� trzy bajty w tablicy wyj�ciowej-  po jednym na ka�dy kana�)
		
		add RAX, qword ptr [result] ;dodanie adresu pocz�tku talicy wynikowej

		mov byte ptr[RAX], CL		;przes�anie wyniku (kana� B)
		mov byte ptr[RAX + 1], CL	;przes�anie wyniku (kana� G)
		mov byte ptr[RAX + 2], CL	;przes�anie wyniku (kana� R)


		inc R10						;inkrementacja iteratora p�tli pikseli w wierszu

		cmp R10, R11				;warunek konca p�tli pikseli w wierszu
		je loop_pixel_end			;je�eli r�wne skok do instrukcji ko�ca p�tli
		jmp loop_pixel				;skok do pocz�tku p�tli
		loop_pixel_end:				;koniec wykonywania p�tli
			mov R10, 1				;ustawienie iteratora p�tli pikseli w wierszu na 1
	inc R8					;inkrementacja iteratora wierszy
	cmp R8, R9				;warunek konca p�tli wierszy
	je loop_end				;je�eli r�wne skok do instrukcji ko�ca p�tli
	jmp loop_row			;skok do pocz�tku p�tli
	loop_end:				;koniec p�tli po wierszach - zako�czenie procedury
		pop RDI			;przywr�cenie ze stosu warto�ci rejestru RDI
		pop RBX			;przywr�cenie ze stosu warto�ci rejestru RBX
		pop RBP			;przywr�cenie ze stosu warto�ci rejestru RBP
		pop RSP			;przywr�cenie ze stosu warto�ci rejestru RSP
		ret				;powr�t z procedury
fnSobelFilter endp	
end
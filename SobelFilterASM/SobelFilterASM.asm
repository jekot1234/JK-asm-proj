;
;Projekt JA Filtr Sobela
;Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
;przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów 
;z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
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

; zapisywanie adresów rejestrów RBP,RBX, RDI,RSP, w celu zachowania spójnoœci pamiêci po wykonaniu procedury
push RSP 
push RBP 
push RBX
push RDI

;pobranie i zaiasnie argumentów
mov R11, qword ptr [RSP + 40]	;sci¹gniecie ze stosu i zachowanie d³ugoœci wiersza
mov qword ptr[data], RCX		;zachowanie adresu tablicy z danymi wejœciowymi w pamiêci
mov qword ptr[result], RDX		;zachowanie adresu tablicy z danymi wyjœciowymi w pamiêci

;ustawienie iteratora pêtli pikseli
mov R10, 1

;pêtla iteruj¹ca po wierszach
loop_row:

	;oblicznie adresu w danych wejœciowych
	mov RAX, R11				;pobranie d³ugoœci wiersza
	mul R8						;wymno¿enie przez iterator wierasza - wyznaczenia indeksu piksela
	add RAX, qword ptr[data]	;wyznaczenie adresu w tablicy danych wejœciowych
	mov RBX, RAX				;zapisanie aktualnego adresu w RBX

	;pêtla iteruj¹ca po pikselach w wierszu
	loop_pixel:		
		inc RBX						;inkrementacja adresu przetwarzanego piksela
		
		;£adowanie pikseli s¹siaduj¹cych z obecnie przetwarzanym
		mov R14, RBX				;przes³anie dresu przetwarzanego piksela do R14
		sub R14, R11				;odjêcie d³ugoœci wiersza
		dec R14						;dekrementacja adresu piksela

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		;poni¿sza czêœæ kodu ma na celu dwie rzeczy - konwersjê z 8-bitowego na 32-bitowe
		;s³owo oraz za³adowanie dwóch pikseli jednoczeœnie na stos

		mov CL, byte ptr[R14]		;pobranie wartoœci piksela [0, 0] do CL						
		inc R14						;inkrementacja adresu piksela
		mov AL, byte ptr[R14]		;pobranie wartoœci piksela [0, 1] do AL
		rol RCX, 32					;przesuniecie wartoœci piksela [0, 0] do górnej czêscie rejestru RCX - przesuniêcie w lewo o 32
		add RAX, RCX				;dodanie obu rejestrów - górna czêœæ RAX - piksel [0, 0], EAX - [0, 1]		
		push RAX					;wys³anie na stos
		
		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		inc R14						;inkrementacja adresu piksela
		mov CL, byte ptr[R14]		;pobranie wartoœci piksela [0, 2] do CL

		sub R14, 2					;zmiana adresu do odczytu dancyh wejœciowych
		add R14, R11				;jeden wiersz dalej, dwa piksele wczeœniej

		mov AL, byte ptr[R14]		;pobranie wartoœci piksela [1, 0] do AL
		rol RCX, 32					;przesuniecie wartoœci piksela [0, 2] do górnej czêscie rejestru RCX
		add RAX, RCX				;dodanie obu rejestrów - górna czêœæ RAX - piksel [0, 2], EAX - [1, 0]
		push RAX					;wys³anie na stos

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		add R14, 2					;dwukrotna inkrementacja adresu piksela - piksel [1, 1] jest pomijany, poniewa¿ zawsze jest mno¿ony przez 0
		mov CL, byte ptr[R14]		;pobranie wartoœci piksela [1, 2] do CL
		sub R14, 2					;zmiana adresu do odczytu dancyh wejœciowych
		add R14, R11				;jeden wiersz dalej, dwa piksele wczeœniej

		mov AL, byte ptr[R14]		;pobranie wartoœci piksela [2, 0] do AL
		rol RCX, 32					;przesuniecie wartoœci piksela [1, 2] do górnej czêscie rejestru RCX
		add RAX, RCX				;dodanie obu rejestrów - górna czêœæ RAX - piksel [1, 2], EAX - [2, 0]
		push RAX								

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		inc R14						;inkrementacja adresu piksela
		mov CL, byte ptr[R14]		;pobranie wartoœci piksela [2, 1] do CL
		inc R14						;inkrementacja adresu piksela
		mov AL, byte ptr[R14]		;pobranie wartoœci piksela [2, 2] do AL
		rol RCX, 32					;przesuniecie wartoœci piksela [2, 1] do górnej czêscie rejestru RCX
		add RAX, RCX				;dodanie obu rejestrów - górna czêœæ RAX - piksel [2, 1], EAX - [2, 2]
		push RAX					;wys³anie na stos

		;³adowanie danych masek do rejestrów XMM

		movups XMM0, xmmword ptr[mask_G1]		;pobranie dolnej po³owy sta³ych odpowiadaj¹cym masce G1 do rejestru XMM0 - 4 razy s³owo 32 bitowa liczba sta³oprzecinkowa
		movups XMM1, xmmword ptr[mask_G1 + 16]	;pobranie górnej po³owy sta³ych odpowiadaj¹cym masce G1 do rejestru XMM1
		movups XMM2, xmmword ptr[mask_G2]		;pobranie dolnej po³owy sta³ych odpowiadaj¹cym masce G2 do rejestru XMM2
		movups XMM3, xmmword ptr[mask_G2 + 16]	;pobranie górnej po³owy sta³ych odpowiadaj¹cym masce G2 do rejestru XMM3
		movups XMM4, xmmword ptr[mask_G3]		;pobranie dolnej po³owy sta³ych odpowiadaj¹cym masce G3 do rejestru XMM4
		movups XMM5, xmmword ptr[mask_G3 + 16]	;pobranie górnej po³owy sta³ych odpowiadaj¹cym masce G3 do rejestru XMM5
		movups XMM6, xmmword ptr[mask_G4]		;pobranie dolnej po³owy sta³ych odpowiadaj¹cym masce G4 do rejestru XMM6
		movups XMM7, xmmword ptr[mask_G4 + 16]	;pobranie górnej po³owy sta³ych odpowiadaj¹cym masce G4 do rejestru XMM7
		
		;sciaganie ze stosu wartoœci pikseli do rejestrów XMM - maski odpowiednio dostosowane do kolejki LIFO!

		movups XMM9, xmmword ptr[RSP]		;sci¹gniêcie ze stosu dolnej po³owy wartoœci pikseli do rejestru XMM9
		add RSP, 16							;korekta wska¿nika stosu - 16 bajtów sci¹gniete ze stosu
		movups XMM8, xmmword ptr[RSP]		;sci¹gniêcie ze stosu dolnej po³owy wartoœci pikseli do rejestru XMM9
		add RSP, 16							;korekta wska¿nika stosu - 16 bajtów sci¹gniete ze stosu

		;wektorowe mno¿enie masek i wartoœci pikseli przy uzyciu rozkazów z roszerzenia SSE 4.1

		PMULLD XMM0, XMM8		;dolna po³owa maski G1 razy dolna po³owa pikseli
		PMULLD XMM1, XMM9		;góra po³owa maski G1 razy góra po³owa pikseli
		PMULLD XMM2, XMM8		;dolna po³owa maski G2 razy dolna po³owa pikseli
		PMULLD XMM3, XMM9		;góra po³owa maski G2 razy góra po³owa pikseli
		PMULLD XMM4, XMM8		;dolna po³owa maski G3 razy dolna po³owa pikseli
		PMULLD XMM5, XMM9		;góra po³owa maski G3 razy góra po³owa pikseli
		PMULLD XMM6, XMM8		;dolna po³owa maski G4 razy dolna po³owa pikseli
		PMULLD XMM7, XMM9		;góra po³owa maski G4 razy góra po³owa pikseli


		xor RCX, RCX			;zerowanie rejestru RCX - tutaj przechowywana bedzie suma kwadratów

		;wys³anie na stos wyników mno¿enia maski G1

		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM0		;wys³anie na stos dolnej po³owy wyniku
		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM1		;wys³anie na stos górnej po³owy wyniku

		;sumowanie kolejnych wyników mno¿enia z mask¹ G1

		xor EAX, EAX						;zerowanie rejestru EAX
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 2. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 3. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 4. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 5. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 6. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 7. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 			
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 8. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 					

		mul RAX								;kwadrat sumy wyników - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys³anie na stos wyników mno¿enia maski G2

		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM2		;wys³anie na stos dolnej po³owy wyniku
		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM3		;wys³anie na stos górnej po³owy wyniku

		;sumowanie kolejnych wyników mno¿enia z mask¹ G2

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 2. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 3. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 4. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 5. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 6. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 7. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 8. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 

		mul RAX								;kwadrat sumy wyników - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys³anie na stos wyników mno¿enia maski G3

		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM4		;wys³anie na stos dolnej po³owy wyniku
		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM5		;wys³anie na stos górnej po³owy wyniku

		;sumowanie kolejnych wyników mno¿enia z mask¹ G3

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 2. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 3. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 4. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 5. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 6. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 7. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 8. wyniku mno¿enia i dodanie go do EAX
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 

		mul RAX								;kwadrat sumy wyników - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys³anie na stos wyników mno¿enia maski G4

		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM6		;wys³anie na stos dolnej po³owy wyniku
		sub RSP, 16							;korekta wskaŸnika stosu - 16 bajtów wys³ane na stos
		movups  xmmword ptr[RSP], XMM7		;wys³anie na stos górnej po³owy wyniku

		;sumowanie kolejnych wyników mno¿enia z mask¹ G4

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 
		add EAX, dword ptr[RSP]				;sci¹gniecie ze stosu 1. wyniku mno¿enia i dodanie go do EAX	
		add RSP, 4							;korekta wska¿nika stosu - 4 bajty sci¹gniete ze stosu 

		mul RAX								;kwadrat sumy wyników - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		push RCX							;wys³anie wyniku na stos

		;obliczanie pierwiastka sumy kwadratów wyników mno¿enia przez maski

		xor RAX, RAX					;zerowanie rejestru RAX
		movsd XMM4, qword ptr[RSP]		;sci¹gniêcie ze stosu wyniku do rejestru XMM4
		add RSP, 8						;korekta stosu - 8 bajtów sci¹gniêtych ze stosu
		
		VCVTQQ2PD XMM4, XMM4			;konwersja liczb sta³oprzecinkowych na zmiennoprzecinkowe (rozkaz AVX512)
		sqrtsd XMM4, XMM4				;obliczenie pierwiastka kwadratowego
		cvttsd2si  RCX, XMM4			;zamiana wyniku na liczbê zmiennoprzecinkow¹ i wys³anie do RCX

		cmp RCX, 255					;oorównanie z 255 w celu dokonania ewentualnej korekty
		jg correction_too_high			;jeœli wiêksze - korekta
		cmp RCX, 0						;porównanie z 0 w celu dokonania ewentualnej korekty
		jl correction_too_low			;jeœli mniejsze - korekta
		jmp save						;jeœli w zakresie skok do zapisu

		;korekta w razie przepe³nienia
		correction_too_high:			
		MOV RCX, 255					;korekta wyniku na wartoœæ 255
		jmp save						;skok do zapisu
		;korekrta w razie niedope³nienia
		correction_too_low:				;korekta wyniku na wartoœæ 0
		MOV RCX, 0

		;zapisanie wyniku

		save:
		;obliczenie adresu zapisu
		mov RAX, R8			;przes³anie do RAX indeksu wiersza
		mul R11				;przemno¿enie indeksu wiersza przez d³ugoœæ wiersza
		add RAX, R10		;dodanie indeksu piksela
		mov R15, 3			;za³adowanie 3 do R15
		mul R15				;przemno¿enie indeksu w tablicy wejœciowej razy 3 w celu otrzymania indeksu w tablicy wyœciowej (pikselowi w tablicy wejœciowej odpowiadaj¹ trzy bajty w tablicy wyjœciowej-  po jednym na ka¿dy kana³)
		
		add RAX, qword ptr [result] ;dodanie adresu pocz¹tku talicy wynikowej

		mov byte ptr[RAX], CL		;przes³anie wyniku (kana³ B)
		mov byte ptr[RAX + 1], CL	;przes³anie wyniku (kana³ G)
		mov byte ptr[RAX + 2], CL	;przes³anie wyniku (kana³ R)


		inc R10						;inkrementacja iteratora pêtli pikseli w wierszu

		cmp R10, R11				;warunek konca pêtli pikseli w wierszu
		je loop_pixel_end			;je¿eli równe skok do instrukcji koñca pêtli
		jmp loop_pixel				;skok do pocz¹tku pêtli
		loop_pixel_end:				;koniec wykonywania pêtli
			mov R10, 1				;ustawienie iteratora pêtli pikseli w wierszu na 1
	inc R8					;inkrementacja iteratora wierszy
	cmp R8, R9				;warunek konca pêtli wierszy
	je loop_end				;je¿eli równe skok do instrukcji koñca pêtli
	jmp loop_row			;skok do pocz¹tku pêtli
	loop_end:				;koniec pêtli po wierszach - zakoñczenie procedury
		pop RDI			;przywrócenie ze stosu wartoœci rejestru RDI
		pop RBX			;przywrócenie ze stosu wartoœci rejestru RBX
		pop RBP			;przywrócenie ze stosu wartoœci rejestru RBP
		pop RSP			;przywrócenie ze stosu wartoœci rejestru RSP
		ret				;powrót z procedury
fnSobelFilter endp	
end
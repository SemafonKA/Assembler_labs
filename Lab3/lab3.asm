.386
.MODEL FLAT
OPTION CASEMAP: NONE

.DATA								; сегмент данных
	; ѕеременные дл€ @DublStr
	idx			dword ?				; »ндекс дл€ цикла
	freeSymbols dword ?				; „исло оставшихс€ свободных символов в строке вывода

.CODE								; сегмент кода 

; fastcall procedure @DublStr@20
; параметры: 
; inpStrPtr  - указатель на начало входной строки (в регистре ecx)
; inpStrSize - размер вход€щей строке, dword (в регистре edx)
; outStrPtr  - указатель на начало выходной строки (в стеке)
; outStrSizePtr - указатель на размер выходной строки (в стеке),
;				изначально должен лежать максимальный размер строки (вместе с символом конца)
; repeats	 - количество повторов входной строки в выходной, dword (в стеке)
@DublStr@20 PROC
	PUSH ebp
	MOV ebp, esp
	add ebp, 8

	outStrPtr equ [ebp]
	outStrSizePtr equ [ebp+4]
	repeats equ [ebp+8]

	push ecx
	mov eax, outStrSizePtr
	mov ecx, [eax]
	mov edi, outStrPtr
	mov eax, 0
	rep stosb				; ѕредварительно полностью очищаем выходную строку (потому что можем)
	pop ecx

	mov eax, outStrSizePtr
	mov ebx, [eax]
	mov freeSymbols, ebx
	sub freeSymbols, 1		; –езервируем один символ под символ конца строки
	mov ebx, 0
	mov [eax], ebx			; «аписываем длину результирующей строки как 0
	
	mov eax, repeats
	push edx				; «апоминаем длину входной строки (чтобы не затереть при умножении)
	mul edx					; ”множаем число повторов на длину первой строки
	pop edx					; ¬озвращаем длину входной строки
	mov idx, eax

	mov edi, outStrPtr		; записываем в дестинейшн указатель на конечную строку
	.while idx
		; ≈сли писать некуда, то сразу ливаем с цикла
		.if freeSymbols == 0
			.break
		.endif

		push ecx			; «апоминаем указатель на начало входной строки
		mov esi, ecx		; «аписываем в сурс указатель на входную строку
		
		; ≈сли символов в строке осталось меньше, чем надо скопировать, то 
		; будем копировать столько сколько осталось
		.if freeSymbols < edx
			mov ecx, freeSymbols
		.else
			mov ecx, edx
		.endif
		sub freeSymbols, ecx
		mov eax, outStrSizePtr
		add [eax], ecx
		sub idx, ecx
		rep movsb			; копируем в новую строку старую строку (ну или часть старой строки)
		pop ecx					
	.endw

	POP EBP
	RET 12			; “.к. в стеке лежит всего 3 аргумента по 4 байта, чистим 12 байт на выходе.
@DublStr@20 ENDP

END; завершение описани€ модул€

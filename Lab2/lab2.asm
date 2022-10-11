.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

; прототипы внешних функций (процедур) описываются директивой EXTERN, 
; после знака @ указывается общая длина передаваемых параметров,
; после двоеточия указывается тип внешнего объекта – процедура
EXTERN  GetStdHandle@4: PROC		; Функция получения дескрипторов ввода (-10) и вывода (-11) данных в консоль
EXTERN  WriteConsoleA@20: PROC
EXTERN  ReadConsoleA@20: PROC
EXTERN  lstrlenA@4: PROC			; функция определения длины строки
EXTERN  ExitProcess@4: PROC			; функция выхода из программы

.CONST								; Сегмент констант
	const_base	dword 16

.DATA								; сегмент данных
	; Переменные для DublStr
	idx			dword ?				; Индекс для цикла
	freeSymbols dword ?				; Число оставшихся свободных символов в строке вывода

	; Переменные для stoi
	chr			byte ?				; Считанный символ

	; Переменные для основной программы
	din			dword ?					; Дескриптор ввода
	dout		dword ?					; Дескриптор вывода
	
	inpRequest1		byte  "Input str to duplicate (shorter than 256 symbols): ", 0
	inpRequest1_len dword ?				

	inpRequest2		byte  "Input count of repeats: ", 0
	inpRequest2_len dword ?	
	
	outPrint1		byte  "Result string: ", 0
	outPrint1_len	dword ?

	outNewLineStr	  byte  13, 10, 0
	outNewLineStr_len dword 2

	inputStr	byte 256 dup (?)
	inputStrLen dword ?

	outStr		byte 512 dup (?)
	outStrLen	dword 512

	inputRepeatsStr		byte 15 dup (?)
	inputRepeatsStrLen	dword ?
	numRepeats			dword ?
.CODE								; сегмент кода 

MAIN PROC; начало описания процедуры с именем MAIN
	push -10		; Получаем дескриптор ввода
	CALL GetStdHandle@4
	mov din, eax

	push -11		; Получаем дескриптор вывода
	CALL GetStdHandle@4
	mov dout, eax

; Выводим первый текст и считываем начальную строку
	push offset inpRequest1
	call lstrlenA@4	; Получаем длину строки
	mov inpRequest1_len, eax

	push 0
	push 0
	push inpRequest1_len
	push offset inpRequest1
	push dout
	CALL WriteConsoleA@20	; Выводим текст в консоль

	push 0
	push offset inputStrLen
	push 256
	push offset inputStr
	push din
	call ReadConsoleA@20	; Считываем строку с консоли

	mov eax, offset inputStr ; убираем из строки лишние символы переноса и возврата каретки
	add eax, inputStrLen
	mov bl, 0
	mov [eax-2], bl
	sub inputStrLen, 2

; Выводим второй текст и считываем число повторов
	push offset inpRequest2
	call lstrlenA@4	; Получаем длину строки
	mov inpRequest2_len, eax

	push 0
	push 0
	push inpRequest2_len
	push offset inpRequest2
	push dout
	CALL WriteConsoleA@20	; Выводим текст в консоль

	push 0
	push offset inputRepeatsStrLen
	push 15
	push offset inputRepeatsStr
	push din
	call ReadConsoleA@20	; Считываем строку с консоли

	mov eax, offset inputRepeatsStr ; убираем из строки лишние символы переноса и возврата каретки
	add eax, inputRepeatsStrLen
	mov bl, 0
	mov [eax-2], bl
	sub inputRepeatsStrLen, 2

; Переводим строку в число
	push inputRepeatsStrLen
	push offset inputRepeatsStr
	call Stoi@8				; Переводим строку в число
	mov numRepeats, eax	

; Получаем итоговую строку
	push numRepeats
	push offset outStrLen
	push offset outStr
	mov edx, inputStrLen
	mov ecx, offset inputStr
	call DublStr@20			; Получаем итоговую строку

; Выводим текст и итоговую строку
	push offset outPrint1
	call lstrlenA@4	; Получаем длину строки
	mov outPrint1_len, eax

	push 0
	push 0
	push outPrint1_len
	push offset outPrint1
	push dout
	CALL WriteConsoleA@20	; Выводим текст в консоль

	push 0
	push 0
	push outStrLen
	push offset outStr
	push dout
	CALL WriteConsoleA@20	; Выводим получившуюся строку в консоль

	push 0
	push 0
	push outNewLineStr_len
	push offset outNewLineStr
	push dout
	CALL WriteConsoleA@20	; Выводим перенос строки в консоль

	push 0
	call ExitProcess@4
MAIN ENDP; завершение описания процедуры с именем MAIN

; fastcall procedure DublStr@20
; параметры: 
; inpStrPtr  - указатель на начало входной строки (в регистре ecx)
; inpStrSize - размер входящей строке, dword (в регистре edx)
; outStrPtr  - указатель на начало выходной строки (в стеке)
; outStrSizePtr - указатель на размер выходной строки (в стеке),
;				изначально должен лежать максимальный размер строки (вместе с символом конца)
; repeats	 - количество повторов входной строки в выходной, dword (в стеке)
DublStr@20 PROC
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
	rep stosb				; Предварительно полностью очищаем выходную строку (потому что можем)
	pop ecx

	mov eax, outStrSizePtr
	mov ebx, [eax]
	mov freeSymbols, ebx
	sub freeSymbols, 1		; Резервируем один символ под символ конца строки
	mov ebx, 0
	mov [eax], ebx			; Записываем длину результирующей строки как 0
	
	mov eax, repeats
	push edx				; Запоминаем длину входной строки (чтобы не затереть при умножении)
	mul edx					; Умножаем число повторов на длину первой строки
	pop edx					; Возвращаем длину входной строки
	mov idx, eax

	mov edi, outStrPtr		; записываем в дестинейшн указатель на конечную строку
	.while idx
		; Если писать некуда, то сразу ливаем с цикла
		.if freeSymbols == 0
			.break
		.endif

		push ecx			; Запоминаем указатель на начало входной строки
		mov esi, ecx		; Записываем в сурс указатель на входную строку
		
		; Если символов в строке осталось меньше, чем надо скопировать, то 
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
	RET 12			; Т.к. в стеке лежит всего 3 аргумента по 4 байта, чистим 12 байт на выходе.
DublStr@20 ENDP

; Процедура перевода строки в беззнаковое целое
; Параметры:
; strPtr - Указатель на строку с числом
; strLen - длина строки
; Возврат: 
; eax - полученное значение числа
Stoi@8 proc
	push ebp			; Сохраняем прежнее значение бегунка по стеку данных (чтобы в конце его вернуть)
	mov ebp, esp		; Записываем в бегунок указатель на вершину стека данных
	add ebp, 8			; Первые 4 байта в стеке - указатель прежнего бегунка, вторые 4 байта - указатель для возврата с процедуры, поэтому их скипнем
	strPtr equ [ebp]	; Обозначаем первый элемент стека как strPtr
	strLen equ [ebp+4]	; Обозначаем второй элемент стека как strLen

	xor eax, eax
	xor ecx, ecx
	mov ecx, strLen
	.while ecx
		mov ebx, strPtr	; Получаем из текущего символа цифру
		mov dl, [ebx]
		mov chr, dl
		sub chr, '0'
		.if chr > 9		; Если символ не цифра, пишем ноль и так и возвращаем
			mov eax, 0
			.break
		.endif
		mov ebx, 10
		mul ebx			; умножаем прошлые результаты из eax на 10
		xor edx, edx
		mov dl, chr
		add eax, edx	; добавляем текущую полученную цифру

		mov edx, 1
		add strPtr, edx
		sub ecx, edx
	.endw

	pop ebp			; Возвращаем указатель бегунка на место
	ret 8			; Завершаем прогу, сдвигая стек на 8 байт (2 параметра)
Stoi@8 endp

END MAIN; завершение описания модуля с указанием первой выполняемой процедуры

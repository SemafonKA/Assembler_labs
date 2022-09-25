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
EXTERN  CharToOemA@8: PROC			; Переводит char символы в oem символы
EXTERN  ExitProcess@4: PROC			; функция выхода из программы

; Макрос превращения строки в oem
GetOemStr macro strPtr
	mov eax, strPtr
	push eax
	push eax
	call CharToOemA@8
endm

.CONST								; Сегмент констант
	const_base	dword 16	
.DATA								; сегмент данных
	; Переменные для процедуры HexToDecimal@12
	intPtr		dword 0					; Указатель на целое число в функции
	strPtr		dword 0					; Указатель на начало функции
	k			byte  0					; Переменная под буквы
	errStr		byte  "Введено неверное число. Программа завершается.", 13, 10, 0
	errStrLen	dword ?					; Переменная для количества символов в строке errStr

	; Переменные для процедуры DecimalToStr@16
	num			sdword 0				; Переданное число для преобразования
	bufPtr		dword 0					; Указатель на буфер
	bufSize		dword 0					; Размер буфера
	factSizePtr	dword 0					; Указатель на фактический размер числа в строке

	; Переменные для основной программы
	din			dword ?					; Дескриптор ввода
	dout		dword ?					; Дескриптор вывода

	signFlag	byte  0					; Флаг для отрицательных чисел
	lens		dword ?					; Переменная для количества выведенных символов
	impStr		byte  "Введите 16-ричное число: ", 13, 10, 0
	impStrLen	dword ?					; Переменная для количества символов в строке impStr
	outStr		byte  "Полученное число: ", 0
	outStrLen   dword ?
	buf			byte 200 dup (?)		; Буфер для ввода, размер 200 символов
	bufLen		dword 200

	firstNum	sdword 0				; Переменная с первым введённым числом
	secondNum	sdword 0				; Переменная со вторым введённым числом
.CODE									; сегмент кода 
MAIN PROC; начало описания процедуры с именем MAIN
	push -10		; Получаем дескриптор ввода
	CALL GetStdHandle@4
	mov din, eax

	push -11		; Получаем дескриптор вывода
	CALL GetStdHandle@4
	mov dout, eax

	GetOemStr offset impStr

	push offset impStr
	call lstrlenA@4	; Получаем длину строки impStr
	mov impStrLen, eax

	; Вводим первое число
;#region 
	PUSH 0					; Какой-то ещё параметр
	PUSH OFFSET lens		; Указатель на число, куда запишется фактическое число выведенных символов
	PUSH impStrLen			; Длина строки
	PUSH OFFSET impStr		; Указатель на строку
	PUSH dout				; Дескриптор вывода в консоль
	CALL WriteConsoleA@20	; Выводим текст в консоль

	push 0					; Какой-то ещё параметр
	push offset lens		; Указатель на фактическую длину считанных параметров
	push 200				; Размер буфера
	push offset buf			; Указатель на буфер
	push din				; Дескриптор ввода
	call ReadConsoleA@20	; Считываем число с консоли

	sub lens, 2				; Убираем из строки с числом символы переноса и сброса каретки
	push offset firstNum
	push lens
	push offset buf
	call HexToDecimal@12

	cmp eax, -1				; Если после работы функции в eax записало -1, то прыгаем на конец программы (ошибка ввода)
	je ExitProc
;#endregion

	; Вводим второе число
;#region
	PUSH 0					; Какой-то ещё параметр
	PUSH OFFSET lens		; Указатель на число, куда запишется фактическое число выведенных символов
	PUSH impStrLen			; Длина строки
	PUSH OFFSET impStr		; Указатель на строку
	PUSH dout				; Дескриптор вывода в консоль
	CALL WriteConsoleA@20	; Выводим текст в консоль

	push 0					; Какой-то ещё параметр
	push offset lens		; Указатель на фактическую длину считанных параметров
	push 200				; Размер буфера
	push offset buf			; Указатель на буфер
	push din				; Дескриптор ввода
	call ReadConsoleA@20	; Считываем число с консоли

	sub lens, 2				; Убираем из строки с числом символы переноса и сброса каретки
	push offset secondNum
	push lens
	push offset buf
	call HexToDecimal@12

	cmp eax, -1				; Если после работы функции в eax записало -1, то прыгаем на конец программы (ошибка ввода)
	je ExitProc
;#endregion
	
	mov eax, firstNum
	sub eax, secondNum
	mov firstNum, eax		; Вычитаем второе число из первого, сохраняем в первом

	push firstNum
	push offset buf
	push 200
	push offset bufLen
	CALL DecimalToStr@16	; Переводим число в строку

	GetOemStr offset outStr
	push offset outStr
	call lstrlenA@4			; Получаем длину строки outStr
	mov outStrLen, eax

	PUSH 0					
	PUSH OFFSET lens		
	PUSH outStrLen			
	PUSH OFFSET outStr		
	PUSH dout				
	CALL WriteConsoleA@20	; Выводим текст outStr в консоль

	PUSH 0					
	PUSH OFFSET lens		
	PUSH bufLen				
	PUSH OFFSET buf			
	PUSH dout				
	CALL WriteConsoleA@20	; Выводим число в консоль

ExitProc:

	push 0
	call ExitProcess@4
MAIN ENDP; завершение описания процедуры с именем MAIN


; Процедура перевода десятичного числа в строку
; На вход число, указатель на буфер, длина буфера, указатель на фактическую длину числа
DecimalToStr@16 proc
	push ebp		; Сохраняем прежнее значение бегунка по стеку данных (чтобы в конце его вернуть)
	mov ebp, esp	; Записываем в бегунок указатель на вершину стека данных
	add ebp, 8		; Первые 4 байта в стеке - указатель прежнего бегунка, вторые 4 байта - указатель для возврата с процедуры, поэтому их скипнем

	mov eax, [ebp]	; Извлекаем указатель на фактическую длину числа
	mov factSizePtr, eax
	mov eax, [ebp+4]; Извлекаем длину буфера
	mov bufSize, eax
	mov eax, [ebp+8]; Извлекаем указатель на буфер
	mov bufPtr, eax
	mov eax, [ebp+12]; Извлекаем число
	mov num, eax

	mov eax, factSizePtr	; Зануляем переменную фактического размера
	mov ebx, 0
	mov [eax], ebx


	; Если число отрицательное, то
	.if num < 0	
		mov signFlag, 1
		mov eax, bufPtr
		mov bl, '-'
		mov [eax], bl			; Записываем в буфер минус
		mov eax, factSizePtr
		mov ebx, 1
		add [eax], ebx			; Добавляем единицу в фактический размер строки
		neg num
	.else
		mov signFlag, 0
	.endif

	; Перебор всего числа, запись цифр числа в стек
	.while num
		xor edx, edx		; При делении на 4 байта, фактически делим edx&eax на что-то, потому edx занулим
		mov eax, num		; Записываем в eax текущий num для его деления
		mov ebx, 10			; Записываем делитель в ebx
		div ebx				; Делим eax на ebx. Результат деления в eax, остаток в edx
		mov num, eax		; Записываем результат деления в num
		add dl, '0'			; Добавляем в edx символ нуля, чтобы получить нужный символ в дальнейшем
		push edx			; Пушим в стек 
		
		mov eax, factSizePtr
		mov edx, 1
		add [eax], edx		; Добавляем единицу в фактический размер строки
	.endw

	; Извлекаем цифры из стека, добавляем к ним '0', пишем в буфер
	mov eax, factSizePtr
	mov ecx, [eax]			; Записываем в ecx фактическое количество символов

	.if signFlag == 1		; Если был записан минус, то вычитаем один символ (т.к. его в стеке не будет)
		dec ecx
	.endif

	.while ecx
		pop eax				; Записываем в eax очередной символ
		mov ebx, factSizePtr
		mov edx, [ebx]
		sub edx, ecx		; Смотрим текущее количество записанных символов
		.if edx <= bufSize	; Если буфер не переполнен, то
			mov ebx, bufPtr
			mov [ebx + edx], al	; Записываем символ в позицию
		.endif
		dec ecx
	.endw

	pop ebp			; Возвращаем прежнее значение бегунка
	ret	16			; Выходим из процедуры, при этом говорим напрямую, что после выхода нужно сдвинуть указатель на 4 элемента:
DecimalToStr@16 endp

; Процедура преобразования строки с 16-ричным числом в 10-ричное 4-байтное
; Принимает на вход указатель на строку с 16-ричным числом, размер строки (4 байта) и указатель на переменную целую 4 байтную (куда запишется число)
; Если произошла ошибка, то в eax записывается число -1
HexToDecimal@12 proc	; Начало процедуры 
	push ebp		; Сохраняем прежнее значение бегунка по стеку данных (чтобы в конце его вернуть)
	mov ebp, esp	; Записываем в бегунок указатель на вершину стека данных
	add ebp, 8		; Первые 4 байта в стеке - указатель прежнего бегунка, вторые 4 байта - указатель для возврата с процедуры, поэтому их скипнем

	mov eax, [ebp+8]
	mov intPtr, eax		; Записали указатель на 4-байтное целое
	mov eax, [ebp+4]
	mov ecx, eax		; Записали длину строки, ECX - итератор цикла
	mov eax, [ebp]
	mov strPtr, eax		; Записали указатель на начало строки

	mov eax, intPtr
	xor ebx, ebx
	mov [eax], ebx		; Записали по адресу intPtr значение ноль
	mov signFlag, 0		; Зануляем signFlag

	mov eax, strPtr
	mov bh, [eax]
	mov k, bh			; записываем текущую букву в k
	cmp k, '-'			; Сравниваем с минусом
	jne loopBegin1
	mov signFlag, 1

loopBegin1: 			; Метка начала цикла
		mov eax, strPtr
		mov bh, [eax]
		mov k, bh		; записываем текущую букву в k
		sub k, '0'

		cmp k, 9			; Если k меньше или равно 9, то
		jbe getToNum		; Переход к метке getToNum

		mov bh, [eax]
		mov k, bh
		sub k, 'A'

		cmp k, 5
		jbe add10		; Если k меньше или равно 5, то всё ок
		
		; Если введено что-то неправильное, то выдаём ошибку
		call PrintErr
		jmp HexToDecExit
	
	add10:
	
		add k, 10

	getToNum:
		
		mov ebx, intPtr
		mov eax, [ebx]
		mul const_base
		mov [ebx], eax
		xor eax, eax
		mov al, k
		add [ebx], eax

		add strPtr, 1
	loop loopBegin1

	cmp signFlag, 1		; Если число отрицательное, то
	jne HexToDecExit
	mov ebx, intPtr
	mov eax, [ebx]
	mov ecx, -1
	mul ecx
	mov [ebx], eax

HexToDecExit:
	pop ebp			; Возвращаем прежнее значение бегунка
	ret	12			; Выходим из процедуры, при этом говорим напрямую, что после выхода нужно сдвинуть указатель на 3 элемента:
					; 4 байта - указатель строки, 4 байта - указатель на длину строки, 4 байта - на число
HexToDecimal@12 endp

PrintErr proc
	GetOemStr offset errStr

	push offset errStr
	call lstrlenA@4		; Получаем длину строки errStr
	mov errStrLen, eax

	PUSH 0					; Какой-то ещё параметр
	PUSH OFFSET lens		; Указатель на число, куда запишется фактическое число выведенных символов
	PUSH errStrLen			; Длина строки
	PUSH OFFSET errStr		; Указатель на строку
	PUSH dout				; Дескриптор вывода в консоль
	CALL WriteConsoleA@20	; Выводим текст в консоль

	mov eax, -1
	ret
PrintErr endp

END MAIN; завершение описания модуля с указанием первой выполняемой процедуры

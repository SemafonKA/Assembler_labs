.386
.MODEL FLAT
OPTION CASEMAP: NONE
.const
	c0 real4 0.0
	c1 real4 1.0
	c2 real4 2.0
.DATA								; сегмент данных
	num real4 0.0
	regBackup word ?
.CODE								; сегмент кода 

; cdecl _Compute procedure
; Входные данные: 
; real4 x - координата, в которой надо вычислить значение функции
; real4* y - указатель на значение функции
; Возврат:
; eax - Код ошибки (0 - всё ок, 1 - всё плохо)
_Compute proc
	PUSH ebp
	MOV ebp, esp
	add ebp, 8

	; Обнуляем регистры сопроцессора
	FINIT

	; запоминаем прошлое состояние сопроцессора (регистр cwr)
	fstcw regBackup
	mov ax, regBackup
	push eax
	
	mov eax, [ebp]		; eax = x
	mov num, eax		; num = x
	fld num				; st(0) = x
	fsub c1				; st(0) = x - 1
	fld c0				; st(0) = 0, st(1) = x - 1
	fcomip st(0), st(1)	; проверка на ноль, st(0) == 0 ? ZF = 1 : ZF = 0. st(0) = x - 1
	je ComputeError		; Если ZF = 1, то идём к ComputeError
	fld num				; st(0) = x, st(1) = x - 1
	fld c2				; st(0) = 2.0, st(1) = x, st(2) = x - 1
	fmulp st(1), st		; st(0) = 2.0 * x, st(1) = x - 1
	fld num				; st(0) = x, st(1) = 2.0 * x, st(2) = x - 1
	fmulp st(1), st		; st(0) = 2.0 * x * x, st(1) = x - 1
	fld num				; st(0) = x, st(1) = 2.0 * x * x, st(2) = x - 1
	faddp st(1), st		; st(0) = x + 2.0 * x * x, st(1) = x - 1
	fdivrp st(1), st	; st(0) = (x + 2.0 * x * x) / (x - 1)

	mov eax, [ebp + 4]	; eax = *y
	fstp num			; num = st(0), st(0) = void
	mov ebx, num
	mov [eax], ebx		; y = num

	mov eax, 0			; exit code = 0
	jmp ComputeExit		; переходим в конец программы

ComputeError:
	fstp num			; num = st(0) = 0, st(0) = void
	mov eax, 1			; exit code = 1

ComputeExit:
	; возвращаем прошлое состояние сопроцессора (регистр cwr)
	pop ebx
	mov regBackup, bx
	fldcw regBackup

	pop ebp
	ret
_Compute endp

END ; завершение описания модуля с указанием первой выполняемой процедуры
.386
.MODEL FLAT
OPTION CASEMAP: NONE
.const
	c1 real4 1.0
	c2 real4 2.0
.DATA								; сегмент данных
	num real4 0.0
	regBackup word ?
.CODE								; сегмент кода 

; cdecl _Compute procedure
; Входные данные: 
; x - координата, в которой надо вычислить значение функции (real4)
; Возврат:
; результат вычислений функции, real8, в ячейке st(0)
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
	fld num				; st(0) = x, st(1) = x - 1
	fld c2				; st(0) = 2.0, st(1) = x, st(2) = x - 1
	fmulp st(1), st		; st(0) = 2.0 * x, st(1) = x - 1
	fld num				; st(0) = x, st(1) = 2.0 * x, st(2) = x - 1
	fmulp st(1), st		; st(0) = 2.0 * x * x, st(1) = x - 1
	fld num				; st(0) = x, st(1) = 2.0 * x * x, st(2) = x - 1
	faddp st(1), st		; st(0) = x + 2.0 * x * x, st(1) = x - 1
	fdivrp st(1), st	; st(0) = (x + 2.0 * x * x) / (x - 1)

	; возвращаем прошлое состояние сопроцессора (регистр cwr)
	pop eax
	mov regBackup, ax
	fldcw regBackup

	pop ebp
	ret
_Compute endp

END ; завершение описания модуля с указанием первой выполняемой процедуры
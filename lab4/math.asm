.386
.MODEL FLAT
OPTION CASEMAP: NONE
.const
	c0 real4 0.0
	c1 real4 1.0
	c2 real4 2.0
.DATA								; ������� ������
	num real4 0.0
	regBackup word ?
.CODE								; ������� ���� 

; cdecl _Compute procedure
; ������� ������: 
; real4 x - ����������, � ������� ���� ��������� �������� �������
; real4* y - ��������� �� �������� �������
; �������:
; eax - ��� ������ (0 - �� ��, 1 - �� �����)
_Compute proc
	PUSH ebp
	MOV ebp, esp
	add ebp, 8

	; �������� �������� ������������
	FINIT

	; ���������� ������� ��������� ������������ (������� cwr)
	fstcw regBackup
	mov ax, regBackup
	push eax
	
	mov eax, [ebp]		; eax = x
	mov num, eax		; num = x
	fld num				; st(0) = x
	fsub c1				; st(0) = x - 1
	fld c0				; st(0) = 0, st(1) = x - 1
	fcomip st(0), st(1)	; �������� �� ����, st(0) == 0 ? ZF = 1 : ZF = 0. st(0) = x - 1
	je ComputeError		; ���� ZF = 1, �� ��� � ComputeError
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
	jmp ComputeExit		; ��������� � ����� ���������

ComputeError:
	fstp num			; num = st(0) = 0, st(0) = void
	mov eax, 1			; exit code = 1

ComputeExit:
	; ���������� ������� ��������� ������������ (������� cwr)
	pop ebx
	mov regBackup, bx
	fldcw regBackup

	pop ebp
	ret
_Compute endp

END ; ���������� �������� ������ � ��������� ������ ����������� ���������
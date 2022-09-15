.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE
; ��������� ������� ������� (��������) ����������� ���������� EXTERN, 
; ����� ����� @ ����������� ����� ����� ������������ ����������,
; ����� ��������� ����������� ��� �������� ������� � ���������
EXTERN  GetStdHandle@4: PROC		; ������� ��������� ������������ ����� (-10) � ������ (-11) ������ � �������
EXTERN  WriteConsoleA@20: PROC
EXTERN  ReadConsoleA@20: PROC
EXTERN  lstrlenA@4: PROC			; ������� ����������� ����� ������
EXTERN  CharToOemA@8: PROC			; ��������� char ������� � oem �������
EXTERN  ExitProcess@4: PROC			; ������� ������ �� ���������

.CONST								; ������� ��������
	const_base	dword 16	
.DATA								; ������� ������
	; ���������� ��� ��������� HexToDecimal@12
	intPtr		dword 0					; ��������� �� ����� ����� � �������
	strPtr		dword 0					; ��������� �� ������ �������
	k			byte  0					; ���������� ��� �����

	; ���������� ��� ��������� DecimalToStr@16
	num			sdword 0				; ���������� ����� ��� ��������������
	bufPtr		dword 0					; ��������� �� �����
	bufSize		dword 0					; ������ ������
	factSizePtr	dword 0					; ��������� �� ����������� ������ ����� � ������

	; ���������� ��� �������� ���������
	din			dword ?					; ���������� �����
	dout		dword ?					; ���������� ������

	lens		dword ?					; ���������� ��� ���������� ���������� ��������
	impStr		byte  "������� 16-������ �����: ", 13, 10, 0
	impStrLen	dword ?					; ���������� ��� ���������� �������� � ������ impStr
	buf			byte 200 dup (?)		; ����� ��� �����, ������ 200 ��������

	firstNum	sdword 0				; ���������� � ������ �������� ������
	secondNum	sdword 0				; ���������� �� ������ �������� ������
.CODE									; ������� ���� 
MAIN PROC; ������ �������� ��������� � ������ MAIN
	push -10		; �������� ���������� �����
	CALL GetStdHandle@4
	mov din, eax

	push -11		; �������� ���������� ������
	CALL GetStdHandle@4
	mov dout, eax


	mov eax, offset impStr
	push eax			; ���� ���������� ��������� 
	push eax			; ����� ������ ������������
	call CharToOemA@8	; ������������ ������� ������ � oem

	push offset impStr
	call lstrlenA@4	; �������� ����� ������ impStr
	mov impStrLen, eax

	; ������ ������ �����
;#region 
	PUSH 0					; �����-�� ��� ��������
	PUSH OFFSET lens		; ��������� �� �����, ���� ��������� ����������� ����� ���������� ��������
	PUSH impStrLen			; ����� ������
	PUSH OFFSET impStr		; ��������� �� ������
	PUSH dout				; ���������� ������ � �������
	CALL WriteConsoleA@20	; ������� ����� � �������

	push 0					; �����-�� ��� ��������
	push offset lens		; ��������� �� ����������� ����� ��������� ����������
	push 200				; ������ ������
	push offset buf			; ��������� �� �����
	push din				; ���������� �����
	call ReadConsoleA@20	; ��������� ����� � �������

	sub lens, 2				; ������� �� ������ � ������ ������� �������� � ������ �������
	push offset firstNum
	push lens
	push offset buf
	call HexToDecimal@12
;#endregion

	; ������ ������ �����
;#region
	PUSH 0					; �����-�� ��� ��������
	PUSH OFFSET lens		; ��������� �� �����, ���� ��������� ����������� ����� ���������� ��������
	PUSH impStrLen			; ����� ������
	PUSH OFFSET impStr		; ��������� �� ������
	PUSH dout				; ���������� ������ � �������
	CALL WriteConsoleA@20	; ������� ����� � �������

	push 0					; �����-�� ��� ��������
	push offset lens		; ��������� �� ����������� ����� ��������� ����������
	push 200				; ������ ������
	push offset buf			; ��������� �� �����
	push din				; ���������� �����
	call ReadConsoleA@20	; ��������� ����� � �������

	sub lens, 2				; ������� �� ������ � ������ ������� �������� � ������ �������
	push offset secondNum
	push lens
	push offset buf
	call HexToDecimal@12
;#endregion
	
	mov eax, firstNum
	sub eax, secondNum
	mov firstNum, eax		; �������� ������ ����� �� �������, ��������� � ������

	push firstNum
	call ExitProcess@4
MAIN ENDP; ���������� �������� ��������� � ������ MAIN


; ��������� �������� ����������� ����� � ������
; �� ���� �����, ��������� �� �����, ����� ������, ��������� �� ����������� ����� �����
DecimalToStr@16 proc
	push ebp		; ��������� ������� �������� ������� �� ����� ������ (����� � ����� ��� �������)
	mov ebp, esp	; ���������� � ������� ��������� �� ������� ����� ������
	add ebp, 8		; ������ 4 ����� � ����� - ��������� �������� �������, ������ 4 ����� - ��������� ��� �������� � ���������, ������� �� �������

	mov eax, [ebp]	; ��������� ��������� �� ����������� ����� �����
	mov factSizePtr, eax
	mov eax, [ebp+4]; ��������� ����� ������
	mov bufSize, eax
	mov eax, [ebp+8]; ��������� ��������� �� �����
	mov bufPtr, eax
	mov eax, [ebp+12]; ��������� �����
	mov num, eax

	mov eax, factSizePtr	; �������� ���������� ������������ �������
	mov ebx, 0
	mov [eax], ebx

	; ������� ����� �����, ������ ���� ����� � ����
	; ���� ����� �������������, �� ����� � ����� �����
	; ��������� ����� �� �����, ��������� � ��� '0', ����� � �����

	pop ebp			; ���������� ������� �������� �������
	ret	16			; ������� �� ���������, ��� ���� ������� ��������, ��� ����� ������ ����� �������� ��������� �� 4 ��������:
DecimalToStr@16 endp

; ��������� �������������� ������ � 16-������ ������ � 10-������ 4-�������
; ��������� �� ���� ��������� �� ������ � 16-������ ������, ������ ������ (4 �����) � ��������� �� ���������� ����� 4 ������� (���� ��������� �����)
HexToDecimal@12 proc	; ������ ��������� 
	push ebp		; ��������� ������� �������� ������� �� ����� ������ (����� � ����� ��� �������)
	mov ebp, esp	; ���������� � ������� ��������� �� ������� ����� ������
	add ebp, 8		; ������ 4 ����� � ����� - ��������� �������� �������, ������ 4 ����� - ��������� ��� �������� � ���������, ������� �� �������

	mov eax, [ebp+8]
	mov intPtr, eax		; �������� ��������� �� 4-������� �����
	mov eax, [ebp+4]
	mov ecx, eax		; �������� ����� ������, ECX - �������� �����
	mov eax, [ebp]
	mov strPtr, eax		; �������� ��������� �� ������ ������

	mov eax, intPtr
	mov ebx, 0
	mov [eax], ebx		; �������� �� ������ intPtr �������� ����
	
loopBegin1: 			; ����� ������ �����
		mov eax, strPtr
		mov bh, [eax]
		mov k, bh		; ���������� ������� ����� � k
		sub k, '0'

		cmp k, 9			; ���� k ������ ��� ����� 9, ��
		jbe getToNum		; ������� � ����� getToNum

		mov bh, [eax]
		mov k, bh
		sub k, 'A'
		add k, 10

	getToNum:

		mov ebx, intPtr
		mov eax, [ebx]
		mul const_base
		mov [ebx], eax
		xor eax, eax
		mov al, k
		add [ebx], eax

		adc strPtr, 1
	loop loopBegin1

	pop ebp			; ���������� ������� �������� �������
	ret	12			; ������� �� ���������, ��� ���� ������� ��������, ��� ����� ������ ����� �������� ��������� �� 3 ��������:
					; 4 ����� - ��������� ������, 4 ����� - ��������� �� ����� ������, 4 ����� - �� �����
HexToDecimal@12 endp

END MAIN; ���������� �������� ������ � ��������� ������ ����������� ���������

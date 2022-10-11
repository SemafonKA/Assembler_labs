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
EXTERN  ExitProcess@4: PROC			; ������� ������ �� ���������

.CONST								; ������� ��������
	const_base	dword 16

.DATA								; ������� ������
	; ���������� ��� DublStr
	idx			dword ?				; ������ ��� �����
	freeSymbols dword ?				; ����� ���������� ��������� �������� � ������ ������

	; ���������� ��� stoi
	chr			byte ?				; ��������� ������

	; ���������� ��� �������� ���������
	din			dword ?					; ���������� �����
	dout		dword ?					; ���������� ������
	
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
.CODE								; ������� ���� 

MAIN PROC; ������ �������� ��������� � ������ MAIN
	push -10		; �������� ���������� �����
	CALL GetStdHandle@4
	mov din, eax

	push -11		; �������� ���������� ������
	CALL GetStdHandle@4
	mov dout, eax

; ������� ������ ����� � ��������� ��������� ������
	push offset inpRequest1
	call lstrlenA@4	; �������� ����� ������
	mov inpRequest1_len, eax

	push 0
	push 0
	push inpRequest1_len
	push offset inpRequest1
	push dout
	CALL WriteConsoleA@20	; ������� ����� � �������

	push 0
	push offset inputStrLen
	push 256
	push offset inputStr
	push din
	call ReadConsoleA@20	; ��������� ������ � �������

	mov eax, offset inputStr ; ������� �� ������ ������ ������� �������� � �������� �������
	add eax, inputStrLen
	mov bl, 0
	mov [eax-2], bl
	sub inputStrLen, 2

; ������� ������ ����� � ��������� ����� ��������
	push offset inpRequest2
	call lstrlenA@4	; �������� ����� ������
	mov inpRequest2_len, eax

	push 0
	push 0
	push inpRequest2_len
	push offset inpRequest2
	push dout
	CALL WriteConsoleA@20	; ������� ����� � �������

	push 0
	push offset inputRepeatsStrLen
	push 15
	push offset inputRepeatsStr
	push din
	call ReadConsoleA@20	; ��������� ������ � �������

	mov eax, offset inputRepeatsStr ; ������� �� ������ ������ ������� �������� � �������� �������
	add eax, inputRepeatsStrLen
	mov bl, 0
	mov [eax-2], bl
	sub inputRepeatsStrLen, 2

; ��������� ������ � �����
	push inputRepeatsStrLen
	push offset inputRepeatsStr
	call Stoi@8				; ��������� ������ � �����
	mov numRepeats, eax	

; �������� �������� ������
	push numRepeats
	push offset outStrLen
	push offset outStr
	mov edx, inputStrLen
	mov ecx, offset inputStr
	call DublStr@20			; �������� �������� ������

; ������� ����� � �������� ������
	push offset outPrint1
	call lstrlenA@4	; �������� ����� ������
	mov outPrint1_len, eax

	push 0
	push 0
	push outPrint1_len
	push offset outPrint1
	push dout
	CALL WriteConsoleA@20	; ������� ����� � �������

	push 0
	push 0
	push outStrLen
	push offset outStr
	push dout
	CALL WriteConsoleA@20	; ������� ������������ ������ � �������

	push 0
	push 0
	push outNewLineStr_len
	push offset outNewLineStr
	push dout
	CALL WriteConsoleA@20	; ������� ������� ������ � �������

	push 0
	call ExitProcess@4
MAIN ENDP; ���������� �������� ��������� � ������ MAIN

; fastcall procedure DublStr@20
; ���������: 
; inpStrPtr  - ��������� �� ������ ������� ������ (� �������� ecx)
; inpStrSize - ������ �������� ������, dword (� �������� edx)
; outStrPtr  - ��������� �� ������ �������� ������ (� �����)
; outStrSizePtr - ��������� �� ������ �������� ������ (� �����),
;				���������� ������ ������ ������������ ������ ������ (������ � �������� �����)
; repeats	 - ���������� �������� ������� ������ � ��������, dword (� �����)
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
	rep stosb				; �������������� ��������� ������� �������� ������ (������ ��� �����)
	pop ecx

	mov eax, outStrSizePtr
	mov ebx, [eax]
	mov freeSymbols, ebx
	sub freeSymbols, 1		; ����������� ���� ������ ��� ������ ����� ������
	mov ebx, 0
	mov [eax], ebx			; ���������� ����� �������������� ������ ��� 0
	
	mov eax, repeats
	push edx				; ���������� ����� ������� ������ (����� �� �������� ��� ���������)
	mul edx					; �������� ����� �������� �� ����� ������ ������
	pop edx					; ���������� ����� ������� ������
	mov idx, eax

	mov edi, outStrPtr		; ���������� � ���������� ��������� �� �������� ������
	.while idx
		; ���� ������ ������, �� ����� ������ � �����
		.if freeSymbols == 0
			.break
		.endif

		push ecx			; ���������� ��������� �� ������ ������� ������
		mov esi, ecx		; ���������� � ���� ��������� �� ������� ������
		
		; ���� �������� � ������ �������� ������, ��� ���� �����������, �� 
		; ����� ���������� ������� ������� ��������
		.if freeSymbols < edx
			mov ecx, freeSymbols
		.else
			mov ecx, edx
		.endif
		sub freeSymbols, ecx
		mov eax, outStrSizePtr
		add [eax], ecx
		sub idx, ecx
		rep movsb			; �������� � ����� ������ ������ ������ (�� ��� ����� ������ ������)
		pop ecx
	.endw

	POP EBP
	RET 12			; �.�. � ����� ����� ����� 3 ��������� �� 4 �����, ������ 12 ���� �� ������.
DublStr@20 ENDP

; ��������� �������� ������ � ����������� �����
; ���������:
; strPtr - ��������� �� ������ � ������
; strLen - ����� ������
; �������: 
; eax - ���������� �������� �����
Stoi@8 proc
	push ebp			; ��������� ������� �������� ������� �� ����� ������ (����� � ����� ��� �������)
	mov ebp, esp		; ���������� � ������� ��������� �� ������� ����� ������
	add ebp, 8			; ������ 4 ����� � ����� - ��������� �������� �������, ������ 4 ����� - ��������� ��� �������� � ���������, ������� �� �������
	strPtr equ [ebp]	; ���������� ������ ������� ����� ��� strPtr
	strLen equ [ebp+4]	; ���������� ������ ������� ����� ��� strLen

	xor eax, eax
	xor ecx, ecx
	mov ecx, strLen
	.while ecx
		mov ebx, strPtr	; �������� �� �������� ������� �����
		mov dl, [ebx]
		mov chr, dl
		sub chr, '0'
		.if chr > 9		; ���� ������ �� �����, ����� ���� � ��� � ����������
			mov eax, 0
			.break
		.endif
		mov ebx, 10
		mul ebx			; �������� ������� ���������� �� eax �� 10
		xor edx, edx
		mov dl, chr
		add eax, edx	; ��������� ������� ���������� �����

		mov edx, 1
		add strPtr, edx
		sub ecx, edx
	.endw

	pop ebp			; ���������� ��������� ������� �� �����
	ret 8			; ��������� �����, ������� ���� �� 8 ���� (2 ���������)
Stoi@8 endp

END MAIN; ���������� �������� ������ � ��������� ������ ����������� ���������

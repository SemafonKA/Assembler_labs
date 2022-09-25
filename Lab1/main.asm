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

; ������ ����������� ������ � oem
GetOemStr macro strPtr
	mov eax, strPtr
	push eax
	push eax
	call CharToOemA@8
endm

.CONST								; ������� ��������
	const_base	dword 16	
.DATA								; ������� ������
	; ���������� ��� ��������� HexToDecimal@12
	intPtr		dword 0					; ��������� �� ����� ����� � �������
	strPtr		dword 0					; ��������� �� ������ �������
	k			byte  0					; ���������� ��� �����
	errStr		byte  "������� �������� �����. ��������� �����������.", 13, 10, 0
	errStrLen	dword ?					; ���������� ��� ���������� �������� � ������ errStr

	; ���������� ��� ��������� DecimalToStr@16
	num			sdword 0				; ���������� ����� ��� ��������������
	bufPtr		dword 0					; ��������� �� �����
	bufSize		dword 0					; ������ ������
	factSizePtr	dword 0					; ��������� �� ����������� ������ ����� � ������

	; ���������� ��� �������� ���������
	din			dword ?					; ���������� �����
	dout		dword ?					; ���������� ������

	signFlag	byte  0					; ���� ��� ������������� �����
	lens		dword ?					; ���������� ��� ���������� ���������� ��������
	impStr		byte  "������� 16-������ �����: ", 13, 10, 0
	impStrLen	dword ?					; ���������� ��� ���������� �������� � ������ impStr
	outStr		byte  "���������� �����: ", 0
	outStrLen   dword ?
	buf			byte 200 dup (?)		; ����� ��� �����, ������ 200 ��������
	bufLen		dword 200

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

	GetOemStr offset impStr

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

	cmp eax, -1				; ���� ����� ������ ������� � eax �������� -1, �� ������� �� ����� ��������� (������ �����)
	je ExitProc
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

	cmp eax, -1				; ���� ����� ������ ������� � eax �������� -1, �� ������� �� ����� ��������� (������ �����)
	je ExitProc
;#endregion
	
	mov eax, firstNum
	sub eax, secondNum
	mov firstNum, eax		; �������� ������ ����� �� �������, ��������� � ������

	push firstNum
	push offset buf
	push 200
	push offset bufLen
	CALL DecimalToStr@16	; ��������� ����� � ������

	GetOemStr offset outStr
	push offset outStr
	call lstrlenA@4			; �������� ����� ������ outStr
	mov outStrLen, eax

	PUSH 0					
	PUSH OFFSET lens		
	PUSH outStrLen			
	PUSH OFFSET outStr		
	PUSH dout				
	CALL WriteConsoleA@20	; ������� ����� outStr � �������

	PUSH 0					
	PUSH OFFSET lens		
	PUSH bufLen				
	PUSH OFFSET buf			
	PUSH dout				
	CALL WriteConsoleA@20	; ������� ����� � �������

ExitProc:

	push 0
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


	; ���� ����� �������������, ��
	.if num < 0	
		mov signFlag, 1
		mov eax, bufPtr
		mov bl, '-'
		mov [eax], bl			; ���������� � ����� �����
		mov eax, factSizePtr
		mov ebx, 1
		add [eax], ebx			; ��������� ������� � ����������� ������ ������
		neg num
	.else
		mov signFlag, 0
	.endif

	; ������� ����� �����, ������ ���� ����� � ����
	.while num
		xor edx, edx		; ��� ������� �� 4 �����, ���������� ����� edx&eax �� ���-��, ������ edx �������
		mov eax, num		; ���������� � eax ������� num ��� ��� �������
		mov ebx, 10			; ���������� �������� � ebx
		div ebx				; ����� eax �� ebx. ��������� ������� � eax, ������� � edx
		mov num, eax		; ���������� ��������� ������� � num
		add dl, '0'			; ��������� � edx ������ ����, ����� �������� ������ ������ � ����������
		push edx			; ����� � ���� 
		
		mov eax, factSizePtr
		mov edx, 1
		add [eax], edx		; ��������� ������� � ����������� ������ ������
	.endw

	; ��������� ����� �� �����, ��������� � ��� '0', ����� � �����
	mov eax, factSizePtr
	mov ecx, [eax]			; ���������� � ecx ����������� ���������� ��������

	.if signFlag == 1		; ���� ��� ������� �����, �� �������� ���� ������ (�.�. ��� � ����� �� �����)
		dec ecx
	.endif

	.while ecx
		pop eax				; ���������� � eax ��������� ������
		mov ebx, factSizePtr
		mov edx, [ebx]
		sub edx, ecx		; ������� ������� ���������� ���������� ��������
		.if edx <= bufSize	; ���� ����� �� ����������, ��
			mov ebx, bufPtr
			mov [ebx + edx], al	; ���������� ������ � �������
		.endif
		dec ecx
	.endw

	pop ebp			; ���������� ������� �������� �������
	ret	16			; ������� �� ���������, ��� ���� ������� ��������, ��� ����� ������ ����� �������� ��������� �� 4 ��������:
DecimalToStr@16 endp

; ��������� �������������� ������ � 16-������ ������ � 10-������ 4-�������
; ��������� �� ���� ��������� �� ������ � 16-������ ������, ������ ������ (4 �����) � ��������� �� ���������� ����� 4 ������� (���� ��������� �����)
; ���� ��������� ������, �� � eax ������������ ����� -1
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
	xor ebx, ebx
	mov [eax], ebx		; �������� �� ������ intPtr �������� ����
	mov signFlag, 0		; �������� signFlag

	mov eax, strPtr
	mov bh, [eax]
	mov k, bh			; ���������� ������� ����� � k
	cmp k, '-'			; ���������� � �������
	jne loopBegin1
	mov signFlag, 1

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

		cmp k, 5
		jbe add10		; ���� k ������ ��� ����� 5, �� �� ��
		
		; ���� ������� ���-�� ������������, �� ����� ������
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

	cmp signFlag, 1		; ���� ����� �������������, ��
	jne HexToDecExit
	mov ebx, intPtr
	mov eax, [ebx]
	mov ecx, -1
	mul ecx
	mov [ebx], eax

HexToDecExit:
	pop ebp			; ���������� ������� �������� �������
	ret	12			; ������� �� ���������, ��� ���� ������� ��������, ��� ����� ������ ����� �������� ��������� �� 3 ��������:
					; 4 ����� - ��������� ������, 4 ����� - ��������� �� ����� ������, 4 ����� - �� �����
HexToDecimal@12 endp

PrintErr proc
	GetOemStr offset errStr

	push offset errStr
	call lstrlenA@4		; �������� ����� ������ errStr
	mov errStrLen, eax

	PUSH 0					; �����-�� ��� ��������
	PUSH OFFSET lens		; ��������� �� �����, ���� ��������� ����������� ����� ���������� ��������
	PUSH errStrLen			; ����� ������
	PUSH OFFSET errStr		; ��������� �� ������
	PUSH dout				; ���������� ������ � �������
	CALL WriteConsoleA@20	; ������� ����� � �������

	mov eax, -1
	ret
PrintErr endp

END MAIN; ���������� �������� ������ � ��������� ������ ����������� ���������

.386
.MODEL FLAT
OPTION CASEMAP: NONE

.DATA								; ������� ������
	; ���������� ��� @DublStr
	idx			dword ?				; ������ ��� �����
	freeSymbols dword ?				; ����� ���������� ��������� �������� � ������ ������

.CODE								; ������� ���� 

; fastcall procedure @DublStr@20
; ���������: 
; inpStrPtr  - ��������� �� ������ ������� ������ (� �������� ecx)
; inpStrSize - ������ �������� ������, dword (� �������� edx)
; outStrPtr  - ��������� �� ������ �������� ������ (� �����)
; outStrSizePtr - ��������� �� ������ �������� ������ (� �����),
;				���������� ������ ������ ������������ ������ ������ (������ � �������� �����)
; repeats	 - ���������� �������� ������� ������ � ��������, dword (� �����)
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
@DublStr@20 ENDP

END; ���������� �������� ������

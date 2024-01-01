; 學號: 111016041
; 姓名: 李其祐
; 操作說明: User 自行使用LDAS / LDAA after processing sub / add instruction, 
;			then call DumpRegs to print the result.
; 自評分數: 100, DAA, DAS功能皆有完成



INCLUDE Irvine32.inc
.386
;.model flat, stdcall
.stack 4096
ExitProcess PROTO, deExitCode:DWORD

.data
lowerFlag BYTE 0
higherFlag BYTE 0
carry WORD 0
hCarry WORD 0
origin DWORD 0
lowerCarry DWORD 0
lower DWORD 0

.code
LDAA PROC
	; init variables
	mov lowerFlag, 0
	mov higherFlag, 0
	mov carry, 0
	mov hCarry, 0
	mov origin, 0
	mov lowerCarry, 0
	mov lower, 0
	push eax
	lahf
	mov al, ah	; store falg status
	mov carry, ax
	pop eax
	and eax, 000000ffh

	mov origin, eax

	; check if lower bits overflow
	and eax, 0000000fh
	bt carry, 4
	jnc lowerNotCarry
	mov lowerFlag, 1
	add eax, 6h
	jmp doneWithLower

	lowerNotCarry:
		cmp eax, 9h
		jbe doneWithLower
		mov lowerFlag, 1
		mov lowerCarry, 10h
		add eax, 6h

	doneWithLower:
		and eax, 0000000fh
		mov lower, eax

	; check if higher bits overflow
	bt carry, 0
	jnc notCarry
	mov higherFlag, 1

	notCarry:
		mov eax, origin	; get origin number
		and eax, 000000f0h
		add eax, lowerCarry

		cmp higherFlag, 0
		je safe
		add eax, 60h
		and eax, 000000f0h
		jmp safe

		cmp eax, 90h
		jbe safe

		; higer overflow
		add eax, 60h
		and eax, 000000f0h
		mov higherFlag, 1
		
	; processing with eax and CF, AF
	safe:
		add eax, lower
		push eax
		mov ah, 0
		cmp lowerFlag, 1
		jne L1
		add ah, 10000b
		L1:
			cmp higherFlag, 1
			jne L2
			add ah, 1
		L2:
			sahf 
			pushfd

		popfd
		pop eax
		ret
LDAA ENDP

LDAS PROC
push eax
lahf
mov al, ah	; store falg status
mov carry, ax
pop eax
and eax, 000000ffh

mov origin, eax

; check if lower bits overflow
and eax, 0000000fh
bt carry, 4
jnc lowerNotCarry
mov lowerFlag, 1
sub eax, 6h
jmp doneWithLower

lowerNotCarry:
	cmp eax, 9h
	jbe doneWithLower
	mov lowerFlag, 1
	sub eax, 6h

doneWithLower:
	and eax, 0000000fh
	mov lower, eax

; check if higher bits overflow
bt carry, 0
jnc notCarry
mov higherFlag, 1

notCarry:
	mov eax, origin	; get origin number
	and eax, 000000f0h
	add eax, lowerCarry

	cmp higherFlag, 0
	je safe
	sub eax, 60h
	and eax, 000000f0h
	jmp safe

	cmp eax, 90h
	jbe safe

	; higer overflow
	sub eax, 60h
	and eax, 000000f0h
	mov higherFlag, 1
		
; processing with CF, AF, eax (result)
safe:
	add eax, lower
	push eax
	mov ah, 0
	cmp lowerFlag, 1
	jne L1
	add ah, 10000b
	L1:
		cmp higherFlag, 1
		jne L2
		add ah, 1
	L2:
		sahf 
		pushfd

	popfd
	pop eax
	ret
LDAS ENDP

main PROC
; example
mov al, 37h
sub al, 18h
call LDAS
call DumpRegs

; example
mov al, 19h
add al, 23h
call LDAA
call DumpRegs

main ENDP
END main
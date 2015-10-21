.586
.model flat,stdcall
.stack 4096
option casemap:none

include     C:\masm32\include\windows.inc
include     C:\masm32\include\kernel32.inc
include		C:\masm32\include\user32.inc
include		C:\masm32\include\msvcrt.inc
include		C:\masm32\include\ca296.inc

includelib	C:\masm32\lib\kernel32.lib
includelib	C:\masm32\lib\user32.lib
includelib	C:\masm32\lib\msvcrt.lib
includelib	C:\masm32\lib\uuid.lib
includelib	C:\masm32\lib\oldnames.lib
includelib	C:\masm32\lib\ca296.lib

;
;  #################### Conway's Game of Life #######################
;
;  Copyright (C) 2015 Anderson Antunes <https://hackaday.io/anderson>  
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;  ##################################################################
;

.data
	X				DWORD	0
	Y				DWORD	0
	RAND			DWORD	0
	
	NEIGH			DWORD	0
	CELL			DWORD	0
	TMPMASK			DWORD	0
	M2				DWORD	32 DUP(0)
	
.code 
	
	main: nop
		invoke Sleep, 500
		
		invoke setPattern, 0
		call createRandomMatrix
		
		untilTheHeatDeathOfTheUniverse: nop
			call step
		jmp untilTheHeatDeathOfTheUniverse
	
	checkNeighborhood: nop ;(X, Y) -> EAX
		mov NEIGH, 0
		cmp Y, 0
		je noTopRow
		;compute top row
		mov eax, Y
		sub eax, 1
		invoke readRow, eax
		mov ebx, X
		sub ebx, 1
		mov cl, bl
		shr eax, cl
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		shr eax, 1
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		shr eax, 1
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		
		noTopRow: nop
		cmp Y, 31
		je noBottomRow
		;compute bottom row
		mov eax, Y
		add eax, 1
		invoke readRow, eax
		mov ebx, X
		sub ebx, 1
		mov cl, bl
		shr eax, cl
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		shr eax, 1
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		shr eax, 1
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		
		noBottomRow: nop
		;compute middle row
		invoke readRow, Y
		mov ebx, X
		sub ebx, 1
		mov cl, bl
		shr eax, cl
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		shr eax, 2
		mov ebx, eax
		and ebx, 1
		add NEIGH, ebx
		
		mov eax, NEIGH
	ret
	
	getCellState: nop ;(X, Y) -> EAX
		invoke readRow, Y
		mov ebx, X
		mov cl, bl
		shr eax, cl
		and eax, 1
	ret
	
	updateValueOnSecondMatrix: nop ;(X, Y, ECX bitVal)
		mov CELL, ecx
		;create mask
		mov eax, 1
		mov ebx, X
		mov cl, bl
		shl eax, cl
		mov TMPMASK, eax
		mov esi, offset M2
		mov ebx, Y
		mov eax, [esi+ebx*4]
		mov ebx, TMPMASK
		
		;if
		cmp CELL,0
		je resetBit
		
		;set bit 1
		or eax, ebx			;or row value with the mask
		jmp endUVOSM
		
		resetBit: nop
		;set bit 0
		not ebx				;not the mask
		and eax, ebx		;and the row value with the mask
		
		endUVOSM: nop
		mov esi, offset M2
		mov ebx, Y
		mov [esi+ebx*4], eax
	ret
	
	checkRules: nop ;(EAX nNB, EBX val) -> EAX
		cmp eax, 3
		ja overPop		;  > 3
		je live			; == 3
		cmp eax, 2
		jb underPop		;  < 2
		;exactly 2 neighbours stays the same
		mov eax, ebx
		ret
			
		underPop:
		overPop:
			mov eax, 0
			ret
		live:
			mov eax, 1
			ret
	ret
	
	updateSecondMatrix: nop
		mov Y, 0
		yLoop:
			mov X, 0
			xLoop:
				call checkNeighborhood
				mov NEIGH, eax
				
				call getCellState
				mov CELL, eax
				
				mov eax, NEIGH
				mov ebx, CELL
				call checkRules
				mov ecx, eax
				call updateValueOnSecondMatrix
				
				add X, 1
				cmp X, 32
				jne xLoop
			add Y, 1
			cmp Y, 32
			jne yLoop
	ret
	
	printSecondMatrix: nop
		mov Y, 0
		PSMLoop:
			mov esi, offset M2
			mov eax, Y
			invoke writeRow, eax,[esi+eax*4]
			
			add Y, 1
			cmp Y, 32
			jne PSMLoop
	ret
	
	step: nop
		invoke Sleep, 100
		call updateSecondMatrix
		call printSecondMatrix
	ret
	
	createRandomMatrix: nop
		mov Y, 0
		CRMLoop:
			call rand32
			mov esi, offset M2
			mov eax, Y
			mov ebx, RAND
			mov [esi+eax*4], ebx
			
			add Y, 1
			cmp Y, 32
			jne CRMLoop
		call printSecondMatrix
	ret
	
	rand32: nop ;() -> [RAND]
		;generate 32-bit unsigned random number
		invoke random, 0eFFFFFFFh
		and eax, 0FFFFh
		shl eax, 16
		mov RAND, eax
		invoke random, 0eFFFFFFFh
		and eax, 0FFFFh
		or RAND, eax
	ret
		
	kill: invoke ExitProcess,0
	end main

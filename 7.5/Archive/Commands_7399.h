"BSET  	3"               "\n\t"
"SUBI  	R27, 7"          "\n\t"
"SWAP  	R3"              "\n\t"
"LPM   	R20, Z"          "\n\t"
"IN    	R0, 32"          "\n\t"
"ROR   	R11"             "\n\t"
"CALL  	Test_JMP"        "\n\t"
"SBRS  	R30, 7"          "\n\t"
"COM   	R8"              "\n\t"
"LSR   	R1"              "\n\t"
"ANDI  	R16, 116"        "\n\t"
"FMULSU	R20, R22"        "\n\t"
"SBI   	24, 3"           "\n\t"
"ASR   	R3"              "\n\t"
"ORI   	R18, 168"        "\n\t"
"SBCI  	R28, 118"        "\n\t"
"COM   	R29"             "\n\t"
"SBRS  	R24, 5"          "\n\t"
"CBI   	4, 5"            "\n\t"
"CALL  	Test_CALL"       "\n\t"
"SER   	R23"             "\n\t"
"FMULSU	R20, R19"        "\n\t"
"SBRS  	R2, 5"           "\n\t"
"MULSU 	R23, R19"        "\n\t"
"LDS   	R0, 2111"        "\n\t"
"NEG   	R18"             "\n\t"
"LD    	R19, Z+"         "\n\t"
"CALL  	Test_CALL"       "\n\t"
"BCLR  	4"               "\n\t"
"CALL  	Test_JMP"        "\n\t"
"ADD   	R4, R28"         "\n\t"
"ORI   	R18, 72"         "\n\t"
"WDR   	"                "\n\t"
"AND   	R15, R3"         "\n\t"
"ASR   	R6"              "\n\t"
"CBI   	0, 5"            "\n\t"
"BCLR  	6"               "\n\t"
"BCLR  	2"               "\n\t"
"WDR   	"                "\n\t"
"CALL  	Test_IJMP"       "\n\t"
"LDD   	R29, Y+34"       "\n\t"
"LDI   	R26, 44"         "\n\t"
"LDI   	R21, 147"        "\n\t"
"WDR   	"                "\n\t"
"ANDI  	R27, 44"         "\n\t"
"CP    	R20, R17"        "\n\t"
"LD    	R10, Y+"         "\n\t"
"CALL  	Test_RJMP"       "\n\t"
"EOR   	R25, R15"        "\n\t"
"COM   	R16"             "\n\t"
"SER   	R22"             "\n\t"
"IN    	R21, 30"         "\n\t"
"ROR   	R10"             "\n\t"
"SWAP  	R7"              "\n\t"
"SUB   	R28, R11"        "\n\t"
"CALL  	Test_BRBC"       "\n\t"
"SBCI  	R31, 59"         "\n\t"
"CALL  	Test_JMP"        "\n\t"
"LDI   	R30, 1"          "\n\t"
"FMULS 	R18, R22"        "\n\t"
"CALL  	Test_RJMP"       "\n\t"
"ADIW  	R26, 25"         "\n\t"
"CALL  	Test_JMP"        "\n\t"
"CBI   	0, 4"            "\n\t"
"CALL  	Test_IJMP"       "\n\t"
"BCLR  	1"               "\n\t"
"FMULS 	R16, R23"        "\n\t"
"SBRS  	R19, 6"          "\n\t"
"LDI   	R29, 21"         "\n\t"
"LDS   	R0, 1003"        "\n\t"
"CALL  	Test_BRBC"       "\n\t"
"LPM   	"                "\n\t"
"BSET  	6"               "\n\t"
"CALL  	Test_BRBC"       "\n\t"
"SUB   	R3, R11"         "\n\t"
"STS   	352, R27"        "\n\t"
"CP    	R1, R1"          "\n\t"
"ORI   	R16, 125"        "\n\t"
"CP    	R10, R25"        "\n\t"
"WDR   	"                "\n\t"
"CPI   	R27, 104"        "\n\t"
"MUL   	R29, R30"        "\n\t"
"CPI   	R23, 155"        "\n\t"
"SBRC  	R20, 6"          "\n\t"
"SUBI  	R22, 220"        "\n\t"
"LSR   	R2"              "\n\t"
"FMULSU	R23, R23"        "\n\t"
"LPM   	R14, Z"          "\n\t"
"WDR   	"                "\n\t"
"CALL  	Test_IJMP"       "\n\t"
"SBC   	R7, R26"         "\n\t"
"NEG   	R30"             "\n\t"
"SWAP  	R22"             "\n\t"
"FMULSU	R19, R22"        "\n\t"
"SUB   	R20, R15"        "\n\t"
"SBRC  	R0, 1"           "\n\t"
"ADIW  	R24, 38"         "\n\t"
"CALL  	Test_BRBS"       "\n\t"
"CALL  	Test_BRBS"       "\n\t"
"LPM   	R0, Z"           "\n\t"
"NOP"                    "\n\t"
"CALL	CRC_REGISTERS%=" "\n\t"
"CALL	DUMP_REGS%="     "\n\t"

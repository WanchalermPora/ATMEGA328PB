#include <avr/io.h>
#include "testlib.h"
#include <avr/interrupt.h>
#include <avr/iom328pb.h>


ISR(INT0_vect) {
	EIMSK &= ~(1 << INT0);
}
ISR(INT1_vect) {
	EIMSK &= ~(1 << INT1);
}
ISR(EE_READY_vect) {}
ISR(USART0_UDRE_vect){}
ISR(USART1_UDRE_vect){}

volatile uint16_t crc = 0x00;
const int seed = 0x1CA8;

int main() {
	srand(seed);
// 	uint16_t Rd = 0;
// 	uint16_t i = 0;
// 	int k = 3;
	/*
	for (uint8_t j = 0;j<10;j++) {
    uint16_t crco0, crco1;
		i = delay_asm(j,300);
		i &= 0xFF;
		crco0 = crc16_ccitt((uint8_t)i, crc);
    crco1 = crc16_ccitt_asm((uint8_t)i, crc);
	}
	testRandom();
	while (k>0) {
		uint8_t output=0;
		continue_loop_until_bit_is_clear(output, 0);
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 1);
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 2); // forever
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 3);
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 0+4);
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 1+4);
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 2+4);
		crc = crc16_ccitt(output, crc);
		continue_loop_until_bit_is_clear(output, 3+4);
		crc = crc16_ccitt(output, crc);
		k--;
	}*/
	
// 	test_rjmp(4);
// 	test_rcall(5);
// 	test_ijmp(3);
// 	test_icall(6);
// 	test_jmp(7);
	//test_call(10);
	//crc = crc16_ccitt(test_breq_forwards(10), crc);
	//crc = crc16_ccitt(test_breq_backwards(10), crc);
	//crc = crc16_ccitt((uint8_t)my_int_power(9 , 7) , crc);

asm volatile ( "\n"
//".org 0x400 \n\t"
".equ SPL, 0x3D" "\n\t" // io address 0x5D for mem addr
".equ SPH, 0x3E" "\n\t" // io address 0x5E for mem addr
".equ SREG, 0x3F" "\n\t" // io address 0x5F for mem addr
".equ CRCH, 0x0401" "\n\t"
".equ CRCL, 0x0400" "\n\t"
".equ FUNCTIONS, 0x06600" "\n\t"

//".equ REGPTR, 0x600" "\n\t"
".equ REGVEC, 0x300" "\n\t"
".equ CRCL, 0x700" "\n\t"
".equ CRCH, 0x701" "\n\t"
//".DSEG \n\t"

//"REGVEC2: .byte 0xFF" "\n\t"
"REGPTR: .byte 1" "\n\t"
//"REGPTRH: .byte 1" "\n\t"
//"REGdag: .byte 2" "\n\t"
"REGVEC: .byte 0xF0" "\n\t"

// "CALL Test_JMP \n\t"
// "CALL Test_CALL \n\t"
// "CALL Test_IJMP \n\t"
// "CALL Test_ICALL \n\t"
// "CALL Test_RJMP \n\t"
// "CALL Test_RCALL \n\t"
// "CALL Test_BRBS \n\t"
// "CALL Test_BRBC \n\t"

"LDI R16, lo8(REGVEC+2)"  "\n\t"
"STS REGVEC, R16" "\n\t"
"LDI R16, hi8(REGVEC+2)" "\n\t"
"STS REGVEC+1, R16" "\n\t"

#include "commands.h"
#include "subroutines_asm.h"
::);

  
  
/*
	while (true) {
		Rd += i;
		asm volatile ("adiw %0, 0 ": "=w"(Rd): );
		asm volatile ("adiw %0, 1 ": "=w"(Rd): );
		asm volatile ("adiw %0, 2 ": "=w"(Rd): );
		asm volatile ("adiw %0, 3 ": "=w"(Rd): );
		asm volatile ("adiw %0, 4 ": "=w"(Rd): );
		asm volatile ("adiw %0, 5 ": "=w"(Rd): );
		asm volatile ("adiw %0, 6 ": "=w"(Rd): );
		asm volatile ("adiw %0, 7 ": "=w"(Rd): );
		asm volatile ("adiw %0, 8 ": "=w"(Rd): ); crc = crc16_ccitt(Rd, crc);
		asm volatile ("adiw %0, 9 ": "=w"(Rd): );
		asm volatile ("adiw %0, 10 ": "=w"(Rd): );
		asm volatile ("adiw %0, 11 ": "=w"(Rd): );
		asm volatile ("adiw %0, 12 ": "=w"(Rd): );
		asm volatile ("adiw %0, 13 ": "=w"(Rd): );
		asm volatile ("adiw %0, 14 ": "=w"(Rd): );
		asm volatile ("adiw %0, 15 ": "=w"(Rd): );
		asm volatile ("adiw %0, 16 ": "=w"(Rd): );
		asm volatile ("adiw %0, 17 ": "=w"(Rd): ); crc = crc16_ccitt(Rd, crc);
		asm volatile ("adiw %0, 18 ": "=w"(Rd): );
		asm volatile ("adiw %0, 19 ": "=w"(Rd): );
		asm volatile ("adiw %0, 20 ": "=w"(Rd): );
		asm volatile ("adiw %0, 21 ": "=w"(Rd): );
		asm volatile ("adiw %0, 22 ": "=w"(Rd): );
		asm volatile ("adiw %0, 23 ": "=w"(Rd): );
		asm volatile ("adiw %0, 24 ": "=w"(Rd): );
		asm volatile ("adiw %0, 25 ": "=w"(Rd): );
		asm volatile ("adiw %0, 26 ": "=w"(Rd): );
		asm volatile ("adiw %0, 27 ": "=w"(Rd): );
		asm volatile ("adiw %0, 28 ": "=w"(Rd): );
		asm volatile ("adiw %0, 29 ": "=w"(Rd): );
		asm volatile ("adiw %0, 30 ": "=w"(Rd): );
		asm volatile ("adiw %0, 31 ": "=w"(Rd): );
		asm volatile ("adiw %0, 32 ": "=w"(Rd): );
		asm volatile ("adiw %0, 33 ": "=w"(Rd): );
		asm volatile ("adiw %0, 34 ": "=w"(Rd): );
		asm volatile ("adiw %0, 35 ": "=w"(Rd): );
		asm volatile ("adiw %0, 36 ": "=w"(Rd): ); crc = crc16_ccitt(Rd, crc);
		asm volatile ("adiw %0, 37 ": "=w"(Rd): );
		asm volatile ("adiw %0, 38 ": "=w"(Rd): );
		asm volatile ("adiw %0, 39 ": "=w"(Rd): );
		asm volatile ("adiw %0, 40 ": "=w"(Rd): );
		asm volatile ("adiw %0, 41 ": "=w"(Rd): );
		asm volatile ("adiw %0, 42 ": "=w"(Rd): );
		asm volatile ("adiw %0, 43 ": "=w"(Rd): );
		asm volatile ("adiw %0, 44 ": "=w"(Rd): );
		asm volatile ("adiw %0, 45 ": "=w"(Rd): );
		asm volatile ("adiw %0, 46 ": "=w"(Rd): );
		asm volatile ("adiw %0, 47 ": "=w"(Rd): );
		asm volatile ("adiw %0, 48 ": "=w"(Rd): );
		asm volatile ("adiw %0, 49 ": "=w"(Rd): );
		asm volatile ("adiw %0, 50 ": "=w"(Rd): );
		asm volatile ("adiw %0, 51 ": "=w"(Rd): );
		asm volatile ("adiw %0, 52 ": "=w"(Rd): );
		asm volatile ("adiw %0, 53 ": "=w"(Rd): );
		asm volatile ("adiw %0, 54 ": "=w"(Rd): );
		asm volatile ("adiw %0, 55 ": "=w"(Rd): ); crc = crc16_ccitt(Rd, crc);
		asm volatile ("adiw %0, 56 ": "=w"(Rd): );
		asm volatile ("adiw %0, 57 ": "=w"(Rd): );
		asm volatile ("adiw %0, 58 ": "=w"(Rd): );
		asm volatile ("adiw %0, 59 ": "=w"(Rd): );
		asm volatile ("adiw %0, 60 ": "=w"(Rd): );
		asm volatile ("adiw %0, 61 ": "=w"(Rd): );
		asm volatile ("adiw %0, 62 ": "=w"(Rd): );
		asm volatile ("adiw %0, 63 ": "=w"(Rd): ); crc = crc16_ccitt(Rd, crc);
		i++;
		if (i>0xFF00) break;
	}*/
}

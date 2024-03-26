#pragma once
#include <stdint.h>
#include <stdlib.h>


#define continue_loop_until_bit_is_clear(R,bitno)  \
asm volatile (					\
"L_%=: "	"inc %0" "\n\t"					\
			"out 0x1E, %0" "\n\t"			\
			"sbic 0x1E, %1" "\n\t"			\
			"rjmp L_%=" "\n\t"				\
			:"=&r" (R) : "I" (bitno))



///-------------------------------------------------
uint16_t crc16_ccitt(uint8_t data, uint16_t crc) {
	crc ^= (data << 8);
	for (uint8_t i = 0; i < 8; i++) {
		if (crc & 0x8000) {
			crc = (crc << 1) ^ 0x1021;
			} else {
			crc <<= 1;
		}
		crc &= 0xFFFF;
	}
	return crc;
}

uint16_t crc16_ccitt(uint8_t , uint16_t ) ;
void test_rjmp (int loop) ;
uint16_t delay_asm(unsigned char ms, unsigned int delay_count);
int my_int_power(int a, int n) ;
bool binaryRandomGenerator(); 

void test_rjmp (int loop) {
	for (;loop >0;loop--){
	asm volatile("\n"
	"L1_%=:""\n\t"
	"rjmp L4_%=" "\n\t"
	"L2_%=:""\n\t"
	"rjmp L5_%=" "\n\t"
	"L3_%=:""\n\t"
	"nop" "\n\t"
	"rjmp L6_%=" "\n\t"
	"L4_%=:""\n\t"
	"rjmp L2_%=" "\n\t"
	"L5_%=:""\n\t"
	"rjmp L3_%=" "\n\t"
	"nop" "\n\t"
	"nop" "\n\t"
	"L6_%=:"
	::
	);
	}
}
void test_rcall (int loop) {
	for (;loop >0;loop--)
	asm volatile("\n"
	"L1_%=:""\n\t"
	"rcall L4_%=" "\n\t"
	"L2_%=:""\n\t"
	"rcall L5_%=" "\n\t"
	"rjmp L7_%=" "\n\t"
	"L3_%=:""\n\t"
	"nop" "\n\t"
	"rjmp L6_%=" "\n\t"
	"L4_%=:""\n\t"
	"rcall L6_%=" "\n\t"
	"ret" "\n\t"
	"L5_%=:""\n\t"
	"rjmp L3_%=" "\n\t"
	"nop" "\n\t"
	"nop" "\n\t"
	"L6_%=:""\n\t"
	"ret" "\n\t"
	"L7_%=:" "\n\t"
	::
	);
}

void test_ijmp (int loop) {
	for (;loop >0;loop--){
		asm volatile("\n"
		"L1_%=:""\n\t"
		"ldi ZH, pm_hi8(L4_%=)" "\n\t"
		"ldi ZL, pm_lo8(L4_%=)" "\n\t"
		"ijmp" "\n\t"
		"L2_%=:""\n\t"
		"ldi ZH, pm_hi8(L5_%=)" "\n\t"
		"ldi ZL, pm_lo8(L5_%=)" "\n\t"
		"ijmp" "\n\t"
		"L3_%=:""\n\t"
		"nop" "\n\t"
		"ldi ZH, pm_hi8(L6_%=)" "\n\t"
		"ldi ZL, pm_lo8(L6_%=)" "\n\t"
		"ijmp" "\n\t"
		"L4_%=:""\n\t"
		"ldi ZH, pm_hi8(L2_%=)" "\n\t"
		"ldi ZL, pm_lo8(L2_%=)" "\n\t"
		"ijmp" "\n\t"
		"L5_%=:""\n\t"
		"nop" "\n\t"
		"nop" "\n\t"
		"ldi ZH, pm_hi8(L3_%=)" "\n\t"
		"ldi ZL, pm_lo8(L3_%=)" "\n\t"
		"ijmp" "\n\t"
		"L6_%=:"
		::
		);
	}
}

void test_icall (int loop) {
 for (;loop >0;loop--){
 asm volatile("\n"
"L1_%=:""\n\t"
  "ldi ZH, pm_hi8(L4_%=)" "\n\t"
  "ldi ZL, pm_lo8(L4_%=)" "\n\t"
   "icall" "\n\t"
   "rjmp L5_%=" "\n\t"
"L2_%=:""\n\t"
  "PUSH __tmp_reg__" "\n\t"
  "POP __tmp_reg__" "\n\t"
  "ret" "\n\t"
"L3_%=:""\n\t"
  "nop" "\n\t"
  "ldi ZH, pm_hi8(L6_%=)" "\n\t"
  "ldi ZL, pm_lo8(L6_%=)" "\n\t"
  "ijmp" "\n\t"
"L4_%=:""\n\t"
  "ldi ZH, pm_hi8(L2_%=)" "\n\t"
  "ldi ZL, pm_lo8(L2_%=)" "\n\t"
 "icall" "\n\t"
  "ret" "\n\t"
"L5_%=:""\n\t"
 "nop" "\n\t"
 "nop" "\n\t"
  "ldi ZH, pm_hi8(L4_%=)" "\n\t"
  "ldi ZL, pm_lo8(L4_%=)" "\n\t"
 "icall" "\n\t"
"L6_%=:"
 ::
 );
 }
}

void test_call (int loop) {
 for (;loop >0;loop--)
 asm volatile("\n"
 "L1_%=:""\n\t"
 "call L4_%=" "\n\t"
 "L2_%=:""\n\t"
 "call L5_%=" "\n\t"
 "rjmp L7_%=" "\n\t"
 "L3_%=:""\n\t"
 "nop" "\n\t"
 "rjmp L6_%=" "\n\t"
 "L4_%=:""\n\t"
 "call L6_%=" "\n\t"
 "ret" "\n\t"
 "L5_%=:""\n\t"
 "rjmp L3_%=" "\n\t"
 "nop" "\n\t"
 "nop" "\n\t"
 "L6_%=:""\n\t"
 "ret" "\n\t"
 "L7_%=:" "\n\t"
 ::
 );
}

void test_jmp (int loop) {
 for (;loop >0;loop--){
 asm volatile("\n"
 "L1_%=:""\n\t"
 "jmp L4_%=" "\n\t"
 "L2_%=:""\n\t"
 "jmp L5_%=" "\n\t"
 "L3_%=:""\n\t"
 "nop" "\n\t"
 "jmp L6_%=" "\n\t"
 "L4_%=:""\n\t"
 "jmp L2_%=" "\n\t"
 "L5_%=:""\n\t"
 "jmp L3_%=" "\n\t"
 "nop" "\n\t"
 "nop" "\n\t"
 "L6_%=:"
 ::
 );
 }
}

uint8_t test_breq_forwards(int loop) {
	uint8_t crc = 0xFF , tmp = 0xA5;
	for(;loop>0;loop--) {
		// test branch forwards

		if (binaryRandomGenerator()) asm volatile( "\n" "SEZ" "\n\t");
		else asm volatile( "\n" "CLZ" "\n\t");
		asm volatile("\n"
		"BREQ NO_XOR%=" "\n\t"
		"EOR %0, %1" "\n\t"
		"NO_XOR%=:" "\n\t"
		"CPI %0, 0x7F" "\n\t"
		"ROR %1" "\n\t"
		: "=&r" (crc), "+r" (tmp)
		:
		);
	}
	return crc;
}

uint8_t test_breq_backwards(int loop) {
	uint8_t crc = 0xFF , tmp = 0xA5;
	for(;loop>0;loop--) {
		if (binaryRandomGenerator()) asm volatile("SEZ" "\n\t");
		else asm volatile("CLZ" "\n\t");
		asm volatile(
		"RJMP TEST%=" "\n\t"
		"XOR%=:" "\n\t"
		"EOR %0, %1" "\n\t"
		"RJMP ROTATE%=" "\n\t"
		"TEST%=:" "\n\t"
		"BREQ XOR%=" "\n\t"
		"ROTATE%=:" "\n\t"
		"CPI %1, 0x7F" "\n\t"
		"ROR %1" "\n\t"
		:"=&r" (crc), "+r" (tmp)
		:
		);
	}
	return crc;
}

uint16_t delay_asm(unsigned char ms, unsigned int delay_count)
{
  uint16_t cnt;
  asm volatile(
    "\n"
    "L_dl1%=:"
      "mov %A0, %A2"  "\n\t"
      "mov %B0, %B2"  "\n"
    "L_dl2%=:"      "\n\t"
      "sbiw %A0, 1"   "\n\t"
      "brne L_dl2%="  "\n\t"
      "sbiw %A2, 1"   "\n\t"  
      "dec %1"        "\n\t"
      "brne L_dl1%="  "\n\t"
    : "=&w" (cnt)
    : "r" (ms), "w" (delay_count)
  );
  return delay_count;
}

int my_int_power(int a, int n) {
	int answer;
	asm volatile( //In AVR
	"mov r24, %A1 \n\t" //set up the arguments for our function
	"mov r25, %B1 \n\t" //move a to r24, r25
	"mov r22, %A2 \n\t" //move n to r22
	"rcall myPow%= \n\t"
	"mov %A0, r24 \n\t"
	"mov %B0, r25 \n\t"
	"rjmp over%= \n\t"
	"myPow%=: nop \n\t"
	"push r20 \n\t" //r20, r21 will be a
	"push r21 \n\t"
	"push r18 \n\t" // r18 is n
	"mov r20, r24 \n\t" //load a
	"mov r21, r25 \n\t" //load a
	"mov r18, r22 \n\t" //load n
	"cpi r18, 0 \n\t" //n == 0
	"breq then%= \n\t"
	"mov r22, r18 \n\t"
	"dec r22 \n\t" //n - 1
	"rcall myPow%= \n\t"
	"mul r20, r24 \n\t"
	"movw r16, r0 \n\t" //r16, r17 hold the product
	"mul r20, r25 \n\t"
	"add r17, r0 \n\t"
	"mul r21, r24 \n\t"
	"add r17, r0 \n\t"
	"clr r1 \n\t" "\n\t"
	"movw r24, r16 \n\t"
	"rjmp past%= \n\t"
	"then%=: ldi r24,1 \n\t"
	"ldi r25, 0 \n\t"
	"past%=: pop r18 \n\t"
	"pop r21 \n\t"
	"pop r22 \n\t"
	"ret \n\t"
	"over%=: nop \n\t"
	: "=d" (answer) //output list
	: "a" (a),"a" (n) //input list
	:
	);
	return answer ;
}

bool binaryRandomGenerator() {
    static uint8_t bitCount = 0 ;
    static int randomNumber;
	randomNumber = rand();
	//static uint16_t randomNumber = (uint16_t) 0;    
    bool returnValue = randomNumber & 0x01;
    randomNumber >>=1; // return next bit
    if (bitCount==15) { 
        //regenerate a number between 0 and 2^16-1
        randomNumber = (uint16_t) rand();
        bitCount = 0;
    } else bitCount++;
    return returnValue;
}
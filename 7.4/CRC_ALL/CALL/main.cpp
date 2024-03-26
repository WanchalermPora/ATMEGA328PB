#include <avr/io.h>
#include "testlib.h"
#include <stdlib.h>

volatile uint16_t crc = 0x00;
const int seed = 0x1CA8;

int main() {
	srand(seed);
	uint16_t Rd = 0;
	uint16_t i = 0;
	int k = 3;
	// for (uint8_t j = 0;j<10;j++) {
	// 	i = delay_asm(j,20);
	// 	i &= 0xFF;
	// 	crc = crc16_ccitt((uint8_t)i, crc);
	// }
	
	// while (k>0) {
	// 	uint8_t output=0;
	// 	continue_loop_until_bit_is_clear(output, 0);
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 1);
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 2); // forever
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 3);
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 0+4);
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 1+4);
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 2+4);
	// 	crc = crc16_ccitt(output, crc);
	// 	continue_loop_until_bit_is_clear(output, 3+4);
	// 	crc = crc16_ccitt(output, crc);
	// 	k--;
	// }
	
/*	int A = rand();*/
// 	
	// test_ijmp(30);
		
	// test_rjmp(30);
	
	// test_rcall(30);
	
	// test_icall(30);
	
	test_jmp(30);
// 	
 	//  test_call(30);
	// crc = crc16_ccitt(test_breq_forwards(10), crc);
	// crc = crc16_ccitt(test_breq_backwards(10), crc);
// 	
// 	for (int i = 1 ; i < 4 ; i++)
// 	{
// 		for(int j = 1 ; j < 10 ; j++){
// 			crc = crc16_ccitt((uint8_t)my_int_power(i*21 , j) , crc);
// 		}
// 	}
// 	crc = crc16_ccitt((uint8_t)my_int_power(9 , 7) , crc);
	crc = crc16_ccitt((uint8_t)my_int_power(121 , 3) , crc);
    return 0;

}

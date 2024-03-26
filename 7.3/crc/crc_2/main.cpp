/*
 * GccApplication4.cpp
 *
 * Created: 1/20/2024 4:03:38 PM
 * Author : USER
 */ 

#include <avr/io.h>

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

int main() {    
    uint8_t Rd = 0, Rr = 0;
    uint8_t i=1; 
    uint8_t j=1;
    volatile uint16_t crc = 0x00;
    while (true) {
      Rr = i;
      while (true) {
        Rd = j;
        asm volatile ("adc %0, %1": "=r" (Rd): "r" (Rr));
        crc = crc16_ccitt(Rd, crc);
        j = j + 1;
        if (j> 63) break;
      }
      i = i + 1;
      if (i > 63) break;
    }
	return 0;
}



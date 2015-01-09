#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

#include "Screen.h"

int main(void) {
    DDRC = 1 << PC7;

    screen_initialize();
    screen_clear(0x00);
    screen_print_string("hello");
    screen_newline();
    screen_print_string("world!");

    for(;;) {
        PORTC &= ~(1 << PC7);
        _delay_ms(1000);
        PORTC |= 1 << PC7;
        _delay_ms(1000);
    }

    return(0);
}

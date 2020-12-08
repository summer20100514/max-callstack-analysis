#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>

void A(void);
void B(void);
void C(void);
void D(void);
void M(void);
void N(void);
void O(void);
void P(void);
void X(void);
void Y(void);
void Z(void);

void A(void)
{
    volatile uint8_t buf[10] = {0};
    B();
    X();
}
void B(void)
{
    volatile uint8_t buf[20] = {0};
    buf[0] = buf[0];
    C();
}
void C(void)
{
    volatile uint8_t buf[30] = {0};
    buf[0] = buf[0];
    D();
    M();
}
void D(void)
{
    volatile uint8_t buf[40] = {0};
    buf[0] = buf[0];
    C();
}
void M(void)
{
    volatile uint8_t buf[50] = {0};
    buf[0] = buf[0];
    N();
}
void N(void)
{
    volatile uint8_t buf[60] = {0};
    buf[0] = buf[0];
    O();
}
void O(void)
{
    volatile uint8_t buf[70] = {0};
    buf[0] = buf[0];
    P();
}
void P(void)
{
    volatile uint8_t buf[80] = {0};
    buf[0] = buf[0];
}
void X(void)
{
    volatile uint8_t buf[15] = {0};
    buf[0] = buf[0];
    Y();
}
void Y(void)
{
    volatile uint8_t buf[25] = {0};
    buf[0] = buf[0];
    Z();
}
void Z(void)
{
    volatile uint8_t buf[35] = {0};
    buf[0] = buf[0];
    C();
}

int START(void)
{
    A();

    return 0;
}


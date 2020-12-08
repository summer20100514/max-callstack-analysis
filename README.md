# maximum call stack analysis

an easy to use maximum stack usage analysis script written in Perl, an improved version of avstack.pl.

origin version written by Daniel Beer https://dlbeer.co.nz/downloads/avstack.pl

## improved features

- show maximum **call stack chains** in readable format
- add parsing of relocation R_ARM_THM_JUMP*

## sample output

```c
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

```

```shell
$ cd call_stack_test && make
$ ls
call_stack_testcase.c  call_stack_testcase.o  call_stack_testcase.S  call_stack_testcase.su  Makefile
$ chmod +x ../armstack.pl ../avstack.pl
$ ../armstack.pl call_stack_testcase.o
  Func                                           Cost    Frame   Height
------------------------------------------------------------------------
> START                                           488        8       10
  A                                               480       24        9
  X                                               456       24        8
  Y                                               432       40        7
R D                                               392       48        6
  Z                                               392       48        6
  B                                               376       32        6
  C                                               344       40        5
  M                                               304       64        4
  N                                               240       72        3
  O                                               168       80        2
  P                                                88       88        1
> INTERRUPT                                         0        0        1


## Chain from START, Cost (488)
------------------------------------------------------------------------
  >START (8)
      >A (24)
          >X (24)
              >Y (40)
                  >Z (48)
                      >C (40)
                          >M (64)
                              >N (72)
                                  >O (80)
                                      >P (88)

## Chain from A, Cost (480)
------------------------------------------------------------------------
  >A (24)
      >X (24)
          >Y (40)
              >Z (48)
                  >C (40)
                      >M (64)
                          >N (72)
                              >O (80)
                                  >P (88)

## Chain from X, Cost (456)
------------------------------------------------------------------------
  >X (24)
      >Y (40)
          >Z (48)
              >C (40)
                  >M (64)
                      >N (72)
                          >O (80)
                              >P (88)

## Chain from Y, Cost (432)
------------------------------------------------------------------------
  >Y (40)
      >Z (48)
          >C (40)
              >M (64)
                  >N (72)
                      >O (80)
                          >P (88)

## Chain from D, Cost (392)
------------------------------------------------------------------------
  >D (48)
      >C (40)
          >M (64)
              >N (72)
                  >O (80)
                      >P (88)

## Chain from Z, Cost (392)
------------------------------------------------------------------------
  >Z (48)
      >C (40)
          >M (64)
              >N (72)
                  >O (80)
                      >P (88)

## Chain from B, Cost (376)
------------------------------------------------------------------------
  >B (32)
      >C (40)
          >M (64)
              >N (72)
                  >O (80)
                      >P (88)

## Chain from C, Cost (344)
------------------------------------------------------------------------
  >C (40)
      >M (64)
          >N (72)
              >O (80)
                  >P (88)

## Chain from M, Cost (304)
------------------------------------------------------------------------
  >M (64)
      >N (72)
          >O (80)
              >P (88)

## Chain from N, Cost (240)
------------------------------------------------------------------------
  >N (72)
      >O (80)
          >P (88)

## Chain from O, Cost (168)
------------------------------------------------------------------------
  >O (80)
      >P (88)

## Chain from P, Cost (88)
------------------------------------------------------------------------
  >P (88)

## Chain from INTERRUPT, Cost (0)
------------------------------------------------------------------------


The following functions were not resolved:
  memset

```


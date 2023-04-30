#!/bin/sh

./mads miniturbo.asm -o:miniturbo.bin
xxd -cols 16 -i miniturbo.bin > miniturbo.h
gcc -Wall -o miniturbo miniturbo.c
./miniturbo
atari800 MaxFlash1Mb.car

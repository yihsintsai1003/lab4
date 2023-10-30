#ifndef __FIR_H__
#define __FIR_H__

#define N 11

int taps[N] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
int inputbuffer[N];
int inputsignal[N] = {10,9,8,7,6,5,4,3,2,1,0};
int outputsignal[N];
#endif
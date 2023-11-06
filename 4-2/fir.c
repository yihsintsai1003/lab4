#include "fir.h"
#include <defs.h>

void __attribute__ ( ( section ( ".mprjram" ) ) ) initfir() {
	//initial your fir
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){
	initfir();
	//write down your fir
  reg_fir_data_length = 64;
  reg_fir_coeff_0 = 0;
  reg_fir_coeff_1 = -10;
  reg_fir_coeff_2 = -9;
  reg_fir_coeff_3 = 23;
  reg_fir_coeff_4 = 56;
  reg_fir_coeff_5 = 63;
  reg_fir_coeff_6 = 56;
  reg_fir_coeff_7 = 23;
  reg_fir_coeff_8 = -9;
  reg_fir_coeff_9 = -10;
  reg_fir_coeff_10 = 0;
  reg_fir_control = 1;
 	for (int i = 0; i < 64; i++) {
    x[i] = i;
    reg_fir_x = x[i];
    outputsignal[i] = reg_fir_y;
	}
  
	return outputsignal;
}
		
#include <stdio.h>

void halve_cats(int *ncats, int *catarray, double * halfcats, int *errflag){

	int i;

	printf("In C, we are going to halve %d cats\n",ncats[0]);

	for(i=0;i<ncats[0];i++){
		halfcats[i] = (float) catarray[i]/2.2;
		printf("ca = %d, hc = %0.3f\n",catarray[i],halfcats[i]);
	}
	errflag[0]=120;
}

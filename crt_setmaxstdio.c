// crt_setmaxstdio.c
#include <stdio.h>
int main() {
   printf("%d\n",_getmaxstdio());
   _setmaxstdio(2048);
   printf("%d\n",_getmaxstdio());
}
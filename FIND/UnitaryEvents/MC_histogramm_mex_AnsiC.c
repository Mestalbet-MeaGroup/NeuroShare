#include "mex.h"
#include<stdio.h>
#include<math.h>
#include <stdlib.h>

/* Format (MCS,rand_init,Experiment_set,Size_MCS_set,histogramm) */ 
 
#define xmax 2147483647
     


void make_hist(int MCS, int size_sample,int size_MCS_sam, double *y, double *h)

{
  register int sum ; 
  register int Index_number;
  register double Rand_norm;
  register int j;
  int i;

  
 Rand_norm=size_sample*1.0/(RAND_MAX);
  for ( i=1 ; i <= MCS ; ++i)
    {sum=0;
    
    for ( j=1 ; j <= size_MCS_sam; ++j)
      {Index_number=(rand()*(Rand_norm));
      sum=sum+*(y+Index_number);
      }
    *(h+sum)=*(h+sum)+1;
    }
}


/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double *y,*z,*h,bet,*iro;
  long   MCS;
  int    status,mrows_trail,ncols_trail,mrows_hist,ncols_hist,size_MCS_sample;
  long   rand_int;
  
  /*  check for proper number of arguments */
  if(nrhs!=5) 
    mexErrMsgTxt("Four inputs required. Format (MCS_steps,rand_init,Exp_set,Size_MCS_set,old_histogramm)");
  if(nlhs!=1) 
    mexErrMsgTxt("One output required. Format (MCS_steps,rand_init,Exp_set,Size_MCS_set,old_histogramm)");
  
  /* check to make sure the first input argument is a scalar */
  if( !mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) ||
      mxIsEmpty(prhs[0])    || mxIsComplex(prhs[0]) ||
      mxGetN(prhs[0])*mxGetM(prhs[0])!=1 ) {
    mexErrMsgTxt("Input x must be a scalar.");
  }
  
  /*  get the scalar input x */
  MCS					= mxGetScalar(prhs[0]);
  rand_int			= mxGetScalar(prhs[1]);
  size_MCS_sample	= mxGetScalar(prhs[3]);
  srand(rand_int);
  
  /*  create a pointer to the input matrix y */
  y 					= mxGetPr(prhs[2]);
  
  h 					= mxGetPr(prhs[4]);
  
  /*  get the dimensions of the matrix input y */
  mrows_trail 		= mxGetM(prhs[2]);
  ncols_trail 		= mxGetN(prhs[2]);
  
  mrows_hist  		= mxGetM(prhs[4]);
  ncols_hist  		= mxGetN(prhs[4]);
  if(size_MCS_sample>ncols_trail) 
    {mexErrMsgTxt("Exp. set has less Indices as the MCS_set. MCS_set_size=Exp_set size will be used");
	  size_MCS_sample=ncols_trail;}
  /*  set the output pointer to the output matrix */
  plhs[0] = mxCreateDoubleMatrix(1,ncols_hist, mxREAL);
  
  /*  create a C pointer to a copy of the output matrix */
  h  = mxGetPr(plhs[0]);
 

  make_hist(MCS,ncols_trail,size_MCS_sample,y,h);
}

#include <stdio.h>
#include "mex.h"
#include <math.h>
#include "matrix.h"


#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

// Global variables
int h_blk;
int w_blk;
int d_blk;
int h_array;
int w_array;
int d_array;
int N2;
double tau_match;
double* ref_blk = NULL;
double* array3D_in = NULL;
double* array3D_out = NULL;
vector<pair<float, unsigned> > patch_dist;

inline void get_dimensions( const mxArray* arr, int& a, int& b, int& c)
{
	int nd = mxGetNumberOfDimensions(arr);
	if( nd==3 )
	{
		a = mxGetDimensions(arr)[0];
		b = mxGetDimensions(arr)[1];
		c = mxGetDimensions(arr)[2];
	}
	else if( nd==2 )
	{
		a = mxGetM(arr);
		b = mxGetN(arr);
		c = 1;
	}
	else
		mexErrMsgTxt("only 2D and 3D arrays supported."); 
}

int closest_power_of_2( int n )
{
    int r = 1;
    while (r * 2 <= n)
        r *= 2;
    return r;
}

 bool ComparaisonFirst(pair<float,int> pair1, pair<float,int> pair2)
{
	return pair1.first < pair2.first;
}

void array_sorting()
{
	int h, w, d;
	double dist, diff;

	patch_dist.clear();
	for(d=0; d<d_array; d++)
	{
		dist = 0;
		for(h=0; h<h_blk; h++)
			for(w=0; w<w_blk; w++)
			{
				diff = array3D_in[d*h_blk*w_blk + w*h_blk + h]-ref_blk[w*h_blk + h];
				dist += diff*diff;
			}
		dist = dist/(h_blk*w_blk); 
		//if( dist < tau_match)
		{
			patch_dist.push_back(make_pair(dist, d));
		}
	}
    //N2 = (N2 > patch_dist.size() ?  closest_power_of_2(patch_dist.size()): N2);
	N2 = (N2 > (int)patch_dist.size() ?  (int)patch_dist.size(): N2);
	partial_sort(patch_dist.begin(), patch_dist.begin()+N2, patch_dist.end(), ComparaisonFirst);
}
void outputArray()
{
	int h, w, d, k;
	for(k=0; k<N2; k++)
	{
		d = patch_dist[k].second;
		for(h=0; h<h_blk; h++)
			for(w=0; w<w_blk; w++)
			{
				array3D_out[k*h_blk*w_blk + w*h_blk + h] = array3D_in[d*h_blk*w_blk + w*h_blk + h];
			}
	}
}


/////////////////////////
// Interface Function
/////////////////////////
void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
   
    /////////////////////
    // Inputs
    /////////////////////
    // Input 0: reference block
	get_dimensions(prhs[0], h_blk, w_blk, d_blk);
	ref_blk = mxGetPr(prhs[0]);

    // Input 1: 3D array
	get_dimensions(prhs[1], h_array, w_array, d_array);
    array3D_in  = mxGetPr(prhs[1]);
    
    // Input 2: N2 is the maximum number of similar patches
    N2 = mxGetScalar(prhs[2]);
    
    // Input 3: tau_match is the threshold for block matching
    tau_match = (double)mxGetScalar(prhs[3]);


	// do block matching and output the first N2 similar patches
	array_sorting();


    ////////////////////
    // Outputs
    ////////////////////
	// Output 0: the 3D array
	int dims[3] = {h_blk, w_blk, N2};
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
	array3D_out = mxGetPr(plhs[0]);
	memset(array3D_out, 0, h_blk*w_blk*N2*sizeof(double));   

	outputArray();

	}


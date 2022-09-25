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
int h_win;
int w_win;
int N2;
double tau_match;
double* ref_blk = NULL;
double* search_window = NULL;
double* array3D = NULL;
double* idx_r = NULL;
double* idx_c = NULL;
vector<pair<float, unsigned> > patch_dist;

inline void get_dimensions( const mxArray* arr, int& a, int& b)
{
	int nd = mxGetNumberOfDimensions(arr);
	if( nd==2 )
	{
		a = mxGetDimensions(arr)[0];
		b = mxGetDimensions(arr)[1];
	}
	else
		mexErrMsgTxt("only 2D supported."); 
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

void block_matching()
{
	int r, c, i, j;
	double dist, diff;

	patch_dist.clear();
	for(r=0; r<=h_win-h_blk; r++)
		for(c=0; c<=w_win-w_blk; c++)
		{
			dist = 0;
			for(i=0; i<h_blk; i++)
				for(j=0; j<w_blk; j++)
				{
					diff = search_window[(c+j)*h_win+(r+i)]-ref_blk[j*h_blk+i];
					dist += diff*diff;
				}
			dist = dist/(h_blk*w_blk); 
			//if( dist < tau_match)
			{
				patch_dist.push_back(make_pair(dist, c*h_win+r));
			}
		}
    //N2 = (N2 > patch_dist.size() ?  closest_power_of_2(patch_dist.size()): N2);
	N2 = (N2 > (int)patch_dist.size() ?  (int)patch_dist.size(): N2);
	partial_sort(patch_dist.begin(), patch_dist.begin()+N2, patch_dist.end(), ComparaisonFirst);
}
void outputArray()
{
	int r,c,i,j,k;
	for(k=0; k<N2; k++)
	{
		r = patch_dist[k].second%h_win;
		c = patch_dist[k].second/h_win;
		idx_r[k] = r;
		idx_c[k] = c;
		for(i=0; i<h_blk; i++)
			for(j=0; j<w_blk; j++)
			{
				array3D[h_blk*w_blk*k+j*h_blk+i] = search_window[(c+j)*h_win+(r+i)];
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
	get_dimensions(prhs[0], h_blk, w_blk);
	ref_blk = mxGetPr(prhs[0]);

    // Input 1: search window
	get_dimensions(prhs[1], h_win, w_win);
    search_window  = mxGetPr(prhs[1]);
    
    // Input 2: N2 is the maximum number of similar patches
    N2 = mxGetScalar(prhs[2]);
    
    // Input 3: tau_match is the threshold for block matching
    tau_match = (double)mxGetScalar(prhs[3]);


	// do block matching and output the first N2 similar patches
	block_matching();


    ////////////////////
    // Outputs
    ////////////////////
	// Output 0: the 3D array
	int dims[3] = {h_blk, w_blk, N2};
    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
	array3D = mxGetPr(plhs[0]);
	memset(array3D, 0, h_blk*w_blk*N2*sizeof(double));
    
	// Output 1: row index for each 2D matrix in the 3D array
	dims[0] = 1; dims[1] = 1;
	plhs[1] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
	idx_r = mxGetPr(plhs[1]);
	memset(idx_r, 0, 1*1*N2*sizeof(double));

	// Output 2: column index for each 2D matrix in the 3D array
	plhs[2] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
	idx_c = mxGetPr(plhs[2]);
	memset(idx_c, 0, 1*1*N2*sizeof(double));

	outputArray();

	}


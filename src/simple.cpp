#include <stdio.h>
#include <math.h>
#include "gen.h"
#include "gen_w.h"
#include "gen_io.h"

double
mysigmoid(double x)
{
	return 1.0 / (1.0 + exp(-x));
}

double
mytanh(double x)
{
	double a = exp(x);
	double b = exp(-x);

	return (a - b)/(a + b);
}

void
vtanh(double a[], int n)
{
    for (int i = 0; i < n; i++)
        a[i] = mytanh(a[i]);
}

void
vcp(double y[], double a[], int n)
{
    for (int i = 0; i < n; i++)
        y[i] = a[i];
}

void
vprint(char const *s, double a[], int n)
{
    printf("vprint(%s) ", s);
    for (int i = 0; i < n; i++)
        printf("%.8g ", (double)a[i]);
    putchar('\n');
}

void
vmul(double y[], double a[], double b[], int n)
{
    for (int i = 0; i < n; i++)
        y[i] = a[i] * b[i];
}

void
vmulsum(double y[], double a[], double b[], double c[], double d[], int n)
{
    for (int i = 0; i < n; i++)
        y[i] = a[i] * b[i] + c[i] * d[i];
}

void
vplusbias(double a[], double b, int n)
{
    for (int i = 0; i < n; i++)
        a[i] = a[i] + b;
}

/* apply sigmoid to a vector */
void
vsigmoid(double a[], int n)
{
    for (int i = 0; i < n; i++)
    	a[i] = mysigmoid(a[i]);
}

void
maxpb(double y[], double x[], double w[], double b[], const int ni, const int nj)
{
	double acc;

	// move clearing of y to inner loop to make a perfect loop
    for (int i = 0; i < ni; i++)
    	y[i] = b[i];
    axi: for (int i = 0; i < ni; i++)
    {
		axj: for (int j = 0; j < nj; j++)
		{
			y[i] += x[j] * w[i * nj + j];
		}
    }
}

/* 
** computes LSTM using x as the input vector and y as the output vector
** most variables are global to facilate 
** parameter passing and hardware implementation
*/
void
lstm(double c[], double h[], double x[])
{
    /* constant offsets used to access the i, j, f and o parts of r */
    #define	pi (r + 0 * L_YDIM)
    #define	pj (r + 1 * L_YDIM)
    #define	pf (r + 2 * L_YDIM)
    #define	po (r + 3 * L_YDIM)

    /* state information */
    static double new_c[L_YDIM];

    static double new_h[L_YDIM];
    static double xc[L_XDIM + L_YDIM];
    static double r[4 * L_YDIM];

    /* xc = np.hstack((x,  h)) */
    vcp((double *)xc, x, L_XDIM);
    vcp(xc + L_XDIM, h, L_YDIM);

    /* [i, j, f, o] = np.split(np.dot(xc, self.w) + self.b, 4) */
    maxpb(r, xc, (double *)l_w, l_b, 4 * L_YDIM, L_XDIM + L_YDIM);

    vplusbias(pf, 1.0, L_YDIM);
    vsigmoid(pf, L_YDIM);
    vsigmoid(pi, L_YDIM);
    vtanh(pj, L_YDIM);
    vmulsum(new_c, c, pf, pi, pj, L_YDIM);

    /* new_h = self.act(new_c) * sigmoid(o) */
    vcp(c, new_c, L_YDIM);	
    vtanh(new_c, L_YDIM);
    vsigmoid(po, L_YDIM);
    vmul(new_h, new_c, po, L_YDIM);	

    /* self.state = [new_c, new_h] */
    vcp(h, new_h, L_YDIM);
    vprint("y_pred", h, L_YDIM);
}

int
main()
{
    static double c[L_YDIM];
    static double h[L_YDIM];

    /* pass the input patterns to the lstm */
    for (int i = 0; i < L_PATS; i++) 
    {
        lstm(c, h, l_x[i]);
    }
    return 0;
}

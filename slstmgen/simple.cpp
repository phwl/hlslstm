#include <stdio.h>
#include <math.h>
#include "gen.h"
#include "gen_w.h"
#include "gen_io.h"

l_t
mysigmoid(l_t x)
{
	return 1.0 / (1.0 + exp(-x));
}

l_t
mytanh(l_t x)
{
	l_t a = exp(x);
	l_t b = exp(-x);

	return (a - b)/(a + b);
}

void
vtanh(l_t a[], int n)
{
    for (int i = 0; i < n; i++)
        a[i] = mytanh(a[i]);
}

void
vcp(l_t y[], l_t a[], int n)
{
    for (int i = 0; i < n; i++)
        y[i] = a[i];
}

void
vprint(char const *s, l_t a[], int n)
{
    printf("vprint(%s) ", s);
    for (int i = 0; i < n; i++)
        printf("%.8g ", (double)a[i]);
    putchar('\n');
}

void
vmul(l_t y[], l_t a[], l_t b[], int n)
{
    for (int i = 0; i < n; i++)
        y[i] = a[i] * b[i];
}

void
vmulsum(l_t y[], l_t a[], l_t b[], l_t c[], l_t d[], int n)
{
    for (int i = 0; i < n; i++)
        y[i] = a[i] * b[i] + c[i] * d[i];
}

void
vplusbias(l_t a[], l_t b, int n)
{
    for (int i = 0; i < n; i++)
        a[i] = a[i] + b;
}

/* apply sigmoid to a vector */
void
vsigmoid(l_t a[], int n)
{
    for (int i = 0; i < n; i++)
    	a[i] = mysigmoid(a[i]);
}

void
maxpb(l_t y[], l_t x[], l_t w[], l_t b[], const int ni, const int nj)
{
	l_t acc;

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
lstm(l_t c[], l_t h[], l_t x[])
{
    /* state information */
    static l_t new_c[L_YDIM];

    static l_t new_h[L_YDIM];
    static l_t xc[L_XDIM + L_YDIM];
    static l_t r[4 * L_YDIM];
    static l_t *i, *j, *f, *o;

    /* xc = np.hstack((x,  h)) */
    vcp((l_t *)xc, x, L_XDIM);
    vcp(xc + L_XDIM, h, L_YDIM);

    /* [i, j, f, o] = np.split(np.dot(xc, self.w) + self.b, 4) */
    maxpb(r, xc, (l_t *)l_w, l_b, 4 * L_YDIM, L_XDIM + L_YDIM);
    i = r + 0 * L_YDIM;
    j = r + 1 * L_YDIM;
    f = r + 2 * L_YDIM;
    o = r + 3 * L_YDIM;

    vplusbias(f, 1.0, L_YDIM);
    vsigmoid(f, L_YDIM);
    vsigmoid(i, L_YDIM);
    vtanh(j, L_YDIM);
    vmulsum(new_c, c, f, i, j, L_YDIM);

    /* new_h = self.act(new_c) * sigmoid(o) */
    vcp(c, new_c, L_YDIM);	
    vtanh(new_c, L_YDIM);
    vsigmoid(o, L_YDIM);
    vmul(new_h, new_c, o, L_YDIM);	

    /* self.state = [new_c, new_h] */
    vcp(h, new_h, L_YDIM);
    vprint("y_pred", h, L_YDIM);
}

int
main()
{
    static l_t c[L_YDIM];
    static l_t h[L_YDIM];

    /* pass the input patterns to the lstm */
    for (int i = 0; i < L_PATS; i++) 
    {
        lstm(c, h, l_x[i]);
    }
    return 0;
}

#include <stdio.h>
#include <math.h>

#define	N	4
#define wht_bfly(a, b) { tmp = a; a += b; b = tmp - b; }

/* integer log2 */
int l2 (int x)
{
  int l2;
  for (l2 = 0; x > 0; x >>=1)
    ++ l2;
  return (l2);
}

/* binary to Gray code */
unsigned int
b2g(unsigned int x)
{
  return (x >> 1) ^ x;
}

/* reverse indices */
unsigned int 
reverse(int bits, unsigned int num)
{
    unsigned int reverse_num = 0;
    int i;
    for (i = 0; i < bits; i++)
    {
        if((num & (1 << i)))
           reverse_num |= 1 << ((bits - 1) - i); 
   }
    return reverse_num;
}

/*
**	do a bit reversal of all elements of x[]
*/
void
inplacereverse(double x[], int n)
{
  int i, j;
  double tmp;

  for (i=0; i < n; i++)
  {
    j = reverse(l2(n) - 1, i);
    if (i < j)
    {
      tmp = x[i];
      x[i] = x[j];
      x[j] = tmp;
    }
  }
}


/*
** Fast in-place Walsh-Hadamard Transform 
** output is in Gray code order
*/

void FWHT (double x[], int n)
{
  double tmp;
  const int log2 = l2(n) - 1;
  int i, j, k;

  for (i = 0; i < log2; ++i)
  {
    for (j = 0; j < (1 << log2); j += 1 << (i+1))
    {
       for (k = 0; k < (1<<i); ++k)
       {
           wht_bfly(x[j + k], x[j + k + (1<<i)]);
       }
    }
  }
  inplacereverse(x, n);
}

int
main()
{
  double x[N];
  unsigned int i;

  for (i = 0; i < N; i++)
    x[i] = i;
  FWHT(x, N);
  for (i = 0; i < N; i++)
    printf("%d: %g\n", i, x[b2g(i)] / N);
  return 0;
}

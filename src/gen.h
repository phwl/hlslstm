#define nelts(x) (sizeof((x)) / sizeof((x)[0]))
#define L_XDIM 2
#define L_YDIM 3
#define L_PATS 4
extern void lstm(double c[L_YDIM], double h[L_YDIM], double x[L_XDIM]);
extern double l_x[4][2];
extern double l_y[4][3];

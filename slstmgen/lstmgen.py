import random

import numpy as np
import pdb
import math

def sigmoid(x):
    return 1. / (1 + np.exp(-x))

def vprint(s, a):
    s = 'vprint(%s) ' % s
    for x in a:
        s = s + ('%.8g ' % x)
    print(s)

# keeps track of declarations for the generated C source
class cgen:
    def __init__(self, xdim, ydim, tfvars, fname = 'gen'):
        self.fname = fname
        self.xdim = xdim
        self.ydim = ydim
        concatdim = xdim + ydim

        # weight matrices
        self.w = tfvars[0].eval()
        self.b = tfvars[1].eval()
        self.forget_bias = 1.0
        self.act = np.tanh

    def genarray(self, outvals, name, xa):
        def out1d(vec):	# print an array with appropriate separator
           s = ',\n'.join(map(lambda x: ('%.9e' % (x)), vec))
           return s
        pa = ' = {'
        if (xa.ndim == 1):
           ni = len(xa)
           p = 'l_t %s[%d]' % (name, ni)
           astr = out1d(xa)
        else:
           (ni, nj) = xa.shape
           p = 'l_t %s[%d][%d]' % (name, ni, nj)
           astr = ',\n'.join(map(out1d, [xa[i, :] for i in range(ni)]))
        if outvals: 	# print the actual array
           s = p + pa + astr + '};\n'
        else:		# print the declaration
           s = 'extern ' + p + ';\n'
        return(s)

    def genweights(self, outvals,  name, a):	# converts 2D array to n 1D ones
         (ni, nj) = a.shape
         # declarations
         s = ''
         for i in range(ni): s = s + self.genarray(outvals, 'l_wx%d' % i, a[i])
         return s

    def ff(self, x, state):
        c, h = state
        xc = np.hstack([x, h])
        r = np.split(np.dot(xc, self.w) + self.b, 4)
        vprint('w', np.ndarray.flatten(np.array(self.w)))
        vprint('r', np.ndarray.flatten(np.array(r)))
        [i, j, f, o] = r
        new_c = (c * sigmoid(f + self.forget_bias) + sigmoid(i) * self.act(j))
        vprint('new_c', new_c)
        new_h = self.act(new_c) * sigmoid(o)
        state = [new_c, new_h]
        vprint('y_pred', new_h)
        return new_h, state

    # generate a program with all the parameters and test set
    def gen(self, x, y):
        print('** Generating output file %s' % self.fname)

        # generate include file
        fh = open(self.fname + '.h', 'w')
        fh.write('#define nelts(x) (sizeof((x)) / sizeof((x)[0]))\n')
        fh.write('#define %s %d\n' % ('L_XDIM', self.xdim))
        fh.write('#define %s %d\n' % ('L_YDIM', self.ydim))
        fh.write('#define %s %d\n' % ('L_PATS', y.shape[0]))
        fh.write('typedef double l_t;\n')
        fh.write('extern void lstm(l_t c[L_YDIM], l_t h[L_YDIM], l_t x[L_XDIM]);\n')
        fh.write(self.genarray(0, "l_x", x))
        fh.write(self.genarray(0, "l_y", y))
        fh.close()


        fh = open(self.fname + '_w.h', 'w')
	# transpose w so we access adjacent elements for x * W
        fh.write(self.genarray(1, "l_w", np.transpose(self.w)))
        fh.write(self.genarray(1, "l_b", self.b))
        fh.close()

        fh = open(self.fname + '_io.h', 'w')
        fh.write(self.genarray(1, "l_x", x))
        fh.write(self.genarray(1, "l_y", y))
        fh.close()


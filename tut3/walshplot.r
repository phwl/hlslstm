# R implementations of the Rademacher and Walsh functions

bit <- function(n, b) {
  ifelse (bitwAnd(as.integer(n), bitwShiftL(1L, as.integer(b))) != 0, 1, 0);
}

walsh <- function(p, n, t) {
  w = 1
  for (r in 0:(p-1)) 
  {
    # cat(sprintf("n(%d)=%d\n", p-1-r, bit(n, p-1-r)))
    # cat(sprintf("t(%d)=%d\n", r, bit(t, r)))
    # cat(sprintf("t(%d)=%d\n", r+1, bit(t, r+1)))
    # cat(sprintf("exp=%d\n", (bit(n, p-1-r) * (bit(t, r) + bit(t, r + 1)))))
    pp = ((-1) ** (bit(n, p-1-r) * (bit(t, r) + bit(t, r + 1))))
    # cat(sprintf("pp=%d\n", pp))
    # cat(sprintf("w=%d\n", w))
    w = w * pp
  }
  return(w);
}

p = 3
n = 1
t = 1
# cat(sprintf("walsh(%d,%d)=%d\n", n, t, walsh(p, n, t)))

W = matrix(nrow=2**p, ncol=2**p)
if (TRUE) {
for (n in 0:(2**p-1)) {
  for (t in 0:(2**p-1)) {
    W[n+1,t+1] = walsh(p, n, t);
  }
}
}

require(stats);
require(graphics)
x <- seq.int(0, 1-1/120, 1/120)
library(splines2)
mat = bSpline(x, df = NULL, knots = NULL, degree = 7, intercept = TRUE,Boundary.knots = range(x, na.rm = TRUE))
matplot(x, mat, type = "l", ylab = "scaled I-spline basis")
write.csv(mat, file = 'splines0.5.csv')
x <- seq.int(0, 1-1/60, 1/60)
write.csv(mat, file = 'splines1.csv')

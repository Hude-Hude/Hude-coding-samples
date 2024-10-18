clear all
import delimited "data.txt", delimiter(" ")
rename v1 Y
rename v2 K
rename v3 L
rename v4 Z1
rename v5 Z2
gen y = log(Y)

nl(y = - 1/{rho = 1} * ln(K^(-1 * {rho}) + L^(-1 * {rho})))

/*
gmm ((y + 1/ {rho=-1} * ln(K^(-1 * {rho}) + L^(-1 * {rho})))), instruments(Z1 Z2) wmatrix(robust) winitial(identity)
*/



gmm  (y + 1/{rho= 1} * ln(K^(-1*{rho}) + L^(-1*{rho}))), instruments(Z1 Z2, noconstant) winitial(identity) onestep

gen u = y + 1/2.300487 * ln(K^(-2.300487) + L^(-2.300487))

mkmat u, matrix (U)
matrix U_tra = U'
mkmat Z1 Z2, matrix(Z)
matrix Z_tra= Z'

/*
matrix h = Z_tra * U
matrix h_tra = h'
matrix o = (1/1000) * h * h_tra
matrix o_inv = inv(o)
*/

matrix omega = 1000 * inv(Z_tra * U * U_tra * Z)
matrix omega_inv = inv(omega)

// mkmat Z1, matrix(Z1)
// mkmat Z2, matrix(Z2)
// mkmat u, matrix (U)
// matrix U_tra = U'
// mkmat h =( (U_tra * Z1)^2, U_tra * Z1 * U_tra * Z2\ U_tra * Z1 * U_tra * Z2, (U_tra * Z2)^)
// matrix o = h * h'
// matrix o_inv = inv(o)

gmm  (y + 1/{rho= 2.300487} * ln(K^(-1*{rho}) + L^(-1*{rho}))), instruments(Z1 Z2, noconstant) winitial(omega_inv) onestep 

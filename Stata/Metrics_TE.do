clear all

import delimited filpoll.txt, clear

rename a A
rename c C
rename d D
rename y Y

//2)
npregress kernel D A C
predict pscore_np

logit D A C
predict pscore_logit, pr

//3)
//assuming homogenous treatment effect
//Simple regression
regress Y D A C
//Matching estimator
teffects psmatch (Y) (D A C)
//Doubly estimator
teffects ipwra (Y) (D A C, logit)

//7)
//IV and LATE
gen Z = A >= 40

logit D C if Z == 0
predict ps_0, pr

logit D C if Z == 1
predict ps_1, pr

reg Y C if Z == 0
predict m0_x

reg Y C if Z == 1
predict m1_x 

gen wald = (m1_x - m0_x) / (ps_1 - ps_0)
display wald

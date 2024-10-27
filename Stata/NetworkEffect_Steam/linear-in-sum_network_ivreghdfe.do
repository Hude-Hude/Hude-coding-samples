clear all

use "/Users/kissshot894/Documents/MAE/MAThesis/Steam_Tables/Dataset_SteamNetwork.dta"

local depvar "owns_game"
local fe "steamid appid"
local regressors "avg_F_spend avg_F_num_friends avg_F_total_games"
local endog "num_F_own"
local instr "num_IF_own avg_IF_spend avg_IF_num_friends avg_IF_total_games sum_F_spend sum_F_num_friends sum_F_total_games"

* Baseline
ivreghdfe `depvar' `regressors' (`endog' = `instr'), absorb(`fe')

* only game FE to control correlated effect
ivreghdfe owns_game num_friend spend total_games sum_F_spend sum_F_num_friends sum_F_total_games avg_F_spend avg_F_num_friends avg_F_total_games (num_F_own = avg_IF_spend avg_IF_num_friends avg_IF_total_games), absorb(appid)

* J-test/overidentification test passed
ivreghdfe owns_game num_IF_own sum_F_spend sum_F_num_friends sum_F_total_games avg_F_spend avg_F_num_friends avg_F_total_games (num_F_own = avg_IF_spend avg_IF_num_friends avg_IF_total_games), absorb(steamid appid)

* Robust Variance
ivreghdfe owns_game num_IF_own sum_F_spend sum_F_num_friends sum_F_total_games avg_F_spend avg_F_num_friends avg_F_total_games (num_F_own = avg_IF_spend avg_IF_num_friends avg_IF_total_games), absorb(steamid appid) cluster(steamid)

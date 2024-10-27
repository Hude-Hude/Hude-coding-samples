clear all

 import delimited "/Users/kissshot894/Documents/MAE/MAThesis/Steam_Tables/Dataset_Final.csv", delimiter(comma) bindquote(nobind) stripquote(yes) stringcols(1) numericcols(2 9 10 11 12 13 14 15 16 17 18 19) 


rename v1 steamid
rename v2 appid
rename v3 owns_game
rename v4 num_friend
rename v5 total_games
rename v6 spend
rename v7 num_F_own
rename v8 num_IF_own
rename v9 avg_F_num_friends
rename v10 avg_F_total_games
rename v11 avg_F_spend
rename v12 avg_F_days_create
rename v13 avg_IF_num_friends
rename v14 avg_IF_total_games
rename v15 avg_IF_spend
rename v16 avg_IF_days_create
rename v17 sum_F_num_friends
rename v18 sum_F_total_games
rename v19 sum_F_spend
rename v20 title
rename v21 price
rename v22 rating
rename v23 genre
rename v24 developer
rename v25 publisher
rename v26 is_same_dev_pub
rename v27 days_release


replace avg_F_spend = 0 if avg_F_spend == .
replace avg_F_num_friends = 0 if avg_F_num_friends == .
replace avg_F_total_games = 0 if avg_F_total_games == .

replace avg_IF_spend = 0 if avg_IF_spend == .
replace avg_IF_num_friends = 0 if avg_IF_num_friends == .
replace avg_IF_total_games = 0 if avg_IF_total_games == .

replace sum_F_spend = 0 if sum_F_spend == .
replace sum_F_num_friends = 0 if sum_F_num_friends == .
replace sum_F_total_games = 0 if sum_F_total_games == .




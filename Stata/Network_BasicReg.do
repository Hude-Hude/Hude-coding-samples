clear all

* Import the CSV and specify that the first column (steamid) should be treated as a string
 import delimited "C:\MAE\Research\Dataset\Final_Sample_2.0.csv"


* Rename the variables
rename v1 steamid
rename v2 appid
rename v3 title
rename v4 price
rename v5 rating
rename v6 release_date
rename v7 owns_game
rename v8 num_friends_owning_game
rename v9 num_indirect_friends_owning_game
rename v10 avg_friends_days_since_creation
rename v11 days_since_release
rename v12 genre
rename v13 developer
rename v14 publisher
rename v15 is_same_dev_pub

encode steamid, gen(userid)

drop if price <= 0
gen log_price = log(price)
 


* Normalize rating
summarize rating
gen norm_rating = (rating - r(mean)) / r(sd)

* Normalize days_since_release
summarize days_since_release
gen norm_days_since_release = (days_since_release - r(mean)) / r(sd)


xtset userid appid

xtivreg owns_game (price num_friends_owning_game = is_same_dev_pub num_indirect_friends_owning_game avg_friends_days_since_creation) norm_rating norm_days_since_release i.genreid, fe vce(cluster steamid)


* First stage for num_friends_owning_game
regress num_friends_owning_game is_same_dev_pub i.genreid norm_rating norm_days_since_release num_indirect_friends_owning_game

* Save the residuals for num_friends_owning_game
predict network_residuals, resid

xtlogit owns_game log_price num_friends_owning_game log_price_residuals network_residuals i.genreid norm_rating norm_days_since_release, fe

xtprobit owns_game log_price num_friends_owning_game log_price_residuals network_residuals i.genreid norm_rating norm_days_since_release, fe





-- d7 특징
with d7_features as 
(select users.user_id, 
max(case when variant='control'and action='onboarding complete' then 'old_ob_complete'
when variant='variant 1' and action='onboarding complete' then 'new_ob_complete' end)as onboarding,
min(case when action='onboarding complete' then date_diff(action_date, created, day) end) as days_to_ob_from_created,
count(case when action='onboarding complete' then purchases.amount end) as count_purchases_d7,
sum(case when action='onboarding complete' then purchases.amount end) as purchases_amount_d7,
min(case when action='onboarding complete' then date_diff(purch_date, action_date, day) end) as days_to_purchase_from_ob

from fair-circuit-470204-b3.mobile_game.game_users as users 
left join fair-circuit-470204-b3.mobile_game.game_actions as actions on users.user_id = actions.user_id
left join fair-circuit-470204-b3.mobile_game.exp_assignment as exp on users.user_id = exp.user_id
left join fair-circuit-470204-b3.mobile_game.game_purchases as purchases on users.user_id = purchases.user_id

where date_diff(purchases.purch_date,users.created,day)<=7

group by 1
order by user_id),


-- LTV_D30(Y데이터)
ltv_d30 as
(select users.user_id, sum(purchases.amount) as LTV_D30

from fair-circuit-470204-b3.mobile_game.game_users as users left join fair-circuit-470204-b3.mobile_game.game_purchases as purchases
on users.user_id=purchases.user_id
where date_diff(purchases.purch_date,users.created,day)<=30

group by 1)


-- 메인쿼리
select users.*, d7_features.onboarding, d7_features.days_to_ob_from_created, d7_features.count_purchases_d7, d7_features.purchases_amount_d7,
d7_features.days_to_purchase_from_ob, ltv_d30.LTV_D30

from fair-circuit-470204-b3.mobile_game.game_users as users 
left join d7_features on users.user_id=d7_features.user_id
left join ltv_d30 on users .user_id=ltv_d30.user_id

order by user_id

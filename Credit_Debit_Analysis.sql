create database Credit_Debit_Analysis;
use Credit_Debit_Analysis;

select * from credit_debit_data;

update credit_debit_data
set Transaction_Date =STR_TO_DATE(Transaction_Date , '%d-%m-%Y');

alter table credit_debit_data
 modify  Transaction_Date date;
 
 
 # ------ Credit and Debit Analysis ----------
 -----------------------------------------------------------------------------------------------------------------------------------------------
 # 1. Total Credit Amount
 select  concat('₹ ',format(sum(Amount)/1000000,0), ' M') As Total_Cedit_Amount from credit_debit_data
 Where Transaction_Type ='Credit';
 -----------------------------------------------------------------------------------------------------------------------------------------------
  # 2. Total Debit Amount
 select  concat('₹ ',format(sum(Amount)/1000000,0),' M') As Total_Debit_Amount from credit_debit_data
 Where Transaction_Type ='Debit';
 -----------------------------------------------------------------------------------------------------------------------------------------------
 # 3. Credit to Debit Ratio
 select  round(sum(CASE when Transaction_Type = "Credit" then Amount else 0 END)/
		 nullif(sum(CASE when Transaction_Type = "Debit" then Amount else 0 END ),0),4) as Credit_Debit_Ratio
         from credit_debit_data;
-----------------------------------------------------------------------------------------------------------------------------------------------
# 4. Net Transaction Amount 
  select  concat('₹ ',format(sum(CASE when Transaction_Type = "Credit" then Amount else 0 END)-
		 (sum(CASE when Transaction_Type = "Debit" then Amount else 0 END )),0))
         as Net_Transaction_Amount
         from credit_debit_data;
-----------------------------------------------------------------------------------------------------------------------------------------------         
# 5. Account Activity Ratio
	select round(count(*) / (sum(Balance)),5) as Account_Activity_Ratio from credit_debit_data;
-----------------------------------------------------------------------------------------------------------------------------------------------    
# 6. Transactions per Day/Week/Month
	#  Total transactions per Day
		select date(Transaction_Date) as date, Dayname(Transaction_Date) as Day,count(*) as Total_transactions
		from credit_debit_data
		group by date(Transaction_Date), Day
		order by date, Day;
	# Total Transactions per Week
		select year(Transaction_Date) as Year, week(Transaction_Date,3) as Week , count(*) as Total_transactions
		from credit_debit_data
		group by  Year,week(Transaction_Date,3) # week(date,3) count weeks starting from monday, 1st week of the year has atleat 4 days
		order by Week;
	# Total Transactions per Month
		select date_format(Transaction_Date,'%M') as Month_name , count(*) as Total_transactions
			from credit_debit_data
			group by month(Transaction_Date), Month_name
			order by month(Transaction_Date);
 -----------------------------------------------------------------------------------------------------------------------------------------------   
# 7. Total Transaction Amount By Branch
	select Branch , concat('₹ ',format(sum(Amount),0)) as Total_Transaction_Amount
    from credit_debit_data
    group by Branch
    order by Total_Transaction_Amount Desc;
 -----------------------------------------------------------------------------------------------------------------------------------------------   
# 8. Total Transaction Amount By Bank
	select Bank_Name , concat('₹ ',format(sum(Amount),0)) as Total_Transaction_Amount
    from credit_debit_data
    group by Bank_Name
    order by Total_Transaction_Amount Desc;
 -----------------------------------------------------------------------------------------------------------------------------------------------   
#  Total Transaction Amount By Bank and branch
	select Bank_Name ,Branch, concat('₹ ',format(sum(Amount),0)) as Total_Transaction_Amount
    from credit_debit_data
    group by Bank_Name,Branch
    order by Bank_Name,Total_Transaction_Amount Desc;
 -----------------------------------------------------------------------------------------------------------------------------------------------   
# 9. Transaction Method Distribution
	select Transaction_Method, format(count(*),0) as total_transactions ,
		 concat(round(count(*)*100.0/ (select count(*) from credit_debit_data),2) ,' %') as percentage
		 from credit_debit_data
		 group by Transaction_Method
		 Order By percentage desc;
 -----------------------------------------------------------------------------------------------------------------------------------------------
 # 10. Branch Transaction Growth
	with Branch_Monthly as (
							select Branch,
							date_format(Transaction_Date,'%M') as Month_name ,
                             month(Transaction_Date) as month_num,
							format(sum(Amount),0) as Total_Amount
							from credit_debit_data
							group by Branch ,Month(Transaction_Date),Month_name 
		)
		select Branch , Month_name , Total_Amount,
        LAG(Total_Amount) over (Partition by Branch order by Month_num) as Prev_month_Amount,
       concat( round((Total_Amount - LAG(Total_Amount) over (Partition by Branch order by Month_num))
        /nullif(LAG(Total_Amount) over (Partition by Branch order by Month_num),0) *100,2),' %') as Percentage_Change
        from Branch_Monthly
        order by Branch , Month_num;
 -----------------------------------------------------------------------------------------------------------------------------------------------       
# 11. High_risk Transaction Flag

	select *,case when amount> 4500 then 'High-Risk'
			  else 'Normal'
              end as Risk_Flag from credit_debit_data;
-----------------------------------------------------------------------------------------------------------------------------------------------
# 12. Suspicious Transactions Frequency
	select monthname(Transaction_Date) as month_name ,count(*) as Suspicious_transactions_count
    from credit_debit_data
    where amount>4500
    group by  month(Transaction_Date),month_name
    order by month(Transaction_Date), month_name ;

    
 
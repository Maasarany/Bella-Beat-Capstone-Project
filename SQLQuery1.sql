create database fitbit_case2;
use fitbit_case2;
go
--show one row of data in every table
select top 1 * from Daily_Activity;
select top 1 * from Daily_Intensities;
select top 1 * from Daily_Calories;
select top 1 * from Hourly_Calories;
select top 1 * from Hourly_Steps;
select top 1 * from Hourly_Intensities;
select top 1 * from Sleep_Day;
go
-- check for duplicate and remove it
go
--Sleep_Day
select Id,SleepDay,TotalSleepRecords,TotalMinutesAsleep,TotalTimeInBed
from [dbo].[Sleep_Day]
group by Id,SleepDay,TotalSleepRecords,TotalMinutesAsleep,TotalTimeInBed
Having count(*)>1
go 

--check if the count of each row is more than one or not by using CTE and window function then deleting it
with Dupl (Id,SleepDay,TotalSleepRecords,TotalMinutesAsleep,TotalTimeInBed,dupl_count)
AS (
select 
	Id,
	SleepDay,
	TotalSleepRecords,
	TotalMinutesAsleep,
	TotalTimeInBed,
	ROW_Number() over (PARTITION by Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed 
		order by Id)						AS dupl_count  
		from [Sleep_Day]
						)
			delete from Dupl
				where dupl_count>1
go
 --Table Daily_Activity
select Id,ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories
from [dbo].[Daily_Activity]
group by Id,ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories
Having count(*)>1
go 
 --Table Daily_Intensities

select Id,ActivityDay,SedentaryMinutes,LightlyActiveMinutes,FairlyActiveMinutes,VeryActiveMinutes,SedentaryActiveDistance,LightActiveDistance,ModeratelyActiveDistance,VeryActiveDistance
from [dbo].[Daily_Intensities]
group by Id,ActivityDay,SedentaryMinutes,LightlyActiveMinutes,FairlyActiveMinutes,VeryActiveMinutes,SedentaryActiveDistance,LightActiveDistance,ModeratelyActiveDistance,VeryActiveDistance
Having count(*)>1
go 
 --Table Hourly_Calories
 select Id,ActivityHour,Calories
 from [dbo].[Hourly_Calories]
group by Id,ActivityHour,Calories
Having count(*)>1
go
 --Table Hourly_Steps
 select Id,ActivityHour,StepTotal
 from [dbo].[Hourly_Steps]
group by Id,ActivityHour,StepTotal
Having count(*)>1
go

--Table Daily_Calories
 select Id,ActivityDate,Calories
 from Daily_Activity
group by Id,ActivityDate,Calories
Having count(*)>1
go

 --Table Hourly_Intensities
 select Id,ActivityHour,TotalIntensity,AverageIntensity
 from [dbo].[Hourly_Intensities]
group by Id,ActivityHour,TotalIntensity,AverageIntensity
Having count(*)>1
go 
select DATENAME(YY,ActivityDate) AS YY,DATENAME(MM,ActivityDate) AS MM,DATENAME(DW,ActivityDate) AS weekday,Id,count(Id) AS count_of_login
from Daily_Activity
group by Id,DATENAME(YY,ActivityDate),DATENAME(MM,ActivityDate),DATENAME(DW,ActivityDate)
go 


--calculate for sum of steps and sedentary
select DA.Id , sum(DA.TotalSteps) AS Tot_Steps , Sum(DI.SedentaryMinutes) AS SED_MIN	
from Daily_Activity AS DA
inner join 
Daily_Intensities AS DI 
on DA.Id = DI.Id 
and DA.ActivityDate = DI.ActivityDay
group by DA.Id
go 

--calculate for sum of steps and calories_
select DA.Id , sum(DA.TotalSteps) AS Tot_Steps ,round(sum(DA.TotalDistance),2) AS Tot_Dis , Sum(HC.Calories) AS TotCalo, datename(dw,HC.ActivityHour) AS week_day
from Daily_Activity AS DA
	inner join 
		Hourly_Calories AS HC
	on DA.Id = HC.Id 
		and datename(dw,DA.ActivityDate)=datename(dw,HC.ActivityHour)
group by DA.Id,datename(dw,HC.ActivityHour)
order by Tot_Dis,TotCalo
go 
--show avg number of login
select avg(Id_count) AS AVG_LOGIN
from (
select count(Id) as Id_count
from Daily_activity) AS T
go
--count of log in per day
select DATENAME(dw,ActivityDate) AS Week_Day , count(Id) AS ID_Count
from Daily_Activity 
group by DATENAME(dw,ActivityDate)
go
--count of total min sleep
select Id,DATENAME(dw,SleepDay) AS Week_day , Sum(TotalMinutesAsleep) As Tot_min
from Sleep_Day 
group by Id,DATENAME(dw,SleepDay)
go

--see who is most active Id 
select top 1  Id,DATENAME(dw,ActivityDate) AS Week_day,SUM(TotalSteps) AS Tot_Steps , SUM(Calories) AS Tot_Calories 
from Daily_Activity 
group by Id,DATENAME(dw,ActivityDate)
order by Tot_Calories desc
go 

 -- most active hour
 select HC.Id, DAtename	(hh,HC.ActivityHour) AS Hour1, HC.Calories,HS.StepTotal,HI.TotalIntensity
 from Hourly_Calories AS HC 
	join Hourly_Steps AS HS
	on HC.Id=HS.Id
	join Hourly_Intensities AS HI
	on HC.Id=HI.Id
	group by HC.Id, DAtename(hh,HC.ActivityHour), HC.Calories,HS.StepTotal,HI.TotalIntensity
go


	





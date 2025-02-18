create database cancer;
use cancer;
CREATE TABLE lung_cancer_data (
    ID INT PRIMARY KEY,
    Country VARCHAR(255),
    Population_Size INT,
    Age INT,
    Gender VARCHAR(10),
    Smoker VARCHAR(3),
    Years_of_Smoking INT,
    Cigarettes_per_Day INT,
    Passive_Smoker VARCHAR(3),
    Family_History VARCHAR(3),
    Lung_Cancer_Diagnosis VARCHAR(3),
    Cancer_Stage VARCHAR(50),
    Survival_Years INT,
    Adenocarcinoma_Type VARCHAR(50),
    Air_Pollution_Exposure VARCHAR(10),
    Occupational_Exposure VARCHAR(3),
    Indoor_Pollution VARCHAR(3),
    Healthcare_Access VARCHAR(50),
    Early_Detection VARCHAR(3),
    Treatment_Type VARCHAR(50),
    Developed_or_Developing VARCHAR(50),
    Annual_Lung_Cancer_Deaths INT,
    Lung_Cancer_Prevalence_Rate FLOAT,
    Mortality_Rate FLOAT
);
load data infile
"D:\lung_cancer_Dataset_final_cleaned.csv"
into table lung_cancer_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows

select * from lung_cancer_data;


-- Basic Level
-- 1. Retrieve all records for individuals diagnosed with lung cancer.
select *
from lung_cancer_data
where lung_cancer_diagnosis = 'yes';

-- 2. Count the number of smokers and non-smokers.
select smoker , count(*) as total_count
from lung_cancer_data
group by smoker;

-- 3. List all unique cancer stages present in the dataset.
select distinct cancer_stage
from lung_cancer_data;

-- 4. Retrieve the average number of cigarettes smoked per day by smokers.
SELECT avg(cigarettes_per_day) as cigarettes_smoked_per_day , smoker
from lung_cancer_data
where smoker = 'yes';

-- 5. Count the number of people exposed to high air pollution.
select count(*) as high_air_pollution
from lung_cancer_data
where Air_Pollution_Exposure = 'high';

-- 6. Find the top 5 countries with the highest lung cancer deaths.
select country , sum(Annual_Lung_Cancer_Deaths) as total_lung_cancer_deaths
from lung_cancer_data
group by country
order by  total_lung_cancer_deaths desc
limit 5;

-- 7. Count the number of people diagnosed with lung cancer by gender.
select count(*) as total_count , gender
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by gender;

-- 8. Retrieve records of individuals older than 60 who are diagnosed with lung cancer.
select *
from lung_cancer_data
where age > 60 and lung_cancer_diagnosis = 'yes';



-- Intermediate Level
-- 1. Find the percentage of smokers who developed lung cancer.
select
(count(case when smoker = 'yes' and lung_cancer_diagnosis = 'yes' then 1 end) * 100.0 /
(count(case when smoker = 'yes'  then 1 end))) as smoker_lung_cancer_percentage
from lung_cancer_data;

-- 2. Calculate the average survival years based on cancer stages.
select cancer_stage, avg(Survival_Years) as avg_survival_year 
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by cancer_stage
order by avg_survival_year asc;

-- 3. Count the number of lung cancer patients based on passive smoking.
select count(*) as lung_cancer_patients , passive_smoker
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by passive_smoker;

-- 4. Find the country with the highest lung cancer prevalence rate.
select country , max(Lung_Cancer_Prevalence_Rate) as highest_lung_cancer_prevalence_rate
from lung_cancer_data
group by country
order by highest_lung_cancer_prevalence_rate asc
limit 1;

-- 5. Identify the smoking years' impact on lung cancer.
select  Years_of_Smoking, count(*) as impact_lung_cancer
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by years_of_smoking
order by Years_of_Smoking asc;

-- 6. Determine the mortality rate for patients with and without early detection.
select early_detection ,
(count(case when lung_cancer_diagnosis = 'yes' and survival_years = 1 then 1 end) * 100.0 /
(count(case when lung_cancer_diagnosis = 'yes' then 1 end))) as mortality_rate
from lung_cancer_data
group by early_detection;

-- 7. Group the lung cancer prevalence rate by developed vs. developing countries.
select developed_or_developing , avg(Lung_Cancer_Prevalence_Rate) as avg_prevalence_rate
from lung_cancer_data
group by developed_or_developing;

-- Advanced Level
-- 1. Identify the correlation between lung cancer prevalence and air pollution levels.
SELECT (SUM(Lung_Cancer_Prevalence_Rate * pollution_score) - (SUM(Lung_Cancer_Prevalence_Rate) * SUM(pollution_score)) / COUNT(*)) /
SQRT((SUM(Lung_Cancer_Prevalence_Rate * Lung_Cancer_Prevalence_Rate) - (SUM(Lung_Cancer_Prevalence_Rate) * SUM(Lung_Cancer_Prevalence_Rate)) / COUNT(*)) *
(SUM(pollution_score * pollution_score) - (SUM(pollution_score) * SUM(pollution_score)) / COUNT(*))) AS correlation
FROM (
select Lung_Cancer_Prevalence_Rate, 
CASE WHEN Air_Pollution_Exposure = 'High' THEN 3
	WHEN Air_Pollution_Exposure = 'Medium' THEN 2
	WHEN Air_Pollution_Exposure = 'Low' THEN 1
	ELSE NULL  -- Handle missing values
END AS pollution_score
fROM lung_cancer_data
WHERE Lung_Cancer_Diagnosis = 'yes'
)AS pollution_data;

--no corr() function support here so we need to use formula persona correlation manually 
simple formula for calculating the correlation between Lung Cancer Prevalence Rate and Air Pollution Exposure:
X = Lung Cancer Prevalence Rate
Y = Air Pollution Exposure (Converted to Numeric Values: High = 3, Medium = 2, Low = 1)
N = Total Number of Records
r = Correlation Coefficient (Range: -1 to 1)
+1 → Strong Positive Correlation
0 → No Correlation
-1 → Strong Negative Correlation

-- 2. Find the average age of lung cancer patients for each country.
select country , round(avg(age),2) as age_lung_cancer_patients
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by country ;

-- 3. Calculate the risk factor of lung cancer by smoker status, passive smoking, and family history.
select count(*) as risk_factor , smoker, passive_smoker, family_history
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by smoker, passive_smoker, family_history;

-- 4. Rank countries based on their mortality rate.
with countries_mortality as (
select country , sum(lung_cancer_diagnosis = 'yes') as death_counts , 
sum(Lung_Cancer_Prevalence_Rate) / count(*) as mortality_rate
from lung_cancer_data
group by country)
select rank() over(order by  mortality_rate desc) as countries_rank , country
from countries_mortality;

-- 5. Determine if treatment type has a significant impact on survival years.
select treatment_type , avg(survival_years) as survival
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by treatment_type;

-- 6. Compare lung cancer prevalence in men vs. women across countries.
select country,
round(avg(case when gender = 'male' then lung_cancer_prevalence_rate end),2) as men_prevalence,
round(avg(case when gender = 'female' then lung_cancer_prevalence_rate end),2) as female_prevalence
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by country;

-- 7. Find how occupational exposure, smoking, and air pollution collectively impact lung cancer rates.
select occupational_exposure ,smoker , air_pollution_exposure ,round(avg(lung_cancer_prevalence_rate),2) as impact_lung_cancer_rates
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by occupational_exposure ,smoker , air_pollution_exposure
order by impact_lung_cancer_rates desc;

-- 8. Analyze the impact of early detection on survival years.
select  early_detection ,avg(survival_years) as survive
from lung_cancer_data
where lung_cancer_diagnosis = 'yes'
group by early_detection
order by survive desc;



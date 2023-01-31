select * From Covidcases
select * From CovidVaccinations

-- AGGREGATE FUNCTIONS

-- checking total no.of records:

select count(*) From Covidcases
select count(*) From CovidVaccinations

--GLOBAL NUMBERS
--Total No.of cases in the world as of 13-jan_2023
select 
     Max(total_cases) As Total_Cases
From Covidcases

--Total Cases Vs Population
select 
     Max(Population) As Population,
     Max(total_cases) As Total_Cases
From Covidcases

-- USING GROUP BY
--total No.of cases in the world countrywise
select 
     location,
     Max(total_cases) As Total_Cases
From Covidcases
Group by location

--Total Cases Vs Total Deaths CountryWise
select 
     location,
     Max(total_cases) As Total_Cases,
	 Max(total_deaths) As Total_Deaths
From Covidcases
Group by location

--countries with highest infection rate
select 
     location,
	 population,
     Max(total_cases) As Highest_Infection_count,
	 Max((total_cases/population))*100 as Highest_Infection_Rate
From Covidcases
Group by 1,2
having location is not null
Order By Highest_Infection_Rate Desc

--Showing continents with highest deaths
select 
    Distinct Continent,
	Population,
     Max(cast (total_deaths As int)) As Highest_Deaths
From Covidcases
Where total_deaths is not null
Group by 1,2
having Continent is not null
Order By  Highest_Deaths Desc

--Total cases In India:
select 
      Location,
	  max(total_cases) As Total_Cases
From Covidcases
Group by location
Having location like 'India%'

-- JOINS
-- Joinig Two tables

Select * 
From CovidCases CC
Inner Join  CovidVaccinations CV
On CC.serial_code=CV.serial_code

-- Total Population Vs Total Cases Vs Total Vaccinnations

Select Continent,
       Max(CC.population) As Total_Population,
       Max(CC.total_cases) as Total_Cases,
       Max(total_vaccinations) as Total_Vaccinations
From CovidCases CC
Inner Join  CovidVaccinations CV
On CC.serial_code=CV.serial_code
Group by 1

-- SUB QUERY
-- WINDOW FUNCTIONS
--Total Population Vs People_Vaccinated

Select Continent,
       Max(population) As Total_Population,
       Max(total_cases) as Total_Cases,
       People_vaccinated_fully
From (Select *,
	         Max(cast(CV.people_fully_vaccinated as bigint)) over(partition by CC.continent order by continent) As people_vaccinated_fully
	  From CovidCases CC
      Inner Join  CovidVaccinations CV
      On CC.serial_code=CV.serial_code) X
Group by 1,4	  

--COMMON TABLE EXPRESSION (CTE)
-- Rolling New Vaccinations Count And Highest Total Vaccinations

With  PopVac As 
( 
	Select CC.continent,
	       CC.location,
	       CC.population,
	       CC.date,
	       CC.total_cases,
	       CC.total_deaths,
	       CV.total_vaccinations,
	       Round((total_deaths/population)*100,2) As Death_Rate,
	       Round((total_vaccinations/population)*100,2) As Vaccination_Rate,
	       Sum(cast(CV.new_vaccinations as bigint)) Over (Partition by CC.continent, CC.Location Order by CC.Continent) As Rolling_Vaccination_Count,
	       Max(cast(CV.total_vaccinations as bigint)) Over (Partition by CC.continent, CC.Location Order by CV.total_vaccinations desc) As Highest_Total_vaccinations
From CovidCases CC
Inner Join CovidVaccinations CV
On CC.serial_code=CV.serial_code
)
Select *,
      Round((Rolling_Vaccination_Count/population)*100,2) As Rolling_People_Vaccination_Rate
From PopVac
--Where total_vaccinations IS NOT NULL  
--And location like 'India%'

--CREATING TEMPORARY TABLE USING TEMP TABLE

DROP Table if exists CovidStats
Create Temp table CovidStats
(
continent varchar(255),
location varchar(255),
population bigint,
date date,
total_cases bigint,
total_deaths bigint,
total_vaccinations bigint,
death_rate numeric,
vaccination_rate numeric,
rolling_vaccination_count numeric,
highest_total_vaccinations bigint
)

-- Inserting Data Into Temp table

Insert Into CovidStats
Select CC.continent,
	       CC.location,
	       CC.population,
	       CC.date,
	       CC.total_cases,
	       CC.total_deaths,
	       CV.total_vaccinations,
	       Round((total_deaths/population)*100,2) As Death_Rate,
	       Round((total_vaccinations/population)*100,2) As Vaccination_Rate,
	       Sum(cast(CV.new_vaccinations as bigint)) Over (Partition by CC.continent, CC.Location Order by CC.Continent) As Rolling_Vaccination_Count,
	       Max(cast(CV.total_vaccinations as bigint)) Over (Partition by CC.continent, CC.Location Order by CV.total_vaccinations desc) As Highest_Total_vaccinations
From CovidCases CC
Inner Join CovidVaccinations CV
On CC.serial_code=CV.serial_code

Select * From CovidStats

-- VIEW
--Creating VIEW To Store Data for Later Visualization

Create View CovidStats As
Select CC.continent,
	       CC.location,
	       CC.population,
	       CC.date,
	       CC.total_cases,
	       CC.total_deaths,
	       CV.total_vaccinations,
	       Round((total_deaths/population)*100,2) As Death_Rate,
	       Round((total_vaccinations/population)*100,2) As Vaccination_Rate,
	       Sum(cast(CV.new_vaccinations as bigint)) Over (Partition by CC.continent, CC.Location Order by CC.Continent) As Rolling_Vaccination_Count,
	       Max(cast(CV.total_vaccinations as bigint)) Over (Partition by CC.continent, CC.Location Order by CV.total_vaccinations desc) As Highest_Total_vaccinations
From CovidCases CC
Inner Join CovidVaccinations CV
On CC.serial_code=CV.serial_code

Select * from CovidStats;


































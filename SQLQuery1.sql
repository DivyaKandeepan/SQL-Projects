--Dispay data
select*from coviddata..coviddeaths
-- this where condition helps to removes the  continent from location column 
--eg. we need only coutries like india and more world, north america etc..
where continent is not null 
order by 3,4

--SELECTING A DATA THAT WE GOING TO START WITH

select location,date,total_cases,new_cases,total_deaths,population 
from coviddata..coviddeaths order by 1,2

-- COUNTRY AND THERE HIGHEST INFECTED RATE

select location,population,max(total_cases) Highest_infected_rate from coviddata..coviddeaths
where continent is not null
group by location,population 
order by  Highest_infected_rate desc;


-- COUNTRY AND THERE HIGHEST DEATH RATE

select location,population,max(cast(total_deaths as int)) Highest_death_rate from coviddata..coviddeaths
where continent is not null
group by location,population 
order by  Highest_death_rate desc;

--TOTAL CASES VS TOTAL DEATHS

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddata..coviddeaths
where continent is not null
order by 1,2 

--SORT BY THERE LOCATION AND WHEN THE CASES STARED TO RISE

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as population_percentage
from coviddata..coviddeaths where location like '%India%' 
and total_cases is not null 
and continent is not null 
order by 1,2 

--TOTAL CASES VS POPULATION
--showS what persentage of population got affected
select location,date,total_cases,population,(total_cases/population)*100 as deathpercentage
from coviddata..coviddeaths where location like '%India%' and total_deaths is not null and
continent is not null
order by 1,2 

--LISTING COURTIES HAVE HIGHEST INFECTED RATE COMPARED TO POPULATION

select location,population,date,max(total_cases) highest_infected_rate,max((total_cases/population))*100 as highest_infected_percentage
from coviddata..coviddeaths

--where location like '%India%'
group by location,population,date
order by highest_infected_percentage desc;

select location,population,max(total_cases) highest_infected_rate,max((total_cases/population))*100 as highest_infected_percentage
from coviddata..coviddeaths
where continent is not null 
--where location like '%India%'
group by location,population
order by highest_infected_percentage desc;

--LISTING COUNRIES HAVE HIGHEST DEATH RATE COMPARED TO POPULATION

--(we using cast because total_deaths is nvarchar date so it doesn't corret values when we perform aggregate function so we used cast to convert into int)
select location,population,max(cast(total_deaths as int)) Highest_death_rate,Max(cast(total_deaths as int)*100) as population_percentage_death_cases
from coviddata..coviddeaths 
--where location like '%India%'
where continent is not null
group by location,population
order by population_percentage_death_cases desc

--CONTINENTS DATASET

--(select continent from protofolio..coviddeaths group by continent;
--select location,continent from protofolio..coviddeaths group by location,continent order by continent;)

--continent with the highest death count
select continent,max(cast(total_deaths as int)) Highest_death_rate,max(((cast(total_deaths as int))/total_cases)*100) as population_percentage_death_cases
from coviddata..coviddeaths 
--where location like '%India%'
where continent is  not null
group by continent
order by population_percentage_death_cases desc


--listing continent, have Highest infected rate compared to population
select continent,max(total_cases) highest_infected_rate,max((total_cases/population))*100 as highest_infected_percentage
from coviddata..coviddeaths
where continent is not null 
--where location like '%India%'
group by continent
order by highest_infected_percentage desc;

--GLOBAL NUMBERS

-- total_cases,total_deaths,death_ percentage of world

select sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100
death_percentage from coviddata..coviddeaths
where continent is not null
--group by date(each day total_cases)
order by 1,2

--looking at total population vs vaccinations
--rolling down vaccinations

--( partitition is used because every time it gets a new location we want the count to start over)

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) number_of_people_vaccinated_till_date
from coviddata..coviddeaths cd join coviddata..covidvaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cd.continent is not null
 order by 2,3

 --(you can use CTE or temp because we can perform a aggregate funtion in this column we created)
 --USE CTE
 with popvac(continent,location,date,population,new_vaccinations,number_of_people_vaccinated_till_date)
 as
 (
 select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) 
over (partition by cd.location order by cd.location,cd.date) number_of_people_vaccinated_till_date
from coviddata..coviddeaths cd join coviddata..covidvaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cd.continent is not null
 )
 select*,(number_of_people_vaccinated_till_date/population)*100 from popvac

 --TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddata..coviddeaths dea
Join coviddata..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) number_of_people_vaccinated_till_date
from coviddata..coviddeaths cd 
join coviddata..covidvaccinations cv
 on cd.location=cv.location and cd.date=cv.date
 where cd.continent is not null








 --






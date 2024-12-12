select * from ProtifolioProject..CovidDeaths
order by 3,4 

--select * from ProtifolioProject..CovidVaccinations
--order by 3,4 

-- select Data that we are going to be using 

select location, date, total_cases,new_cases,total_deaths,population
from ProtifolioProject..CovidDeaths
order by 1,2



-- lokking at atotal cases vs total Deaths 
-- shows likelihood of dying if you contract covid in your country 


select location, date, total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
from ProtifolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- looking at total cases vs population 
-- shows what percentage of population got covid
select location, date,population ,total_cases,(total_cases/population)* 100 as DeathPercentage
from ProtifolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- looking at countries with Highest infection Rate compared to population 

select location ,population , Max(total_cases ) as HighestInfectionCount , Max((total_cases/population )) * 100 as percentPopulationInfected  
from ProtifolioProject..CovidDeaths
group by  location , population 
order by percentPopulationInfected desc

-- showing Countries with Highest Death count per population 

select location ,max(cast (total_deaths as int)) as totalDeathsCount 
from ProtifolioProject..CovidDeaths
group by  location  
order by totalDeathsCount desc

-- let's discover the data where we need the country only 
create view  onlyContry  as
select * 
from ProtifolioProject..CovidDeaths
where continent is not null

---
select * 
from onlyContry

-- let's Break down by continet 

select continent ,max(cast (total_deaths as int)) as totalDeathsCount 
from ProtifolioProject..CovidDeaths
where continent is  not null
group by  continent  
order by totalDeathsCount desc


-- showing Countries with Highest Death count per population 

select location ,max(cast (total_deaths as int)) as totalDeathsCount 
from onlyContry
group by  location  
order by totalDeathsCount desc



-- showing contintents with the highest death count per population
select continent ,max(cast (total_deaths as int)) as totalDeathsCount 
from ProtifolioProject..CovidDeaths
where continent is  not null
group by  continent  
order by totalDeathsCount desc



-- Global numbers 

select date , sum(new_cases) as sum_new_cases , sum(cast(new_deaths as int)) as sum_deaths,sum(cast(new_deaths as int))/sum(new_cases) as 
Deathpercentage
from onlyContry
group by date 
order by 1,2 

-- the total numbers 

select  sum(new_cases) as sum_new_cases , sum(cast(new_deaths as int)) as sum_deaths,sum(cast(new_deaths as int))/sum(new_cases) as 
Deathpercentage
from onlyContry
order by 1,2 


-- let's go to the anthor table covidvaccinations 

select * 
from ProtifolioProject..CovidVaccinations

-- join 
select * 
from ProtifolioProject..CovidDeaths   dea
join ProtifolioProject ..CovidVaccinations  vac
on dea.location = vac .location 
and dea.date = vac.date 

-- looking at Total population vs Vaccinations 

select  dea.continent , dea.location,dea.date , dea.population , vac.new_vaccinations 
,sum(convert ( int , vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date)
as RollingPeoplevaccinated 
from ProtifolioProject..CovidDeaths dea
join ProtifolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3



--USE CTE 

With PopvsVAc(continent , location , date , population ,new_vaccinations, RollingPeoplevaccinated)

as(
select  dea.continent , dea.location,dea.date , dea.population , vac.new_vaccinations 
,sum(convert ( int , vac.new_vaccinations )) over (partition by dea.location order by dea.location ,dea.date)
as RollingPeoplevaccinated 
from ProtifolioProject..CovidDeaths dea
join ProtifolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeoplevaccinated/population)*100  from PopvsVAc


-- Temp table 

Drop table if exists #precentpopulationvaccinated
create table #precentpopulationvaccinated 
(
continent nvarchar(255),
location nvarchar(255) , 
date datetime, 
population numeric,
new_vaccinations numeric ,
RollingPeoplevaccinated numeric
) 

insert into #precentpopulationvaccinated
select  dea.continent , dea.location,dea.date , dea.population , vac.new_vaccinations 
,sum(cast (  vac.new_vaccinations as int )) over (partition by dea.location order by dea.location ,dea.date)
as RollingPeoplevaccinated 
from ProtifolioProject..CovidDeaths dea
join ProtifolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


select *, (RollingPeoplevaccinated/population)*100  from #precentpopulationvaccinated







-- creating view to store data for later visualizations 

create view precentpopulationvaccinated
as 
select  dea.continent , dea.location,dea.date , dea.population , vac.new_vaccinations 
,sum(cast (  vac.new_vaccinations as int )) over (partition by dea.location order by dea.location ,dea.date)
as RollingPeoplevaccinated 
from ProtifolioProject..CovidDeaths dea
join ProtifolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3




select * from precentpopulationvaccinated




















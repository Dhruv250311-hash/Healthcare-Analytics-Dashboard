/*
 Data exploration of Covid Dataset

Things used:
joins, aggregate functions, window function, views
*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

-- checking my data first

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by location,date;

-- checking what is the death percentage

select location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by location,date;

-- checking what is the infection percentage

select location,date,population,total_cases,
(total_cases/population)*100 as infected_percentage
from PortfolioProject..CovidDeaths
order by location,date;

-- which countries with highest infection

select location,population,
max(total_cases) as highest_cases,
max(total_cases/population)*100 as infected_percentage
from PortfolioProject..CovidDeaths
group by location,population
order by infected_percentage desc;

-- which countries with highest deaths

select location,
max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc;

--  continent wise deaths trends

select continent,
max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;

-- what are global numbers
--like total overall deaths , overall death percentage 
select
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- what is the vaccination progress

select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

-- using cte

with pop_vs_vac
(continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

select *,
(rolling_people_vaccinated/population)*100 as vaccinated_percentage
from pop_vs_vac;

-- using temp table

-- firstly dropping the table
drop table if exists #population_vaccinated;

--creating new table for population_vaccinated
create table #population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

insert into #population_vaccinated

select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date;

select *,
(rolling_people_vaccinated/population)*100 as vaccinated_percentage
from #population_vaccinated;

-- creating view to work in Power Bi/Tableau dashboard

create view percent_population_vaccinated as

select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null;

select * from[dbo].[PercentPopulationVaccinated]
select * from [dbo].[VaccinationAnalytics]
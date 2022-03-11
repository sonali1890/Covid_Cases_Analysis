select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select * from PortfolioProject..CovidVaccinations
--order by 3,4;


select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2;
 
-- Looking at Total Cases Vs Deaths
-- Shows Likelihood of dying if you contract Covid in your country
select location, date, total_cases,  total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1, 2;

--Total Cases Vs Population
select location, date,   population, total_cases,(total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%India%'
order by 1, 2;

--Looking at countries having highest infection rate vs population
select location, population, max(total_cases) as HighestInfectionCount,Max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc;

--Looking at countries having highest Death count vs population
select location, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by TotaldeathCount desc;


-- looking at continents having highest death count 

--showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotaldeathCount desc;

--global numbers

select date, sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1, 2;

select sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1, 2;

select * from CovidVaccinations

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--using common table expression(Making a temp table)
with popvsvac (continent, location, date, population , new_vaccinations, rollingpplvaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rollingpplvaccinated/population) * 100 as Percentage_ppl_vaccinated
from popvsvac;

drop table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpplvaccinated numeric
)

Insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *, (rollingpplvaccinated/population) * 100 as Percentage_ppl_vaccinated
from #Percentpopulationvaccinated;

--creating view to store data for visualizations

create view Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * from Percentpopulationvaccinated
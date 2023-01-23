select *
From PortfolioProject..CovidDeaths

--Selecting data I am going to use

Select Location, Date, Total_cases, New_cases, Total_deaths, Population
from PortfolioProject..CovidDeaths
where conitent is not null
order by 1, 2

--Looking at Total Cases vs Total Death

select location, date, total_cases, total_deaths, (total_deaths/nullif ([total_cases],0))*100 as DeathPercentages
from [PortfolioProject]..CovidDeaths
where location like '%china%'
order by 1, 2

--Looking at Total Cases vs Population

select location, date, population, total_cases, (total_cases/nullif ([population],0))*100 as DeathPercentages
from [PortfolioProject]..CovidDeaths
--where location like '%china%'
order by 1, 2

--Lookin at Countries with Highest Infection Rate compared to Population

select location, population, MAX (total_cases) AS HighestInfectionCount, Max ((total_cases/nullif ([population],0)))*100 as PercentPopulationInfected
from [PortfolioProject]..CovidDeaths
--where location like '%china%'
Group by location, population
order by PercentPopulationInfected desc

select location, population, date, MAX (total_cases) AS HighestInfectionCount, Max ((total_cases/nullif ([population],0)))*100 as PercentPopulationInfected
from [PortfolioProject]..CovidDeaths
--where location like '%china%'
Group by location, population, date
order by PercentPopulationInfected desc

--Showing Countries with Highest Death counts per population

select location, MAX(total_deaths) as TotalDeathsCount 
from [PortfolioProject]..CovidDeaths
--where location like '%china%'
Where continent is not null
Group by location 
order by TotalDeathsCount desc

--Breakdown by Continent

--Showing Continents with Highest Death counts per population

select continent, MAX(total_deaths) as TotalDeathsCount 
from [PortfolioProject]..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent 
order by TotalDeathsCount desc

select continent, SUM(new_deaths) as TotalDeathsCount 
from [PortfolioProject]..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathsCount desc

--Global Numbers

select date, Sum(new_cases) as SumNewCases, Sum(new_deaths) as SumNewDeaths, Sum(new_deaths)/nullif(Sum(new_cases),0)*100 as GlobalDeathPercantage
From [PortfolioProject]..CovidDeaths
Where continent is not null
Group by date
order by 1, 2

select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, Sum(new_deaths)/nullif(Sum(new_cases),0)*100 as GlobalDeathPercantage
From [PortfolioProject]..CovidDeaths
Where continent is not null
--Group by date
order by 1, 2

--Looking at Total Vacination vs Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
) 

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Create View to use for visualation to store later

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From [dbo].[PercentPopulationVaccinated]
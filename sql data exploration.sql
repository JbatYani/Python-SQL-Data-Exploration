Select*
From Project..CovidDeaths
Where continent is not null
order by 3,4

Select*
From Project..CovidVaccinations
order by 3,4

--Select data that we are going to be using

Select location, date, total_cases,new_cases, total_deaths,population
From Project..CovidDeaths
order by 1,2


-- Looking at Tot Cases vs Tot Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project..CovidDeaths
Where location like '%malaysia%'
and continent is not null
order by 1,2

-- Looking at tot cases vs population
 --Show percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From Project..CovidDeaths
--Where location like '%malaysia%'
order by 1,2


 --Countries with highest Infection Rate compared to population

Select location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PopulationInfectedPercentage
From Project..CovidDeaths
--Where location like '%malaysia%'
Group by population, location
order by PopulationInfectedPercentage desc


 --Coutries with highest Death Percentage

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by population, location
order by TotalDeathCount desc


--Break things down by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%malaysia%'
Where continent is null
Group by location
order by TotalDeathCount desc

--Continents with highest death percentage per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

 --Global Numbers

Select date, SUM(new_cases) as NewCase, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as NewCase, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%malaysia%'
Where continent is not null
--Group by date
order by 1,2

---------------------------------------------------------------------------------------------------------

 --Total Population vs Total Vaccinations


SELECT dea.continent,dea.location, dea.date, population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,dea.date)As RollingPeopleVaccinated
--MAX( /population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


 Temp Table

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
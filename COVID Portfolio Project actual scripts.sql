
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


--Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%desh%'
and continent is not null
Order By 1,2


--Total Cases vs Population

Select location, date,  population,total_cases, (total_cases/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%desh%'
Order By 1,2


--Countries with Highest Infection Rate

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%desh%'
Group by location, population
Order By 4 DESC


--Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%desh%'
Where continent is not null
Group by location
Order By TotalDeathCount DESC


--Highest Death Count per Continet

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%desh%'
Where continent is null
Group by location
Order By TotalDeathCount DESC


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
Order By 1,2


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)/100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.location like '%desh%'
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


--Temp Table

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
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)/100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)/100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated
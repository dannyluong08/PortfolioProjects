Select *
From [Portfolio Project]..['Covid Deaths $']
Where continent is not null
Order by 3,4 

--Select *
--From [Portfolio Project]..['Covid Vaccinations  $']
--Order by 3,4 


--Select Data that we are going to be using		

Select Location, Date, population, total_cases, new_cases, total_deaths
From [Portfolio Project]..['Covid Deaths $']
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Total_deaths/Total_cases)* 100 will be % Death 
--Shows Likelihood of dying if you were to contract Covid in your Country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['Covid Deaths $']
Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows Which % of population has gotten Covid

Select Location, Date, total_cases, Population,(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..['Covid Deaths $']
Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

Select Location, MAX(total_cases) as HighestinfectionCount, Population, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..['Covid Deaths $']
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths $']
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Simply things by Continent Looking at Death count per Continent

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths $']
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Showing Continents with the Highest Death Count per Population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths $']
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Global Numbers

Select Date, SUM(new_cases) as Total_cases, SUM(cast(New_deaths as int)) as Total_deaths, SUM(cast(New_deaths as int))/sum(new_cases)*100 as DeathPercentage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['Covid Deaths $']
--Where location like '%states%' 
Where continent is not null
Group by date
Order by 1,2

--Total Cases, Deaths and Death Percentage 

Select Date, SUM(new_cases) as Total_cases, SUM(cast(New_deaths as int)) as Total_deaths, SUM(cast(New_deaths as int))/sum(new_cases)*100 as DeathPercentage  --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['Covid Deaths $']
--Where location like '%states%' 
Where continent is not null
Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

--Select *
--FROM [Portfolio Project]..['Covid Deaths $'] dea
--JOIN [Portfolio Project]..['Covid Vaccinations  $'] vac
--	on dea.location = vac.location
--	and dea.date = vac.date 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..['Covid Deaths $'] dea
JOIN [Portfolio Project]..['Covid Vaccinations  $'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
Order by 2,3

--Using CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..['Covid Deaths $'] dea
JOIN [Portfolio Project]..['Covid Vaccinations  $'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..['Covid Deaths $'] dea
JOIN [Portfolio Project]..['Covid Vaccinations  $'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for Visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..['Covid Deaths $'] dea
JOIN [Portfolio Project]..['Covid Vaccinations  $'] vac
	on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3


Select *
FROM PercentPopulationVaccinated
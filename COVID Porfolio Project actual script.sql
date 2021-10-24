create database PortfolioProjects

--AFTER IMPORTING BOTH EXCEL FILE EXECUTES THESE QUERIES

Select * 
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--from PortfolioProjects..CovidVaccinations
--order by 3,4

--Select data that we are going to be use
Select location, date,total_cases, new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases VS Total deaths and also see percentage of death in each country according to populations..
Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
order by 1,2

--now SEE DeathPercentage by selected Location
Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2 

--looking totalcase vs total populations
--show what percentage of populations got by Covid
Select location, date,population, total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%india%'
order by 1,2 

--Looking at countries with Heighest Infections rate compared to Pupulation
Select location,population, MAX(total_cases) AS HeighestInfectedCount,MAX((total_cases/population))*100 as 
PercentagePopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%india%'
Group by location,population
order by PercentagePopulationInfected desc

--Showing Countries with Heighest Death Count per population
Select location,MAX(cast( Total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent
Select continent,MAX(cast( Total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing continent with the highest death count per population

Select continent,MAX(cast( Total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBLE NUMBERS
Select  date,sum(new_cases) as Total_Cases,sum(cast(new_deaths as int))as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as 
DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2 

--cheak out worldwide Total_Cases, Total_deaths and DeathPercentage

Select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int))as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as 
DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2 


--Looking at Total Population VS Vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Looking at Total Population VS Vaccinations
--use Convert and Partition By to partition every location to geting new_vaccination
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition By dea.Location)
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Looking at Total Population VS Vaccinations
--use Convert and Partition By to partition every location to geting new_vaccination
--use calculation go get rolling count for each row

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition By dea.Location Order by dea.location , 
dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac(Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition By dea.Location Order by dea.location , 
dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition By dea.Location Order by dea.location , 
dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--creating a VEIW
Create view PercentPopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition By dea.Location Order by dea.location , 
dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated

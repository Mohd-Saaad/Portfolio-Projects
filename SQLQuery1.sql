Select * From PortfolioProject..CovidDeaths

Select location, date,population,total_cases,new_cases,total_deaths 
from PortfolioProject..CovidDeaths
order by 1,2

-- Total Deaths vs Total Cases in India 
Select location, date,population,total_cases,new_cases,total_deaths, (CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 as DeathPercent
from PortfolioProject..CovidDeaths
where location = 'India'
and population is not null
order by 1,2

-- Percentage of people that got Covid in India
Select location, date,population,total_cases,new_cases,total_deaths, (CONVERT(float,total_cases)/population)*100 as CovidPatientPerPopu
from PortfolioProject..CovidDeaths
where location = 'India'
and population is not null
order by 1,2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfections,MAX(CONVERT(float,total_cases)/population)*100 as CovidPatientPerPopu
from PortfolioProject..CovidDeaths
where population is not null
group by location,population
order by 1,2

--Countries by Highest Deaths
Select location,MAX(cast(total_cases as int)) as Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

--Continents with death count
Select continent, Max(cast(total_cases as int)) as Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Global Numbers
Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
Case
	WHEN SUM(new_cases) = 0 then null 
	else SUM(cast(new_deaths as int))/SUM(new_cases)*100
	end as DeathPerCases
from PortfolioProject..CovidDeaths
where continent is not null
and new_cases is not null
group by date
order by 1,2 

--Total Population vs Vacinations
with PopVsVac (continent,location, date,population,new_vac,PeopleGettingVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date)as PeopleGettingVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
--order by 2,3
)
select *,(PeopleGettingVaccinated/population)*100 as VaccinePercent
from PopVsVac
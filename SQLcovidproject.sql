select * from CovidDeaths
order by 3,4

--select * from CovidVaccinations
--order by 3,4

--select the data 
select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

--total cases v/s total deaths
-- Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentages
from CovidDeaths
where location like '%India%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%India%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select location,population,max(total_cases) as highestinfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
--where location like '%India%'
GROUP BY location,population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
select location,MAX(cast (total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%India%'
where continent is not null
GROUP BY location
order by totaldeathcount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as totaldeathcount from CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

select * from CovidDeaths

select location,MAX(cast(total_deaths as int)) as totaldeathcount from CovidDeaths
where continent is  null
group by location
order by totaldeathcount desc

---- GLOBAL NUMBERS
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
--where location like '%India%'
where continent is not  null
--group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac on 
dea.location=vac.location and dea.date=vac.date
where dea.continent is not  null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
 with popvsvac (Continent,Location,Date,population,new_vaccinations,rollingpeoplevaccinated) as 
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac on 
dea.location=vac.location and dea.date=vac.date
where dea.continent is not  null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query 

DROP Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)


insert into #percentpopulationvaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac on 
dea.location=vac.location and dea.date=vac.date
--where dea.continent is not  null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated

-- -- Creating View to store data for later visualizations
create view Percentpopulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac on 
dea.location=vac.location and dea.date=vac.date
--where dea.continent is not  null
--order by 2,3
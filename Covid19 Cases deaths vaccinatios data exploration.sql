select * from PortfolioProject..coviddeaths
where continent is not null
order by 3,4

select location,date,total_cases,new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

--total cases by total deaths

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as deathspercentage
from PortfolioProject..coviddeaths
where location like 'india'
order by 1,2

--what percentage of population got covid

select location,date,total_cases, population, (total_cases/population)*100 as deathspercentage
from PortfolioProject..coviddeaths
where location like 'india'
order by 1,2

--coutries with highest infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as 
percentpopulationinfected
from PortfolioProject..coviddeaths
where location like 'india'
group by location,population
order by percentpopulationinfected desc

--showing countries with highest death count population

select continent, max(total_deaths) as totaldeathcount 
from PortfolioProject..coviddeaths
--where location like 'india'
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers
--when we use group by remaining columns other than group by columns should be used aggregate functions
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null and new_deaths <>0
--group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location
,dea.date) as rollingpeplevaccinated
--, (rollingpeplevaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
order by 2,3

--use CTE

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location
,dea.date) as rollingpeplevaccinated
--, (rollingpeplevaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated /population) *100
from popvsvac


--temp table

drop table if exists #percentpopulationvaccinated 
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location
,dea.date) as rollingpeplevaccinated
--, (rollingpeplevaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date =vac.date
--where dea.continent is not null

select *,(rollingpeoplevaccinated /population) *100
from #percentpopulationvaccinated


--views to store data for later visualizations

create view percentpeoplevaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location
,dea.date) as rollingpeplevaccinated
--, (rollingpeplevaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccination vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select * from percentpeoplevaccinated
order by 6 desc

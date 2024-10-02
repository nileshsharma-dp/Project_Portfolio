SELECT * 
from porfolio_projects.dbo.Covid_deaths$
where continent is not null
order by 3,4

--SELECT * 
--from porfolio_projects.dbo.Covid_vaccinated$
--where continent is not null
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from porfolio_projects..Covid_deaths$
where continent is not null
order by 1,2 

--Looking for total cases vs total deaths

select Location, date, total_cases, total_deaths, population, Round((total_deaths/NULLIF(total_cases,0))*100, 2) as death_pct
from porfolio_projects..Covid_deaths$
where continent is not null
and Location='India'
order by 1,2 

-- Looking at total_cases vs population

select Location, date, total_cases, total_deaths, population, Round((NULLIF(total_cases,0)/population)*100, 2) as population_pct_infected
from porfolio_projects..Covid_deaths$
where Location='India'
and continent is not null
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population 

select Location, 
population,
Max(total_cases) as Highest_infection_count, 
Round((Max(NULLIF(total_cases,0)/population))*100, 2) as Highest_Population_pct_Infected
from porfolio_projects..Covid_deaths$
where continent is not null
--where Location='India'
Group by Location, population
order by 4 desc

select Location, 
population,
Max(total_cases) as Highest_infection_count, 
Round((Max(total_cases)/population)*100, 2) as Highest_Population_pct_Infected
from porfolio_projects..Covid_deaths$
where continent is not null
--where Location='India'
Group by Location, population
order by 4 desc

--Looking countries with Highest Death/population 

select Location, 
population,
Max(total_deaths) as Highest_death_count, 
Round((Max(total_deaths)/population)*100, 2) as Highest_Population_pct_Infected
from porfolio_projects..Covid_deaths$
where continent is not null
--where Location='India'
Group by Location, population
order by 3 desc

-- Split it into continent

select continent,
Max(total_deaths) as Highest_death_count,
Round((Max(NULLIF(total_cases,0)/population))*100, 2) as Highest_Population_pct_Infected
from porfolio_projects..Covid_deaths$
where continent is not null
--where Location='India'
Group by continent
order by 2 desc

select location,
Max(total_deaths) as Highest_death_count,
Round((Max(NULLIF(total_cases,0)/population))*100, 2) as Highest_Population_pct_Infected
from porfolio_projects..Covid_deaths$
where continent is null
--where Location='India'
Group by location
order by 2 desc

--Taking global number


select sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths ,
round(sum(new_deaths)/sum(new_cases)*100,2) as Death_pct
from porfolio_projects..Covid_deaths$
where continent is not null 
--group by date
order by 1, 2

--Looking at total_population vs vaccination

select *
from porfolio_projects..Covid_deaths$ as d
join porfolio_projects..Covid_vaccinated$ v
on d.location = v.location 
and d.date = v.date

select d.continent, d.location, d.date, d.population, v.new_vaccinations--, v.total_vaccinations
from porfolio_projects..Covid_deaths$ as d
join porfolio_projects..Covid_vaccinated$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null

select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(convert(BIGINT, COALESCE(v.new_vaccinations,0))) over (partition by d.Location ORDER BY d.location, d.date) AS rolling_People_vaccinations
from porfolio_projects..Covid_deaths$ as d
join porfolio_projects..Covid_vaccinated$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
order by 2,3

--Use CTE

with popvsvac (continent ,location, date, population, new_vaccinations, rolling_people_vaccinations)
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(convert(BIGINT, COALESCE(v.new_vaccinations,0))) over (partition by d.Location ORDER BY d.location, d.date) AS rolling_People_vaccinations
from porfolio_projects..Covid_deaths$ as d
join porfolio_projects..Covid_vaccinated$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3 
)
select * , round((rolling_people_vaccinations/population)*100,2) as rolling_pct
from popvsvac

--Temp Table

Drop table if exists #percentpopulationvaccinated
create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
rolling_people_vaccinations numeric
)
insert into #percentpopulationvaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(convert(BIGINT, COALESCE(v.new_vaccinations,0))) over (partition by d.Location ORDER BY d.location, d.date) AS rolling_People_vaccinations
from porfolio_projects..Covid_deaths$ as d
join porfolio_projects..Covid_vaccinated$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
--order by 2,3 

select * , round((rolling_people_vaccinations/population)*100,2) as rolling_pct
from #percentpopulationvaccinated



--Creating View to store data for visulization in future

	create view percentpopulationvaccinated as 
	select d.continent, d.location, d.date, d.population, v.new_vaccinations
	, sum(convert(BIGINT, COALESCE(v.new_vaccinations,0))) over (partition by d.Location ORDER BY d.location, d.date) AS rolling_People_vaccinations
	from porfolio_projects..Covid_deaths$ as d
	join porfolio_projects..Covid_vaccinated$ v
	on d.location = v.location 
	and d.date = v.date
	where d.continent is not null
	--order by 2,3 





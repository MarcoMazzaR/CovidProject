use Covid_Project

--select * from Covid_Deaths
--select * from covid_Vaccinations$


--TOTAL DE CASOS, NUEVOS CASOS Y TOTAL DE MUERTES POR PAIS
select iso_code, location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where iso_code not like '%OWID%'
order by 1,2


--Muestra el riesgo de muerte por contraccion de covid.
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as 'Death percentaje' from Covid_Deaths
where iso_code not like '%OWID%'
order by 1,2

--Cantidad de gente que tuvo covid.

select Location, Date, population, total_cases, (total_cases/population)*100 as 'Porcentaje de contagios' from Covid_deaths
where iso_code not like '%OWID%'
order by 1,2

--Países con mayor indice de contagio en base a la población.

select location, population, max(total_cases)'Max. Infectados', max((total_cases/population)*100) 'Porcentaje de contagios' 
from covid_deaths
group by location, population
order by [Porcentaje de contagios]desc

--Países con mayor mortalidad en base a la población

select location, max(cast(total_deaths as int))' Descesos' from covid_deaths
where iso_code not like '%OWID%'
group by location
order by [ Descesos] desc

--Continentes con mayor mortalidad.
select continent, max(cast(total_deaths as int))' Descesos'from covid_deaths
where continent is not null and iso_code not like '%OWID%'
group by continent
order by [ Descesos] desc


--Números globales

select sum(new_cases) as 'Casos', sum(cast(new_deaths as int)) as 'Muertes' from covid_deaths
where iso_code not like '%OWID%'
order by 1,2


--Casos,Muertes y Mortalidad
select sum(new_cases) as 'Casos', sum(cast(new_deaths as int)) as 'Muertes', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Mortalidad'
from dbo.Covid_Deaths
where continent is not null and iso_code not like '%OWID%'


--COVID VACCINATION-- 
select * from Covid_Vaccinations$
where new_vaccinations = '2859.0'
--vacunacion/poblacion

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by d.location order by d.location, d.date) as TotalVacunados
from Covid_Deaths d
	join
	Covid_Vaccinations$ v on d.location = v.location and d.date = v.date
where d.iso_code not like '%OWID%'
order by 2,3


--CTEs

with PobvsVac (continent,location, date,  population, new_vaccinations, TotalVacunados)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by d.location order by d.location, d.date) as TotalVacunados
from Covid_Deaths d
	join
	Covid_Vaccinations$ v on d.location = v.location and d.date = v.date
where d.iso_code not like '%OWID%'
--order by 2,3
) 
--select location, date, new_vaccinations from Covid_Vaccinations$
--where location = 'Argentina'
select *, (TotalVacunados/population )*100 as PorcentajeVacunacion from PobvsVac


--TEMP TABLE
--drop table #PorcentajeVacunacion
alter table covid_vaccinations$
drop column TotalVacunados

create table #PorcentajeVacunacion(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVacunados numeric
)

insert into #PorcentajeVacunacion
select d.continent, d.location, d.date, d.population, convert (int,v.new_vaccinations) as NewVA, sum(convert(bigint,new_vaccinations)) 
over (Partition by d.location order by d.location, d.date) as TotalVacunados
from Covid_Deaths d
	join
	Covid_Vaccinations$ v on d.location = v.location and d.date = v.date
where d.iso_code not like '%OWID%'
--order by 2,3

select *, (TotalVacunados/population )*100 as PorcentajeVacunacion from #PorcentajeVacunacion


--VIEWS
--Muertes por continente
create view CantidadMuertesContinente as
select continent, max(cast(total_deaths as int))' Descesos'from covid_deaths
where continent is not null and iso_code not like '%OWID%'
group by continent

--VACUNACION GLOBAL

create view PorcentajeVacunacionGlobal as
with PobvsVac (continent,location, date,  population, new_vaccinations, TotalVacunados)
as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by d.location order by d.location, d.date) as TotalVacunados
from Covid_Deaths d
	join
	Covid_Vaccinations$ v on d.location = v.location and d.date = v.date
where d.iso_code not like '%OWID%'
--order by 2,3
) 
--select location, date, new_vaccinations from Covid_Vaccinations$
--where location = 'Argentina'
select *, (TotalVacunados/population )*100 as PorcentajeVacunacion from PobvsVac

--PAISES CON MAYOR MORTALIDAD

create view PaisesMortalidad as
select location, max(cast(total_deaths as int))' Descesos' from covid_deaths
where iso_code not like '%OWID%'
group by location

--TRACKING DE CASOS CON PORCENTAJE DE CONTAGIOS
create view TrackingCasos as
select Location, Date, population, total_cases, (total_cases/population)*100 as 'Porcentaje de contagios' from Covid_deaths
where iso_code not like '%OWID%'


--CASOS, SUMA DE CASOS Y MUERTES POR PAÍS
create view CasosYMuertes as 
select iso_code, location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where iso_code not like '%OWID%'

--COUNT DE MUERTES Y PORCENTAJE
create view MuertesPorcentaje as
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as 'Death percentaje' from Covid_Deaths
where iso_code not like '%OWID%'



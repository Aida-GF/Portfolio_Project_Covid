
SELECT [location], [date], total_cases, new_cases, total_deaths, population
from [Covid-Death_new_updated2]
order BY 1,2;


--Death percentage of covid  in USA
SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Covid-Death_new_updated2]
WHERE [location] like '%States' and total_cases <> 0 
order BY 1,2;

SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Covid-Death_new_updated2]
WHERE [location] ='Iran' and total_cases <> 0 
order BY 1,2;

--percentage of population has gotten covid 
SELECT [location], [date], total_cases, population, (total_cases/population)*100 as 'Got Covid%'
from [Covid-Death_new_updated2]
WHERE [location] ='United States' and total_cases <> 0 
order BY 1,2;

--Countries with highest infection rate
SELECT [location], population, MAX(total_cases) as 'Higheste_Infection_Count', 
MAX(total_cases/population) as 'Percent_Population_Infected'
from [Covid-Death_new_updated2]
GROUP BY [location], population
ORDER BY Percent_Population_Infected DESC;


--Countries with highest death count
SELECT [location], MAX(CAST(total_deaths as int)) as Total_Death_Count
from [Covid-Death_new_updated2]
WHERE continent is NOT NULL
GROUP BY [location] 
ORDER BY Total_Death_Count DESC;


--By Continent
SELECT [continent], MAX(CAST(total_deaths as int)) as Total_Death_Count
from [Covid-Death_new_updated2]
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;
--By location
SELECT [location], MAX(CAST(total_deaths as int)) as Total_Death_Count
from [Covid-Death_new_updated2]
WHERE continent is NULL
GROUP BY [location] 
ORDER BY Total_Death_Count DESC;

--Global
SELECT [date], SUM(new_cases) as Total_Cases_Globally , SUM(new_deaths) as Total_Death_Globally,
SUM(new_deaths)/SUM(new_cases)*100 as Death_Percentage_Global
from [Covid-Death_new_updated2]
WHERE continent is NOT NULL and new_cases <> 0
GROUP BY [date]
ORDER BY 1,2;
--Improved code
SELECT 
    SUM(new_cases) as Total_Cases_Globally,
    SUM(new_deaths) as Total_Death_Globally,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 --division by zero
        ELSE (SUM(new_deaths) * 100.0) / CAST(SUM(new_cases) AS DECIMAL(18, 2))
    END as Death_Percentage_Global
FROM [Covid-Death_new_updated2]
WHERE continent IS NOT NULL AND new_cases <> 0;


--Total vaccinated population globally
SELECT dea.continent, dea.[date], dea.[location], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
FROM [Covid-Death_new_updated2] as dea
JOIN [Covid-Vaccination_new_updated] as vac
on dea.[location] = vac.[location]
AND dea.[date]=vac.[date]
WHERE dea.continent is not NULL and vac.new_vaccinations is not null
order by 2,3;


--Using CTE
WITH Population_Vs_Vaccination (Continent,location, date, population, Rolling_Vaccinated, new_vaccinations)
as 
(
SELECT dea.continent, dea.[date], dea.[location], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
FROM [Covid-Death_new_updated2] as dea
JOIN [Covid-Vaccination_new_updated] as vac
on dea.[location] = vac.[location]
AND dea.[date]=vac.[date]
WHERE dea.continent is not NULL and vac.new_vaccinations is not null
)
select * , (Rolling_Vaccinated/population)*100 as RollingVac_Over_Pop
from Population_Vs_Vaccination;


--Temp table
DROP TABLE if EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent NVARCHAR(225),
LOCATION NVARCHAR(225),
DATE DATETIME,
population numeric,
new_vaccinations numeric,
Rolling_Vaccinated NUMERIC
)

    INSERT into #Percent_Population_Vaccinated
    SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
FROM [Covid-Death_new_updated2] as dea
JOIN [Covid-Vaccination_new_updated] as vac
on dea.[location] = vac.[location]
AND dea.[date]=vac.[date]
WHERE dea.continent is not NULL and vac.new_vaccinations is not null;


--Creating View (store data for visualtion)
CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.[date], dea.[location], dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated
FROM [Covid-Death_new_updated2] as dea
JOIN [Covid-Vaccination_new_updated] as vac
on dea.[location] = vac.[location]
AND dea.[date]=vac.[date]
WHERE dea.continent is not NULL;


SELECT*
from Percent_Population_Vaccinated;

SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[rolling_People_vaccinations]
  FROM [porfolio_projects].[dbo].[percentpopulationvaccinated]

  select* 
  from percentpopulationvaccinated
  where location='India'
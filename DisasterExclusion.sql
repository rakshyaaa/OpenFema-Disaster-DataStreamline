
----------------------------------------------------------------------------------------------------------------------
---------------------------------------- Table definitions -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


--------Disaster Declarations Table---------------

create table fnd_website.DBO.DisasterDeclarations (
disasterNumber int
,declarationDate datetime
,disasterName nvarchar(max)
,incidentBeginDate datetime
,incidentEndDate datetime
,declarationType nvarchar(max)
,stateCode nvarchar(max)
,stateName nvarchar(max)
,incidentType nvarchar(max)
,entryDate datetime
,updateDate datetime
,closeoutDate datetime
,region int
,ihProgramDeclared nvarchar(max)
,iaProgramDeclared nvarchar(max)
,paProgramDeclared nvarchar(max)
,hmProgramDeclared nvarchar(max)
,designatedIncidentTypes nvarchar(max)
,declarationRequestDate datetime
,id nvarchar(max) 
,hash nvarchar(max)
,lastRefresh datetime
);

------Disaster Declarations Summary Table-------------

create table fnd_website.DBO.DisasterDeclarationsSummaries (
femaDeclarationString nvarchar(max)
,disasterNumber int 
,state nvarchar(max)
,declarationType datetime
,declarationDate datetime
,fyDeclared int
,incidentType nvarchar(max)
,declarationTitle nvarchar(max)
,ihProgramDeclared nvarchar(max)
,iaProgramDeclared nvarchar(max)
,paProgramDeclared nvarchar(max)
,hmProgramDeclared nvarchar(max)
,incidentBeginDate datetime
,incidentEndDate datetime
,disasterCloseoutDate datetime
,tribalRequest nvarchar(max)
,fipsStateCode int
,fipsCountyCode int
,placeCode int 
,designatedArea nvarchar(max)
,declarationRequestNumber int 
,lastIAFilingDate datetime
,incidentId bigint
,region int 
,designatedIncidentTypes nvarchar(max)
,lastRefresh datetime
,hash nvarchar(max)
,id nvarchar(max)
);



----------------------------------------------------------------------------------------------------------------------
---------------------------------------- Disaster Impact View definitions --------------------------------------------
----------------------------------------------------------------------------------------------------------------------

ALTER VIEW DBO.DisasterImpacts AS
with statewide_cte as (
select 
d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType as declarationTypeAvv,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
from 
dbo.DisasterDeclarations  d
join DBO.DisasterDeclarationsSummaries ds
on d.disasterNumber = ds.disasterNumber and ds.designatedArea = 'Statewide' 
left join dbo.US_ZIP_CODES us
on ds.state = us.state_code
group by d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
),
county_cte as (
select 
d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType as declarationTypeAvv,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
from 
dbo.DisasterDeclarations  d
join DBO.DisasterDeclarationsSummaries ds
on d.disasterNumber = ds.disasterNumber 
and 
ds.disasterNumber not in (select distinct disasterNumber from fnd_website.DBO.DisasterDeclarationsSummaries where designatedArea = 'Statewide')
and designatedArea like '%(County)%' 
and d.stateCode = ds.state
left join dbo.US_ZIP_CODES us
on ds.state = us.state_code
and SUBSTRING (designatedArea,0,CHARINDEX('(',designatedArea)) = county_name
group by d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
),
parish_cte as (
select 
d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType as declarationTypeAvv,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
from 
dbo.DisasterDeclarations  d
join DBO.DisasterDeclarationsSummaries ds
on d.disasterNumber = ds.disasterNumber 
and ds.disasterNumber not in (select distinct disasterNumber from fnd_website.DBO.DisasterDeclarationsSummaries where designatedArea = 'Statewide')
and  designatedArea like '%(Parish)%'
and d.stateCode = ds.state
left join dbo.US_ZIP_CODES  us
on ds.state = us.state_code
and (((SUBSTRING (designatedArea,0,CHARINDEX('(',designatedArea)) + 'Parish') = county_name) or (SUBSTRING (designatedArea,0,CHARINDEX('(',designatedArea)) = county_name))
group by d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
), 
others_cte as 
(
select 
d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType as declarationTypeAvv,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
from 
dbo.DisasterDeclarations  d
join DBO.DisasterDeclarationsSummaries ds
on d.disasterNumber = ds.disasterNumber 
and cast(ds.disasterNumber as nvarchar)+ds.designatedArea not in (select cast(ds.disasterNumber as nvarchar)+ds.designatedArea from fnd_website.DBO.DisasterDeclarationsSummaries where designatedArea = 'Statewide' or designatedArea like '%(Parish)%' or designatedArea like '%(County)%')
and d.stateCode = ds.state
left join dbo.US_ZIP_CODES us
on ds.state = us.state_code
and  ((ds.designatedArea like '%' + us.county_name + '%' ) or (SUBSTRING (designatedArea,0,CHARINDEX('(',designatedArea)) like '%' + us.county_name + '%' ))
group by d.disasterNumber, d.declarationDate, ds.fyDeclared,d.DisasterName,d.declarationType, 
ds.declarationType,d.stateCode,d.stateName,d.incidentType,ds.designatedArea, 
us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
)
,final_cte as (
select * from statewide_cte
union
select * from county_cte
union
select * from parish_cte
union 
select * from others_cte
)
select * 
from final_cte;


-----------------------------------------------------------------------------------
-------------- Testing  Query ----------------------------------------------------------
-------------------------------------------------------------------------------------

select distinct designatedArea from dbo.DisasterDeclarationsSummaries;

select distinct a.designatedArea, b.designatedArea from dbo.DisasterDeclarationsSummaries a
left join dbo.DisasterImpacts b
on a.designatedArea = b.designatedArea;

with cte as (
select statename, designatedArea, count(postal_code) as postal_count from dbo.DisasterImpacts group by statename, designatedArea
--order by statename, designatedArea
), 
cte2 as
(
select state_name, county_name, count(postal_code) as postal_count from dbo.us_zip_codes 
--where state_name = 'Florida'
group by state_name, county_name
)
select *, case when cte.postal_count = cte2.postal_count then 'True' else 'False' end as validation from cte
left join cte2
on cte.statename = cte2.state_name
and (SUBSTRING (designatedArea,0,CHARINDEX('(',designatedArea)) like '%' + county_name + '%' ) or ((SUBSTRING (designatedArea,0,CHARINDEX('(',designatedArea)) + 'Parish') = county_name);



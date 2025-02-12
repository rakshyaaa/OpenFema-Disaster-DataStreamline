
----------------------------------------------------------------------------------------------------------------------
---------------------------------------- Table definitions -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


--------Disaster Declarations Table---------------

create table DBO.DisasterDeclarations (
disasterNumber int
,declarationDate timestamp
,disasterName varchar
,incidentBeginDate timestamp
,incidentEndDate timestamp
,declarationType varchar
,stateCode varchar
,stateName varchar
,incidentType varchar
,entryDate timestamp
,updateDate timestamp
,closeoutDate timestamp
,region int
,ihProgramDeclared varchar
,iaProgramDeclared varchar
,paProgramDeclared varchar
,hmProgramDeclared varchar
,designatedIncidentTypes varchar
,declarationRequestDate timestamp
,id varchar 
,hash varchar
,lastRefresh timestamp
);

------Disaster Declarations Summary Table-------------

create table DBO.DisasterDeclarationsSummaries (
femaDeclarationString varchar
,disasterNumber int 
,state varchar
,declarationType timestamp
,declarationDate timestamp
,fyDeclared int
,incidentType varchar
,declarationTitle varchar
,ihProgramDeclared varchar
,iaProgramDeclared varchar
,paProgramDeclared varchar
,hmProgramDeclared varchar
,incidentBeginDate timestamp
,incidentEndDate timestamp
,disasterCloseoutDate timestamp
,tribalRequest varchar
,fipsStateCode int
,fipsCountyCode int
,placeCode int 
,designatedArea varchar
,declarationRequestNumber int 
,lastIAFilingDate timestamp
,incidentId bigint
,region int 
,designatedIncidentTypes varchar
,lastRefresh timestamp
,hash varchar
,id varchar
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




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





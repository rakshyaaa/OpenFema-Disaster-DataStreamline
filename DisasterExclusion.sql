
----------------------------------------------------------------------------------------------------------------------
---------------------------------------- Table definitions -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


--------Disaster Declarations Table---------------


CREATE TABLE public."DisasterDeclarations" (
    "disasterNumber" BIGINT,
    "declarationDate" TEXT,
    "disasterName" TEXT,
    "incidentBeginDate" TEXT,
    "incidentEndDate" TEXT,
    "declarationType" TEXT,
    "stateCode" TEXT,
    "stateName" TEXT,
    "incidentType" TEXT,
    "entryDate" TEXT,
    "updateDate" TEXT,
    "closeoutDate" TEXT,
    "region" BIGINT,
    "ihProgramDeclared" BOOLEAN,
    "iaProgramDeclared" BOOLEAN,
    "paProgramDeclared" BOOLEAN,
    "hmProgramDeclared" BOOLEAN,
    "designatedIncidentTypes" TEXT,
    "declarationRequestDate" TEXT,
    "disasterPageUrl" TEXT,
    "shapefileUrl" TEXT,
    "kmzfileUrl" TEXT,
    "geoJsonUrl" TEXT,
    "id" TEXT,
    "hash" TEXT,
    "lastRefresh" TEXT
);


------Disaster Declarations Summary Table-------------

CREATE TABLE public."DisasterDeclarationsSummaries" (
    "femaDeclarationString" TEXT,
    "disasterNumber" BIGINT,
    "state" TEXT,
    "declarationType" TEXT,
    "declarationDate" TEXT,
    "fyDeclared" BIGINT,
    "incidentType" TEXT,
    "declarationTitle" TEXT,
    "ihProgramDeclared" BOOLEAN,
    "iaProgramDeclared" BOOLEAN,
    "paProgramDeclared" BOOLEAN,
    "hmProgramDeclared" BOOLEAN,
    "incidentBeginDate" TEXT,
    "incidentEndDate" TEXT,
    "disasterCloseoutDate" TEXT,
    "tribalRequest" BOOLEAN,
    "fipsStateCode" TEXT,
    "fipsCountyCode" TEXT,
    "placeCode" TEXT,
    "designatedArea" TEXT,
    "declarationRequestNumber" TEXT,
    "lastIAFilingDate" TEXT,
    "incidentId" TEXT,
    "region" BIGINT,
    "designatedIncidentTypes" TEXT,
    "lastRefresh" TEXT,
    "hash" TEXT,
    "id" TEXT
);





----------------------------------------------------------------------------------------------------------------------
---------------------------------------- View definitions -----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


create or replace view disasterImpact as
WITH statewide_cte AS (
    SELECT 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType" AS "declarationTypeAvv", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
    FROM 
        public."DisasterDeclarations" d
    JOIN public."DisasterDeclarationsSummaries" ds
        ON d."disasterNumber" = ds."disasterNumber" AND ds."designatedArea" = 'Statewide' 
    LEFT JOIN public.us_zip_codes us
        ON ds.state = us.state_code
    GROUP BY 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
),
county_cte AS (
    SELECT 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType" AS "declarationTypeAvv", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
    FROM 
        public."DisasterDeclarations" d
    JOIN public."DisasterDeclarationsSummaries" ds
        ON d."disasterNumber" = ds."disasterNumber" 
        AND ds."disasterNumber" NOT IN (
            SELECT DISTINCT "disasterNumber" 
            FROM public."DisasterDeclarationsSummaries" 
            WHERE "designatedArea" = 'Statewide'
        )
        AND ds."designatedArea" LIKE '%(County)%' 
        AND d."stateCode" = ds.state
    LEFT JOIN public.us_zip_codes us
        ON ds.state = us.state_code
        AND TRIM(LOWER(REPLACE(SPLIT_PART(ds."designatedArea", '(', 1), '.', ''))) = TRIM(LOWER(REPLACE(us.county_name, 'County', '')))
    GROUP BY 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
),
parish_cte AS (
    SELECT 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType" AS "declarationTypeAvv", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
    FROM 
        public."DisasterDeclarations" d
    JOIN public."DisasterDeclarationsSummaries" ds
        ON d."disasterNumber" = ds."disasterNumber" 
        AND ds."disasterNumber" NOT IN (
            SELECT DISTINCT "disasterNumber" 
            FROM public."DisasterDeclarationsSummaries" 
            WHERE "designatedArea" = 'Statewide'
        )
        AND ds."designatedArea" LIKE '%(Parish)%'
        AND d."stateCode" = ds.state
    LEFT JOIN public.us_zip_codes us
        ON ds.state = us.state_code
        AND TRIM(LOWER(REPLACE(SPLIT_PART(ds."designatedArea", '(', 1), '.', ''))) = TRIM(LOWER(REPLACE(us.county_name, 'Parish', '')))
    GROUP BY 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
),
others_cte AS (
    SELECT 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType" AS "declarationTypeAvv", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
    FROM 
        public."DisasterDeclarations" d
    JOIN public."DisasterDeclarationsSummaries" ds
        ON d."disasterNumber" = ds."disasterNumber" 
        AND (CAST(ds."disasterNumber" AS TEXT) || ds."designatedArea") NOT IN (
            SELECT (CAST("disasterNumber" AS TEXT) || "designatedArea")
            FROM public."DisasterDeclarationsSummaries"
            WHERE "designatedArea" = 'Statewide' 
               OR "designatedArea" LIKE '%(Parish)%' 
               OR "designatedArea" LIKE '%(County)%'
        )
        AND d."stateCode" = ds.state
    LEFT JOIN public.us_zip_codes us
        ON ds.state = us.state_code
        AND (
            TRIM(LOWER(ds."designatedArea")) ILIKE '%' || TRIM(LOWER(us.county_name)) || '%' 
            OR TRIM(LOWER(SPLIT_PART(ds."designatedArea", '(', 1))) ILIKE '%' || TRIM(LOWER(us.county_name)) || '%'
        )
    GROUP BY 
        d."disasterNumber", d."declarationDate", ds."fyDeclared", d."disasterName", d."declarationType", 
        ds."declarationType", d."stateCode", d."stateName", d."incidentType", ds."designatedArea", 
        us.state_name, us.postal_code, us.county_name, us.state_code, us.place_name
),
final_cte AS (
    SELECT * FROM statewide_cte
    UNION
    SELECT * FROM county_cte
    UNION
    SELECT * FROM parish_cte
    UNION 
    SELECT * FROM others_cte
)
SELECT * 
FROM final_cte;
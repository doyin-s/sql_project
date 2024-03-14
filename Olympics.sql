USE Olympics_History;

SELECT * FROM athlete_events;

-- Ensuring specific columns are not null
SET SQL_SAFE_UPDATES = 0;

SELECT
(case when (sum(case when `Name` IS NULL then 1 else 0 end)) > 0 then True else False end) as is_name_null,
(case when (sum(case when Sex IS NULL then 1 else 0 end)) > 0 then True else False end) as is_sex_null,
(case when (sum(case when Age IS NULL then 1 else 0 end)) > 0 then True else False end) as is_age_null,
(case when (sum(case when Height IS NULL then 1 else 0 end)) > 0 then True else False end) as is_height_null,
(case when (sum(case when Weight IS NULL then 1 else 0 end)) > 0 then True else False end) as is_weight_null,
(case when (sum(case when Team IS NULL then 1 else 0 end)) > 0 then True else False end) as is_team_null,
(case when (sum(case when NOC IS NULL then 1 else 0 end)) > 0 then True else False end) as is_noc_null,
(case when (sum(case when Games IS NULL then 1 else 0 end)) > 0 then True else False end) as is_games_null,
(case when (sum(case when `Year` IS NULL then 1 else 0 end)) > 0 then True else False end) as is_year_null,
(case when (sum(case when Season IS NULL then 1 else 0 end)) > 0 then True else False end) as is_season_null,
(case when (sum(case when City IS NULL then 1 else 0 end)) > 0 then True else False end) as is_city_null,
(case when (sum(case when Sport IS NULL then 1 else 0 end)) > 0 then True else False end) as is_sport_null,
(case when (sum(case when `Event`IS NULL then 1 else 0 end)) > 0 then True else False end) as is_event_null,
(case when (sum(case when Medal IS NULL then 1 else 0 end)) > 0 then True else False end) as is_medal_null
FROM athlete_event; 

-- DUPLICATES

SELECT *
FROM athlete_events
GROUP BY ID, `Name`, Sex, Age, Height, Weight, Team, NOC, Games,`Year`, Season, City, Sport, `Event`,Medal
HAVING COUNT(*) > 1;

-- How many Olypmics have been held in total

SELECT MIN(`YEAR`) AS 'First', MAX(`YEAR`) AS 'Last'
FROM athlete_events;

SELECT MAX(`YEAR`) - MIN(`YEAR`) as 'Total Olympics'
FROM athlete_events;

-- How Many Olympic Games have been held in 120 years
SELECT COUNT(DISTINCT(Games))
FROM athlete_events; 

SELECT `Year`, Season, COUNT(*) AS 'Amount of Games'
FROM athlete_events
GROUP BY `Year`, Season
ORDER BY `Year`;

-- Total Female and Male Participates
SELECT Sex, COUNT(DISTINCT(ID)) AS 'Total'
FROM athlete_events
GROUP BY Sex;

SELECT Games, Sex, COUNT(DISTINCT(ID)) AS 'Total'
FROM athlete_events
GROUP BY Games, Sex;

-- Medals won in each Year and Season
SELECT
`Year`, Season, 
SUM(CASE when Medal = 'Gold' then 1 
	ELSE 0 END) AS 'Gold',
SUM(CASE when Medal = 'Silver' then 1 
	ELSE 0 
END) AS 'Silver',
SUM(CASE when Medal = 'Bronze' then 1 
	ELSE 0 
END) AS 'Bronze',
SUM(CASE when Medal IN ('Gold','Silver','Bronze') then 1 else 0 END) AS 'Total Medals'
FROM athlete_events
GROUP BY `Year`, Season
ORDER BY `Year`;

-- Most medals won in each Region(Country)
SELECT Games,r.Region,
	SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS 'Total Medals'
FROM athlete_events a
JOIN regions r
ON a.NOC = r.NOC
GROUP BY Games,r.Region 
ORDER BY 1,3 DESC;

-- Total gold, silver and bronze medals won by each country
WITH Gold AS (
	SELECT Team,  COUNT(Medal) AS 'Gold_Medals'
	FROM athlete_events WHERE Medal = 'Gold'
	GROUP BY Team ),
Silver AS (
	SELECT Team,  COUNT(Medal) AS 'Silver_Medals'
	FROM athlete_events WHERE Medal = 'Silver'
	GROUP BY Team),
Bronze AS (
	SELECT  Team,  COUNT(Medal) AS 'Bronze_Medals'
	FROM athlete_events WHERE Medal = 'Bronze'
	GROUP BY Team)

SELECT a.Team, a.Gold_Medals AS 'Gold', b.Silver_Medals AS 'Silver', c.Bronze_Medals AS 'Bronze'
FROM Gold a
INNER JOIN Silver b
ON a.Team = b.Team 
JOIN Bronze c
ON a.Team = c.Team
ORDER BY 2 DESC;

-- Females vs Males Partipation
WITH F AS (
SELECT COUNT(DISTINCT(ID)) AS 'Female',Sex, `Year`, Season
FROM athlete_events
WHERE Sex = 'F'
GROUP BY `Year`, Season, Sex),

M AS (SELECT COUNT(DISTINCT(ID)) AS 'Male',Sex, `Year`, Season
FROM athlete_events
WHERE Sex = 'M'
GROUP BY `Year`, Season, Sex)

SELECT M.`Year`, M.Season, M.Male, F.Female
FROM M
LEFT JOIN F
ON F.`Year` = M.`Year` AND F.Season = M.Season
GROUP BY M.`Year`, M.Season,M.Male, F.Female
ORDER BY `Year`;

-- Male VS Female Medal Wins
WITH Medals as (SELECT
`Year`, Season, 
SUM(CASE when Medal IN ('Gold','Silver','Bronze') AND SEX = 'F' then 1 else 0 END) AS 'Female',
SUM(CASE when Medal IN ('Gold','Silver','Bronze') AND SEX = 'M' then 1 else 0 END) AS 'Male'
FROM athlete_events
GROUP BY `Year`, Season
ORDER BY `Year`)

SELECT `Year`,Season, Female, Male, (Female + Male) AS 'Total Medals'
FROM Medals
GROUP BY `Year`, Season
ORDER BY `Year`;

-- Countries that participated in each game
SELECT    `Year`, Season, COUNT(DISTINCT(Team)) AS 'Nation Count' 
FROM athlete_events
GROUP BY `Year`, Season
ORDER BY 1;


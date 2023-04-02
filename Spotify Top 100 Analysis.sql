-- Spotify Top 100 artists based on their top 10 songs

-- --------------------------------------------------------------------------------------------------
-- IMPORT DATABASES AND TRANSFORM DATA --------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------


-- DATABASE 1 --
-- Spotify and Youtube
-- Statistics for the Top 10 songs of various spotify artists and their yt video.
-- Data set obtained on Kaggle https://www.kaggle.com/datasets/salvatorerastelli/spotify-and-youtube
-- Data collected on 7th of February, 2023.

-- View all data
SELECT * FROM Spotify_Youtube;


-- DATABASE 2 --
-- Spotify Artist Metadata Top 10k
-- Age, sex and whereabouts of the top 10 thousand artists on Spotify at the time.
-- Data set obtained on Kaggle https://www.kaggle.com/datasets/jackharding/spotify-artist-metadata-top-10k
-- Data collected on 2020

-- View all data
SELECT * FROM Spotify_Artist_Metadata;

-- Adjust DATABASE 2: change n/a to NULL, set one city instead of 3
UPDATE Spotify_Artist_Metadata SET city_1 = NULL WHERE city_1 = 'n/a';
UPDATE Spotify_Artist_Metadata SET city_2 = NULL WHERE city_2 = 'n/a';
UPDATE Spotify_Artist_Metadata SET city_3 = NULL WHERE city_3 = 'n/a';
UPDATE Spotify_Artist_Metadata SET city_1 = city_2 WHERE city_1 IS NULL;
UPDATE Spotify_Artist_Metadata SET city_1 = city_3 WHERE city_1 IS NULL;
sp_rename 'Spotify_Artist_Metadata.city_1', 'city', 'COLUMN';


-- DATABASE 3 --
-- Country Codes
-- Data set obtained on https://cloford.com/resources/codes/index.htm
-- Data converted from HTML table format to CSV on https://www.convertcsv.com/html-table-to-csv.htm

-- View relevant data
SELECT Country, Internet FROM Countries;

-- Adjust DATABASE 3: change UK/GB to GB
UPDATE Countries SET Country = 'United Kingdom', Internet = 'GB' WHERE Country = 'United Kingdom';

-- --------------------------------------------------------------------------------------------------
-- CREATE VIEWS AND JOINS FOR ANALYSIS --------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------

-- VIEW 1: Artists + Streams
CREATE VIEW Artist_Sreams AS
SELECT Artist, SUM(Stream) AS 'Streams'
FROM Spotify_Youtube
GROUP BY Artist;

SELECT * FROM Artist_Sreams;


-- VIEW 2: Artist + Country Code
CREATE VIEW Artist_CountryCode AS
SELECT DISTINCT Spotify_Youtube.Artist, Spotify_Artist_Metadata.country
FROM Spotify_Youtube
LEFT JOIN Spotify_Artist_Metadata ON Spotify_Youtube.Artist = Spotify_Artist_Metadata.artist;

SELECT * FROM Artist_CountryCode;


-- VIEW 3: Artist + Country Name + Region
CREATE VIEW Artist_Country_Region AS
SELECT Artist_CountryCode.Artist, Countries.Country, Countries.Region
FROM Artist_CountryCode
LEFT JOIN Countries ON Artist_CountryCode.Country = Countries.Internet;

SELECT * FROM Artist_Country_Region;


-- VIEW 4: Artist + Country Name + Region + City
CREATE VIEW Artist_Country_Region_City AS
SELECT DISTINCT
	Artist_Country_Region.Artist,
	Artist_Country_Region.Country,
	Artist_Country_Region.Region,
	Spotify_Artist_Metadata.City
FROM Artist_Country_Region
LEFT JOIN Spotify_Artist_Metadata 
ON Artist_Country_Region.Artist = Spotify_Artist_Metadata.artist;

SELECT * FROM Artist_Country_Region_City;


-- VIEW 5: Artist + Country Name + Region + Streams
CREATE VIEW Artist_Country_Region_City_Streams AS
SELECT 
	Artist_Country_Region_City.Artist,
	Artist_Country_Region_City.Country,
	Artist_Country_Region_City.Region,
	Artist_Country_Region_City.City,
	Artist_Sreams.Streams
FROM Artist_Country_Region_City
JOIN Artist_Sreams ON Artist_Country_Region_City.Artist = Artist_Sreams.Artist;

SELECT * FROM Artist_Country_Region_City_Streams;


-- Slice TOP 100 artists by spotify streams
CREATE VIEW top100 AS
SELECT TOP 100 artist, country, region, city, streams 
FROM Artist_Country_Region_City_Streams 
ORDER BY streams DESC;

SELECT * FROM top100;


-- Check missing data
SELECT * FROM top100 WHERE country IS NULL OR city IS NULL;

-- Update missing cities
UPDATE Spotify_Artist_Metadata SET city = 'Sheffield' WHERE artist = 'Arctic Monkeys';
UPDATE Spotify_Artist_Metadata SET city = 'Fort Stewart' WHERE artist = 'Khalid';
UPDATE Spotify_Artist_Metadata SET city = 'Dumfries' WHERE artist = 'Calvin Harris';
UPDATE Spotify_Artist_Metadata SET city = 'London' WHERE artist = 'Sam Smith';
UPDATE Spotify_Artist_Metadata SET city = 'New York' WHERE artist = 'Lady Gaga';
UPDATE Spotify_Artist_Metadata SET city = 'Inglewood' WHERE artist = 'Swae Lee';
UPDATE Spotify_Artist_Metadata SET city = 'New York' WHERE artist = 'Cardi B';
UPDATE Spotify_Artist_Metadata SET city = 'Middlesex' WHERE artist = 'Elton John';
UPDATE Spotify_Artist_Metadata SET city = 'Colorado Springs' WHERE artist = 'OneRepublic';
UPDATE Spotify_Artist_Metadata SET city = 'Philadelphia' WHERE artist = 'Lil Uzi Vert';
UPDATE Spotify_Artist_Metadata SET city = 'Middlesbrough' WHERE artist = 'James Arthur';
UPDATE Spotify_Artist_Metadata SET city = 'Miami Gardens' WHERE artist = 'Flo Rida';
UPDATE Spotify_Artist_Metadata SET city = 'San Juan' WHERE artist = 'Luis Fonsi';
UPDATE Spotify_Artist_Metadata SET city = 'Amstelveen' WHERE artist = 'Martin Garrix';
UPDATE Spotify_Artist_Metadata SET city = 'Stockholm' WHERE artist = 'Zara Larsson';
UPDATE Spotify_Artist_Metadata SET city = 'Waterloo' WHERE artist = 'The Kid LAROI';

-- Update remaining 12 columns on Excel and load on Power BI...
SELECT * FROM top100;

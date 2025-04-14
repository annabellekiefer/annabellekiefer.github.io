-- ============================================================================
/*
Create a database for a city festival (choose any, e.g., of your hometown or
create a fictional one) as a backend for a WebGIS. Search for information that
you can use for data modeling. The database itself should (if no reasons are
given) be in the third normal form. Import data and de-normalise - if necessary
with views. Create indexes where required. Create at least three queries for
the application that is defined in the second requirement to document that the
database works.
*/
-- ============================================================================
--1. DDL
-- ============================================================================
--1.1 Create PostGIS extension
-- ============================================================================
CREATE EXTENSION postgis;

-- ============================================================================
--1.2 Create tables
-- ============================================================================
CREATE TABLE areas (
    area_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT CHECK (category IN ('bunker', 'mainfloor', 'clubfloor', 'food_area', 'camping', 'parking', 'festival_ground')),
    geom GEOMETRY(POLYGON, 3857)
);

CREATE TABLE facilities (
    facility_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('toilet', 'first aid', 'exit', 'attraction', 'top-up station')),
    area_id INTEGER REFERENCES areas(area_id) ON DELETE CASCADE,
    geom GEOMETRY(POINT, 3857)
);

CREATE TABLE booths (
    booth_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('food', 'merchandise', 'drinks')),
    area_id INTEGER REFERENCES areas(area_id) ON DELETE CASCADE,
    geom GEOMETRY(POINT, 3857)
);

CREATE TABLE operators (
    operator_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    location TEXT
);

CREATE TABLE stages (
    stage_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('indoor_tent', 'indoor_bunker', 'outdoor')),
    floor_type TEXT CHECK (floor_type IN ('mainfloor', 'clubfloor')),
    genre TEXT,
    area_id INTEGER REFERENCES areas(area_id) ON DELETE CASCADE,
	operator_id INTEGER REFERENCES operators(operator_id) ON DELETE CASCADE,
    geom GEOMETRY(POINT, 3857)
);

CREATE TABLE timetable (
    event_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    festival_day TEXT CHECK (festival_day IN ('Friday', 'Saturday')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    stage_id INTEGER REFERENCES stages(stage_id) ON DELETE CASCADE
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    current_location GEOMETRY(POINT, 3857),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
--2. DML
-- ============================================================================
-- ============================================================================
--2.1 Add data with QGIS (for point & polygon data)
-- ============================================================================
--For the recreation of the database, the following SQL queries were used to 
--get the Insert-statements
/*
SELECT 'INSERT INTO areas (area_id, name, category, geom) VALUES (' || 
       area_id || ', ''' || name || ''', ''' || category || ''', ' || 
       'ST_GeomFromText(''' || ST_AsText(geom) || ''', 3857));'
FROM areas;

SELECT 
    'INSERT INTO booths (booth_id, name, type, area_id, geom) VALUES (' || 
    booth_id || ', ''' || name || ''', ''' || type || ''', ' || 
    area_id || ', ST_SetSRID(ST_GeomFromText(''' || ST_AsText(geom) || '''), 3857));'
FROM booths;

SELECT 
    'INSERT INTO stages (stage_id, name, type, floor_type, genre, area_id, operator_id, geom) VALUES (' || 
    stage_id || ', ''' || name || ''', ''' || type || ''', ''' || 
    floor_type || ''', ''' || genre || ''', ' || 
    area_id || ', ' || operator_id || ', ST_SetSRID(ST_GeomFromText(''' || ST_AsText(geom) || '''), 3857));'
FROM stages;

SELECT 
    'INSERT INTO facilities (facility_id, name, type, area_id, geom) VALUES (' || 
    facility_id || ', ''' || name || ''', ''' || type || ''', ' || 
    area_id || ', ST_SetSRID(ST_GeomFromText(''' || ST_AsText(geom) || '''), 3857));'
FROM facilities;
*/
-- ============================================================================
-- Areas
-- ============================================================================

INSERT INTO areas (area_id, name, category, geom) 
VALUES 
	(1, 'OpenAirFloor', 'mainfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826581.2524594333 6453703.636723215,826617.6829003898 6453703.236388698,826617.6829003898 6453743.470007557,826581.4526266912 6453744.070509331,826581.4526266912 6453744.070509331,826581.2524594333 6453703.636723215))'), 3857)),
	(2, 'ClassicTerminal', 'mainfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826582.4534629814 6453955.8474683,826581.2524594334 6453893.395283802,826627.6912632901 6453892.994949287,826628.0915978061 6453954.646464751,826628.0915978061 6453954.646464751,826582.4534629814 6453955.8474683))'), 3857)),
	(3, 'CenturyCircus', 'mainfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826934.3475025505 6453943.437098305,826851.8785922532 6453945.038436369,826850.2772541892 6453854.963170268,826933.9471680344 6453856.164173815,826933.9471680344 6453856.164173815,826934.3475025505 6453943.437098305))'), 3857)),
	(4, 'Homebase', 'mainfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826853.0795958012 6453704.837726764,826852.6792612851 6453631.17617582,826936.3491751304 6453628.373834208,826936.7495096463 6453700.033712572,826936.7495096463 6453700.033712572,826853.0795958012 6453704.837726764))'), 3857)),
	(5, 'bunker_1', 'bunker', ST_SetSRID(ST_GeomFromText('POLYGON((826401.1019272305 6453725.054619826,826426.723336255 6453680.2171540335,826515.5975988082 6453682.61916113,826545.6226875087 6453719.449936602,826509.5925810682 6453735.062982726,826508.7919120361 6453759.083053687,826541.2190078326 6453765.488405943,826516.3982678403 6453804.721188512,826433.128688511 6453807.123195607,826401.5022617466 6453770.6927546505,826437.132033671 6453759.083053687,826435.5306956071 6453733.861979178,826435.5306956071 6453733.861979178,826435.5306956071 6453733.861979178,826401.1019272305 6453725.054619826))'), 3857)),
	(6, 'bunker_2', 'bunker', ST_SetSRID(ST_GeomFromText('POLYGON((826432.728353995 6453819.133231088,826518.8002749364 6453819.93390012,826550.4267017008 6453856.3643410755,826515.9979333243 6453871.176718168,826513.5959262282 6453897.198461709,826544.8220184767 6453903.603813965,826522.4032855803 6453943.236931049,826439.1337062512 6453944.037600081,826407.9076140027 6453907.607159125,826441.9360478632 6453896.798127192,826439.9343752832 6453872.377721716,826410.3096210987 6453860.367686236,826410.3096210987 6453860.367686236,826432.728353995 6453819.133231088))'), 3857)),
	(7, 'bunker_3', 'bunker', ST_SetSRID(ST_GeomFromText('POLYGON((826546.4233565406 6454007.290453611,826561.6360681489 6454041.318887471,826582.8537974971 6454039.717549407,826588.4584807212 6454007.690788127,826620.4852420017 6454029.308851991,826623.6879181297 6454125.389135832,826594.8638329774 6454146.206530664,826584.4551355612 6454115.781107448,826564.4384097608 6454114.5801039,826547.6243600886 6454148.608537761,826526.0062962243 6454141.402516472,826517.1989368722 6454110.5767587405,826517.1989368722 6454026.106175863,826517.1989368722 6454026.106175863,826546.4233565406 6454007.290453611))'), 3857)),
	(8, 'bunker_4', 'bunker', ST_SetSRID(ST_GeomFromText('POLYGON((826661.7196971503 6453977.2653649105,826680.9357539186 6453936.431244278,826771.8116890519 6453933.628902666,826809.0427990406 6453970.059343623,826773.0126926 6453986.873393294,826771.411354536 6454010.092795223,826802.6374467844 6454015.697478447,826779.418044856 6454058.132937144,826696.1484655269 6454058.933606176,826661.7196971503 6454021.302161671,826696.9491345589 6454009.292126191,826696.9491345589 6453984.471386199,826696.9491345589 6453984.471386199,826661.7196971503 6453977.2653649105))'), 3857)),
	(9, 'bunker_5', 'bunker', ST_SetSRID(ST_GeomFromText('POLYGON((826688.5421097225 6453916.814852991,826659.3176900541 6453881.185081067,826692.1451203666 6453868.774711071,826693.3461239146 6453844.754640111,826658.517021022 6453834.74627721,826685.7397681104 6453791.910483997,826775.0143651797 6453792.711153029,826803.8384503322 6453829.541928502,826768.2086784077 6453844.354305594,826767.4080093757 6453869.175045587,826799.0344361401 6453874.779728811,826774.6140306637 6453916.814852991,826774.6140306637 6453916.814852991,826688.5421097225 6453916.814852991))'), 3857)),
	(10, 'bunker_6', 'bunker', ST_SetSRID(ST_GeomFromText('POLYGON((826668.9257184381 6453764.68773691,826656.5153484419 6453743.870342078,826691.3444513344 6453730.258968534,826691.3444513344 6453703.036221446,826653.3126723139 6453698.232207254,826656.1150139259 6453679.816819517,826666.123376826 6453665.805111457,826686.5404371424 6453654.595745008,826771.4113545356 6453657.3980866205,826804.6391193641 6453693.428193061,826768.2086784076 6453709.441573702,826767.8083438915 6453731.059637566,826795.831760012 6453741.068000466,826788.2254042078 6453760.68439175,826769.0093474395 6453771.493423683,826690.5437823024 6453775.496768842,826690.5437823024 6453775.496768842,826668.9257184381 6453764.68773691))'), 3857)),
	(11, 'food_area_1', 'food_area', ST_SetSRID(ST_GeomFromText('POLYGON((826572.4451000807 6453862.3693588115,826570.4434275007 6453769.491751098,826632.8956119976 6453767.089744003,826632.8956119976 6453859.5670171995,826632.8956119976 6453859.5670171995,826572.4451000807 6453862.3693588115))'), 3857)),
	(12, 'food_area_2', 'food_area', ST_SetSRID(ST_GeomFromText('POLYGON((826853.4799303168 6453755.880377553,826853.4799303168 6453715.8469259525,826922.3374670697 6453711.843580793,826923.1381361018 6453752.277366909,826923.1381361018 6453752.277366909,826853.4799303168 6453755.880377553))'), 3857)),
	(13, 'food_area_3', 'food_area', ST_SetSRID(ST_GeomFromText('POLYGON((826479.1671578512 6453648.1903927475,826487.1738481713 6453619.366307596,826560.0347300844 6453639.383033396,826551.6277052482 6453670.609125644,826551.6277052482 6453670.609125644,826479.1671578512 6453648.1903927475))'), 3857)),
	(14, 'camping_standard', 'camping', ST_SetSRID(ST_GeomFromText('POLYGON((828596.9367475224 6452715.010635936,828699.4223836199 6452702.199931423,828572.916676562 6452471.607250204,828456.0189978883 6452486.01929278,828319.9052624464 6452282.649358649,828249.4463876293 6452314.676119929,828212.6156121568 6452313.074781866,828170.9808224922 6452305.068091545,828082.9072289709 6452436.377812795,827909.9627180563 6452333.892176698,827519.2362304346 6452213.791821896,827296.6502395353 6452138.528932887,826960.3692460903 6452532.458096637,827040.4361492915 6452554.876829534,826838.6675532245 6452961.616697796,827050.0441776756 6453016.0621919725,827021.2200925231 6453064.102333893,827203.7726318218 6453121.7505041985,827357.5010859681 6453256.262901576,827466.3920743217 6453525.287696332,827466.3920743217 6453525.287696332,827466.3920743217 6453525.287696332,827466.3920743217 6453525.287696332,827589.6951052513 6454135.397498726,827801.0717297023 6453914.41284589,828143.7580754034 6454032.911862625,828367.9454043667 6454026.5065103695,828252.6490637569 6454106.57341357,828265.4597682691 6454177.032288387,828444.8096314397 6454128.992146467,828422.3908985432 6454430.043702503,828335.918643086 6454599.785537289,828380.7561088786 6455089.79498488,828588.9300572017 6455016.133433935,828877.1709087259 6454692.663145002,828829.1307668053 6454241.085810948,828864.3602042138 6453936.831578784,828758.6718919881 6453946.439607168,828745.861187476 6453872.778056222,828835.5361190613 6453827.94059043,828697.8210455553 6453334.72846671,828595.3354094578 6453187.40536482,828467.2283643357 6453229.040154484,828038.0697631774 6453158.581279667,828095.7179334823 6452966.420711985,828243.0410353724 6452806.286905582,828460.8230120797 6452742.233383021,828460.8230120797 6452742.233383021,828596.9367475224 6452715.010635936))'), 3857)),
	(15, 'camping_comfort', 'camping', ST_SetSRID(ST_GeomFromText('POLYGON((825504.7529458923 6451803.849277504,825837.8312632092 6451742.998431071,825738.5483032397 6451986.401816803,825778.5817548403 6452074.475410324,825648.8733716544 6452120.914214181,825701.7175277672 6452250.622597367,825552.7930878126 6452335.493514759,825480.7328749315 6452034.441958722,825480.7328749315 6452034.441958722,825504.7529458923 6451803.849277504))'), 3857)),
	(16, 'parking', 'parking', ST_SetSRID(ST_GeomFromText('POLYGON((825489.425550225 6451618.749385575,825467.6566044169 6451155.664538383,825544.8374122821 6451131.916597501,825766.4848605107 6451317.942134407,826052.4496486267 6451698.898686049,825504.7473011452 6451803.800885843,825486.4261358167 6451978.076139504,825160.757759039 6451977.952452313,825164.7157491859 6452018.027102551,825051.9130299982 6452044.248787275,824868.3612369342 6451985.868432608,824589.3229315751 6451508.930619904,824699.1571581527 6451503.983132221,824958.4055127772 6451536.636550933,825210.7273846444 6451549.5000189105,825206.7693944975 6451606.890876041,825206.7693944975 6451606.890876041,825489.425550225 6451618.749385575))'), 3857)),
	(17, 'DirtyWorkz', 'clubfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826758.5676068701 6453592.542291599,826763.3302944773 6453572.896205219,826799.0504515304 6453582.421580434,826793.6924279724 6453597.900315157,826793.6924279724 6453597.900315157,826758.5676068701 6453592.542291599))'), 3857)),
	(18, 'BLACKLIST', 'clubfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826496.6326421227 6453989.106947876,826483.6682765447 6453972.153546736,826503.4140025788 6453962.779313164,826515.1816574881 6453979.732714304,826496.6326421227 6453989.106947876))'), 3857)),
	(19, 'Masters_of_Hardcore', 'clubfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826667.7622677524 6454105.387334522,826655.5957092869 6454093.021324278,826679.5299226617 6454066.893141343,826693.0926435741 6454081.453121147,826693.0926435741 6454081.453121147,826667.7622677524 6454105.387334522))'), 3857)),
	(20, 'HEXTechnomovement', 'clubfloor', ST_SetSRID(ST_GeomFromText('POLYGON((826879.7795078973 6453791.849139311,826879.9789596755 6453771.903961499,826901.3202999347 6453770.906702609,826901.3202999347 6453790.851880421,826879.7795078973 6453791.849139311))'), 3857)),
	(21, 'festival_ground', 'festival_ground', ST_SetSRID(ST_GeomFromText('POLYGON((826253.293051985 6453486.590323709,826428.1614235551 6453485.549440545,826957.970954086 6453602.128354926,826960.0527204144 6453964.355696035,826532.2497399661 6454243.312384019,826291.8057290572 6453866.512678611,826291.8057290572 6453866.512678611,826291.8057290573 6453866.496414811,826291.8057290573 6453866.496414811,826253.293051985 6453486.590323709))'), 3857));

-- ============================================================================
-- Booths
-- ============================================================================

INSERT INTO booths (booth_id, name, type, area_id, geom) 
VALUES 
	(1, 'merchandise_1', 'merchandise', 21, ST_SetSRID(ST_GeomFromText('POINT(826536.7399327455 6453518.770846215)'), 3857)),
	(2, 'merchandise_2', 'merchandise', 21, ST_SetSRID(ST_GeomFromText('POINT(826561.9868860857 6453809.636787823)'), 3857)),
	(3, 'merchandise_3', 'merchandise', 21, ST_SetSRID(ST_GeomFromText('POINT(826641.9355716633 6453808.584831433)'), 3857)),
	(4, 'drinks_1', 'drinks', 21, ST_SetSRID(ST_GeomFromText('POINT(826559.8829733075 6453654.999198615)'), 3857)),
	(5, 'drinks_2', 'drinks', 21, ST_SetSRID(ST_GeomFromText('POINT(826601.9612288745 6453764.139673992)'), 3857)),
	(6, 'drinks_3', 'drinks', 21, ST_SetSRID(ST_GeomFromText('POINT(826602.487207069 6453868.020367424)'), 3857)),
	(7, 'drinks_4', 'drinks', 21, ST_SetSRID(ST_GeomFromText('POINT(826846.5410893584 6453735.999840583)'), 3857)),
	(8, 'Burger_Bunker', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826580.3961228962 6453781.759943512)'), 3857)),
	(9, 'Pizza_Paradise', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826579.8701447016 6453802.799071296)'), 3857)),
	(10, 'Techno_Tacos', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826580.9221010908 6453823.312220885)'), 3857)),
	(11, 'Hardcore_Hotdogs', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826580.9221010908 6453841.195479501)'), 3857)),
	(12, 'Rave_Ramen', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826580.3961228962 6453857.500803533)'), 3857)),
	(13, 'Festival_Fries', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826600.9092724852 6453854.87091256)'), 3857)),
	(14, 'Bass_BBQ', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826619.3185092958 6453852.766999782)'), 3857)),
	(15, 'Neon_Noodles', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826623.5263348526 6453835.935697556)'), 3857)),
	(16, 'Acid_Açaí', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826623.5263348526 6453818.052438939)'), 3857)),
	(17, 'Trance_Tapas', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826622.4743784633 6453799.117223934)'), 3857)),
	(18, 'DeepHouse_Döner', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826620.8964438796 6453781.233965318)'), 3857)),
	(19, 'House_Hummus', 'food', 11, ST_SetSRID(ST_GeomFromText('POINT(826601.9612288744 6453779.1300525395)'), 3857)),
	(20, 'Vegan_Vibes', 'food', 12, ST_SetSRID(ST_GeomFromText('POINT(826867.580217142 6453748.623317253)'), 3857)),
	(21, 'Electro_Eggs', 'food', 12, ST_SetSRID(ST_GeomFromText('POINT(826889.1453231202 6453749.675273643)'), 3857)),
	(22, 'Melodic_Muffins', 'food', 12, ST_SetSRID(ST_GeomFromText('POINT(826913.8662982659 6453744.941469891)'), 3857)),
	(23, 'Funky_Falafel', 'food', 12, ST_SetSRID(ST_GeomFromText('POINT(826915.9702110442 6453723.902342107)'), 3857)),
	(24, 'Underground_Udon', 'food', 12, ST_SetSRID(ST_GeomFromText('POINT(826891.775214093 6453722.3244075235)'), 3857)),
	(25, 'Progressive_Pancakes', 'food', 12, ST_SetSRID(ST_GeomFromText('POINT(826867.580217142 6453721.798429329)'), 3857)),
	(26, 'Lush_Lángos', 'food', 13, ST_SetSRID(ST_GeomFromText('POINT(826546.7335184425 6453650.265394866)'), 3857)),
	(27, 'Hardstyle_Halloumi', 'food', 13, ST_SetSRID(ST_GeomFromText('POINT(826531.4801507994 6453643.427678335)'), 3857)),
	(28, 'Minimal_Meatballs', 'food', 13, ST_SetSRID(ST_GeomFromText('POINT(826515.1748267672 6453638.6938745845)'), 3857)),
	(29, 'Groove_Gyros', 'food', 13, ST_SetSRID(ST_GeomFromText('POINT(826495.7136335673 6453635.012027222)'), 3857)),
	(30, 'Psytrance_Pretzels', 'food', 13, ST_SetSRID(ST_GeomFromText('POINT(826504.6552628754 6453649.73941667)'), 3857));

-- ============================================================================
-- Stages
-- ============================================================================

INSERT INTO stages (stage_id, name, type, floor_type, genre, area_id, operator_id, geom) 
VALUES 
	(1, 'OpenAirFloor', 'outdoor', 'mainfloor', 'mixed', 1, 1, ST_SetSRID(ST_GeomFromText('POINT(826599.5616658438 6453742.386001241)'), 3857)),
	(2, 'ClassicTerminal', 'outdoor', 'mainfloor', 'mixed', 2, 1, ST_SetSRID(ST_GeomFromText('POINT(826605.7955003252 6453952.777914982)'), 3857)),
	(3, 'CenturyCircus', 'indoor_tent', 'mainfloor', 'techno', 3, 1, ST_SetSRID(ST_GeomFromText('POINT(826892.0324002552 6453940.050502917)'), 3857)),
	(4, 'Homebase', 'indoor_tent', 'mainfloor', 'house', 4, 1, ST_SetSRID(ST_GeomFromText('POINT(826890.7336847382 6453698.229673668)'), 3857)),
	(5, 'DirtyWorkz', 'outdoor', 'clubfloor', 'hardstyle', 17, 2, ST_SetSRID(ST_GeomFromText('POINT(826780.6026089027 6453587.838854727)'), 3857)),
	(6, 'Gayphoria', 'indoor_bunker', 'clubfloor', 'mixed', 8, 3, ST_SetSRID(ST_GeomFromText('POINT(826683.9781744438 6454037.973652895)'), 3857)),
	(7, 'HardcoreGladiators', 'indoor_bunker', 'clubfloor', 'hardcore', 6, 4, ST_SetSRID(ST_GeomFromText('POINT(826522.1100180662 6453923.433268025)'), 3857)),
	(8, 'HEAVEN&HILL', 'outdoor', 'clubfloor', 'techno', 7, 5, ST_SetSRID(ST_GeomFromText('POINT(826575.0577964879 6454105.695812976)'), 3857)),
	(9, 'HeavensGate', 'outdoor', 'clubfloor', 'techno', 8, 6, ST_SetSRID(ST_GeomFromText('POINT(826733.392018499 6453994.709123592)'), 3857)),
	(10, 'HEXTechnomovement', 'outdoor', 'clubfloor', 'techno', 20, 7, ST_SetSRID(ST_GeomFromText('POINT(826888.1624477317 6453784.445349667)'), 3857)),
	(11, 'Masters_of_Hardcore', 'outdoor', 'clubfloor', 'hardcore', 19, 8, ST_SetSRID(ST_GeomFromText('POINT(826674.8439942825 6454092.204311743)'), 3857)),
	(12, 'PLAY!', 'indoor_bunker', 'clubfloor', 'mixed', 10, 9, ST_SetSRID(ST_GeomFromText('POINT(826678.3446000218 6453754.550620814)'), 3857)),
	(13, 'PUNX', 'outdoor', 'clubfloor', 'mixed', 9, 10, ST_SetSRID(ST_GeomFromText('POINT(826729.066162427 6453855.776056517)'), 3857)),
	(14, 'SUNSHINE_LIVE', 'outdoor', 'clubfloor', 'mixed', 5, 11, ST_SetSRID(ST_GeomFromText('POINT(826460.437801878 6453746.9315019995)'), 3857)),
	(15, 'Tunnel', 'indoor_bunker', 'clubfloor', 'techno', 9, 12, ST_SetSRID(ST_GeomFromText('POINT(826680.9911401173 6453825.834958386)'), 3857)),
	(16, 'V.I.B.E.Z', 'indoor_tent', 'clubfloor', 'goa', 6, 13, ST_SetSRID(ST_GeomFromText('POINT(826476.1114177285 6453883.857951582)'), 3857)),
	(17, 'AcidWars', 'indoor_bunker', 'clubfloor', 'techno', 5, 14, ST_SetSRID(ST_GeomFromText('POINT(826525.0914672613 6453775.013397065)'), 3857)),
	(18, 'AirportOpenAir', 'outdoor', 'clubfloor', 'techno', 7, 15, ST_SetSRID(ST_GeomFromText('POINT(826572.3300039219 6454047.777850686)'), 3857)),
	(19, 'BLACKLIST', 'indoor_tent', 'clubfloor', 'dubstep', 18, 16, ST_SetSRID(ST_GeomFromText('POINT(826496.1388157597 6453978.552714013)'), 3857)),
	(20, 'DieRakete', 'indoor_bunker', 'clubfloor', 'techno', 9, 17, ST_SetSRID(ST_GeomFromText('POINT(826683.606459567 6453890.470710499)'), 3857));

-- ============================================================================
-- Facilities
-- ============================================================================
INSERT INTO facilities (facility_id, name, type, area_id, geom) 
VALUES 
	(1, 'toilets_1', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826402.6154931257 6453758.616902949)'), 3857)),
	(2, 'toilets_2', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826406.8233186825 6453893.267320764)'), 3857)),
	(3, 'toilets_3', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826575.1363409511 6454147.840766946)'), 3857)),
	(4, 'toilets_4', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826794.9952262894 6453993.203177736)'), 3857)),
	(5, 'toilets_5', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826791.8393571218 6453855.396890754)'), 3857)),
	(6, 'toilets_6', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826789.7354443435 6453719.69451655)'), 3857)),
	(7, 'toilets_7', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826755.0208835006 6453579.784316789)'), 3857)),
	(8, 'toilets_8', 'toilet', 21, ST_SetSRID(ST_GeomFromText('POINT(826411.0311442392 6453633.434092637)'), 3857)),
	(9, 'first_aid', 'first aid', 21, ST_SetSRID(ST_GeomFromText('POINT(826302.6796361539 6453821.7342863)'), 3857)),
	(10, 'emergency_exit_1', 'exit', 21, ST_SetSRID(ST_GeomFromText('POINT(826650.8772009719 6454157.308374449)'), 3857)),
	(11, 'emergency_exit_2', 'exit', 21, ST_SetSRID(ST_GeomFromText('POINT(826296.3678978187 6453745.993426279)'), 3857)),
	(12, 'emergency_exit_3', 'exit', 21, ST_SetSRID(ST_GeomFromText('POINT(826264.0202388515 6453489.316067318)'), 3857)),
	(13, 'bungee_jumping', 'attraction', 21, ST_SetSRID(ST_GeomFromText('POINT(826638.7797024964 6453669.726588063)'), 3857)),
	(14, 'top_up_1', 'top-up station', 21, ST_SetSRID(ST_GeomFromText('POINT(826419.4467953527 6453597.1415972095)'), 3857)),
	(15, 'top_up_2', 'top-up station', 5, ST_SetSRID(ST_GeomFromText('POINT(826520.9605869082 6453783.863856289)'), 3857)),
	(16, 'top_up_3', 'top-up station', 6, ST_SetSRID(ST_GeomFromText('POINT(826516.2267831567 6453929.296827091)'), 3857)),
	(17, 'top_up_4', 'top-up station', 21, ST_SetSRID(ST_GeomFromText('POINT(826628.7861167988 6454022.131978437)'), 3857)),
	(18, 'top_up_5', 'top-up station', 21, ST_SetSRID(ST_GeomFromText('POINT(826800.255008235 6453811.214722407)'), 3857)),
	(19, 'top_up_6', 'top-up station', 21, ST_SetSRID(ST_GeomFromText('POINT(826650.8772009715 6453657.892078684)'), 3857)),
	(20, 'top_up_7', 'top-up station', 21, ST_SetSRID(ST_GeomFromText('POINT(826566.1947116425 6453688.135824873)'), 3857));

-- ============================================================================
--2.2 Add data with SQL
-- ============================================================================
-- Timetable OpenAirFloor
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Bennett', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 1 ),
	('LariLuke', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 1 ),
	('Öwnboss', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 1 ),
	('NERVO', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 1 ),
	('Neelix', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 1 ),
	('OBS', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 1 ),
	('MOGUAI', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 1 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('BastiM', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 19:00:00', 1 ),
	('ACINA', 'Saturday', '2025-08-02 19:00:00', '2025-08-02 20:30:00', 1 ),
	('Mausio', 'Saturday', '2025-08-02 20:30:00', '2025-08-02 22:00:00', 1 ),
	('Topic', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 1 ),
	('PaulvanDyk', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:10:00', 1 ),
	('NatureOneInc.', 'Saturday', '2025-08-03 01:10:00', '2025-08-03 01:30:00', 1 ),
	('AlleFarben', 'Saturday', '2025-08-03 01:30:00', '2025-08-03 03:00:00', 1 ),
	('Tchami', 'Saturday', '2025-08-03 03:00:00', '2025-08-03 04:30:00', 1 ),
	('SendervanDoorn', 'Saturday', '2025-08-03 04:30:00', '2025-08-03 06:00:00', 1 ),
	('DJDag', 'Saturday', '2025-08-03 06:00:00', '2025-08-03 08:00:00', 1 );

-- ============================================================================
-- Timetable ClassicTerminal
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('SUNSHINELIVE', 'Friday', '2025-08-01 20:00:00', '2025-08-01 22:30:00', 2 ),
	('MarioPiu', 'Friday', '2025-08-01 22:30:00', '2025-08-01 00:00:00', 2 ),
	('WoodyvanEyden', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 2 ),
	('CharlyLownoise', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 2 ),
	('BonzaiAllStars', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 2 ),
	('TomWax', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 2 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('DJToyax', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 2 ),
	('IanVanDahl', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 2 ),
	('DJQuicksilver', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 2 ),
	('Westbam', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 2 ),
	('MissDjax', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 2 ),
	('Talla2XLC', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 2 ),
	('NIELSVANGOGH', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 2 );

-- ============================================================================
-- Timetable CenturyCircus
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('PETERPAHN', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:30:00', 3 ),
	('SHDW&ObscureShape', 'Friday', '2025-08-01 21:30:00', '2025-08-01 23:00:00', 3 ),
	('GregorTresher', 'Friday', '2025-08-01 23:00:00', '2025-08-02 00:00:00', 3 ),
	('SvenVäth', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 3 ),
	('CharlottedeWitte', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 3 ),
	('KlaudiaGlawas', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 3 ),
	('CharlieSparks', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 3 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('EricWishes', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 19:30:00', 3 ),
	('Klanglos', 'Saturday', '2025-08-02 19:30:00', '2025-08-02 21:00:00', 3),
	('PAN-POT', 'Saturday', '2025-08-02 21:00:00', '2025-08-02 22:30:00', 3 ),
	('LillyPalmer', 'Saturday', '2025-08-02 22:30:00', '2025-08-03 00:00:00', 3 ),
	('AmelieLens', 'Saturday', '2025-08-03 00:00:00', '2025-08-03 01:30:00', 3 ),
	('SHLOMO', 'Saturday', '2025-08-03 01:30:00', '2025-08-03 03:30:00', 3 ),
	('Pappenheimer', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 3 ),
	('Trym', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 06:30:00', 3 ),
	('Alignment', 'Saturday', '2025-08-03 06:30:00', '2025-08-03 08:00:00', 3 );

-- ============================================================================
-- Timetable HomeBase
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('re:frame', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 4 ),
	('Xander', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 4 ),
	('LOVRA', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 4 ),
	('CLAPTONE', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 4 ),
	('TiniGessler', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 4 ),
	('AKAAKA', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 4 ),
	('Babor', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 4 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('PatrickAgricultor', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 12:00:00', 4 ),
	('AlexBreitling', 'Saturday', '2025-08-02 12:00:00', '2025-08-02 21:30:00', 4 ),
	('MonkeySafari', 'Saturday', '2025-08-02 21:30:00', '2025-08-02 23:00:00', 4 ),
	('SuperFlu', 'Saturday', '2025-08-02 23:00:00', '2025-08-03 00:30:00', 4 ),
	('MatthiasTanzmann', 'Saturday', '2025-08-03 00:30:00', '2025-08-03 02:00:00', 4 ),
	('DominikEulberg', 'Saturday', '2025-08-03 02:00:00', '2025-08-03 03:30:00', 4 ),
	('TownshipRebellion', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 4 ),
	('BlackCircle', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 4 );

-- ============================================================================
-- Timetable DirtyWorkz
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('RuffLimits', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 5 ),
	('GLDYLX', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 5 ),
	('DrRude', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 5 ),
	('LostIdentity', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 5 ),
	('Teknoclash', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 5 ),
	('SubSonik', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 5 ),
	('DROPIXX', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 5 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Alleviate', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 5 ),
	('Solstice', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 5 ),
	('Ecstatic', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 5 ),
	('JayReeve', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 5 ),
	('Primeshock', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 5 ),
	('Refuzion', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 5 ),
	('JNXD', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 5 );

-- ============================================================================
-- Timetable Gayphoria
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Paytric', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 6 ),
	('NicoJansen', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 6 ),
	('Simone', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 6 ),
	('Kratz&Kiesslich', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 6 ),
	('TomFranke', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 6 ),
	('Babor', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',6 ),
	('PatrikRoss', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 6 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Kratz&Kiesslich', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 6 ),
	('SimonPhinixx', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 6 ),
	('DominikDiel', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 6 ),
	('FrankDuxxx', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 6 ),
	('Hotte', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 6 ),
	('JamX', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 6 ),
	('Raoul', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 6 );

-- ============================================================================
-- Timetable HardcoreGladiators
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('UnmaskedFury', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 7 ),
	('Hystic', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 7 ),
	('Ron&McIke', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 7 ),
	('Tensor&Re-Direction', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 7 ),
	('Effection', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 7 ),
	('Mr.Bassmeister', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',7 ),
	('TerrorClown', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 7);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('AND', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 7 ),
	('Director', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 7 ),
	('MastersofNoise', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 7 ),
	('MindTrip', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 7 ),
	('SonixTheHeadshock', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 7 ),
	('TheMotordogs', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 7 ),
	('Emphaser', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 7 );

-- ============================================================================
-- Timetable HEAVEN&HILL
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('TroubaMix', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 8 ),
	('Kenlo&Scaffa', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 8 ),
	('Nitrax', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 8 ),
	('MarcWall.E', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 8 ),
	('DIVISION', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 8 ),
	('NICORUSH', 'Friday', '2025-08-02 03:00:00', '2025-08-02 06:00:00',8 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Fabs', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 8 ),
	('TroubaMix', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 8 ),
	('2ElectronicSouls', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 8 ),
	('DanG.', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 8 ),
	('Kenlo&Scaffa', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 8 ),
	('DJFalk', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 8 ),
	('NIELSVANGOGH', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 8 );

-- ============================================================================
-- Timetable HeavensGate
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Fa:Ras', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 9 ),
	('RonwithLeeds', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 9 ),
	('RalphieB', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 9 ),
	('JamesCottle', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 9 ),
	('ReneAblaze', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 9 ),
	('Asteroid', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',9 ),
	('WoodyvanEyden', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 9);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Cyre', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 9 ),
	('TomWax', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 9 ),
	('DJSakin', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 9 ),
	('LXD', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 9 ),
	('Talla2XLC', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 9 ),
	('D72', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 9 ),
	('AllenWatts', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 9 );

-- ============================================================================
-- Timetable HEXTechnomovement
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('NOVAH', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 10 ),
	('SaraLandry', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 10 ),
	('LorenzoRaganzini', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 10 ),
	('PaoloFerrara', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 10 ),
	('OGUZ', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 10 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Noneoftheabove', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 10 ),
	('Flymeon', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 10 ),
	('Vendex', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 10 ),
	('Caravel', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 10 ),
	('Tham', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 10 ),
	('LorenzoRaganzini', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 10 );

-- ============================================================================
-- Timetable Masters of Hardcore
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Bass-D', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 11 ),
	('ThaWatcher', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 11 ),
	('GridKiller', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 11 ),
	('AniMe', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 11 ),
	('Hysta', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 11 ),
	('Furyan', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',11 ),
	('Angerfist', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 11);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('AlexLauthals', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 11 ),
	('TonyMess', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 11 ),
	('P.A.C.O', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 11 ),
	('FrankKlassen', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 11 ),
	('Tube&Berger', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 11 ),
	('JulietSikora', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 11 ),
	('MarieBloomfield', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 11 );

-- ============================================================================
-- Timetable PLAY!
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Sixten', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 12 ),
	('BrianBrainstorm', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 12 ),
	('Lynel', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 12 ),
	('Montee', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 12 ),
	('JonVoid', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 12 ),
	('LyDaBuddah', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',12 ),
	('Fub2bFeed', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 12);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Unfused', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 12 ),
	('Alee', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 12 ),
	('Catscan', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 12 ),
	('Ophidian', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 12 ),
	('NeverSurrender', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 12 ),
	('MadDog', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 12 ),
	('DaY-mar', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 12 );

-- ============================================================================
-- Timetable PUNX
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('ContestWinner', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 13 ),
	('liquidfive', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 13 ),
	('MaxLean', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 13 ),
	('LucasButler', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 13 ),
	('MOGUAI', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 13 ),
	('FrankSonic', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',13 ),
	('Child', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 13);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Siphlex', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 13 ),
	('Moulder', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 13 ),
	('Laeti', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 13 ),
	('LYNE', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 13 ),
	('Voicians', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 13 ),
	('Crewb2b', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 13 ),
	('Pull180', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 13 );

-- ============================================================================
-- Timetable SUNSHINE LIVE
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Klanglos', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 14 ),
	('LOVRA', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 14 ),
	('ChrisNitro', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 14 ),
	('AliciaHahn', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 14 ),
	('DJhttps', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 14 ),
	('AKAAKA', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',14 ),
	('BenDust', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 14);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('TinaTischler', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 14 ),
	('DJFalk', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 14 ),
	('DJHildegard', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 14 ),
	('NIELSVANGOGH', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 14 ),
	('EricSSL', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 14 ),
	('DEVN6', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 14 ),
	('EricWishes', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 14 );

-- ============================================================================
-- Timetable Tunnel
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('DJDoom', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 15 ),
	('DJester', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 15 ),
	('MadnessM', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 15 ),
	('FrankyB', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 15 ),
	('DJDoom', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 15 ),
	('M-Win', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',15 ),
	('Maniac', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 15);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('MadnessM', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 15 ),
	('Kevo', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 15 ),
	('Freaqheadz', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 15 ),
	('Emphases', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 15 ),
	('Texx', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 15 ),
	('ChrizzD.', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 15 ),
	('DJDoom', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 15 );

-- ============================================================================
-- Timetable V.I.B.E.Z
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('TOKRA', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 16 ),
	('T.O.M.E.K.K.', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 16 ),
	('Taluma', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 16 ),
	('Nomo', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 16 ),
	('Doctor-Verleihnix', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 16 ),
	('Patara', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00',16 ),
	('DJANEANNELI', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 16);

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Haircutter', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 16 ),
	('T.O.M.E.K.K.', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 16 ),
	('Grimlock', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 16 ),
	('DjaneLuumica', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 16 ),
	('Akidala', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 16 ),
	('Necmi', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 16 ),
	('Marathi', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 16 );

-- ============================================================================
-- Timetable AcidWars
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('JensMueller', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 17 ),
	('DirtBasscore', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 17 ),
	('Tiko', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 17 ),
	('IanCrank', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 17 ),
	('ManatArms', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 17 ),
	('AlexiaK', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 17 ),
	('SteveShaden', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 17 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('CruelActivity', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 17 ),
	('MechanicFreakz', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 17 ),
	('DominikSaltevski', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 17 ),
	('ScovexVeyla', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 17 ),
	('ManatArms', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 17 ),
	('KerstinEden', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 17 ),
	('Crotekk', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 17 );

-- ============================================================================
-- Timetable AirportOpenAir
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Mantra', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 18 ),
	('SandraRomina', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 18 ),
	('JoshYob.', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 18 ),
	('DeGuzman', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 18 ),
	('ManatArms', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 18 ),
	('Adem', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 18 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('Adem', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 18 ),
	('NEO', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 18 ),
	('MarioAngelo', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 18 ),
	('TimmSchreiner', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 18 ),
	('Mantra', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 18 ),
	('SebastianGroth', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 18 );

-- ============================================================================
-- Timetable BLACKLIST
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('FabioFarell', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 19 ),
	('NoelHoller', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 19 ),
	('BRANDON', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 19 ),
	('Avaion', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 19 ),
	('Harris&Ford', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 19 ),
	('TobyRomeo', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 19 ),
	('OliverMagenta', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 19 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('TMPR', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 19 ),
	('MAKLA', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 19 ),
	('FLOBU', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 19 ),
	('Koven', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 19 ),
	('HolyGoof', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 03:30:00', 19 ),
	('Borgore', 'Saturday', '2025-08-03 03:30:00', '2025-08-03 05:00:00', 19 ),
	('DanLee', 'Saturday', '2025-08-03 05:00:00', '2025-08-03 07:00:00', 19 );

-- ============================================================================
-- Timetable Die Rakete
-- ============================================================================

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('D,Kixx', 'Friday', '2025-08-01 20:00:00', '2025-08-01 21:00:00', 20 ),
	('Brainy', 'Friday', '2025-08-01 21:00:00', '2025-08-01 22:30:00', 20 ),
	('BernhardGroeger', 'Friday', '2025-08-01 22:30:00', '2025-08-02 00:00:00', 20 ),
	('Defex', 'Friday', '2025-08-02 00:00:00', '2025-08-02 01:30:00', 20 ),
	('Drumcomplex', 'Friday', '2025-08-02 01:30:00', '2025-08-02 03:00:00', 20 ),
	('DominikEulberg', 'Friday', '2025-08-02 03:00:00', '2025-08-02 04:30:00', 20 ),
	('CrizRock', 'Friday', '2025-08-02 04:30:00', '2025-08-02 06:00:00', 20 );

INSERT INTO timetable (name, festival_day, start_time, end_time, stage_id)
VALUES 
	('MauriScrivano', 'Saturday', '2025-08-02 18:00:00', '2025-08-02 22:00:00', 20 ),
	('Textasy', 'Saturday', '2025-08-02 22:00:00', '2025-08-02 23:30:00', 20 ),
	('MilanMilano', 'Saturday', '2025-08-02 23:30:00', '2025-08-03 01:00:00', 20 ),
	('GregorTresher', 'Saturday', '2025-08-03 01:00:00', '2025-08-03 02:30:00', 20 ),
	('TorstenKanzler', 'Saturday', '2025-08-03 02:30:00', '2025-08-03 05:00:00', 20 );

-- ============================================================================
-- Operators
-- ============================================================================

INSERT INTO operators (name, location) 
VALUES
	('natureone', 'Unknown'),
	('Dirty Workz', 'Belgium'),
	('Gayphoria Events', 'Koblenz'),
	('Hardcore Gladiators', 'Unknown'),
	('HEXENHOUSE', 'Bocholt'),
	('HeavensGate', 'Dortmund'),
	('HEX Technomovement', 'International'),
	('Masters of Hardcore', 'Netherlands'),
	('PLAY!', 'Unknown'),
	('PUNX', 'Unknown'),
	('FAZE mag', 'Wuppertal'),
	('Tunnel - Underground Rules!', 'Hamburg'),
	('V.I.B.E.Z Production', 'Bochum'),
	('Acid Wars', 'Münster'),
	('Club Airport Würzburg', 'Würzburg'),
	('Bootshaus', 'Köln'),
	('Die Rakete', 'Nürnberg');


-- ============================================================================
--3. Create Views (DDL)
-- ============================================================================
CREATE VIEW area_details AS
SELECT 
    a.area_id, a.name AS area_name, a.category AS area_category, s.stage_id, s.name AS stage_name,
    f.facility_id,f.name AS facility_name, f.type AS facility_type,
    b.booth_id, b.name AS booth_name, b.type AS booth_type
FROM areas a
LEFT JOIN stages s ON a.area_id = s.area_id
LEFT JOIN facilities f ON a.area_id = f.area_id
LEFT JOIN booths b ON a.area_id = b.area_id;

CREATE VIEW timetable_stages AS
SELECT 
    t.event_id, t.name AS event_name,t.start_time,t.end_time,t.stage_id, s.name AS stage_name,s.type AS stage_type,
    s.floor_type,s.genre AS stage_genre,s.area_id,s.operator_id
FROM timetable t
JOIN stages s ON t.stage_id = s.stage_id;

-- ============================================================================
--3. Create Indices (DDL)
-- ============================================================================
--3.1 General Indices (DDL)
-- ============================================================================
CREATE INDEX idx_stages_name ON stages(name);
CREATE INDEX idx_areas_name ON areas(name);

-- ============================================================================
--3.2 Spatial Indices (DDL)
-- ============================================================================
CREATE INDEX idx_areas_geom ON areas USING GIST(geom);
CREATE INDEX idx_stages_geom ON stages USING GIST(geom);

-- ============================================================================
--4 SQL Queries
-- ============================================================================
--4.1 Non-spatial SQL Queries
-- ============================================================================
SELECT * FROM timetable_stages;
SELECT * FROM area_details;

SELECT * FROM timetable_stages 
WHERE stage_name = 'OpenAirFloor'
ORDER BY start_time;

SELECT area_name,
       COUNT(DISTINCT facility_id) AS num_facilities,
       COUNT(DISTINCT stage_id) AS num_stages,
       COUNT(DISTINCT booth_id) AS num_booths
FROM area_details
WHERE facility_id IS NOT NULL
   OR stage_id IS NOT NULL
   OR booth_id IS NOT NULL
GROUP BY area_name
ORDER BY area_name;

-- ============================================================================
--4.2 Spatial SQL Queries
-- ============================================================================
WITH stage_location AS (
    SELECT geom FROM stages WHERE name = 'CenturyCircus')
SELECT f.name, f.type, f.geom, ST_Distance(f.geom, s.geom) AS distance
FROM facilities f, stage_location s
WHERE f.type = 'toilet'
ORDER BY distance;

-- ============================================================================
--4.2.1 User-specific queries
-- ============================================================================
INSERT INTO users (user_id, current_location, timestamp) 
VALUES ('1', ST_SetSRID(ST_MakePoint(826620.8964438796, 6453781.233965318), 3857), TIMESTAMP '2025-08-02 01:24:00');

INSERT INTO users (user_id, current_location, timestamp) 
VALUES ('2', ST_SetSRID(ST_MakePoint(826620.8964438796, 6453781.233965318), 3857), TIMESTAMP '2025-08-02 01:27:00');

--Query for user 1
WITH user_location AS (
    SELECT current_location, timestamp FROM users WHERE user_id = 1
),
event_details AS (
    SELECT 
        e.event_name, 
        e.stage_name, 
        s.geom AS stage_geom,  -- Holen der Geometrie aus stages
        ST_Distance(u.current_location, s.geom) AS distance_meters,
        e.start_time AS event_start_time,
        u.timestamp AS user_timestamp  -- Der echte Timestamp des Users
    FROM timetable_stages e
    JOIN stages s ON e.stage_id = s.stage_id  -- Geometrie aus stages hinzufügen
    CROSS JOIN user_location u  -- CROSS JOIN für Zugriff auf u.location & u.timestamp
    WHERE e.event_name = 'OGUZ'  -- Event OGUZ
)
SELECT *,
    (distance_meters / 1.4) AS estimated_travel_seconds,
    event_start_time - user_timestamp AS time_until_event,  -- Jetzt mit dem echten User-Timestamp!
    CASE 
        WHEN (distance_meters / 1.4) < EXTRACT(EPOCH FROM (event_start_time - user_timestamp))  -- Umwandlung von interval in Sekunden
        THEN '✅ User will make it'
        ELSE '❌ User will not make it'
    END AS arrival_status
FROM event_details;

--Query for user 2
WITH user_location AS (
    SELECT current_location, timestamp FROM users WHERE user_id = 2
),
event_details AS (
    SELECT 
        e.event_name, 
        e.stage_name, 
        s.geom AS stage_geom,  -- Holen der Geometrie aus stages
        ST_Distance(u.current_location, s.geom) AS distance_meters,
        e.start_time AS event_start_time,
        u.timestamp AS user_timestamp  -- Der echte Timestamp des Users
    FROM timetable_stages e
    JOIN stages s ON e.stage_id = s.stage_id  -- Geometrie aus stages hinzufügen
    CROSS JOIN user_location u  -- CROSS JOIN für Zugriff auf u.location & u.timestamp
    WHERE e.event_name = 'OGUZ'  -- Event OGUZ
)
SELECT *,
    (distance_meters / 1.4) AS estimated_travel_seconds,
    event_start_time - user_timestamp AS time_until_event,  -- Jetzt mit dem echten User-Timestamp!
    CASE 
        WHEN (distance_meters / 1.4) < EXTRACT(EPOCH FROM (event_start_time - user_timestamp))  -- Umwandlung von interval in Sekunden
        THEN '✅ User will make it'
        ELSE '❌ User will not make it'
    END AS arrival_status
FROM event_details;

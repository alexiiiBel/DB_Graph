USE master;
GO
DROP DATABASE IF EXISTS AirTravel;
GO
CREATE DATABASE AirTravel
    COLLATE Cyrillic_General_CI_AS;
GO
USE AirTravel;
GO

CREATE TABLE Airport
(
    id               INT           NOT NULL PRIMARY KEY,
    iata_code        CHAR(3)       NOT NULL UNIQUE,
    name             NVARCHAR(100) NOT NULL,
    city             NVARCHAR(50)  NOT NULL,
    country          NVARCHAR(50)  NOT NULL,
    timezone         NVARCHAR(50)  NOT NULL
) AS NODE;
GO

CREATE TABLE Airline
(
    id               INT           NOT NULL PRIMARY KEY,
    iata_code        CHAR(2)       NOT NULL UNIQUE,
    name             NVARCHAR(100) NOT NULL,
    country          NVARCHAR(50)  NOT NULL,
    founded_year     INT           NOT NULL
) AS NODE;
GO

CREATE TABLE City
(
    id               INT           NOT NULL PRIMARY KEY,
    name             NVARCHAR(50)  NOT NULL,
    country          NVARCHAR(50)  NOT NULL,
    population_thou  INT           NOT NULL 
) AS NODE;
GO

CREATE TABLE Flight
(
    flight_number    NVARCHAR(10)  NOT NULL,
    airline_id       INT           NOT NULL,
    duration_min     INT           NOT NULL,
    distance_km      INT           NOT NULL,
    price_rub        INT           NOT NULL
) AS EDGE;
GO
ALTER TABLE Flight
    ADD CONSTRAINT EC_Flight CONNECTION (Airport TO Airport);
GO

CREATE TABLE Operates
(
    since_year       INT           NOT NULL,
    is_hub           BIT           NOT NULL CONSTRAINT DF_Operates_IsHub DEFAULT 0,
    weekly_flights   INT           NOT NULL
) AS EDGE;
GO
ALTER TABLE Operates
    ADD CONSTRAINT EC_Operates CONNECTION (Airline TO Airport);
GO

CREATE TABLE LocatedIn
(
    distance_to_center_km  INT           NOT NULL,
    transport              NVARCHAR(150) NOT NULL
) AS EDGE;
GO
ALTER TABLE LocatedIn
    ADD CONSTRAINT EC_LocatedIn CONNECTION (Airport TO City);
GO

CREATE TABLE Connection
(
    min_connection_min  INT           NOT NULL,
    terminal_change     BIT           NOT NULL CONSTRAINT DF_Connection_TC DEFAULT 0,
    connection_type     NVARCHAR(30)  NOT NULL 
) AS EDGE;
GO
ALTER TABLE Connection
    ADD CONSTRAINT EC_Connection CONNECTION (Airport TO Airport);
GO

INSERT INTO Airport (id, iata_code, name, city, country, timezone)
VALUES
    (1,  'SVO', N'Шереметьево',                        N'Москва',           N'Россия',  N'Europe/Moscow'),
    (2,  'DME', N'Домодедово',                         N'Москва',           N'Россия',  N'Europe/Moscow'),
    (3,  'VKO', N'Внуково',                            N'Москва',           N'Россия',  N'Europe/Moscow'),
    (4,  'LED', N'Пулково',                            N'Санкт-Петербург',  N'Россия',  N'Europe/Moscow'),
    (5,  'AER', N'Сочи (Адлер)',                       N'Сочи',             N'Россия',  N'Europe/Moscow'),
    (6,  'KZN', N'Казань',                             N'Казань',           N'Россия',  N'Europe/Moscow'),
    (7,  'SVX', N'Кольцово',                           N'Екатеринбург',     N'Россия',  N'Asia/Yekaterinburg'),
    (8,  'OVB', N'Толмачёво',                          N'Новосибирск',      N'Россия',  N'Asia/Novosibirsk'),
    (9,  'IKT', N'Иркутск',                            N'Иркутск',          N'Россия',  N'Asia/Irkutsk'),
    (10, 'VVO', N'Кневичи (Владивосток)',              N'Владивосток',      N'Россия',  N'Asia/Vladivostok'),
    (11, 'UFA', N'Уфа',                                N'Уфа',              N'Россия',  N'Asia/Yekaterinburg'),
    (12, 'ROV', N'Платов',                             N'Ростов-на-Дону',   N'Россия',  N'Europe/Moscow');
GO

SELECT * FROM Airport;
GO

INSERT INTO Airline (id, iata_code, name, country, founded_year)
VALUES
    (1,  'SU', N'Аэрофлот',            N'Россия',   1923),
    (2,  'S7', N'S7 Airlines',         N'Россия',   1992),
    (3,  'U6', N'Уральские авиалинии', N'Россия',   1993),
    (4,  'DP', N'Победа',              N'Россия',   2014),
    (5,  'FV', N'Россия',              N'Россия',   1934),
    (6,  'N4', N'Nordwind Airlines',   N'Россия',   2008),
    (7,  'LH', N'Lufthansa',           N'Германия', 1953),
    (8,  'TK', N'Turkish Airlines',    N'Турция',   1933),
    (9,  'EK', N'Emirates',            N'ОАЭ',      1985),
    (10, 'QR', N'Qatar Airways',       N'Катар',    1993);
GO

SELECT * FROM Airline;
GO

INSERT INTO City (id, name, country, population_thou)
VALUES
    (1,  N'Москва',           N'Россия',  12700),
    (2,  N'Санкт-Петербург',  N'Россия',   5600),
    (3,  N'Сочи',             N'Россия',    440),
    (4,  N'Казань',           N'Россия',   1300),
    (5,  N'Екатеринбург',     N'Россия',   1540),
    (6,  N'Новосибирск',      N'Россия',   1640),
    (7,  N'Иркутск',          N'Россия',    660),
    (8,  N'Владивосток',      N'Россия',    610),
    (9,  N'Уфа',              N'Россия',   1170),
    (10, N'Ростов-на-Дону',   N'Россия',   1150),
    (11, N'Дубай',            N'ОАЭ',      3400);
GO

SELECT * FROM City;
GO

INSERT INTO Flight (flight_number, airline_id, duration_min, distance_km, price_rub, $from_id, $to_id)
VALUES
    ('SU0020', 1,  75,  635,  4500,
        (SELECT $node_id FROM Airport WHERE iata_code='SVO'),
        (SELECT $node_id FROM Airport WHERE iata_code='LED')),
    ('SU0024', 1,  75,  635,  4800,
        (SELECT $node_id FROM Airport WHERE iata_code='LED'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    ('SU1140', 1, 100, 1350,  6500,
        (SELECT $node_id FROM Airport WHERE iata_code='SVO'),
        (SELECT $node_id FROM Airport WHERE iata_code='KZN')),
    ('SU1260', 1, 135, 1414,  7200,
        (SELECT $node_id FROM Airport WHERE iata_code='SVO'),
        (SELECT $node_id FROM Airport WHERE iata_code='AER')),
    ('SU1472', 1, 135, 2044,  9800,
        (SELECT $node_id FROM Airport WHERE iata_code='SVO'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ('SU1520', 1, 230, 2812, 12000,
        (SELECT $node_id FROM Airport WHERE iata_code='SVO'),
        (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    ('SU1710', 1, 480, 6430, 18000,
        (SELECT $node_id FROM Airport WHERE iata_code='SVO'),
        (SELECT $node_id FROM Airport WHERE iata_code='VVO')),
    -- S7 Airlines: рейсы из DME
    ('S70011', 2, 135, 2044,  8500,
        (SELECT $node_id FROM Airport WHERE iata_code='DME'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ('S70015', 2, 230, 2812, 11000,
        (SELECT $node_id FROM Airport WHERE iata_code='DME'),
        (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    ('S70031', 2, 355, 4215, 15000,
        (SELECT $node_id FROM Airport WHERE iata_code='DME'),
        (SELECT $node_id FROM Airport WHERE iata_code='IKT')),
    ('S70061', 2, 480, 6430, 17500,
        (SELECT $node_id FROM Airport WHERE iata_code='DME'),
        (SELECT $node_id FROM Airport WHERE iata_code='VVO')),
    ('S70071', 2, 100, 1350,  7000,
        (SELECT $node_id FROM Airport WHERE iata_code='DME'),
        (SELECT $node_id FROM Airport WHERE iata_code='KZN')),
    -- Уральские авиалинии (U6): рейсы из SVX
    ('U60271', 3, 200, 1820,  9000,
        (SELECT $node_id FROM Airport WHERE iata_code='SVX'),
        (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    ('U60272', 3, 200, 1820,  9000,
        (SELECT $node_id FROM Airport WHERE iata_code='OVB'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ('U60311', 3, 120, 1100,  7500,
        (SELECT $node_id FROM Airport WHERE iata_code='SVX'),
        (SELECT $node_id FROM Airport WHERE iata_code='UFA')),
    ('U60312', 3, 120, 1100,  7500,
        (SELECT $node_id FROM Airport WHERE iata_code='UFA'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ('U60411', 3, 135, 2044,  8000,
        (SELECT $node_id FROM Airport WHERE iata_code='SVX'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    -- Победа (DP): рейсы из VKO
    ('DP0141', 4,  75,  635,  3200,
        (SELECT $node_id FROM Airport WHERE iata_code='VKO'),
        (SELECT $node_id FROM Airport WHERE iata_code='LED')),
    ('DP0142', 4,  75,  635,  3200,
        (SELECT $node_id FROM Airport WHERE iata_code='LED'),
        (SELECT $node_id FROM Airport WHERE iata_code='VKO')),
    ('DP0155', 4, 130, 1350,  4800,
        (SELECT $node_id FROM Airport WHERE iata_code='VKO'),
        (SELECT $node_id FROM Airport WHERE iata_code='KZN')),
    ('DP0198', 4, 100,  980,  4000,
        (SELECT $node_id FROM Airport WHERE iata_code='VKO'),
        (SELECT $node_id FROM Airport WHERE iata_code='ROV')),
    -- Россия (FV): рейсы из LED
    ('FV0170', 5,  75,  635,  5000,
        (SELECT $node_id FROM Airport WHERE iata_code='LED'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    ('FV0321', 5, 175, 2400, 10500,
        (SELECT $node_id FROM Airport WHERE iata_code='LED'),
        (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    -- S7: маршруты для транзита OVB -> IKT -> VVO
    ('S70250', 2, 165, 1820, 10000,
        (SELECT $node_id FROM Airport WHERE iata_code='OVB'),
        (SELECT $node_id FROM Airport WHERE iata_code='IKT')),
    ('S70255', 2, 130, 1600,  9500,
        (SELECT $node_id FROM Airport WHERE iata_code='IKT'),
        (SELECT $node_id FROM Airport WHERE iata_code='VVO'));
GO

SELECT * FROM Flight;
GO

INSERT INTO Operates (since_year, is_hub, weekly_flights, $from_id, $to_id)
VALUES
    (1956, 1, 280, (SELECT $node_id FROM Airline WHERE iata_code='SU'), (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    (2000, 0,  42, (SELECT $node_id FROM Airline WHERE iata_code='SU'), (SELECT $node_id FROM Airport WHERE iata_code='LED')),
    (2005, 0,  28, (SELECT $node_id FROM Airline WHERE iata_code='SU'), (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    (1992, 1, 175, (SELECT $node_id FROM Airline WHERE iata_code='S7'), (SELECT $node_id FROM Airport WHERE iata_code='DME')),
    (2003, 1, 120, (SELECT $node_id FROM Airline WHERE iata_code='S7'), (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    (1993, 1, 210, (SELECT $node_id FROM Airline WHERE iata_code='U6'), (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    (2014, 1, 140, (SELECT $node_id FROM Airline WHERE iata_code='DP'), (SELECT $node_id FROM Airport WHERE iata_code='VKO')),
    (1995, 0,  35, (SELECT $node_id FROM Airline WHERE iata_code='DP'), (SELECT $node_id FROM Airport WHERE iata_code='LED')),
    (1934, 1, 190, (SELECT $node_id FROM Airline WHERE iata_code='FV'), (SELECT $node_id FROM Airport WHERE iata_code='LED')),
    (2010, 0,  14, (SELECT $node_id FROM Airline WHERE iata_code='LH'), (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    (2008, 0,  21, (SELECT $node_id FROM Airline WHERE iata_code='TK'), (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    (2014, 0,  14, (SELECT $node_id FROM Airline WHERE iata_code='EK'), (SELECT $node_id FROM Airport WHERE iata_code='SVO'));
GO

SELECT * FROM Operates;
GO

INSERT INTO LocatedIn (distance_to_center_km, transport, $from_id, $to_id)
VALUES
    (29, N'Аэроэкспресс, автобус, такси',               (SELECT $node_id FROM Airport WHERE iata_code='SVO'), (SELECT $node_id FROM City WHERE name=N'Москва')),
    (22, N'Аэроэкспресс, автобус, такси',               (SELECT $node_id FROM Airport WHERE iata_code='DME'), (SELECT $node_id FROM City WHERE name=N'Москва')),
    (28, N'Аэроэкспресс, автобус, такси',               (SELECT $node_id FROM Airport WHERE iata_code='VKO'), (SELECT $node_id FROM City WHERE name=N'Москва')),
    (17, N'Метро (линия 5), автобус, такси',            (SELECT $node_id FROM Airport WHERE iata_code='LED'), (SELECT $node_id FROM City WHERE name=N'Санкт-Петербург')),
    (30, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='AER'), (SELECT $node_id FROM City WHERE name=N'Сочи')),
    (26, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='KZN'), (SELECT $node_id FROM City WHERE name=N'Казань')),
    (16, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='SVX'), (SELECT $node_id FROM City WHERE name=N'Екатеринбург')),
    (18, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='OVB'), (SELECT $node_id FROM City WHERE name=N'Новосибирск')),
    ( 7, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='IKT'), (SELECT $node_id FROM City WHERE name=N'Иркутск')),
    (44, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='VVO'), (SELECT $node_id FROM City WHERE name=N'Владивосток')),
    (30, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='UFA'), (SELECT $node_id FROM City WHERE name=N'Уфа')),
    (30, N'Автобус, такси',                              (SELECT $node_id FROM Airport WHERE iata_code='ROV'), (SELECT $node_id FROM City WHERE name=N'Ростов-на-Дону'));
GO

SELECT * FROM LocatedIn;
GO

INSERT INTO Connection (min_connection_min, terminal_change, connection_type, $from_id, $to_id)
VALUES
    ( 60, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='SVO'), (SELECT $node_id FROM Airport WHERE iata_code='LED')),
    ( 60, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='SVO'), (SELECT $node_id FROM Airport WHERE iata_code='KZN')),
    ( 60, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='SVO'), (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ( 90, 1, N'international', (SELECT $node_id FROM Airport WHERE iata_code='SVO'), (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    ( 90, 1, N'international', (SELECT $node_id FROM Airport WHERE iata_code='SVO'), (SELECT $node_id FROM Airport WHERE iata_code='VVO')),
    ( 60, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='DME'), (SELECT $node_id FROM Airport WHERE iata_code='KZN')),
    ( 75, 1, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='DME'), (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ( 90, 1, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='DME'), (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    ( 45, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='OVB'), (SELECT $node_id FROM Airport WHERE iata_code='IKT')),
    ( 45, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='OVB'), (SELECT $node_id FROM Airport WHERE iata_code='VVO')),
    ( 50, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='SVX'), (SELECT $node_id FROM Airport WHERE iata_code='OVB')),
    ( 60, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='SVX'), (SELECT $node_id FROM Airport WHERE iata_code='UFA')),
    ( 60, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='LED'), (SELECT $node_id FROM Airport WHERE iata_code='SVO')),
    ( 75, 1, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='LED'), (SELECT $node_id FROM Airport WHERE iata_code='SVX')),
    ( 40, 0, N'domestic',      (SELECT $node_id FROM Airport WHERE iata_code='IKT'), (SELECT $node_id FROM Airport WHERE iata_code='VVO'));
GO

SELECT * FROM Connection;
GO

PRINT N'=== Запрос 1. Прямые рейсы из Шереметьево (SVO) ===';

SELECT
    a1.iata_code        AS [Откуда],
    a1.city             AS [Город отправления],
    f.flight_number     AS [Номер рейса],
    f.duration_min      AS [Длит. (мин)],
    f.distance_km       AS [Расстояние (км)],
    f.price_rub         AS [Цена (руб)],
    a2.iata_code        AS [Куда],
    a2.city             AS [Город назначения]
FROM Airport AS a1
   , Flight AS f
   , Airport AS a2
WHERE MATCH(a1-(f)->a2)
  AND a1.iata_code = 'SVO'
ORDER BY f.duration_min;
GO

PRINT N'=== Запрос 2. Авиакомпании в аэропортах Москвы ===';

SELECT
    al.name             AS [Авиакомпания],
    al.country          AS [Страна],
    o.since_year        AS [Год начала],
    o.weekly_flights    AS [Рейсов/нед.],
    IIF(o.is_hub=1, N'Да', N'Нет') AS [Хаб],
    ap.iata_code        AS [Код аэропорта],
    ap.name             AS [Аэропорт],
    c.name              AS [Город]
FROM Airline AS al
   , Operates AS o
   , Airport AS ap
   , LocatedIn AS li
   , City AS c
WHERE MATCH(al-(o)->ap-(li)->c)
  AND c.name = N'Москва'
ORDER BY al.name;
GO

PRINT N'=== Запрос 3. Маршруты с пересадкой до Владивостока ===';

SELECT
    a1.iata_code        AS [Откуда],
    a1.city             AS [Город отправления],
    f1.flight_number    AS [Рейс 1],
    a2.iata_code        AS [Транзит],
    a2.city             AS [Транзитный город],
    f2.flight_number    AS [Рейс 2],
    a3.iata_code        AS [Куда],
    a3.city             AS [Город прибытия],
    (f1.duration_min + f2.duration_min) AS [Суммарное время (мин)],
    (f1.price_rub      + f2.price_rub)  AS [Суммарная цена (руб)]
FROM Airport AS a1
   , Flight  AS f1
   , Airport AS a2
   , Flight  AS f2
   , Airport AS a3
WHERE MATCH(a1-(f1)->a2-(f2)->a3)
  AND a3.iata_code = 'VVO'
  AND a1.iata_code <> 'VVO'
ORDER BY (f1.duration_min + f2.duration_min);
GO

PRINT N'=== Запрос 4. Рейсы Аэрофлота из хабов ===';

SELECT
    al.name             AS [Авиакомпания],
    ap1.iata_code       AS [Хаб],
    ap1.city            AS [Город хаба],
    f.flight_number     AS [Рейс],
    f.duration_min      AS [Длит. (мин)],
    f.price_rub         AS [Цена (руб)],
    ap2.iata_code       AS [Назначение],
    ap2.city            AS [Город назначения]
FROM Airline  AS al
   , Operates AS o
   , Airport  AS ap1
   , Flight   AS f
   , Airport  AS ap2
WHERE MATCH(al-(o)->ap1-(f)->ap2)
  AND al.iata_code = 'SU'
  AND o.is_hub = 1
ORDER BY ap2.city;
GO

PRINT N'=== Запрос 5. Стыковки без смены терминала ===';

SELECT
    c.name              AS [Город хаба],
    ap1.iata_code       AS [Аэропорт-хаб],
    cn.min_connection_min AS [Мин. стыковка (мин)],
    IIF(cn.terminal_change=1, N'Да', N'Нет') AS [Смена терминала],
    cn.connection_type  AS [Тип стыковки],
    ap2.iata_code       AS [Следующий аэропорт],
    ap2.city            AS [Следующий город]
FROM City       AS c
   , LocatedIn  AS li
   , Airport    AS ap1
   , Connection AS cn
   , Airport    AS ap2
WHERE MATCH(c<-(li)-ap1-(cn)->ap2)
  AND cn.terminal_change = 0
ORDER BY c.name, cn.min_connection_min;
GO

PRINT N'=== Запрос 6. Трёхсегментные маршруты через Новосибирск ===';

SELECT
    a1.iata_code        AS [Откуда],
    f1.flight_number    AS [Рейс 1],
    a2.iata_code        AS [Транзит 1],
    f2.flight_number    AS [Рейс 2],
    a3.iata_code        AS [Транзит 2 (OVB)],
    f3.flight_number    AS [Рейс 3],
    a4.iata_code        AS [Куда],
    a4.city             AS [Город прибытия],
    (f1.duration_min + f2.duration_min + f3.duration_min) AS [Общее время (мин)]
FROM Airport AS a1
   , Flight  AS f1
   , Airport AS a2
   , Flight  AS f2
   , Airport AS a3
   , Flight  AS f3
   , Airport AS a4
WHERE MATCH(a1-(f1)->a2-(f2)->a3-(f3)->a4)
  AND a3.iata_code = 'OVB'
  AND a1.iata_code <> a4.iata_code
ORDER BY (f1.duration_min + f2.duration_min + f3.duration_min);
GO

PRINT N'=== Запрос 7. Кратчайшие маршруты из Пулково (LED), шаблон "+" ===';

SELECT
    a1.iata_code  AS [Откуда],
    a1.city       AS [Город отправления],
    STRING_AGG(a2.iata_code, '->') WITHIN GROUP (GRAPH PATH) AS [Маршрут (коды)],
    STRING_AGG(a2.city, ' -> ')    WITHIN GROUP (GRAPH PATH) AS [Маршрут (города)],
    LAST_VALUE(a2.iata_code)       WITHIN GROUP (GRAPH PATH) AS [Конечный аэропорт],
    COUNT(f.*)                     WITHIN GROUP (GRAPH PATH) AS [Количество рейсов]
FROM Airport AS a1
   , Flight FOR PATH AS f
   , Airport FOR PATH AS a2
WHERE MATCH(SHORTEST_PATH(a1(-(f)->a2)+))
  AND a1.iata_code = 'LED'
ORDER BY COUNT(f.*) WITHIN GROUP (GRAPH PATH);
GO

PRINT N'=== Запрос 8. Кратчайший маршрут Уфа (UFA) → Владивосток (VVO) ===';

DECLARE @From CHAR(3) = 'UFA';
DECLARE @To   CHAR(3) = 'VVO';

WITH ShortestRoutes AS
(
    SELECT
        a1.iata_code    AS StartCode,
        a1.city         AS StartCity,
        STRING_AGG(a2.iata_code, '->')  WITHIN GROUP (GRAPH PATH) AS Route,
        STRING_AGG(a2.city, ' -> ')     WITHIN GROUP (GRAPH PATH) AS Cities,
        LAST_VALUE(a2.iata_code)        WITHIN GROUP (GRAPH PATH) AS LastNode,
        COUNT(f.*)                      WITHIN GROUP (GRAPH PATH) AS Hops
    FROM Airport AS a1
       , Flight FOR PATH AS f
       , Airport FOR PATH AS a2
    WHERE MATCH(SHORTEST_PATH(a1(-(f)->a2)+))
      AND a1.iata_code = @From
)
SELECT
    StartCode                       AS [Откуда],
    StartCode + '->' + Route        AS [Полный маршрут],
    StartCity + ' -> ' + Cities     AS [Города по маршруту],
    Hops                            AS [Количество рейсов]
FROM ShortestRoutes
WHERE LastNode = @To;
GO

PRINT N'=== Запрос 9. Маршруты из Шереметьево не более 3 рейсов, шаблон "{1,3}" ===';

SELECT
    a1.iata_code    AS [Откуда],
    a1.city         AS [Город отправления],
    STRING_AGG(a2.iata_code, '->') WITHIN GROUP (GRAPH PATH) AS [Маршрут],
    STRING_AGG(a2.city, ' -> ')    WITHIN GROUP (GRAPH PATH) AS [Города маршрута],
    LAST_VALUE(a2.iata_code)       WITHIN GROUP (GRAPH PATH) AS [Конечный аэропорт],
    LAST_VALUE(a2.city)            WITHIN GROUP (GRAPH PATH) AS [Конечный город],
    COUNT(f.*)                     WITHIN GROUP (GRAPH PATH) AS [Количество рейсов]
FROM Airport AS a1
   , Flight FOR PATH AS f
   , Airport FOR PATH AS a2
WHERE MATCH(SHORTEST_PATH(a1(-(f)->a2){1,3}))
  AND a1.iata_code = 'SVO'
ORDER BY COUNT(f.*) WITHIN GROUP (GRAPH PATH);
GO

PRINT N'=== Запрос 10. Достижимые аэропорты из Ростова (ROV) за 1-2 рейса ===';

SELECT
    a1.iata_code    AS [Откуда],
    STRING_AGG(a2.iata_code, '->') WITHIN GROUP (GRAPH PATH) AS [Маршрут],
    LAST_VALUE(a2.city)            WITHIN GROUP (GRAPH PATH) AS [Конечный город],
    COUNT(f.*)                     WITHIN GROUP (GRAPH PATH) AS [Рейсов]
FROM Airport AS a1
   , Flight FOR PATH AS f
   , Airport FOR PATH AS a2
WHERE MATCH(SHORTEST_PATH(a1(-(f)->a2){1,2}))
  AND a1.iata_code = 'ROV'
ORDER BY COUNT(f.*) WITHIN GROUP (GRAPH PATH);
GO

SELECT
    a1.id           AS IdFirst,
    a1.iata_code    AS First,
    CONCAT(N'Airport', a1.id) AS [First image name],
    a2.id           AS IdSecond,
    a2.iata_code    AS Second,
    CONCAT(N'Airport', a2.id) AS [Second image name],
    f.price_rub     AS Weight
FROM Airport AS a1
   , Flight  AS f
   , Airport AS a2
WHERE MATCH(a1-(f)->a2);
GO

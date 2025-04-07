-- ******************* Tables temporaires pour l'import CSV **************************
CREATE TABLE temp_passengers (first_name TEXT, last_name TEXT, age INTEGER);
CREATE TABLE temp_airlines (name TEXT, concourse TEXT);
CREATE TABLE temp_flights (
    flight_number INTEGER,
    airline TEXT,
    departure_airport TEXT,
    arrival_airport TEXT,
    departure_datetime DATETIME,
    arrival_datetime DATETIME
);
CREATE TABLE temp_check_ins (
    passengers_first_name TEXT,
    passengers_last_name TEXT,
    flight_number INTEGER,
    checkin_datetime DATETIME
);
-- *************************** Tables finales avec contraintes *****************************
CREATE TABLE passengers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER NOT NULL
);
CREATE TABLE airlines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    concourse TEXT NOT NULL
);
CREATE TABLE flights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    flight_number INTEGER NOT NULL,
    airline_id INTEGER NOT NULL,
    departure_airport TEXT NOT NULL,
    arrival_airport TEXT NOT NULL,
    departure_datetime DATETIME NOT NULL,
    arrival_datetime DATETIME NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airlines(id)
);
CREATE TABLE check_ins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    passenger_id INTEGER NOT NULL,
    flight_id INTEGER NOT NULL,
    checkin_datetime DATETIME NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES passengers(id),
    FOREIGN KEY (flight_id) REFERENCES flights(id)
);
-- *************** Importons le CSV dans les tables temporaires***************
.import --csv passengers.csv temp_passengers
.import --csv airlines.csv temp_airlines
.import --csv flights.csv temp_flights
.import --csv check_ins.csv temp_check_ins
--
-- ***************** Transfert vers les tables finales *****************************
--
-- Compagnies aériennes
INSERT INTO airlines (name, concourse)
SELECT DISTINCT name,
    concourse
FROM temp_airlines;
-- Passagers
INSERT INTO passengers (first_name, last_name, age)
SELECT first_name,
    last_name,
    age
FROM temp_passengers;
-- Vols (version simplifiée sans alias)
INSERT INTO flights (
        flight_number,
        airline_id,
        departure_airport,
        arrival_airport,
        departure_datetime,
        arrival_datetime
    )
SELECT temp_flights.flight_number,
    airlines.id,
    temp_flights.departure_airport,
    temp_flights.arrival_airport,
    temp_flights.departure_datetime,
    temp_flights.arrival_datetime
FROM temp_flights
    JOIN airlines ON temp_flights.airline = airlines.name;
-- Enregistrements (version simplifiée sans alias)
INSERT INTO check_ins (
        passenger_id,
        flight_id,
        checkin_datetime
    )
SELECT passengers.id,
    flights.id,
    temp_check_ins.checkin_datetime
FROM temp_check_ins
    JOIN passengers ON temp_check_ins.passengers_first_name = passengers.first_name
    AND temp_check_ins.passengers_last_name = passengers.last_name
    JOIN flights ON temp_check_ins.flight_number = flights.flight_number;
-- Nettoyage
DROP TABLE temp_passengers;
DROP TABLE temp_airlines;
DROP TABLE temp_flights;
DROP TABLE temp_check_ins;

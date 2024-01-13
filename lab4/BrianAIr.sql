-- Active: 1702038603655@@mariadb.edu.liu.se@3306@matka448
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS contact CASCADE;
DROP TABLE IF EXISTS airport CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS update_price CASCADE;
DROP TABLE IF EXISTS flight CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS year CASCADE;
DROP TABLE IF EXISTS weekly_schedule CASCADE;
DROP TABLE IF EXISTS credit_card CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS day CASCADE;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE airport (
    code VARCHAR(3),
    name VARCHAR(30),
    country VARCHAR(30),

    CONSTRAINT pk_airport
         PRIMARY KEY (code)
);

CREATE TABLE route (
    id INT AUTO_INCREMENT,
    to_airport VARCHAR(3),
    from_airport VARCHAR(3),

    CONSTRAINT pk_route
        PRIMARY KEY (id),
    CONSTRAINT fk_to_airport
        FOREIGN KEY (to_airport) REFERENCES airport(code) ON DELETE CASCADE,
    CONSTRAINT fk_from_airport
        FOREIGN KEY (from_airport) REFERENCES airport(code) ON DELETE CASCADE
);

CREATE TABLE weekly_schedule (
    id INT AUTO_INCREMENT,
    day_of_week VARCHAR(10),
    departue TIME,
    route_id INT,
    year_nr INT,

    CONSTRAINT pk_weekly_schedule
        PRIMARY KEY (id),
    CONSTRAINT fk_day_schedule
        FOREIGN KEY (day_of_week) REFERENCES day(weekday) ON DELETE CASCADE,
    CONSTRAINT fk_route_schedule
        FOREIGN KEY (route_id) REFERENCES route(id) ON DELETE CASCADE,
    CONSTRAINT fk_year_schedule
        FOREIGN KEY (year_nr) REFERENCES year(nr) ON DELETE CASCADE
);

CREATE TABLE year (
    nr INT,
    factor DOUBLE,

    CONSTRAINT pk_year
        PRIMARY KEY (nr)
);

CREATE TABLE day (
    weekday VARCHAR(10),
    year_nr INT,
    factor DOUBLE,

    CONSTRAINT pk_day
        PRIMARY KEY (weekday),
    CONSTRAINT fk_year_day
        FOREIGN KEY (year_nr) REFERENCES year(nr) ON DELETE CASCADE
);

CREATE TABLE update_price (
    route_id INT,
    year INT,
    route_price DOUBLE,

    CONSTRAINT pk_update_price
        PRIMARY KEY (route_id, year),
    CONSTRAINT fk_route_update
        FOREIGN KEY (route_id) REFERENCES route(id) ON DELETE CASCADE,
    CONSTRAINT fk_year_update
        FOREIGN KEY (year) REFERENCES year(nr) ON DELETE CASCADE
);

CREATE TABLE flight (
    id INT AUTO_INCREMENT,
    weekly_flight INT,
    week INT,

    CONSTRAINT pk_flight
        PRIMARY KEY (id),
    CONSTRAINT fk_weekly_schedule_flight
        FOREIGN KEY (weekly_flight) REFERENCES weekly_schedule(id) ON DELETE CASCADE
);

CREATE TABLE reservation (
    id INT AUTO_INCREMENT,
    flight_nr INT,
    passenger INT,
    seat_amount INT,

    CONSTRAINT pk_reservation
        PRIMARY KEY (id),
    CONSTRAINT fk_flight_reservation
        FOREIGN KEY (flight_nr) REFERENCES flight(id) ON DELETE CASCADE,
    CONSTRAINT fk_passenger_reservation
        FOREIGN KEY (passenger) REFERENCES passenger(passport_nr) ON DELETE CASCADE
);

CREATE TABLE passenger (
    passport_nr INT,
    name VARCHAR(30),

    CONSTRAINT pk_passenger
        PRIMARY KEY (passport_nr)
);

CREATE TABLE ticket (
    reservation_id INT,
    passenger INT,
    ticket_nr INT,

    CONSTRAINT pk_ticket
        PRIMARY KEY (reservation_id, passenger),
    CONSTRAINT fk_reservation_ticket
        FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE,
    CONSTRAINT fk_passenger_ticket
        FOREIGN KEY (passenger) REFERENCES passenger(passport_nr) ON DELETE CASCADE
);

CREATE TABLE booking (
    reservation_id INT,
    payment_method BIGINT,
    price INT,

    CONSTRAINT pk_booking
        PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_booking
        FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE,
    CONSTRAINT fk_credit_card_booking
        FOREIGN KEY (payment_method) REFERENCES credit_card(card_nr) ON DELETE CASCADE
);

CREATE TABLE contact (
    email VARCHAR(30),
    phone_nr BIGINT,
    passenger INT,
    reservation_id INT,

    CONSTRAINT pk_contact
        PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_contact
        FOREIGN KEY (passenger) REFERENCES passenger(passport_nr) ON DELETE CASCADE,
    CONSTRAINT fk_passenger_contact
        FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE
);

CREATE TABLE credit_card (
    card_nr BIGINT,
    name VARCHAR(64),

    CONSTRAINT pk_credit_card
        PRIMARY KEY (card_nr)
);

DROP PROCEDURE IF EXISTS addYear;

DELIMITER //
CREATE PROCEDURE addYear(IN year INT, IN factor DOUBLE)
BEGIN
    INSERT INTO year(nr, factor) VALUES (year, factor);
END 
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addDay(IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
    INSERT INTO day(weekday, year_nr, factor) VALUES (day, year, factor);
END
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addDestination(IN code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
    INSERT INTO day(code, name, country) VALUES (code, name, country);
END
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addRoute(IN departure_code VARCHAR(3), IN arrival_code VARCHAR(3), IN year INT, IN route_price DOUBLE)
BEGIN
    DECLARE id INT;
    INSERT INTO route(to_airport, from_airport) VALUES (arrival_code, departure_code);
    SET id = LAST_INSERT_ID();
    INSERT INTO update_price(route_id, year, route_price) VALUES (id, year, route_price);
END
// DELIMITER;

DROP PROCEDURE addFlight;
DELIMITER //
CREATE PROCEDURE addFlight(IN departure_code VARCHAR(3), IN arrival_code VARCHAR(3), IN year INT, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
    DECLARE weekly_schedule_id INT;
    /*DECLARE route_id INT;*/
    DECLARE week INT DEFAULT 1;
    /*SET selected_route_id = SELECT id FROM route WHERE from_airport = departure_code AND to_airport = arrival_code;*/
    SELECT id AS route_id FROM route WHERE from_airport = departure_code AND to_airport = arrival_code;
    INSERT INTO weekly_schedule(day_of_week, departue, route_id, year_nr) VALUES (day, departure_time, route_id, year);
    SET weekly_schedule_id = LAST_INSERT_ID();
    WHILE week <= 1 DO
        INSERT INTO flight(weekly_flight, week) VALUES (weekly_schedule_id, week);
        SET week = week + 1;
    END WHILE;
END
// DELIMITER;

DELIMITER //
/*40 seats per plane*/
CREATE FUNCTION calculateFreeSeats(flightnumber INT) RETURNS INT
BEGIN
    DECLARE free_seats INT DEFAULT 40;
    DECLARE booked INT;
    SELECT sum(seat_amount) INTO booked FROM reservation WHERE flight_nr = flightnumber;

    IF booked is NULL THEN
        RETURN free_seats;
    END IF;

    SET free_seats = free_seats-booked;
    RETURN free_seats;
END
// DELIMITER;

DELIMITER //
CREATE FUNCTION calculatePrice(flightnumber INT) RETURNS DOUBLE
BEGIN

DECLARE route_price DOUBLE;
DECLARE weekday_factor DOUBLE;
DECLARE booked_passengers INT;
DECLARE profit_factor DOUBLE;
DECLARE booking_price DOUBLE;

DECLARE weeklyschedule_id INT;
DECLARE route_id INT;
DECLARE flight_weekday VARCHAR(10);
DECLARE flight_year INT;

SELECT weekly_flight INTO weeklyschedule_id FROM flight WHERE id = flightnumber;
SELECT weekly_schedule.route_id INTO route_id FROM weekly_schedule WHERE id = weeklyschedule_id;
SELECT update_price.route_price INTO route_price FROM update_price WHERE update_price.route_id = route_id; 

SELECT day_of_week, year_nr INTO flight_weekday, flight_year FROM weekly_schedule WHERE id = weeklyschedule_id;
SELECT factor INTO weekday_factor FROM day WHERE weekday = flight_weekday AND year_nr = flight_year;
SELECT factor INTO profit_factor FROM year WHERE nr = flight_year;
SET booked_passengers = 40 - calculateFreeSeats(flightnumber);

SET booking_price = route_price * weekday_factor * (booked_passengers + 1)/40 * profit_factor;
RETURN booking_price;

END
// DELIMITER;

DELIMITER //
CREATE TRIGGER gen_ticket_nr BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN

DECLARE ticket_nr INT;
SET ticket_nr = RAND()*((999999999-100000000)+100000000);
INSERT INTO ticket(reservation_id, passenger, ticket_nr) VALUES (NEW.reservation_id, NEW.passenger, ticket_nr);
END

// DELIMITER;

DELIMITER //
CREATE PROCEDURE addReservation(
    IN departure_airport VARCHAR(3),
    IN arrival_airport VARCHAR(3),
    IN year INT,
    IN week INT,
    IN day VARCHAR(10),
    IN time_dep TIME,
    IN number_of_passengers INT,
    OUT output_reservation_nr INT
    )
BEGIN
DECLARE reservation_flight INT;
DECLARE week_schedule INT;
DECLARE id_route INT;
DECLARE free_seats INT;

SELECT id into id_route FROM route WHERE to_airport = arrival_airport AND from_airport = departure_airport;
SELECT id into week_schedule FROM weekly_schedule WHERE 
day_of_week = day   AND
year_nr = year      AND
departue = time_dep AND
route_id = id_route;

SELECT id INTO reservation_flight FROM flight WHERE weekly_flight = week_schedule AND flight.week = week;
SET free_seats = calculateFreeSeats(reservation_flight);

IF free_seats-number_of_passengers >= 0 THEN SET output_reservation_nr = NULL;
ELSE SET output_reservation_nr = RAND()*((999999999-100000000)+100000000);
END IF;

INSERT INTO reservation(id, flight_nr, seat_amount) VALUES (output_reservation_nr, reservation_flight, 0);
END
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addPassenger(
    IN reservation_nr INT,
    IN passport INT,
    IN name VARCHAR(30)
)
BEGIN
INSERT INTO passenger(passport_nr, passenger.name) VALUES (passport, name);
UPDATE reservation SET passenger = passport WHERE id = reservation_nr;
END
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addContact(
    IN reservation_nr INT,
    IN passport INT,
    IN email VARCHAR(30),
    IN phone BIGINT
)
BEGIN
DECLARE person_in_reser INT DEFAULT 0;
SELECT passenger INTO person_in_reser FROM reservation WHERE id = reservation_nr AND passenger = passport;
IF person_in_reser = 0 THEN SELECT "Passenger has no reservation" AS "Message";
ELSE INSERT INTO contact(contact.email, phone_nr, passenger, reservation_id) VALUES (email, phone, passport, reservation_nr);
END IF;
END
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addPayment(
    IN reservation_nr INT,
    IN cardholder_name VARCHAR(64),
    IN creditcard_nr BIGINT
)
BEGIN
DECLARE price INT;
DECLARE contact_person INT;
DECLARE flight INT;
DECLARE seats INT;

SELECT passenger INTO contact_person FROM contact WHERE reservation_id = reservation_nr;
IF contact_person IS NULL THEN SELECT "Reservation has no contact" AS "Message";
ELSE
SELECT flight_nr, seat_amount INTO flight, seats FROM reservation WHERE id = reservation_nr;
IF calculateFreeSeats(flight) < seats THEN SELECT "Not enough free seats" AS "Message";
ELSE SET price = seats * calculatePrice(flight);
INSERT INTO credit_card VALUES (creditcard_nr, cardholder_name);
INSERT INTO booking VALUES (reservation_nr, creditcard_nr, price);
END IF;
END IF;
END
// DELIMITER;

DROP VIEW IF EXISTS allFlights;
CREATE VIEW allFlights AS
(
    SELECT
    (SELECT name FROM airport WHERE code = (SELECT to_airport FROM route WHERE route.id = route_id)) AS destination_city_name,
    (SELECT name FROM airport WHERE code = (SELECT from_airport FROM route WHERE route.id = route_id)) AS departure_city_name,    
    day_of_week AS departure_day,
    week AS departure_week,
    year_nr AS departure_year,
    calculateFreeSeats(flight.id) AS nr_of_free_seats,
    calculatePrice(flight.id) AS current_price_per_seat
    FROM flight INNER JOIN weekly_schedule ON flight.weekly_flight = weekly_schedule.id
);
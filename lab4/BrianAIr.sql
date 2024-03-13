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
    id INT,
    flight_nr INT,
    seat_amount INT,

    CONSTRAINT pk_reservation
        PRIMARY KEY (id),
    CONSTRAINT fk_flight_reservation
        FOREIGN KEY (flight_nr) REFERENCES flight(id) ON DELETE CASCADE
);

CREATE TABLE passenger (
    passport_nr INT,
    name VARCHAR(30),
    reservation_id INT,

    CONSTRAINT pk_passenger
        PRIMARY KEY (passport_nr),
    CONSTRAINT fk_reservation
        FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE
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

CREATE TABLE credit_card (
    card_nr BIGINT,
    name VARCHAR(64),

    CONSTRAINT pk_credit_card
        PRIMARY KEY (card_nr)
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
    INSERT INTO airport(airport.code, airport.name, airport.country) VALUES (code, name, country);
END
// DELIMITER;

DELIMITER //
CREATE PROCEDURE addRoute(IN departure_code VARCHAR(3), IN arrival_code VARCHAR(3), IN year_ INT, IN route_price_ DOUBLE)
BEGIN
DECLARE id_route INT;
    DECLARE route_exist INT DEFAULT NULL;
    SELECT id INTO route_exist FROM route WHERE from_airport = departure_code AND to_airport = arrival_code;
    IF route_exist IS NULL THEN INSERT INTO route(to_airport, from_airport) VALUES (arrival_code, departure_code);
    SET id_route = LAST_INSERT_ID();
    ELSE SET id_route = route_exist;
    END IF;
    INSERT INTO update_price(route_id, year, route_price) VALUES (id_route, year_, route_price_);
END
// DELIMITER;

DROP PROCEDURE addFlight;
DELIMITER //
CREATE PROCEDURE addFlight(IN departure_code varchar(3), IN arrival_code varchar(3), IN year_number int, IN day_name varchar(10), IN departure_time time)
    BEGIN
    DECLARE weekly_schedule_id INT;
    DECLARE route_id_ INT;
    DECLARE week_nr INT DEFAULT 1;
    /*SET selected_route_id = SELECT id FROM route WHERE from_airport = departure_code AND to_airport = arrival_code;*/
    SELECT id INTO route_id_ FROM route WHERE from_airport = departure_code AND to_airport = arrival_code;
    INSERT INTO weekly_schedule(day_of_week, departue, route_id, year_nr) VALUES (day_name, departure_time, route_id_, year_number);
    SET weekly_schedule_id = LAST_INSERT_ID();
    WHILE week_nr <= 52 DO
        INSERT INTO flight(weekly_flight, week) VALUES (weekly_schedule_id, week_nr);
        SET week_nr = week_nr + 1;
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

DECLARE route_price_ DOUBLE;
DECLARE weekday_factor DOUBLE;
DECLARE booked_passengers INT;
DECLARE profit_factor DOUBLE;
DECLARE booking_price DOUBLE;
DECLARE weeklyschedule_id INT;
DECLARE route_id_ INT;
DECLARE flight_weekday VARCHAR(10);
DECLARE flight_year INT;

SELECT weekly_flight INTO weeklyschedule_id FROM flight WHERE id = flightnumber;
SELECT route_id INTO route_id_ FROM weekly_schedule WHERE id = weeklyschedule_id;
SELECT day_of_week, year_nr INTO flight_weekday, flight_year FROM weekly_schedule WHERE id = weeklyschedule_id;
SELECT route_price INTO route_price_ FROM update_price WHERE route_id = route_id_ AND year = flight_year;
SELECT factor INTO weekday_factor FROM day WHERE weekday = flight_weekday AND year_nr = flight_year;
SELECT factor INTO profit_factor FROM year WHERE nr = flight_year;

SET booked_passengers = 40 - calculateFreeSeats(flightnumber);
SET booking_price = route_price_ * weekday_factor * (booked_passengers + 1)/40 * profit_factor;
SET booking_price = ROUND(booking_price, 3);

RETURN booking_price;

END
// DELIMITER;

DROP TRIGGER  gen_ticket_nr;
DELIMITER //
CREATE TRIGGER gen_ticket_nr BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN

DECLARE ticket_n INT;
SET ticket_n = RAND()*((999999999-100000000)+100000000);
/*INSERT INTO ticket(reservation_id, passenger, ticket_nr) VALUES (NEW.reservation_id, NEW.passenger, ticket_nr);*/
SET NEW.ticket_nr = ticket_n;
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
IF free_seats-number_of_passengers <= 0 THEN SET output_reservation_nr = NULL;
ELSE SET output_reservation_nr = RAND()*((999999999-100000000)+100000000);
END IF;
IF output_reservation_nr IS NULL THEN SELECT "Not enough seats" AS "Message";
ELSE
    IF reservation_flight IS NULL THEN SELECT "No such flight" AS "Message";
    ELSE INSERT INTO reservation(id, flight_nr, seat_amount) VALUES (output_reservation_nr, reservation_flight, number_of_passengers);
END IF;
END IF;
END;

// DELIMITER;

DELIMITER //
CREATE PROCEDURE addPassenger(
    IN reservation_nr INT,
    IN passport INT,
    IN name_ VARCHAR(30)
)
BEGIN
DECLARE passenger_exist INT DEFAULT NULL;
DECLARE reservation_exist INT DEFAULT NULL;
DECLARE payed INT DEFAULT NULL;
DECLARE p_has_reserv INT DEFAULT NULL;

SELECT passport_nr INTO passenger_exist FROM passenger WHERE passport_nr = passport;
IF passenger_exist IS NULL THEN
    INSERT INTO passenger(passport_nr, passenger.name) VALUES (passport, name_);
END IF;
SELECT id INTO reservation_exist FROM reservation WHERE reservation_nr = id;
IF reservation_exist IS NULL THEN
    SELECT "No such reservation" AS "Message";
ELSE
SELECT reservation_id INTO payed FROM booking WHERE reservation_id = reservation_nr;
IF payed IS NOT NULL THEN
    SELECT "Booking already payed" AS "Message";
ELSE
SELECT passenger.reservation_id INTO p_has_reserv from passenger WHERE passport_nr = passport;
IF p_has_reserv IS NOT NULL THEN
    SELECT "Passenger aleady has reservation" AS "Message";

ELSE
 UPDATE passenger SET reservation_id = reservation_nr WHERE passport_nr = passport;
 UPDATE reservation SET seat_amount = seat_amount+1 WHERE id = reservation_nr;

END IF;
end if;
END IF;
END;

// DELIMITER;

DELIMITER //
CREATE PROCEDURE addContact(
    IN reservation_nr INT,
    IN passport INT,
    IN email_ VARCHAR(30),
    IN phone BIGINT
)
BEGIN
DECLARE p INT DEFAULT NULL;
SELECT passport_nr INTO p FROM passenger WHERE reservation_id = reservation_nr AND passport_nr = passport;
IF p IS NULL THEN SELECT "Passenger has no reservation" AS "Message";
ELSE INSERT INTO contact(contact.email, contact.phone_nr, contact.passenger, contact.reservation_id) VALUES (email_, phone, passport, reservation_nr);
END IF;
END;
// DELIMITER;

DELIMITER //
BEGIN
DECLARE price_ INT;
DECLARE contact_person INT;
DECLARE flight INT;
DECLARE seats INT;
SELECT passenger INTO contact_person FROM contact WHERE reservation_id = reservation_nr;
IF contact_person IS NULL THEN SELECT "Reservation has no contact" AS "Message";
ELSE
SELECT flight_nr, seat_amount INTO flight, seats FROM reservation WHERE id = reservation_nr;
IF calculateFreeSeats(flight) < seats THEN SELECT "Not enough free seats" AS "Message";
DELETE FROM reservation WHERE id = reservation_nr;
ELSE SET price_ = seats * calculatePrice(flight);
INSERT INTO credit_card(card_nr, name) VALUES (creditcard_nr, cardholder_name);
INSERT INTO booking(reservation_id, payment_method, price) VALUES (reservation_nr, creditcard_nr, price_);
INSERT INTO ticket(reservation_id, passenger) VALUES (reservation_nr, contact_person);
END IF;
END IF;
END;
// DELIMITER;

DROP VIEW IF EXISTS allFlights;
CREATE VIEW allFlights AS
(
    SELECT
    (SELECT name FROM airport WHERE code = (SELECT to_airport FROM route WHERE route.id = route_id)) AS destination_city_name,
    (SELECT name FROM airport WHERE code = (SELECT from_airport FROM route WHERE route.id = route_id)) AS departure_city_name,
    departue AS departure_time,
    day_of_week AS departure_day,
    week AS departure_week,
    year_nr AS departure_year,
    calculateFreeSeats(flight.id) AS nr_of_free_seats,
    calculatePrice(flight.id) AS current_price_per_seat
    FROM flight INNER JOIN weekly_schedule ON flight.weekly_flight = weekly_schedule.id
);

/*
Question 8 a:
A simple way to protect the credit card number would be to encrypt it

8 b:
1. It makes it a lot simpler to update the database since the procedure dependencies are locally stored on the database itself.
2. Locally stored procedures can improve efficiency when querying the database since validation can be done beforehand.
3. It is a good practice to have seperation between the client and the database because then the client does not need to know the
structure of the database.

Question 9b:
For as long as transaction A isn't commited the reservation doesnt exist for B

9c:
The reservation cannot be modified since it doesn't exist for B as long as transaction A has not been committed

10a:
An overbooking did not occur for us we got 19 on both our queries. This might be because it is hard to make the conurrency accurate.
Since we are starting the transactions seperatly it doesnt run "exactly" concurrently

10b:
An overbooking is indeed possible. Since we check if the seats are enough in our addPayment method we can get an okay depending on how many passengers
have been added by the other transaction. If this line happens in one transaction and runs while the other is still add passengers its possible
to get overbookking. (Sorry if we explained it poorly but we did our best)

10c:
We have tried our best to make overbooking occurr but we have not managed to find the right timing. The reason is the same as in 10a. Since
we are running the transactions in seperate terminals on our device, its hard to get the timing right in the transactions. We can of course add
sleeps in our transactions but this does not hinder the human factor in us deciding when the transaction start by running the script

10d: The simplest (although not most effective) way is to lock all of the tables that are read/written to before and after the addPayment method.
In the code it would look as follows:

LOCK TABLES
    (tables that are written to) write,
    (tables that are read form) read;
CALL addPayment()
UNLOCK TABLES;



For the secondary index we feel like the flight table would be an appropriate candidate. Since we often access the table via values 
other than the primary key. Since flight is a table with many values and often accesed via the weekly_schedule id or just the week number
there is potential for an implementation of a secondary index. 

If we create a secondary index for the flight table we first have to decide the block size. This size is pretty much arbitrary as long as it is smalle than 52.
Since the week value will havve many repeated values we use the repeating field with pointers method. This means that each value in the index table has multiple pointers
that cover every entry of the value in the data blocks.

So it could look something like this

Index File:
Week
1, (pointers to data) Ex: Block 1, Block 3, Block 4
2, (pointers to data)
3, (pointers to data)
4, (pointers to data)
5, (pointers to data)

Block 1:
Flight_nr1, weekly_flight1, week1
Flight_nr2, weekly_flight2, week2
Flight_nr2, weekly_flight2, week2

Here the first entry og the index file would point to every block in the data files that contains the week 1.
*/
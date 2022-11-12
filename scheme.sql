/* number, what would you like to be called, email, */
CREATE TABLE People
(
	Full_name            NCHAR(128) 		NOT NULL,
	Age                  TINYINT UNSIGNED 		NOT NULL check ( age < 200 ),
	Passport             CHAR(10) 			NOT NULL check ( Passport REGEXP '^[0-9]\{5,\}$' ),
	Sex                  enum('Not known', 'Male', 'Female', 'Not applicable',
						 'helicopter', 'deer', 'kostyaan') NOT NULL,
	person_id            INTEGER UNSIGNED	 	NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (person_id)
);

-- building, like 1a
-- address
CREATE TABLE Room
(
	Floor                TINYINT UNSIGNED NOT NULL Default( 1 ),
	`Number`             TINYINT UNSIGNED NOT NULL Default( 1 ),
	`Class`              enum('vip', 'standart', 'half vip') NOT NULL default( 'standart' ),
	Capacity             TINYINT UNSIGNED NOT NULL Default( 1 ),
	room_id              INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (room_id)
);

-- add feedback
-- succesful or not + full revert of money or not
CREATE TABLE HotelOrder
(
	DateInfo             DATE 		NOT NULL,
	Price                INT UNSIGNED 	NOT NULL,
	Stars                TINYINT UNSIGNED 	NULL check ( Stars <= 5 ),
	person_id            INTEGER UNSIGNED 	NOT NULL,
	room_id              INTEGER UNSIGNED 	NOT NULL,
	order_id             INTEGER UNSIGNED 	NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (order_id),
	FOREIGN KEY ( person_id ) REFERENCES People( person_id ),
	FOREIGN KEY ( room_id ) REFERENCES Room( room_id )
);



/*
	возможные таблицы
Workers - id, FullName, speciality - profession, worker payment/salary,
					dates when he worked, phone,

					---
					dates for vacation, schedule for week/month or
					involvment in some group that has its own schedule for work
					maybe like waitress or cleaning


secure - workers  -  id, education,
	   					passport, age, sex, notes about,
						worker credit card info





curr info about - I can get from hotel orders





schedule 	-		person_id - dates for vacation,
					schedule for week/month for 1 person or
					involvment in some group that has its own schedule for work
					maybe like waitress or cleaning, but what if it is unique







*/

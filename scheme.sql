CREATE TABLE PersonInfo
(
	FullName			NCHAR(128) 		NOT NULL,
	Age					TINYINT UNSIGNED 		NOT NULL check ( age < 130 ),
	Passport			CHAR(10) 			NOT NULL check ( Passport REGEXP '^[0-9]\{5,\}$' ),
	Sex					enum('Not known', 'Male', 'Female', 'Not applicable') NOT NULL,
	person_id			INTEGER UNSIGNED	 	NOT NULL AUTO_INCREMENT,
	PRIMARY KEY ( person_id )
);


CREATE TABLE Customer
(
	WrongBehaviour		NCHAR(128) 				NULL,
	Status				enum( 'vip', 'standart' ) default( 'standart' ) NULL,
	HavePets			BOOLEAN 				NOT NULL DEFAULT( FALSE ),
	InBlackList			BOOLEAN 				NOT NULL DEFAULT( FALSE ),
	customer_id			INTEGER UNSIGNED	 	NOT NULL,
	FOREIGN KEY ( customer_id ) REFERENCES PersonInfo( person_id ),
	PRIMARY KEY ( customer_id )
);

CREATE TABLE Room
(
	Floor				TINYINT UNSIGNED NOT NULL Default( 1 ),
	`Number`			TINYINT UNSIGNED NOT NULL Default( 1 ),
	`Class`				enum('vip', 'standart', 'half vip') NOT NULL default( 'standart' ),
	Capacity			TINYINT UNSIGNED NOT NULL Default( 1 ),
	room_id				INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	PRIMARY KEY ( room_id )
);

CREATE TABLE HotelOrder
(
	DateInfo			DATE 		NOT NULL,
	Price				INT UNSIGNED 	NOT NULL,
	Stars				TINYINT UNSIGNED 	NULL check ( Stars <= 5 ),
	customer_id			INTEGER UNSIGNED 	NOT NULL,
	room_id				INTEGER UNSIGNED 	NOT NULL,
	order_id			INTEGER UNSIGNED 	NOT NULL AUTO_INCREMENT,
	FOREIGN KEY ( customer_id ) REFERENCES Customer( customer_id ),
	FOREIGN KEY ( room_id ) REFERENCES Room( room_id ),
	PRIMARY KEY ( order_id )
);

CREATE TABLE Employee
(
	Speciality			NCHAR(128) 			NOT NULL,
	PhoneNumber			NCHAR(20)			NOT NULL check ( PhoneNumber REGEXP
															'^[+]?[0-9]\{3,20\}$' ),
	TimeIn				TIME 				NOT NULL default( '9:00:00' ),
	TimeOut				TIME				NOT NULL default( '18:00:00' ),
	employee_id			INTEGER UNSIGNED	NOT NULL,
	FOREIGN KEY ( employee_id ) REFERENCES PersonInfo( person_id ),
	PRIMARY KEY ( employee_id )
);

CREATE TABLE EmployeeDetailedInfo
(
	Salary				INTEGER UNSIGNED 	NOT NULL,
	Rate				FLOAT 				NOT NULL default( 1 ) check( Rate > 0 ),
	Address				NCHAR(50)			NULL,
	supervisor_id		INTEGER UNSIGNED	NULL,
	employee_id			INTEGER UNSIGNED	NOT NULL,
	FOREIGN KEY ( employee_id ) REFERENCES Employee( employee_id ),
	FOREIGN KEY ( supervisor_id ) REFERENCES Employee( employee_id ),
	PRIMARY KEY ( employee_id )
);


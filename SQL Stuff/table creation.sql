DROP TABLE IF EXISTS cfddb.training;
CREATE TABLE cfddb.training (
	training_id int PRIMARY KEY AUTO_INCREMENT,
    training_type varchar(255),
    training_topic varchar(255),
    training_description varchar(1000),
    training_date text,
    training_start_time text,
    training_end_time text,
    training_trainer int,
    training_delete text
);

DROP TABLE IF EXISTS cfddb.firefighter;
CREATE TABLE cfddb.firefighter (
	firefighter_id int PRIMARY KEY AUTO_INCREMENT,
    firefighter_first_name varchar(255),
    firefighter_last_name varchar(255),
    firefighter_full_name varchar(511),
    firefighter_start_date text,
    firefighter_trainer boolean,
    firefighter_officer boolean,
    firefighter_deactive_date text
);

DROP TABLE IF EXISTS cfddb.attendance;
CREATE TABLE cfddb.attendance (
	attendance_id int PRIMARY KEY AUTO_INCREMENT,
    firefighter_id int NOT NULL,
    training_id int NOT NULL,
    check_in text,
    check_out text,
    auto_checkout boolean,
    credit boolean
);


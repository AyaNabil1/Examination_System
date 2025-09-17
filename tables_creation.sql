---DDL----



create table student (
		stud_id int primary key,
		f_name varchar (50)not null,
		l_name varchar (50)not null,
		[user_name] varchar (50)not null,
		[password] varchar (50)not null,
		ssn bigint unique not null,
		gender varchar (50)not null,
		b_date date not null,
		street varchar (50) not null,
		city varchar (50) not null,
		phone varchar (15) not null,
		grad_year varchar(10) not null,
		track_id int foreign key references track (track_id) on delete cascade
					 )

ALTER TABLE Student
ADD Age AS (DATEDIFF(YEAR, B_date, GETDATE()));


create table instructor (
		inst_id int primary key,
		f_name varchar(50) not null,
		l_name varchar(50) not null,
		[user_name] varchar (50)not null,
		[password] varchar (50)not null,
		salary int not null,
		gender varchar (50)not null,
		street varchar (50) not null,
		city varchar (50) not null,
		phone varchar (15) not null,
		dept_id int foreign key references department(dept_id) on delete cascade
						)
create table course (
		crs_id int primary key,
		crs_name varchar (50) not null,
		max_degree int not null,
		min_degree int not null,
		crs_description varchar (50) not null,
		inst_id int foreign key references instructor(inst_id) on delete cascade
					)


create table department (
		dept_id int primary key,
		dept_name varchar(50) not null
						)

create table exam (
		exam_id int primary key,
		exam_name varchar (50) not null,
		exam_type varchar (50) not null,
		[date] date not null,
		start_time time not null,
		end_time time not null,
		exam_grade int,
		inst_id int foreign key references instructor(inst_id) ,
		crs_id int foreign key references course(crs_id) on delete cascade
				  )

ALTER TABLE Exam
ADD Duration AS (DATEDIFF(MINUTE,Start_time, End_time))

create table branch (
		branch_id int primary key,
		branch_name varchar (50) not null,
		[location] varchar (50) not null
				    )

create table track (
		track_id int primary key,
		track_name varchar (50) not null,
		dept_id int foreign key references department (dept_id) on delete cascade 
				   )

create table intake (
		intake_id int primary key,
		[start_date] date not null,
		[end_date] date not null
					)


create table question (
		question_id int primary key,
		question_text varchar (max) not null,
		question_type varchar (50) not null,
		question_point int not null,
		crs_id int foreign key references course (crs_id) on delete cascade ,
		inst_id int foreign key references instructor(inst_id)

					  )

create table choice (
		choice_id int,
		choice_text varchar(50) not null,
		is_correct bit not null ,
		question_id int foreign key references question(question_id) on delete cascade,
		primary key (choice_id,question_id)
			        )

create table student_exam_question (
		stud_id int foreign key references student(stud_id),
		exam_id int foreign key references exam(exam_id) on delete cascade,
		question_id int foreign key references question(question_id),
		stud_answer varchar(50) not null,
		stud_score int,
		primary key (stud_id,exam_id,question_id)
							       )


create table branch_intake_track (
		intake_id int foreign key references intake(intake_id) ,
		branch_id int foreign key references branch(branch_id) ,
		track_id int foreign key references track(track_id) ,
		primary key (intake_id,branch_id,track_id)
								  )


create table course_track (
crs_id int foreign key references course(crs_id) on delete cascade,
track_id int foreign key references track(track_id)
)
CREATE TABLE Exam_Question(
 Exam_id INT FOREIGN KEY REFERENCES Exam(exam_id),
 question_id INT FOREIGN KEY REFERENCES Question(question_id),
 PRIMARY KEY (Exam_id, question_id)
)

create table student_exam(
stud_id int not null foreign key references student(stud_id) ,
exam_id int not null foreign key references exam(exam_id),
PRIMARY KEY (stud_id, exam_id) 
)

create table result (
stud_id int foreign key references student(stud_id) on delete cascade,
exam_id int foreign key references exam(exam_id),
[percentage] decimal(5,1),
PRIMARY KEY (stud_id,exam_id))

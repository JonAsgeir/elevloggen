extends Node
class_name DatabaseManager

var db: SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "user://elevdatabase.db"
	db.open_db()
	create_tables()
	print(ProjectSettings.globalize_path("user://"))
	
	import_students_from_csv("res://import/testdata.csv")

	
func create_tables() -> void:
	db.query("""
	CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birthdate TEXT,
    contact_mother INTEGER DEFAULT 0,
    contact_father INTEGER DEFAULT 0,
    UNIQUE(first_name, last_name, birthdate)
	);
	""")

	db.query("""
	CREATE TABLE IF NOT EXISTS subjects (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL UNIQUE
	);
	""")

	db.query("""
	CREATE TABLE IF NOT EXISTS student_subjects (
	student_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	grade_goal TEXT DEFAULT 'ikke satt',
	PRIMARY KEY (student_id, subject_id),
	FOREIGN KEY (student_id) REFERENCES students(id),
	FOREIGN KEY (subject_id) REFERENCES subjects(id)
	);
	""")

	db.query("""
	CREATE TABLE IF NOT EXISTS goals (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	student_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	goal_text TEXT NOT NULL,
	created_date TEXT NOT NULL,
	completed_date TEXT,
	completion_result TEXT, -- completed / not_completed
	comment TEXT,
	FOREIGN KEY (student_id) REFERENCES students(id),
	FOREIGN KEY (subject_id) REFERENCES subjects(id)
	);
	""")
	
	db.query("""
	CREATE UNIQUE INDEX IF NOT EXISTS one_active_goal_per_student_subject
	ON goals(student_id, subject_id)
	WHERE completed_date IS NULL;
	""")

	db.query("""
	CREATE TABLE IF NOT EXISTS interactions (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	student_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	type TEXT NOT NULL, -- positive / negative
	comment TEXT,
	date TEXT NOT NULL,
	FOREIGN KEY (student_id) REFERENCES students(id),
	FOREIGN KEY (subject_id) REFERENCES subjects(id)
	);
	""")
	
	db.query("""
	CREATE TABLE IF NOT EXISTS mastery_observations (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	student_id INTEGER NOT NULL,
	subject_id INTEGER NOT NULL,
	status TEXT NOT NULL, -- yes / unknown / no
	comment TEXT,
	date TEXT NOT NULL,
	FOREIGN KEY (student_id) REFERENCES students(id),
	FOREIGN KEY (subject_id) REFERENCES subjects(id)
	);
	""")
	
	
func add_student(
	first_name: String,
	last_name: String,
	birthdate: String
) -> void:
	db.query("""
	INSERT INTO students
	(first_name, last_name, birthdate)
	VALUES
	('%s', '%s', '%s');
	""" % [first_name, last_name, birthdate])
	
func get_student(student_id: int) -> Dictionary:
	db.query("""
	SELECT *
	FROM students
	WHERE id = %d;
	""" % student_id)

	if db.query_result.size() > 0:
		return db.query_result[0]

	return {}
	
func get_student_in_subject(student_id: int, subject_id: int) -> Dictionary:
	db.query("""
	SELECT
		students.*,
		student_subjects.grade_goal
	FROM students
	JOIN student_subjects
		ON students.id = student_subjects.student_id
	WHERE students.id = %d
	AND student_subjects.subject_id = %d;
	""" % [student_id, subject_id])

	if db.query_result.size() > 0:
		return db.query_result[0]

	return {}

func add_subject(subject_name: String) -> void:
	db.query("""
	INSERT OR IGNORE INTO subjects (name)
	VALUES ('%s');
	""" % subject_name)

func get_subjects() -> Array:
	db.query("SELECT * FROM subjects ORDER BY name;")
	return db.query_result


func connect_student_to_subject(student_id: int, subject_id: int) -> void:
	db.query("""
	INSERT OR IGNORE INTO student_subjects
	(student_id, subject_id)
	VALUES (%d, %d);
	""" % [student_id, subject_id])

func get_students_in_subject(subject_id: int) -> Array:
	db.query("""
	SELECT
    	students.*,
    	student_subjects.grade_goal
	FROM students
	JOIN student_subjects
    	ON students.id = student_subjects.student_id
	WHERE student_subjects.subject_id = %d
	ORDER BY students.last_name, students.first_name;
	""" % subject_id)

	return db.query_result
	
func get_subject_id(subject_name: String) -> int:
	db.query("""
	SELECT id
	FROM subjects
	WHERE name = '%s';
	""" % subject_name)

	if db.query_result.size() > 0:
		return db.query_result[0]["id"]

	return -1
	
func get_subjects_for_student(student_id: int) -> Array:
	db.query("""
	SELECT subjects.*
	FROM subjects
	JOIN student_subjects
		ON subjects.id = student_subjects.subject_id
	WHERE student_subjects.student_id = %d
	ORDER BY subjects.name;
	""" % student_id)

	return db.query_result
	
func get_or_create_student(first_name: String, last_name: String, birthdate: String) -> int:
	db.query("""
	SELECT id FROM students
	WHERE first_name = '%s'
	AND last_name = '%s'
	AND birthdate = '%s';
	""" % [first_name, last_name, birthdate])

	if db.query_result.size() > 0:
		return db.query_result[0]["id"]

	add_student(first_name, last_name, birthdate)

	db.query("""
	SELECT id FROM students
	WHERE first_name = '%s'
	AND last_name = '%s'
	AND birthdate = '%s';
	""" % [first_name, last_name, birthdate])

	return db.query_result[0]["id"]	
	
func get_or_create_subject(subject_name: String) -> int:
	add_subject(subject_name)
	return get_subject_id(subject_name)	

func update_parent_contact(student_id: int, contact_mother: bool, contact_father: bool) -> void:
	var mother_value := 1 if contact_mother else 0
	var father_value := 1 if contact_father else 0

	db.query("""
	UPDATE students
	SET contact_mother = %d,
	    contact_father = %d
	WHERE id = %d;
	""" % [mother_value, father_value, student_id])

func update_grade_goal(student_id: int, subject_id: int, grade_goal: String) -> void:
	db.query("""
	UPDATE student_subjects
	SET grade_goal = '%s'
	WHERE student_id = %d
	AND subject_id = %d;
	""" % [grade_goal, student_id, subject_id])

func get_active_goal(student_id: int, subject_id: int) -> Dictionary:
	db.query("""
	SELECT *
	FROM goals
	WHERE student_id = %d
	AND subject_id = %d
	AND completed_date IS NULL;
	""" % [student_id, subject_id])

	if db.query_result.size() > 0:
		return db.query_result[0]

	return {}

func save_active_goal(student_id: int, subject_id: int, goal_text: String, date: String) -> void:
	goal_text = goal_text.strip_edges()

	var active_goal: Dictionary = get_active_goal(student_id, subject_id)

	if active_goal.is_empty():
		if goal_text == "":
			return

		db.query("""
		INSERT INTO goals
		(student_id, subject_id, goal_text, created_date)
		VALUES
		(%d, %d, '%s', '%s');
		""" % [student_id, subject_id, goal_text, date])
	else:
		db.query("""
		UPDATE goals
		SET goal_text = '%s'
		WHERE id = %d;
		""" % [goal_text, active_goal["id"]])

func complete_active_goal(
	student_id: int,
	subject_id: int,
	completion_result: String,
	completed_date: String,
	comment: String
) -> void:
	var active_goal: Dictionary = get_active_goal(student_id, subject_id)

	if active_goal.is_empty():
		return

	db.query("""
	UPDATE goals
	SET completed_date = '%s',
	    completion_result = '%s',
	    comment = '%s'
	WHERE id = %d;
	""" % [completed_date, completion_result, comment, active_goal["id"]])

func add_mastery_observation(
	student_id: int,
	subject_id: int,
	status: String,
	comment: String,
	date: String
) -> void:
	db.query("""
	INSERT INTO mastery_observations
	(student_id, subject_id, status, comment, date)
	VALUES
	(%d, %d, '%s', '%s', '%s');
	""" % [student_id, subject_id, status, comment, date])

func add_interaction(
	student_id: int,
	subject_id: int,
	type: String,
	comment: String,
	date: String
) -> void:
	db.query("""
	INSERT INTO interactions
	(student_id, subject_id, type, comment, date)
	VALUES
	(%d, %d, '%s', '%s', '%s');
	""" % [student_id, subject_id, type, comment, date])

func import_students_from_csv(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		print("Kunne ikke åpne CSV-fil: ", path)
		return

	# Hopp over overskriften
	file.get_csv_line()

	while not file.eof_reached():
		var row := file.get_csv_line(";")

		if row.size() < 4:
			continue

		var first_name := row[0].strip_edges()
		var last_name := row[1].strip_edges()
		var birthdate := row[2].strip_edges()
		var subject_name := row[3].strip_edges()

		if first_name == "" or last_name == "" or subject_name == "":
			continue

		var student_id := get_or_create_student(first_name, last_name, birthdate)
		var subject_id := get_or_create_subject(subject_name)

		connect_student_to_subject(student_id, subject_id)

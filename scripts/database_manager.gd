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
	grade_goal TEXT DEFAULT '0',
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
		status TEXT DEFAULT 'active',
		created_date TEXT NOT NULL,
		completed_date TEXT,
		comment TEXT,
		FOREIGN KEY (student_id) REFERENCES students(id),
		FOREIGN KEY (subject_id) REFERENCES subjects(id)
	);
	""")

	db.query("""
	CREATE TABLE IF NOT EXISTS interactions (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		student_id INTEGER NOT NULL,
		subject_id INTEGER NOT NULL,
		type TEXT NOT NULL,
		comment TEXT NOT NULL,
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

func get_students() -> Array:
	db.query("SELECT * FROM students ORDER BY last_name, first_name;")
	return db.query_result
	
func add_subject(name: String) -> void:
	db.query("""
	INSERT OR IGNORE INTO subjects (name)
	VALUES ('%s');
	""" % name)


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

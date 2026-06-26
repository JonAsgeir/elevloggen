extends Node

var selected_subject_id: int = -1
var selected_subject_name: String = ""
var current_students: Array = []
var current_student_index: int = 0

func reset() -> void:
	selected_subject_id = -1
	selected_subject_name = ""
	current_students.clear()
	current_student_index = 0

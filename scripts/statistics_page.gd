extends Control

@onready var subject_label: Label = $MarginContainer/VBoxContainer/HeaderLabel

@onready var back_button: Button = $MarginContainer/VBoxContainer/NavigationButtonsContainer/BackButton
@onready var main_menu_button: Button = $MarginContainer/VBoxContainer/NavigationButtonsContainer/MainMenuButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/NavigationButtonsContainer/QuitButton

@onready var period_option_button: OptionButton = $MarginContainer/VBoxContainer/OptionButtonsContainer/PeriondOptionButton
@onready var limit_option_button: OptionButton = $MarginContainer/VBoxContainer/OptionButtonsContainer/LimitOptionButton

@onready var follow_up_section: StatisticsSection = $MarginContainer/VBoxContainer/ScrollContainer/StatisticsContainer/FollowUpSection
@onready var positive_section: StatisticsSection = $MarginContainer/VBoxContainer/ScrollContainer/StatisticsContainer/PositiveSection

func _ready() -> void:
	#SIGNALS
	back_button.pressed.connect(_on_back_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	period_option_button.item_selected.connect(_on_statistics_settings_changed)
	limit_option_button.item_selected.connect(_on_statistics_settings_changed)
	
	#SECTIONS
	follow_up_section.set_title("Oppfølging")
	positive_section.set_title("Her går det bra")
	
	show_statistics()


func show_statistics() -> void:
	var days := get_selected_period_days()
	var limit := get_selected_limit()

	show_follow_up_statistics(days, limit)
	show_positive_statistics(days, limit)

func get_selected_limit() -> int:
	match limit_option_button.selected:
		0: return 1
		1: return 3
		2: return 5
		_: return -1
	
func get_selected_period_days() -> int:
	match period_option_button.selected:
		0: return 14
		1: return 30
		2: return 60
		_: return -1
	
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/student_page.tscn")


func _on_main_menu_button_pressed() -> void:
	AppState.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_statistics_settings_changed(_index: int) -> void:
	show_statistics()

func show_follow_up_statistics(days: int, limit: int) -> void:
	var text := ""

	text += "[b]Færrest positive interaksjoner[/b]\n"

	var students = Database.get_students_with_fewest_positive_interactions(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%d)\n" % [
			student["first_name"],
			student["last_name"],
			student["positive_count"]
		]

	text += "\n"

	text += "[b]Lengst siden positiv interaksjon[/b]\n"

	students = Database.get_students_with_oldest_positive_interaction(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%s)\n" % [
			student["first_name"],
			student["last_name"],
			format_days(student["days_since_positive"])
		]

	text += "\n[b]Minst registrert mestring[/b]\n"

	students = Database.get_students_with_least_mastery(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%d)\n" % [
			student["first_name"],
			student["last_name"],
			student["mastery_count"]
		]

	text += "\n[b]Lengst siden mestring[/b]\n"

	students = Database.get_students_with_oldest_mastery(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%s)\n" % [
			student["first_name"],
			student["last_name"],
			format_days(student["days_since_mastery"])
		]
	text += "\n[b]Færrest oppnådde mål[/b]\n"

	students = Database.get_students_with_fewest_completed_goals(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%d)\n" % [
			student["first_name"],
			student["last_name"],
			student["completed_goal_count"]
		]

	text += "\n[b]Eldste aktive mål[/b]\n"

	students = Database.get_students_with_oldest_active_goals(
		AppState.selected_subject_id,
		limit
	)

	for student in students:
		text += "• %s %s (%s - %s)\n" % [
			student["first_name"],
			student["last_name"],
			student["goal_text"],
			format_days(student["days_since_goal_created"])
		]
		
	follow_up_section.set_content(text)
	
func show_positive_statistics(days: int, limit: int) -> void:
	var text := ""

	text += "[b]Flest positive interaksjoner[/b]\n"

	var students = Database.get_students_with_most_positive_interactions(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%d)\n" % [
			student["first_name"],
			student["last_name"],
			student["positive_count"]
		]

	text += "\n"

	text += "[b]Nyeste positive interaksjon[/b]\n"

	students = Database.get_students_with_newest_positive_interaction(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%s)\n" % [
			student["first_name"],
			student["last_name"],
			format_days(student["days_since_positive"])
		]
	
	text += "\n[b]Mest registrert mestring[/b]\n"

	students = Database.get_students_with_most_mastery(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%d)\n" % [
			student["first_name"],
			student["last_name"],
			student["mastery_count"]
		]

	text += "\n[b]Nyeste mestring[/b]\n"

	students = Database.get_students_with_newest_mastery(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%s)\n" % [
			student["first_name"],
			student["last_name"],
			format_days(student["days_since_mastery"])
		]
	
	text += "\n[b]Flest oppnådde mål[/b]\n"

	students = Database.get_students_with_most_completed_goals(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%d)\n" % [
			student["first_name"],
			student["last_name"],
			student["completed_goal_count"]
		]

	text += "\n[b]Nyeste oppnådde mål[/b]\n"

	students = Database.get_students_with_newest_completed_goals(
		AppState.selected_subject_id,
		days,
		limit
	)

	for student in students:
		text += "• %s %s (%s - %s)\n" % [
			student["first_name"],
			student["last_name"],
			student["goal_text"],
			format_days(student["days_since_goal_completed"])
		]
	positive_section.set_content(text)

func format_days(days) -> String:
	if days == null:
		return "Ingen"

	if days == 0:
		return "i dag"

	if days == 1:
		return "1 dag"

	return "%d dager" % days

extends VBoxContainer
class_name StatisticsSection

@onready var title_label: RichTextLabel = $Title
@onready var content_label: RichTextLabel = $Content

func set_title(title: String) -> void:
	title_label.text = "[b]%s [/b]\n\n" % [title]
	
func set_content(content: String) -> void:
	content_label.text = content

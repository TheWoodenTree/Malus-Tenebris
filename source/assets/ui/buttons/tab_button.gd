extends IconlessButton

@export var select_color: Color

var selected: bool = false


func select():
	selected = true
	disabled = true
	add_theme_color_override("font_disabled_color", select_color)


func deselect():
	selected = false
	disabled = false
	remove_theme_color_override("font_disabled_color")

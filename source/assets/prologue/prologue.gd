extends Control

signal finished

@onready var cont: MarginContainer = $cont
@onready var rect: ColorRect = $rect


func _ready() -> void:
	rect.z_index = 0
	for card in cont.get_children():
		for label: Label in card.get_children():
			label.visible_characters = 0
		card.visible = true
			
		for label: Label in card.get_children():
			await reveal_label_text(label, 0.05)
			await get_tree().create_timer(1.5, false).timeout
		
		await get_tree().create_timer(2.5, false).timeout
		var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(rect, "color", Color.BLACK, 2.5)
		
		await tween.finished
		card.visible = false
		rect.color = Color(0.0, 0.0, 0.0, 0.0)
		rect.z_index += 1
		await get_tree().create_timer(0.5, false).timeout
	finished.emit()
	queue_free()


func reveal_label_text(label: Label, reveal_interval: float):
	var char_count: int = label.get_total_character_count()
	while label.visible_characters < char_count:
		label.visible_characters += 1
		await get_tree().create_timer(reveal_interval, false).timeout

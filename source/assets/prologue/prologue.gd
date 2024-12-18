extends Control

signal finished

@onready var cont: MarginContainer = $cont
@onready var rect: ColorRect = $rect
@onready var text_click_player: AudioStreamPlayer = $text_click_player


func _ready() -> void:
	rect.z_index = 0
	for card in cont.get_children():
		# Set all text to have no chars showing
		for label: Label in card.get_children():
			label.visible_characters = 0
		card.visible = true
			
		# Reveal text
		for label: Label in card.get_children():
			await reveal_label_text(label, 0.05)
			await get_tree().create_timer(1.5, false).timeout
		
		# Fade to black
		await get_tree().create_timer(2.5, false).timeout
		var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(rect, "color", Color.BLACK, 2.5)
		
		# Prepare for next card to show
		await tween.finished
		card.visible = false
		rect.color = Color(0.0, 0.0, 0.0, 0.0)
		rect.z_index += 1
		await get_tree().create_timer(0.5, false).timeout
	finished.emit()
	queue_free()


func reveal_label_text(label: Label, reveal_interval: float):
	var char_count: int = label.get_total_character_count()
	var idx: int = 0
	while label.visible_characters < char_count:
		label.visible_characters += 1
		#if label.text[label.visible_characters - 1] == " ":
		#	continue
		if idx % 2 == 0:
			text_click_player.play()
		idx += 1
		await get_tree().create_timer(reveal_interval, false).timeout

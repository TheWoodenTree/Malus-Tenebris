extends Menu

@onready var title = $Cont/VBoxCont/Title
@onready var play_button = $Cont/VBoxCont/PlayButton
@onready var settings_button = $Cont/VBoxCont/SettingsButton
@onready var credits_button = $Cont/VBoxCont/CreditsButton
@onready var quit_button = $Cont/VBoxCont/QuitButton
@onready var title_screen_room = Global.main.title_screen_room
@onready var credits_menu = preload("res://source/assets/ui/menus/credits_menu.tscn").instantiate()
@onready var music_player = $MusicPlayer


func _enter_tree():
	Global.main.drone_player.stop()


func _ready():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(music_player, 'volume_db', 0.0, 2.0).from(-30.0)
	music_player.play()


func _on_play_button_pressed():
	Global.main.play_game_sound_player.play()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(music_player, 'volume_db', -80, 5.0)
	title_screen_room.move_camera_forward()
	hide_ui()
	await title_screen_room.camera_moved
	Global.main.load_world_and_player()


func _on_settings_button_pressed():
	Global.ui.display_menu(Global.ui.settings_menu)


func _on_credits_button_pressed():
	Global.ui.display_menu(credits_menu)


func _on_quit_button_pressed():
	get_tree().quit()


func hide_ui():
	visible = false
	play_button.disabled = true
	settings_button.disabled = true
	quit_button.disabled = true
	Global.lock_mouse()

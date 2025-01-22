extends Control

@onready var ui_click := $UiClick as AudioStreamPlayer

var time_paused : bool = false

func _ready() -> void:
	hide()

func pause_game():
	get_tree().paused = true
	show()
	time_paused = true

func unpause_game():
	get_tree().paused = false
	hide()
	time_paused = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if time_paused:
			unpause_game()
		else:
			pause_game()

func _on_continue_button_pressed() -> void:
	ui_click.play()
	unpause_game()


func _on_restart_level_button_pressed() -> void:
	ui_click.play()


func _on_main_menu_button_pressed() -> void:
	ui_click.play()

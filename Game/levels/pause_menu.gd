extends Control

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
	unpause_game()

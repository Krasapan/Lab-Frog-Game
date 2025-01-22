extends Control

@onready var ui_click := $UiClick as AudioStreamPlayer

func _on_start_button_pressed() -> void:
	ui_click.play()

func _on_credits_button_pressed() -> void:
	ui_click.play()

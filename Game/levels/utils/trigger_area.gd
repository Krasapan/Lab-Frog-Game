extends Area2D

@export var trigger_function: functions

@onready var label := $CenterContainer as CenterContainer
@onready var scene_manager := $"../../../" as SceneManager

enum functions {
	NONE,
	GO_TO_NEXT_LEVEL,
	RESTART_LEVEL,
	MUTATE_SMALL_FROG,
	MUTATE_BIG_FROG,
	MUTATE_ABILITY1,
	MUTATE_ABILITY2,
	MUTATE_ABILITY3,
	RESTART_GAME
}

func _ready() -> void:
	#sprite.queue_free()
	label.queue_free()

func _on_body_entered(body: Node2D) -> void:
	
	if body is Player:
		match trigger_function:
			1:
				if !is_instance_valid(scene_manager):
					push_error("SceneManager is not set for Anchor2D.")
					return
				scene_manager.transition_to_next_level()
			2:
				if !is_instance_valid(scene_manager):
					push_error("SceneManager is not set for Anchor2D.")
					return
				scene_manager.transition_to_restart_current_level()
			3:
				body.become_small_frog()
				queue_free()
			4:
				body.metamorph_start(0)
				queue_free()
			5:
				body.metamorph_start(1)
				queue_free()
			6:
				body.metamorph_start(2)
				queue_free()
			7:
				body.metamorph_start(3)
				queue_free()
			8:
				scene_manager._on_main_menu_button_pressed()

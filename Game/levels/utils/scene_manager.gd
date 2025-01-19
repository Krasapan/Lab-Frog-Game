extends Node
class_name SceneManager

@onready var fade_anim_player = $UserInterface/SceneFade/AnimationPlayer as AnimationPlayer
@onready var active_game_scenes_parent = $ActiveGameScenes as Node2D
@onready var next_level_delay_timer = $NextLevelDelay as Timer
@onready var restart_level_delay_timer = $RestartLevelDelay as Timer
@onready var first_level_delay_timer = $FirstLevelDelay as Timer
@onready var main_menu_delay_timer = $MainMenuDelay as Timer
@onready var ui_parent = $UserInterface as CanvasLayer
@onready var main_menu = $UserInterface/MainMenu as Control
@onready var pause_menu = $UserInterface/PauseMenu as Control
@onready var audio_manager = $AudioManager as AudioManager

@export var start_from_level : int = 0

var current_level_index: int = start_from_level
var main_menu_scene = preload("res://menus/main_menu.tscn")
var pause_menu_scene = preload("res://menus/pause_menu.tscn")

var levels = [
	preload("res://levels/level_00.tscn"),
	preload("res://levels/level_01.tscn"),
	preload("res://levels/level_02.tscn"),
	preload("res://levels/level_03.tscn"),
	preload("res://levels/level_04.tscn"),
	preload("res://levels/level_05.tscn"),
	#preload("res://levels/level_06.tscn"),
	#preload("res://levels/level_07.tscn"),
	#preload("res://levels/level_final.tscn")
]

func _ready() -> void:
	for child in active_game_scenes_parent.get_children():
		child.process_mode = PROCESS_MODE_DISABLED
	pause_menu.process_mode = PROCESS_MODE_DISABLED
	audio_manager.play_music_track(0)
	await get_tree().process_frame
	_screen_fade_out()
	



func _screen_fade_out():
	fade_anim_player.play("fade_out")

func _screen_fade_in():
	fade_anim_player.play("fade_in")




func transition_to_first_level():
	first_level_delay_timer.start()

func load_first_level():
	var first_level = levels[start_from_level]
	active_game_scenes_parent.add_child(first_level)

func _on_first_level_delay_timeout() -> void:
	load_first_level()




func transition_to_next_level():
	pause_menu.process_mode = PROCESS_MODE_DISABLED
	_screen_fade_in()
	next_level_delay_timer.start()

func _on_next_level_delay_timeout() -> void:
	load_next_level()

func load_next_level() -> void:
	for child in active_game_scenes_parent.get_children():
		child.queue_free()
		
	current_level_index += 1
	
	if current_level_index < levels.size():
		var next_level = levels[current_level_index]
		var next_level_instance = next_level.instantiate()
		active_game_scenes_parent.add_child(next_level_instance)
	else:
		push_error("No more levels to load! \"load_next_level()\" ignored.")
	await get_tree().process_frame
	pause_menu.process_mode = PROCESS_MODE_ALWAYS
	_screen_fade_out()
	




func _on_restart_level_button_pressed() -> void:
	transition_to_restart_current_level()

func transition_to_restart_current_level() -> void:
	pause_menu.unpause_game()
	pause_menu.process_mode = PROCESS_MODE_DISABLED
	_screen_fade_in()
	restart_level_delay_timer.start()

func restart_current_level() -> void:
	for child in active_game_scenes_parent.get_children():
		child.queue_free()
	var current_level = levels[current_level_index]
	var current_level_instance = current_level.instantiate()
	active_game_scenes_parent.add_child(current_level_instance)
	#else:
		#push_error("Invalid current level index! \"restart_current_level()\" ignored.")
	await get_tree().process_frame
	pause_menu.process_mode = PROCESS_MODE_ALWAYS
	_screen_fade_out()

func _on_restart_level_delay_timeout() -> void:
	restart_current_level()




func _on_start_button_pressed() -> void:
	for children in active_game_scenes_parent.get_children():
		children.process_mode = PROCESS_MODE_INHERIT
	main_menu.queue_free()
	pause_menu.process_mode = PROCESS_MODE_ALWAYS
	audio_manager.main_menu_track_anim_player.play("fade_out")

func _on_main_menu_button_pressed() -> void:
	_screen_fade_in()
	main_menu_delay_timer.start()

func _on_main_menu_delay_timeout() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

extends Node
class_name LevelMusicStarter

@onready var scene_manager := $"../../../" as SceneManager
@export var level_track_index : int = 0

func _ready() -> void:
	if is_instance_valid(scene_manager):
		scene_manager.audio_manager.play_music_track(level_track_index)
	else:
		push_error("SceneManager is not set for LevelMusicStarter.")

extends Node
class_name AudioManager

@onready var main_menu_track = $MainMenuMusic as AudioStreamPlayer
@onready var level01_track = $Level01Music as AudioStreamPlayer
@onready var level02_track = $Level02Music as AudioStreamPlayer
@onready var level03_track = $Level03Music as AudioStreamPlayer
@onready var main_menu_track_anim_player = $MainMenuMusicAnimPlayer as AnimationPlayer

func stop_all_music_tracks():
	for track in get_children():
		if track is AudioStreamPlayer:
			track.stop()

func play_music_track(track_index: int):
	match track_index:
		0:
			if !main_menu_track.is_playing():
				main_menu_track.play()
		1:
			if !level01_track.is_playing():
				level01_track.play()
		2:
			if !level02_track.is_playing():
				level02_track.play()
		3:
			if !level03_track.is_playing():
				level03_track.play()

extends Node
class_name AudioManager

@onready var main_menu_track = $MainMenuMusic as AudioStreamPlayer
@onready var level01_track = $Level01Music as AudioStreamPlayer
@onready var level02_track = $Level02Music as AudioStreamPlayer
@onready var level03_track = $Level03Music as AudioStreamPlayer
@onready var level03_drums01 = $Level03Drums1 as AudioStreamPlayer
@onready var level03_drums02 = $Level03Drums2 as AudioStreamPlayer
@onready var leitmotiv = $LeitmotivMusic as AudioStreamPlayer
@onready var main_menu_track_anim_player = $MainMenuMusicAnimPlayer as AnimationPlayer

func stop_all_music_tracks():
	for track in get_children():
		if track is AudioStreamPlayer:
			track.stop()

func play_music_track(track_index: int):
	match track_index:
		0:
			level03_drums01.stop()
			level03_drums02.stop()
			level03_track.stop()
			_start_if_not_playing(main_menu_track)
		1:
			_start_if_not_playing(level01_track)
		2:
			_crossfade_to_next_track(level01_track, level02_track)
		3:
			_crossfade_to_next_track(level02_track, level03_track)
			_start_if_not_playing(level03_drums01)
			_start_if_not_playing(level03_drums02)
		4:
			_crossfade_to_next_track(null, level03_drums01)
		5:
			level03_drums01.stop()
			_crossfade_to_next_track(null, level03_drums02)
		6:
			level03_drums01.stop()
			level03_drums02.stop()
			level03_track.stop()
			_start_if_not_playing(leitmotiv)

func _crossfade_to_next_track(current: AudioStreamPlayer, next: AudioStreamPlayer):
	if current and current.is_playing():
		var tween1 = get_tree().create_tween()
		tween1.tween_property(current, "volume_db", -80, 8)
		tween1.tween_callback(current.stop)
	if !next.is_playing() or (next.volume_db == -80 and !current):
		next.volume_db = -20
		_start_if_not_playing(next)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(next, "volume_db", 0, 3)

func _start_if_not_playing(track: AudioStreamPlayer):
	if !track.is_playing():
			track.play()

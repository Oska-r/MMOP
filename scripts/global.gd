extends Node

func play_sound(sound, min: float = 0.9, max: float = 1.1):
	if sound is AudioStream:
		var music_player = AudioStreamPlayer.new()
		add_child(music_player)
		music_player.stream = sound
		music_player.play()
	
	elif sound is AudioStreamPlayer3D or sound is AudioStreamPlayer:
		sound.pitch_scale = randf_range(min, max)
		sound.play()

extends Node

## Plays sound with randomized pitch to prevent sound fatigue. Accepts AudioStream, AudioStreamPlayer and AudioStreamPlayer3D.
func play_sound(sound, min_pitch: float = 0.9, max_pitch: float = 1.1):

	if not sound:
		return
		
	var player = sound
	
	if sound is AudioStream:
		player = AudioStreamPlayer.new()
		add_child(player)
		
		# connected signal for self deletion
		player.finished.connect(player.queue_free)
		player.stream = sound
	
	player.pitch_scale = randf_range(min_pitch, max_pitch)
	player.play()

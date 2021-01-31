class_name RandomAudioPlayer
extends AudioStreamPlayer

export(Array, AudioStream) var tracks

var rng = RandomNumberGenerator.new()

func play_random_track() -> void:
	rng.randomize()
	var track_index = rng.randi_range(0, tracks.size() - 1)
	stream = tracks[track_index]
	play()

extends Window
@onready var audio_stream_player: AudioStreamPlayer = $Home/AudioStreamPlayer


func _input(event):
	if event.is_action_pressed('click'):
		stop()

func start(pos: Vector2i):
	position = pos
	audio_stream_player.play()
	show()
	
func stop():
	hide()
	audio_stream_player.stop()
	get_parent().show_sprite()

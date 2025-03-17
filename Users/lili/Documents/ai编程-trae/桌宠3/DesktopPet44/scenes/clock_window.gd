extends Window


func start(pos: Vector2i):
	position = pos
	show()

func stop():
	hide()
	get_parent().show_sprite()

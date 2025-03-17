extends Window

@export var rocket_scene: PackedScene
@export var colors: Array[Gradient]
var running: bool = false

func start():
	var screen = get_parent().screen
	size = DisplayServer.screen_get_size(screen)
	position = DisplayServer.screen_get_position(screen)
	show()
	var rect = DisplayServer.screen_get_usable_rect(screen)
	spawn_rocks(3,rect.size)
	running = true

func spawn_rocks(n:int, size:Vector2):
	var distance = size.x/(n+1)
	for i in range(n):
		var rock = rocket_scene.instantiate()
		rock.global_position = Vector2((i+1)*distance,size.y-100)
		rock.color = colors[i]
		add_child(rock)
		await get_tree().create_timer(0.1).timeout
	
	
func _process(delta: float) -> void:
	if running:
		check_end()
	
func check_end():
	var child_num = get_child_count()
	if child_num == 0:
		stop()
	
	
func stop():
	hide()
	get_parent().show_sprite()
	
	

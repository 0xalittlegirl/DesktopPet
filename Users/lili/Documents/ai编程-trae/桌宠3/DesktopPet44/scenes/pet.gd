extends Node2D

@onready var polygon_2d_player: Polygon2D = $Player/Polygon2DPlayer
@onready var polygon_2d_menu: Polygon2D = $Player/Polygon2DMenu
@onready var area_2d: Area2D = $Player/Sprite2D/Area2D
@onready var llmapi: AI = $LLMAPI
@onready var player: Node2D = $Player
@onready var control: Control = $Player/Control
@onready var rich_text_label: RichTextLabel = $Player/Control/PanelContainer/VBoxContainer/RichTextLabel
@onready var line_edit: LineEdit = $Player/Control/PanelContainer/VBoxContainer/LineEdit
@onready var animation_player: AnimationPlayer = $Player/AnimationPlayer
@onready var sprite_2d: Sprite2D = $Player/Sprite2D
@onready var home_window: Window = $HomeWindow
@onready var fire_window: Window = $FireWindow


var main_window: Window 
var screen: int
var show_menu:bool = false
var dragging:bool = false
var mouse_pos :Vector2i
var polygon : Polygon2D
var polygons = []
var direction = Vector2i.RIGHT
var current_state = "idle"
enum COMMAND {HOME, FIREWORK, GAME, TASK,HELP}
var command_dict = {"home": COMMAND.HOME,
					"firework":COMMAND.FIREWORK,
					"game":COMMAND.GAME,
					"task":COMMAND.TASK,
					"help": COMMAND.HELP}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_window()
	control.scale = Vector2.ZERO
	polygons = [polygon_2d_player, polygon_2d_menu]
	polygon = polygons[int(show_menu)]	
	line_edit.text_submitted.connect(on_submitted)
	llmapi.request_finished.connect(on_request_finished)
	area_2d.input_event.connect(on_input_event)


func _physics_process(delta: float) -> void:
	update_click_through()
	move()
	

func get_direction():
	var target_x = DisplayServer.mouse_get_position().x	
	if abs(main_window.position.x + 310 - target_x)< 200:
		current_state = "idle"
	else:
		current_state = "walk"
		if main_window.position.x + 310 > target_x:
			direction = Vector2i.LEFT
		else:
			direction = Vector2i.RIGHT
	
func move():
	get_direction()
	animation_player.play(current_state)
	sprite_2d.flip_h = direction == Vector2i.LEFT
	if current_state == "walk":
		main_window.position += direction * 5
		

func setup_window():
	main_window = get_window()
	main_window.size = DisplayServer.screen_get_size()
	screen = DisplayServer.window_get_current_screen(main_window.get_window_id())


func update_click_through():
	var click_polygon: PackedVector2Array = polygon.polygon
	for vec_i in range(click_polygon.size()):
		click_polygon[vec_i] = polygon.to_global(click_polygon[vec_i])
	#window.mouse_passthrough_polygon = click_polygon
	DisplayServer.window_set_mouse_passthrough(click_polygon)	

func _input(event):
	if event.is_action_pressed("drag") and  not dragging:
		dragging = true	
		mouse_pos = get_global_mouse_position()

	if event.is_action_released("drag") and dragging:
		dragging = false

	if event is InputEventMouseMotion and dragging:
		DisplayServer.window_set_position(DisplayServer.mouse_get_position()-mouse_pos)
		
	if event.is_action_pressed("quit"):
		get_tree().quit()
		

func show_sprite():
	sprite_2d.show()
	
func hide_sprite():
	show_menu = false
	control.scale = Vector2.ZERO
	sprite_2d.hide()


func on_input_event(viewport, event,shapeidx):
	if event.is_action_released("click") :
		show_menu = not show_menu
		
		var tw = create_tween()
		if show_menu:
			current_state = "idle"
			animation_player.play(current_state)
			polygon = polygons[int(show_menu)]
			tw.tween_property(control,"scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			show_text("你好，我是小狐狸,你可以和我聊任何话题，输入#+空格+help可以显示特殊指令帮助哦，按下Esc退出！",1)
		else:
			tw.tween_property(control,"scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
			rich_text_label.visible_ratio=0
			await tw.finished
			polygon = polygons[int(show_menu)]


func show_text(text:String, time:float):
	rich_text_label.text = text
	var tw = create_tween()
	tw.tween_property(rich_text_label,"visible_ratio",1,time).from(0)


func check_command(text):
	match command_dict[text]:
		COMMAND.FIREWORK:
			show_text("新年快乐啦",0.5)
			await get_tree().create_timer(0.5).timeout
			hide_sprite()
			fire_window.start()
		COMMAND.HOME:
			show_text("休息休息啦",0.5)
			await get_tree().create_timer(0.5).timeout
			hide_sprite()
			home_window.start(main_window.position)
		COMMAND.HELP:
			show_text("# home: 休息\n# firework: 放烟花",0.5)


func on_submitted(new_text:String):
	if new_text.begins_with("#"):
		var command_array = new_text.split(" ")
		if 	command_dict.has(command_array[1]):
			check_command(command_array[1])
	else:
		llmapi.call_aliyun(new_text)
		show_text("让我想想",0.5)
	
func on_request_finished(output:String):
	show_text(output,1)

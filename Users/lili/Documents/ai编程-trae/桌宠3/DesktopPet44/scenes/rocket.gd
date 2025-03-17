extends RigidBody2D

@export var color: Gradient
@export var firework_scene: PackedScene
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_central_impulse(Vector2(0,-1200))
	audio_stream_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if linear_velocity.y >=-50:
		var firework = firework_scene.instantiate()
		firework.global_position  = global_position
		firework.color = color
		get_parent().add_child(firework)
		queue_free()

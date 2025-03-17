extends Node2D


@export var color: Gradient
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var point_light_2d: PointLight2D = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cpu_particles_2d.color_ramp = color
	cpu_particles_2d.emitting = true
	audio_stream_player.play()
	var tw = create_tween()
	tw.tween_property(point_light_2d,"energy",1,2.0).from(4)
	await cpu_particles_2d.finished
	queue_free()

extends Node2D

@onready var spawnpoint: Marker2D = $Spawnpoint
@onready var player: CharacterBody2D = $player
@onready var camera_body_2d: CharacterBody2D = $CameraBody2D


func _process(_delta: float) -> void:
	if spawnpoint.global_position.distance_to(player.global_position) > 1000:
		player.global_position = spawnpoint.global_position
		player.velocity.y = 0.0
		camera_body_2d.global_position = spawnpoint.global_position

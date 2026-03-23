class_name HitBox
extends Area2D

@export var damage:int = 10

func _init() -> void:
	monitoring = false
	collision_layer = 2
	collision_mask = 2

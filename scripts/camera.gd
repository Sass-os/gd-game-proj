extends CharacterBody2D

@export var limit:float
@export var SPEED:float = 0.03
@export var Target:CharacterBody2D



func _physics_process(_delta: float) -> void:
	var speed:float = SPEED
	var parent_pos:Vector2 = Target.global_position
	if global_position != parent_pos:
		if global_position.distance_to(parent_pos) > limit:
			global_position = lerp(global_position,parent_pos,speed*1.5)

		else:
			global_position = lerp(global_position,parent_pos,speed)
		

class_name Damageable
extends Node

@export var health : float = 20

func hit(damage : float):
	health -= damage
	
	if(health <= 0):
		get_parent().queue_free()

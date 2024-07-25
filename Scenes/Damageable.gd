class_name Damageable
extends Node

@export var health : float = 20 :
	get:
		return health
	set(value):
		SignalBus.emit_signal("_on_health_changed", get_parent(), value - health)
		health = value

func hit(damage : float):
	health -= damage
	
	if(health <= 0):
		get_parent().queue_free()

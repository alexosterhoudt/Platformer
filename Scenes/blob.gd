extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var player = $"../Player"

var gravity = 980

func _ready():
	animated_sprite.play("Idle")

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

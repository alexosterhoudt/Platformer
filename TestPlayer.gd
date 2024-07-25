class_name Player
extends CharacterBody2D

@export var speed = 100
@export var jumpImpulse = -400
@export var dust : PackedScene
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var gravity = 980
var isAttacking = false
var screen_size;

signal facing_direction_changed(facing_right : bool)

enum STATE
{
	IDLE,
	WALK,
	JUMP,
	FALL,
	ATTACK
}

var currentState : STATE

func _ready():
	screen_size = get_viewport_rect().size
	_set_state(STATE.IDLE)

func _physics_process(delta):
	if(Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
		
	_update_state(delta)

func _set_state(new_state: STATE):
	if(currentState == new_state):
		return
	_exit_state()
	currentState = new_state
	_enter_state()

func _enter_state():
	match currentState:
		STATE.IDLE:
			animation_player.play("Idle")
		STATE.WALK:
			animation_player.play("Walk")
		STATE.JUMP:
			velocity.y = jumpImpulse
			animation_player.play("Jump")
		STATE.FALL:
			pass
		STATE.ATTACK:
			isAttacking = true
			animation_player.play("Attack")

func _update_state(delta: float):
	var direction = Input.get_axis("move_left", "move_right")
	match currentState:
		STATE.IDLE:
			if (direction):
				_set_state(STATE.WALK)
			elif (!is_on_floor()):
				_set_state(STATE.FALL)
			elif(Input.is_action_just_pressed("jump")):
				_set_state(STATE.JUMP)
			elif(Input.is_action_just_pressed("attack")):
				_set_state(STATE.ATTACK)
				isAttacking = true
		
		STATE.WALK:
			velocity.x = direction * speed
			
			if velocity.x < 0:
				sprite_2d.flip_h = true
			elif velocity.x > 0:
				sprite_2d.flip_h = false
			
			emit_signal("facing_direction_changed", !sprite_2d.flip_h)
			
			if !is_on_floor(): # if not on floor, fall down
				_set_state(STATE.FALL)
			elif Input.is_action_just_pressed("jump"):
				_set_state(STATE.JUMP) # if jump is pressed, jump
			elif velocity.x == 0: # if standing still, then set idle
				_set_state(STATE.IDLE)
			elif(Input.is_action_just_pressed("attack")):
				_set_state(STATE.ATTACK)
				isAttacking = true
				
			move_and_slide()
			
		STATE.JUMP: # Update JUMP state logic
			velocity.x = direction * speed
			
			if velocity.x < 0:
				sprite_2d.flip_h = true
			elif velocity.x > 0:
				sprite_2d.flip_h = false
			
			emit_signal("facing_direction_changed", !sprite_2d.flip_h)
			
			if !is_on_floor(): # if in the air, apply gravity
				velocity.y += gravity * delta
				if velocity.y > 0: # after max height, change from JUMP to FALL
					_set_state(STATE.FALL)
			if(Input.is_action_just_pressed("attack")):
				_set_state(STATE.ATTACK)
				isAttacking = true
				
			move_and_slide()
			
		STATE.FALL: # Update FALL state logic
			velocity.x = direction * speed
			if velocity.x < 0:
				sprite_2d.flip_h = true
			elif velocity.x > 0:
				sprite_2d.flip_h = false
			
			emit_signal("facing_direction_changed", !sprite_2d.flip_h)
			
			if is_on_floor(): # If the ground is reached, change back to idle
				_set_state(STATE.IDLE)
			else: # if still in the air, apply gravity
				velocity.y += gravity * delta
			if(Input.is_action_just_pressed("attack")):
				_set_state(STATE.ATTACK)
				isAttacking = true
				
			move_and_slide()
		
		STATE.ATTACK:
			velocity.x = 0
			if !is_on_floor():
				velocity.y += gravity * delta
			elif is_on_floor() && !isAttacking:
				_set_state(STATE.IDLE)
			
			move_and_slide()

func _exit_state() -> void:
	match currentState:
		STATE.IDLE: # Exit IDLE state logic
			pass
			
		STATE.WALK: # Exit WALK state logic
			pass
			
		STATE.JUMP: # Exit JUMP state logic
			pass
		
		STATE.FALL: # Exit FALL state logic
			if is_on_floor():
				var new_dust : CPUParticles2D = dust.instantiate()
				get_parent().add_child(new_dust)
				new_dust.global_position = global_position + Vector2(0,0)
				new_dust.emitting = true
				await new_dust.finished
				new_dust.queue_free()
		
		STATE.ATTACK:
			isAttacking = false

func _on_animated_sprite_2d_animation_finished():
	_set_state(STATE.IDLE)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Attack":
		_set_state(STATE.IDLE)

extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var gravity = 980

enum STATE
{
	IDLE,
	FALL,
	ATTACK
}

var currentState : STATE
var isAttacking = false

func _ready():
	_set_state(STATE.IDLE)

func _physics_process(delta):
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
			animated_sprite.play("Idle")
		STATE.FALL:
			pass
		STATE.ATTACK:
			isAttacking = true
			animated_sprite.play("Attack")

func _update_state(delta: float):
	match currentState:
		STATE.IDLE:
			if (!is_on_floor()):
				_set_state(STATE.FALL)
			elif(Input.is_action_just_pressed("attack")):
				_set_state(STATE.ATTACK)
				isAttacking = true
		STATE.FALL:
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
		STATE.FALL:
			pass
		STATE.ATTACK:
			isAttacking = false

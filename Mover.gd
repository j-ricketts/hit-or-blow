extends KinematicBody2D

const GRAVITY = 2000.0
const WALK_SPEED = 55
const MAX_WALK_SPEED = 200
const JUMP_SPEED = 650
const JUMP_ANIMATION_DELAY = 0.2
const CAN_JUMP_COOLDOWN = 0.2
const STAND_BY_ANIMATION_COOLDOWN = 10
const ACCEL = 700

# Input data handlers
var is_pressing_right = false
var is_pressing_left = false
var is_pressing_up = false
var is_pressing_down = false
var grounded = false

#Movement
var checking_landing = false
var velocity = Vector2()
onready var _animated_sprite = $AnimatedSprite
onready var _character = $Character

enum CharacterState {
		STANDING,
		RUNNING,
		JUMPING,
		FALLING,
		DEAD
	}
	
var characterState = CharacterState.STANDING

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateAnimation():
	if characterState == CharacterState.STANDING:
		
		_animated_sprite.stop()
		_animated_sprite.visible = false
		_character.visible = true
	elif characterState == CharacterState.RUNNING:
		_character.visible = false
		_animated_sprite.visible = true
		_animated_sprite.play("run")
		if velocity.x > 0:
			_animated_sprite.flip_h = false
		else:
			_animated_sprite.flip_h = true
	elif characterState == CharacterState.JUMPING:
		_character.visible = false
		_animated_sprite.visible = true
		_animated_sprite.play("jump")
	elif characterState == CharacterState.FALLING:
		_character.visible = false
		_animated_sprite.visible = true
		_animated_sprite.play("fall")
	
			
func updateCharacterState():
	if grounded:
		if abs(velocity.x) > 0.001:
			characterState = CharacterState.RUNNING
		else:
			characterState = CharacterState.STANDING
	else:
		if velocity.y < -50:
			characterState = CharacterState.JUMPING
		else:
			characterState = CharacterState.FALLING

func accel(wishDir, wishSpeed, acceleration, delta):
	# How fast are we travelling in the current wish direction.
	
	var currentWishDirSpeed = velocity.dot(wishDir)


	var accelSpeed = delta * acceleration

	var maxAddSpeed = abs(wishSpeed - currentWishDirSpeed)
	if (accelSpeed > maxAddSpeed):
		accelSpeed = maxAddSpeed

	
	velocity = velocity + wishDir*accelSpeed
	if (velocity.x > MAX_WALK_SPEED):
		velocity.x = MAX_WALK_SPEED
	elif (velocity.x < -MAX_WALK_SPEED):
		velocity.x = -MAX_WALK_SPEED
	
	
func updateGrounded():
	if velocity.y < -20:
		grounded = false 
	elif is_on_floor():
		grounded = true
	else:
		grounded = false


func doJump():
	if grounded:
		velocity.y = -JUMP_SPEED


func _physics_process(delta):
	updateAnimation()
	
	var wishDir = Vector2()
	var wishSpeed = 0.0
	
	if Input.is_action_pressed("right"):
		wishDir = Vector2(1, 0)
		wishSpeed = MAX_WALK_SPEED
		
	if Input.is_action_pressed("left"):
		wishDir = Vector2(-1, 0)
		wishSpeed = MAX_WALK_SPEED
	if Input.is_action_pressed("up"):
		doJump()
	
	if wishSpeed == 0:
		if velocity.x > 0:
			wishDir = Vector2(-1, 0)
			wishSpeed = 0
		else:
			wishDir = Vector2(1, 0)
			wishSpeed = 0
			
		# --- GRAVITY ---
	velocity.y += delta * GRAVITY
#
	accel(wishDir, wishSpeed, ACCEL, delta)
	
	updateGrounded()

	if grounded:
		velocity.y = 0
	
	move_and_slide(velocity, Vector2(0,-1))
	updateCharacterState()
	print(characterState)
	
	


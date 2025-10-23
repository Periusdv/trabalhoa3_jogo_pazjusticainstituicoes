extends CharacterBody2D

var speed = 300.0
var jump_speed = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2  # Posição inicial

func _ready():
	start_position = global_position  # Salva a posição inicial ao iniciar

func _physics_process(delta):
	# Adiciona gravidade
	velocity.y += gravity * delta

	# Pulo
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		$SoundJump.play()
		velocity.y = jump_speed

	# Movimento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Animação
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play()
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# Movimento e colisão
	move_and_slide()

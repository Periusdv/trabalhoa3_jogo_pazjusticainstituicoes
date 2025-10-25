extends CharacterBody2D

var speed = 300.0
var jump_speed = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var super_power: bool = false

# força de empurrão ao colidir com inimigo
var knockback_force = 10000.0


func _ready():
	start_position = global_position


func _physics_process(delta):
	# Aplicar gravidade
	velocity.y += gravity * delta

	# Movimento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Animações de movimento
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play()
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# Pulo
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		$SoundJump.play()
		velocity.y = jump_speed

	# Movimento e colisões
	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_collision(collision)

	move_and_slide()


func _on_collision(collision):
	var obj = collision.get_collider()
	if not obj:
		return

	# 🟢 Item: extintor
	if obj.is_in_group("estintor"):
		obj.queue_free()
		do_super()

	# 🔴 Inimigo: fogo
	elif obj.is_in_group("fogo"):
		if super_power:
			# Apaga o fogo
			obj.queue_free()
			
			# Empurra levemente o jogador para trás
			var direction = sign(global_position.x - obj.global_position.x)
			velocity.x = direction * knockback_force * 1  # empurrão
			velocity.y = -150  # leve impulso para cima
			print("Fogo apagado com extintor!")
		else:
			# Jogador sem super_power sofre dano
			var direction = sign(global_position.x - obj.global_position.x)
			velocity.x = direction * knockback_force * 0.5
			velocity.y = -200
			print("Levou dano!")
			#início, use global_position = start_position


func do_super() -> void:
	if not super_power:
		super_power = true
		speed += 100
		print("Poder ativado permanentemente!")
		#$AnimatedSprite2D.animation = "super"
		#get_parent().change_music(true)

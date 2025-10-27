extends CharacterBody2D

var speed = 300.0
var jump_speed = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2

# Knockback
var knockback_force = 1000.0
var knockback_decay = 8.0
var knockback_velocity = Vector2.ZERO
var is_knocked_back = false

# Controle de animação e estado
var is_extinguishing = false
var has_extintor = false
var super_power = false
var facing_dir = 1 # 1 = direita, -1 = esquerda

func _ready():
	start_position = global_position

	# Configura o CollisionShape2D do extintor para cobrir ambos os lados
	if $AreaExtintor:
		var shape = $AreaExtintor.get_node("CollisionShape2D")
		if shape.shape is RectangleShape2D:
			shape.shape.extents.x = 50  # alcance horizontal
			shape.shape.extents.y = 20  # alcance vertical
		$AreaExtintor.position = Vector2.ZERO

func _physics_process(delta):
	velocity.y += gravity * delta

	# Se estiver apagando fogo, mantém animação e ignora input
	if is_extinguishing:
		$AnimatedSprite2D.play("fumaça")
		move_and_slide()
		return

	# Knockback
	if is_knocked_back:
		velocity.x = knockback_velocity.x
		velocity.y += knockback_velocity.y * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay)

		if knockback_velocity.length() < 10:
			is_knocked_back = false
	else:
		# Movimento normal
		var direction = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed

		# Atualiza direção se estiver andando
		if direction != 0:
			facing_dir = direction

		# Animações
		if has_extintor:
			if direction != 0:
				$AnimatedSprite2D.play("super") # andando com extintor
			else:
				$AnimatedSprite2D.stop()        # parado com extintor
				$AnimatedSprite2D.frame = 0
		else:
			if direction != 0:
				$AnimatedSprite2D.play("default") # andando sem extintor
			else:
				$AnimatedSprite2D.stop()           # parado sem extintor
				$AnimatedSprite2D.frame = 0

		$AnimatedSprite2D.flip_h = facing_dir < 0

		# Pulo
		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			$SoundJump.play()
			velocity.y = jump_speed

	move_and_slide()

	# Pressionar espaço para apagar fogo
	if has_extintor and Input.is_action_just_pressed("ui_select"):  # tecla espaço
		_check_and_extinguish_fire()

	var collision = move_and_collide(velocity * get_physics_process_delta_time())
	if collision:
		_on_collision(collision)

func _on_collision(collision):
	var obj = collision.get_collider()
	if not obj:
		return

	# Pegou o extintor
	if obj.is_in_group("estintor"):
		obj.queue_free()
		do_super()

	# Colidiu com fogo
	elif obj.is_in_group("fogo"):
		if not has_extintor:
			# Knockback normal apenas se não tiver extintor
			var direction = sign(global_position.x - obj.global_position.x)
			print("🔥 Levou dano!")
			knockback_velocity = Vector2(direction * knockback_force, -200)
			is_knocked_back = true
		# Se tiver extintor, não faz nada — só apaga se apertar espaço

func _check_and_extinguish_fire():
	var area = $AreaExtintor
	if not area:
		return

	for body in area.get_overlapping_bodies():
		if body.is_in_group("fogo"):
			apagar_fogo(body)
			return

func apagar_fogo(fogo_node):
	is_extinguishing = true
	$AnimatedSprite2D.play("fumaça")
	print("🧯 Apagando fogo!")

	await get_tree().create_timer(0.6).timeout  # tempo da animação
	if is_instance_valid(fogo_node):
		fogo_node.queue_free()

	is_extinguishing = false
	print("🔥 Fogo apagado!")

func do_super() -> void:
	if not super_power:
		super_power = true
		has_extintor = true
		speed += 100
		print("💨 Extintor adquirido!")
		$AnimatedSprite2D.play("super")
		$AnimatedSprite2D.frame = 0

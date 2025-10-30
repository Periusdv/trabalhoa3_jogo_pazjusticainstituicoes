extends CharacterBody2D

# Movimento
var speed := 300.0
var jump_speed := -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var last_safe_position: Vector2

# Knockback
var knockback_velocity := Vector2.ZERO
var is_knocked_back := false

# Estado
var has_extintor := false
var super_power := false
var facing_dir := 1 # 1 = direita, -1 = esquerda

# Cena da fumaça
var smoke_scene := preload("res://fumaça.tscn")

# Limite de queda do mapa
const FALL_LIMIT_Y := 1000.0

func _ready():
	add_to_group("player")
	start_position = global_position
	last_safe_position = start_position

func _physics_process(delta):
	velocity.y += gravity * delta

	# Movimento knockback
	if is_knocked_back:
		velocity.x = knockback_velocity.x
		velocity.y += knockback_velocity.y * delta
		# Decaimento
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 8)
		if knockback_velocity.length() < 10:
			is_knocked_back = false
	else:
		var direction_input = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction_input * speed

		if direction_input != 0:
			facing_dir = direction_input

		# Animações
		if has_extintor:
			if direction_input != 0:
				$AnimatedSprite2D.play("super")
			else:
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 0
		else:
			if direction_input != 0:
				$AnimatedSprite2D.play("default")
			else:
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 0

		$AnimatedSprite2D.flip_h = facing_dir < 0

		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			$SoundJump.play()
			velocity.y = jump_speed

	move_and_slide()

	# Salva posição segura
	if is_on_floor():
		last_safe_position = global_position

	# Dispara fumaça
	if has_extintor and Input.is_action_just_pressed("ui_select"):
		shoot_fumaça()

	var collision = move_and_collide(velocity * get_physics_process_delta_time())
	if collision:
		_on_collision(collision)

	# Caiu do mapa
	if global_position.y > FALL_LIMIT_Y:
		_reset_to_last_safe_position()


# ---- COLISÕES ----
func _on_collision(collision):
	var obj = collision.get_collider()
	if not obj:
		return

	if obj.is_in_group("estintor"):
		obj.queue_free()
		do_super()
	elif obj.is_in_group("fogo"):
		print("🔥 Encostou no fogo!")
		# TODO: todo knockback do fogo é calculado pelo fogo
		if not super_power and obj.has_method("apply_knockback_to_player"):
			obj.apply_knockback_to_player(self)
		else:
			print("🛡️ Imune ao fogo (super ativo)")


# ---- RECEBE KNOCKBACK ----
func apply_knockback(force: Vector2):
	if super_power:
		print("💪 Super ativo — sem knockback")
		return

	print("💥 Jogador levou knockback: ", force)
	knockback_velocity = force
	is_knocked_back = true


# ---- DISPARO DE FUMAÇA ----
func shoot_fumaça():
	if not smoke_scene:
		print("⚠️ Cena da fumaça não atribuída!")
		return

	var fumaça = smoke_scene.instantiate()
	get_parent().add_child(fumaça)

	var pos = Vector2(global_position.x + (32 * facing_dir), global_position.y + 30)
	fumaça.global_position = pos
	fumaça.direction = facing_dir
	print("💨 Fumaça lançada em ", pos)


# ---- EXTINTOR / SUPER ----
func do_super() -> void:
	if not super_power:
		super_power = true
		has_extintor = true
		speed += 50
		print("🧯 Extintor adquirido (modo super)!")
		$AnimatedSprite2D.play("super")
		$AnimatedSprite2D.frame = 0


# ---- RESET POSIÇÃO APÓS QUEDA ----
func _reset_to_last_safe_position():
	print("⚠️ Caiu do mapa! Voltando à última posição segura...")
	global_position = last_safe_position
	velocity = Vector2.ZERO

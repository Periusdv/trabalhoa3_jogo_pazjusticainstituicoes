extends CharacterBody2D

# --- MOVIMENTO ---
var speed := 300.0
var jump_speed := -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var last_safe_position: Vector2

# --- ESTADO ---
var has_extintor := false
var super_power := false
var facing_dir := 1 # 1 = direita, -1 = esquerda

# --- FUMAÇA ---
var smoke_scene := preload("res://fumaça.tscn")
var smoke_cooldown := 0.5
var smoke_timer := 0.0

# --- LIMITE DE QUEDA ---
const FALL_LIMIT_Y := 1000.0

func _ready():
	add_to_group("player")
	start_position = global_position
	last_safe_position = start_position

func _physics_process(delta):
	velocity.y += gravity * delta

	# Movimento horizontal
	var direction_input = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction_input * speed

	if direction_input != 0:
		facing_dir = direction_input

	# Pulo
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		$SoundJump.play()
		velocity.y = jump_speed

	move_and_slide()

	# Salva posição segura
	if is_on_floor():
		last_safe_position = global_position

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

	# Atualiza timer da fumaça
	if smoke_timer > 0:
		smoke_timer -= delta

	# Disparo de fumaça
	if has_extintor and Input.is_action_just_pressed("ui_select") and smoke_timer <= 0:
		shoot_fumaça()
		smoke_timer = smoke_cooldown

	# Colisões
	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_collision(collision)

	# Limite de queda
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
		print("Encostou no fogo!")
		# Sem knockback, apenas impressão / efeito visual
		if not super_power:
			pass # pode adicionar efeito visual aqui se quiser

# ---- DISPARO DE FUMAÇA ----
func shoot_fumaça():
	if not smoke_scene:
		return
	var fumaça = smoke_scene.instantiate()
	get_parent().add_child(fumaça)

	# cria levemente afastada do corpo do player
	var offset = Vector2(40 * facing_dir, 10)
	fumaça.global_position = global_position + offset
	fumaça.direction = facing_dir

	# impede colisão imediata com o player
	fumaça.call_deferred("set_collision_layer_value", 1, false)
	fumaça.call_deferred("set_collision_mask_value", 1, false)

# ---- EXTINTOR / SUPER ----
func do_super() -> void:
	if not super_power:
		super_power = true
		has_extintor = true
		speed += 50
		print("Extintor adquirido (modo super)!")
		$AnimatedSprite2D.play("super")
		$AnimatedSprite2D.frame = 0

# ---- RESET POSIÇÃO APÓS QUEDA ----
func _reset_to_last_safe_position():
	print("Caiu do mapa! Voltando à última posição segura...")
	global_position = last_safe_position
	velocity = Vector2.ZERO

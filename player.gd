extends CharacterBody2D

# Movimento
var speed := 300.0
var jump_speed := -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2

# Knockback
var knockback_force := 1000.0
var knockback_decay := 8.0
var knockback_velocity := Vector2.ZERO
var is_knocked_back := false

# Estado
var has_extintor := false
var super_power := false
var facing_dir := 1 # 1 = direita, -1 = esquerda

# Cena da fumaça
var smoke_scene := preload("res://fumaça.tscn")

func _ready():
	start_position = global_position

func _physics_process(delta):
	velocity.y += gravity * delta

	if is_knocked_back:
		velocity.x = knockback_velocity.x
		velocity.y += knockback_velocity.y * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay)
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

	# Dispara fumaça
	if has_extintor and Input.is_action_just_pressed("ui_select"):
		shoot_fumaça()

	var collision = move_and_collide(velocity * get_physics_process_delta_time())
	if collision:
		_on_collision(collision)

func _on_collision(collision):
	var obj = collision.get_collider()
	if not obj:
		return

	if obj.is_in_group("estintor"):
		obj.queue_free()
		do_super()
	elif obj.is_in_group("fogo") and not has_extintor:
		var dir_hit = sign(global_position.x - obj.global_position.x)
		print("🔥 Levou dano!")
		knockback_velocity = Vector2(dir_hit * knockback_force, -200)
		is_knocked_back = true

# ---- DISPARO DE FUMAÇA ----
func shoot_fumaça():
	if not smoke_scene:
		print("⚠️ Cena da fumaça não atribuída!")
		return

	var fumaça = smoke_scene.instantiate()
	get_parent().add_child(fumaça)

	# Calcula ponto de spawn mais para baixo
	var half_h = $CollisionShape2D.shape.get_rect().size.y / 2.0 if $CollisionShape2D and $CollisionShape2D.shape is RectangleShape2D else 16
	
	
	# Aumente o valor positivo para descer mais
	var pos = Vector2(global_position.x + (32 * facing_dir), global_position.y + 30)
	# ↑↑↑ agora a fumaça sai mais para baixo do corpo

	fumaça.global_position = pos
	fumaça.direction = facing_dir
	print("💨 Fumaça lançada em ", pos)

func do_super() -> void:
	if not super_power:
		super_power = true
		has_extintor = true
		speed += 50
		print("🧯 Extintor adquirido!")
		$AnimatedSprite2D.play("super")
		$AnimatedSprite2D.frame = 0

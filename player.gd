extends CharacterBody2D

# -------------------------------
# MOVIMENTO
# -------------------------------
var speed := 255.0
var jump_speed := -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var start_position: Vector2
var last_safe_position: Vector2

# -------------------------------
# ESTADO
# -------------------------------
var has_extintor := false
var super_power := false
var facing_dir := 1 # 1 = direita, -1 = esquerda

# -------------------------------
# FUMAÇA
# -------------------------------
var smoke_scene := preload("res://fumaça.tscn")
var smoke_cooldown := 0.5
var smoke_timer := 0.0

# -------------------------------
# LIMITE DE QUEDA
# -------------------------------
const FALL_LIMIT_Y := 1000.0

# -------------------------------
# KNOCKBACK
# -------------------------------
var is_knocked_back := false
var knockback_timer := 0.0
const KNOCKBACK_DURATION := 0.3

# -------------------------------
# VIDAS
# -------------------------------
var vidas := 3
@onready var hud := get_tree().current_scene.get_node("HUD")

# -------------------------------
# INVENCIBILIDADE
# -------------------------------
var invencivel := false
var invencivel_tempo := 1.0 # duração em segundos

# -------------------------------
# READY
# -------------------------------
func _ready():
	add_to_group("player")
	start_position = global_position
	last_safe_position = start_position
	hud.atualizar_vidas(vidas)

# -------------------------------
# FÍSICA
# -------------------------------
func _physics_process(delta):
	velocity.y += gravity * delta

	if is_knocked_back:
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
		return

	var direction_input = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction_input * speed
	if direction_input != 0:
		facing_dir = direction_input

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		$SoundJump.play()
		velocity.y = jump_speed

	move_and_slide()

	if is_on_floor():
		last_safe_position = global_position

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

	if smoke_timer > 0:
		smoke_timer -= delta
	if has_extintor and Input.is_action_just_pressed("ui_select") and smoke_timer <= 0:
		shoot_fumaça()
		smoke_timer = smoke_cooldown

	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_collision(collision)

	if global_position.y > FALL_LIMIT_Y:
		morrer()

# -------------------------------
# COLISÕES
# -------------------------------
func _on_collision(collision):
	var obj = collision.get_collider()
	if not obj:
		return

	if obj.is_in_group("estintor"):
		obj.queue_free()
		do_super()

	elif obj.is_in_group("fogo"):
		if not super_power:
			if obj.has_method("apply_knockback_to_player"):
				obj.apply_knockback_to_player(self)
			tomar_dano(1)

	elif obj.is_in_group("predio_especial"):
		print("Fim de jogo!")
		morrer()

# -------------------------------
# KNOCKBACK RECEBIDO
# -------------------------------
func apply_knockback(force: Vector2):
	is_knocked_back = true
	knockback_timer = KNOCKBACK_DURATION
	velocity = force

# -------------------------------
# DANO E MORTE
# -------------------------------
func tomar_dano(valor: int = 1):
	if invencivel:
		return

	vidas -= valor
	hud.atualizar_vidas(vidas)
	print("Jogador tomou dano! Vidas restantes:", vidas)

	if vidas <= 0:
		morrer()
	else:
		tornar_invencivel(invencivel_tempo)

func tornar_invencivel(segundos: float):
	invencivel = true
	$AnimatedSprite2D.modulate = Color(1,1,1,0.5)
	await get_tree().create_timer(segundos).timeout
	invencivel = false
	$AnimatedSprite2D.modulate = Color(1,1,1,1)

# -------------------------------
# FUNÇÃO DE MORTE
# -------------------------------
func morrer():
	print("Jogador morreu!")
	velocity = Vector2.ZERO
	set_physics_process(false)
	$AnimatedSprite2D.visible = false

	var go_scene = preload("res://game_over.tscn").instantiate()
	go_scene.name = "GameOver"
	get_tree().current_scene.add_child(go_scene)

	var btn_restart = go_scene.get_node_or_null("Button")
	if btn_restart:
		btn_restart.pressed.connect(Callable(self, "_on_restart_game"))

# -------------------------------
# FUNÇÃO DE REINÍCIO
# -------------------------------
func _on_restart_game():
	print("Reiniciando jogo...")

	# 1️⃣ Reseta GameManager (fogos/extintores restaurados)
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if gm.has_method("resetar_estado"):
			gm.resetar_estado()

	# 2️⃣ Recarrega a cena do zero
	get_tree().reload_current_scene()

# -------------------------------
# DISPARO DE FUMAÇA
# -------------------------------
func shoot_fumaça():
	if not smoke_scene:
		return
	
	$SomExtintor.play()

	var fumaça = smoke_scene.instantiate()
	get_parent().add_child(fumaça)
	var offset = Vector2(40 * facing_dir, 10)
	fumaça.global_position = global_position + offset
	fumaça.direction = facing_dir
	fumaça.call_deferred("set_collision_layer_value", 1, false)
	fumaça.call_deferred("set_collision_mask_value", 1, false)

# -------------------------------
# EXTINTOR / SUPER
# -------------------------------
func do_super() -> void:
	if not super_power:
		super_power = true
		has_extintor = true
		speed += 50
		print("Extintor adquirido (modo super)!")
		$AnimatedSprite2D.play("super")
		$AnimatedSprite2D.frame = 0

# -------------------------------
# RESET POSIÇÃO APÓS QUEDA
# -------------------------------
func _reset_to_last_safe_position():
	print("Caiu do mapa! Voltando à última posição segura...")
	global_position = last_safe_position
	velocity = Vector2.ZERO

extends Area2D

@export var nome_extintor: String = ""  # Nome único para cada extintor (ex: "extintor_1")
@export var fall_gravity := 900.0
@export var bounce := 0.2
@export var floor_y := 500.0
var velocity := Vector2.ZERO


func _ready():
	add_to_group("extintor")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Se o extintor já foi pego em uma rodada anterior, some
	if nome_extintor in GameManager.extintores_pegos:
		queue_free()


func _physics_process(delta):
	# Aplica gravidade “visual”
	velocity.y += fall_gravity * delta
	global_position.y += velocity.y * delta

	# Impede que atravesse o chão
	if global_position.y >= floor_y:
		global_position.y = floor_y
		velocity.y = -velocity.y * bounce


func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Extintor coletado: %s" % nome_extintor)
		GameManager.registrar_extintor_pego(nome_extintor)
		body.do_super()
		queue_free()

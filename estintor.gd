extends Area2D

@export var fall_gravity := 900.0
@export var bounce := 0.2
@export var floor_y := 500.0
var velocity := Vector2.ZERO

func _ready():
	add_to_group("estintor")
	connect("body_entered", Callable(self, "_on_body_entered"))

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
		print("Extintor coletado!")
		body.do_super()
		queue_free()

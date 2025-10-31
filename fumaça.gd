extends CharacterBody2D

@export var speed := 400.0
@export var lifetime := 1.0
@export var direction: int = 1

var timer := 0.0

func _ready():
	# Movimento
	$AnimatedSprite2D.play()
	add_to_group("fumaça")

	# Conecta o detector de colisão fake
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))


func _physics_process(delta):
	# Movimento horizontal
	velocity.x = speed * direction
	move_and_slide()

	# Timer de vida
	timer += delta
	if timer >= lifetime:
		queue_free()


# Fake hitbox
func _on_body_entered(body):
	if not body:
		return

	# Ignora player
	if body.is_in_group("player"):
		return

	# Interação com fogo
	if body.is_in_group("fogo"):
		if body.has_method("apagar"):
			body.apagar()
		queue_free()
		return

	# Qualquer outro objeto remove a fumaça
	queue_free()

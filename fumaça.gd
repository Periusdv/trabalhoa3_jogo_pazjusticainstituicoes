extends CharacterBody2D

var speed := 400.0
var direction := 1
var lifetime := 1.0
var timer := 0.0

func _physics_process(delta):
	# Move horizontalmente
	var collision = move_and_collide(Vector2(speed * direction * delta, 0))
	
	# Detecta fogo
	if collision and collision.get_collider().is_in_group("fogo"):
		collision.get_collider().extinguish()
		queue_free()

	# Contador de vida
	timer += delta
	if timer >= lifetime:
		queue_free()

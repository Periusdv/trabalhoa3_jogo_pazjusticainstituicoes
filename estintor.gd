extends RigidBody2D

func _ready():
	# Opcional: impedir que ele gire quando cair
	add_to_group("estintor")
	freeze = false
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC

	# Conectar o sinal de colisão (se quiser automatizar)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Item coletado!")
		queue_free()  # remove o item

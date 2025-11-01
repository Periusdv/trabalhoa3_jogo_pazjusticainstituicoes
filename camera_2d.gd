extends Camera2D

@export var target: Node2D

func _process(delta):
	if target:
		# Atualiza apenas o eixo X (horizontal)
		global_position.x = target.global_position.x

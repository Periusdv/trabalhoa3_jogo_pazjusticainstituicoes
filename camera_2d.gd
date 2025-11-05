extends Camera2D

@export var suavidade := 5.0
@export var alvo: Node2D

func _process(delta):
	if not alvo:
		return
	var pos_alvo = alvo.global_position
	global_position = global_position.lerp(pos_alvo, suavidade * delta)

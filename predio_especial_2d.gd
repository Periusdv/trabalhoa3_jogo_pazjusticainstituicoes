extends Area2D

func _ready():
	add_to_group("predio_especial")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Fim de jogo!")
		get_tree().change_scene("res://FimDeJogo.tscn")  # substitua pelo caminho da tela de fim

extends CanvasLayer

@export var max_vidas: int = 3
var vidas: int = max_vidas

# Pega apenas os TextureRect, ignorando separadores
@onready var hearts := $HBoxContainer.get_children().filter(func(c): return c is TextureRect)

func atualizar_vidas(valor: int) -> void:
	vidas = clamp(valor, 0, max_vidas)
	for i in range(max_vidas):
		if i < hearts.size():
			hearts[i].visible = i < vidas

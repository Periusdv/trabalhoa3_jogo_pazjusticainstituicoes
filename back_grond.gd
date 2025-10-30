extends Node2D

@export var velocidade_fundo : float = 0.04  # ajuste conforme quiser
var shader_material : ShaderMaterial

func _ready():
	# Assumindo que o TextureRect é filho direto
	shader_material = $TextureRect.material as ShaderMaterial

func _process(delta):
	# Captura input horizontal do personagem
	var input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input != 0:
		# Atualiza o offset do shader, movendo da direita para esquerda
		shader_material.set_shader_parameter(
			"offset_x",
			shader_material.get_shader_parameter("offset_x") + input * velocidade_fundo * delta
		)

extends Node2D

@export var scroll_speed := 0.5

func _process(_delta):
	var player = get_node("../player") # ajusta o caminho do player
	if player:
		$TextureRect.material.set_shader_parameter("player_position", player.global_position / 1000.0)

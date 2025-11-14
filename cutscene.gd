extends Control

func _ready():
	$AnimationPlayer.play("scroll")

func start_game():
	get_tree().change_scene_to_file("res://world.tscn")

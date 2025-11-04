extends CanvasLayer

signal restart_game

@onready var btn_restart := $Button  # Caminho direto para o Button

func _ready():
	if btn_restart:
		btn_restart.pressed.connect(Callable(self, "_on_restart_pressed"))
	else:
		print("⚠️ Botão Reiniciar não encontrado!")

func _on_restart_pressed():
	emit_signal("restart_game")
	queue_free()  # Remove a tela de GameOver


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://title_screen.tscn")

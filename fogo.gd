extends StaticBody2D

@export var nome_fogo: String = ""
var apagado := false

func _ready():
	add_to_group("fogo")

	if nome_fogo == "":
		push_warning("Fogo sem nome definido!")
	
	if nome_fogo in GameManager.fogos_apagados:
		apagar_visual()
		apagado = true
	else:
		acender_visual()
		apagado = false


func apagar():
	if apagado:
		return
	apagado = true
	GameManager.registrar_fogo_apagado(nome_fogo)
	apagar_visual()


func acender():
	apagado = false
	acender_visual()


func apagar_visual():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.visible = false
	if has_node("CollisionShape2D"):
		await get_tree().process_frame
		$CollisionShape2D.disabled = true


func acender_visual():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play()
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = false


func apply_knockback_to_player(player):
	if apagado:
		return
	if not player or not player.has_method("apply_knockback"):
		return
	var dir = sign(player.global_position.x - global_position.x)
	var force = Vector2(dir * 800, -200)
	player.apply_knockback(force)

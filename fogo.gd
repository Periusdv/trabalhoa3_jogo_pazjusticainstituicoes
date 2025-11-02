extends StaticBody2D

# --- KNOCKBACK ---
var knockback_force := 800.0
var knockback_vertical := -200.0

func _ready():
	add_to_group("fogo")
	$AnimatedSprite2D.play()

# Método chamado quando o jogador encosta no fogo
func apply_knockback_to_player(player):
	if not player or not player.has_method("apply_knockback"):
		return

	# Calcula direção do empurrão
	var dir = sign(player.global_position.x - global_position.x)
	var force = Vector2(dir * knockback_force, knockback_vertical)
	player.apply_knockback(force)

	# Aplica dano (chama método do jogador)
	if player.has_method("tomar_dano"):
		player.tomar_dano()

# Método para apagar o fogo
func apagar():
	$AnimatedSprite2D.stop()
	queue_free()

func extinguish():
	apagar()

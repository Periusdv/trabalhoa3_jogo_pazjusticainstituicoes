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
	var dir = sign(player.global_position.x - global_position.x)
	var force = Vector2(dir * knockback_force, knockback_vertical)
	player.apply_knockback(force)

# Método para apagar o fogo (chamado pela fumaça)
func apagar():
	$AnimatedSprite2D.stop()  # Para a animação
	queue_free()                # Remove o fogo da cena

# Alias opcional se quiser manter o método antigo
func extinguish():
	apagar()

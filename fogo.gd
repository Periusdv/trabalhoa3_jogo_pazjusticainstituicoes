extends StaticBody2D

func _ready():
	add_to_group("fogo") # Grupo pra identificar o tipo do objeto
	$AnimatedSprite2D.play() # Toca a animação do fogo

func extinguish():
	$AnimatedSprite2D.stop()
	queue_free() # remove o fogo da cena (apagado)

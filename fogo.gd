extends StaticBody2D

func _ready():
	add_to_group("fogo")
	$AnimatedSprite2D.play()

func extinguish():
	$AnimatedSprite2D.stop()
	queue_free()

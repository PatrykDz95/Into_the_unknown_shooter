extends Area2D

func _on_bro_body_entered(body):
	if body.name == "Player":
		get_tree().queue_delete(self)



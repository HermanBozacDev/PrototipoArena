extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("hit")

func _animation_finish():
	hide()
	call_deferred("queue_free")

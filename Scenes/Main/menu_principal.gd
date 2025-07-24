extends Control


func _on_texture_button_pressed() -> void:
	get_node("/root/SceneHandler").StartMap()
	call_deferred("queue_free")

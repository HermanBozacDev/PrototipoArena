extends RigidBody2D

var name_skill = ""
var caster

var processed = false
var hit_effect = preload("res://Scenes/UI/HitFx.tscn")

func _ready() -> void:
	$AnimatedSprite2D.play(name_skill)


func _hit_fx():
	var hit_fx_instance =  hit_effect.instantiate()
	hit_fx_instance.position = global_position
	get_node("/root/SceneHandler/Arena").add_child(hit_fx_instance)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("data",area.get_parent().get_name())
	print("al fin",area.name)
	if caster != "enemy" and area.get_parent().get_name() == "Digimon":
		return
	if caster == "enemy" and area.get_parent().get_name() == "Enemy":
		pass
	if caster != "enemy" and area.get_parent().get_name() != "Digimon":
		hide()
		await get_tree().create_timer(0.5).timeout
		call_deferred("queue_free")
	if caster == "enemy" and area.get_parent().get_name() != "Enemy":
		hide()
		await get_tree().create_timer(0.5).timeout
		call_deferred("queue_free")

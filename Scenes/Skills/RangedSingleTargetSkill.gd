extends RigidBody2D

var name_skill = ""
var caster
func _ready() -> void:
	$AnimatedSprite2D.play(name_skill)



func _on_area_2d_body_entered(body: Node2D) -> void:
	print("AAAAAAAAAAA")
	self.hide()

extends StaticBody2D

@export var box_hp: int
var current_life: int


func _ready() -> void:
	%LifeBar.max_value = box_hp
	current_life = box_hp
	

func _process(delta: float) -> void:
	%LifeBar.value = current_life

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var node = area.get_parent()
	if node.processed == true:
		return
	node._hit_fx()
	node.hide()
	node.processed = true
	
	
	
	var skill_name = node.name_skill
	var damage = Data.skill_info.get(skill_name, {}).get("damage", 0)
	current_life -= damage
	if current_life <= 0:
		queue_free()
	node.call_deferred("queue_free")

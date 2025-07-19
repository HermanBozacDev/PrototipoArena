extends CharacterBody2D


var stuck_timer = 0.0
var last_position = Vector2.ZERO

@export var wander_range: float = 300.0
@export var speed: float = 100.0
@export var attack_range: float = 50.0
@export var vision_range: float = 1000.0

@onready var player = get_node("/root/Arena/Digimons/Digimon")

var state = "wander"
var target_position = Vector2.ZERO

var action_timer := 0.0  # cooldown general
var action_cooldown := 0.5  # tiempo entre decisiones

var enemy_cooldowns := {
	"Fireball": false,
	"Ice Spike": false,
	"Speed": false,
	"Heal": false
}

func _ready():
	last_position = global_position
	pick_new_wander_target()

func _process(delta):
	action_timer -= delta
	if action_timer <= 0:
		action_timer = action_cooldown
		match state:
			"wander":
				wander_behavior()
			"engage":
				engage_behavior()
	
	move_towards_target(delta)

	# detectar si está atascado
	if global_position.distance_to(last_position) < 5:
		stuck_timer += delta
		if stuck_timer > 2.0:
			#print("⚠ Enemy stuck, picking new wander target!")
			pick_new_wander_target()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0
	last_position = global_position
	
	
	
	
func wander_behavior():
	if can_see_player():
		state = "engage"
	elif is_at_target():
		pick_new_wander_target()

func engage_behavior():
	if not can_see_player():
		state = "wander"
		pick_new_wander_target()
		return

	var action = choose_action()
	#print("[ENEMY ACTION] →", action)
	match action:
		"idle":
			pass  # no hace nada este ciclo
		"approach":
			target_position = player.global_position
		"cast_skill":
			cast_random_skill()
		"wander":
			pick_new_wander_target()

func pick_new_wander_target():
	var random_offset = Vector2(randf_range(-wander_range, wander_range), randf_range(-wander_range, wander_range))
	target_position = global_position + random_offset

func is_at_target():
	return global_position.distance_to(target_position) < 5

func can_see_player():
	return global_position.distance_to(player.global_position) < vision_range

func choose_action():
	var actions = ["idle", "approach", "cast_skill", "wander"]
	actions.shuffle()
	return actions[0]

func move_towards_target(delta):
	if target_position == Vector2.ZERO:
		return
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func is_in_attack_range():
	return global_position.distance_to(player.global_position) < attack_range

func cast_random_skill():
	var available_skills = []
	for i in Data.powers:
		var skill_name = Data.powers[i]["name"]
		if not enemy_cooldowns[skill_name]:
			available_skills.append(skill_name)
	
	if available_skills.is_empty():
		return

	var chosen_skill = available_skills[randi() % available_skills.size()]
	#print("[ENEMY SKILL] →", chosen_skill)
	enemy_cooldowns[chosen_skill] = true

	get_tree().create_timer(Data.powers[get_skill_index(chosen_skill)]["cooldown"]).timeout.connect(func():
		enemy_cooldowns[chosen_skill] = false
	)

	match chosen_skill:
		"Fireball", "Ice Spike":
			launch_ranged_skill(chosen_skill)
		"Speed":
			await apply_speed_boost()
		"Heal":
			apply_heal()

func get_skill_index(skill_name):
	for i in Data.powers:
		if Data.powers[i]["name"] == skill_name:
			return i
	return 1

func apply_heal():
	var heal_amount = 30
	Data.enemy_data["current_hp"] += heal_amount
	if Data.enemy_data["current_hp"] > Data.enemy_data["max_hp"]:
		Data.enemy_data["current_hp"] = Data.enemy_data["max_hp"]
	#print("💚 Enemy healed to:", Data.enemy_data["current_hp"])

func apply_speed_boost():
	var original_speed = speed
	speed *= 2
	#print("💨 Speed boost activated!")
	await get_tree().create_timer(3.0).timeout
	speed = original_speed
	#print("⏳ Speed boost ended.")

func launch_ranged_skill(skill_name):
	var skill_scene = preload("res://Scenes/Skills/RangeSingleTargetskill.tscn")
	var skill_instance = skill_scene.instantiate()
	var direction = (player.global_position - global_position).normalized()
	skill_instance.global_position = global_position
	skill_instance.linear_velocity = direction * 500
	skill_instance.rotation = direction.angle()
	skill_instance.name_skill = skill_name
	skill_instance.caster = "enemy"
	get_tree().current_scene.add_child(skill_instance)

func apply_damage(amount):
	Data.enemy_data["current_hp"] -= amount
	if Data.enemy_data["current_hp"] < Data.enemy_data["min_hp"]:
		Data.enemy_data["current_hp"] = Data.enemy_data["min_hp"]
	#print("Enemy took", amount, "damage! Current HP:", Data.enemy_data["current_hp"])

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var skill_node = area.get_parent()
	if skill_node.caster == "enemy":
		return
	var damage = Data.skill_info.get(skill_node.name_skill, {}).get("damage", 0)
	#print(" Hurtbox hit by", skill_node.name_skill, "for", damage, "damage")
	apply_damage(damage)  #   apply_damage

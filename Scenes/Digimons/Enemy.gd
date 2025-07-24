extends CharacterBody2D


var stuck_timer = 0.0
var last_position = Vector2.ZERO

@export var wander_range: float = 300.0
@export var speed: float = 50.0
@export var attack_range: float = 50.0
@export var vision_range: float = 300.0

@onready var playerDetectionZone = $PlayerDetectionZone
@onready var player = get_node("/root/SceneHandler/Arena/Digimons/Digimon")
var cast_fx = preload("res://Scenes/UI/CastFx.tscn")


var action_timer := 0.0  # cooldown general
var action_cooldown := 0.5  # tiempo entre decisiones

var enemy_cooldowns := {
	"Fireball": false,
	"Ice Spike": false,
	"Speed": false,
	"Heal": false
}
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_mode = animation_tree.get("parameters/playback")
var last_anim_state = ""
var last_anim_dir = Vector2.ZERO
var state := "idle"
var target_position = Vector2.ZERO
var state_processing = false
func _ready():
	animation_mode.start("Idle")
	last_position = global_position
	pick_new_wander_target()
	


func pick_new_wander_target():
	var random_offset = Vector2(randf_range(-wander_range, wander_range), randf_range(-wander_range, wander_range))
	target_position = global_position + random_offset


func _process(delta):
	if state_processing == false:
		print("state",state)
		match state:
			"idle":
				handle_idle(delta)
			"wander":
				handle_wander(delta)
			"chase":
				handle_chase(delta)
		
	else:
		return
	




func handle_idle(delta):
	state_processing = true
	update_animation()
	await  get_tree().create_timer(0.5).timeout
	var new_state = choose_state()
	state = new_state
	state_processing = false
	

func handle_wander(delta):
	state_processing = true

	if target_position == Vector2.ZERO:
		pick_new_wander_target()

	while global_position.distance_to(target_position) > 5:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		if seek_player():
			return

		if get_slide_collision_count() > 0:
			print("⚠ Colisión detectada, cambiando dirección")
			pick_new_wander_target()
			await get_tree().process_frame
			continue

		update_animation()
		await get_tree().process_frame

	# ✔ Al llegar al destino
	velocity = Vector2.ZERO
	target_position = Vector2.ZERO

	# 🎲 20% de probabilidad de usar skill 3 o 4 si están disponibles
	if randi() % 100 < 20:
		var skills = ["Speed", "Heal"]
		skills = skills.filter(func(s): return not enemy_cooldowns[s])
		if not skills.is_empty():
			var chosen = skills[randi() % skills.size()]
			print("✨ Casteando habilidad en wander:", chosen)
			enemy_cooldowns[chosen] = true

			match chosen:
				"Speed":
					await apply_speed_boost()
				"Heal":
					apply_heal()

	await get_tree().create_timer(0.3).timeout
	state = choose_state()
	state_processing = false





func handle_chase(delta):
	state_processing = true

	while playerDetectionZone.can_see_player():
		var distance = global_position.distance_to(player.global_position)
		print("👣 Persiguiendo jugador. Distancia:", distance)

		if distance > 150:
			handle_chase_long_range()
		else:
			handle_chase_close_range()

		await get_tree().process_frame  # esperar un frame para evitar freeze

	print("❌ Jugador fuera de visión, volviendo a estado aleatorio")
	velocity = Vector2.ZERO
	target_position = Vector2.ZERO
	state = choose_state()
	state_processing = false




func handle_chase_long_range():
	# Usar skill 3 o 4 si están disponibles
	if not enemy_cooldowns["Speed"]:
		cast_random_skill_by_name("Speed")
	elif not enemy_cooldowns["Heal"]:
		cast_random_skill_by_name("Heal")
	else:
		# Acercarse al jugador si no se puede castear
		target_position = player.global_position
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		update_animation()

func handle_chase_close_range():
	# Usar skill 1 o 2 si están disponibles
	if not enemy_cooldowns["Fireball"]:
		cast_random_skill_by_name("Fireball")
	elif not enemy_cooldowns["Ice Spike"]:
		cast_random_skill_by_name("Ice Spike")
	else:
		# Esperar un poquito
		await get_tree().create_timer(0.3).timeout





func cast_random_skill_by_name(skill_name):
	if enemy_cooldowns[skill_name]:
		return

	enemy_cooldowns[skill_name] = true

	get_tree().create_timer(Data.powers[get_skill_index(skill_name)]["cooldown"]).timeout.connect(func():
		enemy_cooldowns[skill_name] = false
	)

	match skill_name:
		"Fireball", "Ice Spike":
			launch_ranged_skill(skill_name)
		"Speed":
			apply_speed_boost()
		"Heal":
			apply_heal()








func choose_state():
	var options = ["idle", "wander"]
	options.shuffle()
	return options[0]

func seek_player() -> bool:
	if playerDetectionZone.can_see_player():
		state = "chase"
		state_processing = false  # 🔁 IMPORTANTE: liberás el bloqueo del _process
		return true  # 🔁 le avisás al que llama que cambió de estado
	return false
	


func update_animation():
	var anim_vector = velocity.normalized()

	if state == "idle":
		animation_mode.travel("Idle")
		animation_tree.set("parameters/Idle/blend_position", anim_vector)


	elif state == "wander":
		animation_mode.travel("Walk")
		animation_tree.set("parameters/Walk/blend_position", anim_vector)




func get_skill_index(skill_name):
	for i in Data.powers:
		if Data.powers[i]["name"] == skill_name:
			return i
	return 1

func apply_heal():
	castFx()
	var heal_amount = 30
	Data.enemy_data["current_hp"] += heal_amount
	if Data.enemy_data["current_hp"] > Data.enemy_data["max_hp"]:
		Data.enemy_data["current_hp"] = Data.enemy_data["max_hp"]
	#print("💚 Enemy healed to:", Data.enemy_data["current_hp"])

func apply_speed_boost():
	castFx()
	var original_speed = speed
	
	speed *= 1.25
	
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
	castFx()
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
	skill_node._hit_fx()
	var damage = Data.skill_info.get(skill_node.name_skill, {}).get("damage", 0)
	#print(" Hurtbox hit by", skill_node.name_skill, "for", damage, "damage")
	apply_damage(damage)  #   apply_damage



func castFx():
	var cast_fx_instance = cast_fx.instantiate()
	add_child(cast_fx_instance)

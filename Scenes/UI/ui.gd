extends Control

@onready var player = get_node("/root/SceneHandler/Arena/Digimons/Digimon")
var skill_scene = preload("res://Scenes/Skills/RangeSingleTargetskill.tscn")
var cast_fx = preload("res://Scenes/UI/CastFx.tscn")


func _ready():
	%Timer1.timeout.connect(_on_timer1_timeout)
	%Timer2.timeout.connect(_on_timer2_timeout)
	%Timer3.timeout.connect(_on_timer3_timeout)
	%Timer4.timeout.connect(_on_timer4_timeout)

	%Skill1Cooldown.hide()
	%Skill2Cooldown.hide()
	%Skill3Cooldown.hide()
	%Skill4Cooldown.hide()
	
	%RoundsLabel.text = str(Data.rounds_won)


func _process(delta):
	if Data.cooldowns[1]:
		%Skill1.text = str(round(%Timer1.time_left))
	if Data.cooldowns[2]:
		%Skill2.text = str(round(%Timer2.time_left))
	if Data.cooldowns[3]:
		%Skill3.text = str(round(%Timer3.time_left))
	if Data.cooldowns[4]:
		%Skill4.text = str(round(%Timer4.time_left))

	update_health_bar(%PlayerBar, Data.player_data["current_hp"], Data.player_data["max_hp"])
	update_health_bar(%EnemyBar, Data.enemy_data["current_hp"], Data.enemy_data["max_hp"])

	if Data.in_battle:
		if Data.enemy_data["current_hp"] <= 0:
			on_enemy_defeated()
		elif Data.player_data["current_hp"] <= 0:
			on_player_defeated()

func on_enemy_defeated():
	print(" Ganaste la ronda!")
	Data.rounds_won += 1
	Data.in_battle = false
	await get_tree().create_timer(1.0).timeout
	restart_game()

func on_player_defeated():
	print(" Perdiste. Reiniciando progresión.")
	Data.rounds_won = 0
	Data.in_battle = false
	await get_tree().create_timer(1.0).timeout
	restart_game()




func restart_game():
	reset_combat_stats()
	get_node("/root/SceneHandler").ReloadMap()

	
func reset_combat_stats():
	Data.cooldowns = {
		1: false,
		2: false,
		3: false,
		4: false
	}
	Data.player_data["current_hp"] = Data.player_data["max_hp"]
	Data.enemy_data["current_hp"] = Data.enemy_data["max_hp"]




	Data.in_battle = true


func update_health_bar(bar: TextureProgressBar, current_hp: int, max_hp: int) -> void:
	bar.max_value = max_hp

	# Crear un Tween temporal para interpolar el valor
	var tween := create_tween()
	tween.tween_property(bar, "value", current_hp, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Cambiar color del progreso según porcentaje
	var percent := int((float(current_hp) / max_hp) * 100)
	if percent >= 60:
		bar.tint_progress = Color("14e114")  # verde
	elif percent >= 25:
		bar.tint_progress = Color("e1be32")  # amarillo
	else:
		bar.tint_progress = Color("e11e1e")  # rojo


func _on_button_1_pressed() -> void:
	if Data.cooldowns[1]:
		print("Poder 1 en cooldown")
		return
	print("Ejecutando flujo 1")
	launch_ranged_skill("Fireball")
	Data.cooldowns[1] = true
	
	%Skill1Cooldown.show()
	%Timer1.start(Data.powers[1]["cooldown"])

func _on_button_2_pressed() -> void:
	if Data.cooldowns[2]:
		print("Poder 2 en cooldown")
		return
	print("Ejecutando flujo 2")
	launch_ranged_skill("Ice Spike")
	Data.cooldowns[2] = true
	%Skill2Cooldown.show()
	%Timer2.start(Data.powers[2]["cooldown"])

func _on_button_3_pressed() -> void:
	if Data.cooldowns[3]:
		print("Poder 3 en cooldown")
		return
	print("Ejecutando flujo 3")
	launch_heal()
	Data.cooldowns[3] = true
	%Skill3Cooldown.show()
	%Timer3.start(Data.powers[3]["cooldown"])

func _on_button_4_pressed() -> void:
	if Data.cooldowns[4]:
		print("Poder 4 en cooldown")
		return
	print("Ejecutando flujo 4")
	launch_speed_up()
	Data.cooldowns[4] = true
	%Skill4Cooldown.show()
	%Timer4.start(Data.powers[4]["cooldown"])

func _on_timer1_timeout():
	Data.cooldowns[1] = false
	%Skill1Cooldown.hide()
	print("Poder 1 listo")

func _on_timer2_timeout():
	Data.cooldowns[2] = false
	%Skill2Cooldown.hide()
	print("Poder 2 listo")

func _on_timer3_timeout():
	Data.cooldowns[3] = false
	%Skill3Cooldown.hide()
	print("Poder 3 listo")

func _on_timer4_timeout():
	Data.cooldowns[4] = false
	%Skill4Cooldown.hide()
	print("Poder 4 listo")



func launch_heal():
	var mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	player.start_attack(mouse_position)
	castFx()
	await get_tree().create_timer(0.4).timeout
	var heal_amount = 30
	Data.player_data["current_hp"] += heal_amount
	if Data.player_data["current_hp"] > Data.player_data["max_hp"]:
		Data.player_data["current_hp"] = Data.player_data["max_hp"]
	print("💚 Player healed to:", Data.player_data["current_hp"])


func launch_speed_up():
	var mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	player.start_attack(mouse_position)
	castFx()
	await get_tree().create_timer(0.4).timeout
	player.max_speed = 125
	$SpeedUp.show()
	await get_tree().create_timer(3).timeout
	player.max_speed = 100
	$SpeedUp.hide()

func launch_ranged_skill(skill_name):
	var mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	player.start_attack(mouse_position)
	castFx()
	await get_tree().create_timer(0.4).timeout
	var skill_instance = skill_scene.instantiate()
	var start_position = player.global_position
	

	var direction = (mouse_position - start_position).normalized()
	
	skill_instance.global_position = start_position
	skill_instance.linear_velocity = direction * 500  # velocidad hardcodeada
	skill_instance.rotation = direction.angle() 
	skill_instance.name_skill = skill_name
	get_tree().current_scene.add_child(skill_instance)



func castFx():
	var cast_fx_instance = cast_fx.instantiate()
	add_child(cast_fx_instance)

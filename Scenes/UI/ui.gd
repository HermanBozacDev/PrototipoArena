extends Control

@onready var player = get_node("/root/Arena/Digimons/Digimon")
var skill_scene = preload("res://Scenes/Skills/RangeSingleTargetskill.tscn")

func _ready():
	%Timer1.timeout.connect(_on_timer1_timeout)
	%Timer2.timeout.connect(_on_timer2_timeout)
	%Timer3.timeout.connect(_on_timer3_timeout)
	%Timer4.timeout.connect(_on_timer4_timeout)

	%Skill1Cooldown.hide()
	%Skill2Cooldown.hide()
	%Skill3Cooldown.hide()
	%Skill4Cooldown.hide()



func _process(delta):
	if Data.cooldowns[1]:
		%Skill1.text = str(round(%Timer1.time_left))
	if Data.cooldowns[2]:
		%Skill2.text = str(round(%Timer2.time_left))
	if Data.cooldowns[3]:
		%Skill3.text = str(round(%Timer3.time_left))
	if Data.cooldowns[4]:
		%Skill4.text = str(round(%Timer4.time_left))

	# Actualizar barra de vida del jugador
	var current_hp = Data.player_data["current_hp"]
	var max_hp = Data.player_data["max_hp"]
	%Player.max_value = max_hp
	%Player.value = current_hp
	

	# Actualizar barra de vida del enemigo
	var enemy_hp = Data.enemy_data["current_hp"]
	var enemy_max_hp = Data.enemy_data["max_hp"]
	%Enemy.max_value = enemy_max_hp
	%Enemy.value = enemy_hp





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
	var heal_amount = 30
	Data.player_data["current_hp"] += heal_amount
	if Data.player_data["current_hp"] > Data.player_data["max_hp"]:
		Data.player_data["current_hp"] = Data.player_data["max_hp"]
	print("💚 Player healed to:", Data.player_data["current_hp"])


func launch_speed_up():
	player.max_speed = 200
	$SpeedUp.show()
	await get_tree().create_timer(3).timeout
	player.max_speed = 100
	$SpeedUp.hide()

func launch_ranged_skill(skill_name):
	var skill_instance = skill_scene.instantiate()
	var start_position = player.global_position
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - start_position).normalized()
	
	skill_instance.global_position = start_position
	skill_instance.linear_velocity = direction * 500  # velocidad hardcodeada
	skill_instance.rotation = direction.angle() 
	skill_instance.name_skill = skill_name
	get_tree().current_scene.add_child(skill_instance)

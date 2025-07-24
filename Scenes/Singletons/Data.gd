extends Node

# Diccionario con los poderes
var powers := {
	1: {"name": "Fireball", "cooldown": 3.0},
	2: {"name": "Ice Spike", "cooldown": 2.0},
	3: {"name": "Speed", "cooldown": 6.0},
	4: {"name": "Heal", "cooldown": 12.0},
}

# Estado actual de cooldown
var cooldowns := {
	1: false,
	2: false,
	3: false,
	4: false,
}

var skill_info := {
	"Fireball": {"damage": 20},
	"Ice Spike": {"damage": 10}
}


var player_data := {
	"current_hp": 100,
	"min_hp": 0,
	"max_hp": 100
}

var enemy_data := {
	"current_hp": 100,
	"min_hp": 0,
	"max_hp": 100,
}



var rounds_won = 0
var in_battle = true

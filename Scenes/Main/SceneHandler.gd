extends Node

var arena = preload("res://Scenes/Map/arena.tscn")
var menu_principal = preload("res://Scenes/Main/MenuPrincipal.tscn")




func _ready() -> void:
	var menu_instance = menu_principal.instantiate()
	add_child(menu_instance)


func StartMap():
	var arena_instance = arena.instantiate()
	add_child(arena_instance)

func ReloadMap():
	for node in get_tree().get_nodes_in_group("Map"):
		node.queue_free()
	await get_tree().create_timer(0.1).timeout
	StartMap()

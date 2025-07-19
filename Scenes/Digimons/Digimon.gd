extends CharacterBody2D

# Estados
enum {
	MOVE,
	IDLE
}

# Variables exportadas
@export var max_speed: float = 100.0

# Variables internas
var destination: Vector2
var moving: bool = false
var move_direction: float = 0.0  # En grados
var anim_direction: String = "S"
var anim_mode: String = "Idle"
var state := IDLE

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	destination = global_position

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		destination = get_global_mouse_position()
		moving = true
		state = MOVE

func _physics_process(delta):
	match state:
		MOVE:
			move_towards_destination()
			update_animation_direction()
			play_animation()
		IDLE:
			anim_mode = "Idle"
			play_animation()
			velocity = Vector2.ZERO

func move_towards_destination():
	var distance = global_position.distance_to(destination)
	if distance > 5:
		var direction = (destination - global_position).normalized()
		move_direction = rad_to_deg(direction.angle())
		velocity = direction * max_speed
		move_and_slide()
		anim_mode = "Walk"
	else:
		moving = false
		state = IDLE

func update_animation_direction():
	if move_direction <= 45 and move_direction >= -45:
		anim_direction = "E"
	elif move_direction <= 135 and move_direction > 45:
		anim_direction = "S"
	elif move_direction >= -135 and move_direction < -45:
		anim_direction = "N"
	else:
		anim_direction = "W"

func play_animation():
	var animation_name = anim_mode + "_" + anim_direction
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

func apply_damage(amount):
	Data.player_data["current_hp"] -= amount
	if Data.player_data["current_hp"] < Data.player_data["min_hp"]:
		Data.player_data["current_hp"] = Data.player_data["min_hp"]
	#print(" Player took", amount, "damage! Current HP:", Data.player_data["current_hp"])


func _on_hurtbox_area_entered(area: Area2D) -> void:
	var skill_node = area.get_parent()
	if skill_node.caster != "enemy":
		return
	var damage = Data.skill_info.get(skill_node.name_skill, {}).get("damage", 0)
	#print(" Player hit by", skill_node.name_skill, "for", damage, "damage")

	apply_damage(damage)

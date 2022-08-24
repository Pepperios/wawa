extends Spatial
onready var camera = $Camera
onready var pillars = $Pillars
var current_card_selected
var current_pillar

func _ready():
	visible = false
	GameEvents.connect("draw_starting_hand", self, "on_show_game")
	GameEvents.connect("adjust_camera_angle", self, "on_adjust_camera_angle")
	GameEvents.connect("on_current_card_selected", self, "on_on_current_card_selected")
	GameEvents.connect("on_player_one", self, "on_player_one_start")
	GameEvents.connect("unit_placed", self, "on_unit_placed")
	GameEvents.connect("enemy_unit_placed", self, "on_unit_placed")
	GameEvents.connect("move_units", self, "on_move_units")
	
func on_show_game():
	visible = true
	
func on_adjust_camera_angle():
	
	camera.rotation_degrees.z = 180
	camera.translation.z = 1.3
	
	for pillar in pillars.get_children():
		var child = pillar.get_node("9")
		child.connect("mouse_entered", self, "on_pillar_entered", [child])
		child.connect("mouse_exited", self, "on_pillar_exited")
		
func on_player_one_start():
	
	for pillar in pillars.get_children():
		var child = pillar.get_node("1")
		child.connect("mouse_entered", self, "on_pillar_entered", [child])
		child.connect("mouse_exited", self, "on_pillar_exited")
	
func on_pillar_entered(pillar):
	current_pillar = pillar
	
func on_pillar_exited():
	current_pillar = null
	
func _process(_delta):
	check_if_unit_can_be_placed()
	
func on_on_current_card_selected(card):
	current_card_selected = card
	
func check_if_unit_can_be_placed():
	
	if Input.is_action_just_pressed("MLEFT"):
		
		if current_pillar:
			if current_pillar.get_node("Unit").get_child_count() == 0:
				if current_card_selected:
					if current_card_selected.type == "Unit":
						var pillar_path = get_pillar_path(current_pillar)
						Server.check_if_player_has_enough_mana(current_card_selected, pillar_path)
						
func get_pillar_path(_pillar):
	var line = _pillar.name 
	var lane = _pillar.get_parent().name 
	
	var pillar_path = [lane, line]
	return pillar_path

func on_unit_placed(card, pillar_path):
	
	var get_path = "Pillars/%s/%s/Unit" % [pillar_path[0], pillar_path[1]]
	var load_path = NodePath(get_path)
	var UnitNode = get_node(load_path)
	
	var get_path2 = "res://models/in_play/%s.tscn" % card.id
	var unit_path = load(get_path2)
	var unit = unit_path.instance()
	
	UnitNode.add_child(unit)
	
func on_move_units(on_all_fields):
	
	for i in pillars.get_children():
		for j in i.get_children():
			var x = j.get_node("Unit")
			if x.get_child_count() > 0:
				for child in x.get_children():
					child.queue_free()
					
	for i in on_all_fields:
		if i:
			if i.size() > 0:
				for j in i:
					if j:
						if j.size() > 0:
							if i == on_all_fields[0]:
								on_unit_placed(j[0], j[1])
							elif i == on_all_fields[1]:
								on_unit_placed(j[0], j[1])

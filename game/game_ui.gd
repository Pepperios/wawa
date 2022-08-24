extends Control

onready var container = $HBoxContainer
onready var passTurnBtn = $PassTurnButton
onready var energyDisplay = $Hero/HeroRect/Label
onready var energyDisplayEnemy = $Hero/EnemyHeroRect/Label
onready var enemyContainer = $EnemyContainer
onready var HeroRect = $Hero/HeroRect
onready var EnemyHeroRect = $Hero/EnemyHeroRect

var current_card_selected
var default_color = Color8(255, 255, 255, 255)
var grey_color = Color8(45, 45, 45, 255)

func _ready():
	visible = false
	GameEvents.connect("start_game_phase", self, "on_start_game_phase")
	GameEvents.connect("hand_data", self, "on_receive_hand_data")
	GameEvents.connect("draw_card", self, "on_receive_new_card")
	GameEvents.connect("on_start_game_is_player_one", self, "on_is_player_one")
	GameEvents.connect("turn_start", self, "on_turn_start")
	GameEvents.connect("update_energy", self, "on_update_energy")
	GameEvents.connect("add_enemy_card", self, "on_add_enemy_card")
	GameEvents.connect("unit_placed", self, "on_unit_placed")
	GameEvents.connect("remove_enemy_card", self, "on_remove_enemy_card")
	GameEvents.connect("update_self_energy_during_turn", self, "on_update_self_energy_during_turn")
	GameEvents.connect("update_enemy_energy_during_turn", self, "on_update_enemy_energy_during_turn")
	GameEvents.connect("adjust_camera_angle", self, "on_is_player_two")
	
func on_is_player_two():

	var get_enemy_hero_rect = preload("res://images/sprites/Temporary_Crab_Hero_Enemy.png")
	var get_hero_rect = preload("res://images/sprites/Temporary_Palm_Hero.png")
	
	HeroRect.set_texture(get_hero_rect)
	EnemyHeroRect.set_texture(get_enemy_hero_rect)

func on_start_game_phase():
	visible = true
	Server.receive_hand_data()
	Server.check_if_player_two()
	
func on_receive_hand_data(hand):
	for card in hand:
		draw_card_in_hand(card)
	
func draw_card_in_hand(card):
	
	var texture_button = TextureButton.new()
	container.add_child(texture_button)
	texture_button.connect("pressed", self, "on_card_pressed", [texture_button, card])
	var get_texture = "res://images/in_hand/%s.png" % card.id
	var load_texture = load(get_texture)
	texture_button.set_normal_texture(load_texture)
	add_stats_label_to_card(texture_button, card)
	
func add_stats_label_to_card(button, card):
	
	var new_label = Label.new()
	var card_stats: String
	button.add_child(new_label)
   
	if card.type == "Unit":
		card_stats = "  %s                         %s\n\n\n\n\n   %s                       %s" % [card.energy, card.spd, card.att, card.hp]
	else:
		card_stats = "  %s" % card.energy

	var new_label_theme_loaded = preload("res://ui_elements/themes/DynaPuffOutline2.tres")
	new_label.set_theme(new_label_theme_loaded)
	new_label.rect_position.x = 6.5
	new_label.rect_position.y = 5
	new_label.text = card_stats
	add_name_label_to_deck_list(button, card)
	add_clan_label_to_deck_list(button, card)
	
func add_name_label_to_deck_list(button, card):
	
	var new_label = Label.new()
	button.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/Lobster-Regular.tres")
	new_label.set_theme(new_label_theme_loaded)

	new_label.set_align(Label.ALIGN_CENTER)
	new_label.set_valign(Label.ALIGN_CENTER)

	new_label.text = "%s" % card.clan
	new_label.rect_size.x = 150
	new_label.rect_position.y = 136
	
func add_clan_label_to_deck_list(button, card):
	
	var new_label = Label.new()
	button.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/Lobster-Regular.tres")
	new_label.set_theme(new_label_theme_loaded)
	
	new_label.set_align(Label.ALIGN_CENTER)
	new_label.set_valign(Label.ALIGN_CENTER)
	
	new_label.text = "%s" % card.name
	new_label.rect_size.x = 150
	new_label.rect_position.y = 268

	add_text_label_to_deck_list(button, card)
	
func add_text_label_to_deck_list(button, card):
	
	var new_label = Label.new()
	button.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/OpenSans.tres")
	new_label.set_theme(new_label_theme_loaded)
	new_label.set_align(Label.ALIGN_CENTER)
	new_label.autowrap = true
	new_label.rect_position.y = 171.5
	new_label.rect_position.x = 15
	new_label.rect_size.x = 120
	new_label.rect_size.y = 90
	
	if card.id == "0028" or card.id == "0029":
		var new_label_theme_load = preload("res://ui_elements/themes/OpenSansFontSmaller.tres")
		new_label.set_theme(new_label_theme_load)
	
	new_label.text = "%s" % card.text
	
func on_receive_new_card(card):
	
	if container.get_child_count() < 10:
		draw_card_in_hand(card)
	
func _on_PassTurnButton_pressed():
	
	current_card_selected = null
	passTurnBtn.disabled = true
	passTurnBtn.set_modulate(grey_color)
	
	for child in container.get_children():
		child.disabled = true
		child.set_modulate(grey_color)
		
	Server.pass_turn()
	GameEvents.emit_signal("on_current_card_selected", current_card_selected)
	
func on_is_player_one(player):
	
	if player == false:
		_on_PassTurnButton_pressed()

func on_turn_start(global, current):
	
	Server.draw_card()
	passTurnBtn.disabled = false
	passTurnBtn.set_modulate(default_color)
	energyDisplayEnemy.text = "%s/%s" % [global, current]
	energyDisplay.text = "%s/%s" % [global, current]
	
	for child in container.get_children():
		child.disabled = false
		child.set_modulate(default_color)
		
func on_update_energy(global, current):
	energyDisplayEnemy.text = "%s/%s" % [current, global]
	energyDisplay.text = "%s/%s" % [current, global]

func on_update_self_energy_during_turn(global, current):
	energyDisplay.text = "%s/%s" % [current, global]

func on_update_enemy_energy_during_turn(global, current):
	energyDisplayEnemy.text = "%s/%s" % [current, global]

func on_card_pressed(button, card):
	
	for child in container.get_children():
		child.set_modulate(default_color)
		
	if current_card_selected == card:
		button.set_modulate(default_color)
		current_card_selected = null
	else:
		button.set_modulate(grey_color)
		current_card_selected = card
	
	GameEvents.emit_signal("on_current_card_selected", current_card_selected)
	
func on_add_enemy_card(num):
	
	for _i in range(num):
		if enemyContainer.get_child_count() < 10:
			var enemy_card = TextureRect.new()
			enemyContainer.add_child(enemy_card)
			var get_texture = preload("res://images/in_hand/card_back_template.png")
			enemy_card.set_texture(get_texture)

func on_unit_placed(card, _pillar):
	
	for child in container.get_children():
		var get_texture: StreamTexture = child.get_normal_texture()
		var load_path = get_texture.get_load_path()
		var substr = load_path.substr(14, 4)
		if substr == card.id:
			child.queue_free()
			break
		
func on_remove_enemy_card(num):
	
	for _i in range(num):
		var card = enemyContainer.get_child(0)
		card.queue_free()

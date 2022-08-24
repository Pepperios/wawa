extends Control
onready var container = $HBoxContainer
onready var ReadyButton = $ReadyButton
var grey_color = Color8(45, 45, 45, 255)
var start_game_phase_wait_time: float = 0.1

func _ready():
	visible = false
	GameEvents.connect("display_starting_hand", self, "on_show_starting_hand")
	GameEvents.connect("draw_starting_hand", self, "on_draw_starting_hand")
	GameEvents.connect("card_switched", self, "on_card_received")
	GameEvents.connect("start_game_phase_countdown", self, "on_start_game_phase_countdown")
	GameEvents.connect("fourth_card_received", self, "on_fourth_card_received")
	
func on_draw_starting_hand():
	visible = true
	Server.give_player_starting_hand()
	
func on_show_starting_hand(hand):
	
	for card in hand:
		on_display_card(card)
	
func on_display_card(card):
	
	var txbtn: TextureButton = TextureButton.new()
	container.add_child(txbtn)
	
	if container.get_child_count() > 3:
		txbtn.set_modulate(grey_color)
		txbtn.disabled = true
	else:
		txbtn.connect("pressed", self, "on_card_switched", [container.get_child_count() - 1, card])
	
	var get_texture = "res://images/in_hand/%s.png" % card.id
	var load_texture = load(get_texture)
	txbtn.set_normal_texture(load_texture)
	
	display_stats(card, txbtn)
	
func display_stats(card, txbtn):
	
	var new_label = Label.new()
	new_label.name = "Stats"
	var card_stats: String
	txbtn.add_child(new_label)
   
	if card.type == "Unit":
		card_stats = "  %s                         %s\n\n\n\n\n   %s                       %s" % [card.energy, card.spd, card.att, card.hp]
	else:
		card_stats = "  %s" % card.energy
	
	new_label.rect_position.x = 6.5
	new_label.rect_position.y = 5
	
	var new_label_theme = "res://ui_elements/themes/DynaPuffOutline2.tres"
	var new_label_theme_loaded = load(new_label_theme)
	new_label.set_theme(new_label_theme_loaded)

	new_label.text = card_stats
	
	display_clan(card, txbtn)
	
func display_clan(card, txbtn):
	
	var new_label = Label.new()
	new_label.name = "Clan"
	txbtn.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/Lobster-Regular.tres")
	new_label.set_theme(new_label_theme_loaded)

	new_label.set_align(Label.ALIGN_CENTER)
	new_label.set_valign(Label.ALIGN_CENTER)

	new_label.text = "%s" % card.clan
	new_label.rect_size.x = 150
	new_label.rect_position.y = 136
	display_name(card, txbtn)
	
func display_name(card, txbtn):
	
	var new_label = Label.new()
	new_label.name = "Name"
	txbtn.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/Lobster-Regular.tres")
	new_label.set_theme(new_label_theme_loaded)
	
	new_label.set_align(Label.ALIGN_CENTER)
	new_label.set_valign(Label.ALIGN_CENTER)
	
	new_label.text = "%s" % card.name
	new_label.rect_size.x = 150
	new_label.rect_position.y = 268

	add_text_label_to_deck_list(txbtn, card)
	
func add_text_label_to_deck_list(txbtn, card):
	
	var new_label = Label.new()
	txbtn.add_child(new_label)
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
	
func on_card_switched(button, card):
	Server.on_card_switched(button, card)
	
func on_card_received(card, button):
	
	var real_button = container.get_child(button)
	real_button.disabled = true
	real_button.set_modulate(grey_color)
	
	var Stats = real_button.get_node("Stats")
	var card_stats
	
	if card.type == "Unit":
		card_stats = "  %s                         %s\n\n\n\n\n   %s                       %s" % [card.energy, card.spd, card.att, card.hp]
	else:
		card_stats = "  %s" % card.energy
		
	Stats.text = card_stats
	
	var Clan = real_button.get_node("Clan")
	Clan.text = "%s" % card.clan
	
	var Name = real_button.get_node("Name")
	Name.text = "%s" % card.name
		
	var get_texture = "res://images/in_hand/%s.png" % card.id
	var load_texture = load(get_texture)
	real_button.set_normal_texture(load_texture)

func _on_ReadyButton_pressed():
	ReadyButton.disabled = true
	ReadyButton.set_modulate(grey_color)
	
	for child in container.get_children():
		child.disabled = true
		child.set_modulate(grey_color)
		
	Server.player_ready()
	
func on_start_game_phase_countdown():
	
	var new_label: Label = Label.new()
	var timer = Timer.new()
	
	add_child(new_label)
	var get_theme = preload("res://ui_elements/themes/Lobster-Regular-Big.tres")
	new_label.set_theme(get_theme)
	new_label.text = "GAME STARTING IN 3 SECONDS"
	new_label.rect_position.y = -300
	new_label.rect_position.x = -331
	
	add_child(timer)
	timer.set_wait_time(start_game_phase_wait_time)
	timer.set_one_shot(true)
	timer.start()
	
	for child in container.get_children():
		child.disabled = true
		child.set_modulate(grey_color)
	
	timer.connect("timeout", self, "on_timer_timeout", [timer, new_label])
	Server.get_player_two_fourth_card()

func on_timer_timeout(timer, new_label):
	visible = false
	GameEvents.emit_signal("start_game_phase")
	
	for child in container.get_children():
		child.queue_free()
	
	new_label.queue_free()
	timer.queue_free()
	
func on_fourth_card_received(card):
	on_display_card(card)

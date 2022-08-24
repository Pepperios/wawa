extends Control

onready var MenuSelectDeck = $MenuSelectDeck
onready var CardsInClan = $CardsInClan
onready var ClanCardContainer = $CardsInClan/ClanCardContainer
onready var CardCounterLabel = $DeckOnDisplay/CardCounterLabel
onready var DeckOnDisplay = $DeckOnDisplay
onready var DeckOnDisplayContainer = $DeckOnDisplay/ScrollContainer/DeckOnDisplayContainer
onready var DeckMenu: TextureRect = $DeckMenu

onready var no_deck_but_builder: StreamTexture = preload("res://images/background/no_deck_but_builder.png")
onready var no_deck: StreamTexture = preload("res://images/background/no_deck.png")
onready var deck_builder: StreamTexture = preload("res://images/background/deck_builder.png")
onready var outside_of_deck_builder: StreamTexture = preload("res://images/background/outside_of_deck_builder.png")

var player_deck: Array

func _ready():
	
	CardCounterLabel.visible = false
	CardsInClan.visible = false
	visible = false
	ButtonEvents.connect("create_deck_button_pressed", self, "on_create_deck_button_pressed")

func _on_MainMenu_pressed():
	visible = false
	ButtonEvents.emit_signal("main_menu_button_pressed", player_deck)
	
func on_create_deck_button_pressed():
	visible = true
	MenuSelectDeck.visible = true
	DeckOnDisplay.visible = true

func _on_ClearDeck_pressed():
	player_deck.clear()
	
	for child in DeckOnDisplayContainer.get_children():
		child.queue_free()

	refresh_cardcounterlabel()
	DeckMenu.set_texture(no_deck)
	CardCounterLabel.visible = false

func _on_PalmDeck_pressed():
	
	MenuSelectDeck.visible = false
	CardsInClan.visible = true
	create_deck_list("Palm")

func _on_CrabDeck_pressed():
	
	MenuSelectDeck.visible = false
	CardsInClan.visible = true
	create_deck_list("Crab")
	
func _on_BackToMenuButton_pressed():
	MenuSelectDeck.visible = true
	CardsInClan.visible = false
	
	if DeckOnDisplayContainer.get_child_count() > 0:
		DeckMenu.set_texture(outside_of_deck_builder)
		CardCounterLabel.visible = true
	else:
		DeckMenu.set_texture(no_deck)
		CardCounterLabel.visible = false
	
	for child in ClanCardContainer.get_children():
		child.queue_free()
	
func create_deck_list(type):
	
	if DeckOnDisplayContainer.get_child_count() > 0:
		DeckMenu.set_texture(deck_builder)
		CardCounterLabel.visible = true
	else:
		DeckMenu.set_texture(no_deck_but_builder)
		CardCounterLabel.visible = false
	
	for card in DeckManager.all_cards:
		if card.clan == type:
			add_to_deck_list(card)
			
func add_to_deck_list(card):
	
	var texture_button = TextureButton.new()
	ClanCardContainer.add_child(texture_button)
	var get_texture = "res://images/in_hand/%s.png" % card.id
	var load_texture = load(get_texture)
	texture_button.set_normal_texture(load_texture)
	texture_button.connect("pressed", self, "on_card_in_deck_list_pressed", [card])
	add_stats_label_to_deck_list(texture_button, card)

func add_stats_label_to_deck_list(texture_button, card):
	
	var new_label = Label.new()
	var card_stats: String
	texture_button.add_child(new_label)
   
	if card.type == "Unit":
		card_stats = "  %s                         %s\n\n\n\n\n   %s                       %s" % [card.energy, card.spd, card.att, card.hp]
	else:
		card_stats = "  %s" % card.energy
	
	new_label.rect_position.x = 6.5
	new_label.rect_position.y = 5
	new_label.text = card_stats
	add_name_label_to_deck_list(texture_button, card)
	add_clan_label_to_deck_list(texture_button, card)
	add_text_label_to_deck_list(texture_button, card)
	
func add_text_label_to_deck_list(texture_button, card):
	var new_label = Label.new()
	texture_button.add_child(new_label)
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
	
func add_clan_label_to_deck_list(texture_button, card):
	var new_label = Label.new()
	texture_button.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/Lobster-Regular.tres")
	new_label.set_theme(new_label_theme_loaded)

	new_label.set_align(Label.ALIGN_CENTER)
	new_label.set_valign(Label.ALIGN_CENTER)

	new_label.text = "%s" % card.clan
	new_label.rect_size.x = 150
	new_label.rect_position.y = 136

func add_name_label_to_deck_list(texture_button, card):
	var new_label = Label.new()
	texture_button.add_child(new_label)
	var new_label_theme_loaded = preload("res://ui_elements/themes/Lobster-Regular.tres")
	new_label.set_theme(new_label_theme_loaded)
	
	new_label.set_align(Label.ALIGN_CENTER)
	new_label.set_valign(Label.ALIGN_CENTER)
	
	new_label.text = "%s" % card.name
	new_label.rect_size.x = 150
	new_label.rect_position.y = 268
	
func on_card_in_deck_list_pressed(card):
	check_if_card_can_be_added_to_deck_display(card)
	
func check_if_card_can_be_added_to_deck_display(card):
	
	var how_many_number: int
	
	if player_deck.size() < 40:
		if card.rarity == "Legendary":
			how_many_number = 1
		elif card.rarity == "Epic":
			how_many_number = 2
		elif card.rarity == "Rare":
			how_many_number = 3
		elif card.rarity == "Common":
			how_many_number = 4
		elif card.rarity == "Scrap":
			how_many_number = 0
			
		if player_deck.count(card) < how_many_number:
			player_deck.append(card)
			refresh_cardcounterlabel()
			add_card_to_display(card)
			DeckMenu.set_texture(deck_builder)
			CardCounterLabel.visible = true
		
func refresh_cardcounterlabel():
	CardCounterLabel.text = "%s/40" % player_deck.size()
	
func add_card_to_display(card):
	
	var texture_button = TextureButton.new()

	DeckOnDisplayContainer.add_child(texture_button)
	var get_texture = "res://images/in_deck/%s.png" % card.id
	var load_texture = load(get_texture)
	texture_button.set_normal_texture(load_texture)
	texture_button.connect("pressed", self, "on_card_in_display_pressed", [texture_button, card])
	add_label_to_card_on_display(texture_button, card)
	
func add_label_to_card_on_display(texture_button, card):
	var new_label = Label.new()
	texture_button.add_child(new_label)
	new_label.rect_position.y = 10
	new_label.rect_position.x = 5
	new_label.text = "%s" % card.name
	
func on_card_in_display_pressed(texture_button, card):
	
	player_deck.erase(card)
	texture_button.queue_free()
	
	if DeckOnDisplayContainer.get_child_count() == 1:
		if DeckMenu.get_texture() == deck_builder:
			DeckMenu.set_texture(no_deck_but_builder)
		else:
			DeckMenu.set_texture(no_deck)
			
		CardCounterLabel.visible = false
	refresh_cardcounterlabel()
	
func _on_BaseDeck_pressed():
	
	for card_id in DeckManager.base_deck:
		for card in DeckManager.all_cards:
			if card_id == card.id:
				check_if_card_can_be_added_to_deck_display(card)
				
	DeckMenu.set_texture(outside_of_deck_builder)


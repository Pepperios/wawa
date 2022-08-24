extends Control
var can_game_be_started = false
var player_deck: Array

func _ready():
	ButtonEvents.connect("main_menu_button_pressed", self, "on_main_menu_button_pressed")
	visible = true
	
func _on_CreateDeckButton_pressed():
	visible = false
	ButtonEvents.emit_signal("create_deck_button_pressed")
	
func on_main_menu_button_pressed(current_deck):
	visible = true
	
	player_deck = current_deck
	
	if current_deck.size() == 40:
		can_game_be_started = true
	else:
		can_game_be_started = false
	
func _on_QuitGameButton_pressed():
	get_tree().quit()

func _on_PlayGameButton_pressed():
	
	if can_game_be_started:
		DeckManager.player_deck = player_deck
		visible = false
		GameEvents.emit_signal("start_online_lobby")

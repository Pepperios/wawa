extends Node

onready var lobby = get_parent().get_node("main/Lobby")
var network = NetworkedMultiplayerENet.new()
var ip = "25.72.112.248"
var port = 1909

func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "on_connection_failed")
	network.connect("connection_succeeded", self, "on_connection_succeeded")
	
func on_connection_succeeded():
	GameEvents.emit_signal("connected_to_server")
	
func sanity_check_player_deck():
	rpc_id(1, "on_sanity_check_player_deck", DeckManager.player_deck)
	
func on_connection_failed():
	print("Not connected")

remote func StartLobby():
	lobby.on_sanity_check_complete()
	
remote func EndLobbyPhase():
	lobby.EndLobbyPhase()
	
func give_player_starting_hand():
	rpc_id(1, "give_player_starting_hand")
	
func on_card_switched(button, card):
	rpc_id(1, "on_card_switched", button, card)
	
func player_ready():
	rpc_id(1, "player_ready")
	
remote func starting_hand_display(hand):
	GameEvents.emit_signal("display_starting_hand", hand)

remote func on_card_switched_done(card, button):
	GameEvents.emit_signal("card_switched", card, button)
	
remote func StartGamePhase():
	GameEvents.emit_signal("start_game_phase_countdown")
	
func get_player_two_fourth_card():
	rpc_id(1, "get_player_two_fourth_card")
	
remote func player_two_receive_fourth_card(card):
	GameEvents.emit_signal("fourth_card_received", card)
	
func receive_hand_data():
	rpc_id(1, "get_player_hand_data")
	
remote func return_hand_data(hand):
	GameEvents.emit_signal("hand_data", hand)
	
func check_if_player_two():
	rpc_id(1, "check_if_player_two")
	
remote func is_player_one(player):
	GameEvents.emit_signal("on_start_game_is_player_one", player)
	
func pass_turn():
	rpc_id(1, "pass_turn")

remote func start_turn(global_energy, current_energy):
	GameEvents.emit_signal("turn_start", global_energy, current_energy)

remote func when_passed_update_energy(global, current):
	GameEvents.emit_signal("update_energy", global, current)
	
func draw_card():
	rpc_id(1, "draw_card")
	
remote func draw_card_receive(card):
	GameEvents.emit_signal("draw_card", card)
	
remote func add_enemy_card(num):
	GameEvents.emit_signal("add_enemy_card", num)
	
remote func receive_if_player_two_to_adjust_camera_angle():
	GameEvents.emit_signal("adjust_camera_angle")
	
remote func if_player_is_one():
	GameEvents.emit_signal("on_player_one")
	
func check_if_player_has_enough_mana(card, pillar):
	rpc_id(1, "check_if_player_has_enough_mana", card, pillar)

remote func unit_has_enough_mana(card, pillar):
	GameEvents.emit_signal("unit_placed", card, pillar) 

remote func remove_enemy_card_from_ui(num):
	GameEvents.emit_signal("remove_enemy_card", num)
	
remote func on_update_enemy_energy_during_turn(global, current):
	GameEvents.emit_signal("update_enemy_energy_during_turn", global, current)
	
remote func on_update_energy_during_turn(global, current):
	GameEvents.emit_signal("update_self_energy_during_turn", global, current)

remote func enemy_unit_placed(card, pillar):
	GameEvents.emit_signal("enemy_unit_placed", card, pillar)
	
remote func move_units(on_all_fields):
	GameEvents.emit_signal("move_units", on_all_fields)

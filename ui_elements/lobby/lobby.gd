extends Control

func _ready():
	visible = false
	GameEvents.connect("start_online_lobby", self, "start_lobby")
	GameEvents.connect("connected_to_server", self, "on_connected_to_server")
	
func start_lobby():
	visible = true
	Server.connect_to_server()

func on_connected_to_server():
	Server.sanity_check_player_deck()
	
func on_sanity_check_complete():
	pass
	
func EndLobbyPhase():
	visible = false
	GameEvents.emit_signal("draw_starting_hand")

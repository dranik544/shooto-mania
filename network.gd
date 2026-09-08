extends Node

var IPadress: String = "localhost"
var port: int = 5454
var myNickname: String = ""

var inGame: bool = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")

func host_game(ip: String = IPadress):
	IPadress = ip
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 128)
	get_tree().network_peer = peer
	print("Хост запущен на ", IPadress, ":", port)

func join_game(ip: String = IPadress):
	IPadress = ip
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(IPadress, port)
	get_tree().network_peer = peer
	print("Подключаемся к ", IPadress, ":", port)
	
	if inGame:
		load_game_scene()

func start_game():
	if not get_tree().is_network_server():
		return
	rpc("load_game_scene")
	load_game_scene()

remote func load_game_scene():
	get_tree().change_scene("res://scenes/main.tscn")

func on_game_scene_loaded():
	if get_tree().is_network_server():
		# Хост создаёт своего игрока локально
		_spawn_player_local(1)
		# Рассылает всем клиентам создать игрока хоста
		rpc("spawn_player", 1)
		# Устанавливает никнейм хоста
		var host_player = get_tree().current_scene.get_node("1")
		if host_player && host_player.has_method("set_nickname"):
			host_player.set_nickname(myNickname)
		rpc("receive_nickname", myNickname)
	else:
		# Клиент сообщает хосту о готовности и отправляет никнейм
		rpc_id(1, "client_ready")
		rpc_id(1, "receive_nickname", myNickname)

remote func client_ready():
	var id = get_tree().get_rpc_sender_id()
	# Хост создаёт игрока для этого клиента локально
	_spawn_player_local(id)
	# Рассылает всем клиентам создать этого игрока
	rpc("spawn_player", id)

remote func spawn_player(id):
	# Эта функция вызывается на всех клиентах (и хосте) для создания игрока
	# На хосте игрок уже создан, поэтому проверяем, есть ли уже узел
	if get_tree().current_scene.has_node(str(id)): return
	
	var playerScene = preload("res://scenes/player.tscn")
	var player = playerScene.instance()
	player.name = str(id)
	get_tree().current_scene.add_child(player)
	for i in get_tree().get_nodes_in_group("player"):
		randomize()
		i.apply_skin(randi() % Global.allSkins.size())
	player.set_network_master(id)
	var spawns = get_tree().get_nodes_in_group("spawn_point")
	if spawns.size() > 0:
		var spawn = spawns[randi() % spawns.size()]
		player.global_position = spawn.global_position

# Внутренняя функция для создания игрока только на хосте (локально)
func _spawn_player_local(id):
	if not get_tree().is_network_server(): return
	if get_tree().current_scene.has_node(str(id)): return
	
	var playerScene = preload("res://scenes/player.tscn")
	var player = playerScene.instance()
	player.name = str(id)
	get_tree().current_scene.add_child(player)
	for i in get_tree().get_nodes_in_group("player"):
		randomize()
		i.apply_skin(randi() % Global.allSkins.size())
	player.set_network_master(id)
	var spawns = get_tree().get_nodes_in_group("spawn_point")
	if spawns.size() > 0:
		var spawn = spawns[randi() % spawns.size()]
		player.global_position = spawn.global_position

func _on_player_connected(id):
	pass

func _on_player_disconnected(id):
	if not get_tree().is_network_server():
		return
	var player = get_tree().current_scene.get_node(str(id))
	if player:
		player.queue_free()

func _on_connected_to_server():
	pass

remote func receive_nickname(nickname: String):
	var senderID = get_tree().get_rpc_sender_id()
	print("Игрок ", senderID, " представился как ", nickname)
	var player_node = get_tree().current_scene.get_node(str(senderID))
	if player_node and player_node.has_method("set_nickname"):
		player_node.set_nickname(nickname)
		rpc("set_player_nickname", senderID, nickname)

remote func set_player_nickname(player_id, new_nick):
	var node = get_tree().current_scene.get_node(str(player_id))
	if node and node.has_method("set_nickname"):
		node.set_nickname(new_nick)

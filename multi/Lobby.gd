extends Control

onready var status_network: Label = $STATUS
onready var status_id: Label = $STATUS2
onready var messanger: TextEdit = $messanger
onready var server: Button = $VBoxContainer/SERVER
onready var client: Button = $VBoxContainer/CLIENT
onready var leave: Button = $VBoxContainer/Leave
onready var chat: LineEdit = $chat

#network

remotesync  var health : String = ""
remotesync  var damage : String = ""


var connection : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var ip = IP.get_local_addresses()[8]
var local_id : int
onready var tree : SceneTree = get_tree()

var port = 5000

func change_state_btn_network(active : bool) -> void:
	server.disabled = !active
	client.disabled = !active
	leave.disabled = active
		

func _ready() -> void:
	
	
	# Вызываются только на клиентах
	tree.connect("connected_to_server", self, "_connected_to_server")
	tree.connect("server_disconnected", self, "_server_disconnected")
	
	#Вызываются у всех
	tree.connect("network_peer_connected", self, "_network_peer_connected")
	tree.connect("network_peer_disconnected", self, "_network_peer_disconnected")

func join(is_server : bool) -> void:
	if is_server:
		connection.set_bind_ip(ip)
		connection.create_server(port)
	else:
		connection.create_client(ip, port)
	tree.network_peer = connection
	#connection.set_target_peer(NetworkedMultiplayerPeer.TARGET_PEER_BROADCAST)
	local_id = tree.get_network_unique_id()
	if is_server:
		status_id.text = str(local_id)
		status_network.text  = "SERVER"
	
	change_state_btn_network(false)

# вызывается только на клиенет	
func _connected_to_server():
	status_network.text = "CLIENT"
	status_id.text = str(local_id)
	
func _server_disconnected():
	print("Вышел с сервера")
	connection.close_connection()
	tree.network_peer = null # закрываем подключение
	status_network.text = "OFFLINE"
	status_id.text = "UNKNOW"
	change_state_btn_network(false)
	
func _network_peer_connected(new_peer_id : int):
	print("Зашел " + str(new_peer_id))

func _network_peer_disconnected(old_peer_id : int):
	print("Вышел: " + str(old_peer_id))

func _on_SERVER_pressed(is_server: bool) -> void:
	join(is_server)

func _on_CLIENT_pressed(is_server: bool) -> void:
	join(is_server)

remotesync func feel_chat(sender_text : String, sender_id : int) -> void:
	messanger.text = messanger.text + "\n" + str(sender_id) + ": " + sender_text

func _on_LineEdit_text_entered(new_text: String) -> void:
	chat.text = ""
	rpc("feel_chat", new_text, local_id)
	

func _on_Leave_pressed() -> void:
	status_network.text = "OFFLINE"
	status_id.text = "UNKNOW"
	connection.close_connection()
	tree.network_peer = null # закрываем подключение
	change_state_btn_network(true)
	

extends CanvasLayer

onready var host_button = $buttons/host_button
onready var join_button = $buttons/join_button
onready var start_game_button = $buttons/start_game_button
onready var nickname_lineedit = $buttons/nickname_lineedit
onready var ipadress_lineedit = $buttons/ipadress_lineedit

onready var ver_label = $ver


func _ready():
	ver_label.text = Global.ver + "\nCreated by Drimer544 & tapoksila"
	
	randomize()
	
	host_button.connect("pressed", self, "_on_host_button_pressed")
	join_button.connect("pressed", self, "_on_join_button_pressed")
	start_game_button.connect("pressed", self, "_on_start_game_button_pressed")
	nickname_lineedit.connect("text_changed", self, "_on_nickname_lineedit_text_changed")
	
	start_game_button.hide()

func _on_host_button_pressed():
	if Network.myNickname == "":
		Network.myNickname = "Host" + str(randi() % 1024)
	Network.host_game()
	
	start_game_button.show()

func _on_join_button_pressed():
	if Network.myNickname == "":
		Network.myNickname = "Player" + str(randi() % 1024)
	Network.join_game(ipadress_lineedit.text)
	start_game_button.hide()

func _on_nickname_lineedit_text_changed(text: String):
	Network.myNickname = text

func _on_start_game_button_pressed():
	Network.start_game()

# nicknameLabel.gd
extends Label


func update_nickname(nickname: String = Network.myNickname):
	text = nickname

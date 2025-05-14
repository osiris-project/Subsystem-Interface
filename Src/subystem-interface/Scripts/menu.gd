extends Node2D

signal connectToIP(ipToConnect: String);
signal setUser(user:String);
signal setPassword(user:String);

@onready var userNameInput = $"Username/Username Input";
@onready var passwordInput = $"Password/Password Input";
@onready var IPInput = $"IP Line/IP Input";
@onready var shouldSave = $"Save Line/Save Input"
@onready var errorMessage = $"Error Message";

var save_path = "user://saves/";
var save_file = "config.tres";
var configData = ConfigData.new();

func pullUpMenu(errorMsg: String):
	visible = true;
	if(errorMsg != ""):
		errorMessage.text = errorMsg;
		errorMessage.visible = true;

func _ready() -> void:
	DirAccess.make_dir_absolute(save_path);
	var load = ResourceLoader.load(save_path + save_file);
	if(load != null):
		configData = load.duplicate(true);
		print("loaded config")
		userNameInput.text = configData.User;
		passwordInput.text = configData.Password;
		IPInput.text = configData.IP_ADDR;
	

func saveConfig():
	ResourceSaver.save(configData, save_path + save_file);
	print("saved config");


func _on_connect_button_pressed() -> void:
	visible = false;
	errorMessage.visible = false;
	if(shouldSave.button_pressed):
		configData.User = userNameInput.text;
		configData.Password = passwordInput.text;
		configData.IP_ADDR = IPInput.text;
		saveConfig();
	if(userNameInput.text):
		setUser.emit(userNameInput.text);
	else:
		setUser.emit(null);
	if(passwordInput.text):
		setPassword.emit(passwordInput.text);
	else:
		setPassword.emit(null);
	connectToIP.emit(IPInput.text);

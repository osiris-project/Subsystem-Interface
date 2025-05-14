extends Node2D

@onready var MQTT = $MQTT;
@export var IP_MQTT = "192.168.0.162"
var timeSinceStart: float = -1.0;
var madeRequests: bool = false;
var wasSuccessfullLastAttempt = false;
var lastCompletedSystemRecieved = 0;
var lastCompletedSystem = -1;
var username = null;
var password = null;
var isConnected = false;


signal updateSevenSeg(newNumber: int);
signal updateSwitches(newNumber: int);
signal newSectionNumber(newSection: int);
signal updateJacks(config:String);
signal updateJacksSolution(config:String);
signal updateButtons(config:String);
signal updateButtonsSolution(config:String);
#signal submissionResult(success:bool); used to validate last completed system
signal lastCompletedSystemUpdated(lastSystem: int);
signal bringUpMenu(error: String);

func startOnIp(NewIP:String):
	IP_MQTT = NewIP;
	connectMQTT();
	madeRequests = false;
	timeSinceStart = 0;


func connectMQTT():
	print("connecting");
	MQTT.set_last_will("Subsystem/viewerClient", "disconnected", false);
	MQTT.client_id = "Subsystem-Interface";
	MQTT.set_user_pass(username,password);
	var addr;
	if(OS.get_name().to_lower().contains("html") || OS.get_name().to_lower().contains("web")):
		addr = "%s%s:%s" % ["ws://", IP_MQTT, "9001"];
	else:
		addr = "%s%s:%s" % ["tcp://", IP_MQTT, "1883"];
	var retval = MQTT.connect_to_broker(addr);
	if(!retval):
		disconnectMQTT();
		bringUpMenu.emit("Error: Server IP is invalid or unreachable");
	isConnected = true;

func disconnectMQTT():
	updateSevenSeg.emit(0);
	updateSwitches.emit(0);
	newSectionNumber.emit(0);
	updateJacks.emit("0,0;0,0;0,0;0,0;0,0;");
	updateJacksSolution.emit("0,0;0,0;0,0;0,0;0,0;");
	updateButtons.emit("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,");
	updateButtonsSolution.emit("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,");
	timeSinceStart = -1;
	MQTT.disconnect_from_server();
	isConnected = false;


func makeSubscriptions():
	MQTT.subscribe("Subsystem/Subsystem");
	MQTT.subscribe("Subsystem/System");
	MQTT.subscribe("Subsystem/Jacks");
	MQTT.subscribe("Subsystem/JackSolution");
	MQTT.subscribe("Subsystem/Buttons");
	MQTT.subscribe("Subsystem/ButtonsSolution");
	MQTT.subscribe("Subsystem/Section");
	MQTT.subscribe("Subsystem/SubmissionResult");
	MQTT.subscribe("Subsystem/CompletedSystem");


func requestRefresh():
	MQTT.publish("Subsystem/req", "Update");
	MQTT.publish("Subsystem/viewerClient", "connected");


func _process(delta: float) -> void:
	if(timeSinceStart >= 0 && isConnected):
		if(timeSinceStart > 0.5 && !madeRequests):
			makeSubscriptions();
			madeRequests = true;
		elif(timeSinceStart > 1):
			requestRefresh();
			timeSinceStart = -1;
		else:
			timeSinceStart += delta;


func _on_mqtt_received_message(topic: Variant, message: Variant) -> void:
	if(topic == "Subsystem/Subsystem"):
		updateSwitches.emit(int(message))
	elif(topic == "Subsystem/System"):
		updateSevenSeg.emit(int(message));
	elif(topic == "Subsystem/Section"):
		newSectionNumber.emit(int(message));
	elif(topic == "Subsystem/Jacks"):
		updateJacks.emit(message);
	elif(topic == "Subsystem/JackSolution"):
		updateJacksSolution.emit(message);
	elif(topic == "Subsystem/Buttons"):
		updateButtons.emit(message);
	elif(topic == "Subsystem/ButtonsSolution"):
		updateButtonsSolution.emit(message);
	elif(topic == "Subsystem/SubmissionResult"):
		wasSuccessfullLastAttempt = int(message) == 1;
		if(wasSuccessfullLastAttempt && abs(Time.get_ticks_msec() - lastCompletedSystem) < 1000):
			lastCompletedSystemUpdated.emit(lastCompletedSystem);
	elif(topic == "Subsystem/CompletedSystem"):
		lastCompletedSystemRecieved = Time.get_ticks_msec();
		lastCompletedSystem = int(message);
		if(wasSuccessfullLastAttempt):
			lastCompletedSystemUpdated.emit(lastCompletedSystem);


func _on_menu_set_user(user: String) -> void:
	username = user;


func _on_menu_set_password(pwd: String) -> void:
	password = pwd;


func _on_menu_button_pressed() -> void:
	disconnectMQTT();
	bringUpMenu.emit("");
	


func _on_mqtt_broker_connection_failed() -> void:
	disconnectMQTT();
	bringUpMenu.emit("Error: Invalid Username/Password");

func _input(event: InputEvent) -> void:
	if(isConnected):
		if(Input.is_action_just_pressed("menu")):
			_on_menu_button_pressed();
		elif(Input.is_action_just_pressed("refresh")):
			requestRefresh();

extends Node2D

@onready var MQTT = $MQTT;
@export var IP_MQTT = "192.168.0.162"
var timeSinceStart: float = -1.0;
var madeRequests: bool = false;
var wasSuccessfullLastAttempt = false;
var lastCompletedSystemRecieved = 0;
var lastCompletedSystem = -1;

signal updateSevenSeg(newNumber: int);
signal updateSwitches(newNumber: int);
signal newSectionNumber(newSection: int);
signal updateJacks(config:String);
signal updateJacksSolution(config:String);
signal updateButtons(config:String);
signal updateButtonsSolution(config:String);
#signal submissionResult(success:bool); used to validate last completed system
signal lastCompletedSystemUpdated(lastSystem: int);

func startOnIp(NewIP:String):
	IP_MQTT = NewIP;
	madeRequests = false;
	timeSinceStart = 0;
	connectMQTT();


func connectMQTT():
	print("connecting");
	MQTT.set_last_will("Subsystem/viewerClient", "disconnected", false);
	MQTT.client_id = "Subsystem-Interface";
	MQTT.set_user_pass("space","BeamMeUp");
	var addr = "%s%s:%s" % ["tcp://", IP_MQTT, "1883"];
	print(addr);
	var retval = MQTT.connect_to_broker(addr);
	if(!retval):
		print("SERVER NOT FOUND");
	else:
		print("connected to server");


func _ready():
	startOnIp(IP_MQTT);


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
	print("Making requests");
	MQTT.publish("Subsystem/req", "Update");
	MQTT.publish("Subsystem/viewerClient", "connected");


func _process(delta: float) -> void:
	if(timeSinceStart >= 0):
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

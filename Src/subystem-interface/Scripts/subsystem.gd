extends Node2D

@onready var MQTT = $MQTT;
@onready var switches: Array = [$"Panel/Section 1/Switch 1", $"Panel/Section 1/Switch 2", $"Panel/Section 1/Switch 3", $"Panel/Section 1/Switch 4", 
								$"Panel/Section 1/Switch 5", $"Panel/Section 1/Switch 6",$"Panel/Section 1/Switch 7", $"Panel/Section 1/Switch 8"];
@export var IP_MQTT = "192.168.0.162"

signal updateSevenSeg(newNumber: int);
signal newSectionNumber(newSection: int);

func connectMQTT():
	print("connecting");
	MQTT.set_last_will("viewerClient", "disconnected", false);
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
	connectMQTT();

var timeSinceStart: float = 0.0;

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
	

func _process(delta: float) -> void:
	if(timeSinceStart >= 0):
		if(timeSinceStart > 1):
			makeSubscriptions();
			timeSinceStart = -1;
		elif(timeSinceStart <= 1):
			timeSinceStart += delta;


func _on_mqtt_received_message(topic: Variant, message: Variant) -> void:
	if(topic == "Subsystem/Subsystem"):
		var subsytem:int = int(message);
		var mask:int = 128;
		for i in range(8):
			switches[i].isClicked = subsytem & mask;
			mask = mask >> 1;
	elif(topic == "Subsystem/System"):
		updateSevenSeg.emit(int(message));
	elif(topic == "Subsystem/Section"):
		newSectionNumber.emit(int(message));

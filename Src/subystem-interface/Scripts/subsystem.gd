extends Node2D

@onready var MQTT = $MQTT;
@export var IP_MQTT = "192.168.0.162"

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
	

func _process(delta: float) -> void:
	if(timeSinceStart >= 0):
		if(timeSinceStart > 1):
			makeSubscriptions();
			timeSinceStart = -1;
		elif(timeSinceStart <= 1):
			timeSinceStart += delta;


func _on_mqtt_received_message(topic: Variant, message: Variant) -> void:
	print("Recieved topic: %s with message: %s" % [topic, message])

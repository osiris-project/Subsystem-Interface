extends TextEdit

var startingText;

func _ready() -> void:
	startingText = text;

func _on_subsystem_last_completed_system_updated(lastSystem: int) -> void:
	text = startingText + str(lastSystem); 

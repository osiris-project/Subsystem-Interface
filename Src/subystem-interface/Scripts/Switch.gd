extends Node2D

@onready var textures: Array = [preload("res://Images/Button_Off.png"), preload("res://Images/Button_On.png")];

@onready var switches: Array = [$"Switch 1", $"Switch 2", $"Switch 3", $"Switch 4", 
								$"Switch 5", $"Switch 6", $"Switch 7", $"Switch 8"];


func _on_subsystem_update_switches(newNumber: int) -> void:
	var mask:int = 128;
	for i in range(8):
		switches[i].texture = textures[1] if newNumber & mask else textures[0];
		mask = mask >> 1;

extends Node2D

@export var alphaVal = 1;
#these are the default colors for the buttons as found in the source code
@export var buttonColors:Array = [Color(0,0,0,0),
  Color(1,0,0, alphaVal),
  Color(1,1,0, alphaVal),
  Color(0,1,0, alphaVal),
  Color(0,1,1, alphaVal),
  Color(179/255.0,120/255.0,211/255.0, alphaVal),
  Color(1,1,1, alphaVal)];

@onready var buttons = [$"Button 1", $"Button 2", $"Button 3", $"Button 4",
			$"Button 5", $"Button 6", $"Button 7", $"Button 8",
			$"Button 9", $"Button 10", $"Button 11", $"Button 12",
			$"Button 13", $"Button 14", $"Button 15", $"Button 16",];

func parseGrid(config:String, isStatus:bool):
	var currInt = "";
	var currButton = 0;
	for char in config:
		if(char.is_valid_int()):
			currInt += char;
		elif(currButton >= len(buttons)):
			return;
		else:
			if(isStatus):
				buttons[currButton].currColor = currInt.to_int();
			else:
				buttons[currButton].solColor = currInt.to_int();
			currButton += 1;
			currInt = "";
	if(currInt.length() > 0 && currButton < len(buttons)):
		if(isStatus):
			buttons[currButton].currColor = currInt.to_int();
		else:
			buttons[currButton].solColor = currInt.to_int();


func _on_subsystem_update_buttons(config: String) -> void:
	parseGrid(config, true);


func _on_subsystem_update_buttons_solution(config: String) -> void:
	parseGrid(config, false);

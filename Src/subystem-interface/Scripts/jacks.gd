extends Node2D

#[[0,0],[0,0],[0,0],[0,0],[0,0]]
var jackStatus = [[0,0],[0,0],[0,0],[0,0],[0,0]]
var jackSolution = [[0,0],[0,0],[0,0],[0,0],[0,0]]
@onready var jacks:Array = [$"Jack 1", $"Jack 2", $"Jack 3", $"Jack 4", $"Jack 5", $"Jack 6", $"Jack 7",$"Jack 8",$"Jack 9",$"Jack 10"]

func drawConnections(net:Array, color:Color, width:int):

	for row in net:
		if(row[0] != 0 && row[1] != 0 && row[0] <= len(jacks) && row[1] <= len(jacks) && row[1] != row[0]):
			var from:Vector2 = jacks[row[0] - 1].global_position;
			var to:Vector2 = jacks[row[1] - 1].global_position;
			draw_line(from, to, color, width, true);

func _draw():
	drawConnections(jackSolution, Color.GREEN, 10);
	drawConnections(jackStatus, Color.DIM_GRAY, 5);

func _process(delta: float) -> void:
	queue_redraw();

func parseStringForJacks(config:String, isStatus:bool):
	var currInt = "";
	var currJack = 0;
	for char in config:
		if(char.is_valid_int()):
			currInt += char;
		elif(currJack >= len(jacks)):
			return;
		else:
			if(isStatus):
				jackStatus[currJack / 2][currJack % 2] = currInt.to_int();
			else:
				jackSolution[currJack / 2][currJack % 2] = currInt.to_int();
			currJack += 1;
			currInt = "";
	if(currInt.length() > 0 && currJack < len(jacks)):
		if(isStatus):
			jackStatus[currJack / 2][currJack % 2] = currInt.to_int();
		else:
			jackSolution[currJack / 2][currJack % 2] = currInt.to_int();
	queue_redraw();

func _on_subsystem_update_jacks(config: String) -> void:
	parseStringForJacks(config, true);

func _on_subsystem_update_jacks_solution(config: String) -> void:
	parseStringForJacks(config, false);

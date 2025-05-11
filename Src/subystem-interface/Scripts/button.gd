extends Sprite2D

@export var sectionNumber = 1;
signal newSectionNumber(newSection: int);

@onready var offState = preload("res://Images/Button Blank.png");
@onready var currState = preload("res://Images/Button In Progress.png");
@onready var completeState = preload("res://Images/Button Finished.png");


func _on_subsystem_new_section_number(newSection: int) -> void:
	if(newSection + 1 < sectionNumber):
		texture = offState;
	elif(newSection + 1 == sectionNumber):
		texture = currState;
	else:
		texture = completeState;
	newSectionNumber.emit(newSection);

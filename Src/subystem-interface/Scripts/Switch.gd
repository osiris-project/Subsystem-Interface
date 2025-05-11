extends Sprite2D

@onready var textures: Array = [preload("res://Images/Button_Off.png"), preload("res://Images/Button_On.png")];

var isClicked:bool = false;
 
func _process(delta: float):
	if isClicked:
		if texture != textures[1]:
			texture = textures[1]
	elif texture != textures[0]:
		texture = textures[0]

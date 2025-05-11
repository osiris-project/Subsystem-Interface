extends Sprite2D

@export var number: int = 0;

@onready var digits:Array = [$OnesPlace,$TwosPlace,$ThreesPlace];
@onready var offTexture = preload("res://Images/Seven Seg Off.png");
@onready var numTextures:Array = [preload("res://Images/Seven Seg 0.png"), preload("res://Images/Seven Seg 1.png"),preload("res://Images/Seven Seg 2.png"),preload("res://Images/Seven Seg 3.png"),
								preload("res://Images/Seven Seg 4.png"),preload("res://Images/Seven Seg 5.png"),preload("res://Images/Seven Seg 6.png"),preload("res://Images/Seven Seg 7.png"),
								preload("res://Images/Seven Seg 8.png"),preload("res://Images/Seven Seg 9.png")];

func _updateSevenSeg(newNum: int) -> void:
	number = newNum;
	for digit in range(len(digits)):
		var place = 10 ** (digit + 1);
		var digitVal = (number % place) / (place / 10);
		if(digit != 0 && digitVal == 0):
			digits[digit].texture = offTexture;
		else:
			digits[digit].texture = numTextures[digitVal];

func _ready() -> void:
	_updateSevenSeg(number);

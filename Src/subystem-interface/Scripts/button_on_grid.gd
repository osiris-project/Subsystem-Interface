extends Sprite2D

var currColor:int = 0;
var solColor:int = 0;
var sizeOfShadedRegion = 220; #Vector2(220,220);
@onready var colorArray = $"..".buttonColors;

func _process(delta: float) -> void:
	if(currColor != 0 || solColor != 0):
		queue_redraw();

func _draw() -> void:
	if(currColor != 0):
		drawTriangle(currColor, true)
	if(solColor != 0):
		drawTriangle(solColor, false)

func drawTriangle(color:int, upper:bool):
	var vertices = PackedVector2Array([Vector2(- sizeOfShadedRegion / 2, - sizeOfShadedRegion / 2), 
					(1 if upper else -1) * Vector2(sizeOfShadedRegion / 2, - sizeOfShadedRegion / 2), 
					Vector2(sizeOfShadedRegion / 2, sizeOfShadedRegion / 2)]);
	var colors = PackedColorArray([colorArray[color], colorArray[color], colorArray[color]]);
	var uvs = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(0.5, 1)]);
	draw_primitive(vertices, colors, uvs);

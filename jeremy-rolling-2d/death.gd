extends StaticBody2D

@export var debounce_time := 0.5
var bounced := false

func _ready():
	add_to_group("death")

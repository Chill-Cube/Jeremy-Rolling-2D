class_name Bouncer
extends StaticBody2D

@export var bounce := 400
var bounced := false

func _ready():
	add_to_group("bouncer")

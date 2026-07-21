extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = !(OS.has_feature("web_android") or OS.has_feature("web_ios"))

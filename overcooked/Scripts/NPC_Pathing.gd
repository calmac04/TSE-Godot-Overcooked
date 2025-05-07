extends PathFollow3D

var speed = 0.0

func _ready():
	randomize()
	speed = randf_range(1.0, 3.0)

func _process(delta):
	progress += speed * delta

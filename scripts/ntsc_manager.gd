extends Node

@export var NTSC : MeshInstance2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not NTSC == null:
		print('NTSC Shader is not null')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

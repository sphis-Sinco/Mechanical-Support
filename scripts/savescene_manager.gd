extends Node

@export var SaveText : RichTextLabel
@export var AnimPlayer : AnimationPlayer 
@export var ConfirmDialogue : ConfirmationDialog

var SAVE_FILE = SystemsManager.blank_save_file()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not ConfirmDialogue.confirmed.is_connected(clear_save):
		ConfirmDialogue.confirmed.connect(clear_save)
	
	SaveText.text = SystemsManager.SAVE_STRING
	
	AnimPlayer.play('open')
	$"../Open".play()

func _unhandled_input(event):
	if event.is_action_released("accept"):
		AnimPlayer.play('close')
		AnimPlayer.animation_finished.connect(anim_finished)
	elif event.is_action_released("back"):
		ConfirmDialogue.show()

func anim_finished(anim_name):
	match anim_name:
		'close':
			get_tree().change_scene_to_file("res://scenes/pay_scene.tscn")

func clear_save():
	StatsManager.SHIFT_PAY = 0
	StatsManager.SYSTEMS_FIXED = 0
	StatsManager.SYSTEMS_MALFUNCTIONED = 0
	StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM = 0
	StatsManager.SHIFT_PERCENT_CHECKS = 0
	
	SAVE_FILE = SystemsManager.blank_save_file()
	
	SystemsManager.save()
	
	get_tree().reload_current_scene()

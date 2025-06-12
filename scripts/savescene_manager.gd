extends Node

@export var SaveText : RichTextLabel
@export var AnimPlayer : AnimationPlayer 
@export var ConfirmDialogue : ConfirmationDialog

var SAVE_FILE = blank_save_file()

var SAVE_STRING = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	SAVE_STRING = SaveText.text
	if not ConfirmDialogue.confirmed.is_connected(clear_save):
		ConfirmDialogue.confirmed.connect(clear_save)
	
	load_save()
	save()
	
	AnimPlayer.play('open')
	$"../Open".play()

const savefile_name = 'save.data'

func load_save():
	if not FileAccess.file_exists("res://"+savefile_name):
		save()
		return # Error! We don't have a save to load.
	
	var save_file = FileAccess.open("res://"+savefile_name, FileAccess.READ)
	SAVE_FILE = JSON.parse_string(save_file.get_as_text())
	save_file.close()

func save():
	var unsaved_save = {
		'M': StatsManager.SHIFT_PAY,
		'SF': StatsManager.SYSTEMS_FIXED,
		'SM': StatsManager.SYSTEMS_MALFUNCTIONED,
		'QWFS': StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM,
		'CSP': StatsManager.SHIFT_PERCENT_CHECKS
	}
	
	print('before')
	print(SAVE_FILE)
	
	SAVE_FILE.M += unsaved_save.M
	SAVE_FILE.SF += unsaved_save.SF
	SAVE_FILE.SM += unsaved_save.SM
	SAVE_FILE.QWFS += unsaved_save.QWFS
	SAVE_FILE.CSP += unsaved_save.CSP
	
	print('after')
	print(SAVE_FILE)
	
	var save_file = FileAccess.open("res://"+savefile_name, FileAccess.WRITE)
	save_file.store_line(str(SAVE_FILE))
	save_file.close()
	
	save_string_replace('$SF_CR', str(StatsManager.SYSTEMS_FIXED))
	save_string_replace('$SM_CR', str(StatsManager.SYSTEMS_MALFUNCTIONED))
	save_string_replace('$QWFS_CR', str(StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM))
	save_string_replace('$CSP_CR', str(StatsManager.SHIFT_PERCENT_CHECKS))
	save_string_replace('$M_CR', '$'+str(StatsManager.SHIFT_PAY))
	
	save_string_replace('$SF', str(SAVE_FILE.SF))
	save_string_replace('$SM', str(SAVE_FILE.SM))
	save_string_replace('$QWFS', str(SAVE_FILE.QWFS))
	save_string_replace('$CSP', str(SAVE_FILE.CSP))
	save_string_replace('$M', '$'+str(SAVE_FILE.M))
	
	SaveText.text = SAVE_STRING

func save_string_replace(what='', with=''):
	SAVE_STRING = SAVE_STRING.replace(what, with)

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
	
	SAVE_FILE = blank_save_file()
	
	save()
	
	get_tree().reload_current_scene()

func blank_save_file():
	return {
		'M': 0,
		'SF': 0,
		'SM': 0,
		'QWFS': 0,
		'CSP': 0
	}

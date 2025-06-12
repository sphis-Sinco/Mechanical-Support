extends Node

@export var AnimPlayer : AnimationPlayer

@export var TerminalText : RichTextLabel
@export var TextInput : TextEdit

var spacing = '-----------------------------------------------------------------------------------------------------------------------------'


# Called when the node enters the scene tree for the first time.
func _ready():
	AnimPlayer.connect('animation_finished', animationPlayer_finishedAnimation)
	AnimPlayer.play('open')
	
	SystemsManager.error_sfx.connect(error_sfx)
	
	$"../Open".play()
	
	if SystemsManager.audio_hvac == null or not SystemsManager.audio_hvac.playing:
		SystemsManager.audio_hvac = $"../HVAC"
	if SystemsManager.audio_light == null or not SystemsManager.audio_light.playing:
		SystemsManager.audio_light = $"../Light"

@onready var error = $"../Error"
@onready var fixed = $"../Fixed"

func error_sfx():
	if error.playing:
		error.stop()
	error.play()

func fixed_sfx():
	if fixed.playing:
		fixed.stop()
	fixed.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if SystemsManager.audio_light.volume_db > -20:
		SystemsManager.audio_light.volume_db -= 2

@onready var blip = $"../Blip"

func _unhandled_input(event):
	if event.is_action_released("accept") and TextInput.text.replace('\n', '').length() > 0:
		input_command(TextInput.text.replace('\n', ''))
		blip.play()
	elif event.is_action_released("accept"):
		if TextInput.text.ends_with('\n'):
			TextInput.text = TextInput.text.replace('\n', '')

func input_command(command):
	var response = ''
	print(command)
	
	match command.to_lower().split(' ')[0]:
		'help':
			response += 'HELP: Display a list of commands'
			response += '\nSYSTEMS / SYS: Display system stats'
			response += '\nFIX: Attempts to fix a system specifed (Example: fix hvac), use "_" or "-" for systems with spaces'
			response += '\nSHIFT: Check the percentage of how long you\'ve participated in your shift'
			response += '\nQUIT: Turn off the system'
		
		'systems', 'sys':
			response += 'SYSTEMS STATUS:'
			response += '\nHVAC: '+SystemsManager.SYSTEM_HVAC
			
			response += '\n\nOffice computers: '+SystemsManager.SYSTEM_OFFICE_COMPUTERS
			response += '\nPrivate computers: '+SystemsManager.SYSTEM_PRIVATE_COMPUTERS
			
			response += '\n\nPrinter: '+SystemsManager.SYSTEM_PRINTER
			response += '\nTelecommunication: '+SystemsManager.SYSTEM_TELECOMMUNICATION
			
			response += '\n\nManufacturing: '+SystemsManager.SYSTEM_MANUFACTURING
		
		'fix':
			if SystemsManager.SYSTEM_REPAIRING:
				response += 'Can only fix 1 system at a time. Apologizes'
			else:
				var arguments = command.split(' ')
				if arguments.size() == 1:
					response += 'More arguments required'
				elif arguments.size() == 3:
					response += 'Use "_" or "-" for systems with spaces'
				else:
					response += 'The requested system is being fixed...'
					fix_command(arguments)
		
		'quit':
			if SystemsManager.SYSTEM_REPAIRING:
				response += 'Cannot quit the program while repairing systems!'
				StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM += 1
			else:
				pass
		
		'shift':
			response += 'You have been here for '
			response += SystemsManager.SHIFT_PERCENT
			response += ' of your shift time.'
			
			StatsManager.SHIFT_PERCENT_CHECKS += 1
		
		_:
			response = 'Unknown command: '+command
	
	TerminalText.text += spacing+'\n'+response+'\n'
	TextInput.text = ""
	
	if command.to_lower() == 'quit' and not SystemsManager.SYSTEM_REPAIRING:
		AnimPlayer.play('close')
		

func animationPlayer_finishedAnimation(anim_name):
	if anim_name == 'close':
		get_tree().change_scene_to_file("res://scenes/office.tscn")

func fix_command(arguments):
	SystemsManager.SYSTEM_IN_REPAIR = arguments[1].replace('_', ' ').replace('-', ' ')
	SystemsManager.SYSTEM_REPAIR_TICKS = randi_range(SystemsManager.SYSTEM_REPAIR_TICKS_MIN, SystemsManager.SYSTEM_REPAIR_TICKS_MAX)
	SystemsManager.SYSTEM_REPAIR_STARTING_TICKS = SystemsManager.SYSTEM_REPAIR_TICKS
	SystemsManager.sys_rep_update()
	
	if not SystemsManager.system_repaired.is_connected(system_fixed):
		SystemsManager.system_repaired.connect(system_fixed)
	if not SystemsManager.system_repair_not_required.is_connected(system_fix_not_needed):
		SystemsManager.system_repair_not_required.connect(system_fix_not_needed)
	if not SystemsManager.system_repair_not_required.is_connected(system_fix_update):
		SystemsManager.system_repair_not_required.connect(system_fix_update)

func system_fixed(system_name):
	fixed_sfx()
	SystemsManager.SYSTEM_IN_REPAIR = ''
	TerminalText.text += spacing+'\nSystem "'+system_name+'" fixed\n'

func system_fix_not_needed(system_name):
	SystemsManager.SYSTEM_IN_REPAIR = ''
	TerminalText.text += spacing+'\nSystem "'+system_name+'" did not require fixing\n'

func system_fix_update(system_name, percent):
	SystemsManager.SYSTEM_IN_REPAIR = ''
	TerminalText.text += spacing+'\nSystem "'+system_name+'" fix at '+percent+'%\n'

extends Node

const STAT_FUNCTIONAL = 'FUNCTIONAL'
const STAT_MALFUNCTIONAL = 'MALFUNCTIONAL'

var SYSTEM_HVAC = STAT_FUNCTIONAL

var SYSTEM_OFFICE_COMPUTERS = STAT_FUNCTIONAL
var SYSTEM_PRIVATE_COMPUTERS = STAT_FUNCTIONAL

var SYSTEM_PRINTER = STAT_FUNCTIONAL
var SYSTEM_TELECOMMUNICATION = STAT_FUNCTIONAL

var SYSTEM_MANUFACTURING = STAT_FUNCTIONAL

var SYSTEM_REPAIR_STARTING_TICKS = 0
var SYSTEM_REPAIR_TICKS = 0
var SYSTEM_REPAIR_PERCENT = 0

var SYSTEM_REPAIRING = false
var SYSTEM_IN_REPAIR = ''

var SYSTEM_REPAIR_TICKS_MIN = 200
var SYSTEM_REPAIR_TICKS_MAX = 800

var SYSTEM_REPAIR_TICKS_PORTABLE_MULTIPLIER = 4
var SYSTEM_REPAIR_TICKS_MIN_PORTABLE = SYSTEM_REPAIR_TICKS_MIN * SYSTEM_REPAIR_TICKS_PORTABLE_MULTIPLIER
var SYSTEM_REPAIR_TICKS_MAX_PORTABLE = SYSTEM_REPAIR_TICKS_MAX * SYSTEM_REPAIR_TICKS_PORTABLE_MULTIPLIER

var SYS_REP_UP1 = 0
var SYS_REP_UP2 = 0
var SYS_REP_UP3 = 0
var SYS_REP_UP4 = 0
var SYS_REP_UP5 = 0

var SYSTEM_MALFUNCTION_TICKS = 0

var SYS_MAL_UP = 0

var SYS_MAL_UP_MIN = 2000
var SYS_MAL_UP_MAX = 10000

var SHIFT_TICK = 0
var SHIFT_TIME_MULTIPLIER = 5 # _ sabotages before the shift ends
var SHIFT_TIME = SYS_MAL_UP_MAX * SHIFT_TIME_MULTIPLIER
var SHIFT_PERCENT = 0
var SHIFT_OVER = false

var audio_light : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
var audio_hvac : AudioStreamPlayer2D = AudioStreamPlayer2D.new()

var SEEN_TUTORIAL = false

var SEEN_PAY = false
var ACCEPTED_PAY = false

var IN_PORTABLE_MONITOR = false

func _ready():
	sys_rep_update()
	sys_mal_update()

func _process(_delta):
	SHIFT_TICK += 1
	
	SHIFT_PERCENT = 0
	if SHIFT_TICK > 0:
		SHIFT_PERCENT = (float(SHIFT_TICK) / SHIFT_TIME) * 100
	
	if SHIFT_TICK == SHIFT_TIME and not SHIFT_OVER:
		print('Shift over!')
		SHIFT_OVER = true
		shift_ended.emit()
	
	if not SHIFT_OVER:
		if not audio_light.playing:
			audio_light.play()
		
		if not audio_hvac.playing and SYSTEM_HVAC == STAT_FUNCTIONAL:
			audio_hvac.play()
		
		system_check('hvac', SYSTEM_HVAC)
		
		system_check('office computers', SYSTEM_OFFICE_COMPUTERS)
		system_check('private computers', SYSTEM_PRIVATE_COMPUTERS)
		
		system_check('printer', SYSTEM_PRINTER)
		system_check('telecommunication', SYSTEM_TELECOMMUNICATION)
		
		system_check('manufacturing', SYSTEM_MANUFACTURING)
		
		if SYSTEM_REPAIR_TICKS > 0:
			SYSTEM_REPAIR_PERCENT = 0
			if not SYSTEM_REPAIR_TICKS == 0:
				SYSTEM_REPAIR_PERCENT = (float(SYSTEM_REPAIR_TICKS)/SYSTEM_REPAIR_STARTING_TICKS)*100
			if SYSTEM_REPAIRING == false:
				SYSTEM_REPAIRING = true
			SYSTEM_REPAIR_TICKS -= 1
			match roundi(SYSTEM_REPAIR_PERCENT):
				SYS_REP_UP1, SYS_REP_UP2, SYS_REP_UP3, SYS_REP_UP4, SYS_REP_UP5:
					system_repair_update.emit(SYSTEM_IN_REPAIR, SYSTEM_REPAIR_PERCENT)
		elif SYSTEM_REPAIRING == true:
			SYSTEM_REPAIRING = false
			StatsManager.SYSTEMS_FIXED += 1
			fixed_system_check(SYSTEM_IN_REPAIR.to_lower())
			system_repaired.emit(SYSTEM_IN_REPAIR.to_lower())
		
		SYSTEM_MALFUNCTION_TICKS += randi_range(1,6)
		
		if SYSTEM_MALFUNCTION_TICKS > SYS_MAL_UP:
			SYSTEM_MALFUNCTION_TICKS = SYS_MAL_UP
		
		if SYSTEM_MALFUNCTION_TICKS == SYS_MAL_UP:
			print('Tick '+str(SYSTEM_MALFUNCTION_TICKS))
			SYSTEM_MALFUNCTION_TICKS = 0
			
			system_malfunction()
			sys_mal_update()

func fixed_system_check(system_name):
	print(system_name)
	match system_name:
		'hvac':
			SYSTEM_HVAC = STAT_FUNCTIONAL
		'office computers':
			SYSTEM_OFFICE_COMPUTERS = STAT_FUNCTIONAL
		'private computers':
			SYSTEM_PRIVATE_COMPUTERS =  STAT_FUNCTIONAL
		'printer':
			SYSTEM_PRINTER = STAT_FUNCTIONAL
		'telecommunication':
			SYSTEM_TELECOMMUNICATION =  STAT_FUNCTIONAL
		'manufacturing':
			SYSTEM_MANUFACTURING = STAT_FUNCTIONAL

func system_malfunction():
	var rand = randi_range(1,6)
	
	match rand:
		# 0:
		# 	SYSTEM_HVAC = sabotage_system('HVAC')
		1:
			SYSTEM_HVAC = sabotage_system('HVAC', SYSTEM_HVAC)
			if SYSTEM_HVAC == STAT_MALFUNCTIONAL:
				audio_hvac.stop()
		2:
			SYSTEM_OFFICE_COMPUTERS = sabotage_system('OFFICE COMPUTERS', SYSTEM_OFFICE_COMPUTERS)
		3:
			SYSTEM_PRIVATE_COMPUTERS = sabotage_system('PRIVATE COMPUTERS', SYSTEM_PRIVATE_COMPUTERS)
		4:
			SYSTEM_PRINTER = sabotage_system('PRINTER', SYSTEM_PRINTER)
		5:
			SYSTEM_TELECOMMUNICATION = sabotage_system('TELECOMMUNICATION', SYSTEM_TELECOMMUNICATION)
		6:
			SYSTEM_MANUFACTURING = sabotage_system('MANUFACTURING', SYSTEM_MANUFACTURING)

func sabotage_system(system_print : String, system_value : String):
	if system_value == STAT_FUNCTIONAL:
		print(system_print.to_upper(), ' SYSTEM MALFUNCTION')
		
		error_sfx.emit()
		
		StatsManager.SYSTEMS_MALFUNCTIONED += 1
		return STAT_MALFUNCTIONAL
	else:
		return system_value

func system_check(system_name,system):
	if SYSTEM_IN_REPAIR.to_lower() == system_name and system == STAT_FUNCTIONAL:
		SYSTEM_REPAIR_TICKS = 0
		# print('False fixing: '+system_name)
		system_repair_not_required.emit(SYSTEM_IN_REPAIR)

func sys_rep_update():
	SYS_REP_UP1 = randi_range(5,10)
	SYS_REP_UP2 = randi_range(15,30)
	SYS_REP_UP3 = randi_range(25,50)
	SYS_REP_UP4 = randi_range(35,70)
	SYS_REP_UP5 = randi_range(45,90)
	
func sys_mal_update():
	# SYS_MAL_UP = 200
	SYS_MAL_UP = randi_range(SYS_MAL_UP_MIN,SYS_MAL_UP_MAX)
	print('System malfunction tick goal: ',SYS_MAL_UP)

signal system_repaired(system_name)
signal system_repair_not_required(system_name)
signal system_repair_update(system_name, percent)

signal error_sfx()

signal shift_ended()

func blank_save_file():
	return {
		'M': 0,
		'SF': 0,
		'SM': 0,
		'QWFS': 0,
		'CSP': 0
	}


const savefile_name = 'save.data'
var SAVE_FILE = {}
var SAVE_STRING = ""

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
	
	return SAVE_STRING

func save_string_replace(what='', with=''):
	SAVE_STRING = SAVE_STRING.replace(what, with)

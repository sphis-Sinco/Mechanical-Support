extends Node

var SYSTEMS_FIXED = 0
var SYSTEMS_MALFUNCTIONED = 0
var ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM = 0
var SHIFT_PERCENT_CHECKS = 0

var SHIFT_MESSAGE = ''
var SHIFT_PAY = 0

var MINIMUM_WAGE = 6.55
var MAXIMUM_WAGE = MINIMUM_WAGE*16

func _ready():
	SYSTEMS_FIXED = 0
	SYSTEMS_MALFUNCTIONED = 0
	ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM = 0
	SHIFT_PERCENT_CHECKS = 0

func calculate_pay():
	const management_appriciates = '\n- Management appriciates'
	const management_doesnt_appriciate = '\n- Management doesn\'t appriciate'
	var multiplier = 1
	var val = 0
	
	SHIFT_MESSAGE = 'Shift notes:'
	SHIFT_PAY = 0
	
	if SYSTEMS_MALFUNCTIONED > 0 and SYSTEMS_FIXED > 0:
		val = (float(SYSTEMS_FIXED) / SYSTEMS_MALFUNCTIONED)*100
		SHIFT_PAY += val
		shift_pay_debug_message('systems fixed and malfunctioned ('+str(val)+')')
	
	if SYSTEMS_FIXED > SYSTEMS_MALFUNCTIONED or SYSTEMS_FIXED == SYSTEMS_MALFUNCTIONED:
		SHIFT_MESSAGE += management_appriciates + ' the many fixex of malfunctioned systems'
	elif SYSTEMS_MALFUNCTIONED > SYSTEMS_FIXED:
		SHIFT_MESSAGE += management_doesnt_appriciate + ' the lack of system fixes'
	
	if SYSTEMS_FIXED > 0 and ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM > 0:
		val = (float(ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM) / SYSTEMS_FIXED) / 5
		SHIFT_PAY -= val
		shift_pay_debug_message('attempts quitting while fixing system ('+str(val)+')')
	
	if SYSTEMS_FIXED > ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM:
		SHIFT_MESSAGE += management_appriciates + ' the prioritization of fixing systems'
		multiplier += float(ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM) / 10
	elif ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM > SYSTEMS_FIXED:
		SHIFT_MESSAGE += management_doesnt_appriciate + ' the lack of prioritization of fixing systems'
		multiplier += float(ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM) / 100
	
	
	if SHIFT_PERCENT_CHECKS > 10:
		SHIFT_MESSAGE += management_doesnt_appriciate + ' the constant checking of how long you\'ve been doing your shift'
		SHIFT_PAY -= SHIFT_PERCENT_CHECKS / 100.0
	else:
		SHIFT_MESSAGE += management_appriciates + ' the lack of care on how long you\'ve been doing your shift'
		SHIFT_PAY += SHIFT_PERCENT_CHECKS / 100.0
		multiplier += SHIFT_PERCENT_CHECKS / 100.0
	shift_pay_debug_message('shift percent checks ('+str(SHIFT_PERCENT_CHECKS)+')')
	
	if SHIFT_PAY < MINIMUM_WAGE:
		SHIFT_PAY = float(MINIMUM_WAGE)
		shift_pay_debug_message('minimum wage check')
	
	SHIFT_PAY = snapped(SHIFT_PAY * multiplier, 0.01)
	shift_pay_debug_message('x'+str(multiplier)+')')
	
	if SHIFT_PAY > MAXIMUM_WAGE:
		SHIFT_PAY = MAXIMUM_WAGE
	
	shift_pay_debug_message('final (not above '+str(MAXIMUM_WAGE)+')')
	print(SHIFT_MESSAGE)

func shift_pay_debug_message(event):
	print('Shift pay (',event,'): $',SHIFT_PAY)

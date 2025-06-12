extends Node

func randomStats(minimum = 0, maximum = 20):
	SystemsManager.SHIFT_OVER = true
	
	StatsManager.SYSTEMS_MALFUNCTIONED = randi_range(minimum, maximum)
	StatsManager.SYSTEMS_FIXED = randi_range(minimum, StatsManager.SYSTEMS_MALFUNCTIONED)
	StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM = randi_range(minimum, StatsManager.SYSTEMS_FIXED)
	StatsManager.SHIFT_PERCENT_CHECKS = randi_range(minimum, maximum)
	
	print(StatsManager.SYSTEMS_MALFUNCTIONED)
	print(StatsManager.SYSTEMS_FIXED)
	
	if minimum > 0:
		print(float(StatsManager.SYSTEMS_FIXED) / StatsManager.SYSTEMS_MALFUNCTIONED * 10)
	
	print(StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM)
	print(StatsManager.SHIFT_PERCENT_CHECKS)
	StatsManager.calculate_pay()

@export var PaymentLabel : Label3D
@export var Scene_AnimationPlayer : AnimationPlayer
@export var Monitor : Node3D

var is_web = OS.get_name() == 'Web'

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if is_web:
		Monitor.visible = false
	
	calc_pay()
	
	if not SystemsManager.SEEN_PAY:
		SAP_play('grabSlip')
	else:
		$"../Close".play()
		SAP_play('closeComputer')
	
	SAP_finished = false
	if not Scene_AnimationPlayer.animation_finished.is_connected(SAP):
		Scene_AnimationPlayer.animation_finished.connect(SAP)

var SAP_finished = false
var SAP_animation = 'grabSlip'

func SAP(anim_name):
	SAP_finished = true
	print('SAP_finished ', SAP_animation)
	match anim_name:
		'grabSlip':
			SystemsManager.SEEN_PAY = true
		'openComputer':
			get_tree().change_scene_to_file('res://scenes/save.tscn')

func calc_pay():
	StatsManager.calculate_pay()
	
	PaymentLabel.text = ''
	PaymentLabel.text += 'Hopo Incorporated. 1992 - 20xx'
	PaymentLabel.text += '\nPayment slip\n'
	PaymentLabel.text += '\nShift pay: $'
	PaymentLabel.text += str(StatsManager.SHIFT_PAY)
	PaymentLabel.text += '\n'
	PaymentLabel.text += StatsManager.SHIFT_MESSAGE

func _unhandled_input(event):
	if SAP_finished and not is_web:
		if event.is_action_released("accept") and SAP_animation == 'grabSlip':
			SAP_play('tossSlip')
		elif event.is_action_released("left"):
			match SAP_animation:
				'tossSlip', 'closeComputer':
					SAP_play('openComputer')

func SAP_play(anim_name):
	Scene_AnimationPlayer.play(anim_name)
	SAP_animation = anim_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

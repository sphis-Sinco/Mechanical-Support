extends Node

func randomStats(min = 0, max = 20):
	SystemsManager.SHIFT_OVER = true
	
	StatsManager.SYSTEMS_MALFUNCTIONED = randi_range(min, max)
	StatsManager.SYSTEMS_FIXED = randi_range(min, StatsManager.SYSTEMS_MALFUNCTIONED)
	StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM = randi_range(min, StatsManager.SYSTEMS_FIXED)
	StatsManager.SHIFT_PERCENT_CHECKS = randi_range(min, max)
	
	print(StatsManager.SYSTEMS_MALFUNCTIONED)
	print(StatsManager.SYSTEMS_FIXED)
	
	if min > 0:
		print(float(StatsManager.SYSTEMS_FIXED) / StatsManager.SYSTEMS_MALFUNCTIONED * 10)
	
	print(StatsManager.ATTEMPTS_QUITTING_WHILE_FIXING_SYSTEM)
	print(StatsManager.SHIFT_PERCENT_CHECKS)
	StatsManager.calculate_pay()

@export var PaymentLabel : Label3D
@export var Scene_AnimationPlayer : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	calc_pay()
	Scene_AnimationPlayer.current_animation = 'grabSlip'
	Scene_AnimationPlayer.play()

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
	if event.is_action_released("accept"):
		# randomStats(0, 20)
		# calc_pay()
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

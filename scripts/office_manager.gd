extends Node

var SCENE_LEFT = 'left'
var SCENE_MONITOR = 'monitor'
var SCENE_RIGHT = 'right'

var CURRENT_SCENE = SCENE_MONITOR

@export var Camera_AnimationPlayer : AnimationPlayer
var CAP_finished = true

var looking_at_newspaper = false

@export var NewsPaper_AnimationPlayer : AnimationPlayer
var NPAP_finished = true

@onready var tutorial = $"../Tutorial"
@onready var Tutorial_AnimPlayer = $"../Tutorial/AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	Camera_AnimationPlayer.connect('animation_finished', CAPF)
	NewsPaper_AnimationPlayer.connect('animation_finished', NPAPF)
	Tutorial_AnimPlayer.connect("animation_finished", TAP)
	
	tutorial.visible = not SystemsManager.SEEN_TUTORIAL
	if not SystemsManager.SEEN_TUTORIAL:
		Tutorial_AnimPlayer.play("tutorial")

	if SystemsManager.IN_PORTABLE_MONITOR:
		SystemsManager.IN_PORTABLE_MONITOR = false
		print('Portable monitor close')
		Camera_AnimationPlayer.play('monitor-close-portable')
	else:
		Camera_AnimationPlayer.play('monitor-close')
	CAP_finished = false
	
	$"../Close".play()
	
	if SystemsManager.audio_hvac == null or not SystemsManager.audio_hvac.playing:
		SystemsManager.audio_hvac = $"../HVAC"
	if SystemsManager.audio_light == null or not SystemsManager.audio_light.playing:
		SystemsManager.audio_light = $"../Light"
	
	SystemsManager.error_sfx.connect(error_sfx)
	
	SystemsManager.shift_ended.connect(shift_ended)

@onready var error = $"../Error"

func error_sfx():
	if error.playing:
		error.stop()
	error.play()
	
func CAPF(anim_name):
	CAP_finished = true
	
	if anim_name.begins_with('monitor-open'):
		get_tree().change_scene_to_file("res://scenes/computer.tscn")
	elif anim_name.ends_with('-back'):
		get_tree().change_scene_to_file("res://scenes/pay_scene.tscn")

func NPAPF(_anim_name):
	NPAP_finished = true
	
func TAP(_anim_name):
	SystemsManager.SEEN_TUTORIAL = true
	tutorial.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if SystemsManager.audio_light.volume_db < 0:
		SystemsManager.audio_light.volume_db += 2
	
	if CAP_finished:
		if Input.is_action_just_released('left'):
			switchScene(SCENE_LEFT, SCENE_MONITOR); looking_at_newspaper = false;
			switchScene(SCENE_MONITOR, SCENE_RIGHT)
		elif Input.is_action_just_released('right'):
			switchScene(SCENE_RIGHT, SCENE_MONITOR)
			if not looking_at_newspaper:
				switchScene(SCENE_MONITOR, SCENE_LEFT)
		elif Input.is_action_just_released('accept'):
			if CURRENT_SCENE == SCENE_LEFT and not NewsPaper_AnimationPlayer == null and NPAP_finished:
				if not looking_at_newspaper and get_viewport().get_mouse_position().y > 599:
					NewsPaper_AnimationPlayer.play('pickup')
					set_looking_at_newspaper(true)
				elif looking_at_newspaper:
					NewsPaper_AnimationPlayer.play('putdown')
					set_looking_at_newspaper(false)
			
			if not SystemsManager.SEEN_TUTORIAL and CURRENT_SCENE == SCENE_MONITOR:
				Tutorial_AnimPlayer.play("skip")
			
			switchScene('open', SCENE_MONITOR)
		elif Input.is_action_just_released("back"):
			SystemsManager.IN_PORTABLE_MONITOR = true
			switchScene('open-portable', SCENE_MONITOR)

func set_looking_at_newspaper(value):
	NPAP_finished = false
	looking_at_newspaper = value

func switchScene(newScene, requiredScene):
	if CURRENT_SCENE == requiredScene and not Camera_AnimationPlayer == null:
		CURRENT_SCENE = newScene
		Camera_AnimationPlayer.play(requiredScene+'-'+newScene)
		CAP_finished = false
		print('Switched scene to ', newScene)

func shift_ended():
	switchScene('back', SCENE_LEFT)
	switchScene('back', SCENE_MONITOR)
	switchScene('back', SCENE_RIGHT)

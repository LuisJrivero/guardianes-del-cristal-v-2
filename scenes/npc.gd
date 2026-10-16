extends Node2D


@onready var Interactive_area: Area2D = $Interactiveárea
var player_nearby: bool = false

func _ready() -> void:
	Interactive_area.body_entered.connect(
		_on_area_2d_body_entered
	)
	Interactive_area.body_exited.connect(
		_on_area_2d_body_exited
	)

func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed('interact'):
		interact()
		
func interact() -> void:
	var dialogue_ui = get_tree().current_scene.get_node('DialogUI')
	if dialogue_ui.is_open:
		return

	var mensajes: Array[String] = []

	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			mensajes = [
				'Guard, Help me !',
				'The enemies have dispersed the three magic crystals around the city',
				'Recuperalos rapido y tráemelos antes de que se pierdan'
			]
			dialogue_ui.show_dialogue('Evo Morales', mensajes)
			QuestManager.start_quest()

		QuestManager.QuestState.ACTIVE:
			mensajes = [
				'There are still crystals missing',
				'You only found %d of %d' % [
					QuestManager.collect_crystal,
					QuestManager.required_crystals
				]
			]
			dialogue_ui.show_dialogue('Evo Morales', mensajes)

		QuestManager.QuestState.READY_TO_DELIVER:
			mensajes = [
				'Perfect, thank you so much for helping me',
				'You have recovered all the crystals in time',
				'Now we can activate the portal'
			]
			dialogue_ui.show_dialogue('Evo Morales', mensajes)
			QuestManager.complete_quest()

		QuestManager.QuestState.COMPLETED:
			mensajes = [
				'Thank you so much for your great help',
				'The portal is ready to be used',
				'Safe travels'
			]
			dialogue_ui.show_dialogue('Evo Morales', mensajes)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		player_nearby = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		player_nearby = false

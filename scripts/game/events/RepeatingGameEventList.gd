extends "res://scripts/game/events/GameEventList.gd"

func _new_instance():
	return RepeatingGameEvent.new()

func _handle_first_event_occurred():
	event_list[0].increase_occurrence_time()

func _handle_multiple_events_occurred(events_occurred: Array):
	for idx in events_occurred:
		event_list[idx].increase_occurrence_time()

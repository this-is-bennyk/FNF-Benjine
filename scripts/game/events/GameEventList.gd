extends Reference

const GameEvent = preload("res://scripts/game/events/GameEvent.gd")

enum SearchType {BY_INDEX, BY_TIME}

var event_list: Array

func _init():
	event_list = []

func add_event(event: GameEvent):
	event_list.append(event)

func add_event_sorted(event: GameEvent, search_type, units = 0):
	match search_type:
		SearchType.BY_TIME:
			_add_sorted_by_time(event)
		_:
			event_list.insert(units, event)

func remove_event(search_type, units, remove_all: bool = false):
	match search_type:
		SearchType.BY_TIME:
			_remove_by_time(units, remove_all)
		_:
			event_list.remove(units)

func update_events():
	if len(event_list) == 0:
		return
	
	_check_all_events()

func deserialize(level: Node, event_info_list: ResourceList):
	if !event_info_list || event_info_list.list.empty():
		return
	
	for event_info in event_info_list.list:
		var game_event = _new_instance()
		
		game_event.deserialize(level, event_info)
		add_event_sorted(game_event, SearchType.BY_TIME)

func _new_instance():
	return GameEvent.new()

func _add_sorted_by_time(new_event: GameEvent):
	if len(event_list) == 0:
		add_event(new_event)
		return
	elif new_event.occurrence_time < event_list[0].occurrence_time:
		event_list.push_front(new_event)
		return
	
	var idx_to_insert = 1
	
	for event in event_list:
		if new_event.occurrence_time >= event.occurrence_time:
			break
		else:
			idx_to_insert += 1
	
	# This shouldn't be the case (if we got to the last event, the idx should be
	# the size of the array), but we're checking just in case
	if idx_to_insert > len(event_list):
		idx_to_insert = len(event_list)
	
	event_list.insert(idx_to_insert, new_event)

func _remove_by_time(time_to_remove, remove_all: bool):
	var indices_to_remove = []
	
	for idx in len(event_list):
		if event_list[idx].occurrence_time == time_to_remove:
			indices_to_remove.append(idx)
			
			if !remove_all:
				break
	
	indices_to_remove.invert()
	
	for idx in indices_to_remove:
		event_list.remove(idx)

func _check_all_events():
	var events_occurred = []
	
	for idx in len(event_list):
		if event_list[idx].ready_to_occur():
			event_list[idx].occur()
			events_occurred.append(idx)
	
	_handle_multiple_events_occurred(events_occurred)

func _handle_multiple_events_occurred(events_occurred: Array):
	events_occurred.invert()
	
	for idx in events_occurred:
		event_list.remove(idx)

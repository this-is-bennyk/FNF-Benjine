extends Node

export(NodePath) var progress_bar_path

onready var progress_bar = get_node_or_null(progress_bar_path)

func update_progress(progress_val):
	if progress_bar:
		progress_bar.value = progress_val

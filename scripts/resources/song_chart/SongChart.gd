extends Resource
class_name SongChart, "res://scripts/resources/song_chart/song_chart_icon.svg"

enum ChartType {SNIFF, FNFVR, KADE_V6PLUS, PSYCH}

export(AudioStream) var instrumental = null
export(AudioStream) var vocals = null

export(float) var initial_bpm = 100
export(Array, Resource) var bpm_maps = []

export(float) var scroll_speed = 1

export(Dictionary) var lanes = {
	player = [],
	opponent = []
}

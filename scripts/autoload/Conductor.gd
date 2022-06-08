extends AudioStreamPlayer

signal quarter_hit(quarter)

enum Notes {SECONDS = -1, QUARTER, EIGHTH, SIXTEENTH}
enum Directions {LEFT, DOWN, UP, RIGHT}

const SAFE_FRAMES = 10
const SAFE_ZONE = SAFE_FRAMES / 60.0 # The amount of time (in seconds, assuming 60 FPS) before / after the note to be considered a valid hit
const COUNTDOWN_CONSTANT = -4 # The number of beats before a level song plays (for the 321GO! sequence)
const SPAWN_TIME_CONSTANT = 2 # Seconds to spawn a note before its strum time in seconds at a scroll speed of 1
const EARLY_HIT_MULT = 0.5

onready var vocals = $Vocals

var song_position: float = 0 # in seconds

var time_offset: float = 0
var event_position: float = 0

var previous_engine_time: int = 0
var last_reported_playhead_position: float = 0

# Assigned -1 to include 1st beat of the song
var last_quarter: int = -1

var scroll_speed: float = 1.0

var counting_down = false
var countdown_bpm: float = 0

# Contains a set of BPM maps. A BPM map transforms / maps song_position from one position of a song (in quarter notes) to another
# in a certain amount of time. The less time it takes to transform from one position to another, the faster the BPM.
var bpm_maps = []
var bpm_map_idx = 0

func _ready():
	set_process(false)

func play_music(music, bpm_):
	if playing:
		stop_song()
	
	stream = music
	
	reset_playhead()
	
	bpm_maps = [{
		end_beat = music.get_length() / get_seconds_per_beat(bpm_),
		bpm = bpm_,
		time = music.get_length()
	}]
	
	play()
	
	set_process(true)

func play_level_song(song_chart: SongChart, level_info: LevelInfo):
	if playing:
		stop_song()
	
	stream = level_info.instrumental_override if level_info.instrumental_override else song_chart.instrumental
	scroll_speed = song_chart.scroll_speed
	
	if song_chart.vocals:
		vocals.stream = level_info.vocals_override if level_info.vocals_override else song_chart.vocals
	vocals.volume_db = 0
	
	reset_playhead()
	
	bpm_maps = song_chart.bpm_maps
	
	play()
	if song_chart.vocals:
		vocals.play()
	
	set_process(true)

func play_level_song_with_countdown(song_chart: SongChart, level_info: LevelInfo):
	if playing:
		stop_song()
	
	scroll_speed = song_chart.scroll_speed
	countdown_bpm = song_chart.initial_bpm
	
	# Have to manually set song position to be 4 beats before the song starts
	song_position = (COUNTDOWN_CONSTANT - 1) * get_seconds_per_beat(countdown_bpm)
	
	time_offset = UserData.get_setting("time_offset", 0, "gameplay", "general") / 1000.0
	event_position = song_position - time_offset
	
	last_quarter = COUNTDOWN_CONSTANT - 1
	reset_time_at_last_update()
	
	counting_down = true
	set_process(true)
	
	connect("quarter_hit", self, "_wait_for_countdown_finish", [song_chart, level_info])

func _wait_for_countdown_finish(quarter, song_chart, level_info):
	if quarter < 0:
		return
	
	disconnect("quarter_hit", self, "_wait_for_countdown_finish")
	
	counting_down = false
	set_process(false)
	play_level_song(song_chart, level_info)

func stop_song():
	stop()
	vocals.stop()
	
	stream = null
	vocals.stream = null
	
	set_process(false)
	
	if is_connected("quarter_hit", self, "_wait_for_countdown_finish"):
		disconnect("quarter_hit", self, "_wait_for_countdown_finish")
		counting_down = false

func _process(_delta):
	update_time()
	
	var cur_quarter = get_quarter(true)
	# We check both greater than and not equal to since the song could loop,
	# meaning last quarter could be greater than cur_quarter
	if cur_quarter > last_quarter:
		emit_signal("quarter_hit", cur_quarter)
		last_quarter = cur_quarter

func update_time():
	var accurate_delta = (OS.get_ticks_usec() - previous_engine_time) / 1_000_000.0 * pitch_scale
	
	if counting_down:
		var countdown_length = COUNTDOWN_CONSTANT * get_seconds_per_beat(countdown_bpm)
		
		if song_position == (COUNTDOWN_CONSTANT - 1) * get_seconds_per_beat(countdown_bpm):
			song_position = clamp(countdown_length + accurate_delta, countdown_length, 0)
		else:
			song_position = clamp(song_position + accurate_delta, countdown_length, 0)
		
		event_position = song_position - time_offset
		
		reset_time_at_last_update()
		
	else:
		song_position = max(0, song_position + accurate_delta)
		event_position = song_position - time_offset
		reset_time_at_last_update()

		if get_playback_position() > last_reported_playhead_position:
			song_position = (song_position + get_playback_position()) / 2.0
			last_reported_playhead_position = get_playback_position()
		
		elif get_playback_position() < last_reported_playhead_position:
			reset_playhead()
			return
		
	if len(bpm_maps) > 0 && song_position > bpm_maps[bpm_map_idx].time && bpm_map_idx != len(bpm_maps) - 1:
		bpm_map_idx += 1

func get_beat(divisor, floored):
	var beat_lerp_val = 0
	var beat = 0
	
	if counting_down:
		beat_lerp_val = inverse_lerp(COUNTDOWN_CONSTANT * get_seconds_per_beat(countdown_bpm), 0, song_position)
		beat = lerp(COUNTDOWN_CONSTANT, 0, beat_lerp_val)
	else:
		var cur_bpm_map = bpm_maps[bpm_map_idx]
		
		var prev_end_beat = bpm_maps[bpm_map_idx - 1].end_beat if bpm_map_idx > 0 else 0
		var prev_time = bpm_maps[bpm_map_idx - 1].time if bpm_map_idx > 0 else 0
		
		beat_lerp_val = inverse_lerp(prev_time, cur_bpm_map.time, song_position)
		beat = lerp(prev_end_beat, cur_bpm_map.end_beat, beat_lerp_val)
		
	beat /= divisor
	
	if counting_down:
		return int(floor(beat)) if floored else beat
	return int(beat) if floored else beat

func get_bpm():
	if counting_down:
		return countdown_bpm
	if len(bpm_maps) > 0:
		return bpm_maps[bpm_map_idx].bpm
	
	# There is no default BPM but beat nodes start up automatically soooo
	# TODO: Figure out better solution for this
	return 60.0

func get_seconds_per_beat(bpm_ = null):
	if bpm_:
		return 60.0 / bpm_
	return 60.0 / get_bpm()

func get_quarter(floored):   return get_beat(1.0, floored)
func get_eighth(floored):    return get_beat(2.0, floored)
func get_sixteenth(floored): return get_beat(4.0, floored)

func get_quarter_length():   return get_seconds_per_beat()
func get_eighth_length():    return get_seconds_per_beat() / 2.0
func get_sixteenth_length(): return get_seconds_per_beat() / 4.0

func reset_playhead():
	song_position = 0
	
	time_offset = UserData.get_setting("time_offset", 0, "gameplay", "general") / 1000.0
	event_position = -time_offset
	
	last_quarter = -1
	
	reset_time_at_last_update()
	last_reported_playhead_position = 0
	
	bpm_map_idx = 0

func reset_time_at_last_update():
	previous_engine_time = OS.get_ticks_usec()

func set_pitch_scale(scale: float = 1):
	pitch_scale = scale
	vocals.pitch_scale = scale

#### Level Functions #################

# Seconds to spawn a note before its strum time in seconds, modified by scroll speed (higher scroll speed = less time to spawn = faster scroll)
func get_current_spawn_time(): return SPAWN_TIME_CONSTANT / scroll_speed
func get_relative_song_position(strum_time, before_hit):
	return inverse_lerp(strum_time - get_current_spawn_time(), strum_time, event_position) if before_hit \
	  else inverse_lerp(strum_time, strum_time + get_current_spawn_time(), event_position)

func is_note_in_safe_zone(strum_time):
	# If the note hasn't passed the strum line (early hit), the safe zone is reduced since
	# we'd rather hit notes later than earlier
	
	# If the song position is still before the note's strum time, check the early hit window
	if sign(strum_time - event_position) == 1:
		return strum_time - event_position < SAFE_ZONE * EARLY_HIT_MULT
	# Otherwise check the late hit window
	return event_position - strum_time < SAFE_ZONE

extends Node

export(NodePath) var gles3_particles_path = NodePath("ParticlesGLES3")
export(NodePath) var gles2_particles_path = NodePath("ParticlesGLES2")

var particles

func _ready():
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES3:
		particles = get_node(gles3_particles_path)
		get_node(gles2_particles_path).queue_free()
	else:
		particles = get_node(gles2_particles_path)
		get_node(gles3_particles_path).queue_free()
	
	particles.speed_scale = Conductor.pitch_scale

func restart():
	particles.restart()

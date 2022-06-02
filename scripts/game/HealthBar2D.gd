extends Line2D

func _ready():
	_adjust_for_downscroll()

func _adjust_for_downscroll():
	if !UserData.get_setting("downscroll", 0, "gameplay"):
		return
	
	position.y = 720 - position.y

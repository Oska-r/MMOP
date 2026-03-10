extends Label3D

func _ready() -> void:
	show()

func _process(_delta):
	UIHelper.rotate(self, 180)

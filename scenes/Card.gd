extends Node2D

signal hovered
signal hovered_off

var initial_scale: Vector2 = Vector2(1, 1)

func _on_mouse_entered():
	hovered.emit()

func _on_mouse_exited():
	hovered_off.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)

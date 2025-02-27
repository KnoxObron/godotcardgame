class_name AtlasCard
extends Node2D


enum CardPattern {
	Hearts = 0,
	Diamonds = 1,
	Clubs = 2,
	Spades = 3
}


signal on_mouse_hover
signal on_mouse_leave


@export var cardEffects: bool = true
@export_range(2, 14, int(1)) var cardValue: int:
	set(value):
		cardValue = clamp(value, 2, 14)
	get:
		return cardValue

@export var cardPattern: CardPattern
@onready var cardTexture: Sprite2D = $CardTexture
@onready var cardShadow: Sprite2D = $CardTexture/Shadow
@onready var cardArea2D: Area2D = $Area2D


var angle_x_max: float = 15.0
var angle_y_max: float = 15.0
var original_scale: Vector2
var hover_scale_factor: float = 1.1
var tween: Tween
var card_size: Vector2 = Vector2(256, 356)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_scale = scale
	
	cardArea2D.mouse_entered.connect(_on_area_2d_mouse_entered)
	cardArea2D.mouse_exited.connect(_on_area_2d_mouse_exited)
	if cardShadow:
		cardShadow.z_index = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	

func _on_area_2d_mouse_entered() -> void:
	on_mouse_hover.emit(self)
	if !cardEffects: return
	hover_parallax()
	

func hover_parallax() -> void:
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * hover_scale_factor, 0.15)


func reset_card() -> void:
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Reset scale
	tween.tween_property(self, "scale", original_scale, 0.2)


func _on_area_2d_mouse_exited() -> void:
	on_mouse_leave.emit(self)
	if !cardEffects: return
	self.reset_card()


func __eq__(card: AtlasCard) -> bool:
	return card.cardPattern == self.cardPattern && card.cardValue == self.cardValue


func _value_to_string() -> String:
	if cardValue < 11:
		return str(cardValue)
	elif cardValue == 11:
		return "Jack"
	elif cardValue == 12:
		return "Queen"
	elif cardValue == 13:
		return "King"
	elif cardValue == 14:
		return "Ace"
	else:
		return str('2')


func _pattern_to_string() -> String:
	if cardPattern == CardPattern.Hearts:
		return "Hearts"
	elif cardPattern == CardPattern.Diamonds:
		return "Diamonds"
	elif cardPattern == CardPattern.Clubs:
		return "Clubs"
	elif cardPattern == CardPattern.Spades:
		return "Spades"
	return "Unknown"


func _to_string() -> String:
	return "{_} of {_}".format([_value_to_string(), _pattern_to_string()])

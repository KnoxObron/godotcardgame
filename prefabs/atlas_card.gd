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
signal on_mouse_click
signal on_mouse_release


@export var cardEffects: bool = true
@export_range(2, 14, int(1)) var cardValue: int = 2:
	set(value):
		cardValue = clamp(value, 2, 14)
		update_texture()
	get:
		return cardValue

@export var cardPattern: CardPattern = CardPattern.Hearts:
	set(value):
		cardPattern = value
		update_texture()
	get:
		return cardPattern

@onready var cardTexture: Sprite2D = $CardTexture
@onready var cardShadow: Sprite2D = $CardTexture/Shadow
@onready var cardArea2D: Area2D = $Area2D

var _texture_initialized: bool = false
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
	cardArea2D.input_event.connect(_on_area_2d_input_event)
	if cardShadow:
		cardShadow.z_index = -1
	_texture_initialized = true
	update_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_texture() -> void:
	if !_texture_initialized || !cardTexture || !is_instance_valid(cardTexture):
		return
	
	if cardTexture.texture is AtlasTexture:
		var atlas = cardTexture.texture as AtlasTexture
		
		# Update X position based on card value
		var x_position = 0
		if cardValue % 13 != 0:
			x_position = (cardValue - 1) * card_size.x
		
		# Update Y position based on card pattern
		var y_position = 0
		match cardPattern:
			CardPattern.Clubs:
				y_position = 0 * card_size.y
			CardPattern.Hearts:
				y_position = 1 * card_size.y
			CardPattern.Spades:
				y_position = 2 * card_size.y
			CardPattern.Diamonds:
				y_position = 3 * card_size.y
		
		atlas.region.position = Vector2(x_position, y_position)


func _on_area_2d_mouse_entered() -> void:
	on_mouse_hover.emit(self)
	if !cardEffects: return
	hover_parallax()


func _on_area_2d_mouse_exited() -> void:
	on_mouse_leave.emit(self)
	if !cardEffects: return
	self.reset_parallax()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				on_mouse_click.emit(self)
			else:
				on_mouse_release.emit(self)


func hover_parallax() -> void:
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * hover_scale_factor, 0.15)


func reset_parallax() -> void:
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Reset scale
	tween.tween_property(self, "scale", original_scale, 0.2)


# Comparison operators
func __eq__(card: AtlasCard) -> bool:
	return cardPattern == card.cardPattern && cardValue == card.cardValue

func __lt__(card: AtlasCard) -> bool:
	return self.cardValue < card.cardValue && self.cardPattern < card.cardPattern
	
func __gt__(card: AtlasCard) -> bool:
	return self.cardValue > card.cardValue && self.cardPattern > card.cardPattern

func __le__(card: AtlasCard) -> bool:
	return self.cardValue <= card.cardValue && self.cardPattern <= card.cardPattern
	
func __ge__(card: AtlasCard) -> bool:
	return self.cardValue >= card.cardValue && self.cardPattern >= card.cardPattern


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

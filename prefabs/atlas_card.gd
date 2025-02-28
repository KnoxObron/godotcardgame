## A 2D card node for card games that uses an AtlasTexture to represent different cards.
## Provides card comparison operations, interactive hover effects, and mouse event handling.
class_name AtlasCard
extends Node2D

## Enum representing the four card suits/patterns
enum CardPattern {
	Hearts = 0,
	Diamonds = 1,
	Clubs = 2,
	Spades = 3
}

## Emitted when the mouse enters the card area
signal on_mouse_hover
## Emitted when the mouse exits the card area
signal on_mouse_leave
## Emitted when the left mouse button is pressed on the card
signal on_mouse_click
## Emitted when the left mouse button is released on the card
signal on_mouse_release

## Whether visual card effects are enabled
@export var cardEffects: bool = true
## The card's data
@export var data: CardData
## The sprite displaying the card texture
@onready var _cardTexture: Sprite2D = $CardTexture
## Optional shadow effect under the card
@onready var _cardShadow: Sprite2D = $CardTexture/Shadow
## Collision area for mouse interaction
@onready var _cardArea2D: Area2D = $Area2D

## Flag to track if the texture is ready for modification
var _texture_initialized: bool = false
## Original scale of the card
var _original_scale: Vector2
## How much the card scales when hovered
var _hover_scale_factor: float = 1.1
## Tween for animation effects
var _tween: Tween
## Size of each card in the atlas texture (width x height)
var _card_size: Vector2 = Vector2(256, 356)


## Initialize the card node
func _ready() -> void:
	_original_scale = scale
	_cardArea2D.mouse_entered.connect(_on_area_2d_mouse_entered)
	_cardArea2D.mouse_exited.connect(_on_area_2d_mouse_exited)
	_cardArea2D.input_event.connect(_on_area_2d_input_event)
	
	if _cardShadow:
		_cardShadow.z_index = -1
		_texture_initialized = true
	update_texture()


func _process(delta: float) -> void:
	pass
	

func _init():
	self.data.randomize()


## Updates the AtlasTexture region based on the current card value and pattern
func update_texture() -> void:
	if !_texture_initialized || !_cardTexture || !is_instance_valid(_cardTexture):
		return
	
	if _cardTexture.texture is AtlasTexture:
		var atlas: AtlasTexture = _cardTexture.texture as AtlasTexture
		
		var x_position: int = 0
		if data.value % 13 != 0:
			x_position = int((data.value - 1) * _card_size.x)
		
		var y_position: int = 0
		match data.pattern:
			CardPattern.Clubs:
				y_position = int(0 * _card_size.y)
			CardPattern.Hearts:
				y_position = int(1 * _card_size.y)
			CardPattern.Spades:
				y_position = int(2 * _card_size.y)
			CardPattern.Diamonds:
				y_position = int(3 * _card_size.y)
		
		atlas.region.position = Vector2(x_position, y_position)


## Handler for mouse entering the card area
func _on_area_2d_mouse_entered() -> void:
	on_mouse_hover.emit(self)
	if !cardEffects: return
	_hover_parallax()


## Handler for mouse exiting the card area
func _on_area_2d_mouse_exited() -> void:
	on_mouse_leave.emit(self)
	if !cardEffects: return
	self._reset_parallax()


## Handler for mouse input events on the card
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				on_mouse_click.emit(self)
			else:
				on_mouse_release.emit(self)


## Scales the card when hovered to create a visual effect
func _hover_parallax() -> void:
	# Cancel any existing tween
	if _tween:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _original_scale * _hover_scale_factor, 0.15)


## Resets the card to its original scale after hover effects
func _reset_parallax() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	_tween.tween_property(self, "scale", _original_scale, 0.2)


## Checks if two cards have the same value and pattern
func __eq__(card: AtlasCard) -> bool:
	return self.data.compare_to(card.data) == 0

## Checks if this card's value and pattern are both less than another's
func __lt__(card: AtlasCard) -> bool:
	return self.data.compare_to(card.data) < 0
	
## Checks if this card's value and pattern are both greater than another's
func __gt__(card: AtlasCard) -> bool:
	return self.data.compare_to(card.data) > 0

## Checks if this card's value and pattern are both less than or equal to another's
func __le__(card: AtlasCard) -> bool:
	return self.data.compare_to(card.data) <= 0
	
## Checks if this card's value and pattern are both greater than or equal to another's
func __ge__(card: AtlasCard) -> bool:
	return self.data.compare_to(card.data) >= 0


## Returns a string representation of the card value
func _value_to_string() -> String:
	if data.value < 11:
		return str(data.value)
	elif data.value == 11:
		return "Jack"
	elif data.value == 12:
		return "Queen"
	elif data.value == 13:
		return "King"
	elif data.value == 14:
		return "Ace"
	else:
		return str('2')


## Returns a string representation of the card pattern
func _pattern_to_string() -> String:
	if data.pattern == CardPattern.Hearts:
		return "Hearts"
	elif data.pattern == CardPattern.Diamonds:
		return "Diamonds"
	elif data.pattern == CardPattern.Clubs:
		return "Clubs"
	elif data.pattern == CardPattern.Spades:
		return "Spades"
	return "Unknown"


## Returns a full string representation of the card (e.g., "Queen of Hearts")
func _to_string() -> String:
	return "{_} of {_}".format([_value_to_string(), _pattern_to_string()])

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
## The card's value (2-14, where 11=Jack, 12=Queen, 13=King, 14=Ace)
@export_range(2, 14, int(1)) var cardValue: int = 2:
	set(value):
		cardValue = clamp(value, 2, 14)
		update_texture()
	get:
		return cardValue

## The card's suit (Hearts, Diamonds, Clubs, Spades)
@export var cardPattern: CardPattern = CardPattern.Hearts:
	set(value):
		cardPattern = value
		update_texture()
	get:
		return cardPattern

## The sprite displaying the card texture
@onready var cardTexture: Sprite2D = $CardTexture
## Optional shadow effect under the card
@onready var cardShadow: Sprite2D = $CardTexture/Shadow
## Collision area for mouse interaction
@onready var cardArea2D: Area2D = $Area2D

## Flag to track if the texture is ready for modification
var _texture_initialized: bool = false
## Original scale of the card
var original_scale: Vector2
## How much the card scales when hovered
var hover_scale_factor: float = 1.1
## Tween for animation effects
var tween: Tween
## Size of each card in the atlas texture (width x height)
var card_size: Vector2 = Vector2(256, 356)


## Initialize the card node
func _ready() -> void:
	original_scale = scale
	cardArea2D.mouse_entered.connect(_on_area_2d_mouse_entered)
	cardArea2D.mouse_exited.connect(_on_area_2d_mouse_exited)
	cardArea2D.input_event.connect(_on_area_2d_input_event)
	if cardShadow:
		cardShadow.z_index = -1
	_texture_initialized = true
	update_texture()


func _process(delta: float) -> void:
	pass


## Updates the AtlasTexture region based on the current card value and pattern
func update_texture() -> void:
	if !_texture_initialized || !cardTexture || !is_instance_valid(cardTexture):
		return
	
	if cardTexture.texture is AtlasTexture:
		var atlas = cardTexture.texture as AtlasTexture
		
		var x_position = 0
		if cardValue % 13 != 0:
			x_position = (cardValue - 1) * card_size.x
		
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


## Handler for mouse entering the card area
func _on_area_2d_mouse_entered() -> void:
	on_mouse_hover.emit(self)
	if !cardEffects: return
	hover_parallax()


## Handler for mouse exiting the card area
func _on_area_2d_mouse_exited() -> void:
	on_mouse_leave.emit(self)
	if !cardEffects: return
	self.reset_parallax()


## Handler for mouse input events on the card
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				on_mouse_click.emit(self)
			else:
				on_mouse_release.emit(self)


## Scales the card when hovered to create a visual effect
func hover_parallax() -> void:
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * hover_scale_factor, 0.15)


## Resets the card to its original scale after hover effects
func reset_parallax() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", original_scale, 0.2)


## Checks if two cards have the same value and pattern
func __eq__(card: AtlasCard) -> bool:
	return cardPattern == card.cardPattern && cardValue == card.cardValue

## Checks if this card's value and pattern are both less than another's
func __lt__(card: AtlasCard) -> bool:
	return self.cardValue < card.cardValue && self.cardPattern < card.cardPattern
	
## Checks if this card's value and pattern are both greater than another's
func __gt__(card: AtlasCard) -> bool:
	return self.cardValue > card.cardValue && self.cardPattern > card.cardPattern

## Checks if this card's value and pattern are both less than or equal to another's
func __le__(card: AtlasCard) -> bool:
	return self.cardValue <= card.cardValue && self.cardPattern <= card.cardPattern
	
## Checks if this card's value and pattern are both greater than or equal to another's
func __ge__(card: AtlasCard) -> bool:
	return self.cardValue >= card.cardValue && self.cardPattern >= card.cardPattern


## Returns a string representation of the card value
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


## Returns a string representation of the card pattern
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


## Returns a full string representation of the card (e.g., "Queen of Hearts")
func _to_string() -> String:
	return "{_} of {_}".format([_value_to_string(), _pattern_to_string()])

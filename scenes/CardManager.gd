extends Node2D

const COLLISION_MASK_CARD = 1

var atlas_image = preload("res://assets/Cards.jpg")

var is_hovering_on_card

var card_width = 256
var card_height = 356

var CardScene = preload("res://scenes/Card.tscn")

var screen_size: Vector2
var card_being_dragged: Node2D = null


func _ready() -> void:
	screen_size = get_viewport_rect().size
	var scale_factor = min(screen_size.x / (13 * card_width), screen_size.y / (4 * card_height))
	scale_factor = clamp(scale_factor, 0.3, 1.0)
	create_all_cards(scale_factor)



func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0,screen_size.x),
			clamp(mouse_pos.y, 0,screen_size.y)
			)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag(card_being_dragged)
			
func start_drag(card):
	card_being_dragged = card
	card.scale = card.initial_scale


func finish_drag(card):
	card_being_dragged.scale = card.initial_scale
	card_being_dragged = null

func create_all_cards(scale_factor: float):
	var horizontal_spacing = card_width * scale_factor * 1.1  # 水平间距
	var vertical_spacing = card_height * scale_factor * 1.1
	
	for i in range(52):
		var card = create_card(i, Vector2(
			(i % 13) * horizontal_spacing,
			(i / 13) * vertical_spacing
		), scale_factor)
		add_child(card)
		connect_card_signals(card)

func create_card(card_index: int, position: Vector2, scale_factor: float) -> Node2D:
	var card = CardScene.instantiate()
	card.position = position
	card.scale = Vector2(scale_factor, scale_factor)
	card.initial_scale = Vector2(scale_factor, scale_factor)
	
	
	var card_image = card.get_node("CardImage")
	card_image.texture = get_card_texture(card_index)
	
	return card


func get_card_texture(card_index: int) -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = atlas_image
	atlas_texture.region = get_card_region(card_index)
	return atlas_texture

func get_card_region(card_index: int) -> Rect2:
	var row = card_index / 13  # Row (0-3)
	var col = card_index % 13  # Column (0-12)
	return Rect2(col * card_width, row * card_height, card_width, card_height)

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
			is_hovering_on_card = true
		else: 
			is_hovering_on_card = false
	

func highlight_card(card, hovered):
	if hovered && !card_being_dragged:
		card.scale = card.initial_scale * 1.05 
		card.z_index = 2
	else:
		card.scale = card.initial_scale
		card.z_index = 1

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card 

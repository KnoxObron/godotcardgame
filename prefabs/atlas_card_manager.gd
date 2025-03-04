class_name AtlasCardManager
extends Node2D

func create_card(card_value: int, card_pattern: int) -> AtlasCard:
	var card = AtlasCard.new()
	card.cardValue = card_value
	card.cardPattern = card_pattern
	return card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
static func shuffle_deck(deck: Array) -> Array:
	var shuffled_deck: Array = deck.duplicate()
	shuffled_deck.shuffle()
	return shuffled_deck
	
	
static func sort_deck(deck: Array) -> Array:
	var sorted_deck: Array = deck.duplicate()
	sorted_deck.sort()
	return sorted_deck
	
	
static func distribute_cards(players: int, cardsPerPlayer: int = 5):
	var deck: Array[CardData] = []
	var holdings: Array = []
	
	for i in players:
		var cards: Array[CardData] = []
		for j in cardsPerPlayer:
			var card: CardData = CardData.new(2, CardData.CardPattern.Hearts).randomize_card()
			while card in deck:
				card = CardData.new(2, CardData.CardPattern.Hearts).randomize_card()
			deck.append(card)
			cards.append(card)
		
		holdings.append(cards)
	return holdings
	
	

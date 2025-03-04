extends Node
class_name CardData

signal on_data_changed

## Enum representing the four card suits/patterns
enum CardPattern {
	Hearts = 0,
	Diamonds = 1,
	Clubs = 2,
	Spades = 3
}

## The card's value (2-14, where 11=Jack, 12=Queen, 13=King, 14=Ace)
@export_range(2, 14, 1) var cardValue: int = 2:
	set(value):
		cardValue = clamp(value, 2, 14)
		self.on_data_changed.emit(self)
	get:
		return cardValue

## The card's suit (Hearts, Diamonds, Clubs, Spades)
@export var cardPattern: CardPattern = CardPattern.Hearts:
	set(value):
		cardPattern = value
		self.on_data_changed.emit(self)
	get:
		return cardPattern
		
		
func _init(pValue: int, pPattern: CardPattern) -> void:
	self.cardValue = pValue
	self.cardPattern = pPattern


# Add this to your CardData class
func compare_to(other: CardData) -> int:
	if self.cardValue > other.cardValue:
		return 1
	elif self.cardValue < other.cardValue:
		return -1
	else:
		# Same value, compare patterns
		if self.cardPattern > other.cardPattern:
			return 1
		elif self.cardPattern < other.cardPattern:
			return -1
		else:
			return 0  # Equal cards


func randomize_card() -> CardData:
	self.cardValue = randi_range(2, 14)
	self.cardPattern = CardPattern.values()[randi_range(0, 3)]
	return self
	

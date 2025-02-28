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
@export_range(2, 14, int(1)) var value: int = 2:
	set(value):
		self.value = clamp(value, 2, 14)
		self.on_data_changed.emit(self)
	get:
		return value

## The card's suit (Hearts, Diamonds, Clubs, Spades)
@export var pattern: CardPattern = CardPattern.Hearts:
	set(value):
		self.pattern = value
		self.on_data_changed.emit(self)
	get:
		return pattern
		
		
func _init(pValue: int, pPattern: CardPattern) -> void:
	self.value = pValue
	self.pattern = pPattern


# Add this to your CardData class
func compare_to(other: CardData) -> int:
	if self.value > other.value:
		return 1
	elif self.value < other.value:
		return -1
	else:
		# Same value, compare patterns
		if self.pattern > other.pattern:
			return 1
		elif self.pattern < other.pattern:
			return -1
		else:
			return 0  # Equal cards


func randomize() -> CardData:
	self.data.value = randi_range(2, 14)
	self.data.pattern = CardPattern.values()[randi_range(0, 3)]
	return self

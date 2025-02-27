# AtlasCard

A 2D card node for card games that uses an AtlasTexture to represent different cards. Provides card comparison operations, interactive hover effects, and mouse event handling.

## Description

`AtlasCard` is a specialized Node2D class designed for card games. It uses an AtlasTexture to display different card values and patterns (suits) from a sprite atlas. The class provides built-in mouse interaction effects including hover scaling, comparison operators for card values, and various signals for mouse events.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `cardEffects` | bool | Whether visual card effects are enabled. |
| `cardValue` | int | The card's value (2-14, where 11=Jack, 12=Queen, 13=King, 14=Ace). |
| `cardPattern` | CardPattern | The card's suit (Hearts, Diamonds, Clubs, Spades). |
| `card_size` | Vector2 | Size of each card in the atlas texture (256×356 pixels by default). |
| `hover_scale_factor` | float | How much the card scales when hovered (1.1 by default). |

## Nodes

| Node | Type | Description |
|------|------|-------------|
| `cardTexture` | Sprite2D | The sprite displaying the card texture. |
| `cardShadow` | Sprite2D | Optional shadow effect under the card. |
| `cardArea2D` | Area2D | Collision area for mouse interaction. |

## Signals

| Signal | Parameters | Description |
|--------|------------|-------------|
| `on_mouse_hover` | self | Emitted when the mouse enters the card area. |
| `on_mouse_leave` | self | Emitted when the mouse exits the card area. |
| `on_mouse_click` | self | Emitted when the left mouse button is pressed over the card. |
| `on_mouse_release` | self | Emitted when the left mouse button is released over the card. |

## Methods

### `update_texture()`
Updates the AtlasTexture region based on the current card value and pattern.

### `hover_parallax()`
Scales the card when hovered to create a visual effect.

### `reset_parallax()`
Resets the card to its original scale after hover effects.

### `_value_to_string() -> String`
Returns a string representation of the card value (e.g., "2", "Jack", "Queen", etc.).

### `_pattern_to_string() -> String`
Returns a string representation of the card pattern (e.g., "Hearts", "Clubs", etc.).

### `_to_string() -> String`
Returns a full string representation of the card (e.g., "Queen of Hearts").

## Comparison Operators

`AtlasCard` implements the following comparison operators to allow direct comparison between cards:

| Operator | Method | Description |
|----------|--------|-------------|
| `==` | `__eq__` | Checks if two cards have the same value and pattern. |
| `<` | `__lt__` | Checks if this card's value and pattern are both less than another's. |
| `>` | `__gt__` | Checks if this card's value and pattern are both greater than another's. |
| `<=` | `__le__` | Checks if this card's value and pattern are both less than or equal to another's. |
| `>=` | `__ge__` | Checks if this card's value and pattern are both greater than or equal to another's. |

## Usage Example

```gdscript
# Create a new card instance
var card = AtlasCard.new()
card.cardValue = 12 # Queen
card.cardPattern = AtlasCard.CardPattern.Hearts

# Connect to signals
card.on_mouse_click.connect(_on_card_clicked)

# Compare cards
if card > other_card:
	print("Card is higher!")

# Get string representation
print(card) # Outputs: "Queen of Hearts"
```

## Notes

- The card texture should be set up as an AtlasTexture with all cards in a grid.
- The default grid size is 256×356 pixels per card.
- The card values in the atlas should be arranged horizontally (by value) and vertically (by suit).
- Make sure to add a proper CollisionShape2D to the Area2D node for mouse interaction to work.

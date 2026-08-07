class_name Deck extends CardHolder

## The cards in the draw pile.
var _draw_pile:Array[Card]
func get_draw_pile() -> Array[Card]: return _draw_pile.duplicate()

## The cards in the discard pile.
var _discard_pile:Array[Card]
func get_discard_pile() -> Array[Card]: return _discard_pile.duplicate()

## The cards currently unaccounted for (assumedly in a Hand).
var _unaccounted_pile:Array[Card]
func get_unaccounted_pile() -> Array[Card]: return _unaccounted_pile.duplicate()

func _init(set_contents:Array[Card]):
	_discard_pile = set_contents
	for card:Card in set_contents: card._holder = weakref(self)
	shuffle_discard()

## Shuffle the discard back into the draw pile.
func shuffle_discard() -> void:
	
	_discard_pile.shuffle()     # Shuffle
	
	_draw_pile += _discard_pile # into draw pile
	
	_discard_pile = []          # and clear.

## Discard a card
func discard(card:Card) -> void:
	
	_draw_pile.erase(card) ## Just in case we're discarding straight from the draw pile.

	_unaccounted_pile.erase(card) ## Just in case we're discarding from the unnacounted pile.
	
	card._holder = weakref(self) ## Card's goin' in the discard, so it belongs to this now.
	
	_discard_pile.append(card) ## Add to the discard pile.

## Draw a card from the draw pile, and return it.
## The drawer is responsible for discarding the card.
func draw() -> Card:
	
	## Nothin' to draw, shuffle the discard before trying to draw.
	if _draw_pile.size() <= 0:
		shuffle_discard()
	
	var card := _draw_pile.pop_front() as Card
	
	_unaccounted_pile.append(card)
	
	return card

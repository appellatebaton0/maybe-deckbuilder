class_name Hand extends CardHolder

var _contents:Array[Card]
func get_contents() -> Array[Card]: return _contents.duplicate()
var deck:Deck

func _init(set_deck:Deck = null): 
	if set_deck: deck = set_deck

## 'n then we just sorta decorate the Deck.

func discard(card:Card) -> void:
	if not deck: return
	
	deck.discard(card)
	
	_contents.erase(card)

func draw() -> Card:
	if not deck: return null
	
	var card := deck.draw()
	
	_contents.append(card)
	
	card._holder = weakref(self)
	
	return card

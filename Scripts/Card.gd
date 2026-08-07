@abstract class_name Card extends Resource
## A card. Duh.

## The traits pertaining to this card.
@abstract func get_traits() -> Array[Trait]

## The holder of the card, whether a Deck or a Hand (CardSet classes)
var _holder:WeakRef
func get_holder() -> CardHolder: return _holder.get_ref()

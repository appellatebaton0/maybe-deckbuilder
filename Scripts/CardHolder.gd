@abstract
class_name CardHolder extends Resource
## A resource that somehow holds a set of cards.

signal contents_changed

@abstract func discard(card:Card) -> void
@abstract func draw() -> Card

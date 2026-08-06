@abstract class_name BaseCard extends Card
## A card played in the Base phase that gives a static *amount* of Shapes,
## not necessarily a static type.

## The name and desc of the card.
@abstract func get_card_name() -> String
@abstract func get_description() -> String

## Apply the 

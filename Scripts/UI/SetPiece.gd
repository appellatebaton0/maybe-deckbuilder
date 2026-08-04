@abstract
class_name SetPiece extends Control
## Might-as-well try out a new idea for UI transitions. We like to have fun here.
## A major piece of UI that will need to be transitioned from or to.

#region Signals
# Signals for transitions ending.
signal transition_out_started
signal transition_in_started
signal transition_started

# Signals for transitions starting
signal transition_out_ended
signal transition_in_ended
signal transition_ended
#endregion

## Whether this set piece is currently within the user's view.
## Stops transitioning in a piece that's already in, if nothing else.
@export var exposed := false 

## All set pieces have access to each other, and are identified by their subclass name.
## There can only be one of each class_name; This functionally makes each SetPiece a singleton.
static var set_contents:Dictionary[StringName, SetPiece]
func _init() -> void: 
	## Get the subclass script.
	var script := get_script() as Script
	if not script: return
	
	## Get the subclass's class_name
	var script_name := script.get_global_name()
	if script_name == "": return
	
	## Add to the list.
	if not set_contents.has(script_name): set_contents[script_name] = self
	else: free() ## Invalid new instance of the singleton. Free *immediately*.

## Transition between one SetPiece to another. Since this's static, it can be called from anywhere!
## Can also use `await transition()` to hold off code until the transition finishes.
## Since this is an args function, you can even go between unrelated screens A & E via transition(a,b,c,d,e) etc.
static func transition(...args:Array[Variant]) -> void:
	
	## Parse the given values into SetPieces and store em.
	var set_pieces:Array[SetPiece]
	
	for argument in args:
		var value := _parse_to_set_piece(argument)
		set_pieces.append(value)
	
	for i in set_pieces.size():
		var piece := set_pieces[i]
		
		# We allow null values so the user can do transition(null, a) for transitioning in,
		# and transition(a, null) for transitioning out safely.
		if not piece: continue 
		
		## The first argument is assumed to already be transitioned in.
		if i > 0 and not piece.exposed:
			# Not the first arg (and not exposed), transition in.
			piece.transition_out_started.emit()
			piece.transition_started.emit()
			
			@warning_ignore("redundant_await") # The code doesn't know the functions will have awaits in them.
			await piece._transition_out() # Do the actual transition. The rest is signals.
			
			piece.transition_out_ended.emit()
			piece.transition_ended.emit()
			
			piece.exposed = true
		
		## The last argument is assumed to not need to be transitioned out.
		if i < set_pieces.size() - 1 and piece.exposed:
			# Not the last arg (and exposed), transition out.
			piece.transition_in_started.emit()
			piece.transition_started.emit()
			
			@warning_ignore("redundant_await") # The code doesn't know the functions will have awaits in them.
			await piece._transition_in() # Do the actual transition. The rest is signals.
			
			piece.transition_in_ended.emit()
			piece.transition_ended.emit()
			
			piece.exposed = false
## Turns a StringName/SetPiece variant into a SetPiece. Typecasting!
static func _parse_to_set_piece(value:Variant) -> SetPiece:
	if value is SetPiece:                               return value
	if value is StringName and set_contents.has(value): return set_contents[value]
	return null

## Functions for transitioning in and out the given set piece.
## These should never be called from outside the class; use the transition func instead.
@abstract func _transition_in() -> void
@abstract func _transition_out() -> void

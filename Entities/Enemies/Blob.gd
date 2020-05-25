extends KinematicBody2D


# Node references
var player

# Random number generator
var rng = RandomNumberGenerator.new()

# Movement variables
export var speed = 125
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0


func _ready():
	player = get_tree().root.get_node("Root/Player")
	rng.randomize()


func _on_Timer_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position
	
	if player_relative_position.length() <= 20:
		# If player is near, don't move but turn toward it
		direction = Vector2.DOWN
		last_direction = player_relative_position.normalized()
	elif player_relative_position.length() <= 1000 and bounce_countdown == 0:
		# If player is within range, move toward it
		# This highly complex algorithm changes the position of Blob so, that it does no go in straight line
		# TODO: will later be added when the player gets a gun and attempts to shoot the green guy :(
		var random_number = rng.randi() % 100
		if random_number < 5:
			direction = Vector2.DOWN.rotated(14 * PI)
		if random_number > 95:
			direction = Vector2.DOWN.rotated(4 * PI)
		if random_number > 5 and  random_number < 95:
			direction = player_relative_position.normalized()
			
	elif bounce_countdown == 0:
		# If player is too far, randomly decide whether to stand still or where to move
		var random_number = rng.randf()
		if random_number < 0.05:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
	
	# Update bounce countdown
	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1
		
		
func _physics_process(delta):
	var movement = direction * speed * delta
	
	var collision = move_and_collide(movement)
	#if there has been a collision with a body other than Player the current direction of movement is rotated by a randomly generated angle
	if collision != null and collision.collider.name != "Player":
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)


func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"
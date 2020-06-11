extends KinematicBody2D

signal death
# Node references
var player
var blob
# Random number generator
var rng = RandomNumberGenerator.new()
# Movement variables
export var speed = 125
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0
var other_animation_playing = false
# Blob stats
var health = 100
var health_max = 100
var health_regeneration = 1


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
	elif player_relative_position.length() <= 10000 and bounce_countdown == 0:
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
	if collision != null and collision.collider.name != "Player" and collision.collider.name != "Blob":
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)
		hit(20)
	

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


func arise():
	other_animation_playing = true
	$AnimatedSprite.play("idle")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "idle":
		$AnimatedSprite.animation = "idle"
		$Timer.start()
	elif $AnimatedSprite.animation == "death":
		get_tree().queue_delete(self)
		$AnimatedSprite.animation = "death"
	other_animation_playing = false
	
	
func _process(delta):
	# Regenerates health
	health = min(health + health_regeneration * delta, health_max)
	
func hit(damage):
	health -= damage
	if health > 0:
		$AnimationPlayer.play("Hit")
	else:
		$Timer.stop()
		direction = Vector2.ZERO
		set_process(false)
		other_animation_playing = true
		#TODO: add death animation
		$CollisionShape2D.disabled = true
		$AnimatedSprite.play("death")
		emit_signal("death")


extends KinematicBody2D
#signal hit
signal player_stats_changed

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var npc

var direction : Vector2

# Player stats
var health = 100
var health_max = 100
var health_regeneration = 6
var mana = 100
var mana_max = 100
var mana_regeneration = 12
var attack_playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	emit_signal("player_stats_changed", self)


func _process(delta):
	
	#Rotating the player where the mouse is pointing
	var target_angle = 0
	var turn_speed = deg2rad(77)
	var dir = get_angle_to(get_global_mouse_position())
	if abs(dir) < turn_speed:
		rotation += dir
	else:
		if dir>0: rotation += turn_speed #clockwise
		if dir<0: rotation -= turn_speed #anit - clockwise
	
	var velocity = Vector2()  # The player's movement vector.
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	# Apply movement
	var movement = speed * velocity * delta
	move_and_slide(velocity)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.flip_v = false
		# See the note below about boolean assignment
		$AnimatedSprite.flip_h = velocity.x < 0
	
	# Regenerates player mana
	var new_mana = min(mana + mana_regeneration * delta, mana_max)
	if new_mana != mana:
		mana = new_mana
		emit_signal("player_stats_changed", self)

	# Regenerates player health
	var new_health = min(health + health_regeneration * delta, health_max)
	if new_health != health:
		health = new_health
		emit_signal("player_stats_changed", self)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation != 'run':
		$AnimatedSprite.play('idle')


func _input(event):
	if event.is_action_pressed("attack"):
		attack_playing = true
					#var animation = get_animation_direction(last_direction) + "_attack"
					#$Sprite.play(animation)
		#TODO Add attack animation
		$AnimatedSprite.play('idle')
	elif event.is_action_pressed("ui_right"): # needs a shoot animation and key
		if mana >= 25:
			mana = mana - 25
			emit_signal("player_stats_changed", self)
			#attack_playing = true
			#TODO Add shot animation
			#var animation = get_animation_direction(last_direction) + "_fireball"
			#$Sprite.play(animation)


func _physics_process(delta):
	
	var movement = direction * speed * delta
	var collision = move_and_collide(movement)
	
	# checks if the player collided with a Blob
	if collision != null and "Blob" in collision.collider.name:
		health = health - 5
		print(health)
		print(collision.collider.name)
		emit_signal("player_stats_changed", self)

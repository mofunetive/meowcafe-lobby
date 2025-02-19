extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	var direction: Vector2 = GameInputEvent.movement_input()


	if direction == Vector2.UP:
		animated_sprite_2d.play("walk_back")
	elif direction == Vector2.RIGHT:
		animated_sprite_2d.play("walk_right")
	elif direction == Vector2.DOWN:
		animated_sprite_2d.play("walk_front")
	elif direction == Vector2.LEFT:
		animated_sprite_2d.play("walk_left")


	if direction != Vector2.ZERO:
		player.player_direction = direction

	var current_speed = player.run_speed if Input.is_action_pressed("run") else player.walk_speed
	player.velocity = direction * current_speed
	player.move_and_slide()

func _on_next_transitions() -> void:
	if !GameInputEvent.is_movement_input():
		transition.emit("Idle")
	elif not Input.is_action_pressed("run"):
		transition.emit("Walk")

func _on_enter() -> void:
	pass

func _on_exit() -> void:
	pass

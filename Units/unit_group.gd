extends CharacterBody2D

enum State { GOING, WAITING, RETURNING }

@export var speed: float = 50.0
@export var wait_time: float = 1.0
@export var damage: int = 10

@onready var wait_timer:Timer = $WaitTimer

var base: Area2D
var village: Village
var state: State = State.GOING
var target: Area2D

func _ready() -> void:
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_finished)

func setup(base_area: Area2D, village_area: Village) -> void:
	base = base_area
	village = village_area
	target = village
	state = State.GOING
	visible = false  # hidden while inside base

	base.body_exited.connect(_on_base_body_exited)
	base.body_entered.connect(_on_base_body_entered)
	village.body_entered.connect(_on_village_body_entered)


func _physics_process(_delta: float) -> void:
	if state == State.WAITING:
		velocity = Vector2.ZERO
		return
	velocity = global_position.direction_to(target.global_position) * speed
	move_and_slide()


# Unit leaves the base -> show it
func _on_base_body_exited(body: Node2D) -> void:
	if body == self and state == State.GOING:
		visible = true


# Unit reaches the village -> hide 1s, then head back from the same spot
func _on_village_body_entered(body: Node2D) -> void:
	if body != self or state != State.GOING:
		return
	if village.current_state == Village.STATE.DESTROYED:
		_return_to_base()
		return
	
	state = State.WAITING
	visible = false
	wait_timer.start(wait_time)

func _on_wait_finished() -> void:
	village.take_damage(damage)
	_return_to_base()

func _return_to_base() -> void:
	visible = true
	target = base
	state = State.RETURNING

# Unit gets back to the base -> hide it (and remove it)
func _on_base_body_entered(body: Node2D) -> void:
	if body != self or state != State.RETURNING:
		return
	visible = false
	queue_free()  # remove this line if you want units to stay parked in the base

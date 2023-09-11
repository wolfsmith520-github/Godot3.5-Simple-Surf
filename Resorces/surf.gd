extends KinematicBody

export var jumpImpulse = 2.0
export var gravity = -5.0
export var groundAcceleration = 30.0
export var groundSpeedLimit = 3.0
export var airAcceleration = 500.0
export var airSpeedLimit = 0.5
export var groundFriction = 0.9

export var mouseSensitivity = 0.1

var velocity = Vector3.ZERO

var restartTransform
var restartVelocity

func _ready():
	restartTransform = self.global_transform
	restartVelocity = self.velocity
	pass # Replace with function body.

func _physics_process(delta):

	velocity.y += gravity * delta
	if is_on_floor():

		if Input.is_action_pressed("move_jump"):
			velocity.y = jumpImpulse
		else:
			velocity *= groundFriction
	

	var basis = $YawAxis/Camera.get_global_transform().basis
	var strafeDir = Vector3(0, 0, 0)
	if Input.is_action_pressed("move_forward"):
		strafeDir -= basis.z
	if Input.is_action_pressed("move_backward"):
		strafeDir += basis.z
	if Input.is_action_pressed("move_left"):
		strafeDir -= basis.x
	if Input.is_action_pressed("move_right"):
		strafeDir += basis.x
	strafeDir.y = 0
	strafeDir = strafeDir.normalized()
	

	var strafeAccel = groundAcceleration if is_on_floor() else airAcceleration
	var speedLimit = groundSpeedLimit if is_on_floor() else airSpeedLimit
	

	var currentSpeed = strafeDir.dot(velocity)
	var accel = strafeAccel * delta
	accel = max(0, min(accel, speedLimit - currentSpeed))
	

	velocity += strafeDir * accel
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if Input.is_action_pressed("move_fast"):
		velocity = Vector3.ZERO
	if Input.is_action_just_released("move_fast"):
		velocity = -30 * basis.z
	
	if Input.is_action_just_pressed("checkpoint"):
		print("Saving Checkpoint: %s / %s" % [self.translation, self.velocity])
		restartTransform = self.global_transform
		restartVelocity = self.velocity	
	
	if Input.is_action_just_pressed("restart"):
		self.global_transform = restartTransform
		self.velocity = restartVelocity
	
	pass

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$YawAxis.rotate_x(deg2rad(event.relative.y * mouseSensitivity * -1))
		self.rotate_y(deg2rad(event.relative.x * mouseSensitivity * -1))

		# Clamp yaw to [-89, 89] degrees so you can't flip over
		var yaw = $YawAxis.rotation_degrees.x
		$YawAxis.rotation_degrees.x = clamp(yaw, -89, 89)    

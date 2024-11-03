extends Node2D

@onready var hand_sprite: AnimatedSprite2D = $HandSprite
@onready var cat_sprite: AnimatedSprite2D = $CatSprite
@onready var dodge_timer: Timer = $DodgeTimer
@onready var song: AudioStreamPlayer = $Song

## Load Scores
var scores_path = "res://assets/scores/scores.json"
var scores_data
var scores_list
var scores_songName
var scores_notes
var scores_bpm
var note_index := 1

## Time measurement about the song
var time_begin
var time_delay
@export var BPM = 120
var secondPerBeat: float = 60.0 / BPM
var time			# time
var timeCount: float = secondPerBeat	# counter to trigger beats

## hand variables
var isDodging := false
const dodgeDist = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("let's learn how to play")
	
	## Load Scores
	scores_data = load_json(scores_path)
	scores_list = scores_data["scores"][1]
	scores_notes = scores_list["notes"]
	
	if scores_notes is Array:
		print("scores_notes is Array!")
	
	## reduce lagging and play music
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	song.play()
	print("Current note index is " + str(note_index))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# get current playtime
	time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	time -= time_delay
	time = max(0, time)
	
	## Handle dodge
	if Input.is_action_just_pressed("tap"):
		print("Dodging!")
		
		# reset timer when re-triggering dodge
		if !dodge_timer.is_stopped():
			hand_sprite.position.y += dodgeDist
			hand_sprite.position.x -= dodgeDist
			dodge_timer.stop()
			hand_sprite.stop()
		
		# dodge down
		hand_sprite.position.y -= dodgeDist
		hand_sprite.position.x += dodgeDist
		dodge_timer.start()
		isDodging = true
	
	if time >= timeCount:
		timeCount += secondPerBeat
		### These codes are triggered at every beat
		
		note_index += 1
		print("Current note index is " + str(note_index))
		
		# reset sprite animation to match the beat
		if !isDodging:
			hand_sprite.stop()
			hand_sprite.play("idle")
		cat_sprite.stop()
		cat_sprite.play()

	## Handle animations
	if isDodging:
		hand_sprite.play("dodge")
	else:
		hand_sprite.play("idle")

#################################################################

func _on_dodge_timer_timeout() -> void:
	
	isDodging = false
	hand_sprite.position.y += dodgeDist
	hand_sprite.position.x -= dodgeDist
	print("I'm back!")

# Read JSON file
func load_json(file_path: String):
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		
		if parsed_result is Dictionary:
			print("Load scores successed!")
			return parsed_result
		else:
			printerr("Load score failed!")
	else:
		printerr("Score file not exist!")

extends Node2D

@onready var hand_sprite: AnimatedSprite2D = $HandSprite
@onready var cat_sprite: AnimatedSprite2D = $CatSprite
@onready var tail_sprite: AnimatedSprite2D = $TailSprite
@onready var dodge_timer: Timer = $DodgeTimer
@onready var bite_timer: Timer = $BiteTimer
@onready var song: AudioStreamPlayer = $Song

## Load Scores
var scores_path = "res://assets/scores/scores.json"
var scores_data
var scores_list
var scores_songName
var scores_notes
var note_index := 0
signal _on_score_end

## Time measurement about the song
var time_begin
var time_delay
@export var BPM = 120
var secondPerBeat: float = 60.0 / BPM
var beatDiv = 1	# beat division
var secondPerMinUnit: float = 60.0 / BPM / beatDiv	# the minimum time period for actions
var time			# time
var timeCount: float = secondPerMinUnit	# counter to trigger beats by minimum time unit
var beatCount: int = 1 # count min time unit to trigger beats

## hand variables
var isDodging := false
var isBiting := false
const dodgeDist = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("let's learn how to play")
	
	## Load Scores
	scores_data = load_json(scores_path)
	scores_list = scores_data["scores"][1]
	scores_notes = scores_list["notes"]
	
	# Initiate parameters
	BPM = scores_list["bpm"]
	beatDiv = scores_list["beatDiv"]
	secondPerMinUnit= 60.0 / BPM / beatDiv
	dodge_timer.wait_time = min(0.2, secondPerBeat/2)
	
	if scores_notes is Array:
		print("scores_notes is Array!")
	
	## reduce lagging and play music
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	#song.play()
	#print("Current note index is " + str(note_index))
	

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
	
	## Handle Level End
	if song.playing == false and time > timeCount:
		print("Level End!")
	
	if time >= timeCount:
		timeCount += secondPerMinUnit
		
		if beatCount < beatDiv:
			beatCount = beatCount + 1
		else:
			beatCount = 1
			###!!! codes here are triggered every beat
			
			# reset sprite animation to match the beat
			if !isDodging:
				hand_sprite.stop()
				hand_sprite.play("idle")
				
			if !isBiting:
				cat_sprite.stop()
				cat_sprite.play()
		
		if note_index == 0:
			song.play()
		
		###!!! Codes here are triggered every minimum time unit
		# print("Current note index is " + str(note_index))
		if note_index < scores_notes.size():
			print("Current action is " + str(scores_notes[note_index]))
			#tail_sprite.play("idle")
			var current_action = scores_notes[note_index]
			
			###!!! Here puts the action handler of the cat
			match int(current_action):
				0:
					print("it's 0")
					tail_sprite.play("idle")
					cat_sprite.play("idle")
				1:
					print("it's 1")
					swing_tail()
				2:
					print("it's 2")
					cat_bite()
				_:
					print("wait wtf?")
				
			
			
			
			
		else:
			emit_signal("_on_score_end")
		
		
		note_index += 1
		
	## Handle Animations
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

func swing_tail():
	if tail_sprite.animation == "left":
		tail_sprite.play("right")
	elif tail_sprite.animation == "right":
		tail_sprite.play("left")
	else:
		tail_sprite.play("left")
	return

######## Unfinished!
func cat_bite():
	cat_sprite.play("bite")
	if !isDodging:
		hand_sprite.play("biten")

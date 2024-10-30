extends Node2D

@onready var welcome_screen: Node2D = $SubViewportContainer/SubViewport/WelcomeScreen
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

enum Pages { WELCOME, TUTORIAL, GAME }
var current_page: Pages

# 切换 SubViewport 中显示的内容
func switch_scene(page: Pages):
	# 清除当前SubViewport当中的场景
	for child in sub_viewport.get_children():
		sub_viewport.remove_child(child)
		child.queue_free()
	
	# 加载并实例化场景
	current_page = page
	var scene_path
	match page:
		Pages.WELCOME:
			scene_path = "res://scenes/welcome_screen.tscn"
		Pages.TUTORIAL:
			scene_path = "res://scenes/tutorial_level.tscn"
		Pages.GAME:
			scene_path = "res://scenes/game.tscn"
	
	var new_scene = load(scene_path) as PackedScene
	sub_viewport.add_child(new_scene.instantiate())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switch_scene(Pages.WELCOME)
	print("scene switched")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("tap") and current_page == Pages.WELCOME:
		#et_tree().change_scene_to_file("res://scenes/tutorial_level.tscn")
		switch_scene(Pages.TUTORIAL)

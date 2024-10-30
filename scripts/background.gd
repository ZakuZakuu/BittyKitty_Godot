extends TextureRect

@export var backgroundColor : Color = Color.AZURE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 构造背景图像
	var img := Image.new()
	img = img.create(430, 650, true, Image.FORMAT_RGBA8)
	img.fill(backgroundColor)
	texture = ImageTexture.create_from_image(img)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

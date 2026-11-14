extends Button

var expectedSize: float = 1.0
var expectedIntensity: float = 0.0
var currentIntensity: float = 0.0
var justHovered: bool = false

func _ready() -> void:
    # 1. Create a wrapper Control node to bypass container layout overrides
    var parent = get_parent()
    if parent is Container:
        var wrapper = Control.new()
        wrapper.name = name + "Wrapper"
        wrapper.size_flags_horizontal = size_flags_horizontal
        wrapper.size_flags_vertical = size_flags_vertical
        wrapper.custom_minimum_size = custom_minimum_size
        
        # Replace button with wrapper in the container tree
        parent.call_deferred("add_child", wrapper)
        parent.call_deferred("remove_child", self)
        wrapper.call_deferred("add_child", self)
    
    # 2. Set pivot to center for smooth scaling
    pivot_offset = size / 2.0
    set_process(true)

func _process(_delta: float) -> void:
    pivot_offset = size / 2.0
    
    if is_hovered():
        expectedIntensity = 0.2
        expectedSize = 1.05
        
        if scale.x < expectedSize:
            scale.x += 0.01
            scale.y += 0.01
            
        if currentIntensity < expectedIntensity:
            currentIntensity += 0.04
            modulate = (modulate.srgb_to_linear() * (2 ** currentIntensity)).linear_to_srgb()
            
        if not justHovered:
            var hover_sound = get_node_or_null("../HoverOverButton")
            if hover_sound and hover_sound.has_method("play"):
                hover_sound.play()
            justHovered = true
    else:
        expectedIntensity = 0.0
        expectedSize = 1.0
        
        if scale.x > expectedSize:
            scale.x -= 0.01
            scale.y -= 0.01
            
        if currentIntensity > expectedIntensity:
            currentIntensity -= 0.04
            modulate = (Color(1.0, 1.0, 1.0, 1.0) * (2 ** currentIntensity)).linear_to_srgb()
            
        if justHovered:
            var off_sound = get_node_or_null("../HoverOffButton")
            if off_sound and off_sound.has_method("play"):
                off_sound.play()
            justHovered = false
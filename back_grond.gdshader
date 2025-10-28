shader_type canvas_item;

uniform float scroll_speed : hint_range(0.0, 2.0) = 0.5;
uniform vec2 player_position;

void fragment() {
    vec2 uv = UV + player_position * scroll_speed;
    COLOR = texture(TEXTURE, uv);
}

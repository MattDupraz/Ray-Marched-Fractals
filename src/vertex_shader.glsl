attribute vec3 vertex;
attribute vec2 tex_coord;

varying vec2 uv_coord;

void main() {
	gl_Position = vec4(vertex, 1.0);
	uv_coord = tex_coord;
}

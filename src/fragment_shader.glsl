#define M_PI 3.1415926535897932384626433832795
#define MARCH_STEPS 1000
#define MARCH_THRESHOLD 4e-3
#define ESCAPE_THRESHOLD 20.0
#define SERPINSKI_ITER 10
#define MANDELBULB_ITER 15
#define MANDELBULB_THRESHOLD 20.0
//#define MANDELBULB_POWER 8.0

uniform float aspect_ratio;
uniform mat4 camera_transform;
uniform float mandelbulb_power;

varying vec2 uv_coord;

float sq(float f) {
	return f * f;
}

// http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/ 
float dist_serpinski(vec3 pos) {
	vec3 a1 = vec3(1,1,1);
	vec3 a2 = vec3(-1,-1,1);
	vec3 a3 = vec3(1,-1,-1);
	vec3 a4 = vec3(-1,1,-1);
	vec3 c;
	int n = 0;
	float dist, d;
	while (n < SERPINSKI_ITER) {
		c = a1; dist = length(pos-a1);
		d = length(pos-a2); if (d < dist) { c = a2; dist=d; }
		d = length(pos-a3); if (d < dist) { c = a3; dist=d; }
		d = length(pos-a4); if (d < dist) { c = a4; dist=d; }
		pos = 2.0*pos - c;
		n++;
	}

	return length(pos) * pow(2.0, float(-n));
}

// http://celarek.at/wp/wp-content/uploads/2014/05/realTimeFractalsReport.pdf
float dist_mandelbulb(vec3 pos) {
	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < MANDELBULB_ITER; i++) {
		r = length(z);
		if (r > MANDELBULB_THRESHOLD)
			break;

		//convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y, z.x);
		dr = pow(r, mandelbulb_power-1.0) * mandelbulb_power * dr + 1.0;

		float zr = pow(r, mandelbulb_power);
		theta = theta * mandelbulb_power;
		phi = phi * mandelbulb_power;

		z = zr * vec3(sin(theta) * cos(phi),
				sin(phi) * sin(theta),
				cos(theta));
		z += pos;
	}
	return 0.5*log(r)*r/dr;	
}

void main() {
	float x = (uv_coord[0] - 0.5) * aspect_ratio * 2.0;
	float y = (uv_coord[1] - 0.5) * 2.0;

	vec3 pos = vec3( camera_transform * vec4(0.0, 0.0, 0.0, 1.0) );
	vec3 screen_pos = vec3( camera_transform * vec4(x, y, 1.5, 1.0) );

	vec3 ray_dir = normalize( screen_pos - pos );
	
	vec3 curr_pos = pos;
	float total_dist = 0.0;
	bool escaped = true;
	int i = 0;
	for (; i < MARCH_STEPS; i++) {
		float d = dist_mandelbulb(curr_pos);
		total_dist += d;
		curr_pos += d * ray_dir;
		if (d < MARCH_THRESHOLD) {
			escaped = false;
			break;
		} if (d > ESCAPE_THRESHOLD) {
			break;
		}
	}

	float brightness = 1.0 - log(float(i)) / log(float(MARCH_STEPS));

	if (!escaped) {
		gl_FragColor = vec4(brightness, brightness, brightness, 1.0);
	} else {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}


/*
	int n_iter = 1000;

	float z_r = 0.0;
	float z_i = 0.0;

	bool escaped = false;
	int i = 0;
	for (; i < n_iter; i++) {
		float new_z_r = sq(z_r) - sq(z_i) + x;
		float new_z_i = 2.0 * z_i * z_r + y;
		if (sq(new_z_r) + sq(new_z_i) > 4.0) {
			escaped = true;
			break;
		}
		z_r = new_z_r;
		z_i = new_z_i;
	}

	float r = sin(log(float(i))/2.0);
	float g = 0.0;//sin(log(float(i))/2.0 + 2.0 / 3.0 * M_PI);
	float b = sin(log(float(i))/2.0 + 4.0 / 3.0 * M_PI);

	if (escaped) {
		gl_FragColor = vec4(r, g, b, 1.0);
	} else {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}
	*/
}

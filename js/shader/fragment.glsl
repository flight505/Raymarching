uniform float time;
uniform float progress;
uniform vec2 mouse;
uniform sampler2D matcap, matcap1;
uniform vec4 resolution;
varying vec2 vUv;
float PI = 3.141592653589793238;


mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

// matcap 
vec2 getmatcap (vec3 eye, vec3 normal) {
	vec3 reflected = reflect(eye, normal);
	float m = 2.8284271247461903 * sqrt(reflected.z + 1.0);
	return reflected.xy / m + 0.5;
}


vec3 rotate(vec3 v, vec3 axis, float angle) { // 
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

// r is radius p is position; return length(p)-r
float sdSphere( vec3 p, float r ){ 
	return length(p)-r;
}

float sdBox( vec3 p, vec3 b )
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float sdf(vec3 p){ // signed distance function
	vec3 p1 = rotate(p,vec3(1.),time/5.0);
	float box = smin(sdBox(p1, vec3(0.2)), sdSphere(p, 0.2), 0.3);

	float realsphere = sdSphere(p1, 0.3);
	float final = mix(box , realsphere, progress);

	for(float i=0.0; i<10.0 ;i++){
	float randOffset = rand(vec2( i, 0.0));
	float progr = fract(time /3.0 + randOffset);
	float gotoCenter = sdSphere(p - vec3(1.0, 0.0, 0.0)* progr, 0.1);
	final = smin(final, gotoCenter, 0.3);
	}

	float mouseSphere = sdSphere( p - vec3(mouse*resolution.zw*2.0, 0.0), 0.2); // sphere roundness. higher = more round
	return smin(final, mouseSphere, 0.4);
}

vec3 calcNormal( in vec3 p ){
	
	const float eps = 0.0001;
	const vec2 h = vec2(eps,0);
	return normalize( vec3(
		sdf(p+h.xyy) - sdf(p-h.xyy),
		sdf(p+h.yxy) - sdf(p-h.yxy),
		sdf(p+h.yyx) - sdf(p-h.yyx)
	));
}

void main()	{
	float dist = length(vUv - vec2(0.5)); // distance from center
	vec3 bg = mix(vec3(0.3), vec3(0.0), dist); // background color

	vec2 newUV = (vUv - vec2(0.5))*resolution.zw + vec2(0.5);
	vec3 camPos = vec3(0.0, 0.0, 0.8);
	vec3 ray = normalize(vec3((vUv - vec2(0.5))*resolution.zw , -0.15)); // ray direction

	vec3 rayPos = camPos; // ray position
	float t = 0.0; // time
	float tMax = 5.0; // max ray length
	for(int i = 0; i < 256; ++i){ // reason for the loop is to prevent the ray from going on forever	
		vec3 pos = camPos + t*ray; // position of the ray
		float h = sdf(pos); // distance to surface
		if(h < 0.0001 || t > tMax) break; // if we hit the surface or we've gone too far, stop
		t += h; // move the ray forward (marching the ray)
	}
	
	vec3 color = bg; // color of the pixel
	if(t < tMax){
		vec3 pos = camPos + t*ray; // position of the ray
		color = vec3(1.0); // if we didn't go too far, color the pixel white
		vec3 normal = calcNormal(pos); // calculate the normal
		color = normal; // color the pixel based on the normal
		float diff =dot(vec3(1.0), normal); // calculate the diffuse lighting
		vec2 matcapUV = getmatcap(ray, normal); // calculate the matcap UV
		color = vec3(diff); // color the pixel based on the diffuse lighting
		color = texture2D(matcap, matcapUV).rgb; // color the pixel based on the matcap

		float fresnel = pow(1.0 + dot(ray, normal), 3.0); // calculate the fresnel
		// color = vec3(fresnel); // color the pixel based on the fresnel
		color = mix(color, bg, fresnel); // mix the matcap and white based on the fresnel
	}

	
	gl_FragColor = vec4(color, 1.0);
	// gl_FragColor = vec4(bg, 1.0);
}
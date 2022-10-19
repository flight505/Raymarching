uniform float time;
uniform float progress;
uniform sampler2D texture1;
uniform vec4 resolution;
varying vec2 vUv;
float PI = 3.141592653589793238;

// r is radius p is position; return length(p)-r
float sdSphere( vec3 p, float r ){ 
	return length(p)-r;
}

float sdBox( vec3 p, vec3 b )
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdf(vec3 p){ // signed distance function
	// float d = sdSphere(p, 1.0);
	float box = sdBox(p, vec3(0.2));
	return sdSphere( p, 0.4 ); // sphere
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
	vec2 newUV = (vUv - vec2(0.5))*resolution.zw + vec2(0.5);
	vec3 camPos = vec3(0.0, 0.0, 0.9);
	vec3 ray = normalize(vec3((vUv - vec2(0.5))*resolution.zw , -0.5)); // ray direction

	vec3 rayPos = camPos; // ray position
	float t = 0.0; // time
	float tMax = 5.0; // max ray length
	for(int i = 0; i < 256; ++i){ // reason for the loop is to prevent the ray from going on forever	
		vec3 pos = camPos + t*ray; // position of the ray
		float h = sdf(pos); // distance to surface
		if(h < 0.0001 || t > tMax) break; // if we hit the surface or we've gone too far, stop
		t += h; // move the ray forward (marching the ray)
	}
	
	vec3 color = vec3(0.0); // color of the pixel
	if(t < tMax){
		vec3 pos = camPos + t*ray; // position of the ray
		color = vec3(1.0); // if we didn't go too far, color the pixel white
		vec3 normal = calcNormal(pos); // calculate the normal
		color = normal; // color the pixel based on the normal
		float diff =dot(vec3(1.0), normal); // calculate the diffuse lighting
		color = vec3(diff); // color the pixel based on the diffuse lighting
	}
	
	gl_FragColor = vec4(color, 1.0);
}
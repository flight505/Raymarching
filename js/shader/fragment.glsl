uniform float time;
uniform float progress;
uniform sampler2D texture1;
uniform vec4 resolution;
varying vec2 vUv;
varying vec3 vPosition;
float PI = 3.141592653589793238;

// float sdSphere( vec3 p, float r )
// {
// 	return length(p)-r;
// };

// float sdf( vec3 p )
// {
// 	return = sdSphere( p, 0.4 );
// };

void main()	{
	// vec2 newUV = (vUv - vec2(0.5))*resolution.zw + vec2(0.5);
	// vec3 camPos = vec3(0.0, 0.0, 2.0);
	// vec3 ray = normalize(vec3(vUv, -1.0));

	// vec3 rayPos = camPos;
	// float t = 0.0;
	// float tMax = 5.0;
	// for(int i = 0; i < 256; i++) // reason for the loop is to prevent the ray from going on forever
	// {	
	// 	vec3 pos = camPos + t*ray;
	// 	float h = sdf(pos);
	// 	if(h < 0.001 || t > tMax) break;
	// 	t += h;
	// }
	// if(t < tMax)
	// {
	// 	color = vec3(1.0);
	// }
	// else
	// {
	// 	gl_FragColor = vec4(color, 1.0);
	// }
		gl_FragColor = vec4(vUv,0.0,1.);

}
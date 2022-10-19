uniform float time;
uniform float progress;
uniform sampler2D texture1;
uniform vec4 resolution;
varying vec2 vUv;
varying vec3 vPosition;
float PI = 3.141592653589793238;

float sdSphere( vec3 p, float r )
{
	return length(p)-r;
}

float map( vec3 p )
{
	return = sdSphere( p, 0.5 );
}

void main()	{
	vec2 newUV = (vUv - vec2(0.5))*resolution.zw + vec2(0.5);
	vec3 camPos = vec3(0.0, 0.0, 2.0);
	vec3 ray = normalize(vec3(newUV, -1.0));

	gl_FragColor = vec4(newUv,0.0,1.);
	gl_FragColor = vec4(newUv,0.0,1.);
}
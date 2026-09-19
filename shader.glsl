mat2 rot(float a){
    float c = cos(a);
    float s = sin(a);
    
    return mat2(
        c, -s,
        s, c
    
    );

}

float cubeSDF(vec3 p){
    p.xz = rot(iTime) * p.xz;
    p.yz = rot(iTime) * p.yz;

    vec3 q = abs(p) - vec3(1.0) + 0.1;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - 0.1;
}

float planeSDF(vec3 p, vec3 n, float h){
    
    return dot(p, normalize(n)) + h; 

}


float map(vec3 p){
    float k = 0.25;

    float cube1 = cubeSDF(p - vec3(-1.0,0.0,0.0));
    float cube2 = cubeSDF(p - vec3(1.0,0.0,0.0));
    
    float plane = planeSDF(p, vec3(0.0, 1.0, 0.0), 2.0);
    
    float h = clamp(0.5 + 0.5 * (cube2 - cube1) / k, 0.0, 1.0);
    return min((mix(cube2, cube1, h) - k * h * (1.0 - h)), plane);
 }


vec3 getNormal(vec3 p){
    float epsilon = 0.001;
    return normalize(
    vec3(
        map(p + vec3(epsilon, 0.0, 0.0)) - map(p - vec3(epsilon, 0.0, 0.0)),
        map(p + vec3(0.0, epsilon, 0.0)) - map(p - vec3(0.0, epsilon, 0.0)),
        map(p + vec3(0.0, 0.0, epsilon)) - map(p - vec3(0.0, 0.0, epsilon))
    ));

}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    
    vec3 lightDir = vec3(0.3, 0.0, -0.8);
    
    vec3 rayOrigin = vec3(0.0, 0.0, -5.0);
    vec3 rayDirection = normalize(vec3(uv, 1.0));
    
    float t = 0.0;
    
    
    for (int i = 0; i <= 100; i++){
        vec3 p = rayOrigin + rayDirection * t;
        
        float d = map(p);
        
        if (d < 0.05){
           float ka = 0.45;
           float kd = 0.25;
           float ks = 0.9;
           float n = 48.0;
           
           
           vec3 ia = vec3(0.2, 0.76, 0.7);
           vec3 ip = vec3(1.0, 0.97, 0.92);
           float d = 1.0;
           vec3 N = getNormal(p);
           vec3 L = normalize(lightDir);
           vec3 V = normalize(rayOrigin - p);
           vec3 R = reflect(-L, N);
           
           vec3 color = ka * ia + (ip / d) * (kd * (max(dot(N, L), 0.0)) + ks * (pow(max(dot(V, R), 0.0), n))); 
           
           fragColor = vec4(color, 1.0);
          
           return;
        }
        t += d;
    
        if (t >= 100.0){
            break;
        }
    
    }
    
    
    fragColor = vec4(0.2, 0.6, 0.8, 1) * (uv.y * 4.0);
}

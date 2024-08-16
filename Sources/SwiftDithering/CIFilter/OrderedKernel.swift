//Created by Lugalu on 08/08/24.

import Foundation

let orderedKernel: String = """

vec3 roundF(vec3 color) {
    vec3 colorOut = color ;
    colorOut.r = floor(colorOut.r + 0.5) > colorOut.r ? ceil(colorOut.r) : floor(colorOut.r);   //floor(colorOut.r) + floor(mod(colorOut.r,1.0) + 0.5);
    colorOut.g = floor(colorOut.g + 0.5) > colorOut.g ? ceil(colorOut.g) : floor(colorOut.g);   //floor(colorOut.g) + floor(mod(colorOut.g,1.0) + 0.5);
    colorOut.b = floor(colorOut.b + 0.5) > colorOut.b ? ceil(colorOut.b) : floor(colorOut.b);   //floor(colorOut.b) + floor(mod(colorOut.b,1.0) + 0.5);
    return colorOut;
}

kernel float4 bayer(sampler s, sampler matrix, float divider, float f, float spread, float n ) {

    int factor = int(f);
    float2 uv = destCoord();

    float threshold = float(getMatrixValue(int(uv.x), int(uv.y), int(divider), factor, matrix));
    threshold *= (1.0/pow(exp2(f),2.0));
    threshold -= 0.5;

    float deviation = spread * threshold;
    float levels = float(1 << int(n)) - 1.0 ;
    float4 color = sample(s,samplerCoord(s));
    color.rgb += deviation;
    color.rgb = roundF(color.rgb * levels) / levels ;

    
    return clamp(color, 0.0, 1.0);
}
"""

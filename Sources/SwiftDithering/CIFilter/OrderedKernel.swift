//Created by Lugalu on 08/08/24.

import Foundation

let orderedKernel: String = """

vec3 roundF(vec3 color) {
    vec3 colorOut = color ;
    colorOut.r = floor(colorOut.r) + floor(mod(colorOut.r,1.0) + 0.5);
    colorOut.g = floor(colorOut.g) + floor(mod(colorOut.g,1.0) + 0.5);
    colorOut.b = floor(colorOut.b) + floor(mod(colorOut.b,1.0) + 0.5);
    return colorOut;
}

kernel float4 bayer(sampler s, sampler matrix, float f, float spread, float n ) {

    int factor = int(f);
    int numberOfBits = int(n);
    float2 uv = destCoord();

    float matrixFactor = pow(f, 2.0);
    float threshold = float(getMatrixValue(int(uv.x), int(uv.y), factor, matrix));
    threshold *= (1.0/pow(matrixFactor,2.0));
    threshold -= 0.5;

    float deviation = spread * threshold;
    float levels = exp2(n);
    float4 color = sample(s,samplerCoord(s)).rgba;
    color.rgb += deviation;
    color.rgb = roundF(color.rgb * levels) / levels ;
    
    return clamp(color, 0.0, 1.0);
}
"""

//Created by Lugalu on 08/08/24.

import Foundation

let orderedKernel: String = """

vec3 roundF(vec3 color) {
    vec3 colorOut = color;
    colorOut.r = colorOut.r < 0.5 ? floor(colorOut.r) : ceil(colorOut.r);
    colorOut.g = colorOut.g < 0.5 ? floor(colorOut.g) : ceil(colorOut.g);
    colorOut.b = colorOut.b < 0.5 ? floor(colorOut.b) : ceil(colorOut.b);
    return colorOut;
}

kernel float4 bayer(sampler s, sampler matrix, float f, float spread, float n ) {

    int factor = int(f);
    int numberOfBits = int(n);
    float2 uv = destCoord();
    float4 extent = samplerExtent(s);
    int matrixValue = getMatrixValue(int(extent.z), int(extent.w), factor, matrix);

    float matrixFactor = pow(2.0, float(factor));
    float threshold = float(matrixValue) / 255.0;
    threshold *= (1.0 / matrixFactor);
    threshold -= 0.5;

    float deviation = spread * threshold;
    float levels = exp2(n) - 1.0;
    float4 color = sample(s,samplerCoord(s)).rgba;
    color.rgb += float3(deviation);
    color.rgb = roundF(color.rgb * levels) / levels;
    
    return color;
}
"""

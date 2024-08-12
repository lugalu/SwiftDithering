//Created by Lugalu on 08/08/24.

import Foundation

let orderedKernel: String = """
kernel float4 test(sampler s, int factor, float spread, int numberOfBits) {
    float2 uv = destCoord();
    float4 extent = samplerExtent(uv);
    int matrixValue = getMatrixValue(extent.x, extent.y, factor)

    float matrixfactor = pow(2.0, factor);
    float threshold = float(matrixValue);
    threshold *= (1.0 / matrixPow);
    threshold -= 0.5;

    float deviation = spread * threshold;
    float levels = float(1 << numberOfBit) - 1.0;
    float4 color = sample(s,uv);
    color.rgb += float3(deviation);
    color.rgb = round(color.rgb * levels) / levels;
    
    return float4(color);
}
"""

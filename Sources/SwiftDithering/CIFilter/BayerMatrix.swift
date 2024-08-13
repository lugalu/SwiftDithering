//Created by Lugalu on 08/08/24.

import Foundation

/**
 N should be the power of the matrix (1 = 2x2, 2=4x4, 3=8x8)
*/
let bayerMatrixCalculation: String = """
int getQuadrant(int x, int y, int half_n){
    if (x < half_n && y < half_n) {
        return 0;
    }
    
    if (x >= half_n && y < half_n) {
        return 2;
    }

    if (x < half_n && y >= half_n) {
        return 3;
    }

    return 1;
}

int getFactor(int n){
    return int(exp2(float(n)));
}

int getBayerValue(int x, int y, int factor, mat4 matrix){
    int posX = x % factor;
    int posY = y % factor;

    float value = matrix[posY][posX];
    return int(value);
}

int getBayerValue(int x, int y, int factor, mat2 matrix){
    int posX = x % factor;
    int posY = y % factor;

    float value = matrix[posY][posX];
    return int(value);
}

int getMatrixValue(int x, int y, int n, sampler bigMatrix){
    int factor = getFactor(n);
    int value = 0;

    if (n == 3){
        float f = float(factor);
        float posX = mod( float(x), f);
        float posY = mod(float(y), f);

        float2 uv = samplerTransform(bigMatrix,float2(posX,posY));
        int retrivedValue = int(sample(bigMatrix, uv ).r * 255.0);
        return retrivedValue;

    }

    if (n == 2){
       mat4 matrix = mat4(
           0.0, 12.0, 3.0, 15.0,
           8.0, 4.0, 11.0, 7.0,
           2.0, 14.0, 1.0, 13.0,
           10.0, 6.0, 9.0, 5.0
       );
        value = getBayerValue(x,y,factor,matrix);

    }
    
    if (n == 1){
      mat2 matrix = mat2(
           0.0, 3.0,
           2.0, 1.0
       );
        value = getBayerValue(x,y,factor,matrix);

    }
    
    return value;
}
"""

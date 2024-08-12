//Created by Lugalu on 08/08/24.

import Foundation

/**
 N should be the power of the matrix (1 = 2x2, 2=4x4, 3=8x8)
*/
let bayerMatrixCalculation: String = """
int getQuadrant(int x, int y, int half){
    if (x < half && y < half) {
        return 0;
    }
    
    if (x >= half && y < half) {
        return 2;
    }

    if (x < half && y >= half) {
        return 3;
    }

    return 1;
}


int getMatrixValue(int x, int y, int n){
    if(n == 1) {
        return abs( 2 * x - 3 * y);
    }

    int half = pow(2, n-1);
    int factor = pow(2, n);
    int newX = x % factor;
    int newY = y % factor;

    int quadrant = getQuadrant(x,y,half);
    newX = newX % half;
    newY = newY % half;

    return 4 * getMatrixValue(x,y,n-1) + quadrant;
}
"""

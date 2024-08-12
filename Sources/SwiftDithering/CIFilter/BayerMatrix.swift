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


int getMatrixValue(int x, int y, int n){
    if(n <= 1) {
        return int(abs( 2.0 * float(x) - 3.0 * float(y)));
    }

    int half_n = int(pow(2.0, float(n-1) ));
    int factor = int(pow(2.0, float(n) ));
    int newX = x % factor;
    int newY = y % factor;

    int quadrant = getQuadrant(newX,newY,half_n);
    newX = newX % half_n;
    newY = newY % half_n;

    return 4 * getMatrixValue(newX,newY,n-1) + quadrant;
}
"""

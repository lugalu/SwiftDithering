//Created by Lugalu on 08/08/24.

import Foundation

/**
 N should be the power of the matrix (1 = 2x2, 2=4x4, 3=8x8)
*/
let bayerMatrixCalculation: String = """
    int bayerValue(int x, int y, int n){
        if(n == 1){
            return int(mat4(0,2,3,1)[y * 4 + x])
        }
        int half = pow(2, n-1);
        int quadrant = max(x, half) + 2 * max(y, half);
        return 4 * bayerValue(x,y,n-1) + quadrant;
    }
"""

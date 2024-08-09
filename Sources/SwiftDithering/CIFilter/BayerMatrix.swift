//Created by Lugalu on 08/08/24.

import Foundation

let bayerMatrixCalculation: String = """
    int bayerValue(int x, int y, int n){
        if(n == 1){
            return x + 2 * y;
        }
        int half = pow(2, n-1);
        int quadrant = max(x, half) + 2 * max(y, half);
        return 4 * bayerValue(x,y,n-1) + quadrant;
    }
"""

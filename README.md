# SwiftDithering

This is a library focused on bringing dithering to Swift since the CIFilter for dither is mostly noise.
The implementation is done via the Accelerate framework.

![Static Badge](https://img.shields.io/badge/Platform_Compatibility-iOS-orange)
<br>
## Examples
- Bayer 8x8:
    <img src= "https://i.imgur.com/6CMZE2w.png"/>
    - Photo by <a href="https://unsplash.com/@andrazlazic?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Andraz Lazic</a> on <a href="https://unsplash.com/photos/5suzgCS6mIc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
<br>

- Floyd-Steinberg:
    - 1-bit:
     <img src="https://i.imgur.com/tyzuqXu.png"/>
    <br>
    
    - 2-bits:
     <img src="https://i.imgur.com/UOo2bbZ.png"/>

<br>

## Usage
To use the library you will have some access points based on UIImages
```Swift
import SwiftDithering

function yourFunction() {
//Highly Recommended
    Task{
        do{
        let ditheredImage = try image?.applyErrorDifusion(withType: .floydSteinberg)
        //or
        //try image?.applyOrderedDither(withSize: .bayer8x8)
        //or
        //try image?.applyThreshold(withType: .fixed)

        }catch{
          //handle errors here
        }
    }
  
}
```
the functions also have more accessible parameters, but for simplicity, this example does not, For more details check the Sample/DitherTester/DitherControl and go to any of the retrivedDitheredImages


## Plans And Features
Since is my first time doing something like this a lot of the code is prone to change, I will try to do it in the most non-disruptive way but I cannot guarantee it will work in every single version.

Currently Features:
 - Bayer matrix;
 - Floyd Steinberg Error Diffusion;
 - Stucky Error Difusion.
 - Fixed Threshold
 - Random Threshold
 - Uniform Threshold
 - Clustered Dots
 - Central White point
 - Balanced Centered point
- Diagonal clustered
 
 <br>
 
Planned Dithers:
 - No Extra dither for now, since I don't know any other technique
 
<br>

Maybe Will be added:
 - CIFilter, the lack of Obj-C knowledge prevents me from doing it for now.
 
 
<br>

 ## Considerations
* Since all runs on the CPU they are calculated as sequential and are expensive so tasks and loadings are needed for the user UI.
* Feel free to suggest performance improvements and report any bug that you may find while using this lib
* These dithers are based on the [matlab article stored in the archive.today](https://archive.ph/71e9G) and other research

# SwiftDithering

This is a library focused on bringing dithering to Swift since the CIFilter for dither is mostly noise.
The implementation is done via the Accelerate framework.  

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Flugalu%2FSwiftDithering%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/lugalu/SwiftDithering)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Flugalu%2FSwiftDithering%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/lugalu/SwiftDithering)
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
To use the library you will have some access points based on UIImages and CIFilter  

CPU:
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

GPU:
```Swift
import SwiftDithering

function yourFunction() {
    let filter = OrderedDithering()
    filter.setValuesForKeys([
        "inputImage": inputCIImage,
        "ditherType": ditherType.getCIFilterID(),
        ...
    ])

   return filter?.outputImage
}
```
I recommend transforming the outputImage to CG before using in IOS, same thing for the respective variants on mac.  

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
 - All Ordered Dithers are Now CPU and GPU supported.  
 
 ## Considerations
* The CPU variants are calculated as sequential and are expensive so tasks and loadings are needed for the user UI.
* Feel free to suggest performance improvements and report any bug that you may find while using this lib
* These dithers are based on the [matlab article stored in the archive.today](https://archive.ph/71e9G) and other research

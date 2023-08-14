# SwiftDithering

This is a library focused on bringing dithering to Swift since the CIFilter for dither is mostly noise.
The implementation is done via the Accelerate framework.
<br>
## Examples
- Bayer 8x8:
    ![European city by Andre Lazic](./Sample/SampleImages/CityComparison.png)
    - Photo by <a href="https://unsplash.com/@andrazlazic?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Andraz Lazic</a> on <a href="https://unsplash.com/photos/5suzgCS6mIc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
    - warning the dither may not appear due to the filter applied during the saving process with UIImageWriteToSavedPhotosAlbum, I recommend giving a try in the sample app for more fidelity.
<br>
- Floyd-Steinberg:
    - 1-bit:
    <img src="https://i.imgur.com/tyzuqXu.png"/>

 <br>

    - 2-bits:
    <img src="https://i.imgur.com/UOo2bbZ.png"/>

<br>

## Plans And Features
Since is my first time doing something like this a lot of the code is prone to change, I will try to do it in the most non-disruptive way but I cannot guarantee it will work in every single version.

Currently Features:
 - Bayer matrix;
 - Floyd Steinberg Error Diffusion;
 - Stucky Error Difusion.
 <br>
Planned Dithers:
 - Fixed Threshold
 - Random Threshold 
 - Clustered Dots
 - Central White point
 - Balanced Centered point
<br>
 Maybe Will be added:
 - Diagonal clustered
<br>
 Others:
 - Documentation and examples outside what the code already provides
 - images in this readme
 - Tags, tests, and releases automation in Github
 - Cocoa pods integration
 - Small test project with some images Pre-loaded and the ability to add your own from the gallery.
 - Downgrade Minimum version since there's nothing that should be bound to older devices
 
<br>
 ## Considerations
* Since all runs on the CPU they are calculated as sequential and are expensive so tasks and loadings are needed for the user UI.
* Feel free to suggest performance improvements and report any bug that you may find while using this lib
* These dithers are based on the [matlab article stored in the archive.today](https://archive.ph/71e9G)

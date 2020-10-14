////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:      GutGFP%CoverageMacro
// Authour:   Jamie Adams (University of Sheffield/ Sheffield)
// Version:   1.0
//
// Aim:       To measure the total area of GFP positive pixels within in image, and to
//            measure the area of objects outlined in the red channel. These areas may
// 			  then be compared to calculate the GFP positive percent coverage of an image.
//
// Usage:     - Open desired RGB image
//			  - Drag and drop macro file into imageJ (launch macro)
//			  - Set image scale 
//			  - Set image thresholds for GFP and red channel (between 0 and 255)
//			  - Export results from 'Results' table containing 'Area' and '%Area'
//			  - Calulcate relevant areas:
//					- GFP positive area: (Image 'Area'/100) * GFP positive '%Area'
//					- red channel area:  (Image 'Area'/100) * Red channel '%Area'
//			  - Calculate GFP% coverage:
//					- GFP% coverage:     (GFP positive area/Red channel area) * 100
//
////////////////////////////////////////////////////////////////////////////////////////////////////////


//Set the relevant image scale 
run("Set Scale...", "distance=1.2 known=1 pixel=1 unit=um global");

//Sets measurements of area, area fraction, integrated density and mean gray value
run("Set Measurements...", "area mean integrated area_fraction redirect=None decimal=3");

//names image 'original'
original = getTitle();

//duplicates image
run("Duplicate...", "mask check");

//names duplicate image as 'copy'
copy = getTitle();

//select original image
selectWindow(original)

//Selects title of image and adds (green) and makes object = name
name = getTitle() + " (green)";
print(name);

//Selects title of image and adds (red) and makes object = name1
name1 = getTitle() + " (red)";
print(name1);

//Selects title of image and adds (blue) and makes object = name
name2 = getTitle() + " (blue)";
print(name2);

//Splits channels into individual RGB colours
run("Split Channels");

//close the Blue window
close(name2)

//selects green colour window
selectWindow(name);

//run autothresholding
setAutoThreshold("Default dark");

//run("Threshold...");
setAutoThreshold("Default dark stack");

//set threshold at custom values for your images (between 0 and 255)
setThreshold(140, 255);

//disables BlackBackground option (found in Binary menu)
setOption("BlackBackground", false);

//Returns image to Mask (rather than Binary)
run("Convert to Mask");

//Removes 'noise' (Despeckle is median filter -> replaces each pixel with median value in its 3x3 adjacent grid)
run("Despeckle");

//Ctrl + m -> Measures area% covered via GFP+ cells
run("Measure");

//make image binary for further processing
run("Make Binary");

//fill in gaps in outlines
run("Dilate");

//remove added pixels (that are possibly not truly GFP+)
run("Erode");

//outline black (+1) pixels
run("Outline");


//add pixels to outlines
run("Find Edges");

//make non-binary
run("Convert to Mask");

//Count number of masks and provide summary dialog without measuring (ctrl + M)
run("Analyze Particles...", "size=10-Infinity pixel show=[Count Masks] include summarize add in_situ");

//Select 'Red' window
selectWindow(name1)

//run("Threshold...");
setAutoThreshold("Default dark stack");

//set threshold at custom values for your images (between 0 and 255)
setThreshold(6, 255)

//Make image non-binary
run("Convert to Mask");

//Make image binary
run("Make Binary");

//Remove 'noise' with despeckle filter
run("Despeckle");

//Fill in 'gaps' with adding pixels via Dilate command (x3)
run("Dilate");

//Remove extra pixels added via Dilate command (x3)
run("Erode");

//Fill in any remaining 'gaps' by Closing
run("Close-");

//Run measure command to find area% filled by gut (provides gut size)
run("Measure");

//selects duplicate of original image
selectWindow(copy)

//overlays shapes saved from ROI manager to coloured copy of original image
roiManager("Show None");
roiManager("Show All");

//closes no-longer necessary windows
close(name);
close(name1);
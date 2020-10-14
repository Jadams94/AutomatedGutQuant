////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:      GFPMaskAreaQuantMacro
// Authour:   Jamie Adams (University of Sheffield/ Sheffield)
// Version:   1.0
//
// Aim:       To measure the area of each individual GFP positive mask.
//
// Usage:	  - Drag and drop macro file into imageJ (launch macro)
//			  - Set image scale 
//			  - Set image thresholds for GFP channel (between 0 and 255)
//			  - Export results from 'Results' table containing 'Area'
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////


//Set the relevant image scale 
run("Set Scale...", "distance=300 known=250 pixel=1 unit=um global");

//Sets the measurement as area only
run("Set Measurements...", "area redirect=None decimal=3");

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

//Removes 'noise' (x2) (Despckle is median filter -> replaces each pixel with median value in its 3x3 adjacent grid)
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

//add pixels to outlines (x4)
run("Find Edges");

//make non-binary
run("Convert to Mask");

//Count number of masks and provide summary dialog without measuring (ctrl + M)
run("Analyze Particles...", "size=10-Infinity pixel show=[Count Masks] include summarize add in_situ");

//selects duplicate of original image
selectWindow(copy);

//overlays shapes saved from ROI manager to coloured copy of original image
roiManager("Show None");
roiManager("Show All");

//closes no-longer necessary windows
close(name);
close(name1);

//Selects ROI Manager and measures area of each individual mask
roiManager("Select", newArray(0));
run("Select All");
roiManager("Measure");

//'Flattens' selected GFP masks onto original image for saving/manual verification
//run("Flatten");

//Closes unnecessary windows and removes initial overall GFP positive area measure
close("Summary")
Table.deleteRows(0,0);


//Clears ROI manager of selected objects - 'uncomment' if you want ROI manager to be cleared
//if (isOpen("ROI Manager")) {
//	selectWindow("ROI Manager");
//	roiManager("reset");
//}

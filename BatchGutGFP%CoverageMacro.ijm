////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:      BatchGutGFP%CoverageMacro
// Authour:   Jamie Adams (University of Sheffield/ Sheffield)
// Version:   1.0
//
// Aim:       To measure the total area of GFP positive pixels within in image, and to
//            measure the area of objects outlined in the red channel. This will be measured 
//			  for each indivudal image, consecutively, within the specified folder. These 
//			  areas may then be compared to calculate the GFP positive percent coverage
// 			  of an image.
//
// Usage:	  - Drag and drop macro file into imageJ (launch macro)
//			  - Set image scale (number of pixels vs known distance)
//			  - Set image thresholds for GFP and red channel (between 0 and 255)
//			  - Run macro and select the folder containing consective RGB images for processing
//			  - Export results from 'Results' table containing 'Area' and '%Area'
//			  - Calulcate relevant areas:
//					- GFP positive area: (Image 'Area'/100) * GFP positive '%Area'
//					- red channel area:  (Image 'Area'/100) * Red channel '%Area'
//			  - Calculate GFP% coverage:
//					- GFP% coverage:     (GFP positive area/Red channel area) * 100
//
// Note:	  The Scale, GFP threshold and red channel threshold will be set the same for ALL images
//			  processed. Ensure images display similar channel intensity before processing!!!
//			  Creates a folder entitled 'Overlays' of 'flattened' images showing outlined GFP positive
//			  masks for manual verification.
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////


//Turns 'GAS_batch' into a user defined function that takes one argument called 'filepath'. 
function GAS_batch(filepath) {

	// Open the file at the path provided to the function - i.e. grabs the next file in the folder. This and the last line - close() - are the only things single gut analysis script function needs different.
	open(filepath);

	//Set the relevant image scale
	run("Set Scale...", "distance=1.2 known=1 pixel=1 unit=um global");

	//Sets measurements of area, area fraction, integrated ddensity and mean gray value
	run("Set Measurements...", "area mean integrated area_fraction redirect=None decimal=3");

	//names image 'original'
	original = getTitle();

	//duplicates image
	run("Duplicate...", "mask check");

	//names duplicate image as 'copy'
	copy = getTitle();

	//select original image
	selectWindow(original);

	//Selects title of image and adds (green) and makes object = name
	name = getTitle() + " (green)";

	//Selects title of image and adds (red) and makes object = name1
	name1 = getTitle() + " (red)";

	//Selects title of image and adds (blue) and makes object = name
	name2 = getTitle() + " (blue)";

	//Splits channels into individual RGB colours
	run("Split Channels");

	//close the Blue window
	close(name2);

	//selects green colour window
	selectWindow(name);

	//run autothresholding
	setAutoThreshold("Default dark");

	//run("Threshold...");
	setAutoThreshold("Default dark stack");

	//set threshold at custom values for your images (between 0 and 255)
	setThreshold(100, 255);

	//disables BlackBackground option (found in Binary menu)
	setOption("BlackBackground", false);

	//Returns image to Mask (rather than Binary)
	run("Convert to Mask");

	//Removes 'noise' (x2) (Despckle is median filter -> replaces each pixel with median value in its 3x3 adjacent grid)
	run("Despeckle");
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

	//Select 'Red' window
	selectWindow(name1);

	//run("Threshold...");
	setAutoThreshold("Default dark stack");

	//set threshold at custom values for your images (between 0 and 255)
	setThreshold(3, 255);

	//Make image non-binary
	run("Convert to Mask");

	//Make image binary
	run("Make Binary");

	//Remove 'noise' with despeckle filter
	run("Despeckle");

	//Fill in 'gaps' with adding pixels via Dilate command
	run("Dilate");

	//Remove extra pixels added via Dilate command
	run("Erode");

	//Fill in any remaining 'gaps' by Closing
	run("Close-");

	//Run measure command to find area% filled by gut (provides gut size)
	run("Measure");

	//selects duplicate of original image
	selectWindow(copy);

	//overlays shapes saved from ROI manager to coloured copy of original image
	roiManager("Show None");
	roiManager("Show All");

	//flattens overlay onto original image copy
	run("Flatten");

	//saves flattened images into overlay folder
	overlay_path = path + "Overlays/" + name + "_overlay.zip";
	save(overlay_path);

	//closes no-longer necessary windows
	close(name);
	close(name1);
	close("Summary");
	roiManager("reset");
	close("ROI Manager");
	close();

	//closes flattened images (remove this if you want to keep flattened images open)
	run("Close All");
  
}

//end of function - following section creates a loop to move through consecutive files within previously selected folder

// Opening dialouge that allows GUI selection of the folder (useful for non-computational people).
path = getDirectory("Please choose the image folder");

// Create an array containing the names of the files in the chosen directory.
files = getFileList(path);

// Prevents the images from opening on screen - 'un-comment' below line if you dont want to see images whilst being processed
setBatchMode(true);

// Store the number of image files that the function needs to work on (from the number of objects in the array), for the loop.
imax = lengthOf(files);

// Create a variable called 'i' and set it to 0. So long as 'i' is below (<) 'imax', run the loop and then add 1 to it (the '++' is a shortcut for this).
for (i = 0; i < imax; i++) {

	// For just the first run through the loop make the output folder.
	if (i == 0) {

		File.makeDirectory(path + "Overlays");

	}

    // Run the 'GAS_batch()' function for each of the files.
	GAS_batch(path + files[i]);
           
}

// Table labels (2 results per gut - to get names correct = ix2 (e.g. gut 4 will be 8 results in, therefore the first result for gut 4 will be (4x2+1 = 9))
for (i = 0; i < lengthOf(files); i++) {

	setResult("Label", (i * 2), files[i]);
	setResult("Label", ((i * 2) + 1), files[i]);
	
}
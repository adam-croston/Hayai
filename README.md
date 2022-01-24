
# Hayai
Hayai is a very simple projection mapping tool with an emphasis on very rapid set up times. The word "hayai" means "fast; quick; hasty; brisk" in Japanese. The program was built was built with  Processing ([1]).

## Credits
Original code by Adam Croston.

## LISCENSE
Copyright Adam Croston 2022.
This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](
http://creativecommons.org/licenses/by-sa/4.0/).

##  INSTALLATION
### Download the App Code
Download the [Code](https://github.com/adam-croston/Hayai/archive/refs/heads/develop.zip).

### Install Processing 3.5.4
Follow the directions on the [Processing]( http://www.processing.org) site.

### Install the Processing "Video" library
This is a [GStreamer](https://gstreamer.freedesktop.org/) (an open source multimedia framework) based video library for Processing.
- From the Processing dev environment select the menu item "'Sketch' ---> 'Import Library' ---> 'Add Library'".
- Select "Video" in the list and click "Install".
 
### Install the "gifAnimation" Libary
This is a library to play and export GIF animations
- Download the full [code](https://github.com/01010101/GifAnimation/archive/master.zip).
- To install the gifAnimation animation library- see the readme in that repo.
- Determine the Processing environments "Sketchbook folder" by selecting the menu item "'File' ---> 'Preferences'".
    - It should look something like: "C:\Users\MyUserName\Documents\Processing".
- Unzip "master.zip" somewhere.
 - Rename "GifAnimation-master" to "GifAnimation".
 - Move the renamed folder to inside of the folder named "libraries" which is itself inside the "Sketchbook folder".
 - To confirm this took properly:
	 - Launch the Processing dev environment.
	 - Select the menu item "'File' ---> 'Examples'".
	 - In the list that appears open the item named "Contributed Libraries".
	 - Open the item "GifAnimation" and then double click the item called "gifDisplay".
    - Run the program.
    - It should display a Sketch window with 3 lava lamps: the first should be constantly animating, the second will only animate a single cycle for each mouse click, and the third will only animate while the mouse moves horizontally over the Sketch window.

### Open the Processing project
- Go inside the code folder and double click the "hayai.pde" file.
	- It and all associated files in the project should open in the Processing editor.

## USAGE
Hayai is intended to be used with a video projector where the projector image is the same as the main desktop screen.
- Hayai starts in full-screen mode.
- You will start in a default empty scene.
- On screen controls can be exposed/hidden by pressing the SPACE key.
- To quit simple press the ESCAPE key.

### Scenes
A scene is composed of one or many shapes. They are intended to be projected into a real world 3D environment.
- Each shape can have a detailed contour, a lively image, and a manually tweaked perspective correcting warp applied to it.
- Scenes can be saved and loaded using the "SAVE SCENE" and "LOAD SCENE" buttons.

### Shapes
Shapes are contoured polygons with a warped image or animation inside of them.
- Shapes can be created, deleted, moved, copied, rotated, flipped, etc.
- Shapes have three important attributes which can all be set and adjusted:
	- Contour (a polygonal outline),
	- Image (which may be static or animated),
	- Warp (the key-stoning perspective correction we can easily apply).

#### To Create a New Shape
- Click on the "Make Shape" mode toggle and then click anywhere to begin creating the shape's contour.
- Left clicks will start a new contour (and thus shape) or add a new point to the end of the current contour (or if close enough to the start point close the shape).

#### To Move a Shape
- Clicking on the “MOVE SHAPE” mode button then left click alone will select the shape.
- While in “MOVE SHAPE” mode left clicking and dragging will move a shape to the desired position.
	- This will select and move both the contour and the associated warped imaged of the shape.
- While in “MOVE SHAPE” mode  with a selected shape the arrow keys may be used to move a shape around pixel by pixel.
		- Pressing the "SHIFT" key and the arrow keys will make moves larger (10x).
- The order in which shapes are draw can be modified by selecting a shape and then using the layer up and down buttons "Up" and "Dn".

#### To Delete, Copy, and Paste Shapes
- This is done by making sure a shape is selected (see above) and then using the DELETE key, CONTROL-C key, or CONTROL-V key.

#### To Add an Image or Animation to a Shape
Without an image a shape will be boring and only display the default graph paper like image.
- With a current shape (which can be selected if not already by clicking on the "MOVE SHAPE" button then left clicking on the shape) press the "SET IMAGE" button then select an image or animation file.
	- Image and animations types supported are: gif, jpg, png, avi, mov, and mp4 files.
#### To Warp a Shape Image (i.e. set key-stoning)
Warping the image is used to make to image appear perspective correct even on extremely oblique surfaces relative to the projector or simply to make the image more interesting.
- With a current shape (which can be selected if not already by clicking on the "MOVE SHAPE" button then left clicking on the shape) press the "FIT WARP" button.
	- This work especially well if the contour is defined with only four points.
	- A common strategy is to initially create shapes with quads that have their four corners aligned to the (seen or imagined) corners of a flat surface and then later add contour point take make the contour of the perimeter match the selected surface/object well.
-  Clicking on the "EDIT WARP" button will allow you to:
	- Move the warp's four control points via left mouse click and drag.
		- This is more easily visualized if the "MASK/NO MASK" toggle is set to "NO MASK".
	-  Change perspective warping strength via the mouse wheel.
		- Middle click to alternate which axis of the perspective warping strength to modify.

#### To Rotate and Mirror Shapes
- While in “MOVE SHAPE” mode with a selected shape:
	- The "fx" and "fy" buttons will flip the shape (and associated warped image) acros it's x-axis or y-axis respectively.
	- The "rR" and "rL" buttons will rotate the shape (and associated warped image) clockwise and anti-clockwise respectively.
- While in “EDIT WARP” mode with a selected shape the above buttons will adjust only the warped image and not the shape contour.
  

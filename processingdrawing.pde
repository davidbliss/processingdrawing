// this is the start of a tool for loading, cropping and processing images. 
// currently uses contours to determin points, then draws lines between all points within range of each point.

// BUG: If you save an image then change the canvas size, (eithr by crop or by scale) the image will not save again properly

import controlP5.*;
import java.util.Map;

ControlP5 cp5;
Group imageGroup;
Group filterGroup;
Group drawingGroup;

Renderer renderer; 

PImage img;
String imgPath;
boolean cropped;
int cropStartX, cropStartY, cropX, cropY, cropW, cropH; 

int progress = 0;
float drawingScale = 1;
int[] canvasOffset = new int[2];
int[] canvasOffsetStart = new int[2];

PGraphics displayCanvas;

int controlPanelHeight = 100;
int controlPanelBGColor = 185;
int controlsVOffset = 3;
int controlHeight = 10;

int settingsGroupX;
int settingsGroupY;

int filterGroupX;
int filterGroupY;

final int WAITING_FOR_IMAGE = 0;
final int DISPLAYING_IMAGE = 1;
final int CROPPING_TO_START = 2;
final int CROPPING = 3;
final int DRAWING = 4;
final int DRAWING_DONE = 5;
final int DISPLAYING_DRAWING = 6;
static int appState;

void setup(){
  size(1400,800, P2D);
  cp5 = new ControlP5(this);
  
  cp5.addSlider("progress")
     .setPosition(0, height-controlPanelHeight)
     .setHeight(3)
     .setWidth(width)
     .setRange(0,100)
     .getValueLabel().setVisible(false)
     ;
     
  imageGroup = cp5.addGroup("imageGroup")
    .setLabel("image")
    .setPosition(30, height-controlPanelHeight+20)
    .setWidth(255)
    .setBackgroundHeight(controlPanelHeight-20)
    .setBackgroundColor(color(controlPanelBGColor))
    ;
  
  cp5.addButton("loadFromFile")
     .setLabel("load from file")
     .setPosition(5, controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(imageGroup)
     ;
   
   cp5.addButton("startCrop")
     .setLabel("crop image")
     .setPosition(cp5.get("loadFromFile").getWidth() + cp5.get("loadFromFile").getPosition()[0] + 5, controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(imageGroup)
     ;
   
   cp5.addButton("clearCrop")
     .setLabel("clear crop")
     .setPosition(cp5.get("startCrop").getWidth() + cp5.get("startCrop").getPosition()[0] + 5, controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(imageGroup)
     ;
     
   cp5.addButton("showImage")
     .setLabel("show image")
     .setPosition(5, cp5.get("loadFromFile").getHeight() + cp5.get("loadFromFile").getPosition()[1] + controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(imageGroup)
     ;
     
   cp5.addButton("resetImage")
     .setLabel("reset image")
     .setPosition(cp5.get("showImage").getWidth() + cp5.get("showImage").getPosition()[0] + 5,  cp5.get("showImage").getPosition()[1] )
     .setHeight(controlHeight)
     .setGroup(imageGroup)
     ;
   
  drawingGroup = cp5.addGroup("drawingGroup")
    .setLabel("drawing")
    .setPosition((imageGroup.getWidth() + imageGroup.getPosition()[0] + 20)*2, height-controlPanelHeight+20)
    .setWidth(255)
    .setBackgroundHeight(controlPanelHeight-20)
    .setBackgroundColor(color(controlPanelBGColor))
    ;
  
  // if render list comes firt, then options are below all these buttons, with it at the end, I can't get measurments. Shortcut, hardcode the top of the first button
  cp5.addButton("startDrawing")
     .setLabel("draw")
     .setPosition(5, 13 + controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(drawingGroup)
     ;
  
  cp5.addButton("saveCanvas")
     .setLabel("save Image")
     .setPosition(cp5.get("startDrawing").getWidth() + cp5.get("startDrawing").getPosition()[0] + 5, cp5.get("startDrawing").getPosition()[1])
     .setHeight(controlHeight)
     .setGroup(drawingGroup)
     ;
     
  cp5.addButton("saveSVG")
     .setLabel("save svg")
     .setPosition(cp5.get("saveCanvas").getWidth() + cp5.get("saveCanvas").getPosition()[0] + 5, cp5.get("startDrawing").getPosition()[1])
     .setHeight(controlHeight)
     .setGroup(drawingGroup)
     ;
     
   cp5.addButton("showDrawing")
     .setLabel("show drawing")
     .setPosition(5, cp5.get("startDrawing").getHeight() + cp5.get("startDrawing").getPosition()[1] + controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(drawingGroup)
     ;
     
  cp5.addButton("showFitDrawing")
     .setLabel("scaleToFit")
     .setPosition(cp5.get("startDrawing").getWidth() + cp5.get("startDrawing").getPosition()[0] + 5, cp5.get("showDrawing").getPosition()[1])
     .setHeight(controlHeight)
     .setGroup(drawingGroup)
     ;
  
  cp5.addDropdownList("rendererList")
    .setPosition(5, controlsVOffset)
    .setOpen(false)
    .setHeight(80)
    .setCaptionLabel("Choose Renderer")
    .addItem("contours", 0)
    .addItem("contours, near points", 1)
    .addItem("hatching", 1)
    .addItem("stipple", 1)
    .addItem("COM, lines", 1)
    .addItem("halftone", 1)
    .setGroup(drawingGroup)
    ;
    
  settingsGroupX = (int)drawingGroup.getWidth() + (int)drawingGroup.getPosition()[0] + 20;
  settingsGroupY = height-controlPanelHeight+20;
  
  filterGroupX = (int)imageGroup.getWidth() + (int)imageGroup.getPosition()[0] + 20;
  filterGroupY = height-controlPanelHeight+20;
  
  filterGroup = cp5.addGroup("filterGroup")
    .setLabel("filter settings")
    .setPosition(filterGroupX, filterGroupY)
    .setWidth(255)
    .setBackgroundHeight(controlPanelHeight-20)
    .setBackgroundColor(color(controlPanelBGColor))
    ;
  
  cp5.addButton("grayFilter")
     .setLabel("gray")
     .setPosition(5, controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(filterGroup)
     ;
     
  cp5.addButton("erodeFilter")
     .setLabel("erode")
     .setPosition(cp5.get("grayFilter").getWidth() + cp5.get("grayFilter").getPosition()[0] + 5, controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(filterGroup)
     ;
   
   cp5.addButton("dilateFilter")
     .setLabel("dilate")
     .setPosition(cp5.get("erodeFilter").getWidth() + cp5.get("erodeFilter").getPosition()[0] + 5, controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(filterGroup)
     ;
  
  cp5.addButton("blurFilter")
     .setLabel("blur")
     .setPosition(5, cp5.get("grayFilter").getHeight() + cp5.get("grayFilter").getPosition()[1] + controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(filterGroup)
     ;
     
  cp5.addSlider("blurDiameter")
     .setPosition(cp5.get("blurFilter").getPosition()[0]+cp5.get("blurFilter").getWidth()+5, cp5.get("blurFilter").getPosition()[1] )
     .setRange(0,100)
     .setLabel("diameter")
     .setGroup(filterGroup)
     .setValue(1)
     .setNumberOfTickMarks(101)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
  cp5.addButton("thresholdFilter")
     .setLabel("threshold")
     .setPosition(5, cp5.get("blurFilter").getHeight() + cp5.get("blurFilter").getPosition()[1] + controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(filterGroup)
     ;
     
   cp5.addSlider("thresholdThreshold")
     .setPosition(cp5.get("thresholdFilter").getPosition()[0]+cp5.get("thresholdFilter").getWidth()+5, cp5.get("thresholdFilter").getPosition()[1] )
     .setRange(0,1)
     .setLabel("threshold")
     .setGroup(filterGroup)
     .setValue(.5)
     ;
     
   cp5.addButton("posterizeFilter")
     .setLabel("posterize")
     .setPosition(5, cp5.get("thresholdFilter").getHeight() + cp5.get("thresholdFilter").getPosition()[1] + controlsVOffset)
     .setHeight(controlHeight)
     .setGroup(filterGroup)
     ;
   
   cp5.addSlider("posterizeThreshold")
     .setPosition(cp5.get("posterizeFilter").getPosition()[0]+cp5.get("posterizeFilter").getWidth()+5, cp5.get("posterizeFilter").getPosition()[1] )
     .setRange(2,255)
     .setLabel("threshold")
     .setGroup(filterGroup)
     .setValue(10)
     .setNumberOfTickMarks(254)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
  appState = WAITING_FOR_IMAGE;
 
  smooth();
  clearArea();
}

void draw(){
  // background for controls
  int response;
  switch(appState){
    case DISPLAYING_IMAGE:
      clearArea();
      drawImage();
      break;
    case CROPPING:
      clearArea();
      drawImage();
      drawCrop();
      break;
    case DRAWING:
      response = renderer.draw(displayCanvas, getImage());
      
      if( response == DRAWING_DONE){
        println("drawing complete");
        appState = DISPLAYING_DRAWING;
      } else {
        drawCanvas();
      }
      break;
    case DISPLAYING_DRAWING:
      drawCanvas();
      break;
  }
  
  noStroke();
  fill(controlPanelBGColor);
  rect(0, height - controlPanelHeight, width, controlPanelHeight);
  noFill();
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    if (theEvent.getController().getName()=="rendererList"){
      appState = DISPLAYING_IMAGE;
      DropdownList ddl = (DropdownList)theEvent.getController();
      Map item = (Map) ddl.getItem( (int) theEvent.getValue() );
      println(item.get("name"));
      if (item.get("name")== "contours, near points"){
        if (renderer != null) renderer.cleanUp();
        renderer = new RendererNearPoints(cp5, settingsGroupX, settingsGroupY);
      } else if (item.get("name")== "contours"){
        if (renderer != null) renderer.cleanUp();
        renderer = new RendererContours(cp5, settingsGroupX, settingsGroupY);
      } else if (item.get("name")== "hatching"){
        if (renderer != null) renderer.cleanUp();
        renderer = new RendererHatching(cp5, settingsGroupX, settingsGroupY);
      } else if (item.get("name")== "stipple"){
        if (renderer != null) renderer.cleanUp();
        renderer = new RendererStipple(cp5, settingsGroupX, settingsGroupY);
      } else if (item.get("name")== "COM, lines"){
        if (renderer != null) renderer.cleanUp();
        renderer = new RendererLinesCOM(cp5, settingsGroupX, settingsGroupY);
      } else if (item.get("name")== "halftone"){
        if (renderer != null) renderer.cleanUp();
        renderer = new RendererHalftone(cp5, settingsGroupX, settingsGroupY);
      } else {
        println("no match found for renderer");
      }
    }
  }
}



void mousePressed(){
  switch(appState){
    case CROPPING_TO_START:
      cropStartX = mouseX;
      cropStartY = mouseY;
      appState = CROPPING;
      break;
    case DISPLAYING_DRAWING:
      canvasOffsetStart[0] = -1;
      if (mouseY<height-controlPanelHeight) {
        canvasOffsetStart[0] = mouseX;
        canvasOffsetStart[1] = mouseY;
      }
      break;
  }
}

void mouseReleased(){
  switch(appState){
    case CROPPING:
      if (cropStartX<mouseX){
        cropX = cropStartX;
        cropW = mouseX-cropStartX;
      } else {
        cropX = mouseX;
        cropW = cropStartX - mouseX;
        cropStartX = mouseX;
      }
      
      if (cropStartY<mouseY){
        cropY = cropStartY;
        cropH = mouseY-cropStartY;
      } else {
        cropY = mouseY;
        cropH = cropStartY - mouseY;
        cropStartY = mouseY;
      }
   
      cropped = true;
      
      appState = DISPLAYING_IMAGE;
      println("displaying image");
      break;
    case DISPLAYING_DRAWING:
      if (canvasOffsetStart[0]>-1){
        canvasOffset[0] -= canvasOffsetStart[0] - mouseX;
        canvasOffset[1] -= canvasOffsetStart[1] - mouseY;
      }
      break;
  }
}

void drawCanvas(){
  clearArea();
  image(displayCanvas, canvasOffset[0], canvasOffset[1], (int)(drawingScale*displayCanvas.width) , (int)(drawingScale*displayCanvas.height));
}

void clearArea(){
  clear();
  background(255);
}

void showImage(){
  appState=DISPLAYING_IMAGE;
}

void showDrawing(){
  canvasOffset[0]=0;
  canvasOffset[1]=0;
  drawingScale = 1.0;
  appState=DISPLAYING_DRAWING;
}

void showFitDrawing(){
  canvasOffset[0]=0;
  canvasOffset[1]=0;
  if (width<displayCanvas.width || (height-controlPanelHeight)<displayCanvas.height ) drawingScale = min( (float)width/displayCanvas.width, (float)(height-controlPanelHeight)/displayCanvas.height);
  appState=DISPLAYING_DRAWING;
}

void drawImage(){
  if (img!=null) image(img, 0, 0);
  if (cropped) drawCrop();
}

void drawCrop(){
  stroke(0, 100);
  if (appState == CROPPING) rect(cropStartX, cropStartY, mouseX-cropStartX, mouseY-cropStartY);
  else rect(cropX, cropY, cropW, cropH);
}

void startCrop(){
  println("select the crop");
  appState = CROPPING_TO_START;
}

void clearCrop(){
  cropped = false;
}

void saveCanvas(){
  //selectOutput("Output .png file name:", "pngFileSelected");
  displayCanvas.save("output/output.png");
}

void loadFromFile(){
  selectInput("Select a file to process:", "loadImageFromDisk");
}

void loadImageFromDisk(File selection){
  if (selection == null) {
    println("dialog closed or canceled.");
  } else {
    println("path selected " + selection.getAbsolutePath());
    displayChosenImage(selection.getAbsolutePath());
  }
}

void resetImage(){
  img = loadImage(imgPath); 
}

void displayChosenImage(String path){
  img = loadImage(path); 
  imgPath = path;
  println("should have drawn image");
  appState=DISPLAYING_IMAGE;
}

void startDrawing(){
  if (renderer == null){
    println("you must first select a renderer");
  } else {
    clearArea();
    int[] dims;
    if (img!=null){
      dims = renderer.processImage(getImage());
    } else {
      println("you must first load an image");
      return;
    }
    
    displayCanvas = createGraphics(dims[0], dims[1], P2D);
    println("image will be " +displayCanvas.width +" by " + displayCanvas.height);
      
    appState = DRAWING;
    println("drawing started");
  }
}

void grayFilter(){
  img.filter(GRAY);
}

void dilateFilter(){
  img.filter(DILATE);
}

void erodeFilter(){
  img.filter(ERODE);
}

void blurFilter(){
  img.filter(BLUR, cp5.getController("blurDiameter").getValue());
}

void thresholdFilter(){
  img.filter(THRESHOLD, cp5.getController("thresholdThreshold").getValue());
}

void posterizeFilter(){
  img.filter(POSTERIZE, cp5.getController("posterizeThreshold").getValue());
}

void saveSVG(){
  selectOutput("Output .svg file name:", "pdfFileSelected");
}

void pdfFileSelected(File selection) {
  String savePath = selection.getAbsolutePath();
  String[] p = splitTokens(savePath, ".");
  boolean fileOK = false;

  if ( p[p.length - 1].equals("SVG"))
    fileOK = true;
  if ( p[p.length - 1].equals("svg"))
    fileOK = true;      

  if (fileOK == false)
    savePath = savePath + ".svg";
    
  println("Saving SVG File");

  String[] FileOutput = loadStrings("svg_header.txt"); 

  // each renderer needs to generate their own appropriate SVG file data.
  FileOutput = renderer.getSVGData(FileOutput, getImage());
  
  // SVG footer:
  FileOutput = append(FileOutput, "</g></g></svg>");
  saveStrings(savePath, FileOutput);
  println("saving complete");
}

void pngFileSelected(File selection){
  // TODO BUG: crashes if you save after calling for path 
  String savePath = selection.getAbsolutePath();
  String[] p = splitTokens(savePath, ".");
  boolean fileOK = false;

  if ( p[p.length - 1].equals("PNG"))
    fileOK = true;
  if ( p[p.length - 1].equals("png"))
    fileOK = true;      
  if (fileOK == false)
    savePath = savePath + ".png";

  
  displayCanvas.save(savePath);
  println("image saved");
}

PImage getImage(){
  if (cropped) {
    return img.get(cropX, cropY, cropW, cropH);
  } else {
    return img;
  } 
}
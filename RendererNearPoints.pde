import controlP5.*;
import blobDetection.*;

class RendererNearPoints extends Renderer{
  Point2d[] points;
  BlobDetection[] theBlobDetection;
  int p1=0;
  
  Group settingsGroup;
  
  RendererNearPoints(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
    settingsGroup = cp5.addGroup("settingsGroup")
    .setLabel("render settings")
    .setPosition(settingsGroupX, settingsGroupY)
    .setWidth(255)
    .setBackgroundHeight(controlPanelHeight-20)
    .setBackgroundColor(color(controlPanelBGColor))
    ;
    
    cp5.addSlider("levels")
     .setPosition(5, controlsVOffset)
     .setRange(0,15)
     .setGroup(settingsGroup)
     .setValue(9)
     .setNumberOfTickMarks(16)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
   cp5.addSlider("factor")
     .setPosition(5, cp5.get("levels").getHeight() + cp5.get("levels").getPosition()[1] + controlsVOffset)
     .setRange(0,20)
     .setLabel("scale factor")
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(21)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("threshold")
     .setPosition(5, cp5.get("factor").getHeight() + cp5.get("factor").getPosition()[1] + controlsVOffset)
     .setRange(0,60)
     .setGroup(settingsGroup)
     .setValue(30)
     .setNumberOfTickMarks(61)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("drawLineAlpha")
     .setLabel("line alpha")
     .setPosition(5, cp5.get("threshold").getHeight() + cp5.get("threshold").getPosition()[1] + controlsVOffset)
     .setRange(0,40)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(41)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  }
  
  public void cleanUp(){
    settingsGroup.remove();
  }
  
  private int getLevels(){
    return (int) cp5.getController("levels").getValue();
  }
  
  private int getFactor(){
    return (int) cp5.getController("factor").getValue();
  }
 
  private int getAlpha(){
    return (int) cp5.getController("drawLineAlpha").getValue();
  }
  
  private int getThreshold(){
    return (int) cp5.getController("threshold").getValue();
  }
  
  public int[] processImage(PImage img){ 
    //Computing Blobs with different thresholds 
    theBlobDetection = new BlobDetection[int(getLevels())];
    points =  new Point2d[0];
    
    for (int i=0 ; i<getLevels() ; i++) {
      theBlobDetection[i] = new BlobDetection(img.width, img.height);
      theBlobDetection[i].setThreshold(i/(float)getLevels());
      theBlobDetection[i].computeBlobs(img.pixels);
    }
    
    for (int i=0 ; i<getLevels() ; i++) { 
      extractContourPoints(i, img);
    }
    
    println(points.length + " points extracted");
    
    p1=0;
    
    int[] wh = new int[2];
    wh[0] = img.width*getFactor();
    wh[1] = img.height*getFactor();
    return wh;
  }
  
  private void extractContourPoints(int i, PImage img) {
    Blob b;
    EdgeVertex eA;
    for (int n=0 ; n<theBlobDetection[i].getBlobNb() ; n++) {
      b=theBlobDetection[i].getBlob(n);
      if (b!=null) {
        for (int m=0;m<b.getEdgeNb();m++) {
          eA = b.getEdgeVertexA(m);
          if (eA !=null){
            if (points==null){
              points = new Point2d[1];
              points[0] = new Point2d(eA.x*img.width*getFactor(), eA.y*img.height*getFactor());
            } else{
              points = (Point2d[]) append (points, new Point2d(eA.x*img.width*getFactor(), eA.y*img.height*getFactor()));
            }
          }
        }
      }
    }
  }
    
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    displayCanvas.stroke(0, getAlpha());
    //println("drawing " + p1 + " of " + points.length);     
    for (int p2=0; p2 < points.length; p2++){  
      if (points[p1].distanceTo(points[p2]) < getThreshold() && p1!=p2){
        displayCanvas.line(points[p1].x, points[p1].y, points[p2].x, points[p2].y);
      }
    }
    displayCanvas.endDraw();
    p1++;
    cp5.get("progress").setValue((int)((float)p1/points.length*100));
    if (p1 >= points.length){
      return DRAWING_DONE;
    } else {
      return DRAWING;
    }
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){ 
    String rowTemp;
    for (int p1=0; p1 < points.length; p1++){
      rowTemp = "<path style=\"fill:none;stroke:black;stroke-opacity:"+getAlpha()/100.0+";stroke-width:1px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M ";
      FileOutput = append(FileOutput, rowTemp);
      for (int p2=0; p2 < points.length; p2++){  
        if (points[p1].distanceTo(points[p2]) < getThreshold() && p1!=p2){
          rowTemp = points[p1].x + " " + points[p1].y + "\r";
          FileOutput = append(FileOutput, rowTemp);
          rowTemp = points[p2].x + " " + points[p2].y + "\r";
          FileOutput = append(FileOutput, rowTemp);
        }
      }
      FileOutput = append(FileOutput, "\" />"); // End path description
    }
   
    return FileOutput;
  }
}
import controlP5.*;
import blobDetection.*;

class RendererContours extends Renderer{
  // This rendered will find edges in the image in the form of contours and draw them. 
  
  BlobDetection[] theBlobDetection;
  int p1=0;
  Group settingsGroup;
  
  RendererContours(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
    
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
     .setValue(5)
     .setNumberOfTickMarks(16)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
   cp5.addSlider("factor")
     .setPosition(5, cp5.get("levels").getHeight() + cp5.get("levels").getPosition()[1] + controlsVOffset)
     .setRange(0,20)
     .setLabel("scale factor")
     .setGroup(settingsGroup)
     .setValue(5)
     .setNumberOfTickMarks(21)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("drawLineAlpha")
     .setLabel("line alpha")
     .setPosition(5, cp5.get("factor").getHeight() + cp5.get("factor").getPosition()[1] + controlsVOffset)
     .setRange(0,255)
     .setGroup(settingsGroup)
     .setValue(75)
     .setNumberOfTickMarks(256)
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
  
  public int[] processImage(PImage img){ 
    //Computing Blobs with different thresholds 
    theBlobDetection = new BlobDetection[int(getLevels())];
    
    for (int i=0 ; i<getLevels() ; i++) {
      theBlobDetection[i] = new BlobDetection(img.width, img.height);
      theBlobDetection[i].setThreshold(i/(float)getLevels());
      theBlobDetection[i].computeBlobs(img.pixels);
    }
    
    // TODO: try to order each contour, connecting each edgeb with an edgea.
    
    p1=0;
    
    int[] wh = new int[2];
    wh[0] = img.width*getFactor();
    wh[1] = img.height*getFactor();
    return wh;
  }
    
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    displayCanvas.strokeWeight(1);
    displayCanvas.stroke(0, getAlpha());
    displayCanvas.noFill();
    
    Blob b;
    EdgeVertex eA,previouseA=null;
    for (int n=0 ; n<theBlobDetection[p1].getBlobNb() ; n++) {
      b=theBlobDetection[p1].getBlob(n);
      if (b!=null) {
        for (int m=0;m<b.getEdgeNb();m++) {
          eA = b.getEdgeVertexA(m);
          
          if (previouseA == null){
            displayCanvas.beginShape();
            displayCanvas.vertex(eA.x*displayCanvas.width, eA.y*displayCanvas.height);
            
            previouseA = eA;
          } else {
            if (distanceBetween2Points(new float[]{eA.x, eA.y}, new float[] {previouseA.x, previouseA.y})<.01){
              
              displayCanvas.vertex(eA.x*displayCanvas.width, eA.y*displayCanvas.height);
              previouseA = eA;
            } else {
              previouseA=null;
              displayCanvas.endShape();
            }
          }
        }
      }
    }
    displayCanvas.endDraw();
    p1++;
    cp5.get("progress").setValue((int)((float)p1/getLevels()*100));
    if (p1 >= getLevels()){
      return DRAWING_DONE;
    } else {
      return DRAWING;
    }
  }

  public String[] getSVGData(String[] FileOutput, PImage image){ 
    Blob b;
    EdgeVertex eA,eB;
    String rowTemp;
    for (int blob=0 ; blob<theBlobDetection.length; blob++){
      for (int n=0 ; n<theBlobDetection[blob].getBlobNb() ; n++) {
        b=theBlobDetection[blob].getBlob(n);
        if (b!=null) {
          for (int m=0;m<b.getEdgeNb();m++) {
            // eB of point m equals aA of point m-1
            // if you just connect all the eA values you miss the last segment (don't close a closed path)
            // sometimes the 2 points of the edge are the same, they should be ignored
            // just connecting eA of the points shows that the order of edges is not entirely (open shapes are broken closed), so we draw an individual line for each edge
            eA = b.getEdgeVertexA(m);
            eB = b.getEdgeVertexB(m);
            if (eA !=null && eB !=null && !(eA.x==eB.x&&eA.y==eB.y) ){
              rowTemp = "<path style=\"fill:none;stroke:black;stroke-opacity:"+getAlpha()/100.0+";stroke-width:1px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M ";
              FileOutput = append(FileOutput, rowTemp);
              rowTemp = eA.x*image.width*getFactor() + " " + eA.y*image.height*getFactor() + "\r";
              FileOutput = append(FileOutput, rowTemp);
              rowTemp = eB.x*image.width*getFactor() + " " + eB.y*image.height*getFactor() + "\r";
              FileOutput = append(FileOutput, rowTemp);
              FileOutput = append(FileOutput, "\" />"); // End path description
            } 
          }
        }
      }
    }
    return FileOutput;
  }
}
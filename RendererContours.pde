import controlP5.*;
import blobDetection.*;

class RendererContours extends Renderer{
  // This rendered will find edges in the image in the form of contours and draw them. 
  
  BlobDetection[] theBlobDetection;
  Group settingsGroup;
  float[][][] lines;
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
    lines = new float[0][0][2];
    //Computing Blobs with different thresholds 
    theBlobDetection = new BlobDetection[int(getLevels())];
    
    for (int i=0 ; i<getLevels() ; i++) {
      theBlobDetection[i] = new BlobDetection(img.width, img.height);
      theBlobDetection[i].setThreshold(i/(float)getLevels());
      theBlobDetection[i].computeBlobs(img.pixels);
    }
    
    Blob b;
    EdgeVertex eA, previouseA=null;
    for (int level=0; level<getLevels(); level++){
      for (int n=0 ; n<theBlobDetection[level].getBlobNb() ; n++) {
        b=theBlobDetection[level].getBlob(n);
        if (b!=null) {
          float[][]line=new float[0][2];
          for (int m=0;m<b.getEdgeNb();m++) {
            eA = b.getEdgeVertexA(m);
            if (previouseA == null){
              line = (float[][])append(line, new float[]{eA.x, eA.y});
              previouseA = eA;
            } else {
              if (distanceBetween2Points(new float[]{eA.x, eA.y}, new float[] {previouseA.x, previouseA.y})<.01){ 
                line = (float[][])append(line, new float[]{eA.x, eA.y});
                previouseA = eA;
              } else {
                if (line.length>0) lines = (float[][][]) append(lines, line);
                line=new float[0][2];
                previouseA=null;
              }
            }
          }
          if (line.length>0) lines = (float[][][]) append(lines, line);
        }
      }
    }
    
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
    for (int line=0; line<lines.length; line++){
      displayCanvas.beginShape();
      for (int point=0; point<lines[line].length; point++){
        displayCanvas.vertex(lines[line][point][0]*displayCanvas.width, lines[line][point][1]*displayCanvas.height);
      }
      displayCanvas.endShape();
    }
    displayCanvas.endDraw();
    
    return DRAWING_DONE;
  }

  public String[] getSVGData(String[] FileOutput, PImage image){ 
    Blob b;
    EdgeVertex eA,eB;
    String rowTemp;
    
    for (int line=0; line<lines.length; line++){
      rowTemp = "<path style=\"fill:none;stroke:black;stroke-opacity:"+getAlpha()/100.0+";stroke-width:1px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M ";
      FileOutput = append(FileOutput, rowTemp);
      for (int point=0; point<lines[line].length; point++){
        rowTemp = lines[line][point][0]*image.width*getFactor() + " " + lines[line][point][1]*image.height*getFactor() + "\r";
        FileOutput = append(FileOutput, rowTemp);
      }
      FileOutput = append(FileOutput, "\" />"); // End path description
    }
    
    return FileOutput;
  }
}
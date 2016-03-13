// draws horizontal line, offsetting y bassed on the center of mass for a vertical sample of pixels at a given x (darker pixel value = greater massmass) 
import controlP5.*;

class RendererLinesCOM extends Renderer{
  Group settingsGroup;
  int numberLines = 0;
  int numberSegments = 0;
  int canvasVertOffset; 
  
  int[][][] lines = {}; // a line consists of points which consist of coords
  
  RendererLinesCOM(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
    println("creating RendererLinesCOM");
   
    settingsGroup = cp5.addGroup("settingsGroup")
    .setLabel("render settings")
    .setPosition(settingsGroupX, settingsGroupY)
    .setWidth(255)
    .setBackgroundHeight(controlPanelHeight-20)
    .setBackgroundColor(color(controlPanelBGColor))
    ;
    
    cp5.addSlider("cellWidth")
     .setLabel("cell Width")
     .setPosition(5, controlsVOffset)
     .setRange(1,35)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(35)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
   cp5.addSlider("cellHeight")
     .setLabel("cell height")
     .setPosition(5, cp5.get("cellWidth").getHeight() + cp5.get("cellWidth").getPosition()[1] + controlsVOffset)
     .setRange(1,15)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(15)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("sampleWidth")
     .setLabel("sample width")
     .setPosition(cp5.get("cellHeight").getWidth() + cp5.get("cellHeight").getPosition()[0] + 100, controlsVOffset)
     .setRange(1,25)
     .setGroup(settingsGroup)
     .setValue(1)
     .setNumberOfTickMarks(25)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("sampleHeight")
     .setLabel("sample height")
     .setPosition(cp5.get("sampleWidth").getPosition()[0], cp5.get("sampleWidth").getHeight() + cp5.get("sampleWidth").getPosition()[1] + controlsVOffset)
     .setRange(1,21)
     .setGroup(settingsGroup)
     .setValue(11)
     .setNumberOfTickMarks(21)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  
  cp5.addSlider("scaleFactor")
     .setLabel("scale factor")
     .setPosition(5, cp5.get("sampleHeight").getHeight() + cp5.get("sampleHeight").getPosition()[1] + controlsVOffset)
     .setRange(1,20)
     .setGroup(settingsGroup)
     .setValue(1)
     .setNumberOfTickMarks(20)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  
    cp5.addSlider("curveTightness")
     .setLabel("curve tightness")
     .setPosition(5, cp5.get("scaleFactor").getHeight() + cp5.get("scaleFactor").getPosition()[1]+ controlsVOffset)
     .setRange(-5,5)
     .setGroup(settingsGroup)
     .setValue(0.0)
     ;
     
    cp5.addSlider("vertOffset")
     .setLabel("vert offset")
     .setPosition(cp5.get("curveTightness").getPosition()[0]+cp5.get("scaleFactor").getWidth()+100 , cp5.get("curveTightness").getPosition()[1])
     .setRange(0,15)
     .setGroup(settingsGroup)
     .setValue(11)
     .setNumberOfTickMarks(16)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
    cp5.addSlider("vertScale")
     .setLabel("vert scale")
     .setPosition(cp5.get("vertOffset").getPosition()[0], cp5.get("vertOffset").getHeight() + cp5.get("vertOffset").getPosition()[1]+ controlsVOffset)
     .setRange(0,255)
     .setGroup(settingsGroup)
     .setValue(20)
     .setNumberOfTickMarks(256)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
    cp5.addToggle("COM")
     .setPosition(5, cp5.get("curveTightness").getHeight() + cp5.get("curveTightness").getPosition()[1] + controlsVOffset)
     .setSize(50,10)
     .setValue(true)
     .setGroup(settingsGroup)
     ;
  }
  
  public void cleanUp(){
    settingsGroup.remove();
  }
  
  private int getCellWidth(){
    return (int) cp5.getController("cellWidth").getValue();
  }
  
  private int getCellHeight(){
    return (int) cp5.getController("cellHeight").getValue();
  }
 
  private int getSampleWidth(){
    return (int) cp5.getController("sampleWidth").getValue();
  }
  
  private int getSampleHeight(){
    return (int) cp5.getController("sampleHeight").getValue();
  }
  
  private int getScaleFactor(){
    return (int) cp5.getController("scaleFactor").getValue();
  }
  
  private int getCurveTightness(){
    return (int) cp5.getController("curveTightness").getValue();
  }
  
  private int getVertScale(){
    return (int) cp5.getController("vertScale").getValue();
  }
  
  // TODO: COM mode should take scale and offset into account
  
  private int getVertOffset(){
    return (int) cp5.getController("vertOffset").getValue();
  }
  
  private int getCOM(){
    return (int) cp5.getController("COM").getValue();
  }
  
  public int[] processImage(PImage img){ 
    println("processing");
    numberLines = floor(img.height / getCellHeight());
    numberSegments = floor(img.width / getCellWidth());
    
    lines= new int[0][0][0];
    
    for (int line=0; line <= numberLines; line++){
      int thisY = line*getCellHeight();
      // get sample range for Y axis
      int topOfSample;
      int bottomOfSample;
      if (getSampleHeight()>1){
        int halfOfSample = floor(getSampleHeight()/2);
        topOfSample = thisY - halfOfSample;
        if (topOfSample<0) topOfSample = 0;
        bottomOfSample = thisY + halfOfSample;
        if (bottomOfSample>=img.height) bottomOfSample = img.height-1;
      } else {
        topOfSample = thisY;
        bottomOfSample = thisY;
      }
      
      
      int[][] points = {};
    
      for (int i=0; i <= numberSegments; i++){ 
        int thisX = i*getCellWidth();
        int leftOfSample;
        int rightOfSample;
        // get sample range for X axis, only currently used for average calc (not COM).
        if (getSampleWidth()>1){
          int halfOfSample = floor(getSampleWidth()/2);
          leftOfSample = thisX - halfOfSample;
          if (leftOfSample<0) leftOfSample = 0;
          rightOfSample = thisX + halfOfSample;
          if (rightOfSample>=img.width) rightOfSample = img.width-1;
        } else {
          leftOfSample = thisX;
          rightOfSample = thisX;
        }
        
        float[] samples = new float[0];
        
        float weightedMass=0;
        float totalMass=0;
        int thisAdjY=0;
        if (this.getCOM()==1){
          // calculate the center of mass
          for (int s=topOfSample; s<=bottomOfSample; s++){
            int loc = (thisX + s*img.width);
            // brightness is 0-255 where 255 is white, we want black to have the most mass so we invert that scale.
            float thisMass = 255-brightness(img.pixels[loc]);
            samples = (float[]) append (samples, thisMass);
            
            totalMass += thisMass;
            weightedMass += thisMass*(s-topOfSample);
          }
          thisAdjY = round(weightedMass/totalMass)+topOfSample;
        } else {
          // calculate the average brightness
          for (int sX=leftOfSample; sX<=rightOfSample; sX++){
            for (int sY=topOfSample; sY<=bottomOfSample; sY++){
              int loc = (sX + sY*img.width);
              // brightness is 0-255 where 255 is white, we want black to have the most mass so we invert that scale.
              totalMass += brightness(img.pixels[loc]);
            }
          }
          float averageMass = totalMass/(getSampleHeight()*getSampleWidth());
          thisAdjY = canvasVertOffset+(line*getVertOffset())-(int)(this.getVertScale()*averageMass/255);
        }
        
        // repeat the first and last points to add controls for them
        if (i==0) points = (int[][])append(points, new int[] {thisX*getScaleFactor(), thisAdjY*getScaleFactor()});
        if (i==numberSegments-1) points = (int[][])append(points, new int[] {thisX*getScaleFactor(), thisAdjY*getScaleFactor()});
        points = (int[][])append(points, new int[] {thisX*getScaleFactor(), thisAdjY*getScaleFactor()});
      }
      lines = (int[][][])append(lines, points);
    }
    
    
    // TODO: return a more accurate canvas size (and add canvas offsets so that things fit). will probably need to give some buffy in the Y directions due to curves?
    
    int[] wh = new int[2];
    wh[0] = img.width*getScaleFactor();
    wh[1] = (int)2.5*img.height*getScaleFactor();
    canvasVertOffset = img.height*getScaleFactor();
    return wh;
  }
      
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    displayCanvas.stroke(100, 255); 
    displayCanvas.curveTightness(getCurveTightness());
    displayCanvas.noFill();
    
    
    for (int line = 0; line<lines.length; line++){
      // lines contain points
      displayCanvas.beginShape();
      for (int point = 0; point<lines[line].length-1; point++){
        // poits contain coordinates
        println(lines[line][point][0]+" "+ lines[line][point][1]);
        displayCanvas.curveVertex(lines[line][point][0], lines[line][point][1]);
      }
      displayCanvas.endShape();
    }
    displayCanvas.endDraw();
    return DRAWING_DONE;
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){ 
    String rowTemp;
    
    for (int line = 0; line<lines.length; line++){
      //build segments using curvePoint
      float[] xSegs={};
      float[] ySegs={};
  
      for (int point = 0; point<lines[line].length-1; point++){
        int x1, x2, x3, x4;
        int y1, y2, y3, y4;
        
        if (point==0) {
          x1 = lines[line][point][0];
          y1 = lines[line][point][1];
        } else {
          x1 = lines[line][point-1][0];
          y1 = lines[line][point-1][1];
        }
        
        x2 = lines[line][point][0];
        y2 = lines[line][point][1];
        
        if (point==lines[line].length-2){
          x3=lines[line][point+1][0]; 
          x4=lines[line][point+1][0]; 
          y3=lines[line][point+1][1]; 
          y4=lines[line][point+1][1]; 
        } else if (point==lines[line].length-1) {
          x3=lines[line][point][0]; 
          x4=lines[line][point][0]; 
          y3=lines[line][point][1]; 
          y4=lines[line][point][1]; 
        } else {
          x3=lines[line][point+1][0]; 
          x4=lines[line][point+2][0]; 
          y3=lines[line][point+1][1]; 
          y4=lines[line][point+2][1]; 
        }
        int segments = 13;
        for (int s=0; s<segments; s++){
          float xVal = curvePoint(x1, x2, x3, x4, s/(float) segments);
          float yVal = curvePoint(y1, y2, y3, y4, s/(float) segments);
          xSegs = append(xSegs, xVal);
          ySegs = append(ySegs, yVal);
        }
       
      }
      
      if (lines[line].length>1) {
        xSegs = append(xSegs, lines[line][lines[line].length-1][0]);
        ySegs = append(ySegs, lines[line][lines[line].length-1][1]);
      }
      
      // draw the lines
      rowTemp = "<path style=\"fill:none;stroke:black;stroke-width:1px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M ";
      FileOutput = append(FileOutput, rowTemp);
      for (int i=0; i<xSegs.length; i++){
        rowTemp = xSegs[i] + " " + ySegs[i] + "\r";
        FileOutput = append(FileOutput, rowTemp);
      }
      FileOutput = append(FileOutput, "\" />"); // End path description
    }
    
    return FileOutput;
  }
}
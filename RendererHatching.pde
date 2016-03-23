import controlP5.*;

class RendererHatching extends Renderer{  
  Group settingsGroup;
  int startIndex;
  int linesPerDraw;
  int sampleIndex;
  int numberLines;
  int numberPoints;
  int[] values;
  float[][][] lines = {};
  
  RendererHatching(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
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
     .setRange(1,40)
     .setGroup(settingsGroup)
     .setValue(20)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
   cp5.addSlider("cellHeight")
     .setLabel("cell height")
     .setPosition(5, cp5.get("cellWidth").getHeight() + cp5.get("cellWidth").getPosition()[1] + controlsVOffset)
     .setRange(1,40)
     .setGroup(settingsGroup)
     .setValue(20)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
   
     
   cp5.addSlider("sampleSize")
     .setLabel("sample size")
     .setPosition(cp5.get("cellHeight").getWidth() + cp5.get("cellHeight").getPosition()[0] + 100, controlsVOffset)
     .setRange(1,40)
     .setGroup(settingsGroup)
     .setValue(20)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
   cp5.addSlider("contrast")
     .setLabel("contrast")
     .setPosition(cp5.get("cellHeight").getWidth() + cp5.get("cellHeight").getPosition()[0] + 100, cp5.get("cellWidth").getHeight() + cp5.get("cellWidth").getPosition()[1] + controlsVOffset)
     .setRange(1,5)
     .setGroup(settingsGroup)
     .setValue(3)
     ;
     
   cp5.addSlider("density")
     .setLabel("density")
     .setPosition(cp5.get("cellHeight").getWidth() + cp5.get("cellHeight").getPosition()[0] + 100, cp5.get("cellHeight").getHeight() + cp5.get("cellHeight").getPosition()[1] + controlsVOffset)
     .setRange(1,100)
     .setGroup(settingsGroup)
     .setValue(25)
     ;
     
   cp5.addSlider("factor")
     .setPosition(5, cp5.get("cellHeight").getHeight() + cp5.get("cellHeight").getPosition()[1] + controlsVOffset)
     .setRange(0,20)
     .setLabel("scale factor")
     .setGroup(settingsGroup)
     .setValue(1)
     .setNumberOfTickMarks(21)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("drawLineAlpha")
     .setLabel("line alpha")
     .setPosition(5, cp5.get("factor").getHeight() + cp5.get("factor").getPosition()[1] + controlsVOffset)
     .setRange(0,100)
     .setGroup(settingsGroup)
     .setValue(100)
     .setNumberOfTickMarks(101)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  
  
   cp5.addToggle("scribbles")
     .setPosition(cp5.get("drawLineAlpha").getWidth() + cp5.get("drawLineAlpha").getPosition()[0] + 100, cp5.get("factor").getHeight() + cp5.get("factor").getPosition()[1] + controlsVOffset)
     .setSize(50,10)
     .setValue(true)
     .setGroup(settingsGroup)
     ;
     
  cp5.addSlider("hatchRadians")
     .setLabel("Hatch Radian")
     .setPosition(5, cp5.get("drawLineAlpha").getHeight() + cp5.get("drawLineAlpha").getPosition()[1] + controlsVOffset)
     .setRange(0, 2*PI)
     .setGroup(settingsGroup)
     .setValue(.4)
     ;
  
  cp5.addSlider("hatchLength")
     .setLabel("Hatch Length")
     .setPosition(5, cp5.get("hatchRadians").getHeight() + cp5.get("hatchRadians").getPosition()[1] + controlsVOffset)
     .setRange(0,40)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(41)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
   cp5.addSlider("hatchRadiansVariation")
     .setLabel("Variation")
     .setPosition(cp5.get("hatchRadians").getWidth() + cp5.get("hatchRadians").getPosition()[0] + 100, cp5.get("hatchRadians").getPosition()[1])
     .setRange(0, 2*PI)
     .setGroup(settingsGroup)
     .setValue(.1)
     ;
     
   cp5.addSlider("hatchLengthVariation")
     .setLabel("Variation")
     .setPosition(cp5.get("hatchLength").getWidth() + cp5.get("hatchLength").getPosition()[0] + 100, cp5.get("hatchLength").getPosition()[1])
     .setRange(0, 1)
     .setGroup(settingsGroup)
     .setValue(.4)
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
  
  private int getSampleSize(){
    return (int) cp5.getController("sampleSize").getValue();
  }
  
  private int getContrast(){
    return (int) cp5.getController("contrast").getValue();
  }
  
  private int getDensity(){
    return (int) cp5.getController("density").getValue();
  }
  
  private int getFactor(){
    return (int) cp5.getController("factor").getValue();
  }
 
  private int getAlpha(){
    return (int) cp5.getController("drawLineAlpha").getValue();
  }
  
  private float getHatchRadians(){
    return cp5.getController("hatchRadians").getValue();
  }
  
  private int getHatchLength(){
    return (int) cp5.getController("hatchLength").getValue();
  }
  
  private float getHatchRadiansVariation(){
    return (float) cp5.getController("hatchRadiansVariation").getValue();
  }
  
  private float getHatchLengthVariation(){
    return (float) cp5.getController("hatchLengthVariation").getValue();
  }
  
  private int getScribbles(){
    return (int) cp5.getController("scribbles").getValue();
  }
  
  public int[] processImage(PImage img){ 
    lines = new float[0][0][0];
    sampleIndex=0;
    numberLines = floor(img.height / getCellHeight());
    numberPoints = floor(img.width / getCellWidth());
    
    
    values = new int[0];
    // determine brightness values for the cells
    for (int line=0; line<= numberLines; line++){
      
      int yVal = (line * getCellHeight())+getCellHeight()/2;
      for (int i = 0; i<numberPoints; i++){
        int xVal = (i*getCellWidth())+(getCellWidth()/2);
          
        int sampleMinX = max(0, xVal-(getSampleSize()/2));
        int sampleMaxX = min(img.width, xVal+(getSampleSize()/2));
        int sampleMinY = max(0, yVal-(getSampleSize()/2));
        int sampleMaxY = min(img.height, yVal+(getSampleSize()/2));
        
        int sampledValue=0;
        int sampledNumber=0;
        for (int y = sampleMinY; y < sampleMaxY; y++){
          for (int x = sampleMinX; x < sampleMaxX; x++){
            sampledValue+=(brightness(img.pixels[y*img.width+x]));
            sampledNumber++;
          }
        }
        int brightness = 255;
        if (sampledNumber!=0){
          brightness = sampledValue/sampledNumber;
        }
        values=append(values, brightness);
      } 
      print("-");
    }
    println();
    
    // determine lines
    for (int line=0; line<= numberLines; line++){
      int yVal = getFactor()*(line * getCellHeight())+getCellHeight()/2;
      for (int i = 0; i<numberPoints; i++){
        int xVal = getFactor()*(i*getCellWidth())+(getCellWidth()/2);
        int darkness = (int)((pow(255-values[sampleIndex],getContrast())/pow(255,getContrast()-1))/(max((255-values[sampleIndex])/getDensity(),1)));
        
        float[][] coords = {};
        if(darkness>0){
          for (int hatch=0; hatch<darkness; hatch++){
            
            // adding randomness is also nice 
            float ranRadians = random(0,getHatchRadiansVariation());
            float ranLength = random(0,getHatchLength()*getHatchLengthVariation());
            float x1 = xVal+random(getFactor()*-getCellWidth()/2,getFactor()*getCellWidth()/2);
            float y1 = yVal+random(getFactor()*-getCellHeight()/2,getFactor()*getCellHeight()/2);
            float x2 = x1+cos(-getHatchRadians() + ranRadians) * (getHatchLength() - ranLength);
            float y2 = y1+sin(-getHatchRadians() + ranRadians) * (getHatchLength() - ranLength);
            
            coords = (float[][])append(coords, new float[] {x1, y1});
            coords = (float[][])append(coords, new float[] {x2, y2});
          }
          lines = (float[][][])append(lines, coords);
        }
        sampleIndex++;
      } 
      print(".");
    }
    println();
    
    // adjust canvas size to fit all values
    float minX = 0, minY = 0, maxX = 0, maxY = 0;
    
    // find the minimum and maximum
    for (int i = 0; i<lines.length; i++){
      for (int s = 0; s<lines[i].length; s++){
        if (lines[i][s][0] < minX) minX = lines[i][s][0];
        if (lines[i][s][0] > maxX) maxX = lines[i][s][0];
        
        if (lines[i][s][1] < minY) minY = lines[i][s][1];
        if (lines[i][s][1] > maxY) maxY = lines[i][s][1];
      }
    } 
    // if mins are less than 0 offset all values
    if (minX<0){
      for (int i = 0; i<lines.length; i++){
        for (int s = 0; s<lines[i].length; s++){
          lines[i][s][0] -= minX;
        }
      }
      maxX -= minX;
    }
    if (minY<0){
      for (int i = 0; i<lines.length; i++){
        for (int s = 0; s<lines[i].length; s++){
          lines[i][s][1] -= minY;
        }
      }
      maxY -= minY;
    }
    
    startIndex=0;
    linesPerDraw=lines.length/numberLines;
    
    int[] wh = new int[2];
    wh[0] = ceil(maxX);
    wh[1] = ceil(maxY);
    return wh;
  }
 
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    displayCanvas.stroke(0, getAlpha());
    displayCanvas.noFill();
    
    int endIndex = startIndex+linesPerDraw;
    if (endIndex>lines.length) endIndex=lines.length; 
    
    if (getScribbles()==1){
      for (int i = startIndex; i<endIndex; i++){
        displayCanvas.beginShape();
        for (int s = 0; s<lines[i].length; s++){
          displayCanvas.vertex(lines[i][s][0], lines[i][s][1]);
        }
        displayCanvas.endShape();
      }
    } else {
      for (int i = startIndex; i<endIndex; i++){
        for (int s = 0; s<lines[i].length-1; s+=2){
          displayCanvas.line(lines[i][s][0], lines[i][s][1], lines[i][s+1][0], lines[i][s+1][1]);
        }
      }
    }
    
    startIndex = endIndex;
    displayCanvas.endDraw();
    if (startIndex >= lines.length){
      return DRAWING_DONE;
    } else {
      return DRAWING;
    }
  }

  public String[] getSVGData(String[] FileOutput, PImage image){ 
    String rowTemp;
    if (getScribbles()==1){
      for (int i = 0; i<lines.length; i++){
        rowTemp = "<path style=\"fill:none;stroke:black;stroke-opacity:"+getAlpha()/100.0+";stroke-width:1px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M ";
        FileOutput = append(FileOutput, rowTemp);
        for (int s = 0; s<lines[i].length; s++){
          rowTemp = lines[i][s][0] + " " + lines[i][s][1] + "\r";
          FileOutput = append(FileOutput, rowTemp);
        }  
        FileOutput = append(FileOutput, "\" />"); // End path description
      }
    } else {
      for (int i = 0; i<lines.length; i++){
        for (int s = 0; s<lines[i].length-1; s+=2){
          rowTemp = "<line stroke=\"black\" stroke-width=\"1\" x1=\"" + lines[i][s][0] + "\" y1=\"" + lines[i][s][1] + "\" x2=\"" + lines[i][s+1][0] + "\" y2=\"" + lines[i][s+1][1] + "\" stroke-opacity=\""+getAlpha()/100.0+"\"/>";
          FileOutput = append(FileOutput, rowTemp);
        }
      }
       }
    return FileOutput;
  }
}
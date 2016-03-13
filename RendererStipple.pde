import controlP5.*;

class RendererStipple extends Renderer{  
  Group settingsGroup;
  int startIndex;
  int ellipsesPerDraw;
  int sampleIndex;
  int numberLines;
  int numberPoints;
  int[] values;
  float[][] ellipses = {};
  
  RendererStipple(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
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
     
   cp5.addSlider("drawPointAlpha")
     .setLabel("point alpha")
     .setPosition(5, cp5.get("factor").getHeight() + cp5.get("factor").getPosition()[1] + controlsVOffset)
     .setRange(0,100)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(101)
     .showTickMarks(false)
     .snapToTickMarks(true)
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
  
  private int getMinRadius(){
    return (int) cp5.getController("minRadius").getValue();
  }
  
  private int getMaxRadius(){
    return (int) cp5.getController("maxRadius").getValue();
  }
  
  private int getFactor(){
    return (int) cp5.getController("factor").getValue();
  }
 
  private int getAlpha(){
    return (int) cp5.getController("drawPointAlpha").getValue();
  }
  
  private float getHatchRadians(){
    return cp5.getController("hatchRadians").getValue();
  }
  
  private int getHatchLength(){
    return (int) cp5.getController("hatchLength").getValue();
  }
  
  public int[] processImage(PImage img){ 
    println("processing image begun");
    ellipses = new float[0][0];
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
        int brightness = sampledValue/sampledNumber;
        values=append(values, brightness);
      } 
      print("-");
    }
    println();
    // calculate circles to match cells
    for (int line=0; line < numberLines; line++){
      int yVal = getFactor()*(line * getCellHeight())+getCellHeight()/2;
      for (int i = 0; i<numberPoints; i++){
        int xVal = getFactor()*(i*getCellWidth())+(getCellWidth()/2);
        int darkness = (255-values[sampleIndex])/2;
        for (int point=0; point<darkness; point++){
          float[] coords = {xVal+random(getFactor()*-getCellWidth()/2, getFactor()*getCellWidth()/2), yVal+random(getFactor()*-getCellHeight()/2, getFactor()*getCellHeight()/2), 1, 1};
          ellipses = (float[][])append(ellipses, coords);
        }
        sampleIndex++;
      } 
      print(".");
    }
    println();
    
    println("processing image complete");
    startIndex=0;
    ellipsesPerDraw=ellipses.length/numberLines;
    
    int[] wh = new int[2];
    wh[0] = img.width*getFactor();
    wh[1] = img.height*getFactor();
    return wh;
  }
  
    
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    displayCanvas.stroke(0, getAlpha());
    
    int endIndex = startIndex+ellipsesPerDraw;
    if (endIndex>ellipses.length) endIndex=ellipses.length; 
    
    for (int i = startIndex; i<endIndex; i++){
      displayCanvas.ellipse(ellipses[i][0], ellipses[i][1], ellipses[i][2], ellipses[i][3]);
    }
    startIndex = endIndex;
    displayCanvas.endDraw();
    
    if (startIndex >= ellipses.length){
      return DRAWING_DONE;
    } else {
      return DRAWING;
    }
  }

  public String[] getSVGData(String[] FileOutput, PImage image){ 
    
    // TODO: finish this
    
    String rowTemp;
    
    for (int i = 0; i<ellipses.length; i++){
      rowTemp = "<circle cx=\"" + ellipses[i][0] + "\" cy=\"" + ellipses[i][1] + "\" r=\"" + ellipses[i][2]/2.0 + "\" fill-opacity=\""+getAlpha()/100.0+"\"/>";
      FileOutput = append(FileOutput, rowTemp);
          
    }
   
    return FileOutput;
  }
}
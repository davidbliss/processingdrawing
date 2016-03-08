import controlP5.*;

class RendererStipple extends Renderer{  
  Group settingsGroup;
  int lineToDraw;
  int sampleIndex;
  int numberLines;
  int numberPoints;
  int[] values;
  
  RendererStipple(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
    println("creating RendererNearPoints");
   
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
    return (int) cp5.getController("drawLineAlpha").getValue();
  }
  
  private float getHatchRadians(){
    return cp5.getController("hatchRadians").getValue();
  }
  
  private int getHatchLength(){
    return (int) cp5.getController("hatchLength").getValue();
  }
  
  public int[] processImage(PImage img){ 
    lineToDraw=0;
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
    }
    
    int[] wh = new int[2];
    wh[0] = img.width*getFactor();
    wh[1] = img.height*getFactor();
    return wh;
  }
  
    
  public int draw(PGraphics displayCanvas, PImage image){
    
    
    // TODO: should move point setting to process image to save for SVG and to better set size of canvas.
    // TODO: should add alpha back in
   
    displayCanvas.beginDraw();
    int yVal = getFactor()*(lineToDraw * getCellHeight())+getCellHeight()/2;
    for (int i = 0; i<numberPoints; i++){
      int xVal = getFactor()*(i*getCellWidth())+(getCellWidth()/2);
      int darkness = (255-values[sampleIndex])/2;
      println(values[sampleIndex]+"->"+darkness);
      for (int hatch=0; hatch<darkness; hatch++){
        displayCanvas.ellipse(xVal+random(getFactor()*-getCellWidth()/2,getFactor()*getCellWidth()/2), yVal+random(getFactor()*-getCellHeight()/2,getFactor()*getCellHeight()/2), 1, 1);
      }
      sampleIndex++;
    } 
    displayCanvas.endDraw();
    lineToDraw++;
    if (lineToDraw >= numberLines){
      return DRAWING_DONE;
    } else {
      return DRAWING;
    }
  }

  public String[] getSVGData(String[] FileOutput, PImage image){ 
    
    // TODO: finish this
    return FileOutput;
  }
}
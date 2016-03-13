// draws horizontal line, offsetting y bassed on the center of mass for a vertical sample of pixels at a given x (darker pixel value = greater massmass) 
import controlP5.*;

class RendererHalftone extends Renderer{
  Group settingsGroup;
  
  int lineToDraw;
  int numberLines;
  int numberPoints;
  int[] values;
  
  RendererHalftone(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
    println("creating RendererHalftone");
   
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
     .setValue(15)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
   
   cp5.addSlider("rowOffset")
     .setLabel("row offset")
     .setPosition(cp5.get("cellHeight").getWidth() + cp5.get("cellHeight").getPosition()[0] + 100, controlsVOffset)
     .setRange(0,20)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(21)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("sampleSize")
     .setLabel("sample size")
     .setPosition(cp5.get("rowOffset").getPosition()[0], cp5.get("rowOffset").getHeight() + cp5.get("rowOffset").getPosition()[1] + controlsVOffset)
     .setRange(1,40)
     .setGroup(settingsGroup)
     .setValue(20)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
   cp5.addSlider("minRadius")
     .setLabel("min radius")
     .setPosition(cp5.get("cellHeight").getPosition()[0], cp5.get("cellHeight").getHeight() + cp5.get("cellHeight").getPosition()[1] + controlsVOffset)
     .setRange(1,40)
     .setGroup(settingsGroup)
     .setValue(2)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  
  cp5.addSlider("maxRadius")
     .setLabel("max radius")
     .setPosition(cp5.get("minRadius").getPosition()[0], cp5.get("minRadius").getHeight() + cp5.get("minRadius").getPosition()[1] + controlsVOffset)
     .setRange(1,40)
     .setGroup(settingsGroup)
     .setValue(10)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
  cp5.addToggle("fill")
     .setPosition(cp5.get("maxRadius").getPosition()[0], cp5.get("maxRadius").getHeight() + cp5.get("maxRadius").getPosition()[1] + controlsVOffset)
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
 
  private int getRowOffset(){
    return (int) cp5.getController("rowOffset").getValue();
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
  
  private int getFill(){
    return (int) cp5.getController("fill").getValue();
  }
  
  public int[] processImage(PImage img){ 
    lineToDraw=0;
    numberLines = floor(img.height / getCellHeight());
    numberPoints = floor(img.width / getCellWidth());
    
    values = new int[0];
    
    int[] wh = new int[2];
    wh[0] = img.width;
    wh[1] = img.height;
    return wh;
  }
      
  public int draw(PGraphics displayCanvas, PImage image){
    int offset=0;
    if(lineToDraw % 2==1){
      offset=getRowOffset();
    } 
    // TODO: better to do processing in processImage and return a more accurate canvas size (and add canvas offsets so that things fit).
    
    int yVal = (lineToDraw * getCellHeight())+getCellHeight()/2;
    displayCanvas.beginDraw();
    if (getFill()==1){
      displayCanvas.fill(0,0,0);
      displayCanvas.noStroke();
    } else {
      displayCanvas.stroke(0,0,0);
      displayCanvas.noFill();
    }
    for (int i = 0; i<numberPoints; i++){
      if (offset>0 && i==numberPoints-1){
        // don't do anything
      } else {
        int xVal = (i*getCellWidth())+(getCellWidth()/2)+offset;
        
        int sampleMinX = max(0, xVal-(getSampleSize()/2));
        int sampleMaxX = min(image.width, xVal+(getSampleSize()/2));
        int sampleMinY = max(0, yVal-(getSampleSize()/2));
        int sampleMaxY = min(image.height, yVal+(getSampleSize()/2));
        
        int sampledValue=0;
        int sampledNumber=0;
        for (int y = sampleMinY; y < sampleMaxY; y++){
          for (int x = sampleMinX; x < sampleMaxX; x++){
            sampledValue+=(255 - brightness(image.pixels[y*image.width+x]));
            sampledNumber++;
          }
        }
        float size = (sampledValue/sampledNumber)/255.0;
        // scale based on desired radius range
        int radius = getMinRadius() + (int)(size*(getMaxRadius()-getMinRadius())); 

        //save for SVG
        values=append(values, radius);
        
        displayCanvas.ellipse(xVal, yVal, radius*2, radius*2);
      }
    }    
    displayCanvas.endDraw();
    lineToDraw++;
    cp5.get("progress").setValue((int)((float)lineToDraw/numberLines*100));
    if (lineToDraw > numberLines){
      return DRAWING_DONE;
    } else {
      return DRAWING;
    }
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){ 
    // TODO: SVG needs to take fill into account
    
    
    String rowTemp;
    int sampleIndex=0;
    for (int line=0; line<= numberLines; line++){
      int offset=0;
      if(line % 2==1){
        offset=getRowOffset();
      } 
      
      int yVal = (line * getCellHeight())+getCellHeight()/2;
      for (int i = 0; i<numberPoints; i++){
        if (offset>0 && i==numberPoints-1){
          // don't do anything
        } else {
          int xVal = (i*getCellWidth())+(getCellWidth()/2)+offset;
          int radius = values[sampleIndex];
          
          rowTemp = "<circle cx=\"" + xVal + "\" cy=\"" + yVal + "\" r=\"" + radius + "\"/>";
          FileOutput = append(FileOutput, rowTemp);
          sampleIndex++;
        }
      }    
    }
    return FileOutput;
  }
}
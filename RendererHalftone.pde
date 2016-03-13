// draws horizontal line, offsetting y bassed on the center of mass for a vertical sample of pixels at a given x (darker pixel value = greater massmass) 
import controlP5.*;

class RendererHalftone extends Renderer{
  Group settingsGroup;
  
  int lineToDraw;
  int numberLines;
  int numberPoints;
  int[][] values;
  
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
     .setRange(0,40)
     .setGroup(settingsGroup)
     .setValue(2)
     .setNumberOfTickMarks(41)
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
    
    values = new int[0][0];
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
          
          int sampleMinX = max(0, xVal-(getSampleSize()/2));
          int sampleMaxX = min(img.width, xVal+(getSampleSize()/2));
          int sampleMinY = max(0, yVal-(getSampleSize()/2));
          int sampleMaxY = min(img.height, yVal+(getSampleSize()/2));
          
          int sampledValue=0;
          int sampledNumber=0;
          for (int y = sampleMinY; y < sampleMaxY; y++){
            for (int x = sampleMinX; x < sampleMaxX; x++){
              sampledValue+=(255 - brightness(img.pixels[y*img.width+x]));
              sampledNumber++;
            }
          }
          float size = (sampledValue/sampledNumber)/255.0;
          // scale based on desired radius range
          int radius = getMinRadius() + (int)(size*(getMaxRadius()-getMinRadius())); 
  
          //save for SVG
          int[] coords = new int[] {xVal, yVal,radius};
          values = (int[][]) append(values, coords);
        }
      }    
    }
    
    // find the minimum and maximum
    int minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (int i = 0; i<values.length; i++){
      if (values[i][0]-values[i][2] < minX) minX = values[i][0]-values[i][2];
      if (values[i][0]+values[i][2] > maxX) maxX = values[i][0]+values[i][2];
      
      if (values[i][1]-values[i][2] < minY) minY = values[i][1]-values[i][2];
      if (values[i][1]+values[i][2] > maxY) maxY = values[i][1]+values[i][2];
    } 
    // if mins are less than 0 offset all values
    for (int i = 0; i<values.length; i++){
      values[i][0] -= minX;
    }
    maxX -= minX;
    
    for (int i = 0; i<values.length; i++){
      values[i][1] -= minY;
    }
    maxY -= minY;
    
    int[] wh = new int[2];
    wh[0] = maxX;
    wh[1] = maxY;
    return wh;
  }
      
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    if (getFill()==1){
      displayCanvas.fill(0,0,0);
      displayCanvas.noStroke();
    } else {
      displayCanvas.stroke(0,0,0);
      displayCanvas.noFill();
    }
    
    for (int i=0; i<values.length; i++){
      displayCanvas.ellipse(values[i][0], values[i][1], values[i][2]*2, values[i][2]*2);
    }
    displayCanvas.endDraw();
      
    return DRAWING;
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){ 
    String rowTemp; 
    for (int i = 0; i<values.length; i++){  
      rowTemp = "<circle";
      if (getFill()==0) rowTemp += " fill=\"none\" stroke=\"black\" stroke-width=\"1\"";
      rowTemp += " cx=\"" + values[i][0] + "\" cy=\"" + values[i][1] + "\" r=\"" + values[i][2] + "\"/>";
      FileOutput = append(FileOutput, rowTemp);
    }
    return FileOutput;
  }
}
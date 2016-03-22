// draws horizontal line, offsetting y bassed on the center of mass for a vertical sample of pixels at a given x (darker pixel value = greater massmass) 
import controlP5.*;

// TODO: NEED TO THINK THROUGH HOW THIS ONE WILL WORK

class RendererConnectDarkest extends Renderer{
  Group settingsGroup;
  int numberRows;
  int numberCells;
  
  int[][][] values = new int[256][0][2];
  
  RendererConnectDarkest(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
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
     .setValue(20)
     .setNumberOfTickMarks(40)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  
    cp5.addSlider("scaleFactor")
     .setLabel("scaleFactor")
     .setPosition(5, cp5.get("cellHeight").getHeight() + cp5.get("cellHeight").getPosition()[1] + controlsVOffset)
     .setRange(1,20)
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
  
  private int getScaleFactor(){
    return (int) cp5.getController("scaleFactor").getValue();
  }
  
  public int[] processImage(PImage img){ 
    values = new int[256][0][2];
    numberRows = floor(img.height / getCellHeight());
    numberCells = floor(img.width / getCellWidth());
    
    for (int x=getCellWidth()/2; x<numberCells*getCellWidth(); x+=getCellWidth()){
      for (int y=getCellHeight()/2; y<numberRows*getCellHeight(); y+=getCellHeight()){
        int brightness=0;
        int sampleSize=0;
        for (int samplex = x - getCellWidth()/2; samplex < x + getCellWidth()/2; samplex++){
          for (int sampley = y - getCellHeight()/2; sampley < y + getCellHeight()/2; sampley++){
            brightness+=brightness(img.pixels[sampley*img.width+samplex]);
            sampleSize++;
          }
        }
        brightness = brightness/sampleSize;
        values[brightness]=(int[][])append(values[brightness], new int[] {x,y});
      }
    }
    
    int[] wh = new int[2];
    wh[0] = img.width*getScaleFactor();
    wh[1] = img.height*getScaleFactor();
    return wh;
  }
      
  public int draw(PGraphics displayCanvas, PImage image){
    
    displayCanvas.beginDraw();
    displayCanvas.stroke(100, 255); 
    displayCanvas.curveTightness(0);
    displayCanvas.noFill();
    
    
    displayCanvas.beginShape();
    // TODO: parameterize the min and max brightness values 
    for (int b = 0; b<255; b++){
      // TODO: parameterixe if stroke alpha should be based on the brightness of the pixels
      displayCanvas.stroke(100, 255); 
      // just connect them in the order they appear
      //for (int point = 0; point<values[b].length; point++){
      //  displayCanvas.curveVertex(values[b][point][0], values[b][point][1]);
      //}
      
      if (values[b].length>0){
        // first pick a random 1
        int first = int(random(values[b].length));
        int[] latest = values[b][first];
        println(values[b][first][0]+","+values[b][first][1]);
        displayCanvas.curveVertex(values[b][first][0], values[b][first][1]);
        // remove it
        for(int i=first ; i<values[b].length-1 ; i++){
         values[b][i] = values[b][i+1];
        }
        values[b] = (int[][])shorten(values[b]);
        
        while (values[b].length>0){
          int closestindex=0;
          float closestdistance=10000;
          for(int v=0;v<values[b].length;v++){
            float distance = sqrt(pow(latest[0]-values[b][v][0], 2)+pow(latest[1]-values[b][v][1], 2));
            if (distance<closestdistance){
              closestdistance = distance;
              closestindex = v;
            }
          }
          
          latest = values[b][closestindex];
          println(values[b][closestindex][0]+","+values[b][closestindex][1]);
          // TODO: do this work in process image and build a list of vectors.
          // TODO: try using bezier instead of simple curve
          displayCanvas.curveVertex(values[b][closestindex][0], values[b][closestindex][1]);
          // remove it
          for(int i=closestindex ; i<values[b].length-1 ; i++){
           values[b][i] = values[b][i+1];
          }
          values[b] = (int[][])shorten(values[b]);
          
        }
      }
    }
    displayCanvas.endShape();
    displayCanvas.endDraw();
    return DRAWING_DONE;
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){ 
   
    return FileOutput;
  }
}
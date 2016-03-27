import controlP5.*;

class RendererConnectDarkest extends Renderer{
  Group settingsGroup;
  int numberRows;
  int numberCells;
  
  int[][][] values = new int[256][0][2];
  int[][] vertexes = new int[0][2];
  float[][] lineCoords = new float[0][2];
  float minDistance = 1000;
  float maxDistance = 0;
  
  RendererConnectDarkest(ControlP5 cp5, int settingsGroupX, int settingsGroupY){
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
     
    cp5.addSlider("minBrightness")
     .setLabel("minimum brightness drawn")
     .setPosition(cp5.get("cellWidth").getWidth() + cp5.get("cellWidth").getPosition()[0] +100, controlsVOffset)
     .setRange(0,255)
     .setGroup(settingsGroup)
     .setValue(0)
     .setNumberOfTickMarks(256)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
    cp5.addSlider("maxBrightness")
     .setLabel("maximum brightness drawn")
     .setPosition(cp5.get("minBrightness").getPosition()[0],  cp5.get("cellWidth").getHeight() + cp5.get("cellWidth").getPosition()[1] + controlsVOffset)
     .setRange(0,255)
     .setGroup(settingsGroup)
     .setValue(255)
     .setNumberOfTickMarks(256)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
  
    cp5.addSlider("scaleFactor")
     .setLabel("scaleFactor")
     .setPosition(5, cp5.get("cellHeight").getHeight() + cp5.get("cellHeight").getPosition()[1] + controlsVOffset)
     .setRange(1,20)
     .setGroup(settingsGroup)
     .setValue(1)
     .setNumberOfTickMarks(20)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
    cp5.addSlider("maxLength")
     .setLabel("maximum length drawn")
     .setPosition(cp5.get("maxBrightness").getPosition()[0],  cp5.get("maxBrightness").getHeight() + cp5.get("maxBrightness").getPosition()[1] + controlsVOffset)
     .setRange(0,300)
     .setGroup(settingsGroup)
     .setValue(300)
     .setNumberOfTickMarks(256)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
    cp5.addSlider("minStrokeDarkness")
     .setLabel("min stroke darkness")
     .setPosition(5, cp5.get("scaleFactor").getHeight() + cp5.get("scaleFactor").getPosition()[1] + controlsVOffset)
     .setRange(1,255)
     .setGroup(settingsGroup)
     .setValue(155)
     .setNumberOfTickMarks(255)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
     
    cp5.addSlider("maxStrokeDarkness")
     .setLabel("max stroke darkness")
     .setPosition(cp5.get("minStrokeDarkness").getWidth() + cp5.get("minStrokeDarkness").getPosition()[0] + 100, cp5.get("minStrokeDarkness").getPosition()[1])
     .setRange(1,255)
     .setGroup(settingsGroup)
     .setValue(255)
     .setNumberOfTickMarks(255)
     .showTickMarks(false)
     .snapToTickMarks(true)
     ;
    
    cp5.addSlider("minStrokeWeight")
     .setLabel("min stroke weight")
     .setPosition(5, cp5.get("minStrokeDarkness").getHeight() + cp5.get("minStrokeDarkness").getPosition()[1] + controlsVOffset)
     .setRange(0,5)
     .setGroup(settingsGroup)
     .setValue(0.5)
     ;
     
    cp5.addSlider("maxStrokeWeight")
     .setLabel("max stroke weight")
     .setPosition(cp5.get("minStrokeWeight").getWidth() + cp5.get("minStrokeWeight").getPosition()[0] + 100, cp5.get("minStrokeWeight").getPosition()[1])
     .setRange(0,5)
     .setGroup(settingsGroup)
     .setValue(1.5)
     ;
    
    cp5.addSlider("curveTightness")
     .setLabel("curve tightness")
     .setPosition(5, cp5.get("minStrokeWeight").getHeight() + cp5.get("minStrokeWeight").getPosition()[1]+ controlsVOffset)
     .setRange(-5,5)
     .setGroup(settingsGroup)
     .setValue(0.0)
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
  
  private int getMinStrokeDarkness(){
    return (int) cp5.getController("minStrokeDarkness").getValue();
  }
  
  private int getMaxStrokeDarkness(){
    return (int) cp5.getController("maxStrokeDarkness").getValue();
  }
  
  private float getMinStrokeWeight(){
    return (float) cp5.getController("minStrokeWeight").getValue();
  }
  
  private float getMaxStrokeWeight(){
    return (float) cp5.getController("maxStrokeWeight").getValue();
  }
  
  private int getMaxBrightness(){
    return (int) cp5.getController("maxBrightness").getValue();
  }
  
  private int getMinBrightness(){
    return (int) cp5.getController("minBrightness").getValue();
  }
  
  private int getMaxLength(){
    return (int) cp5.getController("maxLength").getValue();
  }
  
  private int getScaleFactor(){
    return (int) cp5.getController("scaleFactor").getValue();
  }
  
  private float getCurveTightness(){
    return (float) cp5.getController("curveTightness").getValue();
  }
  
  public int[] processImage(PImage img){ 
    values = new int[256][0][2];
    vertexes = new int[0][2];
    lineCoords = new float[0][2];
    numberRows = floor(img.height / getCellHeight());
    numberCells = floor(img.width / getCellWidth());
    
    // determin the brightness for each reagion (pixelate)
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
        values[brightness]=(int[][])append(values[brightness], new int[] {x*getScaleFactor(),y*getScaleFactor()});
      }
    }
    
    int first = -1;
    int[] latest = {};
    // create vertexes based on each brightness level
    for (int b = getMinBrightness(); b<getMaxBrightness(); b++){
      if (values[b].length>0){
        // first pick a random cell
        if (first<0){
          first = int(random(values[b].length));
          latest = values[b][first];
          vertexes = (int[][])append(vertexes, new int[] {values[b][first][0], values[b][first][1]});
        }
        
        // remove it
        values[b] = slice(values[b], first);
        
        while (values[b].length>0){
          int closestindex=0;
          float closestdistance=10000;
          for(int v=0;v<values[b].length;v++){
            //float distance = sqrt(pow(latest[0]-values[b][v][0], 2)+pow(latest[1]-values[b][v][1], 2));
            float distance = distanceBetween2Points(latest, values[b][v]);
            if (distance<closestdistance){
              closestdistance = distance;
              closestindex = v;
            }
          }
          
          latest = values[b][closestindex]; 
          vertexes = (int[][])append(vertexes, new int[] {values[b][closestindex][0], values[b][closestindex][1]});
       
          // remove it
          values[b] = slice(values[b], closestindex);
        }
      }
    }
    
    lineCoords = curvesToPoints(vertexes, getCurveTightness());
    
    for (int l=0; l<lineCoords.length-1; l++){
      float distance = distanceBetween2Points(lineCoords[l], lineCoords[l+1]);
      if (distance<minDistance) minDistance=distance;
      if (distance>maxDistance) maxDistance=distance;
    }
    
    // find the minimum and maximum values to use as bounding box
    float minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (int point = 0; point<lineCoords.length; point++){
      if (lineCoords[point][0] < minX) minX = lineCoords[point][0];
      if (lineCoords[point][0] > maxX) maxX = lineCoords[point][0];
      
      if (lineCoords[point][1] < minY) minY = lineCoords[point][1];
      if (lineCoords[point][1] > maxY) maxY = lineCoords[point][1];
    }
    for (int point = 0; point<lineCoords.length; point++){
      lineCoords[point][1] -= (minY-5*getScaleFactor());
      lineCoords[point][0] -= (minX-5*getScaleFactor());
    }
    maxY -= (minY-5*getScaleFactor());
    maxX -= (minX-5*getScaleFactor());
    
    int[] wh = new int[2];
    wh[0] = ceil(maxX)+10*getScaleFactor();
    wh[1] = ceil(maxY)+10*getScaleFactor();
    return wh;
  }
      
  public int draw(PGraphics displayCanvas, PImage image){
    // you can draw each individual layer brightness as a line, however, curves seem to need 3 or 4 points to render.
    // after experimenting, I think the output is nicer when drawn as one long line

    displayCanvas.beginDraw();
    displayCanvas.noFill();
    displayCanvas.beginShape(); 
    
    displayCanvas.endShape();
    for (int l=0; l<lineCoords.length-1; l++){
      float distance = distanceBetween2Points(lineCoords[l], lineCoords[l+1]);
      if (distance<getMaxLength()){
        float invertDistance = map(distance, minDistance, maxDistance, 1, 0);
        displayCanvas.stroke(0, map(invertDistance, 0, 1, getMinStrokeDarkness(), getMaxStrokeDarkness()));
        displayCanvas.strokeWeight( map(invertDistance, 0, 1, getMinStrokeWeight(), getMaxStrokeWeight()));
        displayCanvas.strokeCap(SQUARE);
        displayCanvas.line(lineCoords[l][0], lineCoords[l][1], lineCoords[l+1][0], lineCoords[l+1][1]);
      }
    }
    
    displayCanvas.endDraw();
    return DRAWING_DONE;
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){ 
    String rowTemp;
    
      
    // draw the lines
    for (int i=0; i<lineCoords.length-1; i++){
      float distance = distanceBetween2Points(lineCoords[i], lineCoords[i+1]);
      if (distance<getMaxLength()){
        float invertDistance = map(distance, minDistance, maxDistance, 1, 0);
        rowTemp = "<path style=\"fill:none;stroke:black;stroke-opacity:"+map(invertDistance, 0, 1, getMinStrokeDarkness(), getMaxStrokeDarkness())/255.0+";stroke-width:"+map(invertDistance, 0, 1, getMinStrokeWeight(), getMaxStrokeWeight())+"px;stroke-linejoin:round;stroke-linecap:square;\" d=\"M ";
        FileOutput = append(FileOutput, rowTemp);
        rowTemp = lineCoords[i][0] + " " + lineCoords[i][1] + "\r";
        FileOutput = append(FileOutput, rowTemp);
        rowTemp = lineCoords[i+1][0] + " " + lineCoords[i+1][1] + "\r";
        FileOutput = append(FileOutput, rowTemp);
        FileOutput = append(FileOutput, "\" />"); // End path description
      }
    }
    return FileOutput;
  }
}
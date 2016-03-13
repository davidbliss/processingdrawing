import controlP5.*;

class RendererHatching extends Renderer{  
  Group settingsGroup;
  int startIndex;
  int linesPerDraw;
  int sampleIndex;
  int numberLines;
  int numberPoints;
  int[] values;
  float[][] lines = {};
  
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
     .setValue(10)
     .setNumberOfTickMarks(101)
     .showTickMarks(false)
     .snapToTickMarks(true)
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
  
  public int[] processImage(PImage img){ 
    lines = new float[0][0];
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
    
    // determine lines
    for (int line=0; line<= numberLines; line++){
      int yVal = getFactor()*(line * getCellHeight())+getCellHeight()/2;
      for (int i = 0; i<numberPoints; i++){
        int xVal = getFactor()*(i*getCellWidth())+(getCellWidth()/2);
        int darkness = (255-values[sampleIndex])/2;
        for (int hatch=0; hatch<darkness; hatch++){
          // completely random is interesting but is similar to pixelation (grid is apparent)
          //displayCanvas.line( xVal+random(getFactor()*-getCellWidth(),getFactor()*getCellWidth()), 
          //                    yVal+random(getFactor()*-getCellHeight(),getFactor()*getCellHeight()), 
          //                    xVal+random(getFactor()*-getCellWidth(),getFactor()*getCellWidth()), 
          //                    yVal+random(getFactor()*-getCellHeight(),getFactor()*getCellHeight()));
          
          // consistent hatches has a good feel to it
          //float x1 = xVal+random(getFactor()*-getCellWidth()/2,getFactor()*getCellWidth()/2);
          //float y1 = yVal+random(getFactor()*-getCellHeight()/2,getFactor()*getCellHeight()/2);
          //float x2 = x1+cos(-getHatchRadians())*getHatchLength();
          //float y2 = y1+sin(-getHatchRadians())*getHatchLength();
          //displayCanvas.line( x1, 
          //                    y1, 
          //                    x2, 
          //                    y2);
          
          // adding randomness is also nice 
          float ranRadians = random(0,getHatchRadiansVariation());
          float ranLength = random(0,getHatchLength()*getHatchLengthVariation());
          float x1 = xVal+random(getFactor()*-getCellWidth()/2,getFactor()*getCellWidth()/2);
          float y1 = yVal+random(getFactor()*-getCellHeight()/2,getFactor()*getCellHeight()/2);
          float x2 = x1+cos(-getHatchRadians() + ranRadians) * (getHatchLength() - ranLength);
          float y2 = y1+sin(-getHatchRadians() + ranRadians) * (getHatchLength() - ranLength);
          
          float[] coords = {x1, y1, x2, y2};
          lines = (float[][])append(lines, coords);
          
        }
        sampleIndex++;
      } 
      print(".");
    }
    println();
    
    startIndex=0;
    linesPerDraw=lines.length/numberLines;
    
    int[] wh = new int[2];
    wh[0] = img.width*getFactor();
    wh[1] = img.height*getFactor();
    return wh;
  }
 
  public int draw(PGraphics displayCanvas, PImage image){
    displayCanvas.beginDraw();
    displayCanvas.stroke(0, getAlpha());
    
    int endIndex = startIndex+linesPerDraw;
    if (endIndex>lines.length) endIndex=lines.length; 
    
    for (int i = startIndex; i<endIndex; i++){
      displayCanvas.line(lines[i][0], lines[i][1], lines[i][2], lines[i][3]);
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
    for (int i = 0; i<lines.length; i++){
      rowTemp = "<line stroke=\"black\" stroke-width=\"1\" x1=\"" + lines[i][0] + "\" y1=\"" + lines[i][1] + "\" x2=\"" + lines[i][2] + "\" y2=\"" + lines[i][3] + "\" stroke-opacity=\""+getAlpha()/100.0+"\"/>";
      FileOutput = append(FileOutput, rowTemp);
          
    }
    return FileOutput;
  }
}
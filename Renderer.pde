class Renderer{
  Renderer(){
  }
  
  public int[] processImage(PImage crop){ 
    println("Renderer must be extended and processImage probably should be overwritten");
    return new int[2];
  }
    
  public int draw(PGraphics displayCanvas, PImage image){
    println("Renderer must be extended and draw must be overwritten");
    return 0;
  }
 
  public void cleanUp(){
    println("Renderer must be extended and cleanUp must be overwritten");
  }
  
  public String[] getSVGData(String[] FileOutput, PImage image){
    println("Renderer must be extended and getSVGdata must be overwritten");
    FileOutput = append(FileOutput, "<text x=\"250\" y=\"150\" font-family=\"Verdana\" font-size=\"55\">Sorry no SVG data provided</text>");
    
    return FileOutput;
    
    /* EXAMPLE PATH OUTPUT
    String rowTemp;
    // Path header::
    rowTemp = "<path style=\"fill:none;stroke:black;stroke-width:2px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M "; 
    FileOutput = append(FileOutput, rowTemp);

    
    for ( i = 0; i < particleRouteLength; ++i) {

      Vec2D p1 = particles[particleRoute[i]];  

      float xTemp = SVGscale*p1.x + xOffset;
      float yTemp = SVGscale*p1.y + yOffset;        

      rowTemp = xTemp + " " + yTemp + "\r";

      FileOutput = append(FileOutput, rowTemp);
    } 
    FileOutput = append(FileOutput, "\" />"); // End path description
    
    */
    
    /* EXAMPLE CIRCLE OUTPUT
    String rowTemp;
    for ( i = 0; i < particleRouteLength; ++i) {
      
      Vec2D p1 = particles[particleRoute[i]]; 

      int px = fl  int py = floor(p1.y);

      float v = (brightness(imgblur.pixels[ py*imgblur.width + px ]))/255;  

      if (invertImg)
        v = 1 - v;

      float dotrad =  (MaxDotSize - v * dotScale)/2; 

      float xTemp = SVGscale*p1.x + xOffset;
      float yTemp = SVGscale*p1.y + yOffset; 

      rowTemp = "<circle cx=\"" + xTemp + "\" cy=\"" + yTemp + "\" r=\"" + dotrad +
        "\" style=\"fill:none;stroke:black;stroke-width:2;\"/>";

      // Typ:   <circle  cx="1600" cy="450" r="3" style="fill:none;stroke:black;stroke-width:2;"/>

      FileOutput = append(FileOutput, rowTemp);
    }   
    */
  }
}
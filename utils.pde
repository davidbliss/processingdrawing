float distanceBetween2Points(int[] p1, int[] p2){
  return sqrt(pow(p1[0]-p2[0], 2)+pow(p1[1]-p2[1], 2));
}

float distanceBetween2Points(float[] p1, float[] p2){
  return sqrt(pow(p1[0]-p2[0], 2)+pow(p1[1]-p2[1], 2));
}

int[][] slice (int[][] array, int drop){
  for(int i=drop ; i<array.length-1 ; i++){
    array[i] = array[i+1];
  }
  return (int[][]) shorten(array);
}

float[][] curvesToPoints(int[][] line, float curveTightness){
  float[][] segmentedPoints = new float[0][0];
  
  for (int point = 1; point<line.length-3; point++){
    int x1, x2, x3, x4;
    int y1, y2, y3, y4;
    
    if (point==0) {
      x1 = line[point][0];
      y1 = line[point][1];
    } else {
      x1 = line[point-1][0];
      y1 = line[point-1][1];
    }
    
    x2 = line[point][0];
    y2 = line[point][1];
    
    if (point==line.length-2){
      x3=line[point+1][0]; 
      x4=line[point+1][0]; 
      y3=line[point+1][1]; 
      y4=line[point+1][1]; 
    } else if (point==line.length-1) {
      x3=line[point][0]; 
      x4=line[point+1][0]; 
      y3=line[point][1]; 
      y4=line[point+1][1]; 
    } else {
      x3=line[point+1][0]; 
      x4=line[point+2][0]; 
      y3=line[point+1][1]; 
      y4=line[point+2][1]; 
    }
    int segments = 13;
    
    curveTightness(curveTightness);
    for (int s=0; s<segments; s++){
      float xVal = curvePoint(x1, x2, x3, x4, s/(float) segments);
      float yVal = curvePoint(y1, y2, y3, y4, s/(float) segments);
      segmentedPoints = (float[][])append(segmentedPoints, new float[] {xVal, yVal});
    }
   
  }
      
  return segmentedPoints;
}
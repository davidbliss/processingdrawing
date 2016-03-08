class Point2d{
  float x=0;
  float y=0;
  
  Point2d(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public float distanceTo(Point2d p2){
    return sqrt(pow(this.x-p2.x, 2) + pow(this.y-p2.y, 2));
  }
  
  public float[] offset(float radians, int distance){
    float[] newXY = new float[2];
    newXY[0] = x + sin(radians)*distance;
    newXY[1] = y + cos(radians)*distance;
    return newXY;
  }
}
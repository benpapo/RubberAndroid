
class Rect {
  float x, y, w, h;
  int col;
  float r, g, b, a;
  
  Rect(float sx, float sy, float rW, float rH) {
    x = sx;
    y = sy;
    w = rW;
    h = rH;
    col = (int) random(0,360);
    r = ( col + millis() / 25.0 ) % 360;
    g = 80;
    b = 80;
    a = 204;
  }
  
  void display() {
    fill(r,g,b,a);
    //fill( col, 204);
    rect(x,y,w,h);
  }
}
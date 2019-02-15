PImage baseImage, targetImage;
float SENSITIVITY_FACTOR = 1;
int SEARCH_RADIUS = 4;

void setup() {
  baseImage = loadImage("../data/01.jpg");
  targetImage=loadImage("../data/02.png");
  image(targetImage, 0,0);
  size(256,320);
}

int y = SEARCH_RADIUS;

void draw() {
  loadPixels();

  for (int x = SEARCH_RADIUS; x < width-SEARCH_RADIUS; x++) {
    color c1 = pixels[y*width+x];
    
    for(int p = SEARCH_RADIUS; p < baseImage.width-SEARCH_RADIUS; p++){
      for(int q = SEARCH_RADIUS; q < baseImage.height-SEARCH_RADIUS; q++){
        color c2 = baseImage.pixels[q*baseImage.width+p];
        c1=lerpColor(c1, c2, similarity(baseImage, p, q, x, y, SEARCH_RADIUS)*SENSITIVITY_FACTOR);
      }
    }
    
    
    
    pixels[y*width+x]=c1;
  }
  
  updatePixels();
  
  print("Done with line ");
  println(y);
  y++;
  if (y==height-SEARCH_RADIUS) y=0;
}

float similarity(PImage image, int x1, int y1, int x2, int y2, int radius) {
  if (x1<radius) return 0.0;
  if (y1<radius) return 0.0;
  if (x2<radius) return 0.0;
  if (y2<radius) return 0.0;
  if (x1+radius>=image.width) return 0.0;
  if (y1+radius>=image.height) return 0.0;
  if (x2+radius>=width) return 0.0;
  if (y2+radius>=height) return 0.0;

  if (image.pixels==null) image.loadPixels();

  float dot = 0.0, mag1 = 0.0, mag2 = 0.0;
  float totalDifference = 0.0;

  for (int i = -radius; i<radius; i++) {
    for (int j = -radius; j<radius; j++) {
      color c1 = image.pixels[(y1+j)*image.width+(x1+i)];
      color c2 = pixels[(y2+j)*width+(x2+i)];

      float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
      float r2 = red(c2), g2 = green(c2), b2 = blue(c2);

      dot +=r1*r2+g1*g2+b1*b2;
      mag1+=r1*r1+g1*g1+b1*b1;
      mag2+=r2*r2+g2*g2+b2*b2;

      totalDifference += abs(r1-r2)+abs(g1-g2)+abs(b1-b2);
    }
  }
  dot=(dot*dot)/(mag1*mag2);
  if (Float.isNaN(dot)) return 0.0;
assert dot<=1.0001: 
  "Dot is "+dot;
assert totalDifference>=0.0: 
  "totalDifference is "+totalDifference;

  return abs(dot)-totalDifference/(radius*radius*3*256);
}

PImage baseImage, targetImage, output;
int SEARCH_RADIUS = 12;

boolean VERBOSE = false;
final color BLUE = color(0, 0, 255);
final color RED = color(200, 0, 0);

TextureNet t;

void setup() {
  baseImage = loadImage("../data/01.jpg");
  targetImage=loadImage("../data/02.png");
  image(targetImage, 0, 0);
  size(1200, 800);
  noStroke();


  surface.setResizable(true);

  if (VERBOSE)frameRate(10);


  t = new TextureNet(baseImage, SEARCH_RADIUS);

  background(32, 32, 64);
}

int x = SEARCH_RADIUS, y = SEARCH_RADIUS;
int iterations = 0;

void draw() {

  if (key=='s') {
    targetImage.loadPixels();
    for (int i = SEARCH_RADIUS; i < baseImage.width-SEARCH_RADIUS; i++) {
      t.compute(baseImage, i, y);
      set(i+480, y+32, t.getOutput());
    }
    y++;
    if (y>=baseImage.height-SEARCH_RADIUS) {
      y = SEARCH_RADIUS;
    }
  } else if (key == 'o') {
    if (output==null) {
      output = targetImage.copy();
      if (y>=output.height-SEARCH_RADIUS) {
        y = SEARCH_RADIUS;
      }
    }
    output.loadPixels();
    for (int i = SEARCH_RADIUS; i < output.width-SEARCH_RADIUS; i++) {
      t.compute(output, i, y);
      output.pixels[y*output.width+i] = lerpColor(output.pixels[y*output.width+i],t.getOutput(),0.25);
    }
    y++;
    if (y>=output.height-SEARCH_RADIUS) {
      y = SEARCH_RADIUS;
    }
    output.updatePixels();
    image(output,480,32);
  } else {
    output = null;
    
    for (int i = 0; i < (key=='f'?50:10); i++) {
      int x2=int(random(SEARCH_RADIUS, baseImage.width-SEARCH_RADIUS));
      int y2=int(random(SEARCH_RADIUS, baseImage.height-SEARCH_RADIUS));
      t.compute(baseImage, x2, y2);
      t.train(baseImage.pixels[y2*baseImage.width+x2]);
    }

    t.compute(baseImage, x, y);
    t.net.display();
    if (key!='n') {
      t.train(baseImage.pixels[y*baseImage.width+x]);
    }

    fill(0);
    rect(0, height-96, width, 96);


    //Display error values
    float errorR = abs(t.net.outputs[0].error);
    fill(errorR*256.0, 0.0, 0.0);
    rect(0, height-96, errorR*width, 32);

    float errorG = abs(t.net.outputs[1].error);
    fill(0.0, errorG*256.0, 0.0);
    rect(0, height-64, errorG*width, 32);

    float errorB = abs(t.net.outputs[2].error);
    fill(0.0, 0.0, errorB*256.0);
    rect(0, height-32, errorB*width, 32);

    if (mousePressed) {
      //background(0, 0, 64);
      image(baseImage, 480, 32);
      int x2=int(mouseX);
      int y2=int(mouseY);
      x2-=480;
      y2-=32;
      if (x2>=SEARCH_RADIUS&&y2>=SEARCH_RADIUS&&x2<baseImage.width-SEARCH_RADIUS&&y2<baseImage.height-SEARCH_RADIUS) {
        x=x2;
        y=y2;
      }
    } else {
      if (key=='r') {
        x=int(random(SEARCH_RADIUS, baseImage.width-SEARCH_RADIUS));
        y=int(random(SEARCH_RADIUS, baseImage.height-SEARCH_RADIUS));
      } else {
        x++;
        if (x>=baseImage.width-SEARCH_RADIUS) {
          x=SEARCH_RADIUS;
          y++;
          if (y>=baseImage.height-SEARCH_RADIUS) {
            y = SEARCH_RADIUS;
          }
        }
      }
    }
    fill(t.getOutput());
    rect(x-SEARCH_RADIUS+480, y-SEARCH_RADIUS+32, SEARCH_RADIUS*2, SEARCH_RADIUS*2);
    //set(x+480, y+32, t.getOutput());

    iterations++;
  }
}

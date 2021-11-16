import drop.*;


SDrop drop;

PImage inputImage, outputImage;
int SEARCH_RADIUS = 2;

int OFFSET_X = 0;

boolean VERBOSE = false;
final color BLUE = color(0, 0, 255);
final color RED = color(200, 0, 0);

TextureNet t;

int numPixelsPerFrame = 20;


boolean renderBars = true;
boolean renderDot = true;
boolean renderNetwork = true;
boolean computeOne = false;

void setup() {
  inputImage = null;
  size(1200, 800);
  noStroke();


  surface.setResizable(true);

  if (VERBOSE)frameRate(10);


  t = new TextureNet(SEARCH_RADIUS);

  background(32, 32, 64);

  thread("findDifficultDataPoints");
  thread("trainThread");

  // For dropping images
  drop = new SDrop(this);
}


int x = SEARCH_RADIUS, y = SEARCH_RADIUS;
void draw() {
  // Edge case: make sure the output image is not null
  if (outputImage==null) {
    background(0);
    textSize(32);
    text("Drop an image here", 16, 48);
    return;
  }

  background(0);

  try {
    TextureNet t2 = t.copy();
    for (int i = 0; i < numPixelsPerFrame; i++) {
      t2.compute(inputImage, x, y);
      outputImage.pixels[y*outputImage.width+x]=t2.getOutput();
      // Update x and y
      x++;
      if (x>=inputImage.width-SEARCH_RADIUS) {
        x=SEARCH_RADIUS;
        y++;
        if (y>=inputImage.height-SEARCH_RADIUS) {
          y = SEARCH_RADIUS;
        }
      }
    }
    if (mouseX>OFFSET_X && mouseX < OFFSET_X+inputImage.width && mouseY < inputImage.height){
      t2.compute(inputImage, mouseX-OFFSET_X, mouseY);
      t2.net.display(outputImage.width+16, 0);
    }
    if (renderNetwork) t2.net.display(outputImage.width+16, 0);
  } 
  catch(IllegalArgumentException e) {
  }



  outputImage.updatePixels();
  image(outputImage, OFFSET_X, 0);
  if (renderDot) {
    fill(180, 64, 0);
    circle(trainX+OFFSET_X, trainY, 32);
  }
  if (renderBars) {
    drawErrorBars();
  }


  if(computeOne) numPixelsPerFrame = 1;
  else numPixelsPerFrame+=(frameRate-40);
}


void drawErrorBars() {
  //Black background

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
}

void keyPressed() {
  switch(key) {
  case 'b':  // bar
    renderBars = !renderBars;
    break;
  case 'd': // dot
    renderDot = !renderDot;
    break;
  case 'n': // network
    renderNetwork = !renderNetwork;
    break;
  case 'a': // all
    renderBars = true;
    renderDot = true;
    renderNetwork = true;
    break;
  case 'm': // minimal
    renderBars = false;
    renderDot = false;
    renderNetwork = false;
    break;
  case 'o': // One step at a time
    computeOne = !computeOne;
    break;
  case 'r':
    t.net.randomizeWeights();
    break;
  case 't':
    isTraining = !isTraining;
    break;
    
  }
}



// Drop events
void dropEvent(DropEvent theDropEvent) {
  // Print the event for debugging
  println("toString()\t"+theDropEvent.toString());
  // Load the file if it's an image
  if (theDropEvent.isImage()) {
    inputImage = loadImage(theDropEvent.file().toString());
    inputImage.loadPixels();
    outputImage = createImage(inputImage.width, inputImage.height, RGB);
    outputImage.loadPixels();
  }
}

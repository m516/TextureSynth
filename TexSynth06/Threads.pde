void findDifficultDataPoints() {
  int x = SEARCH_RADIUS, y = SEARCH_RADIUS;
  while (true) {
    while (!isFull && inputImage!=null) {
      if (inputImage.pixels==null) inputImage.loadPixels();

      //Do a Laplacian blur
      float r = 0, g = 0, b = 0;
      r+=  red(inputImage.pixels[(y-SEARCH_RADIUS)*inputImage.width+(x  )]);
      g+=green(inputImage.pixels[(y-SEARCH_RADIUS)*inputImage.width+(x  )]);
      b+= blue(inputImage.pixels[(y-SEARCH_RADIUS)*inputImage.width+(x  )]);
      r+=  red(inputImage.pixels[(y+SEARCH_RADIUS)*inputImage.width+(x  )]);
      g+=green(inputImage.pixels[(y+SEARCH_RADIUS)*inputImage.width+(x  )]);
      b+= blue(inputImage.pixels[(y+SEARCH_RADIUS)*inputImage.width+(x  )]);
      r+=  red(inputImage.pixels[(y  )*inputImage.width+(x+SEARCH_RADIUS)]);
      g+=green(inputImage.pixels[(y  )*inputImage.width+(x+SEARCH_RADIUS)]);
      b+= blue(inputImage.pixels[(y  )*inputImage.width+(x+SEARCH_RADIUS)]);
      r+=  red(inputImage.pixels[(y  )*inputImage.width+(x-SEARCH_RADIUS)]);
      g+=green(inputImage.pixels[(y  )*inputImage.width+(x-SEARCH_RADIUS)]);
      b+= blue(inputImage.pixels[(y  )*inputImage.width+(x-SEARCH_RADIUS)]);

      r-=4.0*  red(inputImage.pixels[(y)*inputImage.width+(x)]);
      g-=4.0*green(inputImage.pixels[(y)*inputImage.width+(x)]);
      b-=4.0* blue(inputImage.pixels[(y)*inputImage.width+(x)]);

      if (max(r, max(g, b))>0.3*256.0) {
        difficultDataPoints[endIndex++]=new PVector(x, y);
        if (endIndex==difficultDataPoints.length) {
          endIndex = 0;
        }
        if (endIndex==startIndex) {
          isFull = true;
        }
      }


      x++;
      if (x>=inputImage.width-SEARCH_RADIUS) {
        x=SEARCH_RADIUS;
        y++;
        if (y>=inputImage.height-SEARCH_RADIUS) {
          y = SEARCH_RADIUS;
        }
      }
    }
    delay(100);
  }
}

int trainX = SEARCH_RADIUS, trainY = SEARCH_RADIUS;
boolean isTraining = true;
void trainThread() {
  while (true) {
    try {

      // Edge case: make sure the input image is not null
      if (inputImage == null || !isTraining) {
        delay(1000);
        continue;
      }


      // Data points in order
      for (int i = 0; i < 40; i++) {
        t.compute(inputImage, trainX, trainY);
        t.train(inputImage.pixels[trainY*inputImage.width+trainX]);
        // Update x and y
        trainX++;
        if (trainX>=inputImage.width-SEARCH_RADIUS) {
          trainX=SEARCH_RADIUS;
          trainY++;
          if (trainY>=inputImage.height-SEARCH_RADIUS) {
            trainY = SEARCH_RADIUS;
          }
        }
      }



      // Random data points
      int x2=int(random(SEARCH_RADIUS, inputImage.width-SEARCH_RADIUS));
      int y2=int(random(SEARCH_RADIUS, inputImage.height-SEARCH_RADIUS));
      t.compute(inputImage, x2, y2);
      t.train(inputImage.pixels[y2*inputImage.width+x2]);
      // Difficult data points
      PVector newCoords = getNextDifficultDataPoint();
      if (newCoords!=null) {
        x2 = int(newCoords.x);
        y2 = int(newCoords.y);
        t.compute(inputImage, x2, y2);
        t.train(inputImage.pixels[y2*inputImage.width+x2]);
      }
    }
    catch(Exception e) {
      trainX = SEARCH_RADIUS;
      trainY = SEARCH_RADIUS;
    }
  }
}

volatile PVector[] difficultDataPoints = new PVector[200];
volatile int startIndex = 0;
volatile int endIndex = 0;
volatile boolean isFull = false;

PVector getNextDifficultDataPoint() {
  if (startIndex==endIndex && !isFull) return null;
  isFull = false;
  PVector v = difficultDataPoints[startIndex++];
  if (startIndex==difficultDataPoints.length) startIndex=0;
  return v;
}

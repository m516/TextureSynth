PImage baseImage, targetImage; //<>//
int SEARCH_RADIUS = 4;

boolean VERBOSE = false;

NeuralNetwork neuralNetwork;
TestNet t;

void setup() {
  baseImage = loadImage("../data/01.jpg");
  targetImage=loadImage("../data/02.png");
  image(targetImage, 0, 0);
  size(640, 480);

  setupSigmoid();
  neuralNetwork = new NeuralNetwork(1, 1, 1, 1);

  if (VERBOSE)frameRate(10);


  t = new TestNet();
}

int y = SEARCH_RADIUS;
int iterations = 0;

void draw() {
  background(64, 0, 0);
  t.test(random(0.0, 1.0));
  t.net.display();
  t.train();

  
  float error = abs(t.net.outputs[0].error);
  fill(error*256, 256.0-256.0*error, 0.0);
  rect(0, height-32, error*width, 32);

  iterations++;
}

class TexSynth {
  int SEARCH_RADIUS = 4;
  int DEPTH = 4;
  int HEIGHT = 4;

  NeuralNetwork net;
  PImage image;

  TexSynth(PImage image) {
    this.image = image;
    net = new NeuralNetwork(SEARCH_RADIUS*SEARCH_RADIUS*3, DEPTH, DEPTH, 3);
  }
}

class TestNet {


  float[] inputs = {0.0};
  float[] outputs = {0.0};


  NeuralNetwork net = new NeuralNetwork(inputs.length, 8, 8, outputs.length);

  void test(float value) {
    float v = value;
    inputs[0] = v;
    outputs[0] = v;

    net.setInputs(inputs);


    if (VERBOSE) {
      print("Input: ");
      net.printInputs();
    }

    net.reset();
    net.compute();
    if (VERBOSE) {
      print("\tOutput: ");
      net.printOutputs();
    }
  }

  void train() {
    net.train(outputs);


    if (VERBOSE) {
      print("\tError: ");
      print(net.outputs[0].error);


      print("\tWeight: ");
      print(net.outputs[0].weights[0]);

      println();
    }
  }
}

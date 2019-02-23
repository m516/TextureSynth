class TextureNet { //<>//
  PImage texture;
  int COMPUTE_RADIUS = 2;
  NeuralNetwork net;

  private float[] inputs; 
  private float[] outputs;
  private int currTexCoordX, currTexCoordY;

  TextureNet(PImage sample, int computeRadius) {
    //Set up the sample
    texture = sample;
    if (texture.pixels==null) texture.loadPixels();

    //Set up the network
    COMPUTE_RADIUS = computeRadius;
    net = new NeuralNetwork(COMPUTE_RADIUS*COMPUTE_RADIUS*12, 4, 64, 3);

    //Set up input and output arrays
    inputs = new float[net.inputs.length];
    for (int i = 0; i < inputs.length; i++) inputs[i] = 0.0;
    outputs = new float[3];
    for (int i = 0; i < outputs.length; i++) outputs[i] = 0.0;
  }

  //Estimates 
  void compute(PImage image, int textureX, int textureY) {
    //Error checking
    if (image==null) throw new NullPointerException();
    if (textureX<COMPUTE_RADIUS)                throw new IllegalArgumentException("Texture X coordinate too low");
    if (textureX>=image.width-COMPUTE_RADIUS)   throw new IllegalArgumentException("Texture X coordinate too high");
    if (textureY<COMPUTE_RADIUS)                throw new IllegalArgumentException("Texture Y coordinate too low");
    if (textureY>=image.height-COMPUTE_RADIUS)  throw new IllegalArgumentException("Texture Y coordinate too high");

    //Load the pixels of the image if necessary
    if (image.pixels==null) image.loadPixels();


    //Set private fields
    currTexCoordX = textureX;
    currTexCoordY = textureY;

    //Reset the network
    net.reset();

    //Set up the inputs
    int inputIndex = 0;
    for (int i = -COMPUTE_RADIUS; i < COMPUTE_RADIUS; i++) {
      for (int j = -COMPUTE_RADIUS; j < COMPUTE_RADIUS; j++) {
        if (i==0&&j==0) {
          inputIndex+=3;
          continue; //Ignore the pixel currently in the center of the texture and use it as a ground for the hidden layers
        }
        color c = image.pixels[(textureY+j)*image.width+(textureX+i)];
        inputs[inputIndex++]=red(c)/256.0;
        inputs[inputIndex++]=green(c)/256.0;
        inputs[inputIndex++]=blue(c)/256.0;
      }
    }

    //Give the network its inputs
    net.setInputs(inputs);

    //Tell the net to compute
    net.compute();

    //Copy results to the outputs array
    for (int i = 0; i < outputs.length; i++) {
      outputs[i] = net.outputs[i].value;
    }
  }

  color getOutput() {
    return color(outputs[0]*256.0, outputs[1]*256.0, outputs[2]*256.0);
  }

  void train(color expected) {
    float[] colorAsFloatArray = {red(expected)/256.0, green(expected)/256.0, blue(expected)/256.0};
    net.train(colorAsFloatArray);
  }
}

class TestNet {

  float[] inputs = {0.0};
  float[] outputs = {0.0};

  NeuralNetwork net = new NeuralNetwork(inputs.length, 1, 1, outputs.length);

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
} //<>//

float LEARNING_RATE = 0.05;

class Node {
  float value;

  void display() {
    fill(value*256.0);
    ellipse(0, 0, 16, 16);
  }
}



class Neuron extends Node {
  Node[] inputs;
  float[] weights;

  float error = 0.0;

  public Neuron() {
  }

  public Neuron(Node[] inputNodes) {
    initialize(inputNodes);
  }

  void initialize(Node[] inputNodes) {
    inputs=inputNodes;
    weights = new float[inputs.length];
    for (int i = 0; i < weights.length; i++) weights[i] = random(0.0, 1.0);
  }

  void calculateError(float desired) {
    error = desired-value;
  }

  float compute() {
    for (int i = 0; i < inputs.length; i++) {
      value+=inputs[i].value+weights[i];
    }

    error = 0.0;

    value = 1.0 / (1.0 + exp(-1.0 * value));
    return value;
  }

  void reset() {
    value = 0.0;
  }



  void train() {
    float delta = (1.0-error)*(1.0+error)*error*LEARNING_RATE; //<>//

    for (int i = 0; i < inputs.length; i++) {
      if (inputs[i] instanceof Neuron) {
        Neuron n = (Neuron) inputs[i];
        n.error+=weights[i]*error; //<>//
      }
      weights[i]+=inputs[i].value * delta;
    }
  }
}

class NeuronGenerator {
  ArrayList<Node> nodeList = new ArrayList<Node>();
  Neuron neuron;

  NeuronGenerator() {
    nodeList = new ArrayList<Node>();
  }

  void addNode(Node n) {
    nodeList.add(n);
  }

  Neuron buildNeuron() {
    Node[] n = new Node[nodeList.size()];
    nodeList.toArray(n);
    neuron = new Neuron(n);
    return neuron;
  }

  Neuron currentNeuron() {
    return neuron;
  }

  void clear() {
    nodeList.clear();
    neuron=null;
  }
}

class NeuralNetwork {
  Node[] inputs = new Node[1];

  Neuron[][] layer;

  Neuron[] outputs;

  boolean isReset = false;
  boolean isDoneComputing = false;

  NeuralNetwork(int numInputs, int layerHeight, int layerDepth, int numOutputs) {
    inputs = new Node[numInputs];
    layer = new Neuron[layerHeight][layerDepth];
    outputs = new Neuron[numOutputs];

    //Build the inputs
    NeuronGenerator layerNeuronGenerator = new NeuronGenerator();
    for (int i = 0; i < inputs.length; i++) {
      inputs[i] = new Node();
      layerNeuronGenerator.addNode(inputs[i]);
    }

    //Build the hidden layer
    NeuronGenerator outputNeuronGenerator = new NeuronGenerator();
    for (int i = 0; i < layer.length; i++) {
      for (int j = 0; j < layer[i].length; j++) {
        layer[i][j] = layerNeuronGenerator.buildNeuron();
        outputNeuronGenerator.addNode(layer[i][j]);
      }
      
      for(int k = 0; k < layer[i].length; k++){
        layerNeuronGenerator.addNode(layer[i][k]);
      }
    }

    //Build the output layer
    for (int i = 0; i < outputs.length; i++) {
      outputs[i] = outputNeuronGenerator.buildNeuron();
    }
  }


  void reset() {

    //Reset the hidden layer
    for (int i = 0; i < layer.length; i++) {
      for (int j = 0; j < layer[i].length; j++) {
        layer[i][j].reset();
      }
    }

    //Reset the output layer
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].reset();
    }

    isReset = true;
  }

  void setInput(int index, float value) {
    inputs[index].value=value;
  }

  void setInputs(float[] values) {
    if (values==null) throw new NullPointerException();
    if (values.length!=inputs.length) throw new IllegalArgumentException("Sample data must be the same size as the input data");

    for (int i = 0; i < values.length; i++) {
      inputs[i].value = values[i];
    }
  }

  void compute() {
    if (!isReset) {
      println("Implicitly resetting");
      reset();
    }

    //Process the hidden layer
    for (int i = 0; i < layer.length; i++) {
      for (int j = 0; j < layer[i].length; j++) {
        layer[i][j].compute();
      }
    }

    //Build the output layer
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].compute();
    }

    isDoneComputing = true;
    isReset = false;
  }

  void train(float[] expected) {
    if (expected==null) throw new NullPointerException();
    if (expected.length!=outputs.length) throw new IllegalArgumentException("Training data must be the same size as the output data");
    if (!isDoneComputing) {
      println("Implicitly computing");
      compute();
    }

    //Train the output layer
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].calculateError(expected[i]);
      outputs[i].train();
    }

    //Train the hidden layer
    for (int i = 0; i < layer.length; i++) {
      for (int j = 0; j < layer[i].length; j++) {
        layer[i][j].train();
      }
    }
    isDoneComputing = false;
  }

  float[] getOutputs() {
    float[] list = new float[outputs.length];
    for (int i = 0; i < list.length; i++) { //<>//
      list[i]=outputs[i].value;
    }
    return list;
  }

  void printInputs() {
    print("[");
    for (int i = 0; i < inputs.length-1; i++) {
      print(inputs[i].value);
      print(", ");
    }
    print(inputs[inputs.length-1].value);
    print("]");
  }

  void printOutputs() {
    print("[");
    for (int i = 0; i < outputs.length-1; i++) {
      print(outputs[i].value);
      print(", ");
    }
    print(outputs[outputs.length-1].value);
    print("]");
  }

  void display() {
    pushMatrix();
    
    //Inputs
    pushMatrix();
    translate(32, 32);
    for (int i = 0; i < inputs.length; i++) {
      inputs[i].display();
      translate(0, 32);
    }
    popMatrix();

    //Inputs
    translate(64, 32);
    for (int i = 0; i < layer.length; i++) {
      pushMatrix();
      for (int j = 0; j < layer[i].length; j++) {
        layer[i][j].display();
        translate(0, 32);
      }
      popMatrix();
      translate(32, 0);
    }

    //Outputs
    translate(32,0);
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].display();
      translate(0,32);
    }
    popMatrix();
  }
}

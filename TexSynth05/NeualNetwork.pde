int BLOCK_SIZE = 4; //<>//
float NEURON_ERROR_TO_REVIVE = 0.3;


class NeuralNetwork {
  Node[] inputs = new Node[1];

  Neuron[][] layer;

  Neuron[] outputs;

  boolean isReset = false;
  boolean isDoneComputing = false;

  NeuralNetwork(int numInputs, int layerDepth, int layerHeight, int numOutputs) {
    inputs = new Node[numInputs];
    layer = new Neuron[layerDepth][layerHeight];
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


      //Add this layer of neurons to the list to add to the neuron generator
      //layerNeuronGenerator.clear();
      for (int k = 0; k < layer[i].length; k++) {
        layerNeuronGenerator.addNode(layer[i][k]);
      }
    }

    //Build the output layer
    for (int i = 0; i < outputs.length; i++) {
      outputs[i] = outputNeuronGenerator.buildNeuron();
      //outputs[i] = layerNeuronGenerator.buildNeuron();
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
      if (abs(outputs[i].error)>NEURON_ERROR_TO_REVIVE) reviveDeadNeuron(outputs[i]);
      else outputs[i].train();
    }

    //Train the hidden layer
    for (int i = layer.length-1; i >= 0; i--) {
      for (int j = 0; j < layer[i].length; j++) {
        if (abs(layer[i][j].error)>NEURON_ERROR_TO_REVIVE) reviveDeadNeuron(layer[i][j]);
        else layer[i][j].train();
      }
    }
    isDoneComputing = false;
  }

  float[] getOutputs() {
    float[] list = new float[outputs.length];
    for (int i = 0; i < list.length; i++) {
      list[i]=outputs[i].value;
    }
    return list;
  }

  //Tries to add randomness to the neuron to revive it
  void reviveDeadNeuron(Neuron initialDeadNeuron) {
    //Reset the weights
    for (int i = 0; i < initialDeadNeuron.weights.length; i++) {
      if (initialDeadNeuron.weights[i]>0.3 && initialDeadNeuron.inputs[i] instanceof Neuron) {
        Neuron in = (Neuron)initialDeadNeuron.inputs[i];
        for (int j = 0; j < in.weights.length; j++) {
          in.weights[j]+=random(-1.0, 1.0)*LEARNING_RATE*abs(initialDeadNeuron.weights[i]);
        }
      }
      initialDeadNeuron.weights[i]+=random(-0.01, 0.01);
    }
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
    int maxHeight = (height-96)/BLOCK_SIZE;
    pushMatrix();

    //Inputs
    pushMatrix();
    for (int i = 0; i < inputs.length; i++) {
      if (i%maxHeight==0) {
        popMatrix();
        pushMatrix();
        translate(BLOCK_SIZE*i/maxHeight, BLOCK_SIZE);
      }
      inputs[i].display();
      translate(0, BLOCK_SIZE);
    }
    popMatrix();

    //Inputs
    translate((inputs.length/maxHeight+2)*BLOCK_SIZE, BLOCK_SIZE);
    for (int i = 0; i < layer.length; i++) {
      pushMatrix();
      for (int j = 0; j < layer[i].length; j++) {
        layer[i][j].display();
        translate(0, BLOCK_SIZE);
      }
      popMatrix();
      translate(BLOCK_SIZE, 0);
    }

    //Outputs
    translate(BLOCK_SIZE, 0);
    for (int i = 0; i < outputs.length; i++) {
      outputs[i].display();
      translate(0, BLOCK_SIZE);
    }
    popMatrix();
  }
}

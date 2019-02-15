float LEARNING_RATE = 0.001;

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
    for (int i = 0; i < weights.length; i++) weights[i] = random(-1.0, 1.0);
  }

  void calculateError(float desired) {
    //error = 0.5*pow(desired-value,2.0);
    error=value-desired;
  }

  float compute() {
    float v = 0.0;
    for (int i = 0; i < inputs.length; i++) { //<>//
      v+=inputs[i].value*weights[i];
    }

    error = 0.0;

    v = adjustedValueForNeurons(v);
    
    value=v;
    return value;
  }
  
  

  void reset() {
    value = 0.0;
  }



  void train() {
    float value = this.value;
    float sigma = error*value*(1.0-value);

    for (int i = 0; i < inputs.length; i++) {
      if (inputs[i] instanceof Neuron) {
        Neuron n = (Neuron) inputs[i];
        n.error+=weights[i]*sigma;
      }
      weights[i] -= inputs[i].value * sigma * LEARNING_RATE;
    }
  }
}

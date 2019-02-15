class Node{
  float value;
}

//Source: https://medium.com/typeme/lets-code-a-neural-network-from-scratch-part-2-87e209661638
float [] g_sigmoid = new float [200];

void setupSigmoid() {
  
  for (int i = 0; i < 200; i++) {
    float x = (i / 20.0) - 5.0;
    g_sigmoid[i] = 2.0 / (1.0 + exp(-2.0 * x)) - 1.0;
  }
}

// once the sigmoid has been set up, this function accesses it:
float lookupSigmoid(float x) {
  return g_sigmoid[constrain((int) floor((x + 5.0) * 20.0), 0, 199)];
}



class Neuron extends Node{
  Node[] inputs;
  float[] weights;
  
  public Neuron(){
    
  }
  
  public Neuron(Node[] inputNodes){
    initialize(inputNodes);
  }
  
  void initialize(Node[] inputNodes){
    inputs=inputNodes;
    weights = new float[inputs.length];
    for(int i = 0; i < weights.length; i++) weights[i] = 1.0;
  }
  
  float compute(){
    for(int i = 0;
  }
  
}

class NeuronGenerator{
  ArrayList<Node> nodeList = new ArrayList<>();
  Neuron neuron;
  
  void addNode(Node n){
    nodeList.add(n);
  }
  
  Neuron buildNeuron(){
    Node[] n = new Node[nodeList.size()];
    nodeList.toArray(n);
    neuron = new Neuron(n);
    return neuron;
  }
  
  Neuron currentNeuron(){
    return neuron;
  }
  
  void clear(){
    nodeList.clear();
    neuron=null;
  }
}

class NeuralNetwork{
  
}

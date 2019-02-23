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

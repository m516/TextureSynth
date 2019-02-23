class Node {
  float value;

  void display() {
    fill(value*256.0);
    rect(0, 0, BLOCK_SIZE, BLOCK_SIZE);
  }
  
  float adjustedValueForNeurons(float raw){
    return 1.0 / (1.0 + exp(-raw));
  }
  
  float adjustedValueForNeurons(){
    return 1.0 / (1.0 + exp(value));
  }
}

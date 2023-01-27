import java.util.*;
NeuralNetwork SigmoidNetwork = new NeuralNetwork(new Layer[]{

  new DenseLayer(2, 10), 
  new SigmoidLayer(), 
  new DenseLayer(10, 10), 
  new SigmoidLayer(), 
  new DenseLayer(10, 10),
    new SigmoidLayer(), 
  new DenseLayer(10, 10),
    new SigmoidLayer(), 
  new DenseLayer(10, 10),
  new SigmoidLayer(), 
  new DenseLayer(10, 2), 
  new SoftMaxLayer()
  }, 0.01);
  
NeuralNetwork RELUNetwork = new NeuralNetwork(new Layer[]{
  new DenseLayer(2, 20), 
  new RELULayer(), 
  new DenseLayer(20, 20), 
  new RELULayer(),
  new DenseLayer(20, 10), 
  new RELULayer(),
  new DenseLayer(10, 10), 
  new RELULayer(),
   new DenseLayer(10, 10), 
  new RELULayer(),
   new DenseLayer(10, 10), 
  new RELULayer(),
   new DenseLayer(10, 10), 
  new RELULayer(),
   new DenseLayer(10, 10), 
  new RELULayer(),
   
  new DenseLayer(10, 2), 
  
  new SoftMaxLayer()}, 0.01);


// key bindings
char TrainKey = 't';
char ResetKey='r';
char SwitchKey = 's';
char ResetNetworkKey='n';
char SwitchDomainKey ='d';


int BackgroundColour=220;



Graph graph=new Graph(1000, 1000, 10, 10);
int UIWidth =500;
TEXTBOX LearningRateEntry=new TEXTBOX(graph.Width+10, 445, 200, 50);

// matrix holds the points that the user draws on, and which are used to train network
//Matrix TrainingPoints=new Matrix();
// matrix holds the points that our network has approximated
//Matrix ApproximationPoints=new Matrix();

float samplingfrequency=0.2;
float classificationpointsize=graph.Width/graph.RowNum*samplingfrequency;



// list of networks
NeuralNetwork[] Networks=new NeuralNetwork[]{SigmoidNetwork,RELUNetwork};
String[] NetworkNames = new String[]{ "Sigmoid","RELU"};

// index of current network being used  
int CurrentNetwork=0;

NeuralNetwork nn= Networks[CurrentNetwork];
//Classification Classifier = new CircleClassification(3,graph.Width,graph.Height);
//Classification Classifier = new QuadrantClassification(samplingfrequency);
Classification Classifier = new CircleClassification(4,graph.Width,graph.Height);

//Classification Classifier = new QuadrantClassification(samplingfrequency);

Matrix GridPoints = SampleGrid(samplingfrequency, samplingfrequency);
//Matrix DomainPoints = Classifier.DomainPoints;
Matrix Points =GridPoints;
Matrix TrainingPoints = Matrix.ApplyBinaryFunction(new MultiplicationFunc(),GridPoints,0.1);

//boolean RenderAllGridPoints = false;
Integer[] oldclassifications = new Integer[Points.ColNum];

int count=0;


void settings() {
  size(graph.Width+UIWidth, graph.Height);
}

void setup() {
  
  // initialise old classifications
  for(int i=0;i<Points.ColNum;i++){
    oldclassifications[i]=-1;
  }
  
  
}

void draw() {
  //background(230);
  println(count);
  count+=1;
  
  //for(int i =0;i <4;i++){
  //  for(int j=0;j<10000;j++){
  //    DrawClassifiedPoint(Classifier.ClassificationToPoint(i),i);
  //  }
  //}
  //noLoop();
  Train();


  DrawClassifier(Points);
  graph.Draw();
  DrawUI();
     
  nn.LearningRate=GetLearningRate();
  //noLoop();
}

void Train() {
  for (int i =0; i<100; i++) {
    TrainClassifier();
  }
}



Matrix SamplePoints(Matrix points, float start, float end, float density, Function function) {
  // function returns a matrix of points, which sample values from a function, from start to end, with a particular density
  for (float x =start; x<=end; x+=density) {
    points.AddColumn(new Float[]{x, function.function(x)});
  }
  return points;
}


public Matrix SamplePointsFromNetwork( float start, float end, float density, NeuralNetwork Network) {
  // function returns a matrix of points, which samples points from a network
  Matrix points =new Matrix();
  for (float x =start; x<=end; x+=density) {
    points.AddColumn(new Float[]{x, Network.Query(new Matrix(1, 1, new Float[]{x})).Get(0, 0)});
  }
  return points;
}




void mousePressed() {

  LearningRateEntry.PRESSED(mouseX, mouseY);
  
}

void keyPressed() {
  if ( key==TrainKey) {
    Train();
  } else if ( key== ResetKey) {
    Reset();
  } else if (key==SwitchKey) {
    SwitchNetwork();
  } else if (key==ResetNetworkKey) {
    ResetNetwork();
  }else if (key==SwitchDomainKey){
    //SwitchDomain();
  }


  LearningRateEntry.KEYPRESSED(key, keyCode);
}









void Reset() {
  // resets both the points and the network
  ResetNetwork();
}



void ResetNetwork() {
  nn.Reset();
  println("Network Reset");
}

void SwitchNetwork() {
  CurrentNetwork+=1;
  CurrentNetwork= CurrentNetwork% Networks.length;
  nn=Networks[CurrentNetwork];
  nn.Reset();
}

void DrawUI() {
  // creates UI box at right hand of screen
  fill(220);
  stroke(0);
  rect(graph.Width, 0, width-graph.Width, height);

  // writes instructions
  stroke(0);
  textFont(createFont("Arial", 20, true), 25);
  fill(0);
  text("Click to add a point", graph.Width+10, 75);
  text("Press R to reset points", graph.Width+10, 150);
  text("Press N to reset network", graph.Width+10, 225);
  text("Press S to switch activation functions", graph.Width+10, 300);

  // writes list of different networks
  textFont(createFont("Arial", 20, true), 15);
  String networkslist="";
  for (int i =0; i<NetworkNames.length-1; i++) {
    networkslist+=NetworkNames[i]+" / ";
  }
  networkslist+=NetworkNames[NetworkNames.length-1];
  text(networkslist, graph.Width+10, 330);

  // writes current network being used
  text("Current Activation Function: " + NetworkNames[CurrentNetwork], graph.Width+10, 360);

  // draws learning rate entry box
  textFont(createFont("Arial", 20, true), 25);
  text("Learning Rate:", graph.Width+10, 435);
  LearningRateEntry.DRAW();
}

float GetLearningRate() {
  // returns the learning rate entered in the learning rate entry box
  float lr=float(LearningRateEntry.Text);

  if (Float.isNaN(lr)) {
    return 0.0004;
  }
  return lr;
}


void TrainClassifier() {
  
  int classification = floor(random(0,Classifier.ClassificationNum));
  Matrix inputs= Classifier.ClassificationToPoint(classification);
  Matrix targets = new Matrix(Classifier.ClassificationNum, 1, GetClassificationArray(classification,Classifier.ClassificationNum));
  nn.Train(inputs, targets);

}



void DrawClassifier(Matrix points) {
  
  for (int col=0; col<points.ColNum; col++) {

    Matrix point= new Matrix(2, 1, points.GetColumn(col));
    Matrix output=nn.Query(point);//Matrix.ApplyBinaryFunction(new MultiplicationFunc(),point,(float)1/graph.ColNum));
    //point.OutputMatrix("point");
    //Matrix.ApplyBinaryFunction(new MultiplicationFunc(),point,(float)1/graph.ColNum).OutputMatrix("mapping");
    int classification= GetClassification(output);
    
    if(classification!=oldclassifications[col]){
      oldclassifications[col]=classification;    
      DrawClassifiedPoint(point, classification);
    }
    
  }
}

void DrawClassifiedPoint(Matrix point, int classification) {
  color pointcolour;
  switch(classification) {
  case 0:
    pointcolour = color(255, 0, 0);
    break;
  case 1:
    pointcolour = color(0, 255, 0);
    break;
  case 2:
    pointcolour = color(0, 0, 255);
    break;
  case 3:
    pointcolour = color(255, 255, 0);
    break;
  default:
    pointcolour= color(0,0,0);
    break;
  }
  DrawRectPointMatrix(MapToCanvas(point, graph.RowNum, graph.ColNum, graph.Width, graph.Height), pointcolour, color(0,255), 0,classificationpointsize ,classificationpointsize);
  
}

int GetClassification(Matrix output) {
  // takes a column vector as input 
  // and returns the index of the largest value in that vector
  int largest=0;
  Float[] vector = output.GetColumn(0);
  for (int i=0; i<vector.length; i++) {
    if (vector[i]>vector[largest]) {
      largest=i;
    }
  }
  return largest;
}

Matrix SampleGrid(float xspacing, float yspacing) {

  Matrix points=new Matrix();
  
  for (float x=-graph.ColNum/2-xspacing; x<graph.ColNum/2+xspacing; x=x+xspacing) {
    for (float y=-graph.RowNum/2-yspacing; y<graph.RowNum/2+yspacing; y=y+yspacing) {
      points.AddColumn(new Float[]{x, y});
    }
  }
  return points;
}



Float[] GetClassificationArray(int index, int size) {
  ArrayList<Float> classification=new ArrayList<Float>();
  for (int i =0; i<size; i++) {
    if (i==index) {
      classification.add(0.99f);
    } else {
      classification.add(0.01f);
    }
  }
  Float[] arr= new Float[classification.size()];
  return classification.toArray(arr);
}

//void SwitchDomain(){
//  RenderAllGridPoints= !RenderAllGridPoints;
  
//  if(RenderAllGridPoints){
//    Points= GridPoints;
//  }
//  else{
//    Points=DomainPoints;
//  }
  
//  oldclassifications= new Integer[Points.ColNum];
//  for(int i=0;i<Points.ColNum;i++){
//    oldclassifications[i]=-1;
//  }
//  background(BackgroundColour);
//}

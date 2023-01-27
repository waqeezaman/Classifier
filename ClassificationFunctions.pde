
abstract class Classification {
  // takes a 2d input point and assigns a classification to the point 
  public int ClassificationNum;
  public abstract Matrix ClassificationToPoint(int classification);
}



class QuadrantClassification extends Classification {


  public QuadrantClassification() {
    ClassificationNum=4;
  }




  public Matrix ClassificationToPoint(int classification) {
    switch(classification) {
    case 0:
      return new Matrix(2, 1, new Float[]{random(0, 5), random(0, 5)});

    case 1:
      return new Matrix(2, 1, new Float[]{random(-5, 0), random(0, 5)});

    case 2:
      return new Matrix(2, 1, new Float[]{random(-5, 0), random(-5, 0)});

    case 3:
      return new Matrix(2, 1, new Float[]{random(0, 5), random(-5, 0)});


    default:
      println("ERROR --- ClassificationToPoint()  --- classification given not part of valid classifications" ); 
      return null;
    }
  }
}


class SpiralClassification extends Classification {

  private float LowerLimit=-1;
  private float UpperLimit=1;

  public SpiralClassification(int spiralnum, float lowerlim, float upperlim) {
    ClassificationNum=spiralnum;

    LowerLimit=lowerlim;
    UpperLimit=upperlim;
  }

  public Matrix ClassificationToPoint(int classification) {
    float t = random(LowerLimit, UpperLimit);

    return new Matrix(2, 1, GetSpiralPoint(classification, t));
  }

  public Float[] GetSpiralPoint(int classification, float t ) {
    float random= random(0, 1);
    float x =t*sin((2*PI/ClassificationNum)*((2*t)+classification-1+random));
    float y =t*cos((2*PI/ClassificationNum)*((2*t)+classification-1+random));    
    return new Float[]{x, y};
  }


}



class CircleClassification extends Classification {

  float Radius;
  float GraphWidth;
  float GraphHeight;

  public CircleClassification(float radius, float graphwidth, float graphheight ) {

    ClassificationNum=2;

    Radius=radius;

    GraphWidth=graphwidth;
    GraphHeight=graphheight;
    
    //DomainPoints=new Matrix(2,1,new Float[]{1f,1f});
  }




  public Matrix ClassificationToPoint(int classification) {
    float theta = random(0, 2*PI);
    float distance=0;
    switch(classification) {
    case 0:
      distance= random(Radius, GraphWidth/2);
      return new Matrix(2, 1, new Float[]{sin(theta)* distance, cos(theta) * distance});

    case 1:
      distance= random(0, Radius);
      return new Matrix(2, 1, new Float[]{sin(theta)* distance, cos(theta) * distance});

    default:
      println("ERROR --- ClassificationToPoint()  --- classification given not part of valid classifications" ); 
      return null;
    }
  }
}

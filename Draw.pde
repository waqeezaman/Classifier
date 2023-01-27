// file that holds functions to draw objects to canvas

void DrawPoint(float x, float y, float radius, color colour,color outlinecolour,float outlinewidth) {
  // draws a point
  
  if(outlinewidth==0){
    noStroke();
  }else{
    strokeWeight(outlinewidth);
    stroke(outlinecolour);
  }
  
  fill(colour);
  circle(x, y, radius);
}

void DrawRect(float x, float y, float rwidth, float rheight, color fillcolour, color outlinecolour,float outlinewidth) {
  // draws a rectangle at a point 
  // the x and y values given are the bottom left of the rectangle
  if(outlinewidth==0){
    noStroke();
  }else{
    strokeWeight(outlinewidth);
    stroke(outlinecolour);
  }
  
  fill(fillcolour);
  rect(x, y-rheight, rwidth, rheight);
}

void DrawLine(float x1, float y1, float x2, float y2, color colour, float thickness) {
  // draws a line
  stroke(colour);
  strokeWeight(thickness);
  line(x1, y1, x2, y2);
}


void DrawPointMatrix(Matrix points, color pointcolour,color outlinecolour, float PointRadius,float outlinewidth) {
  // draws a set of points in a matrix


  for (int j =0; j<points.ColNum; j++) {

    // draws points
    DrawPoint(points.Get(0, j), points.Get(1, j), PointRadius, pointcolour,outlinecolour,outlinewidth);
  }

}

void DrawRectPointMatrix(Matrix points, color rectcolour,color outlinecolour,float outlinewidth ,float rwidth,float rheight) {
  // draws a set of points in a matrix


  for (int j =0; j<points.ColNum; j++) {

    // draws rectangles at points
    DrawRect(points.Get(0, j), points.Get(1, j), rwidth, rheight,rectcolour,outlinecolour,outlinewidth);
  }

}

void DrawLineMatrix(Matrix points, color linecolour, float linethickness, boolean cyclical) {
  // draws a lines between a set of points

  //draws a line between end and start points
  if (points.ColNum>2 && cyclical) {
    DrawLine(points.Get(0, 0), points.Get(1, 0), points.Get(0, points.ColNum-1), points.Get(1, points.ColNum-1), 
      linecolour, linethickness);
  }

  for (int j =0; j<points.ColNum; j++) {

    if (j!=points.ColNum-1 ) { // draws lines between points
      DrawLine(points.Get(0, j), points.Get(1, j), points.Get(0, j+1), points.Get(1, j+1), linecolour, linethickness);
    }
  }
}





void DrawGrid(int rownum, int colnum, color GridLineColour, float GridLinesThickness, int graphwidth, int graphheight) {

  // draws a grid


  float xspacing = float(graphwidth/colnum);
  float yspacing = float(graphheight/rownum);

  // draw rows
  for (int r =0; r<rownum; r++) {
    DrawLine(0, r*yspacing, graphwidth, r*yspacing, GridLineColour, GridLinesThickness);
  }
  //draw columns
  for (int c =0; c<colnum; c++) {
    DrawLine(c*xspacing, 0, c*xspacing, graphheight, GridLineColour, GridLinesThickness);
  }

  // draws axis, with double thickness
  DrawLine(graphwidth/2, 0, graphwidth/2, graphheight, GridLineColour, GridLinesThickness*2);
  DrawLine(0, graphheight/2, graphwidth, graphheight/2, GridLineColour, GridLinesThickness*2);
} 

Point MapPointToCanvas(Point point, int colnum, int rownum, int graphwidth, int graphheight) {
  // maps a point from the cartesian grid to canvas
  float x = point.x+float(colnum/2);
  x*=float(graphheight/colnum);
  float y = point.y*-1;
  y+=float(rownum/2);
  y*=float(graphheight/rownum);
  return new Point(x, y);
}
Point MapPointToCartesian(Point point, int colnum, int rownum, int graphwidth, int graphheight) {
  // maps a single point from the canvas to the cartesian grid
  float x = point.x/float(graphwidth/colnum);
  x-=float(colnum/2);

  float y = point.y/ float(graphheight/rownum);
  y*=-1;
  y+=float(rownum/2);
  return new Point(x, y);
}




Matrix MapToCanvas(Matrix points, int rownum, int colnum, int graphwidth, int graphheight) {
  // maps cartesian co-ordinates to canvas co-ordinates

  Matrix transformedmatrix= new Matrix(points.RowNum, points.ColNum);


  transformedmatrix.ApplyBinaryOperationToRow(new AdditionFunc(), 0, graphwidth/2);
  transformedmatrix.ApplyBinaryOperationToRow(new AdditionFunc(), 1, graphheight/2);

  Matrix transformedpoints = new Matrix(points);

  transformedpoints.ApplyBinaryOperationToRow(new MultiplicationFunc(), 0, graphwidth/rownum);
  transformedpoints.ApplyBinaryOperationToRow(new MultiplicationFunc(), 1, -graphheight/colnum);

  transformedmatrix.OperationBetweenMatrices(new AdditionFunc(), transformedpoints);





  return transformedmatrix;
}

Matrix MapToCartesian(Matrix points, int colnum, int rownum, int graphwidth, int graphheight) {
  // maps a matrix of points from canvas co-ordinates to cartesian grid co-ordinates
  Matrix transformedmatrix= new Matrix();

  float horizontalscale = 1/(float(graphwidth)/float(colnum));
  float verticalscale = 1/(float(graphheight)/float(rownum));

  transformedmatrix=Matrix.ApplyBinaryOperationToRow(new MultiplicationFunc(), points, 0, horizontalscale);
  transformedmatrix.ApplyBinaryOperationToRow(new MultiplicationFunc(), 0, verticalscale);

  // flip row
  transformedmatrix.ApplyBinaryOperationToRow(new MultiplicationFunc(), 1, -1f);

  transformedmatrix.ApplyBinaryOperationToRow(new AdditionFunc(), 0, -float(colnum/2));
  transformedmatrix.ApplyBinaryOperationToRow(new AdditionFunc(), 1, float(rownum/2));



  return transformedmatrix;
}

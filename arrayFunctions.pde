public static int arrayMinIndex(float[] inArray){
  int index = 0;
  for(int i=0; i<inArray.length; i++){
    if(i != index){
      if(inArray[i] < inArray[index]){
        index = i;
      }
    }
  }
  return index;
}
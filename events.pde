void keyPressed(){
	
  if(key == '1')      isGrid     = !isGrid;
  if(key == '2')      isEqualise = !isEqualise;
  else if(key == ' ') isGeo      = !isGeo;

  loop();
}
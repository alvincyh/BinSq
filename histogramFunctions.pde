static Map sortByValue(Map inMap, boolean isDescending) {
  List list = new LinkedList(inMap.entrySet());
  Collections.sort(list, new Comparator() {
    public int compare(Object o1, Object o2) {
      return ((Comparable) ((Map.Entry) (o1)).getValue()).compareTo(((Map.Entry) (o2)).getValue());
    }
  });
  if(isDescending) Collections.reverse(list);
  Map output = new LinkedHashMap();
  for (Iterator it = list.iterator(); it.hasNext();) {
    Map.Entry entry = (Map.Entry) it.next();
    output.put(entry.getKey(), entry.getValue());
  }
  return output;
}


static int getSum(Map<Integer,Integer> inMap){
  int output = 0;
  for(Integer key : inMap.keySet()){
    int value = (Integer) inMap.get(key);
    output += value;
  }
  return output;
}


static int getBestMatch(int inBase, int inMatchTo){
  int inMatch = 0;
  int count = 1;
  while(inMatch < inMatchTo){
    inMatch = inBase;
    count++;
    inMatch *= count;
  }
  int valCurrCount = count * inBase;
  int valPrevCount = (count-1) * inBase;
  int bufferA = abs(valPrevCount - inMatchTo);
  int bufferB = abs(valCurrCount - inMatchTo);
  if(bufferA < bufferB) return count-1;
  else return count;
}
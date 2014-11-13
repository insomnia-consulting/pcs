package com.pacytology.pcs;

public class FileMap<K, V, N> 
{
  private final K k;
  private final V v;
  private final N n;
   
  public FileMap(K key, V value, N name) {
    k = key;
    v = value;
    n = name;
  }
 
  public String toString() {
    return String.format("KEY: '%s', VALUE: '%s', NAME: '%s'", k, v, n);
  }
  public K getOne(){
	  return this.k;
  }
  public V getTwo() {
	  return this.v;
  }
  public N getThree() {
	  return this.n;
  }
   
}
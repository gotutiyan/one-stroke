class Cyber{
  int n;
  float size[]=new float[2];
  float deg[],add_deg[];
  PVector pos[];
  float noise_seed[];
  Cyber(int n, float size1, float size2){
    this.n=n;
    deg=new float[n];
    add_deg=new float[n];
    noise_seed=new float[n];
    pos=new PVector[n];
    for(int i=0;i<n;i++)pos[i]=new PVector(0,0);
    
    this.size[0]=size1;
    this.size[1]=size2;
    for(int i=0;i<n;i++){
      deg[i]=random(0,361);
      add_deg[i]=radians(random(0.1,2.0));
      noise_seed[i]=random(10000);
    }
  }
  
  void show(){
    for(int i=0;i<n;i++){
     float noi=map(noise(noise_seed[i]),0,1,-20,20);
     pos[i].x=(size[i/(n/2)]+noi)*cos(deg[i]); 
     pos[i].y=(size[i/(n/2)]+noi)*sin(deg[i]);
     deg[i]+=add_deg[i];
     noise_seed[i]+=0.01;
    }
    stroke(#FFFFFF);
    for(int i=0;i<n;i++){
      for(int j=i+1;j<n;j++){
        if(pos[i].dist(pos[j])<80){
          strokeWeight(map(pos[i].dist(pos[j]),0,80,0,3));
          line(pos[i].x,pos[i].y,pos[j].x,pos[j].y); 
        }
      }
    }
    strokeWeight(1);
    stroke(100);
  }
}
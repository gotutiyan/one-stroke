class Make_stage{
  int n;
  int stage[][]=new int[10][10];
  int degree[][]=new int[10][10];
  Make_stage(int _n){
    n=_n; 
    for(int i=0;i<n;i++)
      for(int j=0;j<n;j++)
        stage[i][j]=0;
  }
  
  //障害物を設置する
  //input1 設置したい障害物の個数
  void set_obj(int num){
   for(int i=0;i<n;i++)
     for(int j=0;j<n;j++)
       stage[i][j]=0;
   for(int i=0;i<num;i++){
    boolean ok=put_obj();
    if(!ok)return;
   }
   return;
  }
  
  
  //今の状態から、ランダムに障害物を設置する
  boolean put_obj(){
    int sy=int(random(n));
    int sx=int(random(n));
    int dx[]={0,1,0,-1};
    int dy[]={1,0,-1,0};
    for(int i=sy;i<sy+n;i++){ //どこに２を置くか全探索
     for(int j=sx;j<sx+n;j++){
       if(stage[i%n][j%n]==2)continue;
       stage[i%n][j%n]=2;
       
       for(int p=0;p<n;p++){ //次数テーブルの構築
        for(int q=0;q<n;q++){
          if(stage[p][q]==2){
            degree[p][q]=-1;
            continue;
          }
          int ct=0;
          for(int idx=0;idx<4;idx++){
            int nx=q+dy[idx];
            int ny=p+dx[idx];
            ct+=grid_score(nx,ny);
          }
          degree[p][q]=ct;
        }
       }
       
       if(f())return true;
       println("failed to find path");
       stage[i%n][j%n]=0;
      
     }
    }
    return false;
  }
  //次数テーブルを元に、それが一筆書きできるものか判定
  boolean f(){
    int dx[]={1,0,-1,0};
    int dy[]={0,1,0,-1};
    //int dx[]={0,1,0,-1};
    //int dy[]={-1,0,1,0};
   while(true){
     boolean finish=true;
     for(int i=0;i<n;i++){
      for(int j=0;j<n;j++){
         if(degree[i][j]>=3){
           for(int k=0;k<4;k++){
             int nx=j+dx[k];
             int ny=i+dy[k];
             if(!in(nx,ny))continue;
             if(degree[ny][nx]>=2){
               degree[i][j]--;
               degree[ny][nx]--;
               finish=false;
               break;
             }
           }
         }
        }
      }
      //debug_print2();
      //println();
      if(finish)break;
   }
      
      int odd=0;
      for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
           if(degree[i][j]%2==1)odd++;
        }
      }
      if(odd!=0 && odd!=2)return false;
      if(bfs())return true;
      else return false;
   }
  
  //　座標が盤面内で、かつ障害マスでない
  int grid_score(int x,int y){
    int ret=0;
    if(0<=x&&0<=y&&x<n&&y<n){
      //ret++;
      if(stage[y][x]==0)ret++;
    }
    return ret;
  }
  
  
  //障害物の位置を格納したArrayListを取得
  ArrayList<PVector> get_obj(){
  ArrayList<PVector> ret=new ArrayList<PVector>();
  ArrayList<PVector> ones=new ArrayList<PVector>();
  ArrayList<PVector> twos=new ArrayList<PVector>();
  debug_print2();
   for(int i=n-1;i>=0;i--)
     for(int j=n-1;j>=0;j--)
       if(degree[i][j]==1){
         ones.add(new PVector(j,i));
       }else if(degree[i][j]==2){
         twos.add(new PVector(i,j));
       }
   if(ones.size()>0){
     stage[int(ones.get(0).y)][int(ones.get(0).x)]=2;
     if(!bfs()){
       stage[int(ones.get(0).y)][int(ones.get(0).x)]=0;
       ret.add(new PVector(int(ones.get(1).x),int(ones.get(1).y)));
     }else {
       stage[int(ones.get(0).y)][int(ones.get(0).x)]=0;
       ret.add(new PVector(int(ones.get(0).x),int(ones.get(0).y)));
     }
   }else {
     int idx=int(random(0,twos.size()));
     ret.add(new PVector(int(twos.get(idx).x), int(twos.get(idx).y)));
   }
   
   for(int i=0;i<n;i++){
    for(int j=0;j<n;j++){
      if(stage[i][j]==2)ret.add(new PVector(j,i));
    }
   }
   //全ての頂点が偶点であるとき、左上を始点とする
   if(ret.size()==0)ret.add(new PVector(0,0));
   return ret;
  }
  
  boolean in(int x,int y){
   return (0<=x&&0<=y&&x<n&&y<n); 
  }
  
  boolean bfs(){
    int dx[]={1,0,-1,0};
    int dy[]={0,1,0,-1};
     boolean visited[][]=new boolean[10][10];
      for(int i=0;i<n;i++)
        for(int j=0;j<n;j++)
          visited[i][j]=false;
      for(int i=0;i<n;i++){
       for(int j=0;j<n;j++){
         if(stage[i][j]==0){
           ArrayList<PVector> queue=new ArrayList<PVector>();
           queue.add(new PVector(j,i));
           visited[i][j]=true;
           while(queue.size()>0){
             PVector now=queue.get(0);
             queue.remove(0);
             for(int k=0;k<4;k++){
              int nx=int(now.x)+dx[k];
              int ny=int(now.y)+dy[k];
              if(in(nx,ny) && stage[ny][nx]==0 && !visited[ny][nx]){
                 queue.add(new PVector(nx,ny));
                 visited[ny][nx]=true;
              }
             }
           }
           
           for(int p=0;p<n;p++){
            for(int q=0;q<n;q++){
              if(stage[p][q]==0 && !visited[p][q]){
                return false;
              }
            }
           }
           return true;
         }
       }
      }
      return false;
  }
  
  void debug_print(){
   for(int i=0;i<n;i++){
    for(int j=0;j<n;j++){
     if(j>0)print(" ");
     print(stage[i][j]);
    }
    println();
   }
   println();
  }
  
  void debug_print2(){
    for(int i=0;i<n;i++){
     for(int j=0;j<n;j++){
      if(j>0)print(" ");
      print(degree[i][j]);
     }
     println();
    }
    println();
  }
  
  void set_size(int _n){
    this.n=_n;
  }
}

// <---------------------------------------------------------->
/*
class Make_stage{
  int n;
  int stage[][]=new int[10][10];
  int degree[][]=new int[10][10];
  Make_stage(int _n){
    n=_n; 
    for(int i=0;i<n;i++)
      for(int j=0;j<n;j++)
        stage[i][j]=0;
  }
  
  //障害物を設置する
  //input1 設置したい障害物の個数
  void set_obj(int num){
   for(int i=0;i<n;i++)
     for(int j=0;j<n;j++)
       stage[i][j]=0;
   for(int i=0;i<num;i++){
    boolean ok=put_obj();
    if(!ok)return;
   }
   return;
  }
  
  
  //今の状態から、ランダムに障害物を設置する
  boolean put_obj(){
    int sy=int(random(n));
    int sx=int(random(n));
    int dx[]={0,1,0,-1};
    int dy[]={1,0,-1,0};
    for(int i=sy;i<sy+n;i++){ //どこに２を置くか全探索
     for(int j=sx;j<sx+n;j++){
       if(stage[i%n][j%n]==2)continue;
       stage[i%n][j%n]=2;
       
       for(int p=0;p<n;p++){ //次数テーブルの構築
        for(int q=0;q<n;q++){
          if(stage[p][q]==2){
            degree[p][q]=-1;
            continue;
          }
          int ct=0;
          for(int idx=0;idx<4;idx++){
            int nx=q+dy[idx];
            int ny=p+dx[idx];
            ct+=grid_score(nx,ny);
          }
          degree[p][q]=ct;
        }
       }
       
       if(f())return true;
       println("failed to find path");
       stage[i%n][j%n]=0;
      
     }
    }
    return false;
  }
  //次数テーブルを元に、それが一筆書きできるものか判定
  boolean f(){
    int dx[]={1,0,-1,0};
    int dy[]={0,1,0,-1};
   while(true){
     boolean finish=true;
     for(int i=0;i<n;i++){
      for(int j=0;j<n;j++){
         if(degree[i][j]>=3){
           for(int k=0;k<4;k++){
             int nx=j+dx[k];
             int ny=i+dy[k];
             if(!in(nx,ny))continue;
             if(degree[ny][nx]>=2){
               degree[i][j]--;
               degree[ny][nx]--;
               finish=false;
               break;
             }
           }
         }
        }
      }
      //debug_print2();
      //println();
      if(finish)break;
   }
      
      int odd=0;
      for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
           if(degree[i][j]%2==1)odd++;
        }
      }
      if(odd!=0 && odd!=2)return false;
      
      boolean visited[][]=new boolean[10][10];
      for(int i=0;i<n;i++)
        for(int j=0;j<n;j++)
          visited[i][j]=false;
      for(int i=0;i<n;i++){
       for(int j=0;j<n;j++){
         if(stage[i][j]==0){
           ArrayList<PVector> queue=new ArrayList<PVector>();
           queue.add(new PVector(j,i));
           visited[i][j]=true;
           while(queue.size()>0){
             PVector now=queue.get(0);
             queue.remove(0);
             for(int k=0;k<4;k++){
              int nx=int(now.x)+dx[k];
              int ny=int(now.y)+dy[k];
              if(in(nx,ny) && stage[ny][nx]==0 && !visited[ny][nx]){
                 queue.add(new PVector(nx,ny));
                 visited[ny][nx]=true;
              }
             }
           }
           
           for(int p=0;p<n;p++){
            for(int q=0;q<n;q++){
              if(stage[p][q]==0 && !visited[p][q]){
                return false;
              }
            }
           }
           return true;
         }
       }
      }
      return false;
      
   }
  
  //　座標が盤面内で、かつ障害マスでない
  int grid_score(int x,int y){
    int ret=0;
    if(0<=x&&0<=y&&x<n&&y<n){
      //ret++;
      if(stage[y][x]==0)ret++;
    }
    return ret;
  }
  
  
  //障害物の位置を格納したArrayListを取得
  ArrayList<PVector> get_obj(){
    ArrayList<PVector> ret=new ArrayList<PVector>();
   for(int i=n-1;i>=0;i--)
     for(int j=n-1;j>=0;j--)
       if(degree[i][j]%2==1 && ret.size()==0){
         ret.add(new PVector(j,i));
         break;
       }
   for(int i=0;i<n;i++){
    for(int j=0;j<n;j++){
      if(stage[i][j]==2)ret.add(new PVector(j,i));
    }
   }
   //全ての頂点が偶点であるとき、左上を始点とする
   if(ret.size()==0)ret.add(new PVector(0,0));
   return ret;
  }
  
  boolean in(int x,int y){
   return (0<=x&&0<=y&&x<n&&y<n); 
  }
  
  void debug_print(){
   for(int i=0;i<n;i++){
    for(int j=0;j<n;j++){
     if(j>0)print(" ");
     print(stage[i][j]);
    }
    println();
   }
   println();
  }
  
  void debug_print2(){
    for(int i=0;i<n;i++){
     for(int j=0;j<n;j++){
      if(j>0)print(" ");
      print(degree[i][j]);
     }
     println();
    }
    println();
  }
  
  void set_size(int _n){
    this.n=_n;
  }
}
*/
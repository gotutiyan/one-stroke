import ddf.minim.*;

/*
moved[i][j]=0　塗ってないマス
moved[i][j]=1  塗ったマス
moved[i][j]=2  塗れないマス
*/
import processing.sound.*;
Minim minims,minimp,minim;
AudioPlayer sound,pop;
//SoundFile sound, pop;
SoundButton mute;
Cyber cy,cy1;
Make_stage ms=new Make_stage(2);
int n=2, frameX=50, frameY=150;
float leng=500.0/n;
int moved[][]=new int[10][10];
int stage=0;
ArrayList<PVector> prev=new ArrayList<PVector>();
int prevx=0, prevy=-1;
boolean cleared=false,isdelay=false;
int delay_start=0;
ArrayList<PVector> obs=new ArrayList<PVector>();
PImage title_info,title;

void setup() {
  size(600, 700);
  resize_parameter();
  
  minim=new Minim(this);
  sound=minim.loadFile("voice1.wav");
  sound.loop();
  pop=minim.loadFile("pop.wav");
  pop.setLoopPoints(170,250);
  pop.loop();
  pop.mute();
  
  mute = new SoundButton(width-100,10,90,90,#EEEEEE);
  title_info=loadImage("info1.png");
  title=loadImage("title.png");
  cy=new Cyber(30,120,200);
  cy1=new Cyber(30,120,200);
  textSize(50);
  stroke(100);
  
  init();
}

void draw() {
  background(100);
  textSize(30);
  fill(255);
  if(stage>0)text("push 'R' to generate new stage.",100,height-10);
  textSize(50);
  mute.move();
  fill(255);
  
  if(stage==0){
    image(title_info,width/2-150,10,300,300);
    image(title,185,575,240,120);
  }
  else {
    if(stage%5==0){
      pushMatrix();
      translate(width/2,height/2+50);
      cy.show();
      popMatrix();
    }
    text("stage"+stage,200,100);
  }
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      if (moved[i][j]==0)fill(255);
      else if(moved[i][j]==1)fill(255,0,0,100);
      else if(moved[i][j]==2)fill(100);
      rect(frameX+i*leng, frameY+j*leng, leng, leng);
    }
  }
  
  
  clear_performance();
}

void mouseDragged() {
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      if(cleared)break;
      if (frameX+i*leng<=mouseX && mouseX<=frameX+(i+1)*leng &&  frameY+j*leng<=mouseY && mouseY<=frameY+(j+1)*leng) {
        if ((prevx!=i || prevy!=j)&&(abs(i-prevx)+abs(j-prevy)>1))continue;
        if ((prevx!=i || prevy!=j)&&abs(i-prevx)+abs(j-prevy)==1) {
          if (moved[i][j]==0) {
            prev.add(new PVector(i, j));
          } else if(moved[i][j]==1){
            while (true) {
              if (prev.size()==0)break;
              PVector now=prev.get(prev.size()-1);
              if (now.x==i && now.y==j)break;
              else {
                moved[(int)now.x][(int)now.y]=0;
                prev.remove(prev.size()-1);
              }
            }
          }
          if(moved[i][j]!=2){
            moved[i][j]=1;
            prevx=i;
            prevy=j;
          }
          if(isClear()){
            cleared=true;
            fill(255,0,0,100);
            rect(frameX+i*leng,frameY+j*leng,leng,leng);
            pop.unmute();
          }
        }
      }
    }
  }
}

/*
盤面がクリア済みかどうか判定する
*/
boolean isClear() {
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      if (moved[i][j]==0)return false;
    }
  }
  return true;
}

/*
クリアした時に呼べば、クリア演出ができる
*/
void clear_performance(){
  if(!cleared)return;
  if((frameCount%3==1 || frameCount%3==0))return;
  
  if(prev.size()==0){
   cleared=false;
   stage++;
   resize_parameter();
   init();
   pop.mute();
   return;
  }
  PVector now=prev.get(prev.size()-1);
  moved[(int)now.x][(int)now.y]=0;
  prev.remove(prev.size()-1);
  return;
}

/*
盤面情報を生成する。stage番目のArrayListに格納されている障害マス情報を読み取り、反映
*/
void init() {
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      moved[i][j]=0;
    }
  }
  if(stage==0){
    obs.add(new PVector(0,0));
  }
  for(int i=1;i<obs.size();i++){
    PVector p=obs.get(i);
    moved[(int)p.x][(int)p.y]=2;
  }
  PVector start=obs.get(0);
  moved[(int)start.x][(int)start.y]=1;
  prevx=(int)start.x;
  prevy=(int)start.y;
  //d();
  
  return;
}

/* debug出力 */
void d(){
 for(int i=0;i<n;i++){
  for(int j=0;j<n;j++)print(moved[i][j]); 
  println();
 }
 println();
}

/*
ステージによりマス目の数が変わるので、そこの処理
*/
void resize_parameter(){
   int num_obs=5;
   if(stage==0)n=2;
   else if(stage<6)n=5;
   else if(stage<13)n=6;
   else if(stage<19)n=7;
   else if(stage<21)n=8;
   else n=int(random(5,9));
   num_obs=5+3*(n-5);
   leng=500.0/n;
   if(stage==0) {
     leng=100;
     frameX=200;
     frameY=350;
   }else {
     frameX=50;
     frameY=150;
   }
   ms.set_size(n);
   if(stage!=0){
     ms.set_obj(num_obs);
     obs=ms.get_obj();
   }
   ms.debug_print();
   ms.debug_print2();
}

/* 
n*nのサイズの盤面を生成  
intput 1 : 盤面サイズ
*/
int[][] generate_stage(int n){
   int v[][]=new int[n][n];
   for(int i=0;i<n;i++)for(int j=0;j<n;j++)v[i][j]=0;
   return v;
}

void mousePressed(){
  if(mute.x<=mouseX && mouseX<=mute.w+mute.x && mute.y<=mouseY && mouseY<=mute.y+mute.h){
   if(!sound.isMuted())sound.mute();
   else {
     sound=minim.loadFile("voice1.wav");
     sound.loop();
   }
  }
}

void mouseReleased() {
  if(cleared)return;
  init();
  prev.clear();
}

void keyPressed(){
 if(key==ESC){
   minim.stop();
   exit();
 }
 if(key=='r'){
    println("pushed_ R");
    ms.set_obj(5);
    obs=ms.get_obj();
    init();
 }
}
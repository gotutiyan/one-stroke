class SoundButton{
  int x,y,w,h;
  color c;
  PImage mute,play;
 SoundButton(int x, int y, int w, int h, color c) {
   this.x=x; this.y=y; this.w=w; this.h=h; this.c=c;
   mute=loadImage("mute1.png");
   play=loadImage("play1.png");
 }
 
 void move(){
   fill(c);
   rect(x,y,w,h);
   if(!sound.isMuted())image(mute,x,y,w,h);
   else image(play,x,y,w,h);
 }
}
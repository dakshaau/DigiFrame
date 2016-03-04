
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import net.silentlycrashing.gestures.*;
import net.silentlycrashing.gestures.preset.*;
import net.silentlycrashing.util.*;

import jp.nyatla.nyar4psg.*;
import codeanticode.gsvideo.*;
import javax.swing.ImageIcon;

int ino=1;
int state=0,mode=0;
int alpa=255;
GestureAnalyzer brain;
PostGestureListener lft;
PostGestureListener rht;
PostGestureListener zin;
PostGestureListener zout;
GSCapture cam;
MultiMarker mak;
PImage x,i,img,icon;
float zm=0.20f,rot=0.01f;
AudioPlayer player;
Minim minim;

void setup(){
  size(640,480,P3D);
  cam=new GSCapture(this,640,480);
  cam.start();
  frame.setTitle("DigiFrame");
  ImageIcon titlebaricon = new ImageIcon(loadBytes("icon.png"));
  frame.setIconImage(titlebaricon.getImage());
  mak=new MultiMarker(this,width,height,"camera_para.dat",NyAR4PsgConfig.CONFIG_PSG);
  mak.addARMarker("DG",80);
  mak.addARMarker("prev",80);
  mak.addARMarker("next",80);
  mak.addARMarker("zin",80);
  mak.addARMarker("zout",80);
  img=loadImage(ino+".jpg");
  brain=new MouseGestureAnalyzer(this);
  brain.setVerbose(true);
  lft=new PostGestureListener(this,brain,"^(L)$");
  lft.registerOnAction("prevImage",this);
  rht=new PostGestureListener(this,brain,"^(R)$");
  rht.registerOnAction("nextImage",this);
  zin=new PostGestureListener(this,brain,"^(U)$");
  zin.registerOnAction("zoomIn",this);
  zout=new PostGestureListener(this,brain,"^(D)$");
  zout.registerOnAction("zoomOut",this);
  minim=new Minim(this);
  player=minim.loadFile("audio.mp3",6144);
  player.play();
  player.loop();
}
void draw(){
  if (cam.available() !=true) {
      return;
  }
  cam.read();
  mak.detect(cam);
  background(cam);
  mak.drawBackground(cam);//frustumを考慮した背景描画
  if(mak.isExistMarker(0)){
    if(!mak.isExistMarker(1)){
      prevImage();
    }
    else if(!mak.isExistMarker(2)){
      nextImage();
    }
    else if(!mak.isExistMarker(3)){
      zoomIn();
    }
    else if(!mak.isExistMarker(4)){
      zoomOut();
    }
    mak.beginTransform(0);
    smooth();
    rotate(1.5*PI);
    scale(zm,zm,1);
    tint(255,alpa);
    if(state==1){
      if(alpa>0){
        alpa-=35;
        if(alpa<0)
          alpa=0;
      }
      else
        loadImg(mode);
    }
    if(state==2)
    {
       if(alpa<255){
         alpa+=35;
         if(alpa>255)
           alpa=255;
       }
       else{
         mode=0;
         state=0;
       }
    }
    image(img,-(img.width/2),-(img.height/2));
    mak.endTransform();
  }
}

public void prevImage(){
  mode=1;
  state=1;
}
public void nextImage() {
  mode=2;
  state=1;  
}
public void loadImg(int mode){//1 for previous 2 for next
  switch(mode)
  {
     case 1:
     if(ino>1)
      ino--;
     img=loadImage(ino+".jpg");
     break;
     
     case 2:
     if(ino<51)
       ino++;
     img=loadImage(ino+".jpg");
     break;
  }
  //zm=0.2;
  state=2;
}
public void zoomIn(){
  if(zm<=3)
    zm+=0.01;
}
public void zoomOut(){
  if(zm>=0.1)
    zm-=0.01;
}
void stop()
{
  player.close();
  minim.stop();
  super.stop();
}

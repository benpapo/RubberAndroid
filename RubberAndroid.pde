
// rubber banding example
import android.os.Vibrator;
import android.content.Context;
import android.media.MediaPlayer;
import android.content.res.AssetFileDescriptor;
import android.app.Activity;
import android.content.Intent;
import android.os.Environment;
import android.graphics.Bitmap;
import java.io.FileOutputStream;
import android.view.View;
import android.widget.Toast;
import android.provider.MediaStore;
import android.widget.ImageView;
import android.os.Bundle;
import android.net.Uri;
import java.io.File;
import android.support.v4.content.FileProvider;

static final int PICK_FILE_REQUEST = 100;
static final int RESULT_OK = -1;
static final int RESULT_CANCELED = 0;
static final int REQUEST_IMAGE_CAPTURE = 1;

float sX, sY, tmpX, tmpY;
ArrayList <Rect> rects;
boolean positioning;
int rectIndex;
Table table;
PImage webImg;

// media player
MediaPlayer mp;
Context context; 
Activity act;
AssetFileDescriptor afd;

//======================================

void setup() {

  // init canvas
  fullScreen();
  colorMode(HSB, 360,100,100);
  background(255);
  stroke(1);
  strokeWeight(2);
  positioning = false;

  // rect array list
  rects = new ArrayList<Rect>();
  
  // init media player
  act = this.getActivity();
  context = act.getApplicationContext();

  try {
    mp = new MediaPlayer();
    afd = context.getAssets().openFd("test.mp3");
    mp.setDataSource(afd.getFileDescriptor());
    mp.prepare();
  } 

  catch(IOException e) {
    println("mp3 file did not load");
  }
  
  // load rects csv
  loadRectCSV();
  
  // String url = "https://processing.org/img/processing-web.png"; 
  // Load image from a web server 
  // webImg = loadImage(url);
  
  // play welcome sound
  mp.start();
}

//======================================

void loadRectCSV() {
  
  // check if file exists
  String csvFileName = new String(Environment.getExternalStorageDirectory().getAbsolutePath() + "/rect.csv");
  
  File csvFile = new File( csvFileName );
  if( ! csvFile.exists() ) {
    // create empty table
    table = new Table();
    table.addColumn( "x" );
    table.addColumn( "y" );
    table.addColumn( "width" );
    table.addColumn( "height" );
  } else {
    // load rect csv file
    try {
      table = loadTable( csvFileName,"header");
    
      // create rect array
      for (int i = 0; i<table.getRowCount(); i++) {
        TableRow row = table.getRow(i); 
        float x = row.getFloat("x"); 
        float y = row.getFloat("y"); 
        float w = row.getFloat("width"); 
        float h = row.getFloat("height");
        rects.add(new Rect(x,y,w,h));
      }
    }
  
    catch(Exception e) 
    {
      e.printStackTrace();
    }
  }
}

//======================================

void mousePressed() {

  // rubber band rect
  sX = mouseX;
  sY = mouseY;
  tmpX = mouseX;
  tmpY = mouseY;
  
  // are we moving an existing rect?
  for (int i = rects.size() - 1; i >= 0; i--) {
    Rect r = rects.get(i);
    if (mouseX >= r.x && mouseX <= (r.x+r.w) && mouseY >= r.y && mouseY <= (r.y+r.h) ) {
      positioning = true;
      rectIndex = i;
      vibrate(50);
      
      // toast text
      act.runOnUiThread(new Runnable() { 
        public void run() { 
          Toast.makeText(act, "Moving...", Toast.LENGTH_SHORT).show(); 
        } 
      });
      break;
    }
  }
}

//======================================

void mouseDragged() {
  
  // rubber banding
  if( ! positioning ) {
    if(mouseX < sX ) {
      tmpX = mouseX;
    }
  
    if(mouseY < sY ) {
      tmpY = mouseY;
    }    
  } else {
    // moving existing rect
    Rect r = rects.get(rectIndex);
    r.x -= tmpX-mouseX;
    r.y -= tmpY-mouseY;
    tmpX = mouseX;
    tmpY = mouseY;
    
    // update table row
    TableRow row = table.getRow( rectIndex );
    row.setFloat( "x", r.x );
    row.setFloat( "y", r.y );
  }
}

//======================================

void mouseReleased() {
   
  // add new rect to list
  if( ! positioning ) {
    // prevent slivers
    float w = abs(sX-mouseX);
    float h = abs(sY-mouseY);
    if( w > 10 && h > 10 ) {
      rects.add(new Rect(tmpX,tmpY,w,h));
      TableRow row = table.addRow();
      row.setFloat("x",tmpX);
      row.setFloat("y",tmpY);
      row.setFloat("width",w);
      row.setFloat("height",h);
    }
  } else {
    // delete rect from list
    if( mouseX > width-40 || mouseX < 40 ) {
      for (int i = rects.size() - 1; i >= 0; i--) {
        Rect r = rects.get(i);
        if (mouseX >= r.x && mouseX <= (r.x+r.w) && mouseY >= r.y && mouseY <= (r.y+r.h) ) {
          rects.remove(i);
          table.removeRow(i);
          break;
        }
      }
    }
  }
  
  // vibrate phone
  //vibrate(50);
  positioning = false;
}

//======================================

void vibrate(int millis) {
  Vibrator v;
  v = (Vibrator)act.getSystemService( Context.VIBRATOR_SERVICE);
  v.vibrate(millis);
}

//======================================

void draw() {
  
  // clear
  background(255);
  //image( webImg,0,0);
  
  // draw rect list
  for (int i = 0; i < rects.size(); i++ ) {
    Rect r = rects.get(i);
    r.display();
  }
  
  // draw rubber band rect
  if( mousePressed && ! positioning ) {
    // draw temp rubber rect
    noFill();
    rect(tmpX,tmpY,abs(sX-mouseX),abs(sY-mouseY));
  }
}

//======================================

void onStart() {
  super.onStart();
  try {
    // play sound
    //mp.seekTo(0);
    //mp.start();
  }
  
  catch(Exception e) 
  {
    println("bad pointer" + e.getMessage());
  }
}

//======================================

void onDestroy() {
  super.onDestroy();
  mp.release();
}

//======================================

void onStop() {
  println("table count " + table.getRowCount());
  super.onStop();
  
  String csvFileName = new String(Environment.getExternalStorageDirectory().getAbsolutePath() + "/rect.csv");
  saveTable( table, csvFileName );
  println( csvFileName );

}

//======================================


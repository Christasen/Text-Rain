/**
    Text Rain
    Copyright (c) 2018 Guangyu Yan,  University of Minnesota.
**/


import processing.video.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;
boolean debug_mode = false;
int p_thrd = 128, sec = 0;


void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
}

Text chars = new Text();
int y = 0;

void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.

  
  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable
  
  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);
  }
  else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
  }


  // Fill in your code to implement the rest of TextRain here..

  // Tip: This code draws the current input image to the screen
  set(0, 0, inputImage);
  // Filp the image
  if (cam != null )
  {
    loadPixels(); // setting up pixels
    filter(GRAY);
    for (int y = 0; y < height;  ++y){
      for (int x = 0; x < width/2; ++x)
      {
        color c = pixels[x+y+width];
        pixels[x+y+width] = pixels[(width-x-1)+y*width];
        pixels[(width-x-1)+y*width] = c;
      }
    }
    updatePixels();  // update the pixels
  }
  
  //if(debug_mode) Debug();
  if ( sec == 0)
  {
    sec = 20;
    chars.generate();
  }
  chars.Draw();
  --sec;
   

}

class Text{
private  
  int[] x_, y_; // These two contains all the positions of texts
  float[] v_; // Velocity of characters
  int time_; // Default time
  char[] char_; // Characters
  int numbers_; // Number of characters
  int std_length = 10; // Shown length of text
  color[] color_; // Color of character.
  String std_sentence = "UniversityofMinnesotaTwinCities"; // Could be user customized here;
public
  // Constructors
  Text(){
    numbers_ = 0;
    x_ = new int[1];
    y_ = new int[1];
    char_ = new char[1];
    color_ = new color[1];
    v_ = new float[1];
    time_ = second();
  }
  
  Text(int n){
    numbers_ = 0;
    x_ = new int[1];
    y_ = new int[1];
    char_ = new char[1];
    //color_ = new color[1];
    v_ = new float[n+1];
    time_ = second();
  }
  
  char get_char(int i) { return char_[i]; } 
 
  int get_y(int i) { return y_[i]; } 
  
  int get_x(int i) { return x_[i]; } 
  
  int get_size(){ return numbers_; }
  
  color get_color(int i) { return color_[i];}
  
  void change_text (int n){
    std_length += n;
    if(std_length < 1) std_length = 1;
    if(std_length > 31) std_length = 31;
  }
  
  // Updating the position of characters
  void update(){
    loadPixels();
    for (int i = 0; i <= numbers_; ++i)
    {
      if (y_[i] >= height) char_[i] = '\0';
      if (char_[i] != '\0')
      {
        int half = int(textWidth(char_[i])/2);
        int bottom_of_character = x_[i] + (y_[i] + half)*width;
       // int up_of_character = x_[i] - (y_[i] + half)*width;
        while( bottom_of_character >= pixels.length ) bottom_of_character -= width;
        if( pixels[bottom_of_character] >= color(p_thrd, p_thrd, p_thrd) )
        {
          if ( time_ != second() )
          {
            time_ = second();
            v_[i] = v_[i] + 9.81;
          }
          y_[i] += int(v_[i]/60);
        }
        else
        {
          while( pixels[bottom_of_character] < color(p_thrd, p_thrd, p_thrd) )
          {
            if ((bottom_of_character - width) < 0) break;
             bottom_of_character -= width;
          }
          y_[i] = ( bottom_of_character -x_[i])/width -half;
        }
      }
    }
    updatePixels();  
 }
  
  // generate a new charater from the texyt
  void generate()
  {
    ++numbers_;
    char_ = append( char_, std_sentence.charAt(int(random(std_length))));
    x_ = append(x_, int(random(width)));
    y_ = append(y_, 0);
    color_ = append(color_, color(int(random(256)), int(random(256)), int(random(256))) );
    v_ = append(v_, random(1, 6)*60);
  }
  
  // Drawing characters on the screen
  void Draw()
  {
    for( int i = 0; i < numbers_; ++i)
    {
      if (char_[i] != '\0')
      {
        fill(color_[i]);
        text(char_[i], x_[i], y_[i]);
      }
    }
    update();
  }
}

void keyPressed() {
  
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..
  
  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
     p_thrd ++;
    }
    else if (keyCode == DOWN) {
      // down arrow key pressed
      p_thrd --;
    }
    else if (keyCode == LEFT) {
  // left arrow key pressed
    chars.change_text(-1);
  }
    else if (keyCode == RIGHT) {
    // right arrow key pressed
    chars.change_text(1);
  }
  }

  
}

//Mux_Shield_DigitalOut_Example
//http://mayhewlabs.com/arduino-mux-shield

/*
This example shows how to output high or low on all 48 pins.  To use the analog pins as digital, we use
pin numbers 14-16 (instead of analog numbers 0-2). 

To simplify this code further, one might use nested for loops or function calls.
*/

//Give convenient names to the control pins
#define CONTROL0 5    //MUX control pin 0 (S3 is connected to Arduino pin 2)
#define CONTROL1 4
#define CONTROL2 3
#define CONTROL3 2

#define WIDTH 8
#define HEIGHT 6

//State machine states
enum{
  STATE_0 = 0,
  STATE_1 = 1
};

int screen[WIDTH][HEIGHT];

unsigned long stateStart;
unsigned long stateEnd;
unsigned long t;
unsigned long t_start;
unsigned long t_end;
unsigned long dt;
int gx;

int testState=STATE_0;

void setup()
{
  /*Serial.begin(9600);*/
  /*Serial.println("Hello world");*/
  /*delay(2000);// Give reader a chance to see the output.*/

  gx = 0;
  t = 0;
  t_start = 0;
  t_end = 0;
  dt = 1000;

  randomSeed(analogRead(0));

  //Set MUX control pins to output
  pinMode(CONTROL0, OUTPUT);
  pinMode(CONTROL1, OUTPUT);
  pinMode(CONTROL2, OUTPUT);
  pinMode(CONTROL3, OUTPUT);

  pinMode(14, OUTPUT);
  pinMode(15, OUTPUT);
  pinMode(16, OUTPUT);

  screen_init(screen);
}
  

void loop()
{

  screen_step(screen);

  display_reset();
  screen_draw(screen);
}

void screen_draw(int m[WIDTH][HEIGHT])
{
  for(int x=0; x < WIDTH; ++x)
    for(int y=0; y < HEIGHT; ++y)
      if(m[x][y] > 0)
        setPin(y*WIDTH + x);

}

void display_reset()
{
  pinMode(14, INPUT);
  pinMode(15, INPUT);
  pinMode(16, INPUT);
  
  pinMode(14, OUTPUT);
  pinMode(15, OUTPUT);
  pinMode(16, OUTPUT);
}

void screen_step(int m[WIDTH][HEIGHT])
{
    if(millis() > t_end){
      t_start = millis();
      t_end = t_start + dt;

      game_of_life(m, WIDTH, HEIGHT);
    }
}

void screen_init(int m[WIDTH][HEIGHT])
{
  for(int i=0; i<WIDTH; ++i)
    for(int j = 0; j < HEIGHT; j++)
      m[i][j] = random() % 2;


      /*m[1][0] = 1;*/
      /*m[2][0] = 1;*/
      /*m[3][0] = 1;*/
}

void setMuxAndPin(int mux, int pin, int value)
{
  digitalWrite(CONTROL0, (pin&15)>>3); //S3
  digitalWrite(CONTROL1, (pin&7)>>2);  //S2
  digitalWrite(CONTROL2, (pin&3)>>1);  //S1
  digitalWrite(CONTROL3, (pin&1));     //S0

  digitalWrite(14+mux, value);
  delay(1);

  digitalWrite(14+mux, LOW);

}

void setPin(int pin)
{
  int mux = pin/16;
  int p = pin%16;
  setMuxAndPin(mux, p, HIGH);
}


void game_of_life(int h[WIDTH][HEIGHT], int row, int col)
{
  int tmp[WIDTH][HEIGHT];

  for(int x=0; x < WIDTH; ++x)
    for(int y=0; y < HEIGHT; ++y)
      tmp[x][y] = 0;

  for(int x=0; x < WIDTH; ++x)
  {
    for(int y=0; y < HEIGHT; ++y)
    {
      int neighbors = 0;

      for(int i=-1; i<2; i++)
      {
        for(int j=-1; j<2; ++j)
        {
          if((i == 0 && j == 0) || x+i < 0 || x+i >= WIDTH || y+j < 0 || y+j >= HEIGHT)
            continue;

          if(h[x+i][y+j] > 0)
            ++neighbors;
        }
      }

      // Live cell
      if(h[x][y] > 0)
      {
        if(neighbors < 2)
          tmp[x][y] = 0;
        else if(neighbors > 3)
          tmp[x][y] = 0;
        else if(neighbors == 2 || neighbors == 3)
          tmp[x][y] = 1;
      }
      // Dead cell
      else
      {
        if(neighbors == 3)
          tmp[x][y] = 1;
      }
    }
  }

  for(int x=0; x < WIDTH; ++x)
    for(int y=0; y < HEIGHT; ++y)
      h[x][y] = tmp[x][y];
}





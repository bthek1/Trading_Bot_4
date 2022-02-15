//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property copyright "Copyright 2014-2020, Orchard Forex"
#property link      "https://orchardforex.com"
#property version   "1.02"
#property strict
#property indicator_chart_window

#property indicator_buffers 8

#include "ao_reader.mqh";
#include "rectangle.mqh"
#include "arrow.mqh"
#include "rsi_reader.mqh"

input    int            SignalMAPeriod    =  5;          // Signal period
input    int            FastMAPeriod      =  13;         // Fast period
input    int            SlowMAPeriod      =  34;         // Slow period
input    int            AO_buyrange      =  0;        //buy when sell than
input    int            AO_sellrange     =  0;       //sell when sell than
input    ENUM_MA_METHOD MAMethod          =  MODE_EMA;   // MA Mode

double   BufferUp[];
double   BufferDown[];

double   BufferFast[];
double   BufferSlow[];

#define  UpIndicator    0
#define  SlowIndicator  1
#define  DownIndicator  2
#define  FastIndicator  3


double up[];
double down[];

#define UP 4
#define DOWN 5


double recname[];
double reccolor[];
#define RECNAME 6
#define RECCOLOR 7

#define UPARROW 233
#define DOWNARROW 234
#define ARROWSHIFT 15


int line, count;
double objopen;
double namecount;
enum region {notrade, buy, sell, trade};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
   ChartRedraw();
   show_nothing();

   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
   show_nothing();
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   int      limit;

   if(rates_total<=SlowMAPeriod)
      return(0);

   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(int i=limit-1; i>=0; i--) // alternative    for(i=0; i<limit; i++)
     {
      //moving_avg(i);
      // If none of the above the trend is not confirmed

      RSI_display(i, time[i], 30, 33, 65);
      //AO_check1(i, high[i], low[i], 50, 50);

     }
//--- return value of prev_calculated for next call
   return(rates_total);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {
   long start1 = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR, 0) -  ChartGetInteger(0, CHART_VISIBLE_BARS, 0) - 1000;
   long end = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR, 0)+1000;
   if(start1 < 0)
      start1 = 0;

   if(id==CHARTEVENT_CLICK)
     {
      line = 0;
      //Print("The coordinates of the mouse click on the chart are: x = ",lparam,"  y = ",dparam);
      //ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
      Print("off");
      show_nothing();

      for(long i = start1; i <= end; i++)
        {
         RectangleChange(0, DoubleToString(recname[i], 4), 0, clrBlack);
        }
      ChartRedraw();

     }

   if(id ==  CHARTEVENT_MOUSE_MOVE && sparam[0] == '1' && line == 0)
     {
     Print("on");
      show();
      for(long i = start1; i < end; i++)
        {
         RectangleChange(0, DoubleToString(recname[i], 4), 0, (color)reccolor[i]);
        }
      ChartRedraw();
      line = 1;
     }
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      //Alert("The mouse has been clicked on the object with name '"+sparam+"'");
     }
   if(id == CHARTEVENT_KEYDOWN)
     {
      if(lparam == 9)
        {
         Print("tap");
        }
      //Alert("yeah: x = ",lparam,"  y = ",dparam, " rest ", sparam);

      //ChartRedraw();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   count++;

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void show()
  {
   ChartSetInteger(0,CHART_COLOR_GRID, clrGoldenrod);

   SetIndexStyle(UP,DRAW_ARROW,STYLE_SOLID, 1, clrBlue);
   SetIndexArrow(UP, UPARROW);
   SetIndexBuffer(UP,  up, INDICATOR_CALCULATIONS);
   SetIndexLabel(UP,"UP");

   SetIndexStyle(DOWN,DRAW_ARROW,STYLE_SOLID, 1, clrRed);
   SetIndexArrow(DOWN, DOWNARROW);
   SetIndexBuffer(DOWN,  down, INDICATOR_CALCULATIONS);
   SetIndexLabel(DOWN,"DOWN");

//ChartSetInteger(0, CHART_COLOR_BACKGROUND, C'0,20,0');
   SetIndexStyle(UpIndicator,DRAW_HISTOGRAM, STYLE_SOLID, 3, clrGreen);
   SetIndexBuffer(UpIndicator, BufferUp, INDICATOR_DATA);
   SetIndexEmptyValue(UpIndicator,0.0);

   SetIndexStyle(SlowIndicator,DRAW_LINE,STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(SlowIndicator,BufferSlow, INDICATOR_DATA);
   SetIndexLabel(SlowIndicator,"Slow");

   SetIndexStyle(DownIndicator,DRAW_HISTOGRAM, STYLE_SOLID, 3, clrFireBrick);
   SetIndexBuffer(DownIndicator, BufferDown, INDICATOR_DATA);
   SetIndexEmptyValue(DownIndicator,0.0);

   SetIndexStyle(FastIndicator,DRAW_LINE,STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(FastIndicator,BufferFast, INDICATOR_DATA);
   SetIndexLabel(FastIndicator,"Fast");
  }
//+------------------------------------------------------------------+
void show_nothing()
  {
   ChartSetInteger(0,CHART_COLOR_GRID, clrGray);

   SetIndexStyle(UP,DRAW_NONE,STYLE_SOLID, 1, clrBlue);
   SetIndexArrow(UP, UPARROW);
   SetIndexBuffer(UP,  up, INDICATOR_CALCULATIONS);
   SetIndexLabel(UP,"UP");

   SetIndexStyle(DOWN,DRAW_NONE,STYLE_SOLID, 1, clrRed);
   SetIndexArrow(DOWN, DOWNARROW);
   SetIndexBuffer(DOWN,  down, INDICATOR_CALCULATIONS);
   SetIndexLabel(DOWN,"DOWN");

   SetIndexStyle(UpIndicator,DRAW_NONE, STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(UpIndicator, BufferUp, INDICATOR_CALCULATIONS);
   SetIndexEmptyValue(UpIndicator,0.0);

   SetIndexStyle(SlowIndicator,DRAW_NONE,STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(SlowIndicator,BufferSlow, INDICATOR_CALCULATIONS);
   SetIndexLabel(SlowIndicator,"Slow");

   SetIndexStyle(DownIndicator,DRAW_NONE, STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(DownIndicator, BufferDown, INDICATOR_CALCULATIONS);
   SetIndexEmptyValue(DownIndicator,0.0);

   SetIndexStyle(FastIndicator,DRAW_NONE,STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(FastIndicator,BufferFast, INDICATOR_CALCULATIONS);
   SetIndexLabel(FastIndicator,"Fast");

   SetIndexStyle(RECNAME,DRAW_NONE,STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(RECNAME,recname, INDICATOR_CALCULATIONS);
   SetIndexLabel(RECNAME,"recname");
   SetIndexEmptyValue(RECNAME,0.0);

   SetIndexStyle(RECCOLOR,DRAW_NONE,STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(RECCOLOR,reccolor, INDICATOR_CALCULATIONS);
   SetIndexLabel(RECCOLOR,"reccolor");
   SetIndexEmptyValue(RECCOLOR,0.0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

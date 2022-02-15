//+------------------------------------------------------------------+
//|                                                      Awesome.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "test"
#property strict

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3      //number of indcators on graph
#property  indicator_color1  Gold
#property  indicator_color2  Green
#property  indicator_color3  Red
//--- buffers

input string               Inpindix1   =  "SPX500";   //Trade comment - for information
input string               Inpindix2   =  "AUS200";   //Trade comment - for information


double     ExtAOBuffer[];
double     ExtUpBuffer[];
double     ExtDnBuffer[];
//---
#define PERIOD_FAST  1
#define PERIOD_SLOW 1
//--- bars minimum for calculation
#define DATA_LIMIT  34

#define DATA 0
#define UP 1
#define DOWN 2

int line;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit(void)
  {
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
//--- drawing settings
   SetIndexStyle(DATA,DRAW_LINE);
   SetIndexStyle(UP,DRAW_NONE);
   SetIndexStyle(DOWN,DRAW_NONE);
   IndicatorDigits(Digits+1);
   SetIndexDrawBegin(DATA,DATA_LIMIT);
   SetIndexDrawBegin(UP,DATA_LIMIT);
   SetIndexDrawBegin(DOWN,DATA_LIMIT);
//--- 3 indicator buffers mapping
   SetIndexBuffer(DATA,ExtAOBuffer);
   SetIndexBuffer(UP,ExtUpBuffer);
   SetIndexBuffer(DOWN,ExtDnBuffer);
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("TT");
   SetIndexLabel(UP,NULL);
   SetIndexLabel(DOWN,NULL);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
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

   int    i,limit=rates_total-prev_calculated;
   double prev=0.0,current;
//--- check for rates total
   if(rates_total<=DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   if(prev_calculated>0)
     {
      limit++;
      prev=ExtAOBuffer[limit];
     }
//--- macd
   for(i=0; i<limit; i++)
//      ExtAOBuffer[i]=iMA(Inpindix1,0,PERIOD_FAST,0,MODE_SMA,PRICE_MEDIAN,i)/
//                     iMA(Inpindix2,0,PERIOD_SLOW,0,MODE_SMA,PRICE_MEDIAN,i);
      ExtAOBuffer[i]=iAO(Inpindix1, 0, i)+
                     iAO(Inpindix2, 0, i);
      //ExtAOBuffer[i]   = round(iMA(Inpindix1,0,PERIOD_SLOW,0,MODE_SMA,PRICE_MEDIAN,i))/4000;            
//--- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtAOBuffer[i];
      if(current>prev)
         up=true;
      if(current<prev)
         up=false;
      if(!up)
        {
         ExtDnBuffer[i]=current;
         ExtUpBuffer[i]=0.0;
        }
      else
        {
         ExtUpBuffer[i]=current;
         ExtDnBuffer[i]=0.0;
        }
      prev=current;
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {
   if(id==CHARTEVENT_CLICK)
     {
      line = 0;
      //Print("The coordinates of the mouse click on the chart are: x = ",lparam,"  y = ",dparam);
      //ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
      ChartSetInteger(0,CHART_COLOR_GRID, clrGray);
      SetIndexStyle(DATA,DRAW_LINE);
      SetIndexStyle(UP,DRAW_NONE);
      SetIndexStyle(DOWN,DRAW_NONE);
     }

   if(id ==  CHARTEVENT_MOUSE_MOVE && sparam[0] == '1')
     {
      //Print("yeah: x = ",lparam,"  y = ",dparam, " rest ", sparam);
      if(line == 0)
        {
         //ChartSetInteger(0, CHART_COLOR_BACKGROUND, C'0,20,0');
         ChartSetInteger(0,CHART_COLOR_GRID, clrGoldenrod);
         SetIndexStyle(DATA,DRAW_ARROW);
         SetIndexStyle(UP,DRAW_NONE);
         SetIndexStyle(DOWN,DRAW_NONE);
        }
      line = 1;

     }
//  if(id == CHARTEVENT_OBJECT_CLICK)
//  {
//Alert("The mouse has been clicked on the object with name '"+sparam+"'");
//   }
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



//+------------------------------------------------------------------+

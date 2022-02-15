/***********
   MA Ribbon.mq4
   Copyright 2014-2020, Orchard Forex
   https://orchardforex.com

   Version History
   ===============
   1.00     Original version

   1.01     Minor code updates before releasing for download
            These should not affect the indicator at all and have been made only
            to keep the code tidy
   1.02     Minor adjustments for re-release under Orchard Forex label

***********/

#property copyright "Copyright 2014-2020, Orchard Forex"
#property link      "https://orchardforex.com"
#property version   "1.02"
#property strict
#property indicator_chart_window

#property indicator_buffers 2

input    int            SignalMAPeriod    =  5;          // Signal period
input    int            FastMAPeriod      =  13;         // Fast period
input    int            SlowMAPeriod      =  34;         // Slow period
input    ENUM_MA_METHOD MAMethod          =  MODE_EMA;   // MA Mode

double   BufferUp[];
double   BufferDown[];

#define  highv    0

#define  lowv  1




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);

   SetIndexStyle(highv,DRAW_LINE,STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(highv,BufferUp);
   SetIndexLabel(highv,"Slow");

   SetIndexStyle(lowv,DRAW_LINE,STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(lowv,BufferDown);
   SetIndexLabel(lowv,"Fast");


   return(INIT_SUCCEEDED);

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
   //double   signalMa,
   //         fastMa,
   //         slowMa;

   if(rates_total<=SlowMAPeriod)
      return(0);

   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(int i=limit-1; i>=0; i--) // alternative    for(i=0; i<limit; i++)
     {
     BufferUp[i] = high[i];
     BufferDown[i] = low[i];
     
     if(i == 0)
       {
        BufferUp[0] = Ask;
        BufferDown[0] = Bid;
       }
     /*
      signalMa=iMA(Symbol(), Period(), SignalMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
      fastMa=iMA(Symbol(), Period(), FastMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
      slowMa=iMA(Symbol(), Period(), SlowMAPeriod, 0, MAMethod, PRICE_CLOSE, i);



      if(signalMa>fastMa && fastMa>slowMa)  // trending up
        {
         BufferFast[i]=fastMa;
         BufferSlow[i]=slowMa;

         BufferUp[i]=fastMa;
        }
      else
         if(signalMa<fastMa && fastMa<slowMa)  // trending down
           {
            BufferFast[i]=fastMa;
            BufferSlow[i]=slowMa;

            BufferDown[i]=slowMa;
           }
      // If none of the above the trend is not confirmed
      */
     }

      
//--- return value of prev_calculated for next call
   return(rates_total);

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RSI_display(int i, datetime time, int period  = 30, int less_than = 40, int greater_than = 60)
  {
   double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, i);
//Alert(RSI, "  ", buycount, "  ", sellcount);
   if(RSI <= less_than)
     {
      if(!objopen)
        {
         objopen = 1;
         namecount++;
         recname[i] = namecount;
         reccolor[i] = (double)C'0,0,70';
         RectangleCreate(0,DoubleToString(namecount, 4),0,time,0,time,0, clrBlack);
        }
      else
        {
         RectanglePointChange(0,DoubleToString(namecount, 4), 1,time,0);
         ChartRedraw();

        }
     }
   else
      if(RSI > greater_than)
        {
         if(!objopen)
           {
            objopen = 1;
            namecount++;
            recname[i] = namecount;
            reccolor[i] = (double)C'100,0,0';
            RectangleCreate(0,DoubleToString(namecount, 4),0,time,0,time,0, clrBlack);
           }
         else
           {
            RectanglePointChange(0,DoubleToString(namecount, 4), 1,time,0);
           }
        }
      else
        {
         if(objopen)
           {
            RectanglePointChange(0,DoubleToString(namecount, 4), 1,time,0);

           }
         objopen = 0;
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void moving_avg(int i)
  {
   double signalMa=iMA(Symbol(), Period(), SignalMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
   double fastMa=iMA(Symbol(), Period(), FastMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
   double slowMa=iMA(Symbol(), Period(), SlowMAPeriod, 0, MAMethod, PRICE_CLOSE, i);

   up[i] = EMPTY_VALUE;
   down[i] = EMPTY_VALUE;

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


  }
//+------------------------------------------------------------------+

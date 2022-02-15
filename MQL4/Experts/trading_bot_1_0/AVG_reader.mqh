//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AVG_check1(int period, int shift)
  {
   double AVG1 = iMA(Symbol(),Period(),period,shift,MODE_EMA,PRICE_CLOSE,1);
   double AVG2 = iMA(Symbol(),Period(),period,shift,MODE_EMA,PRICE_CLOSE,2);

   if((fabs(AVG1 - AVG2))/AVG2 < 0.001)
     {
      //Alert(AVG1, "  trade  ",AVG2, "  ", (fabs(AVG1 - AVG2))/AVG2 );
      return trade;
     }
//Alert(AVG1, "  trade  ",AVG2, "  ", fabs(AVG1 - AVG2), "  no");
   return notrade;
  }
//+------------------------------------------------------------------+

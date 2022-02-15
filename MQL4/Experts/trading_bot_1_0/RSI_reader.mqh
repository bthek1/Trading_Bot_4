//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RSI_check1(int item, int period, int less_than, int greater_than, double multi)
  {
   double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, 1);
//Alert(RSI, "  ", buycount, "  ", sellcount);
   if(RSI <= (less_than-(multi*buycount)))
     {
      conditionvalues[item] = less_than - RSI;
      return buy;
     }
   else
     {
      if(RSI > (greater_than+(multi*sellcount)))
        {
         conditionvalues[item] = RSI - greater_than;
         return sell;
        }
     }
   conditionvalues[rsi1] = 0;
   return notrade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RSI_check2(int item, int period, int less_than, int greater_than, int rsi2_status)
  {
   double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, 0);
   if(RSI < less_than)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(RSI >= less_than && rsi2_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(RSI > greater_than)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(RSI <= greater_than && rsi2_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }
//+------------------------------------------------------------------+

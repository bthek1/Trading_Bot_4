//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MOCH_check1(int item, int fast, int slow, int sma, int moch_status)
  {
   double MAIN=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_MAIN, 1);
   double SIGNAL=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_SIGNAL, 1);

   if(MAIN < SIGNAL)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(MAIN >= SIGNAL && moch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(MAIN > SIGNAL)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(MAIN <= SIGNAL && moch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }

   return notrade;
//printf("reset %f \n ", STOCH);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MOCH_check2(int item, int fast, int slow, int sma)
  {
   double main=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_MAIN, 1);
   double signal=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_SIGNAL, 1);

   if(main > signal && main < 0)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buy;
     }

   if(main < signal && main > 0)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return sell;
     }

   return notrade;
//printf("reset %f \n ", STOCH);
  }
//+------------------------------------------------------------------+

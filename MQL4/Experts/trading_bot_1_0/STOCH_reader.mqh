//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int STOCH_check1(int item, int k, int d, int slowing, int less_than, int greater_than, int stoch_status)
  {
   double STOCH_MAIN = iStochastic(Symbol(), Period(), k, d, slowing, MODE_SMA, 0, MODE_MAIN, 1);
   double STOCH_SIG = iStochastic(Symbol(), Period(), k, d, slowing, MODE_SMA, 0, MODE_SIGNAL, 1);

   if(STOCH_MAIN < STOCH_SIG && STOCH_MAIN < less_than)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(STOCH_MAIN > STOCH_SIG && stoch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(STOCH_MAIN > STOCH_SIG && STOCH_MAIN > greater_than)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(STOCH_MAIN < STOCH_SIG && stoch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int STOCH_check2(int item, int k, int d, int slowing, int less_than, int greater_than, int stoch_status)
  {
   double STOCH = iStochastic(Symbol(), Period(), k, d, slowing, MODE_SMA, 0, MODE_MAIN, 1);

   if(STOCH < less_than)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(STOCH >= less_than && stoch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(STOCH > greater_than)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(STOCH <= greater_than && stoch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }

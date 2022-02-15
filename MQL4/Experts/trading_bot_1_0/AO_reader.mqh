//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AO_check1(double buyrange, double sellrange)
  {
   double AO[5] = {0,0,0,0,0};
   for(int i=0; i<5; i++)
     {
      AO[i] = iAO(Symbol(), Period(), i);
     }
   //Alert(AO[4]-AO[3], "  ", AO[3]-AO[2], "  ", AO[2]-AO[1], "  ", AO[0]-AO[1]);
   //Print(AO[4]-AO[3], "  ", AO[3]-AO[2], "  ", AO[2]-AO[1], "  ", AO[0]-AO[1]);
   if(AO[4] > AO[3]
      && AO[3] > AO[2]
      && AO[2] > AO[1]
      && AO[1] < AO[0]
      && AO[0] < -buyrange)
     {
      //Alert("buy");
      return buy;
     }
   else
     {
      if(AO[4] < AO[3]
         && AO[3] < AO[2]
         && AO[2] < AO[1]
         && AO[1] > AO[0]
         && AO[0] > sellrange)
        {
         //Alert("sell");
         return sell;
        }
     }
   return notrade;
  }
//+------------------------------------------------------------------+
int AO_check2(double buyrange, double sellrange)
  {
   double AO[4] = {0,0,0,0};
   for(int i=0; i<4; i++)
     {
      AO[i] = iAO(Symbol(), Period(), i+1);
     }
   //Alert(AO[4]-AO[3], "  ", AO[3]-AO[2], "  ", AO[2]-AO[1], "  ", AO[0]-AO[1]);
   //Print(AO[3]-AO[2], "  ", AO[2]-AO[1], "  ", AO[0]-AO[1]);
   if(AO[1] < AO[0])
     {
      //Alert("buy", AO[0]-AO[1]);
      return buy;
     }
   else
     {
      if(AO[1] > AO[0])
        {
         //Alert("sell", AO[1]-AO[0]);
         return sell;
        }
     }
   return notrade;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AC_check1(double buyrange, double sellrange)
  {
   double AC[5] = {0,0,0,0,0};
   for(int i=0; i<5; i++)
     {
      AC[i] = iAC(Symbol(), Period(), i+1);
     }
   //Alert(AO[4]-AO[3], "  ", AO[3]-AO[2], "  ", AO[2]-AO[1], "  ", AO[0]-AO[1]);
   //Print(AO[4]-AO[3], "  ", AO[3]-AO[2], "  ", AO[2]-AO[1], "  ", AO[0]-AO[1]);
   if(AC[4] > AC[3]
      && AC[3] > AC[2]
      && AC[2] > AC[1]
      && AC[1] < AC[0]
      && AC[0] < -buyrange)
     {
      //Alert("buy");
      return buy;
     }
   else
     {
      if(AC[4] < AC[3]
         && AC[3] < AC[2]
         && AC[2] < AC[1]
         && AC[1] > AC[0]
         && AC[0] > sellrange)
        {
         //Alert("sell");
         return sell;
        }
     }
   return notrade;
  }
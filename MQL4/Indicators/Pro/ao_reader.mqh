
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AO_check1(int i, double high, double low, double buyrange = 100, double sellrange = 100)
  {
   double AO[5] = {0,0,0,0,0};
   for(int j=0; j<5; j++)
     {
      AO[j] = iAO(Symbol(), Period(), j+i+1);
     }

//Alert(AO[2], "  ", AO[3], "  ", AO[4]);
   if(AO[4] > AO[3]
      && AO[3] > AO[2]
      && AO[2] > AO[1]
      && AO[1] < AO[0]
      && AO[1] < -buyrange)
     {
      up[i] = high;
     }
   else
     {
      if(AO[4] < AO[3]
         && AO[3] < AO[2]
         && AO[2] < AO[1]
         && AO[1] > AO[0]
         && AO[1] > sellrange)
        {
      down[i] = low;
        }
     }

  }
//+------------------------------------------------------------------+

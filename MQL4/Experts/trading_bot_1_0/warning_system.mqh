//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void internet_connection(void)
  {
   if(!IsConnected())
     {
      warning[1] = 1;
      Alert("no connection");
     }
   if(warning[1] == 1 && IsConnected())
     {
      warning[1] = 0;
      Alert("connection restored");
     }
  }
//+------------------------------------------------------------------+
double trade_margin_calc()
  {
   timer3++;
   double margin_percent = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit = AccountInfoDouble(ACCOUNT_PROFIT);

   if((margin_percent < 125 && margin_percent != 0)
      || profit < -balance*0.20)
     {
      warning[2] = 2;
      Alert("risk level red   ", margin_percent, "  ", profit + balance*0.20);
      return 0.5;
     }

   if((margin_percent < 133 && margin_percent != 0)
      || profit < -balance*0.10)
     {
      if(timer3 >= 10)
        {
         timer3 = 0;
         Alert("risk level yellow   ", margin_percent, "  ", profit + balance*0.10);
        }
      warning[2] = 1;
      return 0.5;
     }
   if(((margin_percent > 133 && margin_percent != 0)
       || profit > -balance*0.10)
      && (warning[2] == 1 || warning[2] == 2))
     {
      Alert("risk level good   ", margin_percent, "  ", profit + balance*0.10);
      warning[2] = 0;
     }
   if(timer3 >= 100)
     {
      timer3 = 10;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

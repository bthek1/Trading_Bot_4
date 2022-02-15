//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void print_details(void)
  {
   Print("Symbol name of the current chart=",_Symbol);
   Print("Timeframe of the current chart=",_Period);
   Print("The latest known seller's price (ask price) for the current symbol=",Ask);
   Print("The latest known buyer's price (bid price) of the current symbol=",Bid);
   Print("Number of decimal places=",Digits);
   Print("Number of decimal places=",_Digits);
   Print("Size of the current symbol point in the quote currency=",_Point);
   Print("Size of the current symbol point in the quote currency=",Point);
   Print("Number of bars in the current chart=",Bars);
   Print("Open price of the current bar of the current chart=",Open[0]);
   Print("Close price of the current bar of the current chart=",Close[0]);
   Print("High price of the current bar of the current chart=",High[0]);
   Print("Low price of the current bar of the current chart=",Low[0]);
   Print("Time of the current bar of the current chart=",Time[0]);
   Print("Tick volume of the current bar of the current chart=",Volume[0]);
   Print("Last error code=",_LastError);
   Print("Random seed=",_RandomSeed);
   Print("Stop flag=",_StopFlag);
   Print("Uninitialization reason code=",_UninitReason);

   printf("ACCOUNT_BALANCE =  %G",AccountInfoDouble(ACCOUNT_BALANCE));
   printf("ACCOUNT_CREDIT =  %G",AccountInfoDouble(ACCOUNT_CREDIT));
   printf("ACCOUNT_PROFIT =  %G",AccountInfoDouble(ACCOUNT_PROFIT));
   printf("ACCOUNT_EQUITY =  %G",AccountInfoDouble(ACCOUNT_EQUITY));
   printf("ACCOUNT_MARGIN =  %G",AccountInfoDouble(ACCOUNT_MARGIN));
   printf("ACCOUNT_MARGIN_FREE =  %G",AccountInfoDouble(ACCOUNT_FREEMARGIN));
   printf("ACCOUNT_MARGIN_LEVEL =  %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   printf("ACCOUNT_MARGIN_SO_CALL = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   printf("ACCOUNT_MARGIN_SO_SO = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));

  }
//+------------------------------------------------------------------+

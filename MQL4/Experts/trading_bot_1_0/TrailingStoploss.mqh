//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStopRSI(double retrade)
  {
   double RSI = iRSI(Symbol(), Period(), InpRSIPeriods, PRICE_CLOSE, 1);
   bool check;
   static int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()!=Symbol())
         continue;

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==OP_BUY)
        {
         if(RSI > 60)
           {
            double buystoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID) - retrade, digits);
            buystoploss = buystoploss+((buystoploss- OrderOpenPrice())*0.05);
            if(buystoploss > OrderOpenPrice())
              {
               if(OrderStopLoss() == 0 || buystoploss > OrderStopLoss())
                 {
                  //Alert("buy stoploss applied");
                  check = OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss, 0, 0, clrAqua);
                 }
              }

            else
               //Alert(Symbol(), "buy stoploss adjust  ", buystoploss);
               check = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, clrLightCyan);
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(RSI <= 40)
           {
            double sellstoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK) + retrade, digits);
            sellstoploss = sellstoploss-((OrderOpenPrice()- sellstoploss)*0.05);
            if(sellstoploss < OrderOpenPrice())
              {
               if(OrderStopLoss() == 0 || sellstoploss < OrderStopLoss())
                 {
                  //Alert("sell stoploss applied");
                  check = OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss, 0, 0, clrOrangeRed);
                 }
              }
            else
               check = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, clrMistyRose);
            //Alert(Symbol(), "sell stoploss adjust  ", sellstoploss);

           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStop(double retrade)
  {
   double RSI = iRSI(Symbol(), Period(), InpRSIPeriods, PRICE_CLOSE, 1);
   bool check;
   static int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()!=Symbol())
         continue;

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==OP_BUY)
        {

         double buystoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID) - retrade, digits);
         buystoploss = buystoploss+((buystoploss- OrderOpenPrice())*0.05);
         if(buystoploss > OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || buystoploss > OrderStopLoss())
              {
               //Alert("buy stoploss applied");
               check = OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss, 0, 0, clrAqua);
              }
           }

         else
            //Alert(Symbol(), "buy stoploss adjust  ", buystoploss);
            check = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, clrLightCyan);
        }

      if(OrderType()==OP_SELL)
        {

         double sellstoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK) + retrade, digits);
         sellstoploss = sellstoploss-((OrderOpenPrice()- sellstoploss)*0.05);
         if(sellstoploss < OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || sellstoploss < OrderStopLoss())
              {
               //Alert("sell stoploss applied");
               check = OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss, 0, 0, clrOrangeRed);
              }
           }
         else
            check = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, clrMistyRose);
         //Alert(Symbol(), "sell stoploss adjust  ", sellstoploss);

        }
     }

  }
//+------------------------------------------------------------------+

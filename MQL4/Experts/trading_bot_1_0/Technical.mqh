//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int buy_trade(double orderSize, int open)
  {
   if(sellcount > 0)
      Order_close(OP_SELL);
   else
      if(buycount < Tradelimit && open)
         return Order_open(OP_BUY, orderSize);
   return 0;
  }
//+------------------------------------------------------------------+
//| sell_trade                                                       |
//+------------------------------------------------------------------+
int sell_trade(double orderSize, int open)
  {
   if(buycount > 0)
      Order_close(OP_BUY);
   else
      if(sellcount < Tradelimit && open)
         return Order_open(OP_SELL, orderSize);
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_open(ENUM_ORDER_TYPE orderType, double orderSize)
  {
   if(orderType == OP_BUY)
     {
      double openPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      return OrderSend(Symbol(), orderType, orderSize, Ask, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, clrBlue);
     }
   if(orderType == OP_SELL)
     {
      double openPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      return OrderSend(Symbol(), orderType, orderSize, Bid, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, clrRed);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_close(ENUM_ORDER_TYPE orderType)
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()!=Symbol())
         continue;

      if(orderType==OP_BUY)
        {
         double closeprice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         if(!OrderClose(OrderTicket(),OrderLots(), Bid, 0, clrGreenYellow))
            Print("OrderClose error ",GetLastError());
        }
      if(orderType==OP_SELL)
        {
         double closeprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         if(!OrderClose(OrderTicket(),OrderLots(), Ask, 0, clrGold))
            Print("OrderClose error ",GetLastError());
        }

      break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateCurrentOrders()
  {
   int buys=0,sells=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
            buys++;
         if(OrderType()==OP_SELL)
            sells++;
        }
     }
   buycount = buys;
   sellcount = sells;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateCurrentOrdersSize(double start_val, double increment)
  {
   double buysz = start_val, sellsz = start_val;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            if(OrderOpenPrice() > Open[0])
              {
               buysz = OrderLots() + increment;
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(OrderOpenPrice() < Open[0])
              {
               sellsz = OrderLots() + increment;
              }
           }
        }
     }
   buysize = buysz;
   sellsize = sellsz;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double max(int search)
  {
   double maximum = 0.0;
   for(int i=0; i<search; i++)
     {
      if(High[i] > maximum || maximum == 0.0)
        {
         maximum = High[i];
        }
     }

   return maximum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double min(int search)
  {
   double minimum = 0.0;
   for(int i=0; i<search; i++)
     {
      if(Low[i] < minimum || minimum == 0.0)
        {
         minimum = Low[i];
        }
     }
   return minimum;
  }


//+------------------------------------------------------------------+

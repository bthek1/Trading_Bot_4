void runaway(double retrade)
  {
   int ticket;
   double currentbuyprice = Ask;
   double currentsellprice = Bid;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()!=Symbol())
         continue;

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==OP_BUY)
        {
         if(OrderOpenPrice() > (currentbuyprice + retrade))
           {
            double size = OrderLots();

            if(OrderClose(OrderTicket(), size, currentsellprice, 0, clrLightCyan))
              {
               Alert("retrade buy");
               ticket = OrderSend(Symbol(), OP_BUY, size*2, currentbuyprice, 0, 0, 0, "retrade buy", InpMagicNumber, 0, clrAqua);
              }
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(OrderOpenPrice() < (currentsellprice - retrade))
           {
            double size = OrderLots();
            if(OrderClose(OrderTicket(),size, currentbuyprice, 0, clrMistyRose))
              {
               Alert("retrade sell trade");
               ticket = OrderSend(Symbol(), OP_SELL, size*2, currentsellprice, 0, 0, 0, "retrade sell", InpMagicNumber, 0, clrOrangeRed);
              }
           }
        }
     }
  }
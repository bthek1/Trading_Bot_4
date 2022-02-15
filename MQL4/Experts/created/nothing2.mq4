//+------------------------------------------------------------------+
//|                                               basic_with_RSI.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

bool buyallow = true;
bool sellallow = true;

//RSI levels are from 0-100, select levels for overbrought and oversold
//and the inputs to RSI
input int                  InpRSIPeriods     =  7;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

// The levels
input double               InpSellLevel  = 70.0;           //Sell level
input double               InpBuyLevel = 30.0;           //Buy level

//Take profit and stop loss as each criteria for each trade
//A simple way to exit
input double               InpTakeProfit     =  5.0;          //Take profit in currency value
input double               InpStopLoss       =  0.0;          //Stop loss in currency value


//Standard inputs - you should have something like this in every EA
input double               InpOrderSize      =  0.01;             //Order size - start small
input string               InpTradeComment   =  "Beginner RSI";   //Trade comment - for information
input int                  InpMagicNumber    =  111111;           //Magic number - identifies these


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Alert("Success alert");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Alert("tear down");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
   return;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_open(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit)
  {

   int ticket = 0;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;

//calculate the open price, take profit and stop loss prices based on the order type

   if(orderType == ORDER_TYPE_BUY)
     {
      openPrice = Open[0];

      stopLossPrice = (stopLoss == 0.0) ? 0.0 : NormalizeDouble(openPrice - stopLoss, Digits());
      takeProfitPrice = (takeProfit == 0.0) ? 0.0 : NormalizeDouble(openPrice + takeProfit, Digits());
      //Alert(stopLossPrice, "  ", openPrice, "  ", takeProfitPrice);
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, Bid, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Blue);

     }
   if(orderType == ORDER_TYPE_SELL)
     {
      openPrice = Open[0];

      stopLossPrice = (stopLoss == 0.0) ? 0.0 : NormalizeDouble(openPrice + stopLoss, Digits());
      takeProfitPrice = (takeProfit == 0.0) ? 0.0 : NormalizeDouble(openPrice - takeProfit, Digits());
      //Alert(stopLossPrice, "  ", openPrice, "  ", takeProfitPrice);
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, Ask, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Red);

     }
   return ticket;
  }
//+------------------------------------------------------------------+
void Order_close(ENUM_ORDER_TYPE orderType)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;
      //--- check order type
      if(orderType==ORDER_TYPE_SELL)
        {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3, Green))
            Print("OrderClose error ",GetLastError());
        }
      if(orderType==ORDER_TYPE_BUY)
        {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Yellow))
           {
            Print("OrderClose error ",GetLastError());
           }
         break;

        }
     }
//---
  }



//+------------------------------------------------------------------+
int CalculateCurrentOrders()
  {
   int buys=0,sells=0;
//---
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber)
        {
         if(OrderType()==OP_BUY)
            buys++;
         if(OrderType()==OP_SELL)
            sells++;
        }
     }
//--- return orders volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+

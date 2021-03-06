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
input int                  InpRSIPeriods     =  3;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

// The levels
input double               InpSellLevel  = 70.0;           //Sell level
input double               InpBuyLevel = 30.0;           //Buy level

//Take profit and stop loss as each criteria for each trade
//A simple way to exit
input double               InpTakeProfit     =  5.0;          //Take profit in currency value
input double               InpStopLoss       =  0.0;          //Stop loss in currency value


input int                  InpMAPeriods      =  15;         //MovingAvg Periods
input int                  InpMAShift        =  0;          //MovingAvg Rightshift

input int                  Tradelimit        =  10;         //Number of trades allowed
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
   int tradeCount = CalculateCurrentOrders();
   double rsiValue = iRSI(Symbol(), Period(), InpRSIPeriods, InpRSIPRICE, 1);

   double maValue = iMA(Symbol(),0,InpMAPeriods,InpMAShift,MODE_SMA,PRICE_CLOSE,0);

   if(Open[0] > (maValue*1.0002) || Open[0] < (maValue*0.9998))
     {
      //Alert("outside moving average", maValue);
     }



   if(Volume[0] == 1)
     {
      if(!sellallow)
        {
         sellallow = true;
         //Alert("sellallowed", Volume[0]);
        }
      if(!buyallow)
        {
         buyallow = true;
         //Alert("buyallowed", Volume[0]);
        }
     }

   if(!sellallow && !buyallow)
      return;  //only trade on a new bar

//Alert(Open[0], "  ", Close[0], "  ", rsiValue, "   ", tradeCount);

///////////////////////real////////////////////////////////////////

//get the direction of the last bar. This will just give a positive number
// for up and a negative number for down
   double direction = iClose(Symbol(), Period(), 1) - iOpen(Symbol(), Period(), 1);

// If RSI has crossed the midpoint, then clear any old flags


   int ticket = 0;
   if((rsiValue < 30) && (maValue*0.9998 > Open[0]) && buyallow)
     {
      if(tradeCount < 0)
        {
         Order_close(ORDER_TYPE_SELL);
         Alert("Close sell trade", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
         buyallow = false;
        }
      else
        {
         if(tradeCount <= Tradelimit && tradeCount >= 0)
           {
            ticket = Order_open(ORDER_TYPE_BUY, InpStopLoss, InpTakeProfit);
            Alert("Buy trade", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
            buyallow = false;
           }
        }

     }

   else
     {
      if(rsiValue > 70 && (maValue*1.0002 < Open[0]) && sellallow)
        {
         if(tradeCount > 0)
           {
            Order_close(ORDER_TYPE_BUY);
            Alert("Close buy trade", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
            sellallow = false;
           }
         else
           {
            if((tradeCount*-1) <= Tradelimit && tradeCount <= 0)
              {
               ticket = Order_open(ORDER_TYPE_SELL, InpStopLoss, InpTakeProfit);
               Alert("Sell trade, ", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
               sellallow = false;
              }
           }

        }
      else
        {
         //Alert("new data  : ", Open[0], " : ", Close[0], "   rsi: ", rsi, "   trades: ", CalculateCurrentOrders());
        }
     }

///////////////////Finished//////////////////

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
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, 0, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Blue);

     }
   if(orderType == ORDER_TYPE_SELL)
     {
      openPrice = Open[0];

      stopLossPrice = (stopLoss == 0.0) ? 0.0 : NormalizeDouble(openPrice + stopLoss, Digits());
      takeProfitPrice = (takeProfit == 0.0) ? 0.0 : NormalizeDouble(openPrice - takeProfit, Digits());
      //Alert(stopLossPrice, "  ", openPrice, "  ", takeProfitPrice);
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, 0, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Red);

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
            Print("OrderClose error ",GetLastError());
        }
      break;
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

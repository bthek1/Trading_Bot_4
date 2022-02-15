//+------------------------------------------------------------------+
//|                                               basic_with_RSI.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//RSI levels are from 0-100, select levels for overbrought and oversold
//and the inputs to RSI
input int                  InpRSIPeriods     =  5;            //RSI Periods
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

input int                  Tradelimit        =  15;         //Number of trades allowed
input int                  InpTrailingStop   =  1;     //trailing stop points
//Standard inputs - you should have something like this in every EA
input double               InpOrderSize      =  0.01;             //Order size - start small
input string               InpTradeComment   =  "Beginner RSI";   //Trade comment - for information
input int                  InpMagicNumber    =  000020;           //Magic number - identifies these


bool buyallow = true;
bool sellallow = true;

int timer;

double StopLoss;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   StopLoss = SymbolInfoDouble(Symbol(), SYMBOL_POINT)*InpTrailingStop;
   EventSetTimer(1);
   printf("Success alert");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Alert("tear down");

  }

//+------------------------------------------------------------------+
//|  On timer                                                                |
//+------------------------------------------------------------------+
void OnTimer()
  {
   timer++;
   if(timer >= 60)
     {
      if(!buyallow)
         buyallow = true;
      if(!sellallow)
         sellallow = true;
      timer = 0;
     }
   ApplyTrailingStop(StopLoss);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int tradeCount = CalculateCurrentOrders();
   double rsiValue = iRSI(Symbol(), Period(), InpRSIPeriods, InpRSIPRICE, 1);

   double maValue = iMA(Symbol(),0,InpMAPeriods,InpMAShift,MODE_SMA,PRICE_CLOSE,0);

   if(!sellallow && !buyallow)
      return;  //only trade on a new bar

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
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Blue);

     }
   if(orderType == ORDER_TYPE_SELL)
     {
      openPrice = Open[0];

      stopLossPrice = (stopLoss == 0.0) ? 0.0 : NormalizeDouble(openPrice + stopLoss, Digits());
      takeProfitPrice = (takeProfit == 0.0) ? 0.0 : NormalizeDouble(openPrice - takeProfit, Digits());
      //Alert(stopLossPrice, "  ", openPrice, "  ", takeProfitPrice);
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Red);

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
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Orange))
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStop(double stoploss)
  {

   int ticket;
   static int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   double price = Open[0];


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;
      //--- check order type
      
      double buystoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID) - 0.5, digits);
      double sellstoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK) + 0.5, digits);
      
      buystoploss = buystoploss-((buystoploss- OrderOpenPrice())*0.3);
      sellstoploss = sellstoploss+((OrderOpenPrice()- sellstoploss)*0.3);
      
      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==ORDER_TYPE_BUY)
         if(buystoploss > OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || buystoploss > OrderStopLoss())
              {
               ticket = OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss, OrderTakeProfit(), OrderExpiration(), Yellow);
               //if(ticket != 0)
                  //Alert("buy ticket modified  ", ticket, "  ", buystoploss);
              }
           }
         else
           {
            ticket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderTakeProfit(), OrderExpiration(), Yellow);
           }
      if(OrderType()==ORDER_TYPE_SELL)
         if(sellstoploss < OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || sellstoploss < OrderStopLoss())
              {
               ticket = OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss, OrderTakeProfit(), OrderExpiration(), White);
               //if(ticket != 0)
                  //Alert("sell ticket modified  ", ticket, "  ", sellstoploss);
              }
           }
         else
           {
            ticket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderTakeProfit(), OrderExpiration(), White);
           }
     }
  }
//+------------------------------------------------------------------+

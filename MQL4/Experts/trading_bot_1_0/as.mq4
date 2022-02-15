//+------------------------------------------------------------------+
//|                                                      nothing.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "AO_reader.mqh";
#include "AVG_reader.mqh";
#include "MOCH_reader.mqh";
#include "Print.mqh";
#include "RSI_reader.mqh";
#include "STOCH_reader.mqh";
#include "Technical.mqh";
#include "TrailingStoploss.mqh";
#include "Runawaytrade.mqh";
#include "warning_system.mqh";
#include <stderror.mqh>;
#include <stdlib.mqh>;


input int                  InpRSIPeriods     =  30;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

input double               InpSellLevel      = 70.0;           //Sell level
input double               InpBuyLevel       = 30.0;           //Buy level

input int                  InpMAPeriods      =  15;         //MovingAvg Periods
input int                  InpMAShift        =  0;          //MovingAvg Rightshift

input int                  Tradelimit        =  15;         //Number of trades allowed
input int                  InpTrailingStop   =  1;          //trailing stop points
//Standard inputs - you should have something like this in every EA
input double               InpOGOrderSize      =  0.01;        //Order size - start small
input double               InpOrderSizeInc      =  0.02;       //Order size increase with no. of order
input string               InpTradeComment   =  "currency_1";  //Trade comment - for information
input int                  InpMagicNumber    =  100999;        //Magic number - identifies these

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int tradecondition[12];
double conditionvalues[12];
double warning[5];
double memory;

double timer, timer2, timer3;

enum status {rsi1, rsi2, rsi3, stoch1, stoch2, moch1, moch2, avg1, ao1, ac1, margin1, time_gap};
enum region {notrade, buy, sell, trade};
enum trigger {reset, buyarmed, buytrigger, sellarmed, selltrigger, buywait, sellwait};

int buycount, sellcount;

double upper = 00, lower = 00;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(5);
   print_details();
   if(!StringCompare(Symbol(), "EURUSD"))
     {
      upper = 0.0;
      lower = 0.0;
     }
   if(!StringCompare(Symbol(), "AUDJPY"))
     {
      upper = 0.0;
      lower = 0.0;
     }
   if(!StringCompare(Symbol(), "SPX500"))
     {
      upper = 30;
      lower = 30;
     }
   if(!StringCompare(Symbol(), "AUS200"))
     {
      upper = 50;
      lower = 50;
     }
   if(!StringCompare(Symbol(), "UK100"))
     {
      upper = 45;
      lower = 45;
     }

   Alert("upper:", upper,"  lower:", lower);


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   internet_connection();
   trade_margin_calc();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   internet_connection();

   trade_margin_calc();

///////////////////////////
   string token = "2141028845:AAE6_IwcT0lDSMkft4EGpM0BVSXVG_OR_sY";
   string chat_id = "2125387299";
   string message = "hello world";

   string cookie = NULL, headers;
   char post[], result[];

   int res;
   string base_url = "https://api.telegram.org";
   string url = base_url + "/bot" + token + "/sendMessage?chat_id=" + chat_id + "&text=" + message;

   ResetLastError();
   
   int timeout = 5000;
   res = WebRequest("GET", url, cookie, NULL, timeout, post, 0, result, headers);
   
   


   Alert(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(memory != Open[0])
     {
      memory = Open[0];
      timer++;
      timer2++;
     }
   if(timer >= 5)
     {
      timer = 0;
      double StopLoss = (max(90) - min(90))*0.3;
      //runaway(StopLoss * 5);
      ApplyTrailingStop(StopLoss);
     }

   if(timer2 >= 2)
     {
      timer2=0;
      tradecondition[time_gap] = 1;
     }
//Alert(Close[0]);
   CalculateCurrentOrders(); //update buycount and sellcount

///////////////////////real/////////////////////////////////////
   int ticket = 0;

   tradecondition[rsi1] = RSI_check2(rsi1, 15, 20, 80, tradecondition[rsi1]);

   tradecondition[rsi2] = RSI_check1(rsi2, 30, 45, 55, 0);  //return if in buy or sell region

   tradecondition[stoch2] = STOCH_check2(stoch2, 7, 5, 3, 20, 80, tradecondition[stoch2]);

   tradecondition[avg1] = AVG_check1(15, 0);

   tradecondition[ao1] = AO_check1(upper, lower);

   if(((tradecondition[ao1] == buy) && (tradecondition[rsi2] == buy) && (tradecondition[time_gap] == 1))
//((tradecondition[rsi2] == buy) && (tradecondition[time_gap] == 2) &&
// ((tradecondition[rsi1] == buytrigger) || (tradecondition[stoch2] == buytrigger)))
     )
     {
      double size = InpOGOrderSize + InpOrderSizeInc * buycount;
      ticket = buy_trade(size, 1);
      Alert(Symbol(), "buy trade:", buycount, " ordersize:", size);
      tradecondition[time_gap] = 0;
      timer2=0;
     }


   if(((tradecondition[ao1] == sell) && (tradecondition[rsi2] == sell) && (tradecondition[time_gap] == 1))
//((tradecondition[rsi2] == sell) && (tradecondition[time_gap] == 2) &&
// ((tradecondition[rsi1] == selltrigger) || (tradecondition[stoch2] == selltrigger)))
     )
     {
      double size = InpOGOrderSize + InpOrderSizeInc * sellcount;
      ticket = sell_trade(size, 1);
      Alert(Symbol(), "sell trade:", sellcount, " ordersize:", size);
      tradecondition[time_gap] = 0;
      timer2=0;
     }
  }
//+------------------------------------------------------------------+

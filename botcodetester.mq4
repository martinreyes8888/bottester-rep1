//+------------------------------------------------------------------+
//|                                                    robotbeta.mq4 |
//|                                                   bekbek trading |
//|                                                             null |
//+------------------------------------------------------------------+
#property copyright "bekbek trading"
#property link      "null"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int Order = SIGNAL_NONE;
//extern double Lot1 = 0.05;
//extern double Lot2 = 0.1;
extern int TakeProfitDown =150;
extern int TakeProfitUp =100;
extern int StopLossDown =100;
extern int StopLossUp = 70;
extern bool UseTrailingStop = True;
extern int TrailingStop = 30;
extern int TradeLimit = 50;
double smaS_1, smaS_2, smaF_1, smaF_2;
int P = 1;
int  Total, Ticket2, Ticket1;
int OnInit()
  {
      
   if(Digits == 5 || Digits == 3 || Digits == 1)P = 10;else P = 1; // To account for 5 digit brokers

      
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      Alert("lowballerbot is now terminated");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      double ATR_Current=iATR(_Symbol,_Period, 14,0);
      double ATR_Previous=iATR(_Symbol,_Period, 14, 5);
      if(AccountBalance() >=TradeLimit)
      
         {
            string signal = "";
            int point_Control =NULL ;
            int totalOrders = OrdersTotal();
         double macd = iMACD(_Symbol,_Period,12,29,9,PRICE_CLOSE,MODE_MAIN,0);
         
         smaF_1 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 0); // c
         smaF_2 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 1); // b
         smaS_1 = iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0); // d
         smaS_2 = iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 1); // a
      
      //   smaS_1 = iMA(_Symbol,PERIOD_H1, 20, 0, MODE_SMA, PRICE_CLOSE, 1); // c
      //   smaF_1 = iMA(_Symbol,PERIOD_H1, 20, 20, MODE_SMA, PRICE_CLOSE, 1); // d
         
         double TakeProfitLevelDown = Ask+TakeProfitDown*Point;
         double TakeProfitLevelUp = Ask+TakeProfitUp*Point;
         double StopLossLevelDown = Ask-StopLossDown*Point;
         double StopLossLevelUP = Ask-StopLossUp*Point;
         
         int SizingIndicator = ATR_Current* 1000;
         
          if(_Symbol == "USDJPY" )
         {
           point_Control = 1000;
         }else
         {
            point_Control = 100000;
         }
      
          int ATRStopLoss = (ATR_Current*point_Control)*2;
          int StopLossModifier = NULL;
         if(ATRStopLoss >= 300) 
           {
            StopLossModifier = 150 ;
           }else
           {
            StopLossModifier = ATRStopLoss;
           }
         
         
         
        // int ticket1;
         
         if(macd >0) signal = "UP";
         if(macd <0) signal = "DOWN";
         
 
         
         Comment("Current trend is", " " ,signal," " ,"ATR is:",SizingIndicator," ","StopLoss is:" ,StopLossModifier);
        
        // NORMAL TO HIGH Volatility 
        if(SizingIndicator >=1  && signal=="UP" && smaF_2<smaS_2 && smaF_1>smaS_1 && OrdersTotal() ==0 )
          {
            
            
             OrderSend(_Symbol,OP_BUY,0.1,Ask,3,0,Ask+100*_Point,"Buying",0,0,Green);
            
          } 
        if(SizingIndicator >=1  && signal=="DOWN" && smaF_2>smaS_2 && smaF_1<smaS_1 && OrdersTotal() ==0 )
         {
            
             OrderSend (_Symbol, OP_SELL, 0.1, Bid, 3, 0, Bid-100*_Point, "On Short", 0, 0, Red);
         } 
         
         // LOW Volatility
       if(SizingIndicator == 0 && signal=="UP" && smaF_2<smaS_2 && smaF_1>smaS_1 && OrdersTotal() ==0 )
          {
            
             OrderSend(_Symbol,OP_BUY,0.1,Ask,3,0,Ask+80*_Point,"Buying",0,0,Green);
            
          } 
        if(SizingIndicator == 0 && signal=="DOWN" && smaF_2>smaS_2 && smaF_1<smaS_1 && OrdersTotal() ==0 )
         {
            OrderSend (_Symbol, OP_SELL, 0.1, Bid, 3, 0, Bid-80*_Point, "On Short", 0, 0, Red);
         } 
       if(ATR_Previous>ATR_Current)
         
        {
          Comment("Volatility is to low !!");
          
          for(int b = OrdersTotal()-1;b>=0;b--)
            {
               if(OrderSelect(b, SELECT_BY_POS,MODE_TRADES))
                 
                 if(OrderSymbol() == Symbol())
                   
                    if(OrderType() == OP_BUY)
                       {
                          if(AccountEquity()> AccountBalance())
                            {
                              bool close_buy;
                              close_buy = OrderClose(OrderTicket(),0.1,Bid,3,CLR_NONE);
                              
                               if(close_buy == false)
                                 {
                                  Alert("Modify failed");
                                 }else
                                   {
                                    Alert("Modify success");
                                   } 
                            }
                       }
            }
          }
         
         
        if(ATR_Previous>ATR_Current)
         
        {
          Comment("Volatility is to low !!");
          
          for(int b = OrdersTotal()-1;b>=0;b--)
            {
               if(OrderSelect(b, SELECT_BY_POS,MODE_TRADES))
                 
                 if(OrderSymbol() == Symbol())
                   
                    if(OrderType() == OP_SELL)
                       {
                        
                            if(AccountEquity()> AccountBalance())
                            {
                              bool close_sell;   
                              close_sell = OrderClose(OrderTicket(),0.1,Ask,3,CLR_NONE);
                              
                              if(close_sell == false)
                                 {
                                  Alert("Modify failed");
                                 }else
                                   {
                                    Alert("Modify success");
                                   }
                            }
                          
                       }
            }
            
            //----stoploss----///
            if(SizingIndicator >=1  && signal=="UP")
            {
            for(int b = OrdersTotal()-1;b>=0;b--)
                         {
               if(OrderSelect(b, SELECT_BY_POS,MODE_TRADES))
                 
                 if(OrderSymbol() == Symbol())
                   
                    if(OrderType() == OP_SELL)
                       {
                       
                       if(smaF_2<smaS_2 && smaF_1>smaS_1)
                            {
                        bool close_sell;   
                              close_sell = OrderClose(OrderTicket(), 0.1,Ask,3,CLR_NONE);
                              
                              if(close_sell == false)
                                 {
                                  Alert("Sell StopLoss failed");
                                 }else
                                   {
                                    Alert("Sell StopLoss success");
                                   }
                       }  }
                  }  
              }
          }
          
          
          if(SizingIndicator >=1  && signal=="DOWN")
            {
            for(int b = OrdersTotal()-1;b>=0;b--)
            {
               if(OrderSelect(b, SELECT_BY_POS,MODE_TRADES))
                 
                 if(OrderSymbol() == Symbol())
                   
                    if(OrderType() == OP_BUY)
                       {
                          if(smaF_2>smaS_2 && smaF_1<smaS_1)
                          {
                              bool close_buy;
                              close_buy = OrderClose(OrderTicket(), 0.1,Bid,3,CLR_NONE);
                              
                               if(close_buy == false)
                                 {
                                 Alert("Buy StopLoss failed");
                                 }else
                                   {
                                    Alert("Buy StopLoss  success");
                             
                             }        
                       }
            } 
              }
          }
         
       }
       
        
  }
//+------------------------------------------------------------------+

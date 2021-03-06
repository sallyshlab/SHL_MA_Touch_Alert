//+------------------------------------------------------------------+
//|                                           SHL_MA_Touch_Alert.mq4 |
//|                             Copyright 2020, Sally's Holiday Lab. |
//|                                    https://sallys-holiday-lab.jp |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Sally's Holiday Lab."
#property link      "https://sallys-holiday-lab.jp"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Touch
#property indicator_label1  "Touch"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      ma_period=20; //移動平均線の設定値
input int      ma_method=MODE_SMA; //移動平均線の種類
input int      applied_price=PRICE_CLOSE; //移動平均の計算に適用する価格タイプ
input double allowable_width_pips=5.0; //タッチしそうだと判断する許容pips
input int      tick_interval=500; //何ティック毎にアラートさせるか
//--- indicator buffers
double         TouchBuffer[];
//--- other
const string script_name="SHL_MA_Touch_Alert";
const string status_touch="TOUCH";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,TouchBuffer);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   static int counter=0;
   if(counter>tick_interval)
   {
      counter=0;
   }
   const double ma_current=iMA(NULL,PERIOD_CURRENT,ma_period,0,ma_method,applied_price,0);
   const double price_current=Close[0];
   const bool touch_judgement=TouchJudgement(ma_current,
      price_current);
   if(counter==0&&touch_judgement)
   {
      SendCustomMail(status_touch);
   }
   if(touch_judgement)
   {
      counter++;
   }   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| 1.タッチしそうか？                                                   |
//| 　価格がMAにNpips以内に近づいた場合       |
//+------------------------------------------------------------------+
bool TouchJudgement(const double ma,
  const double price)
  {
//---
   double allowable_width_pips_tmp=allowable_width_pips/2;
   if(allowable_width_pips_tmp<0)
   {
      allowable_width_pips_tmp=-allowable_width_pips_tmp;
   }
   double diff=PriceToPips(ma-price);
   if(-allowable_width_pips_tmp<diff&&diff<allowable_width_pips_tmp)
   {
      Print("TouchJudgement: true");
      return(true);
   }
   Print("TouchJudgement: false");
   return(false);
  }
//+------------------------------------------------------------------+
//| 価格をpipsに換算する関数
//| (C) https://minagachi.com/price-to-pips
//+------------------------------------------------------------------+
double PriceToPips(double price)
{
   double pips = 0;

   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);

   // 3桁・5桁のFXブローカーの場合
   if(digits == 3 || digits == 5){
     pips = price * MathPow(10, digits) / 10;
   }
   // 2桁・4桁のFXブローカーの場合
   if(digits == 2 || digits == 4){
     pips = price * MathPow(10, digits);
   }
   // 少数点以下を１桁に丸める（目的によって桁数は変更する）
   pips = NormalizeDouble(pips, 1);

   return(pips);
}
//+------------------------------------------------------------------+
//| アラートメール送信                                                   |
//+------------------------------------------------------------------+
void SendCustomMail(const string stauts)
  {
//---
   const string subject=script_name+": "+Symbol()+" "+stauts;
   const string content="";
   SendMail(subject,content);
   Print("Sended Mail.");
  }
//+------------------------------------------------------------------+

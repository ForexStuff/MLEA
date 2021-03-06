//+------------------------------------------------------------------+
//|                                          ForexMoringTrailing.mqh |
//|                                                         Zephyrrr |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Zephyrrr"
#property link      "http://www.mql5.com"

#include <ExpertModel\ExpertModel.mqh>
#include <ExpertModel\ExpertModelTrailing.mqh>

#include <Trade\Trade.mqh>
 
class CForexMorningTrailing : public CExpertModelTrailing
{
private:
    int m_breakEvenAtPipsProfit;    // 当超过m_breakEvenAtPipsProfit后，sl设置为m_breakEvenAddPips
    int m_breakEvenAddPips;
    
    int m_trailingStopPips;
public:
                      CForexMorningTrailing();
    virtual bool      ValidationSettings();
    virtual bool      InitIndicators(CIndicators* indicators);
    
    virtual bool      CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp);
    virtual bool      CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp);
    
    void InitParameters(int breakEvenAtPipsProfit, int breakEvenAddPips, int trailingStopPips);
};

void CForexMorningTrailing::CForexMorningTrailing()
{
}

bool CForexMorningTrailing::ValidationSettings()
{
    if (!CExpertModelTrailing::ValidationSettings())
        return false;
        
   return true;
}

void CForexMorningTrailing::InitParameters(int breakEvenAtPipsProfit = 20, int breakEvenAddPips = 0, int trailingStopPips = 0)
{
    m_breakEvenAtPipsProfit = breakEvenAtPipsProfit * GetPointOffset(m_symbol.Digits());;
    m_breakEvenAddPips = breakEvenAddPips * GetPointOffset(m_symbol.Digits());;
    m_trailingStopPips = trailingStopPips * GetPointOffset(m_symbol.Digits());;
}

bool CForexMorningTrailing::InitIndicators(CIndicators* indicators)
{
    if(indicators==NULL) 
        return(false);
    bool ret = true;
    
    return ret;
}

bool CForexMorningTrailing::CheckTrailingStopLong(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    if (m_trailingStopPips > 0) 
    {
        if (m_symbol.Bid() > order.StopLoss() + m_trailingStopPips * m_symbol.Point()) 
        {
            sl = m_symbol.Bid() - m_trailingStopPips * m_symbol.Point();
            Debug("CForexMorningTrailing set sl1 = " + DoubleToString(sl, 4));
        }
    }
    
    if (m_breakEvenAtPipsProfit > 0)
    {
        if (m_symbol.Bid() - order.Price() >= m_breakEvenAtPipsProfit * m_symbol.Point() 
            && order.StopLoss() < order.Price()) 
        {
            sl = order.Price() + m_breakEvenAddPips * m_symbol.Point();
            Debug("CForexMorningTrailing set sl2 = " + DoubleToString(sl, 4));
        }
    }
    
    if ((sl != EMPTY_VALUE && sl != order.StopLoss())
        || (tp != EMPTY_VALUE && tp != order.TakeProfit()))
    {
        return true;
    }
    
    return false;
}

bool CForexMorningTrailing::CheckTrailingStopShort(CTableOrder* order,double& sl,double& tp)
{
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    
    if(order==NULL)  
        return(false);
    
    if (m_trailingStopPips > 0) 
    {
        if (m_symbol.Ask() < order.StopLoss() - m_trailingStopPips * m_symbol.Point()) 
        {
            sl = m_symbol.Ask() + m_trailingStopPips * m_symbol.Point();
            Debug("CForexMorningTrailing set sl1 = " + DoubleToString(sl, 4));
        }
    }
    if (m_breakEvenAtPipsProfit > 0)
    {
        if (order.Price() - m_symbol.Ask() >= m_breakEvenAtPipsProfit * m_symbol.Point() 
            && order.StopLoss() > order.Price())
        {
            sl = order.Price() - m_breakEvenAddPips * m_symbol.Point();
            Debug("CForexMorningTrailing set sl2 = " + DoubleToString(sl, 4));
        }
    }
        
    if ((sl != EMPTY_VALUE && sl != order.StopLoss())
        || (tp != EMPTY_VALUE && tp != order.TakeProfit()))
    {
        return true;
    }
    return false;
}
//+------------------------------------------------------------------+


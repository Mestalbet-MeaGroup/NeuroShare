// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSEvtAverage wrapper class

class IMCSEvtAverage : public COleDispatchDriver
{
public:
	IMCSEvtAverage(){} // Calls COleDispatchDriver default constructor
	IMCSEvtAverage(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSEvtAverage(const IMCSEvtAverage& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSEvtAverage methods
public:
	short GetADData(long iIndex)
	{
		short result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_I2, (void*)&result, parms, iIndex);
		return result;
	}
	BOOL GetADDataArray(short * buf)
	{
		BOOL result;
		static BYTE parms[] = VTS_PI2 ;
		InvokeHelper(0x5, DISPATCH_METHOD, VT_BOOL, (void*)&result, parms, buf);
		return result;
	}
	short Next()
	{
		short result;
		InvokeHelper(0x1000f, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH Clone()
	{
		LPDISPATCH result;
		InvokeHelper(0x10010, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	short GetHWID()
	{
		short result;
		InvokeHelper(0x6, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}

	// IMCSEvtAverage properties
public:
	long GetCount()
	{
		long result;
		GetProperty(0x1, VT_I4, (void*)&result);
		return result;
	}
	void SetCount(long propVal)
	{
		SetProperty(0x1, VT_I4, propVal);
	}
	short GetChannel()
	{
		short result;
		GetProperty(0x2, VT_I2, (void*)&result);
		return result;
	}
	void SetChannel(short propVal)
	{
		SetProperty(0x2, VT_I2, propVal);
	}
	long GetTimeWindowCount()
	{
		long result;
		GetProperty(0x3, VT_I4, (void*)&result);
		return result;
	}
	void SetTimeWindowCount(long propVal)
	{
		SetProperty(0x3, VT_I4, propVal);
	}
	short GetYear()
	{
		short result;
		GetProperty(0x10001, VT_I2, (void*)&result);
		return result;
	}
	void SetYear(short propVal)
	{
		SetProperty(0x10001, VT_I2, propVal);
	}
	short GetMonth()
	{
		short result;
		GetProperty(0x10002, VT_I2, (void*)&result);
		return result;
	}
	void SetMonth(short propVal)
	{
		SetProperty(0x10002, VT_I2, propVal);
	}
	short GetDay()
	{
		short result;
		GetProperty(0x10003, VT_I2, (void*)&result);
		return result;
	}
	void SetDay(short propVal)
	{
		SetProperty(0x10003, VT_I2, propVal);
	}
	short GetHour()
	{
		short result;
		GetProperty(0x10004, VT_I2, (void*)&result);
		return result;
	}
	void SetHour(short propVal)
	{
		SetProperty(0x10004, VT_I2, propVal);
	}
	short GetMinute()
	{
		short result;
		GetProperty(0x10005, VT_I2, (void*)&result);
		return result;
	}
	void SetMinute(short propVal)
	{
		SetProperty(0x10005, VT_I2, propVal);
	}
	short GetSecond()
	{
		short result;
		GetProperty(0x10006, VT_I2, (void*)&result);
		return result;
	}
	void SetSecond(short propVal)
	{
		SetProperty(0x10006, VT_I2, propVal);
	}
	short GetMillisecond()
	{
		short result;
		GetProperty(0x10007, VT_I2, (void*)&result);
		return result;
	}
	void SetMillisecond(short propVal)
	{
		SetProperty(0x10007, VT_I2, propVal);
	}
	short GetMicrosecond()
	{
		short result;
		GetProperty(0x10008, VT_I2, (void*)&result);
		return result;
	}
	void SetMicrosecond(short propVal)
	{
		SetProperty(0x10008, VT_I2, propVal);
	}
	short GetNanosecond()
	{
		short result;
		GetProperty(0x10009, VT_I2, (void*)&result);
		return result;
	}
	void SetNanosecond(short propVal)
	{
		SetProperty(0x10009, VT_I2, propVal);
	}
	long GetSecondFromStart()
	{
		long result;
		GetProperty(0x1000a, VT_I4, (void*)&result);
		return result;
	}
	void SetSecondFromStart(long propVal)
	{
		SetProperty(0x1000a, VT_I4, propVal);
	}
	short GetMillisecondFromStart()
	{
		short result;
		GetProperty(0x1000b, VT_I2, (void*)&result);
		return result;
	}
	void SetMillisecondFromStart(short propVal)
	{
		SetProperty(0x1000b, VT_I2, propVal);
	}
	short GetMicrosecondFromStart()
	{
		short result;
		GetProperty(0x1000c, VT_I2, (void*)&result);
		return result;
	}
	void SetMicrosecondFromStart(short propVal)
	{
		SetProperty(0x1000c, VT_I2, propVal);
	}
	short GetNanosecondFromStart()
	{
		short result;
		GetProperty(0x1000d, VT_I2, (void*)&result);
		return result;
	}
	void SetNanosecondFromStart(short propVal)
	{
		SetProperty(0x1000d, VT_I2, propVal);
	}
	LPDISPATCH GetTimeStamp()
	{
		LPDISPATCH result;
		GetProperty(0x1000e, VT_DISPATCH, (void*)&result);
		return result;
	}
	void SetTimeStamp(LPDISPATCH propVal)
	{
		SetProperty(0x1000e, VT_DISPATCH, propVal);
	}

};

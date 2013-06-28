// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSEvent wrapper class

class IMCSEvent : public COleDispatchDriver
{
public:
	IMCSEvent(){} // Calls COleDispatchDriver default constructor
	IMCSEvent(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSEvent(const IMCSEvent& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSEvent methods
public:
	short Next()
	{
		short result;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH Clone()
	{
		LPDISPATCH result;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	long GetSize()
	{
		long result;
		InvokeHelper(0x11, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	unsigned __int64 GetRawTimeStamp()
	{
		unsigned __int64 result;
		InvokeHelper(0x12, DISPATCH_METHOD, VT_UI8, (void*)&result, NULL);
		return result;
	}

	// IMCSEvent properties
public:
	short GetYear()
	{
		short result;
		GetProperty(0x1, VT_I2, (void*)&result);
		return result;
	}
	void SetYear(short propVal)
	{
		SetProperty(0x1, VT_I2, propVal);
	}
	short GetMonth()
	{
		short result;
		GetProperty(0x2, VT_I2, (void*)&result);
		return result;
	}
	void SetMonth(short propVal)
	{
		SetProperty(0x2, VT_I2, propVal);
	}
	short GetDay()
	{
		short result;
		GetProperty(0x3, VT_I2, (void*)&result);
		return result;
	}
	void SetDay(short propVal)
	{
		SetProperty(0x3, VT_I2, propVal);
	}
	short GetHour()
	{
		short result;
		GetProperty(0x4, VT_I2, (void*)&result);
		return result;
	}
	void SetHour(short propVal)
	{
		SetProperty(0x4, VT_I2, propVal);
	}
	short GetMinute()
	{
		short result;
		GetProperty(0x5, VT_I2, (void*)&result);
		return result;
	}
	void SetMinute(short propVal)
	{
		SetProperty(0x5, VT_I2, propVal);
	}
	short GetSecond()
	{
		short result;
		GetProperty(0x6, VT_I2, (void*)&result);
		return result;
	}
	void SetSecond(short propVal)
	{
		SetProperty(0x6, VT_I2, propVal);
	}
	short GetMillisecond()
	{
		short result;
		GetProperty(0x7, VT_I2, (void*)&result);
		return result;
	}
	void SetMillisecond(short propVal)
	{
		SetProperty(0x7, VT_I2, propVal);
	}
	short GetMicrosecond()
	{
		short result;
		GetProperty(0x8, VT_I2, (void*)&result);
		return result;
	}
	void SetMicrosecond(short propVal)
	{
		SetProperty(0x8, VT_I2, propVal);
	}
	short GetNanosecond()
	{
		short result;
		GetProperty(0x9, VT_I2, (void*)&result);
		return result;
	}
	void SetNanosecond(short propVal)
	{
		SetProperty(0x9, VT_I2, propVal);
	}
	long GetSecondFromStart()
	{
		long result;
		GetProperty(0xa, VT_I4, (void*)&result);
		return result;
	}
	void SetSecondFromStart(long propVal)
	{
		SetProperty(0xa, VT_I4, propVal);
	}
	short GetMillisecondFromStart()
	{
		short result;
		GetProperty(0xb, VT_I2, (void*)&result);
		return result;
	}
	void SetMillisecondFromStart(short propVal)
	{
		SetProperty(0xb, VT_I2, propVal);
	}
	short GetMicrosecondFromStart()
	{
		short result;
		GetProperty(0xc, VT_I2, (void*)&result);
		return result;
	}
	void SetMicrosecondFromStart(short propVal)
	{
		SetProperty(0xc, VT_I2, propVal);
	}
	short GetNanosecondFromStart()
	{
		short result;
		GetProperty(0xd, VT_I2, (void*)&result);
		return result;
	}
	void SetNanosecondFromStart(short propVal)
	{
		SetProperty(0xd, VT_I2, propVal);
	}
	LPDISPATCH GetTimeStamp()
	{
		LPDISPATCH result;
		GetProperty(0xe, VT_DISPATCH, (void*)&result);
		return result;
	}
	void SetTimeStamp(LPDISPATCH propVal)
	{
		SetProperty(0xe, VT_DISPATCH, propVal);
	}

};

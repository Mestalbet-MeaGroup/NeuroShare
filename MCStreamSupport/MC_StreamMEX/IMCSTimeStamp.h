// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSTimeStamp wrapper class

class IMCSTimeStamp : public COleDispatchDriver
{
public:
	IMCSTimeStamp(){} // Calls COleDispatchDriver default constructor
	IMCSTimeStamp(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSTimeStamp(const IMCSTimeStamp& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSTimeStamp methods
public:
	short GetYear()
	{
		short result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetMonth()
	{
		short result;
		InvokeHelper(0x2, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetDay()
	{
		short result;
		InvokeHelper(0x3, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetHour()
	{
		short result;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetMinute()
	{
		short result;
		InvokeHelper(0x5, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetSecond()
	{
		short result;
		InvokeHelper(0x6, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetMillisecond()
	{
		short result;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetMicrosecond()
	{
		short result;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetNanosecond()
	{
		short result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	long GetSecondFromStart()
	{
		long result;
		InvokeHelper(0xa, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	short GetMillisecondFromStart()
	{
		short result;
		InvokeHelper(0xb, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetMicrosecondFromStart()
	{
		short result;
		InvokeHelper(0xc, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetNanosecondFromStart()
	{
		short result;
		InvokeHelper(0xd, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	void SetMillisecondFromStart(short sMilli)
	{
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_EMPTY, NULL, parms, sMilli);
	}
	void SetMicrosecondFromStart(short sMicro)
	{
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_EMPTY, NULL, parms, sMicro);
	}
	void SetNanosecondFromStart(short sNano)
	{
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_EMPTY, NULL, parms, sNano);
	}
	void SetSecondFromStart(long sSecond)
	{
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x11, DISPATCH_METHOD, VT_EMPTY, NULL, parms, sSecond);
	}
	LPDISPATCH Clone()
	{
		LPDISPATCH result;
		InvokeHelper(0x12, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	long GetTimeStampMinor()
	{
		long result;
		InvokeHelper(0x13, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetTimeStampMajor()
	{
		long result;
		InvokeHelper(0x14, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetStartTimeMajor()
	{
		long result;
		InvokeHelper(0x15, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetStartTimeMinor()
	{
		long result;
		InvokeHelper(0x16, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}

	// IMCSTimeStamp properties
public:

};

// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSInfoParam wrapper class

class IMCSInfoParam : public COleDispatchDriver
{
public:
	IMCSInfoParam(){} // Calls COleDispatchDriver default constructor
	IMCSInfoParam(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSInfoParam(const IMCSInfoParam& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSInfoParam methods
public:
	short MinPos()
	{
		short result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short MaxPos()
	{
		short result;
		InvokeHelper(0x2, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short TMinPos()
	{
		short result;
		InvokeHelper(0x3, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short TMaxPos()
	{
		short result;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short HeightPos()
	{
		short result;
		InvokeHelper(0x5, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short WidthPos()
	{
		short result;
		InvokeHelper(0x6, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short AmplitudePos()
	{
		short result;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short AreaPos()
	{
		short result;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short NumberPos()
	{
		short result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short RatePos()
	{
		short result;
		InvokeHelper(0xa, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short NumTimeWindows()
	{
		short result;
		InvokeHelper(0xb, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	CString InputBufferName()
	{
		CString result;
		InvokeHelper(0xc, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	float TimeWindowTime1()
	{
		float result;
		InvokeHelper(0xd, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	float TimeWindowTime2()
	{
		float result;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	short TimeWindowChoice()
	{
		short result;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short TimeWindowStartTriggerID()
	{
		short result;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short TimeWindowStopTriggerID()
	{
		short result;
		InvokeHelper(0x11, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short SlopePos()
	{
		short result;
		InvokeHelper(0x12, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}

	// IMCSInfoParam properties
public:

};

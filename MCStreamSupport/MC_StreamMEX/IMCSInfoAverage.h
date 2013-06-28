// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSInfoAverage wrapper class

class IMCSInfoAverage : public COleDispatchDriver
{
public:
	IMCSInfoAverage(){} // Calls COleDispatchDriver default constructor
	IMCSInfoAverage(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSInfoAverage(const IMCSInfoAverage& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSInfoAverage methods
public:
	CString GetTriggerBufferID()
	{
		CString result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	float GetTimeWindowStartTime()
	{
		float result;
		InvokeHelper(0x2, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	float GetTimeWindowWindowExtend()
	{
		float result;
		InvokeHelper(0x3, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	short GetMaxTimeWindowCount()
	{
		short result;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}

	// IMCSInfoAverage properties
public:

};

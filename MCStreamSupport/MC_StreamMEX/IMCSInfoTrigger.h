// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSInfoTrigger wrapper class

class IMCSInfoTrigger : public COleDispatchDriver
{
public:
	IMCSInfoTrigger(){} // Calls COleDispatchDriver default constructor
	IMCSInfoTrigger(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSInfoTrigger(const IMCSInfoTrigger& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSInfoTrigger methods
public:
	long GetChannel()
	{
		long result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetDeadTime()
	{
		long result;
		InvokeHelper(0x2, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetLevel()
	{
		long result;
		InvokeHelper(0x3, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSlope()
	{
		long result;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetTriggeredStreamId()
	{
		long result;
		InvokeHelper(0x5, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	BOOL IsDigitalTrigger()
	{
		BOOL result;
		InvokeHelper(0x6, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	long GetDigitalTriggerValue()
	{
		long result;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetDigitalTriggerType()
	{
		long result;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetDigitalTriggerMask()
	{
		long result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	CString GetInputBufferID()
	{
		CString result;
		InvokeHelper(0xa, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	BOOL IsParameterTrigger()
	{
		BOOL result;
		InvokeHelper(0xb, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	CString GetParameter()
	{
		CString result;
		InvokeHelper(0xc, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	CString GetParameterUnit()
	{
		CString result;
		InvokeHelper(0xd, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	BOOL TrialSynchronization()
	{
		BOOL result;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}

	// IMCSInfoTrigger properties
public:

};

// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSInfoFilter wrapper class

class IMCSInfoFilter : public COleDispatchDriver
{
public:
	IMCSInfoFilter(){} // Calls COleDispatchDriver default constructor
	IMCSInfoFilter(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSInfoFilter(const IMCSInfoFilter& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSInfoFilter methods
public:
	CString GetFilterName()
	{
		CString result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	long GetLowerCutoff()
	{
		long result;
		InvokeHelper(0x2, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetUpperCutoff()
	{
		long result;
		InvokeHelper(0x3, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	CString GetPassTypeAsString()
	{
		CString result;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	long GetPassType()
	{
		long result;
		InvokeHelper(0x5, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSGOrder()
	{
		long result;
		InvokeHelper(0x6, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSGNumSamples()
	{
		long result;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSGNumDataPointsLeft()
	{
		long result;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	double GetCenterFrequency()
	{
		double result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_R8, (void*)&result, NULL);
		return result;
	}
	double GetQFactor()
	{
		double result;
		InvokeHelper(0xa, DISPATCH_METHOD, VT_R8, (void*)&result, NULL);
		return result;
	}
	BOOL IsDownsamplingEnabled()
	{
		BOOL result;
		InvokeHelper(0xb, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	long GetDownsamplingFrequency()
	{
		long result;
		InvokeHelper(0xc, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetCutoff()
	{
		long result;
		InvokeHelper(0xd, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	BOOL IsSGFilter()
	{
		BOOL result;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	long GetFilterType()
	{
		long result;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}

	// IMCSInfoFilter properties
public:

};

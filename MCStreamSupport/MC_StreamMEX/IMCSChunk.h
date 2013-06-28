// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSChunk wrapper class

class IMCSChunk : public COleDispatchDriver
{
public:
	IMCSChunk(){} // Calls COleDispatchDriver default constructor
	IMCSChunk(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSChunk(const IMCSChunk& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSChunk methods
public:
	long ReadData(short * pBuffer)
	{
		long result;
		static BYTE parms[] = VTS_PI2 ;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I4, (void*)&result, parms, pBuffer);
		return result;
	}
	LPDISPATCH GetFirstEvent()
	{
		LPDISPATCH result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}

	// IMCSChunk properties
public:
	long GetFromHigh()
	{
		long result;
		GetProperty(0x1, VT_I4, (void*)&result);
		return result;
	}
	void SetFromHigh(long propVal)
	{
		SetProperty(0x1, VT_I4, propVal);
	}
	long GetFromLow()
	{
		long result;
		GetProperty(0x2, VT_I4, (void*)&result);
		return result;
	}
	void SetFromLow(long propVal)
	{
		SetProperty(0x2, VT_I4, propVal);
	}
	long GetToHigh()
	{
		long result;
		GetProperty(0x3, VT_I4, (void*)&result);
		return result;
	}
	void SetToHigh(long propVal)
	{
		SetProperty(0x3, VT_I4, propVal);
	}
	long GetToLow()
	{
		long result;
		GetProperty(0x4, VT_I4, (void*)&result);
		return result;
	}
	void SetToLow(long propVal)
	{
		SetProperty(0x4, VT_I4, propVal);
	}
	long GetSize()
	{
		long result;
		GetProperty(0x5, VT_I4, (void*)&result);
		return result;
	}
	void SetSize(long propVal)
	{
		SetProperty(0x5, VT_I4, propVal);
	}
	LPDISPATCH GetTimeStampTo()
	{
		LPDISPATCH result;
		GetProperty(0x6, VT_DISPATCH, (void*)&result);
		return result;
	}
	void SetTimeStampTo(LPDISPATCH propVal)
	{
		SetProperty(0x6, VT_DISPATCH, propVal);
	}
	LPDISPATCH GetTimeStampFrom()
	{
		LPDISPATCH result;
		GetProperty(0x7, VT_DISPATCH, (void*)&result);
		return result;
	}
	void SetTimeStampFrom(LPDISPATCH propVal)
	{
		SetProperty(0x7, VT_DISPATCH, propVal);
	}

};

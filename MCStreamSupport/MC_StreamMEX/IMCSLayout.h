// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSLayout wrapper class

class IMCSLayout : public COleDispatchDriver
{
public:
	IMCSLayout(){} // Calls COleDispatchDriver default constructor
	IMCSLayout(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSLayout(const IMCSLayout& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSLayout methods
public:
	LPDISPATCH GetChannelLayout(long Index)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, Index);
		return result;
	}
	long GetNumberOfConfigAmps()
	{
		long result;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	CString GetNameOfConfigAmp(long Index)
	{
		CString result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_BSTR, (void*)&result, parms, Index);
		return result;
	}
	long GetNumberOfConfigMEAs()
	{
		long result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	CString GetNameOfConfigMEA(long Index)
	{
		CString result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0xa, DISPATCH_METHOD, VT_BSTR, (void*)&result, parms, Index);
		return result;
	}
	CString GetMEANameFromHWID(long HWID)
	{
		CString result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0xb, DISPATCH_METHOD, VT_BSTR, (void*)&result, parms, HWID);
		return result;
	}
	CString GetAmplifierNameFromHWID(long HWID)
	{
		CString result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0xc, DISPATCH_METHOD, VT_BSTR, (void*)&result, parms, HWID);
		return result;
	}
	long GetMEAIndexFromHWID(long HWID)
	{
		long result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0xd, DISPATCH_METHOD, VT_I4, (void*)&result, parms, HWID);
		return result;
	}
	long GetChannelTypeFromHWID(long HWID)
	{
		long result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_I4, (void*)&result, parms, HWID);
		return result;
	}
	long GetRelativeChannelPosX(long MEAIndex, long HWID)
	{
		long result;
		static BYTE parms[] = VTS_I4 VTS_I4 ;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_I4, (void*)&result, parms, MEAIndex, HWID);
		return result;
	}
	long GetRelativeChannelPosY(long MEAIndex, long HWID)
	{
		long result;
		static BYTE parms[] = VTS_I4 VTS_I4 ;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_I4, (void*)&result, parms, MEAIndex, HWID);
		return result;
	}

	// IMCSLayout properties
public:
	long GetLayoutType()
	{
		long result;
		GetProperty(0x2, VT_I4, (void*)&result);
		return result;
	}
	void SetLayoutType(long propVal)
	{
		SetProperty(0x2, VT_I4, propVal);
	}
	long GetNTotal()
	{
		long result;
		GetProperty(0x3, VT_I4, (void*)&result);
		return result;
	}
	void SetNTotal(long propVal)
	{
		SetProperty(0x3, VT_I4, propVal);
	}
	long GetNElec()
	{
		long result;
		GetProperty(0x4, VT_I4, (void*)&result);
		return result;
	}
	void SetNElec(long propVal)
	{
		SetProperty(0x4, VT_I4, propVal);
	}
	long GetNAnlg()
	{
		long result;
		GetProperty(0x5, VT_I4, (void*)&result);
		return result;
	}
	void SetNAnlg(long propVal)
	{
		SetProperty(0x5, VT_I4, propVal);
	}
	long GetNDigi()
	{
		long result;
		GetProperty(0x6, VT_I4, (void*)&result);
		return result;
	}
	void SetNDigi(long propVal)
	{
		SetProperty(0x6, VT_I4, propVal);
	}

};

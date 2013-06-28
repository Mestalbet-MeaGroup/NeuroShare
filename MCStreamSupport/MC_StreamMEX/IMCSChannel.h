// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSChannel wrapper class

class IMCSChannel : public COleDispatchDriver
{
public:
	IMCSChannel(){} // Calls COleDispatchDriver default constructor
	IMCSChannel(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSChannel(const IMCSChannel& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSChannel methods
public:
	long GetRefBufferID(long Index)
	{
		long result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I4, (void*)&result, parms, Index);
		return result;
	}
	long GetRefChannelID(long Index)
	{
		long result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I4, (void*)&result, parms, Index);
		return result;
	}
	long GetGroupID()
	{
		long result;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}

	// IMCSChannel properties
public:
	long GetReferenceCount()
	{
		long result;
		GetProperty(0x1, VT_I4, (void*)&result);
		return result;
	}
	void SetReferenceCount(long propVal)
	{
		SetProperty(0x1, VT_I4, propVal);
	}
	short GetHeaderVersion()
	{
		short result;
		GetProperty(0x2, VT_I2, (void*)&result);
		return result;
	}
	void SetHeaderVersion(short propVal)
	{
		SetProperty(0x2, VT_I2, propVal);
	}
	long GetID()
	{
		long result;
		GetProperty(0x3, VT_I4, (void*)&result);
		return result;
	}
	void SetID(long propVal)
	{
		SetProperty(0x3, VT_I4, propVal);
	}
	CString GetName()
	{
		CString result;
		GetProperty(0x4, VT_BSTR, (void*)&result);
		return result;
	}
	void SetName(CString propVal)
	{
		SetProperty(0x4, VT_BSTR, propVal);
	}
	CString GetComment()
	{
		CString result;
		GetProperty(0x5, VT_BSTR, (void*)&result);
		return result;
	}
	void SetComment(CString propVal)
	{
		SetProperty(0x5, VT_BSTR, propVal);
	}
	long GetHWID()
	{
		long result;
		GetProperty(0x6, VT_I4, (void*)&result);
		return result;
	}
	void SetHWID(long propVal)
	{
		SetProperty(0x6, VT_I4, propVal);
	}
	CString GetDecoratedName()
	{
		CString result;
		GetProperty(0xa, VT_BSTR, (void*)&result);
		return result;
	}
	void SetDecoratedName(CString propVal)
	{
		SetProperty(0xa, VT_BSTR, propVal);
	}
	long GetGain()
	{
		long result;
		GetProperty(0xb, VT_I4, (void*)&result);
		return result;
	}
	void SetGain(long propVal)
	{
		SetProperty(0xb, VT_I4, propVal);
	}
	long GetPosX()
	{
		long result;
		GetProperty(0xc, VT_I4, (void*)&result);
		return result;
	}
	void SetPosX(long propVal)
	{
		SetProperty(0xc, VT_I4, propVal);
	}
	long GetPosY()
	{
		long result;
		GetProperty(0xd, VT_I4, (void*)&result);
		return result;
	}
	void SetPosY(long propVal)
	{
		SetProperty(0xd, VT_I4, propVal);
	}
	long GetPosZ()
	{
		long result;
		GetProperty(0xe, VT_I4, (void*)&result);
		return result;
	}
	void SetPosZ(long propVal)
	{
		SetProperty(0xe, VT_I4, propVal);
	}
	long GetExtendX()
	{
		long result;
		GetProperty(0xf, VT_I4, (void*)&result);
		return result;
	}
	void SetExtendX(long propVal)
	{
		SetProperty(0xf, VT_I4, propVal);
	}
	long GetExtendY()
	{
		long result;
		GetProperty(0x10, VT_I4, (void*)&result);
		return result;
	}
	void SetExtendY(long propVal)
	{
		SetProperty(0x10, VT_I4, propVal);
	}
	long GetDiameter()
	{
		long result;
		GetProperty(0x11, VT_I4, (void*)&result);
		return result;
	}
	void SetDiameter(long propVal)
	{
		SetProperty(0x11, VT_I4, propVal);
	}
	long GetDisplayX()
	{
		long result;
		GetProperty(0x12, VT_I4, (void*)&result);
		return result;
	}
	void SetDisplayX(long propVal)
	{
		SetProperty(0x12, VT_I4, propVal);
	}
	long GetDisplayY()
	{
		long result;
		GetProperty(0x13, VT_I4, (void*)&result);
		return result;
	}
	void SetDisplayY(long propVal)
	{
		SetProperty(0x13, VT_I4, propVal);
	}
	long GetDisplayExtendX()
	{
		long result;
		GetProperty(0x14, VT_I4, (void*)&result);
		return result;
	}
	void SetDisplayExtendX(long propVal)
	{
		SetProperty(0x14, VT_I4, propVal);
	}
	long GetDisplayExtendY()
	{
		long result;
		GetProperty(0x15, VT_I4, (void*)&result);
		return result;
	}
	void SetDisplayExtendY(long propVal)
	{
		SetProperty(0x15, VT_I4, propVal);
	}
	long GetLowF()
	{
		long result;
		GetProperty(0x16, VT_I4, (void*)&result);
		return result;
	}
	void SetLowF(long propVal)
	{
		SetProperty(0x16, VT_I4, propVal);
	}
	long GetHighF()
	{
		long result;
		GetProperty(0x17, VT_I4, (void*)&result);
		return result;
	}
	void SetHighF(long propVal)
	{
		SetProperty(0x17, VT_I4, propVal);
	}

};

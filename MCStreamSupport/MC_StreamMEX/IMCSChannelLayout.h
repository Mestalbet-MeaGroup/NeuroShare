// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSChannelLayout wrapper class

class IMCSChannelLayout : public COleDispatchDriver
{
public:
	IMCSChannelLayout(){} // Calls COleDispatchDriver default constructor
	IMCSChannelLayout(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSChannelLayout(const IMCSChannelLayout& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSChannelLayout methods
public:

	// IMCSChannelLayout properties
public:
	long GetHWID()
	{
		long result;
		GetProperty(0x1, VT_I4, (void*)&result);
		return result;
	}
	void SetHWID(long propVal)
	{
		SetProperty(0x1, VT_I4, propVal);
	}
	long GetMeaSubType()
	{
		long result;
		GetProperty(0x2, VT_I4, (void*)&result);
		return result;
	}
	void SetMeaSubType(long propVal)
	{
		SetProperty(0x2, VT_I4, propVal);
	}
	long GetGain()
	{
		long result;
		GetProperty(0x3, VT_I4, (void*)&result);
		return result;
	}
	void SetGain(long propVal)
	{
		SetProperty(0x3, VT_I4, propVal);
	}
	long GetLowF()
	{
		long result;
		GetProperty(0x4, VT_I4, (void*)&result);
		return result;
	}
	void SetLowF(long propVal)
	{
		SetProperty(0x4, VT_I4, propVal);
	}
	long GetHighF()
	{
		long result;
		GetProperty(0x5, VT_I4, (void*)&result);
		return result;
	}
	void SetHighF(long propVal)
	{
		SetProperty(0x5, VT_I4, propVal);
	}
	CString GetName()
	{
		CString result;
		GetProperty(0x6, VT_BSTR, (void*)&result);
		return result;
	}
	void SetName(CString propVal)
	{
		SetProperty(0x6, VT_BSTR, propVal);
	}
	CString GetDecoratedName()
	{
		CString result;
		GetProperty(0x7, VT_BSTR, (void*)&result);
		return result;
	}
	void SetDecoratedName(CString propVal)
	{
		SetProperty(0x7, VT_BSTR, propVal);
	}
	long GetMeaNumber()
	{
		long result;
		GetProperty(0x8, VT_I4, (void*)&result);
		return result;
	}
	void SetMeaNumber(long propVal)
	{
		SetProperty(0x8, VT_I4, propVal);
	}
	CString GetMeaName()
	{
		CString result;
		GetProperty(0x9, VT_BSTR, (void*)&result);
		return result;
	}
	void SetMeaName(CString propVal)
	{
		SetProperty(0x9, VT_BSTR, propVal);
	}
	long GetElecType()
	{
		long result;
		GetProperty(0xa, VT_I4, (void*)&result);
		return result;
	}
	void SetElecType(long propVal)
	{
		SetProperty(0xa, VT_I4, propVal);
	}
	long GetX()
	{
		long result;
		GetProperty(0xb, VT_I4, (void*)&result);
		return result;
	}
	void SetX(long propVal)
	{
		SetProperty(0xb, VT_I4, propVal);
	}
	long GetY()
	{
		long result;
		GetProperty(0xc, VT_I4, (void*)&result);
		return result;
	}
	void SetY(long propVal)
	{
		SetProperty(0xc, VT_I4, propVal);
	}
	long GetZ()
	{
		long result;
		GetProperty(0xd, VT_I4, (void*)&result);
		return result;
	}
	void SetZ(long propVal)
	{
		SetProperty(0xd, VT_I4, propVal);
	}
	long GetXExtend()
	{
		long result;
		GetProperty(0xe, VT_I4, (void*)&result);
		return result;
	}
	void SetXExtend(long propVal)
	{
		SetProperty(0xe, VT_I4, propVal);
	}
	long GetYExtend()
	{
		long result;
		GetProperty(0xf, VT_I4, (void*)&result);
		return result;
	}
	void SetYExtend(long propVal)
	{
		SetProperty(0xf, VT_I4, propVal);
	}
	long GetDiameter()
	{
		long result;
		GetProperty(0x10, VT_I4, (void*)&result);
		return result;
	}
	void SetDiameter(long propVal)
	{
		SetProperty(0x10, VT_I4, propVal);
	}
	long GetDX()
	{
		long result;
		GetProperty(0x11, VT_I4, (void*)&result);
		return result;
	}
	void SetDX(long propVal)
	{
		SetProperty(0x11, VT_I4, propVal);
	}
	long GetDY()
	{
		long result;
		GetProperty(0x12, VT_I4, (void*)&result);
		return result;
	}
	void SetDY(long propVal)
	{
		SetProperty(0x12, VT_I4, propVal);
	}
	long GetDXExtend()
	{
		long result;
		GetProperty(0x13, VT_I4, (void*)&result);
		return result;
	}
	void SetDXExtend(long propVal)
	{
		SetProperty(0x13, VT_I4, propVal);
	}
	long GetDYExtend()
	{
		long result;
		GetProperty(0x14, VT_I4, (void*)&result);
		return result;
	}
	void SetDYExtend(long propVal)
	{
		SetProperty(0x14, VT_I4, propVal);
	}
	CString GetPinName()
	{
		CString result;
		GetProperty(0x15, VT_BSTR, (void*)&result);
		return result;
	}
	void SetPinName(CString propVal)
	{
		SetProperty(0x15, VT_BSTR, propVal);
	}
	CString GetAmplifierName()
	{
		CString result;
		GetProperty(0x16, VT_BSTR, (void*)&result);
		return result;
	}
	void SetAmplifierName(CString propVal)
	{
		SetProperty(0x16, VT_BSTR, propVal);
	}

};

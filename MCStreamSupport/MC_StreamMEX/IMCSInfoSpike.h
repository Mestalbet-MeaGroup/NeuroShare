// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSInfoSpike wrapper class

class IMCSInfoSpike : public COleDispatchDriver
{
public:
	IMCSInfoSpike(){} // Calls COleDispatchDriver default constructor
	IMCSInfoSpike(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSInfoSpike(const IMCSInfoSpike& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSInfoSpike methods
public:
	CString GetInputBufferID()
	{
		CString result;
		InvokeHelper(0x1, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	short GetDetectMethod()
	{
		short result;
		InvokeHelper(0x2, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetSortMethod()
	{
		short result;
		InvokeHelper(0x3, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	float GetPreTrigger()
	{
		float result;
		InvokeHelper(0x4, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	float GetPostTrigger()
	{
		float result;
		InvokeHelper(0x5, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	float GetDeadTime()
	{
		float result;
		InvokeHelper(0x6, DISPATCH_METHOD, VT_R4, (void*)&result, NULL);
		return result;
	}
	short GetChannelGroupID(short iChHWID)
	{
		short result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x7, DISPATCH_METHOD, VT_I2, (void*)&result, parms, iChHWID);
		return result;
	}
	short GetThresholdSlope(short iChHWID)
	{
		short result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x8, DISPATCH_METHOD, VT_I2, (void*)&result, parms, iChHWID);
		return result;
	}
	float GetSlopeDeltaV(short iChHWID)
	{
		float result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x9, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID);
		return result;
	}
	float GetSlopeMin(short iChHWID)
	{
		float result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0xa, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID);
		return result;
	}
	float GetSlopeMax(short iChHWID)
	{
		float result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0xb, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID);
		return result;
	}
	short GetSpikeUnitCount()
	{
		short result;
		InvokeHelper(0xc, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetSpikeUnitID(short iIndex)
	{
		short result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0xd, DISPATCH_METHOD, VT_I2, (void*)&result, parms, iIndex);
		return result;
	}
	float GetSpikeUnitWndTime(short iChHWID, short iUnitID)
	{
		float result;
		static BYTE parms[] = VTS_I2 VTS_I2 ;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID, iUnitID);
		return result;
	}
	float GetSpikeUnitWndMin(short iChHWID, short iUnitID)
	{
		float result;
		static BYTE parms[] = VTS_I2 VTS_I2 ;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID, iUnitID);
		return result;
	}
	float GetSpikeUnitWndMax(short iChHWID, short iUnitID)
	{
		float result;
		static BYTE parms[] = VTS_I2 VTS_I2 ;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID, iUnitID);
		return result;
	}
	float GetThresholdLevel(short iChHWID)
	{
		float result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x11, DISPATCH_METHOD, VT_R4, (void*)&result, parms, iChHWID);
		return result;
	}
	long GetPreTrigger_us()
	{
		long result;
		InvokeHelper(0x12, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetPostTrigger_us()
	{
		long result;
		InvokeHelper(0x13, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	unsigned long GetDeadTime_us()
	{
		unsigned long result;
		InvokeHelper(0x14, DISPATCH_METHOD, VT_UI4, (void*)&result, NULL);
		return result;
	}

	// IMCSInfoSpike properties
public:

};

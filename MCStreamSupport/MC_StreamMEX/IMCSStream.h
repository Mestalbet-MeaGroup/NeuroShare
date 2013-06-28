// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSStream wrapper class

class IMCSStream : public COleDispatchDriver
{
public:
	IMCSStream(){} // Calls COleDispatchDriver default constructor
	IMCSStream(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSStream(const IMCSStream& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSStream methods
public:
	LPDISPATCH GetChannel(short Index)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, Index);
		return result;
	}
	void Reset()
	{
		InvokeHelper(0x11, DISPATCH_METHOD, VT_EMPTY, NULL, NULL);
	}
	LPDISPATCH GetFirstChunk()
	{
		LPDISPATCH result;
		InvokeHelper(0x12, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetNextChunk(LPDISPATCH pCurrentChunk)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_DISPATCH ;
		InvokeHelper(0x13, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, pCurrentChunk);
		return result;
	}
	LPDISPATCH GetFirstEvent()
	{
		LPDISPATCH result;
		InvokeHelper(0x14, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetNextEvent(LPDISPATCH pCurrentEvent)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_DISPATCH ;
		InvokeHelper(0x15, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, pCurrentEvent);
		return result;
	}
	long GetStreamFormatPrivate(long * pData)
	{
		long result;
		static BYTE parms[] = VTS_PI4 ;
		InvokeHelper(0x16, DISPATCH_METHOD, VT_I4, (void*)&result, parms, pData);
		return result;
	}
	CString GetChannelName(short Index)
	{
		CString result;
		static BYTE parms[] = VTS_I2 ;
		InvokeHelper(0x17, DISPATCH_METHOD, VT_BSTR, (void*)&result, parms, Index);
		return result;
	}
	LPDISPATCH GetChunkNextTo(LPDISPATCH ts)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_DISPATCH ;
		InvokeHelper(0x18, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, ts);
		return result;
	}
	LPDISPATCH GetEventNextTo(LPDISPATCH ts)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_DISPATCH ;
		InvokeHelper(0x19, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, ts);
		return result;
	}
	void EventCountFromTo(LPDISPATCH dispFrom, LPDISPATCH dispTo, long * arrEventCount)
	{
		static BYTE parms[] = VTS_DISPATCH VTS_DISPATCH VTS_PI4 ;
		InvokeHelper(0x1a, DISPATCH_METHOD, VT_EMPTY, NULL, parms, dispFrom, dispTo, arrEventCount);
	}
	LPDISPATCH GetInfo()
	{
		LPDISPATCH result;
		InvokeHelper(0x1b, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	CString GetBufferID()
	{
		CString result;
		InvokeHelper(0x1c, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	BOOL HasRawData()
	{
		BOOL result;
		InvokeHelper(0x1d, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	BOOL HasContinuousData()
	{
		BOOL result;
		InvokeHelper(0x1e, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	long GetRawDataBufferSizeOfChannel()
	{
		long result;
		InvokeHelper(0x1f, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetRawDataOfChannel(short * pData, long lIndex)
	{
		long result;
		static BYTE parms[] = VTS_PI2 VTS_I4 ;
		InvokeHelper(0x20, DISPATCH_METHOD, VT_I4, (void*)&result, parms, pData, lIndex);
		return result;
	}
	long GetRawData(short * pData, LPDISPATCH tsFrom, LPDISPATCH tsTo)
	{
		long result;
		static BYTE parms[] = VTS_PI2 VTS_DISPATCH VTS_DISPATCH ;
		InvokeHelper(0x21, DISPATCH_METHOD, VT_I4, (void*)&result, parms, pData, tsFrom, tsTo);
		return result;
	}
	long GetRawDataBufferSize(LPDISPATCH tsFrom, LPDISPATCH tsTo)
	{
		long result;
		static BYTE parms[] = VTS_DISPATCH VTS_DISPATCH ;
		InvokeHelper(0x22, DISPATCH_METHOD, VT_I4, (void*)&result, parms, tsFrom, tsTo);
		return result;
	}
	long GetSweepRawDataBufferSize(long lSweepIndex)
	{
		long result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x23, DISPATCH_METHOD, VT_I4, (void*)&result, parms, lSweepIndex);
		return result;
	}
	long GetSweepRawData(short * pData, long lSweepIndex)
	{
		long result;
		static BYTE parms[] = VTS_PI2 VTS_I4 ;
		InvokeHelper(0x24, DISPATCH_METHOD, VT_I4, (void*)&result, parms, pData, lSweepIndex);
		return result;
	}
	long GetSampleRate()
	{
		long result;
		InvokeHelper(0x25, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}

	// IMCSStream properties
public:
	long GetChannelCount()
	{
		long result;
		GetProperty(0x1, VT_I4, (void*)&result);
		return result;
	}
	void SetChannelCount(long propVal)
	{
		SetProperty(0x1, VT_I4, propVal);
	}
	long GetHeaderVersion()
	{
		long result;
		GetProperty(0x2, VT_I4, (void*)&result);
		return result;
	}
	void SetHeaderVersion(long propVal)
	{
		SetProperty(0x2, VT_I4, propVal);
	}
	CString GetDataType()
	{
		CString result;
		GetProperty(0x3, VT_BSTR, (void*)&result);
		return result;
	}
	void SetDataType(CString propVal)
	{
		SetProperty(0x3, VT_BSTR, propVal);
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
	short GetID()
	{
		short result;
		GetProperty(0x6, VT_I2, (void*)&result);
		return result;
	}
	void SetID(short propVal)
	{
		SetProperty(0x6, VT_I2, propVal);
	}
	long GetMillisamplesPerSecond()
	{
		long result;
		GetProperty(0x7, VT_I4, (void*)&result);
		return result;
	}
	void SetMillisamplesPerSecond(long propVal)
	{
		SetProperty(0x7, VT_I4, propVal);
	}
	short GetFormatVersion()
	{
		short result;
		GetProperty(0x8, VT_I2, (void*)&result);
		return result;
	}
	void SetFormatVersion(short propVal)
	{
		SetProperty(0x8, VT_I2, propVal);
	}
	short GetUnitSign()
	{
		short result;
		GetProperty(0x9, VT_I2, (void*)&result);
		return result;
	}
	void SetUnitSign(short propVal)
	{
		SetProperty(0x9, VT_I2, propVal);
	}
	short GetADBits()
	{
		short result;
		GetProperty(0xa, VT_I2, (void*)&result);
		return result;
	}
	void SetADBits(short propVal)
	{
		SetProperty(0xa, VT_I2, propVal);
	}
	long GetADZero()
	{
		long result;
		GetProperty(0xb, VT_I4, (void*)&result);
		return result;
	}
	void SetADZero(long propVal)
	{
		SetProperty(0xb, VT_I4, propVal);
	}
	double GetUnitsPerAD()
	{
		double result;
		GetProperty(0xc, VT_R8, (void*)&result);
		return result;
	}
	void SetUnitsPerAD(double propVal)
	{
		SetProperty(0xc, VT_R8, propVal);
	}
	short GetBytesPerChannel()
	{
		short result;
		GetProperty(0xd, VT_I2, (void*)&result);
		return result;
	}
	void SetBytesPerChannel(short propVal)
	{
		SetProperty(0xd, VT_I2, propVal);
	}
	short GetDefaultSamplesPerSegment()
	{
		short result;
		GetProperty(0xe, VT_I2, (void*)&result);
		return result;
	}
	void SetDefaultSamplesPerSegment(short propVal)
	{
		SetProperty(0xe, VT_I2, propVal);
	}
	short GetDefaultSegmentCount()
	{
		short result;
		GetProperty(0xf, VT_I2, (void*)&result);
		return result;
	}
	void SetDefaultSegmentCount(short propVal)
	{
		SetProperty(0xf, VT_I2, propVal);
	}

};

// Machine generated IDispatch wrapper class(es) created with Add Class from Typelib Wizard

// IMCSStreamFile wrapper class

class IMCSStreamFile : public COleDispatchDriver
{
public:
	IMCSStreamFile(){} // Calls COleDispatchDriver default constructor
	IMCSStreamFile(LPDISPATCH pDispatch) : COleDispatchDriver(pDispatch) {}
	IMCSStreamFile(const IMCSStreamFile& dispatchSrc) : COleDispatchDriver(dispatchSrc) {}

	// Attributes
public:

	// Operations
public:


	// IMCSStreamFile methods
public:
	short OpenFile(LPCTSTR szFileName)
	{
		short result;
		static BYTE parms[] = VTS_BSTR ;
		InvokeHelper(0xe, DISPATCH_METHOD, VT_I2, (void*)&result, parms, szFileName);
		return result;
	}
	short CloseFile()
	{
		short result;
		InvokeHelper(0xf, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetStream(long Index)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x10, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, Index);
		return result;
	}
	long GetSweepCount()
	{
		long result;
		InvokeHelper(0x11, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSweepLength()
	{
		long result;
		InvokeHelper(0x12, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetSweepStartTimeAt(long lSweep)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x13, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, lSweep);
		return result;
	}
	LPDISPATCH GetSweepEndTimeAt(long lSweep)
	{
		LPDISPATCH result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x14, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, parms, lSweep);
		return result;
	}
	long GetStartTriggerStreamID()
	{
		long result;
		InvokeHelper(0x15, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetStopTriggerStreamID()
	{
		long result;
		InvokeHelper(0x16, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetPreTriggerTime()
	{
		long result;
		InvokeHelper(0x17, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetPostTriggerTime()
	{
		long result;
		InvokeHelper(0x18, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetTimeStamp()
	{
		LPDISPATCH result;
		InvokeHelper(0x19, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	short GetSourceType()
	{
		short result;
		InvokeHelper(0x1a, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetStopTime()
	{
		LPDISPATCH result;
		InvokeHelper(0x1b, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	BOOL GetWithIndex()
	{
		BOOL result;
		InvokeHelper(0x1c, DISPATCH_METHOD, VT_BOOL, (void*)&result, NULL);
		return result;
	}
	long GetSoftwareVersionMajor()
	{
		long result;
		InvokeHelper(0x1d, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSoftwareVersionMinor()
	{
		long result;
		InvokeHelper(0x1e, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetSegmentTime()
	{
		long result;
		InvokeHelper(0x1f, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	short GetElectrodeChannels()
	{
		short result;
		InvokeHelper(0x20, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetAnalogChannels()
	{
		short result;
		InvokeHelper(0x21, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetDigitalChannels()
	{
		short result;
		InvokeHelper(0x22, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetTotalChannels()
	{
		short result;
		InvokeHelper(0x23, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	long GetDriverVersionMajor()
	{
		long result;
		InvokeHelper(0x24, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetDriverVersionMinor()
	{
		long result;
		InvokeHelper(0x25, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetTimeStampStartPressed()
	{
		LPDISPATCH result;
		InvokeHelper(0x26, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetStartTime()
	{
		LPDISPATCH result;
		InvokeHelper(0x27, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	short OpenFileEx(LPCTSTR szFileName)
	{
		short result;
		static BYTE parms[] = VTS_BSTR ;
		InvokeHelper(0x28, DISPATCH_METHOD, VT_I2, (void*)&result, parms, szFileName);
		return result;
	}
	CString GetImageFilePathName(long imageIndex)
	{
		CString result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x29, DISPATCH_METHOD, VT_BSTR, (void*)&result, parms, imageIndex);
		return result;
	}
	void GetImageData(long imageIndex, long * selectedElec1, long * selectedElec2, long * xLayoutPosElec1, long * yLayoutPosElec1, long * xLayoutPosElec2, long * yLayoutPosElec2, double * xImagePosElec1, double * yImagePosElec1, double * xImagePosElec2, double * yImagePosElec2)
	{
		static BYTE parms[] = VTS_I4 VTS_PI4 VTS_PI4 VTS_PI4 VTS_PI4 VTS_PI4 VTS_PI4 VTS_PR8 VTS_PR8 VTS_PR8 VTS_PR8 ;
		InvokeHelper(0x2a, DISPATCH_METHOD, VT_EMPTY, NULL, parms, imageIndex, selectedElec1, selectedElec2, xLayoutPosElec1, yLayoutPosElec1, xLayoutPosElec2, yLayoutPosElec2, xImagePosElec1, yImagePosElec1, xImagePosElec2, yImagePosElec2);
	}
	short GetElectrodeChannels2()
	{
		short result;
		InvokeHelper(0x2b, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetAnalogChannels2()
	{
		short result;
		InvokeHelper(0x2c, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetElectrodeChannelOffset1()
	{
		short result;
		InvokeHelper(0x2d, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetElectrodeChannelOffset2()
	{
		short result;
		InvokeHelper(0x2e, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetAnalogChannelOffset1()
	{
		short result;
		InvokeHelper(0x2f, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	short GetAnalogChannelOffset2()
	{
		short result;
		InvokeHelper(0x30, DISPATCH_METHOD, VT_I2, (void*)&result, NULL);
		return result;
	}
	long GetVoltageRange()
	{
		long result;
		InvokeHelper(0x31, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	unsigned __int64 GetSweepRawStartTimeAt(long sweepIndex)
	{
		unsigned __int64 result;
		static BYTE parms[] = VTS_I4 ;
		InvokeHelper(0x32, DISPATCH_METHOD, VT_UI8, (void*)&result, parms, sweepIndex);
		return result;
	}
	LPDISPATCH GetLayout()
	{
		LPDISPATCH result;
		InvokeHelper(0x33, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}
	long MCRack_DataSourceType()
	{
		long result;
		InvokeHelper(0x34, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	CString GetDataSourceName()
	{
		CString result;
		InvokeHelper(0x35, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	CString GetSerialNumber()
	{
		CString result;
		InvokeHelper(0x36, DISPATCH_METHOD, VT_BSTR, (void*)&result, NULL);
		return result;
	}
	long GetBusType()
	{
		long result;
		InvokeHelper(0x37, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetVendorId()
	{
		long result;
		InvokeHelper(0x38, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	long GetProductId()
	{
		long result;
		InvokeHelper(0x39, DISPATCH_METHOD, VT_I4, (void*)&result, NULL);
		return result;
	}
	LPDISPATCH GetMea21StimulatorProperty()
	{
		LPDISPATCH result;
		InvokeHelper(0x3a, DISPATCH_METHOD, VT_DISPATCH, (void*)&result, NULL);
		return result;
	}

	// IMCSStreamFile properties
public:
	short GetHeaderVersion()
	{
		short result;
		GetProperty(0x1, VT_I2, (void*)&result);
		return result;
	}
	void SetHeaderVersion(short propVal)
	{
		SetProperty(0x1, VT_I2, propVal);
	}
	long GetStreamCount()
	{
		long result;
		GetProperty(0x2, VT_I4, (void*)&result);
		return result;
	}
	void SetStreamCount(long propVal)
	{
		SetProperty(0x2, VT_I4, propVal);
	}
	long GetMillisamplesPerSecond()
	{
		long result;
		GetProperty(0x3, VT_I4, (void*)&result);
		return result;
	}
	void SetMillisamplesPerSecond(long propVal)
	{
		SetProperty(0x3, VT_I4, propVal);
	}
	CString GetComment()
	{
		CString result;
		GetProperty(0x4, VT_BSTR, (void*)&result);
		return result;
	}
	void SetComment(CString propVal)
	{
		SetProperty(0x4, VT_BSTR, propVal);
	}
	short GetYear()
	{
		short result;
		GetProperty(0x5, VT_I2, (void*)&result);
		return result;
	}
	void SetYear(short propVal)
	{
		SetProperty(0x5, VT_I2, propVal);
	}
	short GetMonth()
	{
		short result;
		GetProperty(0x6, VT_I2, (void*)&result);
		return result;
	}
	void SetMonth(short propVal)
	{
		SetProperty(0x6, VT_I2, propVal);
	}
	short GetDay()
	{
		short result;
		GetProperty(0x7, VT_I2, (void*)&result);
		return result;
	}
	void SetDay(short propVal)
	{
		SetProperty(0x7, VT_I2, propVal);
	}
	short GetHour()
	{
		short result;
		GetProperty(0x8, VT_I2, (void*)&result);
		return result;
	}
	void SetHour(short propVal)
	{
		SetProperty(0x8, VT_I2, propVal);
	}
	short GetMinute()
	{
		short result;
		GetProperty(0x9, VT_I2, (void*)&result);
		return result;
	}
	void SetMinute(short propVal)
	{
		SetProperty(0x9, VT_I2, propVal);
	}
	short GetSecond()
	{
		short result;
		GetProperty(0xa, VT_I2, (void*)&result);
		return result;
	}
	void SetSecond(short propVal)
	{
		SetProperty(0xa, VT_I2, propVal);
	}
	short GetMillisecond()
	{
		short result;
		GetProperty(0xb, VT_I2, (void*)&result);
		return result;
	}
	void SetMillisecond(short propVal)
	{
		SetProperty(0xb, VT_I2, propVal);
	}
	short GetMicrosecond()
	{
		short result;
		GetProperty(0xc, VT_I2, (void*)&result);
		return result;
	}
	void SetMicrosecond(short propVal)
	{
		SetProperty(0xc, VT_I2, propVal);
	}
	short GetNanosecond()
	{
		short result;
		GetProperty(0xd, VT_I2, (void*)&result);
		return result;
	}
	void SetNanosecond(short propVal)
	{
		SetProperty(0xd, VT_I2, propVal);
	}

};

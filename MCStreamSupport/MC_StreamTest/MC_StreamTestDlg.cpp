// MC_StreamTestDlg.cpp : implementation file
//

#include "stdafx.h"
#include "MC_StreamTest.h"
#include "MC_StreamTestDlg.h"

//#include <AtlBase.H>
//#include <AtlConv.H>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()



CMC_StreamTestDlg::CMC_StreamTestDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMC_StreamTestDlg::IDD, pParent)
    , m_FileInfo(_T(""))
    , m_StreamInfo(_T(""))
	, m_ChannelInfo(_T(""))
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_CurrentStreamIndex = -1;
}

void CMC_StreamTestDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDT_FILE_INFO, m_FileInfo);
	DDX_Control(pDX, IDC_LIST_STREAMS, m_ListBoxStreams);
	DDX_Text(pDX, IDC_EDT_STREAM_INFO, m_StreamInfo);
	DDX_Control(pDX, IDC_LIST_CHANNELS, m_ListBoxChannels);
	DDX_Control(pDX, IDC_BTN_READ_DATA, m_ButtonReadData);
	DDX_Text(pDX, IDC_EDT_CHANNEL_INFO, m_ChannelInfo);
	DDX_Control(pDX, IDC_BTN_EXPORT_CHANNEL_INFO, m_btnExportChannelInfo);
}

BEGIN_MESSAGE_MAP(CMC_StreamTestDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
    ON_BN_CLICKED(IDC_BUTTON1, &CMC_StreamTestDlg::OnBnClickedBtnQuickTest)
    ON_BN_CLICKED(IDC_BTN_OPEN_MCD_FILE, &CMC_StreamTestDlg::OnBnClickedBtnOpenMcdFile)
    ON_LBN_SELCHANGE(IDC_LIST_STREAMS, &CMC_StreamTestDlg::OnLbnSelchangeListStreams)
    ON_BN_CLICKED(IDC_BTN_ABOUT, &CMC_StreamTestDlg::OnBnClickedBtnAbout)
    ON_BN_CLICKED(IDC_BTN_READ_DATA, &CMC_StreamTestDlg::OnBnClickedBtnReadData)
    ON_LBN_SELCHANGE(IDC_LIST_CHANNELS, &CMC_StreamTestDlg::OnLbnSelchangeListChannels)
    ON_BN_CLICKED(IDC_BTN_SAVE_INFO, &CMC_StreamTestDlg::OnBnClickedBtnSaveInfo)
	ON_BN_CLICKED(IDC_BTN_EXPORT_CHANNEL_INFO, &CMC_StreamTestDlg::OnBnClickedBtnExportChannelInfo)
END_MESSAGE_MAP()


// CMC_StreamTestDlg message handlers

BOOL CMC_StreamTestDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization here
    HRESULT res = m_IStreamFile.CoCreateInstance(_bstr_t("MCSTREAM.MCSSTRM"));
    if (res != S_OK)
    {
        MessageBox("Could not find registered MCStream.dll");
    }

#ifdef _DEBUG
	m_btnExportChannelInfo.ShowWindow(SW_SHOW);
#else
	m_btnExportChannelInfo.ShowWindow(SW_HIDE);
#endif

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CMC_StreamTestDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CMC_StreamTestDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CMC_StreamTestDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


void CMC_StreamTestDlg::OnBnClickedBtnQuickTest()
{
    QuickTestMCDFile();
}

//! create smart pointer from dispatch
template<class T> CComPtr<T> MakeSP(IDispatchPtr p)
{
    IDispatchPtr pStream = p;
    CComPtr<T> IStream = (T*)pStream.GetInterfacePtr();
    return IStream;
}

void CMC_StreamTestDlg::QuickTestMCDFile(void)
{
    CString strFilter = "MC_Rack Data (*.mcd)|*.mcd|All Files (*.*)|*.*||";
    CFileDialog dlg(
        TRUE,
        NULL,
        NULL,
        OFN_HIDEREADONLY | OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_NOCHANGEDIR,
        strFilter,
        this);

    if (dlg.DoModal() == IDOK)
    {
        CComPtr<MCStream::IMCSStreamFile> IMcdFile;
        HRESULT hres = IMcdFile.CoCreateInstance(_bstr_t("MCSTREAM.MCSSTRM"));
        if (hres != S_OK)
        {
            MessageBox("Could not find registered MCStream.dll");
            return;
        }
        // open the mcd file
        short res = IMcdFile->OpenFileEx(_bstr_t(dlg.GetPathName()));
        if (res != 0)
        {
            CString s;
            s = "Error loading file: ";
            s += dlg.GetPathName();
            s += "\n";

            switch(res)
            {
            case 0: break;
            case 1: s += "File can not be opened.";
                break;
            case 2: s += "Wrong file format.";
                break;
            case 3: s += "Wrong file header.";
                break;
            case 4: s += "Empty data file.";
                break;
            default: ASSERT(0);
            }
            AfxMessageBox(s);
            return;
        }

        // demonstrates how to handle TimeStamp dispatch
        IDispatchPtr pStart = IMcdFile->GetStartTime();
        IDispatchPtr pStop = IMcdFile->GetStopTime();
        CComPtr<MCStream::IMCSTimeStamp> ItsStart;
        CComPtr<MCStream::IMCSTimeStamp> ItsStop;
        ItsStart = (MCStream::IMCSTimeStamp*) pStart.GetInterfacePtr();
        ItsStop = (MCStream::IMCSTimeStamp*) pStop.GetInterfacePtr();

        long yearStart = ItsStart->GetYear();
        long monthStart = ItsStart->GetMonth();
        long dayStart = ItsStart->GetDay();
        long hourSart = ItsStart->GetHour();
        long minStart = ItsStart->GetMinute();
        long secStart = ItsStart->GetSecond();

        TRACE("Start time of file: %d-%d-%d %d:%d:%d\n", yearStart, monthStart, dayStart, hourSart, minStart, secStart);

        long numStreams = IMcdFile->GetStreamCount();

        // do something with the data streams
        CString buffers;
        buffers.Format("%d buffers in file: ", numStreams);
        for (int i=0; i<numStreams; i++)
        {
            CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(IMcdFile->GetStream(i));

            buffers += IStream->GetBufferID().GetBSTR();
            buffers += " ";
        }
        buffers += "\n";
        TRACE(buffers);

        if (numStreams > 0)
        {
            // get some channel info for first buffer
            CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(IMcdFile->GetStream(0));

            long numChannels = IStream->GetChannelCount();
            CString channels;
            CString bufID = IStream->GetBufferID();
            channels.Format("%d channels in buffer %s: ", numChannels, bufID); 
            for (int i=0; i<numChannels; i++)
            {
                CComPtr<MCStream::IMCSChannel> IChannel = MakeSP<MCStream::IMCSChannel>(IStream->GetChannel(static_cast<short>(i)));

                CString name = IChannel->GetDecoratedName();
                long hwID = IChannel->GetHWID();
                CString tmp;
                tmp.Format("ch: %s, HWID: %d, ", name, hwID);
                channels += tmp;
                if (i % 16 == 0)
                {
                    channels += "\n";
                    TRACE(channels);
                    channels = "";
                }
            }
            channels += "\n";
            TRACE(channels);
        }

        // now do something different for each different type of buffer
        for (int i=0; i<numStreams; i++)
        {
            CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(IMcdFile->GetStream(i));
            CString bufferID = IStream->GetBufferID();
            if (bufferID.Find("spks") != -1)
            {
                // see function ReadSpikeData()
            }
            else if (bufferID.Find("elec") != -1)
            {
                // read first 100 ms of raw data
                CComPtr<MCStream::IMCSTimeStamp> ItsStart = MakeSP<MCStream::IMCSTimeStamp>(IMcdFile->GetStartTime());

                ItsStart->SetNanosecondFromStart(0);
                ItsStart->SetMicrosecondFromStart(0);
                ItsStart->SetMillisecondFromStart(0);
                ItsStart->SetSecondFromStart(0);
                CComPtr<MCStream::IMCSTimeStamp> ItsEnd;

                // must create a new object
                IDispatchPtr pEnd;
                pEnd = ItsStart->Clone();
                ItsEnd = (MCStream::IMCSTimeStamp*)pEnd.GetInterfacePtr();
                ItsEnd->SetMillisecondFromStart(100);
                ItsEnd->SetMicrosecondFromStart(0);
                ItsEnd->SetNanosecondFromStart(0);
                ItsEnd->SetSecondFromStart(0);

                long eventCount = 0;
                IStream->EventCountFromTo(ItsStart, ItsEnd, &eventCount);
                TRACE("There are %d events in the first 100 ms\n", eventCount);

                long bufferSize = IStream->GetRawDataBufferSize(ItsStart, ItsEnd);
                short* pBuffer = new short[bufferSize];

                long rawDataCount = IStream->GetRawData(pBuffer, ItsStart, ItsEnd);
                if (bufferSize != rawDataCount)
                {
                    TRACE("error reading data\n");
                    delete[] pBuffer;
                    return;
                }

                TRACE("Data for first 100 ms\n");
                long numChannels = IStream->GetChannelCount();

                // for raw data the following can be asserted
                ASSERT(eventCount * numChannels == bufferSize);
                
                // example for channel 0
                int offset = 0;
                for (int i=0; i<100; i++)
                {
                    short d = pBuffer[(i*numChannels) + offset];
                    TRACE("%hd\n", d);
                    // the buffer contains the raw ADC data, these must be converted to real world units
                    // see function ReadContinuousRawData()
                }
                delete[] pBuffer;
            }
        }
        IMcdFile->CloseFile();
    }
}

void CMC_StreamTestDlg::OnBnClickedBtnOpenMcdFile()
{
    if (m_IStreamFile == NULL)
    {
        MessageBox("Could not get MCStream.dll interface");
        return;
    }
    m_IStreamFile->CloseFile();
    CString FileName;
    if (OpenMcdFile(FileName))
    {
        m_ButtonReadData.EnableWindow(FALSE);
        m_ListBoxStreams.ResetContent();
        m_ListBoxChannels.ResetContent();
        m_StreamInfo = "";
		m_ChannelInfo = "";

		m_FileName = FileName;

        m_FileInfo = FileName;
        m_FileInfo += "\r\n";
        m_FileInfo += "Start time: ";
        m_FileInfo += GetStartTime();
        m_FileInfo += "  Stop time: ";
        m_FileInfo += GetStopTime();

        CString tmp;
        long numStreams = m_IStreamFile->GetStreamCount();
        for (int i=0; i<numStreams; i++)
        {
            CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(m_IStreamFile->GetStream(i));
            CString name = IStream->GetName();
            m_ListBoxStreams.AddString(name);


            // Check for first buffer only. All buffers have same adBits
            if (i == 0)
            {
                m_FileInfo += "\r\n";
                short adBits = IStream->ADBits;
                tmp.Format("Data Format: %hd bits", adBits);
                m_FileInfo += tmp;
            }
        }

        int swMajor = m_IStreamFile->GetSoftwareVersionMajor();
        int swMajor1 = swMajor >> 16;
        int swMajor2 = swMajor & 0x0000FFFF;
        int swMinor = m_IStreamFile->GetSoftwareVersionMinor();
        int swMinor1 = swMinor >> 16;
        int swMinor2 = swMinor  & 0x0000FFFF;
        tmp.Format("SW version: %d.%d.%d.%d", swMajor1, swMajor2, swMinor1, swMinor2);
        m_FileInfo += "\r\n";
        m_FileInfo += tmp;

        m_FileInfo += "\r\n";
        m_FileInfo += "--- Layout Info ---";


		CComPtr<MCStream::IMCSLayout> ILayout = MakeSP<MCStream::IMCSLayout>(m_IStreamFile->GetLayout());
		long lt = ILayout->LayoutType;
		CString tmp2;
		switch(lt)
		{
		case 0:
			tmp2 = "Linear (Plain) Layout";
			break;
		case 1:
			tmp2 = "Standard MEA Layout";
			break;
		case 2:
			tmp2 = "Double MEA Layout";
			break;
		case 3:
			tmp2 = "Defined Layout";
			break;
		default:
			ASSERT(0);
		}
		tmp.Format("Layout type %d: %s", lt, tmp2);		
        m_FileInfo += "\r\n";
        m_FileInfo += tmp;

		int numAmps = ILayout->GetNumberOfConfigAmps();
		if (numAmps > 0)
		{
			tmp.Format("Number of Amplifiers: %d", numAmps);
		}
		else
		{
			tmp = "No amplifiers configured";
		}
        m_FileInfo += "\r\n";
        m_FileInfo += tmp;
		if (lt == 3)
		{
			for (int i=0; i<numAmps; i++)
			{
				CString ampName = ILayout->GetNameOfConfigAmp(i);
				tmp.Format("%d: %s", i + 1, ampName);
				m_FileInfo += "\r\n";
				m_FileInfo += tmp;
			}
		}

		int numMEAs = ILayout->GetNumberOfConfigMEAs();
		if (numMEAs > 0)
		{
			tmp.Format("Number of MEAs: %d", numMEAs);
		}
		else
		{
			tmp = "No MEAs configured";
		}
        m_FileInfo += "\r\n";
        m_FileInfo += tmp;
		if (lt == 3)
		{
			for (int i=0; i<numMEAs; i++)
			{
				CString MEAName = ILayout->GetNameOfConfigMEA(i);
				tmp.Format("%d: %s", i + 1, MEAName);
				m_FileInfo += "\r\n";
				m_FileInfo += tmp;
			}
		}

		CComPtr<MCStream::IMCSMea21StimulatorProperty> IMea21StimulatorProperty = MakeSP<MCStream::IMCSMea21StimulatorProperty>(m_IStreamFile->GetMea21StimulatorProperty());
		long NumberOfStreams = IMea21StimulatorProperty->GetNumberOfStreams();
		
		UpdateData(FALSE);
    }
}

bool CMC_StreamTestDlg::OpenMcdFile(CString& fileName)
{
    CString strFilter = "MC_Rack Data (*.mcd)|*.mcd|All Files (*.*)|*.*||";
    CFileDialog dlg(
        TRUE,
        NULL,
        NULL,
        OFN_HIDEREADONLY | OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_NOCHANGEDIR,
        strFilter,
        this);

    if (dlg.DoModal() == IDOK)
    {
        short res = m_IStreamFile->OpenFileEx(_bstr_t(dlg.GetPathName()));
        if (res != 0)
        {
            CString s;
            s = "Error loading file: ";
            s += dlg.GetPathName();
            s += "\n";

            switch(res)
            {
            case 0: break;
            case 1: s += "File can not be opened.";
                break;
            case 2: s += "Wrong file format.";
                break;
            case 3: s += "Wrong file header.";
                break;
            case 4: s += "Empty data file.";
                break;
            default: ASSERT(0);
            }
            AfxMessageBox(s);
            return false;
        }
        else
        {
            fileName = dlg.GetFileName();
            return true;
        }
    }
    else
    {
        return false;
    }
}

CString CMC_StreamTestDlg::GetStartTime()
{
    CComPtr<MCStream::IMCSTimeStamp> ItsStart = MakeSP<MCStream::IMCSTimeStamp>(m_IStreamFile->GetStartTime());
    long yearStart = ItsStart->GetYear();
    long monthStart = ItsStart->GetMonth();
    long dayStart = ItsStart->GetDay();
    long hourSart = ItsStart->GetHour();
    long minStart = ItsStart->GetMinute();
    long secStart = ItsStart->GetSecond();
    CString time;
    time.Format("%d-%02d-%02d %02d:%02d:%02d", yearStart, monthStart, dayStart, hourSart, minStart, secStart);
    return time;
}

CString CMC_StreamTestDlg::GetStopTime()
{
    CComPtr<MCStream::IMCSTimeStamp> ItsStop = MakeSP<MCStream::IMCSTimeStamp>(m_IStreamFile->GetStopTime());
    long yearStart = ItsStop->GetYear();
    long monthStart = ItsStop->GetMonth();
    long dayStart = ItsStop->GetDay();
    long hourSart = ItsStop->GetHour();
    long minStart = ItsStop->GetMinute();
    long secStart = ItsStop->GetSecond();
    CString time;
    time.Format("%d-%02d-%02d %02d:%02d:%02d", yearStart, monthStart, dayStart, hourSart, minStart, secStart);
    return time;
}

void CMC_StreamTestDlg::OnLbnSelchangeListStreams()
{
    m_CurrentStreamIndex = m_ListBoxStreams.GetCurSel();
    CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(m_IStreamFile->GetStream(m_CurrentStreamIndex));

	//m_StreamInfo = "";
	m_ChannelInfo = "";

	m_StreamInfo.Format("Sample rate: %d Hz\r\n", IStream->GetSampleRate());

    CString bufferID = IStream->GetBufferID();
    if (bufferID.Find("elec") != -1 ||
        //bufferID.Find("filt") != -1 ||
        bufferID.Find("anlg") != -1 ||
        bufferID.Find("digi") != -1)
    {
        ReadRawInfo(IStream);
    }
    else if (bufferID.Find("filt") != -1)
    {
        ReadFilterInfo(IStream);
    }
    else if (bufferID.Find("spks") != -1)
    {
        ReadSpikeInfo(IStream);
    }
    else if (bufferID.Find("trig") != -1)
    {
        ReadTriggerInfo(IStream);
    }
    else if (bufferID.Find("mean") != -1)
    {
        ReadAverageInfo(IStream);
    }
    else if (bufferID.Find("para") != -1)
    {
        ReadParamInfo(IStream);
    }
    else if (bufferID.Find("sppa") != -1)
    {
        ReadSpikeParamInfo(IStream);
    }
	else if (bufferID.Find("bupa") != -1)
    {
        ReadBurstParamInfo(IStream);
    }
	else if (bufferID.Find("chtl") != -1)
	{
		ReadChannelToolInfo(IStream);
	}

    DisplayChannels(IStream);

    UpdateData(FALSE);
}

void CMC_StreamTestDlg::ReadSpikeInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoSpike> IInfoSpike = MakeSP<MCStream::IMCSInfoSpike>(IStream->GetInfo());
    short detectMethod = IInfoSpike->GetDetectMethod();
    short sortMethod = IInfoSpike->GetSortMethod();

	long preTrigger_us = IInfoSpike->GetPreTrigger_us();
	long postTrigger_us = IInfoSpike->GetPostTrigger_us();
	long deadTime_us = IInfoSpike->GetDeadTime_us();

	// these functions are deprecated from V 4.0
    //float preTrigger = IInfoSpike->GetPreTrigger();
    //float postTrigger = IInfoSpike->GetPostTrigger();
    //float deadTime = IInfoSpike->GetDeadTime();

    //unsigned int preTriggerMs = static_cast<unsigned int>(preTrigger*1000);
    //unsigned int postTriggerMs = static_cast<unsigned int>(postTrigger*1000);
    //unsigned int deadTimeMs = static_cast<unsigned int>(deadTime*1000);

    int preTriggerMs = preTrigger_us/1000;
    int postTriggerMs = postTrigger_us/1000;
    int deadTimeMs = deadTime_us/1000;


    for (int i=0; i<IStream->GetChannelCount(); i++)
    {
        CComPtr<MCStream::IMCSChannel> IChannel = MakeSP<MCStream::IMCSChannel>(IStream->GetChannel(static_cast<short>(i)));
        int chHWID = IChannel->GetHWID();
        ASSERT(chHWID <= 256);
        int iChBufferIndex = IChannel->GetID();
        CString csChannelName = IChannel->GetDecoratedName();
    }
    CString InfoLine;
    CString tmp;
    InfoLine.Format("No. channels: %d", IStream->GetChannelCount());
    tmp.Format("Pre Trigger: %d ms\tPost Trigger: %d ms", preTriggerMs, postTriggerMs);
    InfoLine += "\r\n";
    InfoLine += tmp;
    tmp.Format("Dead Time: %d ms", deadTimeMs);
    InfoLine += "\r\n";
    InfoLine += tmp;

    tmp = detectMethod == 0 ? "Threshold" : "Slope";
    tmp += " detection, ";
    tmp += sortMethod == 0 ? "not sorted" : "Window sorter";
    InfoLine += "\r\n";
    InfoLine += tmp;

    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadSpikeData(CComPtr<MCStream::IMCSStream>& IStream, int index)
{
    CComPtr<MCStream::IMCSEvtSpike> ISpikeEvent = MakeSP<MCStream::IMCSEvtSpike>(IStream->GetFirstEvent());
    if (ISpikeEvent != NULL)
    {
        short cont = 1;
        do
        {
            short channel = ISpikeEvent->Channel;
            if (channel == index)
            {
                int unitID = ISpikeEvent->GetUnitID(); //if 0 spike is not classified

                int seconds = ISpikeEvent->SecondFromStart;
                int milliS = ISpikeEvent->MillisecondFromStart;
                int microS = ISpikeEvent->MicrosecondFromStart;
                int nanoS = ISpikeEvent->NanosecondFromStart;

                int spikeTimeStamp = seconds +
                    (milliS) / 1000 +
                    (microS) / 1000000 +
                    (nanoS) / 1000000000;


                int adZero = IStream->ADZero;
                double unitsPerAD = IStream->UnitsPerAD;

                CString channelName = IStream->GetChannelName(channel);
				short HWID = ISpikeEvent->GetHWID();
				TRACE("Spike from channel %s, HWID: %hd\n", channelName, HWID);

                int dataArraySize = ISpikeEvent->Count;
                unsigned short* spikeDataBuffer = new unsigned short[dataArraySize];
                // the following cast is necessary, otherwise 16 bit data are not read correctly
                ISpikeEvent->GetADDataArray(reinterpret_cast<short*>(spikeDataBuffer));

                for (int i = 0; i < dataArraySize; ++i)
                {
                    double realWorldValue;
                    // value in V
                    realWorldValue = (*(spikeDataBuffer + i) - adZero) * unitsPerAD;
                    TRACE("%f\n", realWorldValue);
                }
                TRACE("\n");

                delete[] spikeDataBuffer;
            }
            cont = ISpikeEvent->Next();
        }
        while (cont == 1);
    }
}

void CMC_StreamTestDlg::ReadFilterInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoFilter> IInfoFilter = MakeSP<MCStream::IMCSInfoFilter>(IStream->GetInfo());
    CString InfoLine;
    CString tmp;
    InfoLine.Format("No. channels: %d", IStream->GetChannelCount());

	CString FilterName = IInfoFilter->GetFilterName();
	tmp.Format("Filter: %s", FilterName.GetString());
    InfoLine += "\r\n";
    InfoLine += tmp;

	if (IInfoFilter->IsSGFilter())
	{
		tmp.Format("Order: %d", IInfoFilter->GetSGOrder());
		InfoLine += "\r\n";
		InfoLine += tmp;
		tmp.Format("Num. Points: %d", IInfoFilter->GetSGNumDataPointsLeft());
		InfoLine += "\r\n";
		InfoLine += tmp;
	}
	else
	{
		// 0: Bessel 2nd order
		// 1: Bessel 4th order
		// 2: Butterworth 2nd order
		// 3: Chebyshev 2nd order 0.5 dB
		// 4: Chebyshev 2nd order 1.0 dB
		// 5: Chebyshev 2nd order 2.0 dB
		// 6: Chebyshev 2nd order 3.0 dB
		// 7: Bandstop Resonator
		// 8: Savitzky-Golay
		long FilterType = IInfoFilter->GetFilterType();
		if (FilterType == 7)
		{
			tmp.Format("Center freq.: %.0f Hz", IInfoFilter->GetCenterFrequency());
			InfoLine += "\r\n";
			InfoLine += tmp;
			tmp.Format("Q-factor: %.0f", IInfoFilter->GetQFactor());
			InfoLine += "\r\n";
			InfoLine += tmp;
		}
		else
		{
			CString PassType = IInfoFilter->GetPassTypeAsString();
			tmp.Format("Type: %s", PassType);
			InfoLine += "\r\n";
			InfoLine += tmp;
			tmp.Format("Cutoff frequency: %d", IInfoFilter->GetCutoff());
			InfoLine += "\r\n";
			InfoLine += tmp;
			 // 1: Low pass
			 // 2: High pass
			if (IInfoFilter->GetPassType() == 1)
			{
				if (IInfoFilter->IsDownsamplingEnabled())
				{
					tmp = "Downsampling: Yes";
					InfoLine += "\r\n";
					InfoLine += tmp;
					tmp.Format("Frequency: %d Hz", IInfoFilter->GetDownsamplingFrequency());
					InfoLine += "\r\n";
					InfoLine += tmp;
				}
				else
				{
					tmp = "Downsampling: No";
					InfoLine += "\r\n";
					InfoLine += tmp;
				}
			}
		}
	}
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadTriggerInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoTrigger> IInfoTrigger = MakeSP<MCStream::IMCSInfoTrigger>(IStream->GetInfo());
    CString inputBuffer = IInfoTrigger->GetInputBufferID();
    int channel = IInfoTrigger->GetChannel();
    int deadTime = IInfoTrigger->GetDeadTime();
    VARIANT_BOOL isDigital = IInfoTrigger->IsDigitalTrigger();
    VARIANT_BOOL isParam = IInfoTrigger->IsParameterTrigger();

    int streamID = IInfoTrigger->GetTriggeredStreamId();

    CString InfoLine;
    if (isDigital == VARIANT_TRUE)
    {
        int digitalType = IInfoTrigger->GetDigitalTriggerType();
        if (digitalType == 0)
        {
            InfoLine = "Type: <";
        }
        else if (digitalType == 1)
        {
            InfoLine = "Type: =";
        }
        else if (digitalType == 2)
        {
            InfoLine = "Type: >";
        }
        else
        {
            InfoLine = "unknown";
            ASSERT(0);
        }
        m_StreamInfo += InfoLine;
    }
    else if (isParam == VARIANT_TRUE)
    {
    }
    else
    {
        int level = IInfoTrigger->GetLevel();
        int slope = IInfoTrigger->GetSlope();
        if (slope == 0)
        {
            InfoLine.Format("Level: %d  Slope: pos", level/10);
        }
        else
        {
            InfoLine.Format("Level: %d  Slope: neg", level/10);
        }
    }

    m_StreamInfo += "\r\n";
    InfoLine.Format("Dead time: %d ms", deadTime);
    //m_StreamInfo = InfoLine;
    //m_StreamInfo += "\r\n";
    //InfoLine.Format("Start time: %.1f   Extend: %.1f", startTime, extend);
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadRawInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    //CComPtr<MCStream::IMCSInfoRaw> IInfoRaw = MakeSP<MCStream::IMCSInfoRaw>(IStream->GetInfo());

    // no info here
    //m_StreamInfo = "";
}

void CMC_StreamTestDlg::ReadContinuousRawData(CComPtr<MCStream::IMCSStream>& IStream, int index)
{
    int size = IStream->GetRawDataBufferSizeOfChannel();
    int adZero = IStream->ADZero;
    double unitsPerAD = IStream->UnitsPerAD;
    if (size > 0)
    {
        TRACE("reading %d samples of raw data from channel %d\n", size, index);
        short* pData = new short[size];
        IStream->GetRawDataOfChannel(pData, index);
        TRACE("raw data\n");
        for (int i=0; i<min(size, 1000); i++)
        {
            TRACE("%hd\n", pData[i]);
        }
        for (int i=0; i<min(size, 1000); i++)
        {
            // value in V
            double realWorldValue = ((unsigned short)(pData[i]) - adZero) * unitsPerAD;
            TRACE("%f\n", realWorldValue);
        }
    }
}

void CMC_StreamTestDlg::ReadTriggeredRawData(CComPtr<MCStream::IMCSStream>& IStream, int index)
{
    long sweepCount = m_IStreamFile->GetSweepCount();
	if (sweepCount > 0)
    {
        for(long sweep = 0; sweep < sweepCount; ++sweep)
        {
            CComPtr<MCStream::IMCSTimeStamp> ItsFrom = MakeSP<MCStream::IMCSTimeStamp>(m_IStreamFile->GetSweepStartTimeAt(sweep));
            int secondsFrom = ItsFrom->GetSecondFromStart();
            int milliSFrom = ItsFrom->GetMillisecondFromStart();

            CComPtr<MCStream::IMCSTimeStamp> ItsTo = MakeSP<MCStream::IMCSTimeStamp>(m_IStreamFile->GetSweepEndTimeAt(sweep));
            int secondsTo = ItsTo->GetSecondFromStart();
            int milliSTo = ItsTo->GetMillisecondFromStart();

            int adZero = IStream->ADZero;
            double unitsPerAD = IStream->UnitsPerAD;

            long bufferSize = IStream->GetRawDataBufferSize(ItsFrom, ItsTo);

            short* pData = new short[bufferSize];

            TRACE("Reading triggered data from channel %d, from %d.%ds to %d.%ds\n", index, secondsFrom, milliSFrom, secondsTo, milliSTo);

            long rawDataSize = IStream->GetRawData(pData, ItsFrom, ItsTo);
            if (bufferSize != rawDataSize)
            {
                ASSERT(0);
            }
            else
            {
                for (int i=0; i<min(bufferSize, 1000); i++)
                {
                    //TRACE("%hd\n", pData[i]);
                    double realWorldValue = ((unsigned short)(pData[i]) - adZero) * unitsPerAD;
                    TRACE("%f\n", realWorldValue);
                }
            }
            delete[] pData;
        }
    }
}

void CMC_StreamTestDlg::ReadAverageInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoAverage> IInfoAverage = MakeSP<MCStream::IMCSInfoAverage>(IStream->GetInfo());
    float startTime = IInfoAverage->GetTimeWindowStartTime();
    float extend = IInfoAverage->GetTimeWindowWindowExtend();
    CString bufferID = IInfoAverage->GetTriggerBufferID();
    short maxTimeWindowCount = IInfoAverage->GetMaxTimeWindowCount();
    CString InfoLine;
    InfoLine.Format("Input:    %s No. time windows: %hd", bufferID, maxTimeWindowCount);
    m_StreamInfo += InfoLine;
    m_StreamInfo += "\r\n";
    InfoLine.Format("Start time: %.1f   Extend: %.1f", startTime, extend);
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadAverageData(CComPtr<MCStream::IMCSStream>& IStream, int index)
{
    CComPtr<MCStream::IMCSEvtAverage> IAverageEvent = MakeSP<MCStream::IMCSEvtAverage>(IStream->GetFirstEvent());
    if (IAverageEvent != NULL)
    {
        short cont = 1;
        do
        {
            short channel = IAverageEvent->Channel;
            if (channel == index)
            {
                int adZero = IStream->ADZero;
                double unitsPerAD = IStream->UnitsPerAD;

                CString channelName = IStream->GetChannelName(channel);
				short HWID = IAverageEvent->GetHWID();
				TRACE("Average from channel %s, HWID: %hd\n", channelName, HWID);
                int dataArraySize = IAverageEvent->Count;
                unsigned short* dataBuffer = new unsigned short[dataArraySize];
                // the following cast is necessary, otherwise 16 bit data are not read correctly
                IAverageEvent->GetADDataArray(reinterpret_cast<short*>(dataBuffer));

                for (int i = 0; i < dataArraySize; ++i)
                {
                    double realWorldValue;
                    // value in V
                    realWorldValue = (*(dataBuffer + i) - adZero) * unitsPerAD;
                    TRACE("%f\n", realWorldValue);
                }
                TRACE("\n");

                delete[] dataBuffer;
            }
            cont = IAverageEvent->Next();
        }
        while (cont == 1);
    }
}

void CMC_StreamTestDlg::ReadParamInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoParam> IInfoParam = MakeSP<MCStream::IMCSInfoParam>(IStream->GetInfo());
    CString inputBuffer = IInfoParam->InputBufferName();
    CString InfoLine;
    InfoLine.Format("Input buffer: %s", inputBuffer);
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadSpikeParamInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoSpikeParameter> IInfoSpikeParam = MakeSP<MCStream::IMCSInfoSpikeParameter>(IStream->GetInfo());
    CString inputBuffer = IInfoSpikeParam->InputBufferName();
    int numParams = IInfoSpikeParam->ParameterCount();
    CString InfoLine;
    InfoLine.Format("Input buffer: %s  No. of params: %d", inputBuffer, numParams);
    //m_StreamInfo += InfoLine;
    CString tmpParams = "Params: ";;
    for (int i=0; i<numParams; i++)
    {
        bool paramSelected = IInfoSpikeParam->ParameterSelected(i) == VARIANT_TRUE;
        if (paramSelected)
        {
            _bstr_t paramName = IInfoSpikeParam->ParameterName(i);
            CString tmp = paramName;
            tmpParams += tmp;
            tmpParams += " ";
            double factor = IInfoSpikeParam->ParameterFactor(i);
            int exponent = IInfoSpikeParam->ParameterExponent(i);
            _bstr_t unit = IInfoSpikeParam->ParameterUnit(i);
        }
    }
    InfoLine += "\r\n";
    InfoLine += tmpParams;
    int numUnits = IInfoSpikeParam->UnitCount();
    int sortMethod = IInfoSpikeParam->UnitSortMethod();
    CString sMethod;
    sMethod.Format("Sort method: %s", sortMethod == 0 ? "No sorting" : "Window");
    InfoLine += "\r\n";
    InfoLine += sMethod;
    for (int i=0; i<numUnits; i++)
    {
        IInfoSpikeParam->UnitSelected(i);
    }
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadBurstParamInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoBurstParameter> IInfoBurstParam = MakeSP<MCStream::IMCSInfoBurstParameter>(IStream->GetInfo());
    CString inputBuffer = IInfoBurstParam->InputBufferName();
    int numParams = IInfoBurstParam->ParameterCount();
    CString InfoLine;
    InfoLine.Format("Input buffer: %s  No. of params: %d", inputBuffer, numParams);
    //m_StreamInfo += InfoLine;
    CString tmpParams = "Params: ";;
    for (int i=0; i<numParams; i++)
    {
        bool paramSelected = IInfoBurstParam->ParameterSelected(i) == VARIANT_TRUE;
        if (paramSelected)
        {
            _bstr_t paramName = IInfoBurstParam->ParameterName(i);
            CString tmp = paramName;
            tmpParams += tmp;
            tmpParams += " ";
            double factor = IInfoBurstParam->ParameterFactor(i);
            int exponent = IInfoBurstParam->ParameterExponent(i);
            _bstr_t unit = IInfoBurstParam->ParameterUnit(i);
        }
    }
    InfoLine += "\r\n";
    InfoLine += tmpParams;
    int numUnits = IInfoBurstParam->UnitCount();
    int sortMethod = IInfoBurstParam->UnitSortMethod();
    CString sMethod;
    sMethod.Format("Sort method: %s", sortMethod == 0 ? "No sorting" : "Window");
    InfoLine += "\r\n";
    InfoLine += sMethod;
    for (int i=0; i<numUnits; i++)
    {
        IInfoBurstParam->UnitSelected(i);
    }
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadChannelToolInfo(CComPtr<MCStream::IMCSStream>& IStream)
{
    CComPtr<MCStream::IMCSInfoChannelTool> IInfoChannelTool = MakeSP<MCStream::IMCSInfoChannelTool>(IStream->GetInfo());
    CString inputBuffer = IInfoChannelTool->InputBufferName();
	CString refChannelName = IInfoChannelTool->RefChannelName();
	CString InfoLine;
    InfoLine.Format("Input buffer: %s\r\nReference channel: %s", inputBuffer, refChannelName);
    m_StreamInfo += InfoLine;
}

void CMC_StreamTestDlg::ReadSpikeParameterData(CComPtr<MCStream::IMCSStream>& IStream, int index)
{
    CComPtr<MCStream::IMCSEvtSpikeParameter> ISpikeParameterEvent = MakeSP<MCStream::IMCSEvtSpikeParameter>(IStream->GetFirstEvent());
    CComPtr<MCStream::IMCSInfoSpikeParameter> IInfoSpikeParameter = MakeSP<MCStream::IMCSInfoSpikeParameter>(IStream->GetInfo());
    if (ISpikeParameterEvent != NULL)
    {
        short cont = 1;
        do
        {
            short channel = ISpikeParameterEvent->Channel;
            if (channel == index)
            {
                CString channelName = IStream->GetChannelName(channel);
                TRACE("Spike parameter from channel %s\n", channelName);

                unsigned long ParamID = 0;	// interspike interval
                double ISI = ISpikeParameterEvent->Parameter(ParamID) / IInfoSpikeParameter->ParameterFactor(ParamID);
                CString isiUnit = IInfoSpikeParameter->ParameterUnit(ParamID);			

                ParamID = 1;	// Rate
                double Rate = ISpikeParameterEvent->Parameter(ParamID) / IInfoSpikeParameter->ParameterFactor(ParamID);
                CString rateUnit = IInfoSpikeParameter->ParameterUnit(ParamID);

				// old MC_Rack versions produced files with two parameters
				if (IInfoSpikeParameter->ParameterCount() > 2)
				{
					ParamID = 2;	// Spike Timestamp
					double spikeTimestamp = ISpikeParameterEvent->Parameter(ParamID) / IInfoSpikeParameter->ParameterFactor(ParamID);
					// timestamps do not have parameter unit for display on y- axis
				}
            }
            cont = ISpikeParameterEvent->Next();
        }
        while (cont == 1);
    }
}

void CMC_StreamTestDlg::ReadBurstParameterData(CComPtr<MCStream::IMCSStream>& IStream, int index)
{
    CComPtr<MCStream::IMCSEvtBurstParameter> IBurstParameterEvent = MakeSP<MCStream::IMCSEvtBurstParameter>(IStream->GetFirstEvent());
    CComPtr<MCStream::IMCSInfoBurstParameter> IInfoBurstParameter = MakeSP<MCStream::IMCSInfoBurstParameter>(IStream->GetInfo());
    if (IBurstParameterEvent != NULL)
    {
        short cont = 1;
        do
        {
			short channel = IBurstParameterEvent->Channel;
			if (channel == index)
			{
				DWORDLONG timestamp = IBurstParameterEvent->GetTimeStampOfBurst();

				CString channelName = IStream->GetChannelName(channel);
				TRACE("Burst parameter from channel %s\n", channelName);

				unsigned long ParamID = 0;	// duration of burst
				double duration = IBurstParameterEvent->Parameter(ParamID) / IInfoBurstParameter->ParameterFactor(ParamID);
				CString durationUnit = IInfoBurstParameter->ParameterUnit(ParamID);			

				ParamID = 1;	// Spike frequency
				double spikeFrequency = IBurstParameterEvent->Parameter(ParamID) / IInfoBurstParameter->ParameterFactor(ParamID);
				CString spikeFrequencyUnit = IInfoBurstParameter->ParameterUnit(ParamID);

				ParamID = 2;	// Number of spikes in burst
				double numberOfSpikes = IBurstParameterEvent->Parameter(ParamID) / IInfoBurstParameter->ParameterFactor(ParamID);
				CString numberOfSpikesUnit = IInfoBurstParameter->ParameterUnit(ParamID);
            }
            cont = IBurstParameterEvent->Next();
        }
        while (cont == 1);
    }
}

void CMC_StreamTestDlg::DisplayChannels(ATL::CComPtr<MCStream::IMCSStream> &IStream)
{
    m_ListBoxChannels.ResetContent();
    for (int i=0; i<IStream->GetChannelCount(); i++)
    {
        CComPtr<MCStream::IMCSChannel> IChannel = MakeSP<MCStream::IMCSChannel>(IStream->GetChannel(static_cast<short>(i)));
        CString channelName = IChannel->GetDecoratedName();
		CString sHWID;
		sHWID.Format("%d", IChannel->GetHWID());
		channelName += " (HW ID: ";
		channelName += sHWID;
		channelName += ")";
        m_ListBoxChannels.AddString(channelName);
    }
}

void CMC_StreamTestDlg::OnLbnSelchangeListChannels()
{
    CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(m_IStreamFile->GetStream(m_CurrentStreamIndex));
	int chIndex = m_ListBoxChannels.GetCurSel();
	CComPtr<MCStream::IMCSChannel> IChannel = MakeSP<MCStream::IMCSChannel>(IStream->GetChannel(chIndex));
	m_ChannelInfo = "";
	CString tmp;

	long HWID = IChannel->GetHWID();
	CComPtr<MCStream::IMCSLayout> ILayout = MakeSP<MCStream::IMCSLayout>(m_IStreamFile->GetLayout());
	int MEAIndex = ILayout->GetMEAIndexFromHWID(HWID);
	tmp.Format("MEA Index: %d", MEAIndex);
	m_ChannelInfo += tmp;
	m_ChannelInfo += "\r\n";
	int relX = ILayout->GetRelativeChannelPosX(MEAIndex, HWID);
	tmp.Format("Rel. PosX: %d", relX);
	m_ChannelInfo += tmp;
	m_ChannelInfo += "\r\n";
	int relY = ILayout->GetRelativeChannelPosY(MEAIndex, HWID);
	tmp.Format("Rel. PosY: %d", relY);
	m_ChannelInfo += tmp;
	m_ChannelInfo += "\r\n";

	tmp.Format("PosX: %d", IChannel->PosX);
	m_ChannelInfo += tmp;
	m_ChannelInfo += "\r\n";
	tmp.Format("PosY: %d", IChannel->PosY);
	m_ChannelInfo += tmp;
	m_ChannelInfo += "\r\n";

    m_ButtonReadData.EnableWindow(TRUE);
	UpdateData(FALSE);
}

void CMC_StreamTestDlg::OnBnClickedBtnReadData()
{
    int indexStream = m_ListBoxStreams.GetCurSel();
    CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(m_IStreamFile->GetStream(indexStream));
    int indexChannel = m_ListBoxChannels.GetCurSel();
    CString bufferID = IStream->GetBufferID();
    if (bufferID.Find("elec") != -1 ||
		bufferID.Find("chtl") != -1 ||
        bufferID.Find("filt") != -1 ||
        bufferID.Find("anlg") != -1 ||
        bufferID.Find("digi") != -1)
    {
        if (IStream->HasRawData())
        {
            if (IStream->HasContinuousData())
            {
                ReadContinuousRawData(IStream, indexChannel);
            }
            else
            {
                ReadTriggeredRawData(IStream, indexChannel);
            }
        }
    }
    else if (bufferID.Find("spks") != -1)
    {
        ReadSpikeData(IStream, indexChannel);
    }
    else if (bufferID.Find("trig") != -1)
    {
        // \todo implement ReadTriggerData()
    }
    else if (bufferID.Find("mean") != -1)
    {
        ReadAverageData(IStream, indexChannel);
    }
    else if (bufferID.Find("para") != -1)
    {
        // \todo implement ReadParamData()
    }
    else if (bufferID.Find("sppa") != -1)
    {
        ReadSpikeParameterData(IStream, indexChannel);
	}
	else if (bufferID.Find("bupa") != -1)
	{
		ReadBurstParameterData(IStream, indexChannel);
    }
}

void CMC_StreamTestDlg::OnBnClickedBtnAbout()
{
    CAboutDlg dlg;
    dlg.DoModal();
}

void CMC_StreamTestDlg::OnBnClickedBtnSaveInfo()
{
	CString strFilter = "ASCII mcd info (*.dat)|*.dat|All Files (*.*)|*.*||";

	CFileDialog dlg(
		FALSE,
		"dat",
		NULL,
        OFN_HIDEREADONLY | OFN_PATHMUSTEXIST | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT,
		strFilter,
		this);


	if (dlg.DoModal()==IDOK)
	{
        CFile infoFile;
        CFileException fileException;
        if (!infoFile.Open(dlg.GetPathName(), CFile::modeCreate | CFile::modeReadWrite, &fileException))
        {
            MessageBox("Could not create file %s", dlg.GetPathName());
        }
        else
        {
            CString line;
            line = "MC_StreamTest File info\r\n";
            infoFile.Write(line, line.GetLength());
            line = "-----------------------\r\n\r\n";
            infoFile.Write(line, line.GetLength());
            line = "File info:\r\n";
            infoFile.Write(line, line.GetLength());
            infoFile.Write(m_FileInfo, m_FileInfo.GetLength());
            line = "\r\n\r\nStream info:\r\n";
            infoFile.Write(line, line.GetLength());
            infoFile.Write(m_StreamInfo, m_StreamInfo.GetLength());
        }
    }
}

void CMC_StreamTestDlg::OnBnClickedBtnExportChannelInfo()
{
	CString strFilter = "Channel info (*.dat)|*.dat|All Files (*.*)|*.*||";

	CFileDialog dlg(
		FALSE,
		"dat",
		NULL,
        OFN_HIDEREADONLY | OFN_PATHMUSTEXIST | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT,
		strFilter,
		this);

	if (dlg.DoModal()==IDOK)
	{
        CFile exportFile;
        CFileException fileException;
        if (!exportFile.Open(dlg.GetPathName(), CFile::modeCreate | CFile::modeReadWrite, &fileException))
        {
            MessageBox("Could not create file %s", dlg.GetPathName());
        }
        else
        {
			CString tmp;
			CString line;
		    CComPtr<MCStream::IMCSStream> IStream = MakeSP<MCStream::IMCSStream>(m_IStreamFile->GetStream(m_CurrentStreamIndex));
			CComPtr<MCStream::IMCSLayout> ILayout = MakeSP<MCStream::IMCSLayout>(m_IStreamFile->GetLayout());
			line.Format("Channel Data Export: %s\r\n", m_FileName);
			exportFile.Write(line, line.GetLength());
			long lt = ILayout->LayoutType;
			if (lt == 3)
			{
				line = "";
				int numAmps = ILayout->GetNumberOfConfigAmps();
				for (int i=0; i<numAmps; i++)
				{
					CString ampName = ILayout->GetNameOfConfigAmp(i);
					tmp.Format("%d: %s", i + 1, ampName);

					line += tmp;
					line += "\t";
				}
				line += "\r\n";
				exportFile.Write(line, line.GetLength());

				line = "";
				int numMEAs = ILayout->GetNumberOfConfigMEAs();
				for (int i=0; i<numMEAs; i++)
				{
					CString MEAName = ILayout->GetNameOfConfigMEA(i);
					tmp.Format("%d: %s", i + 1, MEAName);

					line += tmp;
					line += "\t";
				}
				line += "\r\n";
				exportFile.Write(line, line.GetLength());
			}

			line = "HWID\tname\tMEA\tX\tY\tRelX\tRelY";
			line += "\r\n";
			exportFile.Write(line, line.GetLength());
			for (int i=0; i<IStream->GetChannelCount(); i++)
			{
				line = "";
				CComPtr<MCStream::IMCSChannel> IChannel = MakeSP<MCStream::IMCSChannel>(IStream->GetChannel(static_cast<short>(i)));
				long HWID = IChannel->GetHWID();
				tmp.Format("%d", IChannel->GetHWID());
				line += tmp;
				line += "\t";
				CString name = IChannel->GetDecoratedName();
				line += name;
				line += "\t";

				int MEAIndex = ILayout->GetMEAIndexFromHWID(IChannel->GetHWID());
				tmp.Format("%d", MEAIndex);
				line += tmp;
				line += "\t";

				tmp.Format("%d", IChannel->PosX);
				line += tmp;
				line += "\t";
				tmp.Format("%d", IChannel->PosY);
				line += tmp;
				line += "\t";
				tmp.Format("%d", ILayout->GetRelativeChannelPosX(MEAIndex, HWID));
				line += tmp;
				line += "\t";
				tmp.Format("%d", ILayout->GetRelativeChannelPosY(MEAIndex, HWID));
				line += tmp;

				line += "\r\n";

				exportFile.Write(line, line.GetLength());
			}
        }
    }
}

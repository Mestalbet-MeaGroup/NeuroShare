// MC_StreamTestDlg.h : header file
//

#pragma once

#import "MCStream.tlb"
#include "afxwin.h"

// CMC_StreamTestDlg dialog
class CMC_StreamTestDlg : public CDialog
{
// Construction
public:
	CMC_StreamTestDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_MC_STREAMTEST_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()

private:
    void QuickTestMCDFile(void);
    bool OpenMcdFile(CString& fileName);
    CString GetStartTime();
    CString GetStopTime();

    void ReadRawInfo(CComPtr<MCStream::IMCSStream>& IStream);
    // read information about the spike stream
    void ReadSpikeInfo(CComPtr<MCStream::IMCSStream>& IStream);
    void ReadFilterInfo(CComPtr<MCStream::IMCSStream>& IStream);
    void ReadTriggerInfo(CComPtr<MCStream::IMCSStream>& IStream);
    void ReadAverageInfo(CComPtr<MCStream::IMCSStream>& IStream);
    void ReadParamInfo(CComPtr<MCStream::IMCSStream>& IStream);
    void ReadSpikeParamInfo(CComPtr<MCStream::IMCSStream>& IStream);
	void ReadBurstParamInfo(CComPtr<MCStream::IMCSStream>& IStream);
	void ReadChannelToolInfo(CComPtr<MCStream::IMCSStream>& IStream);

    void ReadContinuousRawData(CComPtr<MCStream::IMCSStream>& IStream, int index);
    void ReadTriggeredRawData(CComPtr<MCStream::IMCSStream>& IStream, int index);
    void ReadSpikeData(CComPtr<MCStream::IMCSStream>& IStream, int index);
    void ReadAverageData(CComPtr<MCStream::IMCSStream>& IStream, int index);
    void ReadSpikeParameterData(CComPtr<MCStream::IMCSStream>& IStream, int index);
	void ReadBurstParameterData(CComPtr<MCStream::IMCSStream>& IStream, int index);

    void DisplayChannels(CComPtr<MCStream::IMCSStream>& IStream);

    CComPtr<MCStream::IMCSStream> m_IStream;
    CComPtr<MCStream::IMCSStreamFile> m_IStreamFile;

    afx_msg void OnBnClickedBtnQuickTest();
    afx_msg void OnBnClickedBtnOpenMcdFile();
    afx_msg void OnLbnSelchangeListStreams();

	// mcd file name
	CString m_FileName;

    //! display of mcd file info
    CString m_FileInfo;
    //! list of mcd streams
    CListBox m_ListBoxStreams;
    //! display of mcd stream info, dependent on the stream type
    CString m_StreamInfo;
    CListBox m_ListBoxChannels;
    afx_msg void OnBnClickedBtnAbout();
    afx_msg void OnBnClickedBtnReadData();
    CButton m_ButtonReadData;
    afx_msg void OnLbnSelchangeListChannels();
    afx_msg void OnBnClickedBtnSaveInfo();

	CString m_ChannelInfo;

	int m_CurrentStreamIndex;
public:
	CButton m_btnExportChannelInfo;
	afx_msg void OnBnClickedBtnExportChannelInfo();
};

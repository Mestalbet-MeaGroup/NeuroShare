/////////////////////////////////////////////////////////////////////////////
//
// MC_StreamMEX
//
// Copyright (C) 1998-2003 Multi Channel Systems, all rights reserved
//
// $Workfile: MCStreamMEX.h $
//
// Description: interface to Matlab
//
// $Header: /MC_StreamMEX/MCStreamMEX.h 1     23.02.04 11:48 Patzwahl $
//
// $Modtime: 23.09.03 12:34 $
//
// $Log: /MC_StreamMEX/MCStreamMEX.h $
// * 
// * 1     23.02.04 11:48 Patzwahl
// * repeated initial check in, because this files were checked out by a an
// * out of data computer
// * 
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_MCSTREAMMEX_H__DF509C16_D403_11D3_B4F6_0000B4552050__INCLUDED_)
#define AFX_MCSTREAMMEX_H__DF509C16_D403_11D3_B4F6_0000B4552050__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// #ifndef __AFXWIN_H__
// 	#error include '#' before including this file for PCH
// #endif

#include "resource.h"		// main symbols
#include "mex.h"
#include "mcstream.h"

/////////////////////////////////////////////////////////////////////////////
// CMCStreamMEXApp
// See MCStreamMEX.cpp for the implementation of this class
//

class CMCStreamMEXApp : public CWinApp
{
public:
	CMCStreamMEXApp();
	~CMCStreamMEXApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMCStreamMEXApp)

	//}}AFX_VIRTUAL

	//{{AFX_MSG(CMCStreamMEXApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP();
};

class CMCChunkPtrArray;

class CMCStreamMEX : public CObject
{
public:
/*	dFrom, dTo = time in ms
	**
*/
	void GetFromTo(double dFrom,double dTo,int iStream,mxArray *yp, 
					int *iSorter, int selectedChannel, BOOL bTimesOnly,
					mxArray* mxEventtimes, double dRange);
	CMCStreamMEX();
	~CMCStreamMEX();
	void GetChunk(
		   int iStreamId,
		   DWORD iChunk,
		   mxArray *yp
		   );
	void OpenFile(
		   char *buf,
		   mxArray *yp
		   );
	void CloseFile();

	CArray<IMCSStream*, IMCSStream*> m_arrStream;
	IMCSStreamFile *m_piStreamFile;
	IMCSStream *m_piStream;
	long m_lSweepNumber;
};

#endif // !defined(AFX_MCSTREAMMEX_H__DF509C16_D403_11D3_B4F6_0000B4552050__INCLUDED_)

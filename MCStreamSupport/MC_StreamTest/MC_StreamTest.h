// MC_StreamTest.h : main header file for the PROJECT_NAME application
//

#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"		// main symbols


// CMC_StreamTestApp:
// See MC_StreamTest.cpp for the implementation of this class
//

class CMC_StreamTestApp : public CWinApp
{
public:
	CMC_StreamTestApp();

// Overrides
	public:
	virtual BOOL InitInstance();

// Implementation

	DECLARE_MESSAGE_MAP()
};

extern CMC_StreamTestApp theApp;
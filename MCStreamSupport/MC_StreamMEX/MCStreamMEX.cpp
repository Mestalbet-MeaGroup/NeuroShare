/////////////////////////////////////////////////////////////////////////////
//
// MC_StreamMEX
//
// Copyright (C) 1998-2003 Multi Channel Systems, all rights reserved
//
// $Workfile: MCStreamMEX.cpp $
//
// Description: interface to Matlab
//
// $Header: /MC_Rack_II/MC_StreamMEX/MCStreamMEX.cpp 6     30.01.12 14:03 Paetzold $
//
// $Modtime: 21.11.11 13:43 $
//
// $Log: /MC_Rack_II/MC_StreamMEX/MCStreamMEX.cpp $
// * 
// * 6     30.01.12 14:03 Paetzold
// * Changed number of max channels to 257
// * 
// * 5     13.05.09 16:31 Merz
// * changes for the new ChannelTool instrument
// * 
// * 4     16.03.07 9:58 Loeffler
// * warning removed, WINVER changed
// * 
// * 3     15.08.06 13:01 Jesinger
// * work around for possible signed/unsigned bug
// * 
// * 2     14.08.06 11:27 Jesinger
// * Hwid -> HWID
// * Id->ID
// * 
// * Adapted to Visual Studio .NET 2005
// * 
// * 1     23.02.04 11:48 Patzwahl
// * repeated initial check in, because this files were checked out by a an
// * out of data computer
// * 
//
/////////////////////////////////////////////////////////////////////////////

#include "mex.h"
#include "matrix.h"
#include "stdafx.h"
#include "MCStreamMEX.h"
#include "tmwtypes.h"
#define _AFXDLL

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

CMCStreamMEX *g_pStreamMEX;

#define round_int(x)	((x)>=0?int((x)+0.5):int((x)-0.5))
#define DIGITALNUM 1
#define ANALOGNUM 4
#define ELECTRODENUM 64
#define HARDWAREELECTRODENUM 257


/////////////////////////////////////////////////////////////////////////////
// CMCStreamMEXApp

BEGIN_MESSAGE_MAP(CMCStreamMEXApp, CWinApp)
	//{{AFX_MSG_MAP(CMCStreamMEXApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


CMCStreamMEXApp::CMCStreamMEXApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

CMCStreamMEXApp::~CMCStreamMEXApp()
{
	if(g_pStreamMEX)
	{
		delete g_pStreamMEX;
	}
}


CMCStreamMEXApp theApp;




//MEX Code *************************

#include <math.h>

/* Input Arguments */

#define	T_IN	prhs[0]
#define	Y_IN	prhs[1]


/* Output Arguments */

#define	YP_OUT	plhs[0]


// CMCStreamMEX //

CMCStreamMEX::CMCStreamMEX()
{
	m_piStreamFile = 0;
	m_arrStream.SetSize(0,10);
	m_lSweepNumber = 1;
}

CMCStreamMEX::~CMCStreamMEX()
{
	CloseFile();
}

void CMCStreamMEX::GetFromTo(double dFrom,double dTo,int iStream,mxArray *yp, 
							 int *iSorter, int selectedChannel, BOOL bTimesOnly,
							 mxArray* mxEventtimes, double dRange) 
{

	if(!m_piStreamFile)
	{
		mexErrMsgTxt("No File opened.");
	}
	if(iStream >= m_arrStream.GetSize())
	{
		mexErrMsgTxt("StreamNumber to high, Stream does not exist.");
	}

	mxArray *mxTmp,*mxCell,*mxCell2;
    mxTmp = NULL;
	double *dTmp;
	int iChannelCount;
	LPDISPATCH tmpDispatch;
	int iHardwareID[HARDWAREELECTRODENUM];
	int iChannelID[HARDWAREELECTRODENUM];
	int iChannelLinearID[HARDWAREELECTRODENUM];

	// DP This hack is to prevent a wrong time in nano seconds
	// which could happen because of the holey double representation
	DWORDLONG dwFrom = static_cast<DWORDLONG>((dFrom * 1000000.) + 0.1);
	long lFromSec=(long)(dwFrom / 1000000000);
	short sFromMSec=(short)((dwFrom - (DWORDLONG)lFromSec * 1000000000) / 1000000);
	short sFromUSec=(short)((dwFrom - (DWORDLONG)lFromSec * 1000000000 - (DWORDLONG)sFromMSec * 1000000) / 1000);
	short sFromNSec=(short)(dwFrom - (DWORDLONG)lFromSec * 1000000000 - (DWORDLONG)sFromMSec * 1000000 - (DWORDLONG)sFromUSec *1000);

	DWORDLONG dwTo = static_cast<DWORDLONG>((dTo * 1000000.) + 0.1);
	long lToSec=(long)(dwTo / 1000000000);
	short sToMSec=(short)((dwTo - (DWORDLONG)lToSec * 1000000000) / 1000000);
	short sToUSec=(short)((dwTo - (DWORDLONG)lToSec * 1000000000 - (DWORDLONG)sToMSec * 1000000) / 1000);
	short sToNSec=(short)(dwTo - (DWORDLONG)lToSec * 1000000000 - (DWORDLONG)sToMSec * 1000000 - (DWORDLONG)sToUSec * 1000);

//	DP this causes a rounding error!!
//	long lFromSec=(long)(dFrom/1000);
//	short sFromMSec=(short)(dFrom-(double)lFromSec*1000);
//	short sFromUSec=(short)((dFrom-(double)lFromSec*1000-(double)sFromMSec)*1000);
//	short sFromNSec=(short)(((dFrom-(double)lFromSec*1000-sFromMSec)*1000-sFromUSec)*1000);
//	long lToSec=(long)(dTo/1000);
//	short sToMSec=(short)(dTo-(double)lToSec*1000);
//	short sToUSec=(short)((dTo-(double)lToSec*1000-sToMSec)*1000);
//	short sToNSec=(short)(((dTo-(double)lToSec*1000-sToMSec)*1000-sToUSec)*1000);

	IMCSTimeStamp tsFrom,tsTo;
	tsTo.AttachDispatch(m_piStreamFile->GetStartTime());
	tsFrom.AttachDispatch(tsTo.Clone());
	tsFrom.SetSecondFromStart(lFromSec);
	tsFrom.SetMillisecondFromStart(sFromMSec);
	tsFrom.SetMicrosecondFromStart(sFromUSec);
	tsFrom.SetNanosecondFromStart(sFromNSec);
	tsTo.ReleaseDispatch();
	tsTo.AttachDispatch(tsFrom.Clone());
	tsTo.SetSecondFromStart(lToSec);
	tsTo.SetMillisecondFromStart(sToMSec);
	tsTo.SetMicrosecondFromStart(sToUSec);
	tsTo.SetNanosecondFromStart(sToNSec);

	if(iSorter[0]==-1)
	{
		if (selectedChannel==-1)
		{
			iChannelCount = m_arrStream[iStream]->GetChannelCount();
		}
		else
		{
			iChannelCount = 1;
		}
	}
	else
	{
		if (m_arrStream[iStream]->GetName()=="Analog Raw Data")
		{
			iChannelCount= ANALOGNUM;
		}
		else if (m_arrStream[iStream]->GetName()=="Digital Data")
		{
			iChannelCount= DIGITALNUM;
		}
		else
		{
			iChannelCount= ELECTRODENUM;
		}
	}
	
	IMCSChannel *pChannel = new IMCSChannel;
	for(short i = 0; i < m_arrStream[iStream]->GetChannelCount(); i++)
	{
		pChannel->AttachDispatch(m_arrStream[iStream]->GetChannel(i));
		iHardwareID[i]=static_cast<int>(pChannel->GetHWID());
		iChannelID[i]=static_cast<int>(pChannel->GetID());
		iChannelLinearID[iChannelID[i]]=i;
	}
	delete pChannel;
	
	if (m_arrStream[iStream]->HasRawData())
	{
		if(m_arrStream[iStream]->HasContinuousData())
		{
			long lBufferSize = m_arrStream[iStream]->GetRawDataBufferSize(tsFrom, tsTo);
			long lChannelCount = m_arrStream[iStream]->GetChannelCount();
			long lBufferSize64 = lBufferSize / lChannelCount * 64;

			if(lBufferSize != 0)
			{
				unsigned short* bufRaw;
				bufRaw = new unsigned short[lBufferSize];
				if(lBufferSize != m_arrStream[iStream]->GetRawData((short *)bufRaw, tsFrom, tsTo))
				{
					mexWarnMsgTxt("Read beyond file scope or stream without content!");
					mxTmp = mxCreateDoubleMatrix(0, 0, mxREAL);
					mxSetField(yp, 0,"data", mxTmp);
					delete [] bufRaw;
					return;
				}

				if(iSorter[0]==-1)
				{
					mxTmp = mxCreateDoubleMatrix(lBufferSize, 1, mxREAL);
					dTmp = mxGetPr(mxTmp);
					for(long i = 0; i < lBufferSize; ++i)
					{
						dTmp[i] = static_cast<double>(bufRaw[i]);
					}
				}
				else
				{
					mxTmp = mxCreateDoubleMatrix(lBufferSize64, 1, mxREAL);
					dTmp = mxGetPr(mxTmp);
					long lOffset = 0;
					long lRaw = 0;
					while(lRaw < lBufferSize)
					{
						for (int iC = 0; iC < lChannelCount; iC++)
						{
							dTmp[lOffset + iSorter[iHardwareID[iC]]] = static_cast<double>(bufRaw[lRaw]);
							++lRaw;
						}
						lOffset += iChannelCount;
					}
				}
				delete [] bufRaw;
			}
		}
		else
		{
			//event based access for triggered data

			tmpDispatch = m_arrStream[iStream]->GetEventNextTo(tsFrom.m_lpDispatch);
			if (!tmpDispatch)	
			{
				//there is a bug (22.10.98) in MCRack rack saving, which leads to streams without channels
				mexWarnMsgTxt("Read beyond file scope or stream without content!");
				mxTmp = mxCreateDoubleMatrix(0, 0, mxREAL);
				mxSetField(yp, 0,"data", mxTmp);
				return;
			}

			IMCSEvtRaw event; 
			event.AttachDispatch(tmpDispatch); 
			int iContinue = 1;
			long lSize=(long) round_int((dTo-dFrom) * iChannelCount * ((double) m_piStreamFile->GetMillisamplesPerSecond()/1000000));
			mxTmp = mxCreateDoubleMatrix(lSize, 1, mxREAL);
			dTmp = mxGetPr(mxTmp);
			double dTmpZero = (double) m_arrStream[iStream]->GetADZero();
			for(long ilSize=0;ilSize<lSize;ilSize++)
				dTmp[ilSize]=dTmpZero;
			DWORD dwOffset;
			unsigned short *buf;
			buf = new unsigned short[m_arrStream[iStream]->GetChannelCount()];
			int iOffsetCorr=-1;
			while((iContinue && event.GetSecondFromStart() < lToSec) 
					||
					((iContinue && event.GetSecondFromStart() == lToSec)
						&&
						((event.GetMillisecondFromStart() < sToMSec)
							||
							((event.GetMillisecondFromStart() == sToMSec)
								&&(event.GetMicrosecondFromStart() < sToUSec)
							)
						)
					)
				)
			{
				
				double dTicks =	(
									(double)(event.GetSecondFromStart()-lFromSec)+
									((double) (event.GetMillisecondFromStart()-sFromMSec))/(double)1000+
									((double) (event.GetMicrosecondFromStart()-sFromUSec))/(double)1000000
								) 
								* ((double) m_piStreamFile->GetMillisamplesPerSecond()/(double)1000);
	//						round_int( //we are always positive here and do a little bit more than round
				
				dwOffset = ((DWORD)	(0.51+ dTicks)) * iChannelCount;

				if(iOffsetCorr==-1) //on first entrance do a little bit less than round
				{	
					iOffsetCorr=0;
					if(dTicks<0.51 && dwOffset == (DWORD)iChannelCount)
					{
						iOffsetCorr = iChannelCount;
					}
				}
				dwOffset = dwOffset - (DWORD)iOffsetCorr;
				event.GetADDataArray((short *)buf);
				for (int iC=0;iC<m_arrStream[iStream]->GetChannelCount();iC++)
				{
					if(iSorter[0]==-1)
					{
						if(dwOffset+iC >= (DWORD)lSize)
							break; //should not happen, but prevents tick misalgin etc from crashing
						dTmp[dwOffset+iC]=(double) buf[iC];
					}
					else
					{
						if(dwOffset+iSorter[iHardwareID[iC]] >= (DWORD)lSize)
							break; //should not happen, but prevents tick misalgin etc from crashing
						dTmp[dwOffset+iSorter[iHardwareID[iC]]]=(double) buf[iC];
					}
				}
				iContinue = event.Next();
			}
			delete buf;
		}
		mxSetField(yp, 0,"data", mxTmp);
	}
	else if (m_arrStream[iStream]->GetDataType()=="spikes")
	{
		tmpDispatch = m_arrStream[iStream]->GetEventNextTo(tsFrom.m_lpDispatch);
		mxCell = mxCreateCellMatrix(iChannelCount, 1);
		mxCell2 = mxCreateCellMatrix(iChannelCount, 1);
		if(!tmpDispatch)
		{
			mxSetField(yp, 0,"spikevalues", mxCell);
			mxSetField(yp, 0,"spiketimes", mxCell2);
			return;
		}

		long *arrEventCount;

		arrEventCount = new long[HARDWAREELECTRODENUM];
		for(int i=0;i<HARDWAREELECTRODENUM;i++)
			arrEventCount[i]=0;
		DWORD dwEventCount=0;
		if(mxEventtimes)
		{
			dwEventCount=mxGetM(mxEventtimes) * mxGetN(mxEventtimes);
		}
		else
		{
			m_arrStream[iStream]->EventCountFromTo(tsFrom.m_lpDispatch,tsTo.m_lpDispatch,arrEventCount);
			for(int i=0;i<m_arrStream[iStream]->GetChannelCount();i++)
			{
				// In spike files containing not all channels, when selection was made 
				// in Recorder channels page - not in Spikes Channels Page - spike channelid 
				// start not from 0! That means it can not be used as linear index!
				dwEventCount=dwEventCount+arrEventCount[iChannelID[i]];
			}
		}


		IMCSEvtSpike event;
		event.AttachDispatch(tmpDispatch);

		if(dwEventCount==0)
		{
			mxSetField(yp, 0,"spikevalues", mxCell);
			mxSetField(yp, 0,"spiketimes", mxCell2);
			event.ReleaseDispatch();
			delete arrEventCount;
			return;
		}

		unsigned short *buf;
		buf = new unsigned short[event.GetCount()];

		mxArray *(*mxValArray),*(*mxTimeArray);	//array of mxArray's
		mxValArray = (mxArray**) mxMalloc(iChannelCount * sizeof(mxArray*));
		mxTimeArray = (mxArray**) mxMalloc(iChannelCount * sizeof(mxArray*));

		int iIndex;
		if(iSorter[0]!=-1)
		{
			for (int iC = 0; iC < iChannelCount; iC++)
			{
				mxValArray[iC] = mxCreateDoubleMatrix(0,0,mxREAL);
				mxTimeArray[iC] = mxCreateDoubleMatrix(0,0,mxREAL);
			}
		}		
		int selectedChannelID=-1;
		if (selectedChannel==-1)
		{
			for (int iC = 0; iC < m_arrStream[iStream]->GetChannelCount(); iC++)
			{
				if(iSorter[0]==-1)
				{
					iIndex = iC;
				}
				else
				{
					iIndex = iSorter[iHardwareID[iC]];
					mxDestroyArray(mxValArray[iIndex]);
					mxDestroyArray(mxTimeArray[iIndex]);
				}
				if(bTimesOnly)
				{
					mxValArray[iIndex] = mxCreateDoubleMatrix(0,0,mxREAL);
				}
				else
				{
					mxValArray[iIndex] = mxCreateDoubleMatrix(event.GetCount(),arrEventCount[iChannelID[iC]],mxREAL);
				}					
				mxTimeArray[iIndex] = mxCreateDoubleMatrix(arrEventCount[iChannelID[iC]],1,mxREAL);
			}
		}
		else
		{	
			BOOL bValidChannel=FALSE;
			for(int iC = 0; iC < m_arrStream[iStream]->GetChannelCount(); iC++)
			{
				if(selectedChannel==iHardwareID[iC])
				{
					selectedChannelID=iChannelID[iC]; //channel ID
					bValidChannel=TRUE;
					break;
				}
			}
			if (!bValidChannel)
			{
				mxSetField(yp, 0,"spikevalues", mxCell);
				mxSetField(yp, 0,"spiketimes", mxCell2);
				event.ReleaseDispatch();
				delete arrEventCount;
				return;
			}
			if(mxEventtimes)
			{
				arrEventCount[selectedChannelID]=dwEventCount;
			}
			if(bTimesOnly)
			{
				mxValArray[0] = mxCreateDoubleMatrix(0,0,mxREAL);
			}
			else
			{
				mxValArray[0] = mxCreateDoubleMatrix(event.GetCount(),arrEventCount[selectedChannelID],mxREAL);
			}
			mxTimeArray[0] = mxCreateDoubleMatrix(arrEventCount[selectedChannelID],1,mxREAL);
		}
		delete arrEventCount;
		arrEventCount = new long[m_arrStream[iStream]->GetChannelCount()];
		for(int i=0;i<m_arrStream[iStream]->GetChannelCount();i++)
		{
			arrEventCount[i]=0;
		}
		unsigned int iS=0;
		double* dEvTim = NULL;
		if(mxEventtimes)
		{
			dEvTim = mxGetPr(mxEventtimes);
		}
		
		while(iS < dwEventCount)
		{
			int iChannel = event.GetChannel();
			if(iSorter[0] == -1)
			{
				iIndex = iChannelLinearID[iChannel];
			}
			else
			{
				iIndex = iSorter[iHardwareID[iChannelLinearID[iChannel]]];
			}
			if(selectedChannel!=-1)
			{
				iIndex=-1;
				if (iChannel == selectedChannelID)
					iIndex=0;
			}
			BOOL bNext=TRUE;
			if (iIndex!=-1)
			{
				dTmp = mxGetPr(mxTimeArray[iIndex]);
				double evtTime = (double)event.GetSecondFromStart()*1000 + (double)event.GetMillisecondFromStart() + ((double)event.GetMicrosecondFromStart())/1000;
				BOOL bFound=FALSE;
				unsigned int iEvIdx;
				if(mxEventtimes)
				{
					iEvIdx = iS;
					if(evtTime > (dEvTim[iEvIdx]-dRange))
					{
						iS++;
						bNext=FALSE; //compare this event again to next eventtimes, even it was a hit
					}
					if(iS > iEvIdx && evtTime < (dEvTim[iEvIdx]+dRange))
					{
						bFound=TRUE;
						dTmp[iEvIdx]=evtTime;
					}
				}
				else
				{
					iEvIdx=arrEventCount[iChannelLinearID[iChannel]];
					dTmp[iEvIdx]=evtTime;
					bFound=TRUE;
				}
				if(!bTimesOnly && bFound)
				{
					dTmp = mxGetPr(mxValArray[iIndex]);
					event.GetADDataArray((short *)buf);
					int iCount=event.GetCount();
					for (int iAD=0;iAD<iCount;iAD++)
					{
						DWORD dwIdx=iEvIdx*iCount+iAD;
						dTmp[dwIdx]=buf[iAD];
					}
				}
			}
			if(!mxEventtimes)
			{
				iS++;
			}
			if(bNext)
			{
				arrEventCount[iChannelLinearID[iChannel]]++;
				event.Next();
			}
		}
		event.ReleaseDispatch();
		delete buf;
		if(selectedChannel==-1)
		{
			for (int iC = 0; iC < iChannelCount; iC++)
			{
				mxSetCell(mxCell, iC, mxValArray[iC]);
				mxSetCell(mxCell2, iC, mxTimeArray[iC]);
			}
			mxSetField(yp, 0,"spikevalues", mxCell);
			mxSetField(yp, 0,"spiketimes", mxCell2);
		}
		else
		{
			mxSetField(yp, 0,"spikevalues", mxValArray[0]);
			mxSetField(yp, 0,"spiketimes", mxTimeArray[0]);
			mxDestroyArray(mxCell);
			mxDestroyArray(mxCell2);
		}
		mxFree(mxValArray);
		mxFree(mxTimeArray);
		delete arrEventCount;
	}
	else if (m_arrStream[iStream]->GetDataType()=="trigger")
	{
		tmpDispatch = m_arrStream[iStream]->GetEventNextTo(tsFrom.m_lpDispatch);
		if(!tmpDispatch)
		{
			return;
		}
		long arrEventCount=0;
		m_arrStream[iStream]->EventCountFromTo(tsFrom.m_lpDispatch,tsTo.m_lpDispatch,&arrEventCount);
		DWORD dwEventCount=arrEventCount;
		IMCSEvtTrigger event;
		event.AttachDispatch(tmpDispatch);
		if(dwEventCount==0)
		{
			event.ReleaseDispatch();
			return;
		}
		mxArray *mxVal,*mxTime;
		mxVal = mxCreateDoubleMatrix(1,dwEventCount,mxREAL);
		mxTime = mxCreateDoubleMatrix(1,dwEventCount,mxREAL);
		for (unsigned int iS = 0; iS < dwEventCount; iS++)
		{
			dTmp = mxGetPr(mxTime);
			dTmp[iS] = (double)event.GetSecondFromStart()*1000 + (double)event.GetMillisecondFromStart() + ((double)event.GetMicrosecondFromStart())/1000;
			dTmp = mxGetPr(mxVal);
			dTmp[iS] = (double) event.GetADData();
			event.Next();
		}
		event.ReleaseDispatch();
		mxSetField(yp, 0,"values", mxVal);
		mxSetField(yp, 0,"times", mxTime);
	}
	else if (m_arrStream[iStream]->GetDataType()=="params")
	{
		tmpDispatch = m_arrStream[iStream]->GetEventNextTo(tsFrom.m_lpDispatch);
		if(!tmpDispatch)
		{
			return;
		}
		
		long arrEventCount=0;
		m_arrStream[iStream]->EventCountFromTo(tsFrom.m_lpDispatch,tsTo.m_lpDispatch,&arrEventCount);
		DWORD dwEventCount = arrEventCount;
		if(dwEventCount==0)
		{
			return;
		}
		
		mxArray *mxTime = NULL, *mxMin = NULL, *mxMax = NULL, *mxTMin = NULL, *mxTMax = NULL, *mxHeight = NULL, *mxWidth = NULL, *mxAmplitude = NULL, *mxArea = NULL, *mxNumber = NULL, *mxRate = NULL;
		double *dMin = NULL, *dMax = NULL, *dTMin = NULL, *dTMax = NULL, *dHeight = NULL, *dWidth = NULL, *dAmplitude = NULL, *dArea = NULL, *dNumber = NULL, *dRate = NULL;
		int iMin,iMax,iTMin,iTMax,iHeight,iWidth,iAmplitude,iArea,iNumber,iRate;
		
		mxTime = mxCreateDoubleMatrix(1,dwEventCount,mxREAL);
		IMCSEvtParam event;
		event.AttachDispatch(tmpDispatch);
		tmpDispatch = m_arrStream[iStream]->GetInfo();
		if(!tmpDispatch)
			return;
		
		IMCSInfoParam info;
		info.AttachDispatch(tmpDispatch);

		if((iMin=info.MinPos())>=0)
		{	
			mxMin = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dMin = mxGetPr(mxMin);
		}
		if((iMax=info.MaxPos())>=0)
		{	
			mxMax = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dMax = mxGetPr(mxMax);
		}
		if((iTMin=info.TMinPos())>=0)
		{	
			mxTMin = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dTMin = mxGetPr(mxTMin);
		}
		if((iTMax=info.TMaxPos())>=0)
		{	
			mxTMax = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dTMax = mxGetPr(mxTMax);
		}
		if((iHeight=info.HeightPos())>=0)
		{	
			mxHeight = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dHeight = mxGetPr(mxHeight);
		}
		if((iWidth=info.WidthPos())>=0)
		{	
			mxWidth = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dWidth = mxGetPr(mxWidth);
		}
		if((iAmplitude=info.AmplitudePos())>=0)
		{	
			mxAmplitude = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dAmplitude = mxGetPr(mxAmplitude);
		}
		if((iArea=info.AreaPos())>=0)
		{	
			mxArea = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dArea = mxGetPr(mxArea);
		}
		if((iNumber=info.NumberPos())>=0)
		{	
			mxNumber = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dNumber = mxGetPr(mxNumber);
		}
		if((iRate=info.RatePos())>=0)
		{	
			mxRate = mxCreateDoubleMatrix(iChannelCount, dwEventCount, mxREAL);
			dRate = mxGetPr(mxRate);
		}
		float *fbuf;
		fbuf = new float[12]; //AN_NCHOICES 12
		for (unsigned int iS = 0; iS < dwEventCount; iS++)
		{
			dTmp = mxGetPr(mxTime);
			dTmp[iS] = (double)event.GetSecondFromStart()*1000+(double)event.GetMillisecondFromStart()+((double)event.GetMicrosecondFromStart())/1000;
			
			for (short iC = 0; iC < m_arrStream[iStream]->GetChannelCount(); iC++)
			{
				DWORD dwIndex;
				if(iSorter[0]==-1)
				{
					dwIndex = iC;
				}
				else
				{
					dwIndex = iSorter[iHardwareID[iC]];
				}
				event.GetDataArray(iC,fbuf);
				if(mxMin)
					dMin[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iMin];
				if(mxMax)
					dMax[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iMax];
				if(mxTMin)
					dTMin[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iTMin];
				if(mxTMax)
					dTMax[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iTMax];
				if(mxHeight)
					dHeight[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iHeight];
				if(mxWidth)
					dWidth[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iWidth];
				if(mxAmplitude)
					dAmplitude[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iAmplitude];
				if(mxArea)
					dArea[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iArea];
				if(mxNumber)
					dNumber[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iNumber];
				if(mxRate)
					dRate[iS * (DWORD)iChannelCount + dwIndex] = (double) fbuf[iRate];
			}
			event.Next();
		}
		delete fbuf;
		event.ReleaseDispatch();
		info.ReleaseDispatch();
		mxSetField(yp, 0,"times", mxTime);
		if(mxMin) mxSetField(yp, 0,"min", mxMin);
		if(mxMax) mxSetField(yp, 0,"max", mxMax);
		if(mxTMin) mxSetField(yp, 0,"tmin", mxTMin);
		if(mxTMax) mxSetField(yp, 0,"tmax", mxTMax);
		if(mxHeight) mxSetField(yp, 0,"height", mxHeight);
		if(mxWidth) mxSetField(yp, 0,"width", mxWidth);
		if(mxAmplitude) mxSetField(yp, 0,"amplitude", mxAmplitude);
		if(mxNumber) mxSetField(yp, 0,"area", mxArea);
		if(mxNumber) mxSetField(yp, 0,"number", mxNumber);
		if(mxRate) mxSetField(yp, 0,"rate", mxRate);
	}
}

void CMCStreamMEX::GetChunk(int iStreamId, DWORD iChunk, mxArray *yp)
{
	if(!m_piStreamFile)
	{
		mexErrMsgTxt("No File opened.");
	}
	if(iStreamId>=m_arrStream.GetSize())
	{
		mexErrMsgTxt("StreamNumber to high, Stream does not exist.");
	}

	LPDISPATCH tmpDispatch = m_arrStream[iStreamId]->GetFirstChunk();
	DWORD count=0;
	while ((count<iChunk) && tmpDispatch)
	{
		tmpDispatch = m_arrStream[iStreamId]->GetNextChunk(tmpDispatch);
		count++;
	}
	mxArray *mxTmp;
	if(!tmpDispatch)
	{
		mxTmp = mxCreateDoubleMatrix(0, 0, mxREAL);
		mxSetField(yp, 0,"ChunkData", mxTmp);
		mxSetField(yp, 0,"ChunkTime", mxTmp);
		return;
	}
	IMCSChunk chunk;
	chunk.AttachDispatch(tmpDispatch);

	long size = chunk.GetSize() / 2;
	
	unsigned short* buf = new unsigned short[size];
	if(!buf)
		mexErrMsgTxt("Memory Allocation Error.");
	chunk.ReadData((short *)buf);
	double *dTmp;
	mxTmp = mxCreateDoubleMatrix((size), 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	for (long i = 0; i < (size); i++)
	{
		dTmp[i]=(double) buf[i];
	}
	delete buf;

	mxSetField(yp, 0,"ChunkData", mxTmp);
	mxTmp = mxCreateDoubleMatrix(3, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	IMCSTimeStamp *tsFrom;
	tsFrom = new IMCSTimeStamp;
	tsFrom->AttachDispatch(chunk.GetTimeStampFrom());
	dTmp[0]=((double)tsFrom->GetSecondFromStart()*1000+(double)tsFrom->GetMillisecondFromStart());
	dTmp[1]=(double) ((unsigned long) chunk.GetFromLow());
	dTmp[2]=(double) ((unsigned long) chunk.GetFromHigh());
	mxSetField(yp, 0,"ChunkTime", mxTmp);
	delete tsFrom;
 }

void CMCStreamMEX::CloseFile()
{
	for (int i=0;i<m_arrStream.GetSize();i++)
	{
		m_arrStream[i]->ReleaseDispatch();
		delete m_arrStream[i];
	}
	m_arrStream.SetSize(0,10);
	if(m_piStreamFile)
	{
		m_piStreamFile->CloseFile();
		m_piStreamFile->ReleaseDispatch();
		delete m_piStreamFile;
		m_piStreamFile=0;
	}
	m_lSweepNumber = 1;
}


void CMCStreamMEX::OpenFile(char *buf, mxArray *yp)
{

	CloseFile();
	m_piStreamFile = new IMCSStreamFile;
	if(!m_piStreamFile->CreateDispatch("MCSTREAM.MCSSTRM"))
	{
		mexErrMsgTxt("CreateDispatch of iStreamFile failed.");
	}
	if(!m_piStreamFile->OpenFile(buf))
	{
		mexErrMsgTxt("m_piStreamFile->OpenFile failed (filename?).");
	}

	mxArray *mxTmp,*mxTmp2,*mxTmp3,*mxTmp4,*mxTmp5,*mxCell,*mxSamplesPerSeg,*mxCellChannels,*mxChannelID, *mxCellInfo;
	double *dTmp,*dTmp2,*dTmp3,*dTmp4,*dTmp5,*dSamplesPerSeg, *dChannelID;
	IMCSTimeStamp tsTmp;

	mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double) m_piStreamFile->GetHeaderVersion();
	mxSetField(yp, 0,"HeaderVersion", mxTmp);
	
	CString m_strSoftwareVersion;
	m_strSoftwareVersion.Format("%d.%d.%d.%d", 
		m_piStreamFile->GetSoftwareVersionMajor() >> 16,
		m_piStreamFile->GetSoftwareVersionMajor() & 0x0000FFFF,
		m_piStreamFile->GetSoftwareVersionMinor() >> 16,
		m_piStreamFile->GetSoftwareVersionMinor() & 0x0000FFFF);
	mxTmp = mxCreateString(m_strSoftwareVersion);
	mxSetField(yp, 0,"SoftwareVersion", mxTmp);

	mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double) m_piStreamFile->GetMillisamplesPerSecond();
	mxSetField(yp, 0,"MillisamplesPerSecond", mxTmp);

	mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double) m_piStreamFile->GetStreamCount();
	mxSetField(yp, 0,"StreamCount", mxTmp);
	int strmC=(int)(dTmp[0]);

	mxSamplesPerSeg = mxCreateDoubleMatrix(strmC, 1, mxREAL);
	dSamplesPerSeg = mxGetPr(mxSamplesPerSeg);

	mxCell = mxCreateCellMatrix(strmC, 1);

	mxTmp = mxCreateDoubleMatrix(strmC, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	mxTmp2 = mxCreateDoubleMatrix(strmC, 1, mxREAL);
	dTmp2 = mxGetPr(mxTmp2);
	mxTmp3 = mxCreateDoubleMatrix(strmC, 1, mxREAL);
	dTmp3 = mxGetPr(mxTmp3);
	mxTmp4 = mxCreateDoubleMatrix(strmC, 1, mxREAL);
	dTmp4 = mxGetPr(mxTmp4);
	mxTmp5 = mxCreateDoubleMatrix(strmC, 1, mxREAL);
	dTmp5 = mxGetPr(mxTmp5);

	int iChannelCount = 0;

	for (int isC = 0; isC < strmC; isC++)
	{
		m_arrStream.Add(new IMCSStream);
		m_arrStream[isC]->AttachDispatch(m_piStreamFile->GetStream(isC));
		dTmp[isC] = (double) m_arrStream[isC]->GetChannelCount();
		if (m_arrStream[isC]->GetChannelCount() > iChannelCount)
		{
			iChannelCount = m_arrStream[isC]->GetChannelCount();
		}
		dTmp2[isC] = (double) m_arrStream[isC]->GetADZero();
		dTmp3[isC] = (double) m_arrStream[isC]->GetUnitsPerAD();
		dTmp4[isC] = (double) m_arrStream[isC]->GetUnitSign();
		dTmp5[isC] = (double) m_arrStream[isC]->GetMillisamplesPerSecond();
	}

	mxSetField(yp, 0,"ChannelCount", mxTmp);
	mxSetField(yp, 0,"ZeroADValue", mxTmp2);
	mxSetField(yp, 0,"UnitsPerAD", mxTmp3);
	mxSetField(yp, 0,"UnitSign", mxTmp4);
	mxSetField(yp, 0,"MillisamplesPerSecond2", mxTmp5);
	
	mxCellChannels = mxCreateCellMatrix(iChannelCount, strmC );
	mxChannelID = mxCreateDoubleMatrix(iChannelCount, strmC, mxREAL);
	dChannelID = mxGetPr(mxChannelID);


	//Sweep start times are extracted from time gaps in data.
	//This holds for continous, continous with holes, StartOnTrigger or StartAndStopOnTrigger,
	//but can miss e.g. in StartOnTrigger new sweeps within posttrigger time
	//The user can define his own Sweep start times by setting 
	//the SweepStartTime variable in the datastrm object, e.g. to the event times of the start trigger.
	//This code works also for data recorded before V.1.4.
	long lSweepCount = m_piStreamFile->GetSweepCount();
	mxTmp = mxCreateDoubleMatrix(lSweepCount, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	mxTmp2 = mxCreateDoubleMatrix(lSweepCount, 1, mxREAL);
	dTmp2 = mxGetPr(mxTmp2);
	for(int iTT = 0; iTT < lSweepCount; ++iTT)
	{
		tsTmp.AttachDispatch(m_piStreamFile->GetSweepStartTimeAt((long)iTT));
		dTmp[iTT]=(double) 
				(tsTmp.GetSecondFromStart()*1000+tsTmp.GetMillisecondFromStart())
				+((double)tsTmp.GetMicrosecondFromStart()/1000) ;
		tsTmp.ReleaseDispatch();
		tsTmp.AttachDispatch(m_piStreamFile->GetSweepEndTimeAt((long)iTT));
		dTmp2[iTT]=(double) 
				(tsTmp.GetSecondFromStart()*1000+tsTmp.GetMillisecondFromStart())
				+((double)tsTmp.GetMicrosecondFromStart()/1000) ;
		tsTmp.ReleaseDispatch();
	}

	mxSetField(yp, 0,"SweepStartTime", mxTmp);
	mxSetField(yp, 0,"SweepStopTime", mxTmp2);

	//read start and stop time after the file scan done in GetSweepCount()
	mxTmp = mxCreateDoubleMatrix(1, 6, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double) m_piStreamFile->GetYear();
	dTmp[1]=(double) m_piStreamFile->GetMonth();
	dTmp[2]=(double) m_piStreamFile->GetDay();
	dTmp[3]=(double) m_piStreamFile->GetHour();
	dTmp[4]=(double) m_piStreamFile->GetMinute();
	dTmp[5]=(double) m_piStreamFile->GetSecond();
	mxSetField(yp, 0,"RecordingDate", mxTmp);

	tsTmp.AttachDispatch(m_piStreamFile->GetStopTime());
	mxTmp = mxCreateDoubleMatrix(1, 6, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double) tsTmp.GetYear();
	dTmp[1]=(double) tsTmp.GetMonth();
	dTmp[2]=(double) tsTmp.GetDay();
	dTmp[3]=(double) tsTmp.GetHour();
	dTmp[4]=(double) tsTmp.GetMinute();
	dTmp[5]=(double) tsTmp.GetSecond();
	mxSetField(yp, 0,"RecordingStopDate", mxTmp);
	tsTmp.ReleaseDispatch();

	mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double)m_piStreamFile->GetSweepLength();
	mxSetField(yp, 0,"SweepLength", mxTmp);

	mxTmp = mxCreateDoubleMatrix(1, 2, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double)m_piStreamFile->GetStartTriggerStreamID();
	dTmp[1]=(double)m_piStreamFile->GetStopTriggerStreamID();
	mxSetField(yp, 0,"TriggerStreamID", mxTmp);

	mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double)m_piStreamFile->GetSourceType();
	mxSetField(yp, 0,"SourceType", mxTmp);

	mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp);
	dTmp[0]=(double)m_piStreamFile->GetTotalChannels();
	mxSetField(yp, 0,"TotalChannels", mxTmp);

	const char *fieldnames[] = 
		{"Choice","Time1","Time2",
		"StartTrigger","StopTrigger"};
	mxTmp = mxCreateStructMatrix(1,1,5, fieldnames);

	if(m_piStreamFile->GetStartTriggerStreamID()<0)
		{mxTmp2 = mxCreateString("Fixed Window");}
	else if(m_piStreamFile->GetStopTriggerStreamID()<0)
		{mxTmp2 = mxCreateString("Start On Trigger");}
	else
		{mxTmp2 = mxCreateString("Start And Stop On Trigger");}
	mxSetField(mxTmp, 0,"Choice", mxTmp2);

	CString strTrigger="";
	if(m_piStreamFile->GetStartTriggerStreamID()>=0 && m_piStreamFile->GetStartTriggerStreamID()<m_arrStream.GetSize())
		strTrigger=m_arrStream[m_piStreamFile->GetStartTriggerStreamID()]->GetName();
	mxTmp2 = mxCreateString(strTrigger);
	mxSetField(mxTmp, 0,"StartTrigger", mxTmp2);

	strTrigger="";
	if(m_piStreamFile->GetStopTriggerStreamID()>=0 && m_piStreamFile->GetStopTriggerStreamID()<m_arrStream.GetSize())
		strTrigger=m_arrStream[m_piStreamFile->GetStopTriggerStreamID()]->GetName();
	mxTmp2 = mxCreateString(strTrigger);
	mxSetField(mxTmp, 0,"StopTrigger", mxTmp2);

	mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp2);
	dTmp[0]=(double)m_piStreamFile->GetPreTriggerTime();
	mxSetField(mxTmp, 0,"Time1", mxTmp2);

	mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
	dTmp = mxGetPr(mxTmp2);
	dTmp[0]=(double)m_piStreamFile->GetPostTriggerTime();
	mxSetField(mxTmp, 0,"Time2", mxTmp2);


/*	mxCellInfo = mxCreateCellMatrix(1, 1);
	mxSetCell(mxCellInfo, 1, mxTmp );
	mxSetField(yp, 0,"TimeWindow", mxCellInfo);
*/
	mxSetField(yp, 0,"TimeWindow", mxTmp);

	mxCellInfo = mxCreateCellMatrix(strmC, 1);
	for (int isC = 0; isC < strmC; isC++)
	{
		CString str = m_arrStream[isC]->GetName();
		mxTmp = mxCreateString(str);
		mxSetCell(mxCell, isC, mxTmp );
		dSamplesPerSeg[isC]=(double) m_arrStream[isC]->GetDefaultSamplesPerSegment();
		IMCSChannel *pChannel = new IMCSChannel;
		for(short iChannelCtr = 0; iChannelCtr < iChannelCount; ++iChannelCtr)
		{
			dChannelID[isC*iChannelCount+iChannelCtr]=-1.0;
			if(iChannelCtr < m_arrStream[isC]->GetChannelCount())
			{
				CString str = m_arrStream[isC]->GetChannelName(iChannelCtr);
				mxTmp = mxCreateString(str);
				mxSetCell(mxCellChannels, isC*iChannelCount+iChannelCtr, mxTmp );
				pChannel->AttachDispatch(m_arrStream[isC]->GetChannel(iChannelCtr));
				dChannelID[isC*iChannelCount+iChannelCtr]=(double)pChannel->GetHWID();
			}
		}
		delete pChannel;
		str = m_arrStream[isC]->GetDataType();
		if (str=="trigger")
		{
			IMCSInfoTrigger m_InfoTrigger;
			LPDISPATCH tmpDispatch = m_arrStream[isC]->GetInfo();
			if(tmpDispatch)
			{
				m_InfoTrigger.AttachDispatch(tmpDispatch);
				const char *fieldnames[] = 
				{"StreamName","DataType","Channel","DeadTime","Level","Slope","InputBufferName"};
				mxTmp = mxCreateStructMatrix(1,1,7, fieldnames);

				mxTmp2 = mxCreateString(m_arrStream[isC]->GetName());
				mxSetField(mxTmp, 0,"StreamName", mxTmp2 );

				mxTmp2 = mxCreateString(str);
				mxSetField(mxTmp, 0,"DataType", mxTmp2 );

				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)(m_InfoTrigger.GetChannel()+1);
				mxSetField(mxTmp, 0,"Channel", mxTmp2);
	
				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoTrigger.GetDeadTime();
				mxSetField(mxTmp, 0,"DeadTime", mxTmp2);
	
				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoTrigger.GetLevel();
				mxSetField(mxTmp, 0,"Level", mxTmp2);
	
				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoTrigger.GetSlope();
				mxSetField(mxTmp, 0,"Slope", mxTmp2);

				mxTmp2 = mxCreateString(m_InfoTrigger.GetInputBufferID());
				mxSetField(mxTmp, 0,"InputBufferName", mxTmp2 );

				mxSetCell(mxCellInfo, isC, mxTmp );
			}
		}
		else if (str=="spikes")
		{
/*
			int iHardwareID[HARDWAREELECTRODENUM];
			IMCSChannel *pChannel = new IMCSChannel;
			for(int i=0;i<m_arrStream[isC]->GetChannelCount();i++)
			{
				pChannel->AttachDispatch(m_arrStream[isC]->GetChannel(i));
				iHardwareID[i]=(int)pChannel->GetHWID();
			}
			delete pChannel;
*/
			IMCSInfoSpike m_InfoSpike;
			LPDISPATCH tmpDispatch = m_arrStream[isC]->GetInfo();
			if(tmpDispatch)
			{
				m_InfoSpike.AttachDispatch(tmpDispatch);
/*
				int iPropArrHardwareIDPosition[HARDWAREELECTRODENUM];
				for(int i=0;i<HARDWAREELECTRODENUM;i++)
				{
					int iHWID = (int)m_InfoSpike.GetChannelHWID(i);
					if(iHWID != -1 )
					{
						iPropArrHardwareIDPosition[iHWID]=i;
					}
				}
*/				
				const char *fieldnames[] = 	{"StreamName", "DataType", "PreTrigger", "PostTrigger", "DeadTime", "Level", "Slope", "ChannelNames"};
				mxTmp = mxCreateStructMatrix(1,1,8, fieldnames);

				mxTmp2 = mxCreateString(m_arrStream[isC]->GetName());
				mxSetField(mxTmp, 0,"StreamName", mxTmp2 );

				mxTmp2 = mxCreateString(str);
				mxSetField(mxTmp, 0,"DataType", mxTmp2 );

				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoSpike.GetPreTrigger();
				mxSetField(mxTmp, 0,"PreTrigger", mxTmp2);
	
				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoSpike.GetPostTrigger();
				mxSetField(mxTmp, 0,"PostTrigger", mxTmp2);
	
				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoSpike.GetDeadTime();
				mxSetField(mxTmp, 0,"DeadTime", mxTmp2);
	
				mxArray* mxCellInfoChannels = mxCreateCellMatrix(1, m_arrStream[isC]->GetChannelCount());
				mxTmp2 = mxCreateDoubleMatrix(1, m_arrStream[isC]->GetChannelCount(), mxREAL);
				mxTmp3 = mxCreateDoubleMatrix(1, m_arrStream[isC]->GetChannelCount(), mxREAL);

				IMCSChannel *pChannel = new IMCSChannel;
				for(short iC=0; iC<m_arrStream[isC]->GetChannelCount();iC++)
				{
					pChannel->AttachDispatch(m_arrStream[isC]->GetChannel(iC));

					dTmp = mxGetPr(mxTmp2);
					dTmp[iC]=(double)m_InfoSpike.GetThresholdLevel(static_cast<short>(pChannel->GetHWID()));
					dTmp = mxGetPr(mxTmp3);
					dTmp[iC]=(double)m_InfoSpike.GetThresholdSlope(static_cast<short>(pChannel->GetHWID()));
					CString str = m_arrStream[isC]->GetChannelName(iC);
					mxTmp4 = mxCreateString(str);
					mxSetCell(mxCellInfoChannels, iC, mxTmp4 );
				}
				delete pChannel;

				mxSetField(mxTmp, 0,"Level", mxTmp2);
				mxSetField(mxTmp, 0,"Slope", mxTmp3);
				mxSetField(mxTmp, 0,"ChannelNames", mxCellInfoChannels);

				mxSetCell(mxCellInfo, isC, mxTmp );
			}
		}
		else if (str=="params")
		{
			IMCSInfoParam m_InfoParam;
			LPDISPATCH tmpDispatch = m_arrStream[isC]->GetInfo();
			if(tmpDispatch)
			{
				m_InfoParam.AttachDispatch(tmpDispatch);
				const char *fieldnames[] = 
					{"StreamName","DataType","Parameters","InputBufferName","NumTimeWindows",
					"TimeWindowChoice","TimeWindowStartTrigger","TimeWindowStopTrigger",
					"TimeWindowTime1","TimeWindowTime2"};
				mxTmp = mxCreateStructMatrix(1,1,8, fieldnames);

				mxTmp2 = mxCreateString(m_arrStream[isC]->GetName());
				mxSetField(mxTmp, 0,"StreamName", mxTmp2 );

				mxTmp2 = mxCreateString(str);
				mxSetField(mxTmp, 0,"DataType", mxTmp2 );

				CStringArray arrStr;
				arrStr.SetSize(0,12);

				if(m_InfoParam.MinPos()>=0)
					arrStr.Add("min");

				if(m_InfoParam.MaxPos()>=0)
					arrStr.Add("max");

				if(m_InfoParam.TMinPos()>=0)
					arrStr.Add("tmin");

				if(m_InfoParam.TMaxPos()>=0)
					arrStr.Add("tmax");

				if(m_InfoParam.HeightPos()>=0)
					arrStr.Add("height");

				if(m_InfoParam.WidthPos()>=0)
					arrStr.Add("width");

				if(m_InfoParam.AmplitudePos()>=0)
					arrStr.Add("amplitude");

				if(m_InfoParam.AreaPos()>=0)
					arrStr.Add("area");

				if(m_InfoParam.NumberPos()>=0)
					arrStr.Add("number");

				if(m_InfoParam.RatePos()>=0)
					arrStr.Add("rate");

				mxArray *mxCellParams = mxCreateCellMatrix(arrStr.GetSize(), 1);

				for(int iaS = 0; iaS < arrStr.GetSize(); iaS++)
				{
					mxTmp2 = mxCreateString(arrStr.GetAt(iaS));
					mxSetCell(mxCellParams , iaS, mxTmp2 );
				}
				mxSetField(mxTmp, 0,"Parameters", mxCellParams );

				mxTmp2 = mxCreateString(m_InfoParam.InputBufferName());
				mxSetField(mxTmp, 0,"InputBufferName", mxTmp2 );

				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoParam.NumTimeWindows();
				mxSetField(mxTmp, 0,"NumTimeWindows", mxTmp2);

				if(m_InfoParam.TimeWindowChoice()==0)
				{
					mxTmp2 = mxCreateString("Fixed Window");
				}
				else if(m_InfoParam.TimeWindowChoice()==1)
				{
					mxTmp2 = mxCreateString("Start On Trigger");
				}
				else if(m_InfoParam.TimeWindowChoice()==2)
				{
					mxTmp2 = mxCreateString("Start And Stop On Trigger");
				}
				else 
				{
					mxTmp2 = mxCreateString("not recorded");
				}
				mxSetField(mxTmp, 0,"TimeWindowChoice", mxTmp2);

				CString strTrigger="";
				if(m_InfoParam.TimeWindowChoice()>0)
				{
					strTrigger="not recorded";
					for (int isC2=0;isC2<strmC;isC2++)
					{
						if(m_arrStream[isC2]->GetID()==m_InfoParam.TimeWindowStartTriggerID())
						{
							strTrigger=m_arrStream[isC2]->GetName();
							break;
						}
					}
				}
				mxTmp2 = mxCreateString(strTrigger);
				mxSetField(mxTmp, 0,"TimeWindowStartTrigger", mxTmp2);

				strTrigger="";
				if(m_InfoParam.TimeWindowChoice()>1)
				{
					strTrigger="not recorded";
					for (int isC2=0;isC2<strmC;isC2++)
					{
						if(m_arrStream[isC2]->GetID()==m_InfoParam.TimeWindowStopTriggerID())
						{
							strTrigger=m_arrStream[isC2]->GetName();
							break;
						}
					}
				}
				mxTmp2 = mxCreateString(strTrigger);
				mxSetField(mxTmp, 0,"TimeWindowStopTrigger", mxTmp2);

				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoParam.TimeWindowTime1();
				mxSetField(mxTmp, 0,"TimeWindowTime1", mxTmp2);

				mxTmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
				dTmp = mxGetPr(mxTmp2);
				dTmp[0]=(double)m_InfoParam.TimeWindowTime2();
				mxSetField(mxTmp, 0,"TimeWindowTime2", mxTmp2);

				mxSetCell(mxCellInfo, isC, mxTmp );
			}
		}
		else //if (str=="...") not needed/programmed yet
		{
				const char *fieldnames[] = {"StreamName","DataType"};
				mxTmp = mxCreateStructMatrix(1,1,2, fieldnames);

				mxTmp2 = mxCreateString(m_arrStream[isC]->GetName());
				mxSetField(mxTmp, 0,"StreamName", mxTmp2 );

				mxTmp2 = mxCreateString(str);
				mxSetField(mxTmp, 0,"DataType", mxTmp2 );
				mxSetCell(mxCellInfo, isC, mxTmp );
		}
	}

	mxSetField(yp, 0,"SamplesPerSegment", mxSamplesPerSeg);
	mxSetField(yp, 0,"StreamNames", mxCell);
	mxSetField(yp, 0,"ChannelNames", mxCellChannels);
	mxSetField(yp, 0,"ChannelID", mxChannelID);
	mxSetField(yp, 0,"StreamInfo", mxCellInfo);

	return;
}



//MEX Code Begin *************************

void mexFunction(
                 int nlhs,       mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]
		 )
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState()); //Visual C++ 6.0
	char	*buf;
	mxArray *mxaBuf;
	unsigned int	buflen;

//	CMCStreamMEXApp* thisApp = ((CMCStreamMEXApp*)AfxGetApp());

	if(!g_pStreamMEX)
		g_pStreamMEX = new CMCStreamMEX;
			
	/* check arguments */
	if (nrhs != 1) {
		mexErrMsgTxt("MCStreamMEX requires one input argument.");
	} else if (nlhs > 1) {
		mexErrMsgTxt("MCStreamMEX requires zero or one output arguments.");
	}
	if(!mxIsStruct(prhs[0])){
		mexErrMsgTxt("MCStreamMEX requires a struct as input argument.");
	}
	if(mxGetFieldNumber(prhs[0],"function")==-1){
		mexErrMsgTxt("MCStreamMEX input struct requires field 'function' (with name of OLE Object Function)");
	}
	mxaBuf=mxGetField(prhs[0], 0, "function");
	if(!mxIsChar(mxaBuf)){
		mexErrMsgTxt("MCStreamMEX input struct field 'function' must be of class char)");
	}
	buflen = (mxGetM(mxaBuf) * mxGetN(mxaBuf)) + 1;
	buf = (char*) mxCalloc(buflen, sizeof(char));
	if(buf==NULL) {
		mexErrMsgTxt("Not enough heap space to hold converted string.");
	}
	if(mxGetString(mxaBuf, buf, buflen)!=0)
	{
	    mexErrMsgTxt("Could not get string.");
	}
	/* end check arguments */


	if(strcmp(buf,			/****/"OpenFile"/****/			)==0){
		
		if(mxGetFieldNumber(prhs[0],"Filename")==-1){
			mexErrMsgTxt("MCStreamMEX OpenFile input struct requires field 'Filename')");
		}
		mxaBuf=mxGetField(prhs[0], 0, "Filename");
		if(!mxIsChar(mxaBuf)){
			mexErrMsgTxt("MCStreamMEX OpenFile input struct requires field 'Filename' of class char)");
		}
		buflen = (mxGetM(mxaBuf) * mxGetN(mxaBuf)) + 1;
		buf = (char*) mxCalloc(buflen, sizeof(char));
		if(buf==NULL) {
			mexErrMsgTxt("Not enough heap space to hold converted Filename string.");
		}
		if(mxGetString(mxaBuf, buf, buflen)!=0)
		{
		    mexErrMsgTxt("Could not get Filename string.");
		}
		const char *fieldnames[] = {"HeaderVersion", "MillisamplesPerSecond", 
			"StreamCount", "StreamNames", "SamplesPerSegment",
			"ChannelCount", "ChannelNames", "ChannelID", "RecordingDate", "RecordingStopDate",
			"ZeroADValue", "UnitsPerAD", "UnitSign", "SweepStartTime",
			"SweepLength", "TriggerStreamID", "TimeWindow", "StreamInfo",
			"SoftwareVersion","MillisamplesPerSecond2","SourceType","TotalChannels", "SweepStopTime"};
		YP_OUT = mxCreateStructMatrix(1,1,23, fieldnames);
		mxaBuf = YP_OUT;
		g_pStreamMEX->OpenFile(buf,mxaBuf);

	} else if(strcmp(buf,	/****/"CloseFile"/****/			)==0)

	{
		g_pStreamMEX->CloseFile();

	} 
	else if(strcmp(buf,	/****/"GetFromTo"/****/			)==0)
	{
		if(mxGetFieldNumber(prhs[0],"startend")==-1)
		{
			mexErrMsgTxt("MCStreamMEX GetFromTo input struct requires field 'startend'");
		}
		mxaBuf=mxGetField(prhs[0], 0, "startend");
		if(!mxIsDouble(mxaBuf)){
			mexErrMsgTxt("MCStreamMEX GetFromTo input struct requires field 'startend' of class double");
		}
		double *pdFromTo;
		pdFromTo = mxGetPr(mxaBuf);

		if(mxGetFieldNumber(prhs[0],"StreamNumber")==-1){
			mexErrMsgTxt("MCStreamMEX GetFromTo input struct requires field 'StreamNumber'");
		}
		mxaBuf=mxGetField(prhs[0], 0, "StreamNumber");
		if(!mxIsDouble(mxaBuf)){
			mexErrMsgTxt("MCStreamMEX GetFromTo input struct requires field 'StreamNumber' of class double");
		}
		int iStreamNumber = (int) mxGetScalar(mxaBuf);

		int selectedChannel = -1;
		if(mxGetFieldNumber(prhs[0],"hardwarechannelid") != -1)
		{
			mxaBuf=mxGetField(prhs[0], 0, "hardwarechannelid");
			if(!mxIsDouble(mxaBuf))
			{
				mexErrMsgTxt("MCStreamMEX GetFromTo input struct field 'hardwarechannelid' must be of class double");
			}
			selectedChannel = (int) mxGetScalar(mxaBuf);
		}
		BOOL bTimesOnly=FALSE;
		int iSorter[130];
		for (int i=0;i<130;i++)
			iSorter[i]= -1;
		if(mxGetFieldNumber(prhs[0], "sorterleft") > -1){
			mxaBuf=mxGetField(prhs[0], 0, "sorterleft");
			double *dBuf = mxGetPr(mxaBuf);
			for (int i=0;i<(mxGetM(mxaBuf)*mxGetN(mxaBuf));i++)
				iSorter[i]=(int)dBuf[i];
		};
		mxArray* mxEventtimes=NULL;
		double dRange=0.040; //in ms, is set to tick lenght in MATLAB code
		if(mxGetFieldNumber(prhs[0], "eventtimes") > -1){
			mxEventtimes=mxGetField(prhs[0], 0, "eventtimes");
			if(mxGetFieldNumber(prhs[0], "eventtimesrange") > -1){
				dRange=mxGetScalar(mxGetField(prhs[0], 0, "eventtimesrange"));
			}
		};
		
		const char *fieldsAnalog[] = {"data"};
		const char *fieldsSpikes[] = {"spiketimes", "spikevalues"};
		const char *fieldsTrigger[] = {"times", "values"};
		const char *fieldsAnalyzer[] = {"times","min","max","tmin","tmax","height",
										"width","amplitude","area","number","rate"};

		if (g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="analog" ||
				g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="chat" ||
				g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="filter" ||
				g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="digital")
		{
			mxaBuf = mxCreateStructMatrix(1,1,1, fieldsAnalog);
		} 
		else if (g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="spikes")
		{
			if(mxGetFieldNumber(prhs[0],"timesonly") != -1)
			{
				mxaBuf=mxGetField(prhs[0], 0, "timesonly");
				if(!mxIsDouble(mxaBuf))
				{
					mexErrMsgTxt("MCStreamMEX GetFromTo input struct field 'timesonly' must be of class double");
				}
				bTimesOnly = (BOOL)(mxGetScalar(mxaBuf)==1);
			}
			mxaBuf = mxCreateStructMatrix(1,1,2, fieldsSpikes);
		} 
		else if (g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="trigger")
		{
			mxaBuf = mxCreateStructMatrix(1,1,2, fieldsTrigger);
		} 
		else if (g_pStreamMEX->m_arrStream[iStreamNumber]->GetDataType()=="params")
		{
			mxaBuf = mxCreateStructMatrix(1,1,11, fieldsAnalyzer);
		}
		else
			mexErrMsgTxt("Data Type in GetFromTo not implemented yet");
		

		g_pStreamMEX->GetFromTo(pdFromTo[0],pdFromTo[1],iStreamNumber,mxaBuf,
			iSorter,selectedChannel,bTimesOnly,mxEventtimes,dRange);
		YP_OUT = mxaBuf;

	} 
	else if(strcmp(buf,	/****/"GetSweepNumber"/****/ )==0)
	{
		const char *fieldnames[] = {"SweepNumber"};
		YP_OUT = mxCreateStructMatrix(1,1,1, fieldnames);
		mxaBuf = YP_OUT;
		mxArray *mxTmp;
		double *dTmp;
		mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		dTmp = mxGetPr(mxTmp);
		dTmp[0]=(double) g_pStreamMEX->m_lSweepNumber;
		mxSetField(mxaBuf, 0,"SweepNumber", mxTmp);
	} 
	else if(strcmp(buf,	/****/"SetSweepNumber"/****/ )==0)
	{
		if(mxGetFieldNumber(prhs[0],"SweepNumber")==-1){
			mexErrMsgTxt("MCStreamMEX SetSweepNumber input struct requires field 'SweepNumber')");
		}
		mxaBuf=mxGetField(prhs[0], 0, "SweepNumber");
		if(!mxIsDouble(mxaBuf)){
			mexErrMsgTxt("MCStreamMEX SetSweepNumber input struct requires field 'SweepNumber' of class double)");
		}
		g_pStreamMEX->m_lSweepNumber = (long) mxGetScalar(mxaBuf);
		const char *fieldnames[] = {"SweepNumber"};
		YP_OUT = mxCreateStructMatrix(1,1,1, fieldnames);
		mxaBuf = YP_OUT;
		mxArray *mxTmp;
		double *dTmp;
		mxTmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		dTmp = mxGetPr(mxTmp);
		dTmp[0]=(double) g_pStreamMEX->m_lSweepNumber;
		mxSetField(mxaBuf, 0,"SweepNumber", mxTmp);
	} 
	else if(strcmp(buf,	/****/"GetChunk"/****/ )==0)
	{
		if(mxGetFieldNumber(prhs[0],"StreamNumber")==-1){
			mexErrMsgTxt("MCStreamMEX GetChunk input struct requires field 'StreamNumber')");
		}
		mxaBuf=mxGetField(prhs[0], 0, "StreamNumber");
		if(!mxIsDouble(mxaBuf)){
			mexErrMsgTxt("MCStreamMEX GetChunk input struct requires field 'StreamNumber' of class double)");
		}
		int iStreamNumber = (int) mxGetScalar(mxaBuf);
		if(mxGetFieldNumber(prhs[0],"ChunkNumber")==-1){
			mexErrMsgTxt("MCStreamMEX GetChunk input struct requires field 'ChunkNumber')");
		}
		mxaBuf=mxGetField(prhs[0], 0, "ChunkNumber");
		if(!mxIsDouble(mxaBuf)){
			mexErrMsgTxt("MCStreamMEX GetChunk input struct requires field 'ChunkNumber' of class double)");
		}
		int iChunk = (int) mxGetScalar(mxaBuf);
		const char *fieldnames[] = {"ChunkTime", "ChunkData"};
		YP_OUT = mxCreateStructMatrix(1,1,2, fieldnames);
		mxaBuf = YP_OUT;
		g_pStreamMEX->GetChunk(iStreamNumber,iChunk,mxaBuf);

	} 
	else					/**Function not implemented**/
	{
	    mexErrMsgTxt("Function not implemented");
	}
	
	return;
}
  



//MEX Code End *************************



/*	for (iChunk=0;iChunk<m_arrChunkPtrArrays[iStream]->GetSize();iChunk++)
	{
		pChunk=m_arrChunkPtrArrays[iStream]->m_arrChunks[iChunk];
		pTS->AttachDispatch(pChunk->GetTimeStampTo());
		if( (pTS->GetSecondFromStart() > lFromSec) 
			||
			((pTS->GetSecondFromStart() == lFromSec)
				&& 
				((pTS->GetMillisecondFromStart() > sFromMSec)
					||
					((pTS->GetMillisecondFromStart() == sFromMSec)
						&& (pTS->GetMicrosecondFromStart() > sFromUSec)
					)
				)
			)
		)
		{
			break;		
		}
	}
*/

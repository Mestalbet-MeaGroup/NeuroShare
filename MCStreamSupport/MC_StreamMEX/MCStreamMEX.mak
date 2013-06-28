# Microsoft Developer Studio Generated NMAKE File, Based on MCStreamMEX.dsp
!IF "$(CFG)" == ""
CFG=MCStreamMEX - Win32 Release
!MESSAGE No configuration specified. Defaulting to MCStreamMEX - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "MCStreamMEX - Win32 Release" && "$(CFG)" != "MCStreamMEX - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "MCStreamMEX.mak" CFG="MCStreamMEX - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "MCStreamMEX - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "MCStreamMEX - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "MCStreamMEX - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\MCStreamMEX.dll"


CLEAN :
	-@erase "$(INTDIR)\mcstream.obj"
	-@erase "$(INTDIR)\MCStreamMEX.obj"
	-@erase "$(INTDIR)\MCStreamMEX.pch"
	-@erase "$(INTDIR)\MCStreamMEX.res"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\MCStreamMEX.dll"
	-@erase "$(OUTDIR)\MCStreamMEX.exp"
	-@erase "$(OUTDIR)\MCStreamMEX.lib"
	-@erase "$(OUTDIR)\MCStreamMEX.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "\MATLABR11\EXTERN\INCLUDE" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "MATLAB_MEX_FILE" /D "_WINDLL" /Fp"$(INTDIR)\MCStreamMEX.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC_PROJ=/l 0x407 /fo"$(INTDIR)\MCStreamMEX.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\MCStreamMEX.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=c:\matlabr11\extern\include\mymeximports.lib winmm.lib /nologo /subsystem:windows /dll /incremental:no /pdb:"$(OUTDIR)\MCStreamMEX.pdb" /debug /machine:I386 /def:".\MCStreamMEX.def" /out:"$(OUTDIR)\MCStreamMEX.dll" /implib:"$(OUTDIR)\MCStreamMEX.lib" 
DEF_FILE= \
	".\MCStreamMEX.def"
LINK32_OBJS= \
	"$(INTDIR)\mcstream.obj" \
	"$(INTDIR)\MCStreamMEX.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\MCStreamMEX.res"

"$(OUTDIR)\MCStreamMEX.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "MCStreamMEX - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\MCStreamMEX.dll"


CLEAN :
	-@erase "$(INTDIR)\mcstream.obj"
	-@erase "$(INTDIR)\MCStreamMEX.obj"
	-@erase "$(INTDIR)\MCStreamMEX.pch"
	-@erase "$(INTDIR)\MCStreamMEX.res"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\MCStreamMEX.dll"
	-@erase "$(OUTDIR)\MCStreamMEX.exp"
	-@erase "$(OUTDIR)\MCStreamMEX.lib"
	-@erase "$(OUTDIR)\MCStreamMEX.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "\MATLABR11\EXTERN\INCLUDE" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "MATLAB_MEX_FILE" /D "_WINDLL" /Fp"$(INTDIR)\MCStreamMEX.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
RSC_PROJ=/l 0x407 /fo"$(INTDIR)\MCStreamMEX.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\MCStreamMEX.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=c:\matlabr11\extern\include\mymeximports.lib winmm.lib /nologo /subsystem:windows /dll /incremental:no /pdb:"$(OUTDIR)\MCStreamMEX.pdb" /debug /machine:I386 /def:".\MCStreamMEX.def" /out:"$(OUTDIR)\MCStreamMEX.dll" /implib:"$(OUTDIR)\MCStreamMEX.lib" 
DEF_FILE= \
	".\MCStreamMEX.def"
LINK32_OBJS= \
	"$(INTDIR)\mcstream.obj" \
	"$(INTDIR)\MCStreamMEX.obj" \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\MCStreamMEX.res"

"$(OUTDIR)\MCStreamMEX.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("MCStreamMEX.dep")
!INCLUDE "MCStreamMEX.dep"
!ELSE 
!MESSAGE Warning: cannot find "MCStreamMEX.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "MCStreamMEX - Win32 Release" || "$(CFG)" == "MCStreamMEX - Win32 Debug"
SOURCE=.\mcstream.cpp

"$(INTDIR)\mcstream.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\MCStreamMEX.pch"


SOURCE=.\MCStreamMEX.cpp

"$(INTDIR)\MCStreamMEX.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\MCStreamMEX.pch"


SOURCE=.\MCStreamMEX.rc

"$(INTDIR)\MCStreamMEX.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)


SOURCE=.\StdAfx.cpp

!IF  "$(CFG)" == "MCStreamMEX - Win32 Release"

CPP_SWITCHES=/nologo /MT /W3 /GX /O2 /I "\MATLABR11\EXTERN\INCLUDE" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "MATLAB_MEX_FILE" /D "_WINDLL" /Fp"$(INTDIR)\MCStreamMEX.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\MCStreamMEX.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "MCStreamMEX - Win32 Debug"

CPP_SWITCHES=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "\MATLABR11\EXTERN\INCLUDE" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "MATLAB_MEX_FILE" /D "_WINDLL" /Fp"$(INTDIR)\MCStreamMEX.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\MCStreamMEX.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ENDIF 


!ENDIF 


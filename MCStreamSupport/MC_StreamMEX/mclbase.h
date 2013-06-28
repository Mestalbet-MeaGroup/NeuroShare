/*
 * @(#)mclbase.h    generated by: makeheader 5.1.5  Fri Jul 20 17:38:25 2012
 *
 *		built from:	../../src/include/copyright.h
 *				../../src/include/pragma_interface.h
 *				LastError.cpp
 *				app_state.cpp
 *				mclException.cpp
 *				mclFileUtilities.cpp
 *				mclOutputHandler.cpp
 *				mclPathMacros.cpp
 *				mclProxy.cpp
 *				mclRuntimePathMacros.cpp
 *				mclStatic.cpp
 *				mclStrUtils.cpp
 *				mxarray_utils.cpp
 *				runmain.cpp
 */

#if defined(_MSC_VER)
# pragma once
#endif
#if defined(__GNUC__) && (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ > 3))
# pragma once
#endif

#ifndef mclbase_h
#define mclbase_h


/*
 * Copyright 1984-2003 The MathWorks, Inc.
 * All Rights Reserved.
 */



/* Copyright 2003-2006 The MathWorks, Inc. */

/* Only define EXTERN_C if it hasn't been defined already. This allows
 * individual modules to have more control over managing their exports.
 */
#ifndef EXTERN_C

#ifdef __cplusplus
  #define EXTERN_C extern "C"
#else
  #define EXTERN_C extern
#endif

#endif


EXTERN_C void mclSetLastErrIdAndMsg(const char* newid, const char* newmsg);

 
EXTERN_C const char* mclGetLastErrorMessage();

 
/* Get stack trace string when error happens
*/
EXTERN_C int mclGetStackTrace(char*** stack);

 
/* Free the stack trace string allocated earlier 
*/
EXTERN_C int mclFreeStackTrace(char*** stack, int nStackDepth);


#include <stdarg.h>
#include <string.h>
#include <wchar.h>
#include "tmwtypes.h"


#define mclUndefined 0
#define mclNoMvm 1
#define mclStandaloneApp 2
#define mclStandaloneContainer 3
#define mclJavaBuilder 4



EXTERN_C void mclAcquireMutex(void);


EXTERN_C void mclReleaseMutex(void);


EXTERN_C bool mclIsMCRInitialized();


EXTERN_C bool mclIsJVMEnabled();


EXTERN_C const char* mclGetLogFileName();


EXTERN_C bool mclIsNoDisplaySet();


EXTERN_C bool mclInitializeApplication(const char** options, size_t count);


EXTERN_C bool mclTerminateApplication(void);


EXTERN_C bool mclIsMcc();


typedef int (*mclOutputHandlerFcn)(const char *s);


#include <string.h>


/* Extract the path from a file name specified by either absolute or
 * relative path. For example:
 *
 *   /home/foo/bar.exe -> /home/foo
 *   ./bar.exe -> <full path to cwd>/bar.exe
 *   bar.exe -> <empty string>
 *
 * Returns a pointer to the memory passed in by the caller. 
 */
EXTERN_C void separatePathName(const char *fullname, char *buf, size_t bufLen);


typedef void* HMCRINSTANCE;


EXTERN_C bool mclFreeStrArray(char **array, size_t elements);


#include "matrix.h"


EXTERN_C void mclFreeArrayList(int nargs, mxArray** ppxArgs);


EXTERN_C mxArray *mclCreateCellArrayFromArrayList(int narray, mxArray *parray[]);


EXTERN_C mxArray* mclCreateSharedCopy(mxArray* px);


EXTERN_C mxArray* mclCreateEmptyArray(void);


EXTERN_C mxArray* mclCreateSimpleFunctionHandle(mxFunctionPtr fcn);


EXTERN_C mxArray* mclMxSerialize(const mxArray * pa);


EXTERN_C mxArray* mclMxDeserialize(const void* ps, size_t len);


EXTERN_C void mclMxDestroyArray(mxArray* pa, bool onInterpreterThread);


EXTERN_C bool mclMxIsA(mxArray* pa, const char *cname);


/* Main functions passed to mclRunMain must be of this type. This typedef
 * must be placed OUTSIDE of an extern "C" block to ensure that it has the
 * right linkage in the automatically generated MCLMCRRT proxy API. See
 * mclmcrrt/GenLibProxyAPI.pl for more details.
 */
typedef int (*mclMainFcnType)(int, const char **);


EXTERN_C int mclRunMain(mclMainFcnType run_main,
               int argc,
               const char **argv);

#endif /* mclbase_h */
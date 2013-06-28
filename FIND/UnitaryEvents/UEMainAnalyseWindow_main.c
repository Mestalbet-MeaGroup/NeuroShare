/*
 * MATLAB Compiler: 4.3 (R14SP3)
 * Date: Fri Jan  6 16:06:01 2006
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe"
 * "UEMainAnalyseWindow" 
 */

#include <stdio.h>
#include "mclmcr.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_UEMainAnalyseWindow_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;


static int mclDefaultPrintHandler(const char *s)
{
    return fwrite(s, sizeof(char), strlen(s), stdout);
}

static int mclDefaultErrorHandler(const char *s)
{
    int written = 0, len = 0;
    len = strlen(s);
    written = fwrite(s, sizeof(char), len, stderr);
    if (len > 0 && s[ len-1 ] != '\n')
        written += fwrite("\n", sizeof(char), 1, stderr);
    return written;
}


/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_UEMainAnalyseWindow_C_API 
#define LIB_UEMainAnalyseWindow_C_API /* No special import/export declaration */
#endif

LIB_UEMainAnalyseWindow_C_API 
bool UEMainAnalyseWindowInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
    if (_mcr_inst != NULL)
        return true;
    if (!mclmcrInitialize())
        return false;
    if (!mclInitializeComponentInstance(&_mcr_inst,
                                        &__MCC_UEMainAnalyseWindow_component_data,
                                        true, NoObjectType, ExeTarget,
                                        error_handler, print_handler))
        return false;
    return true;
}

LIB_UEMainAnalyseWindow_C_API 
bool UEMainAnalyseWindowInitialize(void)
{
    return UEMainAnalyseWindowInitializeWithHandlers(mclDefaultErrorHandler,
                                                     mclDefaultPrintHandler);
}

LIB_UEMainAnalyseWindow_C_API 
void UEMainAnalyseWindowTerminate(void)
{
    if (_mcr_inst != NULL)
        mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
    int _retval;
    /* Generate and populate the path_to_component. */
    char *path_to_component = separatePathName(argv[0]);
    __MCC_UEMainAnalyseWindow_component_data.path_to_component = path_to_component; 
    if (!UEMainAnalyseWindowInitialize()) {
        free(path_to_component);
        return -1;
    }
    _retval = mclMain(_mcr_inst, argc, argv, "UEMainAnalyseWindow", 0);
    if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
    UEMainAnalyseWindowTerminate();
    free(path_to_component);
    mclTerminateApplication();
    return _retval;
}

int main(int argc, const char **argv)
{
    if (!mclInitializeApplication(
        __MCC_UEMainAnalyseWindow_component_data.application_options,
        __MCC_UEMainAnalyseWindow_component_data.application_option_count))
        return 0;
    
    return mclRunMain(run_main, argc, argv);
}

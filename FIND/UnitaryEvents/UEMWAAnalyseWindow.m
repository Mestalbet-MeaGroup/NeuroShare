function UEinMW = UEMWAAnalyseWindow(Alpha,Complexity,UEMethod,Wildcard,...
                                     Basis,ExistingPatterns,w,...
                                     NShuffleElements,NMCSteps,gen_case)
% UEinMW = UEMWAAnalyseWindow(Alpha,Complexity,Basis,UEMethod,Wildcard,...
%                             Basis,ExistingPatterns,w,...
%                             NShuffleElements,NMCSteps,gen_case)
% ***************************************************************
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% *                                                             *
% * Usage:           COMMENT !!!!!!!!!!                         *
% *                                                             *
% * Input:  w:  Window-structure                                *
% *                                                             *
% * Passes: (to UEcore)                                         *
% *                                                             *
% *         Alpha                                               *
% *         Complexity                                          *
% *         Bin.Results.Basis                                   *
% *         Raw.Results.ExistingPatterns                        *
% *         structure: Window                                   *
% *         UEmethod                                            *
% *         Wildcard                                            *
% *         NShuffleElements                                    *
% *         NMCSteps                                            *
% *         gen_case                                            *
% *                                                             *
% *                                                             *
% * Output: structure UEinMW with:                              *
% *                                                             *
% *         UEinMW.bstjk  (Results of UE_core-Analysis)         *
% *         UEinMW.ues                                          *
% *         UEinMW.it                                           *
% *         UEinMW.Time   (Information about analysed window)   *
% *         UEinMW.Wrange                                       *
% *                                                             *
% *                                                             *
% * Uses:                                                       *
% *         UEcore()                                            *
% *         d3tod2()                                            *
% *                                                             *
% * History:                                                    *
% *                                                             *
% *     UEMWAAnalyseWindow consists of main part of original    *
% *     UEMWA.m                                                 *  
% *                                                             *
% *         (3) passes CSR parameters to UEcore()               *
% *            PM, 14.9.02, FfM                                 *
% *         (2) implemetation of new UEcore() with UEMethod     *
% *             and Wildcard                                    *
% *            PM, 1.8.02, FfM                                  *
% *         (1) splitting of original UEMWA.m                   *
% *            PM, 20.2.02, FfM                                 *
% *                                                             *
% * History of original UEMWA.m                                 *
% *                                                             *
% *         (8) wrap around option added. UE_core forced to     *
% *             return full statistics.                         *
% *            MD, 29.7.97, Jerusalem                           * 
% *         (7) Tslid argument now in ms                        *
% *            MD, 27.5.97, Jerusalem                           *
% *         (6) version 5 matrix operations                     *
% *            MD, 4.5.97, Freiburg                             *
% *         (5) ijk interface to pat2cell introduced,           *
% *             UEMWA_Mat no longer needed here                 *
% *            MD, 2.4.1997, Freiburg                           *
% *         (4) commented                                       *
% *            SG, 11.3.1997, Jerusalem                         *
% *         (3) commented                                       *
% *            MD, 3.3.1997, Freiburg                           *
% *         (2) test version for new core                       *
% *            MD, 24.2.1997, Jerusalem                         *
% *         (1) made faster                                     *
% *            SG, 25.8.1996                                    *
% *         (0) first version                                   *
% *            SG, 12.3.96                                      * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************


% ***************************************************
% * from binned data organized 3d by neuron         *
% * time and trial construct a 2d matrix            *
% * organized by neuron and time where in the time  *
% * dimension trials are glued consecutively        *
% *************************************************** 

[bst, bstjk] = d3tod2(w.Data,1,2,3);


% **************************************
% * compute unitary events statistics  *
% **************************************
% [ues,it,rates] =
% UE_core(bst',significance,complexity,BinBasis,PAT_EXIST);

[ues,it,bstjk2] = UEcore(bst', bstjk', w.Data,...
                         Alpha,...
                         Complexity,...
                         Basis,...
                         UEMethod, Wildcard,...
			             ExistingPatterns,...
                         NShuffleElements,...
                         NMCSteps,...
                         gen_case);
        
bstjk = bstjk2';
                     
UEinMW.bstjk  = bstjk;
UEinMW.ues    = ues;
UEinMW.it     = it;
UEinMW.Wrange = w.Parameters.Wrange;
UEinMW.Time   = w.Parameters.Time;

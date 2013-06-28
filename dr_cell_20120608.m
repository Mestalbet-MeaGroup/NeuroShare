% ++++++++++++++++++++++++++++++++++
% ++++++++++ Dr.Cell 1.04 ++++++++++
% ++++++++++++++++++++++++++++++++++

function dr_cell %#ok<FNDEF>

    disp ('--- Dr.Cell 1.04 ---');
    
    warning off all;
    % Folgende Variablen sind global, um sie im Workspace verwenden zu können:
    global nr_channel nr_channel_old M T M_OR SaRa NR_SPIKES INDIES EL_NAMES THRESHOLDS SPIKES SPIKES3D SPIKES_OR BURSTS SPIKES_IN_BURSTS SI_EVENTS waitbaradd waitbar_counter h_wait ACTIVITY END BEG EL_NUMS PREF rec_dur rec_dur_string
    global allorone threshrmsdecide ELEC_CHECK CALC COL_SDT SNR SNR_dB Nr_SI_EVENTS Mean_SIB Mean_SNR_dB EL_Auswahl ELEKTRODEN BURSTDUR meanburstduration MBDae STDburst STDburstae IBImean IBIstd aeIBImean aeIBIstd cellselect signal_draw signalCorr_draw timePr kappa_mean
    global MinRise MaxRise MinFall MaxFall MinDuration MaxDuration Meanrise stdMeanRise Meanfall stdMeanFall MeanDuration stdMeanDuration ORDER BURSTTIME numberfiles file %globale Variablen für Netzwerkburstanalyse
    global SubMEA SubMEA_vier                   %globale Varibale für die verschiedenen Subplots
    global ST_EL_Auswahl ST_ELEKTRODEN spiketrainWindow INV_ELEKTRODEN EL_invert_Auswahl varT varTdata varoffset Shapesvar %Andys Variablen 
    global is_open CORRBIN TESTcorr CurElec
    global chosenThreshold SpikeTimes SpikeMaxima_Stellen dv Anzahl_Score NumberCluster ClusterZuordnung_Assign A verschiebung msec S stellenberechnung datainfo KOORDINATEN REST CopyCluster_Zuordnung Cluster SpikeShapes  ValuesinWindow Score_values Maxima_Spikes2_1 Maxima_Spikes2_2 Maxima_Spikes3_1 Maxima_Spikes3_2 Maxima_Spikes3_3 Maxima_Spikes4_1 Maxima_Spikes4_2 Maxima_Spikes4_3 Maxima_Spikes4_4 Copy_ElekSPSO Copy_refractory ElekSPSO;%zum Algorithmus Spike Sorting
    global deleteCheck infoFirstpage 
    global handle_Add handle_draw handle_restore handle_assign datacluster dataCursor COPYX merker scaleSingleWaves bscale copy_i accountedVariance2 accountedVariance3 Clusterpaneltop Clusterpanelbot sizescore Copy_Cluster_Zuordnung copy_w copy_x copy_y copy_z%für Clusteranalyse (innerhalb Spike Sorting)
    global AssignCluster_Figure waveformspaneltop waveformspanelbot %Ergebnisse des Spike Sortings (einzelne "Spike Trains")
    %global first_open first_open4 drawnbefore4 drawnbeforeall spiketraincheck rawcheck %können evtl gelöscht werden - funktioniert es dann noch?
    global Shapes data ti Coeff TEST MX y; % Spikes  Analyse Variablen
    global SPIKES3D_Norm Min Max check Elektrode SPIKES_Discrete Class cln SPIKES3D_discard Sorting Window SubmitSorting SubmitRefinement M_old SPIKES_Class NR_SPIKES_Sorted  NR_BURSTS_Sorted SPIKES_FPCA;
 
            
    % --- Variablendeklaration ---    
    % Allgemein:
    full_path       = 0;    % Pfad der geöffneten Datei
    fileinfo        = 0;    % Fileinfo
    M               = 0;    % Messdaten-Array
    M_OR            = 0;    % Messdaten-Array (Kopie zum Zurücksetzen)
    T               = 0;    % Timestamps
    EL_NAMES        = 0;    % Bezeichnungen der Elektroden
    EL_NUMS         = 0;
    
    % Analyse:
    PREF            = 0;    % Voreinstellungen für die Analyse [1:Multiplikator RMS für Threshold; 2:Anfangszeit zur Berechnung Threshold; 3: Endzeit zu (2); 
                            % 4: Totzeit zw. 2 Spikes; 5: Mind. Anzahl Spikes/Burst; 6: Zeit zw. 1. und 2. Spike im Burst; 7: Zeiten zw. übrigen Spikes; 
                            % 8: Totzeit zw. Bursts; 9: Elektrode für ZeroOut-Berechnung; 10: Threshold für ZeroOut; 11: Nachschwingzeit nach ZeroOut, 12: Hochpassfilter, 13: Tiefpassfilter, 14: ZeroOut]
                            
    SPIKES3D        = [];   % 3D-Matrix: Zeile: Betreffender Spike; Spalte:Betreffende Elektrode; 
                            % Blatt 1: Timestamp des Spikes; Blatt 2: Negative Amplitude des Spikes;
                            % Blatt 3: Positive Amplitude des Spikes; Blatt 4: Ergebnis des NEO des Spikes;
                            % Blatt 5: Negative Signalenergie des Spikes; % Blatt 6: Positive Signalenergie des Spikes
                            % Blatt 7: Spikedauer; Blatt 8: Öffnungswinkel nach links; 
                            % Blatt 9: Öffnungswinkel nach rechts; Blatt 10: varAmplitude; 
                            % Blatt 11: varSpikedauer; Blatt 12: varÖffnungswinkel nach links; Blatt 13: varÖffnungswinkel nach rechts
    Viewselect      = true;                         
    waitbar_counter = 0;
    THRESHOLDS      = 0;    % Thresholds der einzelnen Elektroden
    spikedata       = false;    % 1, wenn Spikedaten vorhanden
    thresholddata   = false;    % 1, wenn Thresholds berechnet wurden
    SPIKES          = 0;    % Spike-Timestamps
    BURSTS          = 0;    % Burst-Timestamps
    SI_EVENTS       = 0;    % Parallelereignis-Timestamps
    NR_SPIKES       = 0;    % Anzahl der Spikes der einzelnen Elektr.
    NR_BURSTS       = 0;    % Anzahl der Bursts der einzelnen Elektr.
    SIB             = 0;    % Durchschn. Spikes/Burst der einzelnen Elektr.
    auto            = true;    % Automatische Threshold berechnung (true) oder manuell (false)
    cellselect      = 1;    % 1  or 2 if Neurons, 0 if MCC
    Mean_SIB        = 0;    % Mittelwert Spikes pro Burst aller Elektroden
    Mean_SNR_dB     = 0;    % Mittelwert SNR in dB
    MBDae           = 0;    % Mittelwert Burstdauer aller Elektroden
    STDburstae      = 0;    % Standardabweichung Burstdauer aller Elektroden
    aeIBImean       = 0;    % Mittelwert Interburstintervalle aller Elektroden
    aeIBIstd        = 0;    % Standardabweichung Interburstintervalle aller Elektroden
    spiketraincheck = false;    % wird eins, wenn eine Spiketrain geladen wurde
    rawcheck        = false;    % wird eins, wenn Rohdaten geladen wurden
    first_open      = false;
    first_open4     = false;
    drawnbefore4    = false;
    drawnbeforeall  = false;
    is_open         = false;
  
    % Stimulation:
    stimulidata     = false;    % 1, wenn Stimulidaten vorhanden
    STIMULI_1       = 0;    % negative Flanken der Stimulation
    STIMULI_2       = 0;    % positive Flanken der Stimulation
    BEGEND          = 0;    % Timestamps der Stimuli (Anfänge und Enden)
    BEG             = 0;    % Timestamps der Stimulistarts
    END             = 0;    % Timestamps der Stimulienden
  
    % Autokorrelation
    CORRBIN = 0;
    
    % Threshold
    varT            = 0;
    varTdata        = 0;
    
    % Spike Analyse, Refinement, Sorting
    data = false;   % Wird auf True gesetzt sobald alle Daten beim 1.Aufruf berechnet wurden
    ti = 0;         % Berechnet die möglichen Spike-Shape Betrachtungsintervalle 
    Sorting = 1;    % necessary Parameter to determine whether Cluster Functions are being called by Refinement or Sorting tool
    Window = 0;     % necessary Parameter to determine whether Spike Sorting Window is open or not
    submit_data = 0; % test if Spike Sorting cluster was submitted so that new Wavelet Coeffs and PCA can be derived
    M_old = [];     % Variable to hold the original Electrode Signal during Sorting Process (only for the currrently sorted Electrode)
    SPIKES_Class = []; % Variable to hold the Class of Sorted Spikes
    SubmitSorting = 0; % necessary Parameter to determine Spikes have already been submitted to the Electrode that is currently sorted
    SubmitRefinement = 0; % necessary Parameter to determine Spikes have already been submitted to the Electrode that is currently refined
    NR_SPIKES_Sorted = []; % Number of the SPIKES of the different Cells after Spike Sorting
    NR_BURSTS_Sorted = []; % Number of the BURSTS of the different Cells after Spike 
    NR_SPIKES_temp = 0; % temporary Variable to store NR_SPIKES_Sorted when Spike Numbers are refreshed through Submit function
    SPIKES_FPCA =[];  % Array of PCA Features calculated from the evaluated Spike Features (First 4 PCA's of the derived Feauture Space)
    preti = 0;
    postti = 0;
   
% ---------------------------------------------------------------------
% --- GUI -------------------------------------------------------------
% ---------------------------------------------------------------------

        % Hauptfenster
        mainWindow = figure('Position',[20 40 1224 700],'Tag','Dr.CELL','Name','Dr.Cell 1.04','NumberTitle','off','Toolbar','none','Resize','off');

        % Infopanel (oben links)
        leftPanel = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 560 370 140],'BackgroundColor',[0.8 0.8 0.8]);

        % Textfeld für Logo
        uicontrol('Parent',leftPanel,'Units','pixels','Position',[8 90 348 35],'HorizontalAlignment','left','Tag','CELL_infoText','String','- Dr.Cell - ','FontSize',24,'Style','text','HorizontalAlignment','center','FontName','Times New Roman','fontweight','bold','ForegroundColor',[0.2 0.2 0.2],'BackgroundColor',[0.95 0.95 0.95]);

        %Auswahl Ansicht 4er oder alle
        uicontrol('Parent',leftPanel,'Units','pixels','Position',[8 60 110 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','String','View','Enable','off','tag','VIEWtext');
        radiogroupview = uibuttongroup('Parent',leftPanel,'Visible','on','Units','Pixels','Position',[8 5 210 40],'BackgroundColor',[0.8 0.8 0.8],'BorderType','none','SelectionChangeFcn',@viewhandler);
        uicontrol('Parent',radiogroupview,'Units','pixels','Position',[1 32 210 20],'Style','radio','HorizontalAlignment','left','Tag','radio_allinone','Enable','off','String','All electrodes for 1 sec.','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows 1 sec of all 60 Electrodes at the same time');
        uicontrol('Parent',radiogroupview,'Units','pixels','Position',[1 12 210 20],'Style','radio','HorizontalAlignment','left','Tag','radio_fouralltime','Enable','off','String','4 electrodes for the recorded time','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows 4 Electrodes for the full recorded time.');

        % Auswahlfeld für die Y-Skalierung
        uicontrol('Parent',leftPanel,'units','pixels','position',[250 60 100 20],'style','text','FontWeight','bold','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'Enable','off','Tag','CELL_scaleBoxLabel','String','y-Axis Scale');
        scalehandle = uicontrol('Parent',leftPanel,'Units','pixels','Position',[250 30 100 25],'Tag','CELL_scaleBox','String',['50 uV  ';'100 uV ';'200 uV ';'500 uV ';'1000 uV'],'Enable','off','Tooltipstring','y-Skalierung','Value',2,'Style','popupmenu','callback',@redrawdecide);


        % Tabpanel (oben rechts)
        tabgroup = uitabgroup('Parent',mainWindow,'Units','pixels','Position',[380 560 842 140],'BackgroundColor',[0.8 0.8 0.8]); drawnow;
        tab1 = uitab(tabgroup,'Title','Data');
        tab2 = uitab(tabgroup,'Title','Preprocessing','Visible','off');
        tab3 = uitab(tabgroup,'Title','Threshold');
        tab4 = uitab(tabgroup,'Title','Analysis');
        tab5 = uitab(tabgroup,'Title','Postprocessing');
        tab6 = uitab(tabgroup,'Title','Spike Sorting');
        tab7 = uitab(tabgroup,'Title','Export');
        tab8 = uitab(tabgroup,'Title','Fileinfo');
        tab9 = uitab(tabgroup, 'Title','About');
        
        t1 = uipanel('Parent',tab1,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t2 = uipanel('Parent',tab2,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t3 = uipanel('Parent',tab3,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t4 = uipanel('Parent',tab4,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t5 = uipanel('Parent',tab5,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t6 = uipanel('Parent',tab6,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t7 = uipanel('Parent',tab7,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t8 = uipanel('Parent',tab8,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);
        t9 = uipanel('Parent',tab9,'Units','pixels','Position',[0 0 839 120],'BackgroundColor', [0.8 0.8 0.8]);


        % Tab 1 (Data):
        % "Import Data File..." - Button
        uicontrol('Parent',t1,'Units','pixels','Position',[8 66 180 24],'Tag','CELL_openFileButton','String','Import Data File...','FontSize',9,'TooltipString','Load a recorded .dat or .txt raw-file or a spiketrain-file.','Callback',@openFileButtonCallback);

        % Import McRack-Datei
        uicontrol('Parent',t1,'Units','pixels','Position',[8 37 180 24],'Tag','CELL_openMcRackButton','String','Import McRack file...','FontSize',9,'TooltipString','Load a recorded McRack file(.txt)','Callback',@openMcRackButtonCallback);

        % "Import xls Files zur Netzwerkbursanalyse..." - Button
        uicontrol('Parent',t1,'Units','pixels','Position',[200 66 180 24],'Tag','CELL_BurstanalysexlsButton','String','Analyse Network-Bursts (xls)...','FontSize',9,'TooltipString','Load one or more .xls-files to analyse the network bursts.','Callback',@AnalyseNetworkburstxls);



        % Tab 2 (Preprocessing):
        uicontrol('Parent',t2,'Units','pixels','Position',[8 85 180 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Filter');
        % "50Hz-Filter" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[8 65 120 24],'Style','checkbox','Tag','CELL_highpassFilterCheckbox','String','50Hz Filter','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Tchebychew-HP (3.degree) @ 58Hz, max. attenuation  @ 50Hz.');

        % "Lowpass-Filter" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[8 45 120 24],'Style','checkbox','Tag','CELL_lowpassFilterCheckbox','String','LP Filter','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Butterworth-lowpass (5.degree) @ 500Hz, attenuation of highfrequency noise.');

        % "Zero Out" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[8 25 120 24],'Style','checkbox','Tag','CELL_ZeroOutCheckbox','String','clear artefakts','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','apply Zero Out-algorithm, to get rid of stimulation artefakts.', 'CallBack',@onofffkt);

        %Zero Out Elektrode und Nachschwingzeit
        uicontrol('Parent',t2,'Units','pixels','Position',[130 86 100 20],'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','FontWeight','bold','String','Zero Out','Tag','headlines','enable','off');
        uicontrol('Parent',t2,'Units','pixels','Position',[130 64 100 20],'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Threshold [uV]','TooltipString','Threshold to detect stimulation.','Tag','threshstim','enable','off');
        uicontrol('Parent',t2,'Units','pixels','Position',[220 66 50 20],'style','edit','HorizontalAlignment','left','FontSize',9,'units','pixels','String',700,'Tag','th_stim','enable','off');
        uicontrol('Parent',t2,'Units','Pixels','position',[130 39 90 20],'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'String','Electrode','Tag','Elekstimname','enable','off');
        uicontrol('Parent',t2,'Units','Pixels','Position',[220 38 100 25],'Tag','CELL_selectelectrode','FontSize',8,'enable','on','String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Tooltipstring','Elektrodenauswahl','Style','popupmenu','enable','off');
        uicontrol('Parent',t2,'Units','pixels','Position',[130 16 100 20],'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','clear until','TooltipString','clear signal from beginning to end of stimulation + this time.','Tag','text_aftertime','enable','off');
        uicontrol('Parent',t2,'Units','pixels','Position',[220 18 55 20],'style','edit','HorizontalAlignment','left','FontSize',9,'units','pixels','String','0.005','Tag','aftertime','enable','off');
        uicontrol('Parent',t2,'Units','pixels','Position',[206 16 10 20],'style','text','HorizontalAlignment','right','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','+','TooltipString','clear signal from beginning to end of stimulation + this time.','Tag','textplus','enable','off');
        uicontrol('Parent',t2,'Units','pixels','Position',[275 16 20 20],'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','s','TooltipString','clear signal from beginning to end of stimulation + this time.','Tag','textsek','enable','off');

        % "Ausnullen" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[360 66 110 24],'Tag','CELL_ElnullenButton','String','Clear Els.','FontSize',10,'Enable','off','TooltipString','clears electrodes.','Callback',@ELnullenCallback);

        % "Invert Signals" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[360 37 110 24],'Tag','CELL_invertButton','String','Invert Signal','FontSize',10,'Enable','off','TooltipString','invert single electrodes.','Callback',@invertButtonCallback);

        % "Restore Data" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[475 37 110 24],'Tag','CELL_restoreButton','String','Restore Data','FontSize',10,'Enable','off','TooltipString','undo all filters and restore original data.','Callback',@unfilterButtonCallback);

        % "Apply" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[475 8 110 24],'Tag','CELL_applyButton','String','Apply...','FontSize',10,'Enable','off','TooltipString','Automated Spike/Burst-Analysis.','fontweight','bold','Callback',@Applyfilter);

        % "empty" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[475 66 110 24],'Tag','CELL_preprocessingempty1Button','String','empty','FontSize',10,'Enable','off','TooltipString','empty.','Callback',@preprocessingempty1Callback);

        % "Smoothing" - Button
        uicontrol('Parent',t2,'Units','pixels','Position',[360 8 110 24],'Tag','CELL_smoothButton','String','Smooth Signal','FontSize',10,'Enable','off','TooltipString','smooth single electrodes.','Callback',@smoothButtonCallback);

        
        %Tab3 (Threshold)
        
        % Thresholds-Levelauswahl
        uicontrol('Parent',t3,'Units','pixels','Position',[8 85 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Threshold Calculation standard');
        uicontrol('Parent',t3,'Units','pixels','Position',[80 60 100 20],'Tag','CELL_sensitivityBox','HorizontalAlignment','left','String',['14 * RMS (max)';'11 * RMS      ';'9 * RMS       ';'7 * RMS       ';'6 * RMS       ';'5 * RMS       ';'4 * RMS       ';'3 * RMS (min) '],'Enable','off','Tooltipstring','Lage des negativen Schwellwertes als vielfaches des quadratischen Mittels der Elektrodenspannung.','Value',5,'Style','popupmenu');

        % Thresholds Auto oder Manuell
        radiogroup2 = uibuttongroup('Parent',t3,'visible','on','Units','Pixels','Position',[8 35 150 40],'BackgroundColor',[0.8 0.8 0.8],'BorderType','none','SelectionChangeFcn',@handler2);
        uicontrol('Parent',radiogroup2,'Units','pixels','Position',[1 30 65 20],'Style','radio','HorizontalAlignment','left','Tag','thresh_auto','String','Auto','Enable','off','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','find threshold in thermal noise');
        uicontrol('Parent',radiogroup2,'Units','pixels','Position',[1 12 65 20],'Style','radio','HorizontalAlignment','left','Tag','thresh_manu','String','Manual:','Enable','off','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','find threshold in given interval');

        radiogroup3 = uibuttongroup('Parent',t3,'visible','on','Units','Pixels','Position',[8 35 150 40],'BackgroundColor',[0.8 0.8 0.8],'BorderType','none','SelectionChangeFcn',@handler3);
        uicontrol('Parent',radiogroup3,'Units','pixels','Position',[1 -12 65 20],'Style','radio','HorizontalAlignment','left','Tag','thresh_rms','String','rms','Enable','off','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','find threshold in thermal noise');
        uicontrol('Parent',radiogroup3,'Units','pixels','Position',[1 -30 65 20],'Style','radio','HorizontalAlignment','left','Tag','thresh_sigma','String','sigma','Enable','off','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','find threshold in given interval');

        uicontrol('Parent',t3,'Units','pixels','Position',[80 33 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','time_start','String','-','enable','off');
        uicontrol('Parent',t3,'Units','pixels','Position',[122 31 10 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','-','Tag','text_2','enable','off');
        uicontrol('Parent',t3,'Units','pixels','Position',[130 33 40 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','time_end','String','-','enable','off');
        uicontrol('Parent',t3,'Units','pixels','Position',[170 31 15 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','s','Tag','text_3','enable','off');

        % "Calculate" - Button
        uicontrol('Parent',t3,'Units','pixels','Position',[80 5 100 24],'Tag','CELL_calculateButton','String','Calculate...','FontSize',11,'Enable','off','TooltipString','Threshold. ','fontweight','bold','Callback',@CalculateThreshold);

        %Thresholds per Hand manipulieren
        uicontrol('Parent',t3,'Units','pixels','Position',[500 85 180 20],'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Enter Threshold');
        uicontrol('Parent',t3,'Units','pixels','Position',[500 58 60 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Electrode');
        uicontrol('Parent',t3,'Units','pixels','Position',[620 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','Elsel_Thresh');
        uicontrol('Parent',t3,'Units','pixels','Position',[500 31 150 22],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Current Threshold');
        uicontrol('Parent',t3,'Units','pixels','Position',[620 33 120 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','CELL_ShowcurrentThresh');

        % "Show" - Button
        uicontrol('Parent',t3,'Units','pixels','Position',[760 60 60 24],'Tag','CELL_safeButton','String','Show...','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@ElgetThresholdfunction);

        % "Safe" - Button
        uicontrol('Parent',t3,'Units','pixels','Position',[760 35 60 24],'Tag','CELL_safeButton','String','Save...','FontSize',10,'Enable','off','TooltipString','Safe Threshold. ','fontweight','bold','Callback',@ELsaveThresholdfunction);

        % Variabler Threshold
        uicontrol('Parent',t3,'Units','pixels','Position',[250 85 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','Enable','off','FontWeight','bold','String','Threshold Calculation variable');
        uicontrol('Parent',t3,'Units','pixels','Position',[250 62 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','Enable','off','String','offset multiplier');
        uicontrol('Parent',t3,'Units','pixels','Position',[350 64 100 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','Tag','varTmultiplier');
        uicontrol('Parent',t3,'Units','pixels','Position',[250 42 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','Enable','off','String','smooth');
        uicontrol('Parent',t3,'Units','pixels','Position',[250 27 220 20],'Tag','CELL_sensitivityBoxtext','style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','Enable','off','String','span / degree');
        uicontrol('Parent',t3,'Units','pixels','Position',[350 36 45 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String',91,'Tag','varTspan');
        uicontrol('Parent',t3,'Units','pixels','Position',[405 36 45 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String',1,'Tag','varTdegree');
        uicontrol('Parent',t3,'Units','pixels','Position',[350 5 100 24],'Tag','CELL_calculateButton','String','varCalculate...','FontSize',11,'Enable','off','TooltipString','Threshold. ','fontweight','bold','Callback',@CalculatevarThreshold);

         

        % Tab 4 (Analysis):

        % Voreinstellung Drop Down
        uicontrol('Parent',t4,'Units','pixels','Position',[8 85 130 20],'style','text','HorizontalAlignment','left','FontWeight','bold','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','String','Default Settings','Enable','off');
        defaulthandle = uicontrol('Parent',t4,'Units','pixels','Position',[8 66 130 20],'Tag','CELL_DefaultBox','String',['Neuron [Tam]      ';'Neuron [Baker]    ';'Neuron [Wagenaar4]';'Neuron [Wagenaar3]';'Cardiac 200ms     ';'Cardiac 100ms     '],'Enable','off','Tooltipstring','Default settings for Spike and Burstdetection','Value',1,'Style','popupmenu','callback',@handler);

        %Help - Info über Burstdefinitionen
        uicontrol('Parent',t4,'Units','pixels','Position',[8 37 100 20],'Tag','CELL_HelpBurst','String','Help?...','FontSize',10,'Enable','off','TooltipString','Explanations for different Burstdefinitions.','fontweight','bold','Callback',@HelpBurstFunction);

        %SBE Analyse aktivieren
        uicontrol('Parent',t4,'Units','pixels','Position',[8 14 100 20],'Style','checkbox','Tag','Burst_Box','String','Burst Analysis','FontSize',9,'Value',1,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','En/Disables SBE Analysis');
        

        % Spike/Burst-Kriterien
        uicontrol('Parent',t4,'Units','pixels','Position',[160 85 180 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','FontWeight','bold','String','Spike & Burst Criteria');

        uicontrol('Parent',t4,'Units','pixels','Position',[160 58 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Spike Idle Time [ms]','TooltipString','time, where no other spike is detected after having detected one before.');
        uicontrol('Parent',t4,'Units','pixels','Position',[290 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','1','Tag','t_spike');
        uicontrol('Parent',t4,'Units','pixels','Position',[160 36 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Min. Spikes per Burst');
        uicontrol('Parent',t4,'Units','pixels','Position',[290 38 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','3','Tag','spike_no');
        uicontrol('Parent',t4,'Units','pixels','Position',[160 14 120 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Burst Idle Time [ms]');
        uicontrol('Parent',t4,'Units','pixels','Position',[290 16 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','500','Tag','t_dead');
        uicontrol('Parent',t4,'Units','pixels','Position',[340 58 145 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Max. Time 2 first SiBs [ms]');
        uicontrol('Parent',t4,'Units','pixels','Position',[500 60 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','10','Tag','t_12');
        uicontrol('Parent',t4,'Units','pixels','Position',[340 36 145 20],'style','text','HorizontalAlignment','left','Enable','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'units','pixels','String','Max. Time other SiBs [ms]');
        uicontrol('Parent',t4,'Units','pixels','Position',[500 38 30 20],'style','edit','HorizontalAlignment','left','Enable','off','FontSize',9,'units','pixels','String','20','Tag','t_nn');

        % "Analyse" - Button
        uicontrol('Parent',t4,'Units','pixels','Position',[550 7 105 25],'Tag','CELL_analyzeButton','String','Analyze...','FontSize',11,'Enable','off','TooltipString','Automated Spike/Burst-Analysis.','fontweight','bold','Callback',@Analysedecide);



        % Tab 5 (Postprocessing):

        %"Checkboxen für die Anzeige der Spike/Burst/Stimuli/Threshold-Markierungen"
        uicontrol('Parent',t5,'style','text','position',[10 85 40 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Enable','off','Tag','CELL_showMarksCheckbox','units','pixels','String','Show...');
        uicontrol('Parent',t5,'Units','pixels','Position',[10 65 100 27],'Style','checkbox','Tag','CELL_showThresholdsCheckbox','String','Thresholds','FontSize',9,'Value',1,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the used tresholds.','Callback',@redrawdecide);
        uicontrol('Parent',t5,'Units','pixels','Position',[10 45 100 27],'Style','checkbox','Tag','CELL_showSpikesCheckbox','String','Spikes (green)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the detected spikes.','Callback',@redrawdecide);
        uicontrol('Parent',t5,'Units','pixels','Position',[10 25 100 27],'Style','checkbox','Tag','CELL_showBurstsCheckbox','String','Bursts (yellow)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the detected bursts.','Callback',@redrawdecide);
        uicontrol('Parent',t5,'Units','pixels','Position',[10 5 100 27],'Style','checkbox','Tag','CELL_showStimuliCheckbox','String','Stimuli (red)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the detected stimuli.','Callback',@redrawdecide);

        % "Rasterplot" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[130 66 110 24],'String','Raster Plot','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Spike Sorting Function.','Callback',@rasterplotButtonCallback);

        %"Spiketrain" - Button    %ANDY
        uicontrol('Parent',t5,'Units','pixels','Position',[130 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Spike Train','FontSize',9,'Enable','off','TooltipString','Spike train for individual electrodes.','Callback',@spiketrainButtonCallback);  %ANDY

        % "Networkburst" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[130 8 110 24],'Tag','CELL_Networkbursts','String','Networkbursts','FontSize',9,'Enable','off','TooltipString','Analyse network bursts','Callback',@AnalyseNetworkburst);


        % "Timing Analysis" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[245 66 110 24],'String','Eventtracing','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Timing Function.','Callback',@timingButtonCallback);

        % "Frequenzanalyse" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[245 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Beating Rate','FontSize',9,'Enable','off','TooltipString','Analyse HMZ.','Callback',@frequenzanalyseButtonCallback);

        % "Zero-Out Example" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[245 8 110 24],'Tag','CELL_ShowZeroOutExample','String','Example ZeroOut','FontSize',9,'Enable','off','TooltipString','Shows an Example of ZeroOut algorithm','Callback',@ZeroOutExampleButtonCallback);


        % "Spike " - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[360 66 110 24],'String','Spike Sorting','Tag','SpikeSorting','FontSize',9,'Enable','off','TooltipString','Spike Sorting Function.','Callback',@sortingButtonCallback);

        % "Autocorrelation" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[360 37 110 24],'String','Autocorrelation','Tag','CELL_Autocorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@correlationButtonCallback);

        % "Crosscorrelation" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[360 8 110 24],'String','Crosscorrelation','Tag','CELL_Crosscorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@crosscorrelationButtonCallback);

        % "Spike Analyse" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[475 37 110 24],'String','Spike Analyse','Tag','CELL_Spike Analyse','FontSize',9,'Enable','off','TooltipString','Spike Analyse','Callback',@Spike_Analyse);

        % "Detektion Refinement" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[475 8 110 24],'String','Detection Refinement','Tag','CELL_Detektion Refinement','FontSize',8,'Enable','off','TooltipString','Detektion Refinement','Callback',@Detektion_Refinement);

        %%%%%LEERE BOTTONS%%%%%
        % "Spike Overlay " - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[475 66 110 24],'String','SpikeOverlay','Tag','CELL_SpkOverlay','FontSize',9,'Enable','off','TooltipString','Spike-Overlay & QT-Intervallbestimmung','Callback',@SpkOverlay);

        % "BURST/SBE Analysis " - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[590 66 110 24],'String','Burst/SBE','Tag','Burst_SBE','FontSize',9,'Enable','off','TooltipString','Burst and SBE Analysis','Callback',@Re_Burst);

        % "??" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[590 37 110 24],'String','???','Tag','CELL_test2','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@unknwonButtonCallback);

        % "??" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[590 8 110 24],'String','???','Tag','CELL_test3','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@unknwonButtonCallback);

        % "?? " - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[705 66 110 24],'String','???','Tag','CELL_test1','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@unknwonCallback);

        % "??" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[705 37 110 24],'String','???','Tag','CELL_test2','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@unknwonButtonCallback);

        % "??" - Button
        uicontrol('Parent',t5,'Units','pixels','Position',[705 8 110 24],'String','???','Tag','CELL_test3','FontSize',9,'Enable','off','TooltipString','unknown Function.','Callback',@unknwonButtonCallback);

        % Tab 6 (Spike Sorting):

        %"Checkboxen für die Anzeige der Spike/Burst/Stimuli/Threshold-Markierungen"
        uicontrol('Parent',t6,'style','text','position',[10 85 40 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Enable','off','Tag','CELL_showMarksCheckbox','units','pixels','String','Show...');
        uicontrol('Parent',t6,'Units','pixels','Position',[10 65 100 27],'Style','checkbox','Tag','CELL_showThresholdsCheckbox','String','Thresholds','FontSize',9,'Value',1,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the used tresholds.','Callback',@redrawdecide);
        uicontrol('Parent',t6,'Units','pixels','Position',[10 45 100 27],'Style','checkbox','Tag','CELL_showSpikesCheckbox','String','Spikes (green)','FontSize',9,'Value',1,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the detected spikes.','Callback',@redrawdecide);
        uicontrol('Parent',t6,'Units','pixels','Position',[10 25 100 27],'Style','checkbox','Tag','CELL_showBurstsCheckbox','String','Bursts (yellow)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the detected bursts.','Callback',@redrawdecide);
        uicontrol('Parent',t6,'Units','pixels','Position',[10 5 100 27],'Style','checkbox','Tag','CELL_showStimuliCheckbox','String','Stimuli (red)','FontSize',9,'Value',0,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Shows the detected stimuli.','Callback',@redrawdecide);

        %"Rasterplot" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[130 66 110 24],'String','Raster Plot','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Spike Sorting Function.','Callback',@rasterplotButtonCallback);

        %"Spiketrain" - Button    %ANDY
        uicontrol('Parent',t6,'Units','pixels','Position',[130 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Spike Train','FontSize',9,'Enable','off','TooltipString','Spike train for individual electrodes.','Callback',@spiketrainButtonCallback);  %ANDY

        % "Networkburst" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[130 8 110 24],'Tag','CELL_Networkbursts','String','Networkbursts','FontSize',9,'Enable','off','TooltipString','Analyse network bursts','Callback',@AnalyseNetworkburst);

        % "Timing Analysis" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[245 66 110 24],'String','Eventtracing','Tag','t4_buttons','FontSize',9,'Enable','off','TooltipString','Timing Function.','Callback',@timingButtonCallback);

        % "Frequenzanalyse" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[245 37 110 24],'Tag','CELL_frequenzanalyseButton','String','Beating Rate','FontSize',9,'Enable','off','TooltipString','Analyse HMZ.','Callback',@frequenzanalyseButtonCallback);

        % "Zero-Out Example" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[245 8 110 24],'Tag','CELL_ShowZeroOutExample','String','Example ZeroOut','FontSize',9,'Enable','off','TooltipString','Shows an Example of ZeroOut algorithm','Callback',@ZeroOutExampleButtonCallback);
        
        % "Spike Overlay " - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[360 66 110 24],'String','SpikeOverlay','Tag','CELL_SpkOverlay','FontSize',9,'Enable','off','TooltipString','Spike-Overlay & QT-Intervallbestimmung','Callback',@SpkOverlay);

        % "Autocorrelation" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[360 37 110 24],'String','Autocorrelation','Tag','CELL_Autocorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@correlationButtonCallback);

        % "Crosscorrelation" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[360 8 110 24],'String','Crosscorrelation','Tag','CELL_Crosscorrelation','FontSize',9,'Enable','off','TooltipString','Autocorrelation Function.','Callback',@crosscorrelationButtonCallback);
        
        %Apply Expectation Maximation Algorithm
        uicontrol('Parent',t6,'Units','Pixels','Position',[475 70 170 20],'FontSize',9,'Tag','S_EM_GM','String','Expectation Maximation','Enable','off','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        
        %Apply EM k-means Algorithm
        uicontrol('Parent',t6,'Units','Pixels','Position',[475 50 170 20],'FontSize',9,'Tag','S_EM_k-means','String','EM k-means','Enable','off','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        
        %Wavelets on/off
        uicontrol('Parent',t6,'Units','Pixels','Position',[475 30 170 20],'FontSize',9,'Tag','S_Wavelet','String','Wavelet Packet Analysis','Enable','off','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
       
        %FPCA Features
        uicontrol('Parent',t6,'Units','Pixels','Position',[475 10 170 20],'FontSize',9,'Tag','S_FPCA','String','FPCA Features','Enable','off','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);

        %Electrode Selection
        uicontrol('Parent',t6,'Style', 'text','Position',[630 40 100 21],'HorizontalAlignment','left','String','Electrode: ','Enable','off','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 12 50 51],'Tag','S_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Enable','off','Value',1,'Style','popupmenu','callback',@recalculate);

        % Shapes Window Dimension
        uicontrol('Parent',t6,'Style', 'text','Position', [630 72 80 20],'HorizontalAlignment','left','String', 'Window: ','FontSize',10,'Enable','off','FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 65 50 30],'Tag','S_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);
        uicontrol('Parent',t6,'Units','Pixels','Position',[760 65 50 30],'Tag','S_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);

        % Class Nr.
        uicontrol('Parent',t6,'Style', 'text','Position', [630 8 100 21],'HorizontalAlignment','left','String','Cluster Nr.:','Enable','off','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',t6,'Units','Pixels','Position', [710 10 40 21],'Tag','S_K_Nr','HorizontalAlignment','right','FontSize',8,'Enable','off','Value',1,'String',0,'Style','edit');
        
        
        % "Analyse" - Button
        uicontrol('Parent',t6,'Units','pixels','Position',[760 8 70 24],'Tag','Spike_Sorting','String','Analyse','FontSize',11,'fontweight','bold','Enable','off','TooltipString','Starts Spike Sorting','Callback',@Spike_Sorting);
        
        % Tab 7 (Export):

        % "Export Summary" - Feld mit Checkboxen für die Optionen
        uicontrol('Parent',t7,'Units','pixels','Position',[8 66 180 24],'Tag','CELL_exportButton','String','Export Summary to .xls','FontSize',9,'Enable','off','TooltipString','Speichert eine Auswertedatei als .xls','Callback',@safexlsButtonCallback);
        uicontrol('Parent',t7,'Units','pixels','Position',[15 28 120 27],'Style','checkbox','Tag','CELL_exportAllCheckbox','String','with Timestamps','FontSize',9,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Write timestamps to file?');
        uicontrol('Parent',t7,'Units','pixels','Position',[15 8 120 27],'Style','checkbox','Tag','CELL_showExportCheckbox','String','open File now','FontSize',9,'Enable','off','BackgroundColor', [0.8 0.8 0.8],'TooltipString','Should the file be opened after exporting?');

        % "Export Networkburst" - Feld mit Checkboxen für die Optionen
        uicontrol('Parent',t7,'Units','pixels','Position',[200 66 180 24],'Tag','CELL_exportNWBButton','String','Export Networkburst to .xls','FontSize',9,'Enable','off','TooltipString','Saves Networkburstanalysis into a .xls-file','Callback',@ExportNWBCallback);


        % Tab 8 (Fileimfo):
        %Filename
        uicontrol('Parent',t8,'Units','pixels','Position',[55 75 250 20],'Tag','CELL_dataFile','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','Data file name.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [5 75 35 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Name:','Enable','off');

        %Kommentar
        uicontrol('Parent',t8,'Units','pixels','Position',[55 50 250 20],'Tag','CELL_fileInfo','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','Data details.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [5 50 40 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Details:','Enable','off');

        %Datum and Time
        uicontrol('Parent',t8,'Units','pixels','Position',[55 25 100 20],'Tag','CELL_dataDate','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','day of recording.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [5 25 40 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Date:','Enable','off');

        uicontrol('Parent',t8,'Units','pixels','Position',[205 25 100 20],'Tag','CELL_dataTime','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','time, when the recording was started.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [165 25 40 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Time:','Enable','off');

        %Samplerate
        uicontrol('Parent',t8,'Units','pixels','Position',[455 75 100 20],'Tag','CELL_dataSaRa','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','Samplerate.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [325 75 100 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','SampleRate [Hz]:','Enable','off');

        %Anzahl der Elektroden
        uicontrol('Parent',t8,'Units','pixels','Position',[455 50 100 20],'Tag','CELL_dataNrEl','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','Number of Electrodes.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [325 50 80 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','#Electrodes:','Enable','off');

        %Dauer der Messung
        uicontrol('Parent',t8,'Units','pixels','Position',[455 25 100 20],'Tag','CELL_dataDur','Style','edit','BackgroundColor',[0.8 0.8 0.8],'TooltipString','measuring time of the recorded data.','Enable','off');
        uicontrol('Parent',t8,'style','text','position', [325 25 120 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Measuring time [s]:','Enable','off');

        
        
        % Tab 9 (About):
        uicontrol('Parent',t9,'style','text','position', [5 75 750 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','This software is property of the biomems lab of the University of Applied Sciences Aschaffenburg, Germany.','Enable','on');
        uicontrol('Parent',t9,'style','text','position', [5 50 750 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','If used for analyzing data to be published, authors would appreciate proper citation of this work.','Enable','on');
        uicontrol('Parent',t9,'style','text','position', [5 25 750 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',9,'units','pixels','String','Contact us: www.h-ab.de\biomems or christiane.thielemann@h-ab.de .','Enable','on');
        
                  
        % Unteres Panel
        bottomPanel = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel','BackgroundColor', [0.8 0.8 0.8]);

        % Scrollbar vertikal bei viereransicht
        uicontrol('Parent',bottomPanel,'style', 'slider','Tag','CELL_slider','units', 'pixels', 'position', [1189 5 20 543],'Enable','off','visible','off','callback',@redrawdecide);

        
        % "Zoom"-Buttons
        dist = 120;
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 480 45 20],'Tag','CELL_zoomGraphButton1','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton1Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 480-dist 45 20],'Tag','CELL_zoomGraphButton2','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton2Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 480-2*dist 45 20],'Tag','CELL_zoomGraphButton3','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton3Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 480-3*dist 45 20],'Tag','CELL_zoomGraphButton4','String','Zoom','Visible','off','TooltipString','zoom into this Graph.','Callback',@zoomButton4Callback);

        % 'Invertieren'-Buttons
        dist = 120;
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 455 45 20],'Tag','CELL_invertButton1','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton1Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 455-dist 45 20],'Tag','CELL_invertButton2','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton2Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 455-2*dist 45 20],'Tag','CELL_invertButton3','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton3Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 455-3*dist 45 20],'Tag','CELL_invertButton4','String','Invert.','Visible','off','TooltipString','invert signal of this electrode.','Callback',@invertButton4Callback);

        % 'Ausnullen'-Buttons
        dist = 120;
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 430 45 20],'Tag','CELL_zeroButton1','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton1Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 430-dist 45 20],'Tag','CELL_zeroButton2','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton2Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 430-2*dist 45 20],'Tag','CELL_zeroButton3','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton3Callback);
        uicontrol('Parent',bottomPanel,'Units','pixels','Position',[80 430-3*dist 45 20],'Tag','CELL_zeroButton4','String','Clear','Visible','off','TooltipString','clear signal of this electrode.','Callback',@clearButton4Callback);


        % Unteres Panel 2
        bottomPanel_zwei = uipanel('Parent',mainWindow,'Units','pixels','Position',[5 5 1214 553],'Tag','CELL_BottomPanel_zwei','BackgroundColor', [0.8 0.8 0.8]);

        % Scrollbar horizontal bei Übersicht
        uicontrol('Parent', bottomPanel_zwei,'style', 'slider','Tag','MEA_slider','units', 'pixels', 'position', [5 5 1204 20],'Enable','off','callback',@redrawdecide);

            
       
            
        
            
    % ---------------------------------------------------------------------
    % --- Funktionen ------------------------------------------------------
    % ---------------------------------------------------------------------
    
    %Funktionen - dauerhaft sichtbar / allgemein
    %----------------------------------------------------------------------
    
    % --- ScaleRedraw-Auswahl (CN)-----------------------------------------
    function redrawdecide(source,event) %#ok
    %Funktion entscheidet je nachdem welche Ansicht gewählt wurde
    %welche Redrawfunktion aufgerufen werden muss.
                if Viewselect == 1;
                    redraw_allinone;
                elseif Viewselect == 0;
                    redraw;
                end 
    end

    % --- View-Auswahl (CN)------------------------------------------------
    function viewhandler(source,event) %#ok<INUSL>       
            t = get(event.NewValue,'Tag');
            switch(t)
            case 'radio_allinone'                                         % Gesamtansicht
                Viewselect = 1;
                %Scrollbar konfigurieren und aktivieren und Graphen neuzeichnen
                set(findobj(gcf,'Tag','CELL_slider'),'Enable','off')
                set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...       
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[0.25/rec_dur 1/rec_dur]);
                set(findobj(gcf,'Parent',bottomPanel,'Visible','on'),'Visible','off');
                redraw_allinone;
            case 'radio_fouralltime'                                          % Detailansicht
                Viewselect = 0;
                %Scrollbar konfigurieren und aktivieren und Graphen neuzeichnen
                 set(findobj(gcf,'Tag','MEA_slider'),'Enable','off')
                 if nr_channel > 4
                    set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', size(M,2)-4, 'Value', size(M,2)-4,...
                    'SliderStep', [1/(size(M,2)-4) 4/(size(M,2)-4)]);
                 end
                 set(findobj(gcf,'Parent',bottomPanel,'Visible','off'),'Visible','on');
                 redraw; 
            end    
    end

    % --- Neuzeichnen der Graphen in Vierer-Ansicht (GH)-------------------
    function redraw(~,~)      
        set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','off');
        set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','on');
        set(0,'CurrentFigure',mainWindow) % changes current figure so that gcf and sliderpos works
        slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));   % Position der Scrollbar
        graph_no = size(M,2)-slider_pos-3;                                  % Index des obersten Graphen

        if first_open4 == 0 && drawnbefore4 == 1    %beim ersten Zeichnen, wenn bereits eine Datei geöffnet ist
            if nr_channel_old>=4
            delete(SubMEA_vier);
            elseif nr_channel_old==3
            delete(SubMEA_vier(1:3))    
            elseif nr_channel_old==2
            delete(SubMEA_vier(1:2))
            end
            delete(findobj(gcf,'Tag','ShowElNames'));                   
        end
       
        %Versteckt gegebenfalls die 
        if nr_channel >= 4
               set(findobj(gcf,'Tag','CELL_slider'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        elseif nr_channel==3
               set(findobj(gcf,'Tag','CELL_slider'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        elseif nr_channel==2
               set(findobj(gcf,'Tag','CELL_slider'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');     
        elseif nr_channel==1
               set(findobj(gcf,'Tag','CELL_slider'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_invertButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zeroButton4'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton3'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_invertButton3'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zeroButton3'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton2'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_invertButton2'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zeroButton2'),'Visible','off');
               set(findobj(gcf,'Tag','CELL_zoomGraphButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_invertButton1'),'Visible','on');
               set(findobj(gcf,'Tag','CELL_zeroButton1'),'Visible','on');
        end
                 
        scale = get(scalehandle,'value');   % Y-Skalierung festlegen                                
        switch scale
            case 1, scale = 50;
            case 2, scale = 100;
            case 3, scale = 200;
            case 4, scale = 500;
            case 5, scale = 1000;
        end
        
        if max(SubmitSorting) >= 1
           delete(findobj(0,'Tag','ShowSpikesBurstsperCell')); % refresh display
        end

        if nr_channel>4    

            for n=0:3
                % Namen der 4 angezeigten Elektroden anzeigen
                uicontrol('style', 'text',...                       
                    'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-n*120 50 25],...
                    'Parent', bottomPanel, 'Tag', 'ShowElNames','String', EL_NAMES(graph_no+n));
                SubMEA_vier(n+1)=subplot(4,1,n+1,'Parent',bottomPanel);
                
                plot(T,M(:,graph_no+n));
                axis([0 T(size(T,2)) -1*scale scale]); grid on;                     % 4 Graphen zeichnen (Als Subplot 2 bis 5)
                hold on;                
                    if varTdata==1
                        plot (T,varT(:,graph_no+n),...
                         'LineStyle','--','Color','red');                            % variablen Threshold zeichnen (AD)
                    end
                hold off;
                
                if thresholddata
                    if varTdata==0;                                                     %variabler threshold?                                             
                        if  get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','parent',t6),'value');   % Thresholds % Änderung (RB) damit in beiden Tabs der Threshold Button funktioniert
                            line ('Xdata',[0 T(length(T))],...                              % (gestrichelte Linie)
                                'Ydata',[THRESHOLDS(graph_no+n) THRESHOLDS(graph_no+n)],...
                                'LineStyle','--','Color','red');
                        end
                    end
                end
                    
                if spikedata==1
                  
                  if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes

                    if max(SubmitSorting) > 0
                           set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','off');
                           colormap('Lines');
                           cmap = colormap;

                           if SubmitSorting(graph_no+n) >= 1

                               for i = 1:max(SPIKES_Class(:,graph_no+n,2))                         % (farbige Dreiecke bei mehreren Zellen)
                                   SP = nonzeros(SPIKES_Class((SPIKES_Class(:,graph_no+n,2)==i),graph_no+n,1));
                                   y_axis = ones(length(SP),1).*scale.*.9;
                                   line ('Xdata',SP,'Ydata', y_axis,...
                                         'LineStyle','none','Marker','v',...
                                         'MarkerFaceColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'MarkerSize',6);

                                   SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(i,graph_no+n)),' / ',num2str(NR_BURSTS_Sorted(i,graph_no+n))];

                                   %Anzahl der Spikes und Bursts anzeigen 
                                   uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-(n*120)-((i-1)*20)) 80 20],...
                                             'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'String',SpikeString);
                               end
                           else
                              SP = nonzeros(SPIKES(:,graph_no+n)); 
                              y_axis = ones(length(SP),1).*scale.*.9;
                              line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'MarkerSize',6);

                               SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(1,graph_no+n)),' / ',num2str(NR_BURSTS_Sorted(1,graph_no+n))];

                               %Anzahl der Spikes und Bursts anzeigen 
                                uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-(n*120)) 80 20],...
                                          'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'String',SpikeString);
                           end
                           set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','on'); % after changes set visibility on again
                       
                    else
                       set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','off'); 
                       set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','on');
                       
                       %Schriftzug für Anzeige #Spikes und #Bursts für jede El.
                       uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1105 462-n*120 39 20],...
                       'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Spikes','Visible','off');
                       uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1105 432-n*120 39 20],...
                       'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Bursts','Visible','off');

                       %Anzahl der Spikes anzeigen
                       uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-n*120 30 20],...
                       'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(graph_no+n));
                       %Anzahl der Bursts anzeigen
                       uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-n*120 30 20],...
                       'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', NR_BURSTS(graph_no+n));


                       if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','parent',t6),'value'); % Spikes % Änderung (RB) damit in beiden Tabs der Spikes Button funktioniert
                          SP = nonzeros(SPIKES(:,graph_no+n));                            % (grüne Dreiecke)
                          if isempty(SP)==0
                             y_axis = ones(length(SP),1).*scale.*.9;
                             line ('Xdata',SP,'Ydata', y_axis,...
                                   'LineStyle','none','Marker','v',...
                                   'MarkerFaceColor','green','MarkerSize',9);
                          end
                       end
                    end
                    if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1;       % Bursts % Änderung (RB) damit in beiden Tabs der Burst Button funktioniert
                       SP = nonzeros(BURSTS(:,graph_no+n));                            % (gelbe Dreiecke)
                       if isempty(SP)==0
                          y_axis = ones(length(SP),1).*scale.*.9;
                          line ('Xdata',SP,'Ydata', y_axis,...
                                'LineStyle','none','Marker','v',...
                                'MarkerFaceColor','yellow','MarkerSize',9);
                       end
                     end
                  end
                end
                if stimulidata==1
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','parent',t6),'value');  % Stimuli % Änderung (RB) damit in beiden Tabs der Stimuli Button funktioniert
                       for k=1:length(BEGEND)                                       % (Rote Linien)
                        line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                        'Color','red', 'LineWidth', 1);
                       end 
                    end
                end        
            end
            
        else %Falls weniger als 4 Elektroden aufgenommen wurden
            for n=1:(nr_channel) 
                %Schriftzug für Anzeige #Spikes und #Bursts für jede El.
                uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1105 462-(n-1)*120 39 20],...
                'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Spikes','Visible','off');
                uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1105 432-(n-1)*120 39 20],...
                'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', '#Bursts','Visible','off');
                
                % Namen der 4 angezeigten Elektroden anzeigen
                uicontrol('style', 'text',...                       
                'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-(n-1)*120 50 25],...
                'Parent', bottomPanel,'Tag', 'ShowElNames','String', EL_NAMES(n));

                SubMEA_vier(n)=subplot(4,1,n,'Parent',bottomPanel);
                plot(T,M(:,n));                                             % 4 Graphen zeichnen (Als Subplot 2 bis 5)
                axis([0 T(size(T,2)) -1*scale scale]); grid on;
                
                    hold on;                
                    if varTdata==1
                        plot (T,varT(:,n),...
                         'LineStyle','--','Color','red');                   % variablen Threshold zeichnen (AD)
                    end
                    hold off;
                    
                  if thresholddata
                     if varTdata==0;                                                     %variabler threshold?                                             
                      if get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','parent',t6),'value');   % Thresholds % Änderung (RB) damit in beiden Tabs der Threshold Button funktioniert
                        line ('Xdata',[0 T(length(T))],...                              % (gestrichelte Linie)
                            'Ydata',[THRESHOLDS(n) THRESHOLDS(n)],...
                            'LineStyle','--','Color','red');
                       end
                     end
                  end 

                 if spikedata==1
                    
                     if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes

                        if max(SubmitSorting) > 0
                           set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','off');
                           colormap('Lines');
                           cmap = colormap;

                           if SubmitSorting(n) >= 1

                               for i = 1:max(SPIKES_Class(:,n,2))                         % (farbige Dreiecke bei mehreren Zellen)
                                   SP = nonzeros(SPIKES_Class((SPIKES_Class(:,n,2)==i),n,1));
                                   y_axis = ones(length(SP),1).*scale.*.9;
                                   line ('Xdata',SP,'Ydata', y_axis,...
                                         'LineStyle','none','Marker','v',...
                                         'MarkerFaceColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'MarkerSize',6);

                                   SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(i,n)),' / ',num2str(NR_BURSTS_Sorted(i,n))];

                                   %Anzahl der Spikes und Bursts anzeigen 
                                   uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-((n-1)*120)-((i-1)*20)) 180 20],...
                                            'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(i,1),cmap(i,2),cmap(i,3)],'String',SpikeString);
                               end
                           else
                              SP = nonzeros(SPIKES(:,n)); 
                              y_axis = ones(length(SP),1).*scale.*.9;
                              line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'MarkerSize',6);

                               SpikeString = ['S/B: ', num2str(NR_SPIKES_Sorted(1,n)),' / ',num2str(NR_BURSTS_Sorted(1,n))];

                               %Anzahl der Spikes und Bursts anzeigen 
                               uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1102 (490-(n-1)*120) 80 20],...
                                          'Parent',bottomPanel, 'Tag','ShowSpikesBurstsperCell','ForegroundColor',[cmap(1,1),cmap(1,2),cmap(1,3)],'String',SpikeString);
                           end
                           set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','on'); % after changes set visibility on again
                        else
                           SP = nonzeros(SPIKES(:,n)); 
                           set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','off'); 
                           set(findobj('Tag','ShowSpikesBurstsperEL','Parent',bottomPanel),'Visible','on'); 
                           %Anzahl der Spikes anzeigen (Änderungen Andy, OK?)
                           uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-((n-1)*120) 30 20],...
                                     'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String',NR_SPIKES(n)); 

                           y_axis = ones(length(SP),1).*scale.*.9;                   % (grüne Dreiecke)
                           line ('Xdata',SP,'Ydata', y_axis,...
                                  'LineStyle','none','Marker','v',...
                                  'MarkerFaceColor','green','MarkerSize',9);

                           %Anzahl der Bursts anzeigen
                           uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-((n-1)*120) 30 20],...
                                      'Parent',bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String',NR_BURSTS(n));   
                        end
                                     
                        if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1;       % Bursts % Änderung (RB) damit in beiden Tabs der Burst Button funktioniert
                           SP = nonzeros(BURSTS(:,n));                            % (gelbe Dreiecke)
                           if isempty(SP)==0
                              y_axis = ones(length(SP),1).*scale.*.9;
                              line ('Xdata',SP,'Ydata', y_axis,...
                                    'LineStyle','none','Marker','v',...
                                    'MarkerFaceColor','yellow','MarkerSize',9);
                           end
                        end
                     end
                 end
                 if stimulidata==1
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','parent',t6),'value');  % Stimuli % Änderung (RB) damit in beiden Tabs der Stimuli Button funktioniert
                       for k=1:length(BEGEND)                                       % (Rote Linien)
                        line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                        'Color','red', 'LineWidth', 1);
                       end 
                    end
                end        
            end
    
        end
        if max(SubmitSorting) > 0
           set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','off');
           set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','on'); % refresh Spike/Burst Nr. display
        else
           set(findobj(gcf,'Tag','ShowSpikesBurstsperEL'),'Visible','on');
           set(findobj(gcf,'Tag','ShowSpikesBurstsperCell'),'Visible','off'); % refresh Spike/Burst Nr. display
        end
            
        first_open4=true;
        drawnbefore4=true;
        xlabel('time / s','FontSize',12);
    end

    % --- Neuzeichnen der Graphen in Übersicht (CN) ------------------------
    function redraw_allinone(source,event) %#ok<INUSD>     
         
        set(findobj(gcf,'Tag','CELL_BottomPanel'),'Visible','off');
        set(findobj(gcf,'Tag','CELL_BottomPanel_zwei'),'Visible','on');
        MEAslider_pos = double(int8(get(findobj(gcf,'Tag','MEA_slider'),'value')));
        
        scale = get(scalehandle,'value');   % Y-Skalierung festlegen                                
        switch scale
            case 1, scale = 50;
            case 2, scale = 100;
            case 3, scale = 200;
            case 4, scale = 500;
            case 5, scale = 1000;
        end
        
        if first_open == 0 && drawnbeforeall == 1    %beim ersten Zeichnen, wenn bereits eine Datei geöffnet ist
            delete(SubMEA(2:7));
            delete(SubMEA(9:56));
            delete(SubMEA(58:63));
        end
        
        showend = MEAslider_pos*SaRa + 1;
        showstart = showend - SaRa;
        n=2;
        ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
        %ZUORDNUNG = [7 15 23 31 39 47 1 8 16 24 32 40 48 55 2 9 17 25 33 41 49 56 3 10 18 26 34 42 50 57 4 11 19 27 35 43 51 58 5 12 20 28 36 44 52 59 6 13 21 29 37 45 53 60 14 22 30 38 46 54];
        ZUORDNUNG2= [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];
           
        while n <= 63                       %whileschleife zum Zeichnen der leeren Subplots
            if n==8 || n==57   
                n = n+1;
            end
            bottomPanel_zwei;
            SubMEA(n) = subplot(8,8,n,'Parent',bottomPanel_zwei);
            set(gca,'XTickLabel',[],'YTickLabel',[]);
           
            if n == 49
               set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
            end        
            n=n+1; 
        end
        
        for n=1:nr_channel
            subplotposition = ZUORDNUNG2(find(ALL_CHANNELS==EL_NUMS(n)));%#ok

            subplot(8,8,subplotposition);                                       %Ansprechen der korrekten Subplots
            plot(T(showstart:showend),M(showstart:showend,n))                   %Zeichen in diesen Subplot
            axis([T(showstart) T(showend) -1*scale scale])
            set(gca,'XTickLabel',[],'YTickLabel',[]);
            
            if (EL_NUMS(n) == 17)
               set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
            end   
            
            if thresholddata
               if get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showThresholdsCheckbox','parent',t6),'value');   % Thresholds % Änderung (RB) damit in beiden Tabs der Threshold Button funktioniert
                    line ('Xdata',[0 T(length(T))],...                              % (gestrichelte Linie)
                        'Ydata',[THRESHOLDS(n) THRESHOLDS(n)],'LineStyle','--','Color','red');
                end
            end
                
            if spikedata==1
                if get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showSpikesCheckbox','parent',t6),'value'); % Spikes % Änderung (RB) damit in beiden Tabs der Spikes Button funktioniert
                    SP = nonzeros(SPIKES(:,n));                            % (grüne Dreiecke)
                    if isempty(SP)==0
                        y_axis = ones(length(SP),1).*scale.*.9;
                        line ('Xdata',SP,'Ydata', y_axis,...
                            'LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                    end
                end
                if  max(cell2mat(get(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'value')))>=1;       % Bursts % Änderung (RB) damit in beiden Tabs der Burst Button funktioniert
                    SP = nonzeros(BURSTS(:,n));                            % (gelbe Dreiecke)
                    if isempty(SP)==0
                        y_axis = ones(length(SP),1).*scale.*.9;
                        line ('Xdata',SP,'Ydata', y_axis,...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','yellow','MarkerSize',9);
                    end
                end       
            end
            
                if stimulidata==1
                    if get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj(gcf,'Tag','CELL_showStimuliCheckbox','parent',t6),'value');  % Stimuli % Änderung (RB) damit in beiden Tabs der Stimuli Button funktioniert
                       for k=1:length(BEGEND)                                       % (Rote Linien)
                        line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                        'Color','red', 'LineWidth', 1);
                       end 
                    end
                end  
        end
           
        first_open=true;
        drawnbeforeall=true;
        
        for n=1:8
            Elzeile = strcat('El X ',num2str(n));
            uicontrol('style', 'text','BackgroundColor', [0.8 0.8 0.8],'FontSize', 11,'units', 'pixels', 'position', [30 525-n*57 60 25],...
                'Parent', bottomPanel_zwei, 'String', Elzeile);
        end
        
        for n=1:8
            Elspalte = strcat({'El '}, num2str(n),{'X'});
            uicontrol('style', 'text','BackgroundColor', [0.8 0.8 0.8],'FontSize', 11,'units', 'pixels', 'position', [54+n*121 520 60 25],...
                'Parent', bottomPanel_zwei, 'String', Elspalte);
        end
        
        uicontrol('style', 'text','BackgroundColor', [0.8 0.8 0.8],'FontSize', 7,'units', 'pixels', 'position', [180 94 40 15],...
                'Parent', bottomPanel_zwei, 'String', 'time / s');     
    end

    % --- Funktionen der 'groß'-Buttons (MG)-------------------------------
    function zoomButton1Callback(source,event) %#ok<INUSD>
        if rawcheck == 1          
            if nr_channel>4
               slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
               Zoom_Electrode = nr_channel-slider_pos-3;

               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end 
              else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            else
               Zoom_Electrode = 1;
               
               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end
               else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
       
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos-3; 
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,1));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
    end
    function zoomButton2Callback(source,event) %#ok<INUSD>
        if rawcheck == 1          
            if nr_channel>4
               slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
               Zoom_Electrode = nr_channel-slider_pos-2;

               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end 
              else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            else
               Zoom_Electrode = 2;
               
               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end
               else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
            
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos-2; 
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,2));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
    end
    function zoomButton3Callback(source,event) %#ok<INUSD> 
        if rawcheck == 1          
            if nr_channel>4
               slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
               Zoom_Electrode = nr_channel-slider_pos-1;

               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end 
              else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            else
               Zoom_Electrode = 3;
               
               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end
               else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
       
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos-1; 
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,3));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
    end
    function zoomButton4Callback(source,event) %#ok<INUSD>
        if rawcheck == 1          
            if nr_channel>4
               slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
               Zoom_Electrode = nr_channel-slider_pos;

               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end 
              else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            else
               Zoom_Electrode = 4;
               
               if SubmitSorting(Zoom_Electrode) >= 1 % Änderung ,damit nach Sorting die einzelnen Zellsignale bei Zoom angezeigt werden(RB)
                  M_Zoom(1:size(M,1),1)=zeros;
                  colormap('Lines');
                  cmap = colormap;
                  Cell = ['Cell ' num2str(Zoom_Electrode)];
                  figure('Units','normalized','Position',[.1 .1 .8 .8],'Name',Cell,'NumberTitle','off');
                  Graph_offset = 0.035;
                  Graph_size = 1/SubmitSorting(Zoom_Electrode)-Graph_offset*2;
                   for m=1:SubmitSorting(Zoom_Electrode)
                       M_Zoom(1:size(M,1),1) = zeros;
                       SPI1 = SPIKES_Class(SPIKES_Class(:,Zoom_Electrode,2)==m,Zoom_Electrode,1)*SaRa;
                       for i=1:size(SPI1,1)
                           if ((SPI1(i)+1+floor(SaRa*0.5/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*0.5/1000)) >= 0) % test if 
                              M_Zoom(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),1) = M(SPI1(i)+1-floor(SaRa*0.5/1000):SPI1(i)+1+ceil(SaRa*0.5/1000),Zoom_Electrode); % Shapes variabler Länge
                           end
                       end
                       subplot('Position',[0.1 (1-Graph_size*m-Graph_offset*m) 0.8 Graph_size]);
                       hold on;
                       plot(T,M_Zoom,'color',[cmap(m,1),cmap(m,2),cmap(m,3)]); grid on;
                       hold off;
                   end
               else
                  figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                  plot(T,M(:,Zoom_Electrode)); grid on;
               end
            end
            xlabel('Time / s'); ylabel('Voltage / uV');
       
        elseif spiketraincheck == 1
            
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                graph_no = size(SPIKES,2)-slider_pos; 
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,graph_no));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            else
                figure('Units','normalized','Position',[.025 .3 .95 .4],'Name','Zoom','NumberTitle','off');
                plot(T,M); grid on;
                SP = nonzeros(SPIKES(:,4));
                    if isempty(SP)==0
                        for z=1:length(SP)
                        line('Xdata',[SP(z) SP(z)],'YData',[-1000 1000],'Color','blue','LineWidth',1);   
                        end
                    end
                xlabel('Time / s'); ylabel('Voltage / uV');
            end
        end
    end

    % --- Funktionen der 'invert'-Buttons (AD)-----------------------------
    function invertButton1Callback(source,event) %#ok 
        if rawcheck == 1 %Funktion macht nur bei Rohdaten Sinn
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos-3;
                M(:,Inv_Elektrode)=M(:,Inv_Elektrode)*(-1);
            else
                M(:,1)=M(:,1)*(-1);
            end
            redraw;
        end
    end
    function invertButton2Callback(source,event) %#ok 
        if rawcheck == 1
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos-2;
                M(:,Inv_Elektrode)=M(:,Inv_Elektrode)*(-1);
            else
                M(:,2)=M(:,2)*(-1);
            end
            redraw;
        end
    end
    function invertButton3Callback(source,event) %#ok 
        if rawcheck == 1
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos-1;
                M(:,Inv_Elektrode)=M(:,Inv_Elektrode)*(-1);
            else
                M(:,3)=M(:,3)*(-1);
            end
            redraw;
        end
    end
    function invertButton4Callback(source,event) %#ok 
        if rawcheck == 1
            if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Inv_Elektrode=nr_channel-slider_pos;
                M(:,Inv_Elektrode)=M(:,Inv_Elektrode)*(-1);
            else
                M(:,4)=M(:,4)*(-1);
            end
            redraw;
        end
    end

    % --- Funktionen der 'Ausnullen'-Buttons (CN)--------------------------
    function clearButton1Callback(source,event) %#ok 
        if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Clear_Elektrode=nr_channel-slider_pos-3;
        else
                Clear_Elektrode = 1;   
        end

        M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0; 
        end
        redraw;
    end
    function clearButton2Callback(source,event) %#ok 
        if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Clear_Elektrode=nr_channel-slider_pos-2;
        else
                Clear_Elektrode = 2;   
        end

        M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0; 
        end
        redraw;
    end
    function clearButton3Callback(source,event)  %#ok 
        if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Clear_Elektrode=nr_channel-slider_pos-1;
        else
                Clear_Elektrode = 3;   
        end

        M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0; 
        end
        redraw;
    end
    function clearButton4Callback(source,event)  %#ok 
        if nr_channel>4
                slider_pos = int8(get(findobj(gcf,'Tag','CELL_slider'),'value'));
                Clear_Elektrode=nr_channel-slider_pos;
        else
                Clear_Elektrode = 4;   
        end

        M(:,Clear_Elektrode)=0;
        if spiketraincheck == 1
            SPIKES(:,Clear_Elektrode)=0;
            BURSTS(:,Clear_Elektrode)=0; 
        end
        redraw;
    end


    %Funktionen - Tab Data
    %----------------------------------------------------------------------
    
    % --- Datei (Raw oder Spiketrain) öffnen (MG&CN)-----------------------
    function openFileButtonCallback(source,event) %#ok<INUSD>
        % Mögliche Filter und Analyseergebnisse einer vorher geladenen Datei entfernen.
        clear Energy Variance; %Damit Dimension bei neuen Berechnungen noch passt (vor allem bei Wavelets)
        SPIKES3D = [];
        SPIKES = [];
        SubmitSorting = 0; % Sorting Variable is reset 
        SPIKES_Class = [];
        set(findobj('Tag','S_K_Nr','parent',t6),'String',0); % Cluster Number in Sorting tab is reset
        
        clear BEGEND;
        waitbar_counter = 0;
        stimulidata     = false;    % 1, wenn Stimulidaten vorhanden
        thresholddata   = false;
        STIMULI_1       = 0;    % negative Flanken der Stimulation
        STIMULI_2       = 0;    % positive Flanken der Stimulation
        BEGEND          = 0;    % Timestamps der Stimuli (Anfänge und Enden)
        BEG             = 0;    % Timestamps der Stimulistarts
        END             = 0;    % Timestamps der Stimulienden
        cellselect      = 1; 
                             set(defaulthandle,'Value',1); %Muss ebenfalls gesetzt werden. Sollte Cardiac ausgewählt und anschließend eine neue Datei eingeladen werden,
                             handler;                      %so wird auf Option Neuronen resetet. Somit müssen aber auch die Anzeigen wieder zurück auf Neurone springen, nicht nur die Variable cellselect.        
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0; 
        SPIKES          = 0;
        BURSTS          = 0;
        SI_EVENTS       = 0;
        spikedata       = false;
        M               = 0;
        EL_NUMS         = 0;
        first_open      = false;
        first_open4     = false; 
        spiketraincheck = false;    % wird eins, wenn eine Spiketrain geladen wurde
        rawcheck        = false;    % wird eins, wenn Rohdaten geladen wurden
        NR_SPIKES       = 0;
        NR_BURSTS       = 0;
        THRESHOLDS      = 0;
        kappa_mean      = 0;
        threshrmsdecide = 1; %As Default setting use rms for threshold calculation
        
        varT            = 0;     % varibler threshold
        varTdata        = 0;
        
        % 'Datei öffen' - Dialogfeld
        [file,path] = uigetfile({'*.txt;*.dat','Data file (*.txt,*.dat)'},'Open data file...');
        if file==0,return,end                                       % Falls auf 'Abbrechen', tue nichts
        full_path = [path,file];
        disp ('Importing data file:'); tic
        h = waitbar(0,'Please wait - importing data file...');
        fid = fopen([path file]);                                   % Datei öffnen...

        fseek(fid,0,'eof');                                         % answer Ende der Datei springen,
        filesize = ftell(fid);                                      % Dateigröße in Byte speichern,
        fseek(fid,0,'bof');                                         % zurück an den Anfang.
        fileinfo = textscan(fid,'%s',1,'delimiter','\n');           % erste Zeile enthält Infos über Messung
        
        filedetails = textscan(fid,'%s %s %s %*s %s',1);                 %Einlesen der SampleRate
        Date = char([filedetails{1}]);
        Date = Date(1:(size(Date,2)-1));
        Time = char([filedetails{2}]);
        Time = Time(1:(size(Time,2)-1));
        Sample = char([filedetails{3}]);
        SaRa = str2double(Sample);
        FileType = char([filedetails{4}]);
                    
        if isempty(Date)
            waitbar(1,h,'Complete.'); close(h);
            msgbox('Maybe you try to open a McRack-file with the wrong button?!','Dr.CELL´s hint','help');
            uiwait;
            return                  
        end
        fseek(fid,0,'bof');                                         
        
        %---Falls Datei eine alte Datei ohne Anmerkung im Header ist---  
        if isempty(FileType)
        
            textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);   % Nach Zeile 3, dort 1. Wort überlesen
            elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');    % Elektrodennamen einlesen
            EL_NAMES = [elresult{:}];

            if is_open==1
               nr_channel_old = nr_channel; 
            end

            nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);                                   % Elektrodennamen erst in char..

            for n=1:size(EL_CHAR,1)                                     % ...und dann in doubles umwandeln.
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end

            fseek(fid,0,'bof');                                         % Wieder zurück zum Anfang

            if file(length(file)-2)=='t'                                % Zu Zeile 5 springen (und einlesen)
                mresult = textscan(fid,'',1,'headerlines',4);           % ...falls .txt-Datei:
                %T = [mresult{1}];                                      % Timestamps
                M = [mresult{2:length(mresult)-1}];                     % Messdaten
            else
                %---Für alte Dateien mit Komma-separation---
                %Für Punktseparation siehe ifelse FileType == 'R'!
                
                mresult = textscan(fid,'%n,%n',(nr_channel+1)*1,'headerlines',4);   % ...falls .dat-Datei:
                M = mresult{1}+mresult{2}.*(.1-.2*(mresult{1}<0));      % Vor- und Nachkommastellen zusammenkleben
                M = reshape(M,(nr_channel+1),1);                        % Von Array in Matrix umformen 
                M = M';
                %T = M(:,1);                                             % Array in Timestamps und...
                M = M(:,2:(nr_channel+1));                               % ...Elektrodenspannungen unterteilen       
            end

            clear M_temp;
            % Den Rest der Datei in Blöcke zu etwa 1/10 unterteilt einlesen,...
            % ...mit 'cat' zusammenhängen und zwischendurch die Statusanzeige... 
            % ...aktualisieren (a bit tricky):

            while ftell(fid)<filesize
                if file(length(file)-2)=='t'
                    mresult = textscan(fid,'',ceil(filesize/10000));
                    %T = cat(1,T,[mresult{1}]);
                    M = cat(1,M,[mresult{2:length(mresult)-1}]);
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                else
                    %---Für alte Dateien mit Komma-separation---
                    mresult = textscan(fid,'%n,%n',(nr_channel+1)*30000); %1 Vor und 2 Nachkommastellen
                    M_temp = mresult{1}+mresult{2}.*(.1-.2*(mresult{1}<0));   
                    M_temp = reshape(M_temp,(nr_channel+1),[]);
                    M_temp = M_temp';
                    %T = cat(1,T,M_temp(:,1));
                    M = cat(1,M,M_temp(:,2:(nr_channel+1)));
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                end
            end

            %T = (T')./1000;   % T in Zeilenvektor und Sekunden umwandeln
            clear M_temp;     % Reste wegräumen
            clear mresult;  
            
            %An dieser Stelle wird ein künstlicher Zeitvektor aus den
            %Informationen Samplerate und Länge von M erstellt 
            
            T2=(0:1/SaRa:(size(M,1)/SaRa));
            T=T2(1:(length(T2)-1));
            clear T2 %gleich Aufräumen

            M = cat(2,EL_NUMS',M');             % Elektrodennummern an Messwertarray kleben
            M = sortrows(M);                    % Messwerte nach den Nummern sortieren
            M = M(:,2:size(M,2));               % M wieder in Ursprungsform bringen
            M = M';                             % "
            EL_NAMES = sortrows(EL_NAMES);      % Elektrodennamen sortieren
            EL_NUMS = sort(EL_NUMS);            % Elektrodennummern sortieren
            rec_dur = ceil(T(length(T)));
            rec_dur_string = num2str(rec_dur);

            %falls benötigt wieder % entfernen
            %M_OR = M;                           % Sicherheitskopie M erstellen

            fclose(fid);                        % Datei schliessen
            waitbar(1,h,'Complete.'); close(h);   % Waitbar schliessen
            toc

            
             % Scrollbar konfigurieren und aktivieren und Graphen neuzeichnen
            if Viewselect == 0
                if nr_channel>4
                    set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', size(M,2)-4, 'Value', size(M,2)-4,...
                    'SliderStep', [1/(size(M,2)-4) 4/(size(M,2)-4)]);
                end          
                redraw
             elseif Viewselect == 1
                set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...       
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
                redraw_allinone 
            end
            is_open = true;
            rawcheck = true;    % wird eins, wenn Rohdaten geladen wurden 
        
      
        %---Falls die Datei eine Rohdatei ist---
        elseif FileType(1) == 'R'
        
            textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);   % Nach Zeile 3, dort 1. Wort überlesen
            elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');    % Elektrodennamen einlesen
            EL_NAMES = [elresult{:}];

            if is_open==1
               nr_channel_old = nr_channel; 
            end

            nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);                                   % Elektrodennamen erst in char..

            for n=1:size(EL_CHAR,1)                                     % ...und dann in doubles umwandeln.
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end

            fseek(fid,0,'bof');                                         % Wieder zurück zum Anfang
            if file(length(file)-2)=='t'                                % Zu Zeile 5 springen (und einlesen)
                mresult = textscan(fid,'',1,'headerlines',4);           % ...falls .txt-Datei:
                %T = [mresult{1}];                                      % Timestamps
                M = [mresult{2:length(mresult)-1}];                     % Messdaten
            else
                %---Für neue Dateien mit Punkt-separation---
                mresult = textscan(fid,'',1,'headerlines',4);
                %T = [mresult{1}];                                     %Nicht unbedingt nötig, da T künstlich erzeugt wird.
                M = [mresult{2:length(mresult)}];
            end

            clear M_temp;
            % Den Rest der Datei in Blöcke zu etwa 1/10 unterteilt einlesen,...
            % ...mit 'cat' zusammenhängen und zwischendurch die Statusanzeige... 
            % ...aktualisieren (a bit tricky):

            while ftell(fid)<filesize
                if file(length(file)-2)=='t'
                    mresult = textscan(fid,'',ceil(filesize/10000));
                    %T = cat(1,T,[mresult{1}]);
                    M = cat(1,M,[mresult{2:length(mresult)-1}]);
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                else

                    %---Für neue Dateien mit Punkt-separation---
                    %- Für Dateien mit Kommaseparation schaue in elseif isempty(FileType)
                    
                    mresult = textscan(fid,'',ceil(filesize/10000));
                    %T = cat(1,T,[mresult{1}]);
                    M = cat(1,M,[mresult{2:length(mresult)}]);
                    waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                end
            end

            %T = (T')./1000;   % T in Zeilenvektor und Sekunden umwandeln
            clear M_temp;     % Reste wegräumen
            clear mresult;  

            %An dieser Stelle wird ein künstlicher Zeitvektor aus den Informationen Samplerate und Länge von M erstellt 
            T2=(0:1/SaRa:(size(M,1)/SaRa));
            T=T2(1:(length(T2)-1));
            clear T2 %gleich Aufräumen

            M = cat(2,EL_NUMS',M');             % Elektrodennummern an Messwertarray kleben
            M = sortrows(M);                    % Messwerte nach den Nummern sortieren
            M = M(:,2:size(M,2));               % M wieder in Ursprungsform bringen
            M = M';                             % "
            EL_NAMES = sortrows(EL_NAMES);      % Elektrodennamen sortieren
            EL_NUMS = sort(EL_NUMS);            % Elektrodennummern sortieren
            rec_dur = ceil(T(length(T)));
            rec_dur_string = num2str(rec_dur);
            
            %M1 = M(1:size(M,1)/2,1); % TEST ob mehr Daten (längere Aufnahmezeit) beseres Sorting ermöglichen
            %T1 = T(1,1:size(T,2)/2);
        
            %M = M1;
            %T = T1;
            %rec_dur = ceil(T(length(T)));
            %rec_dur_string = num2str(rec_dur);


            %falls benötigt wieder % entfernen
            %M_OR = M;                           % Sicherheitskopie M erstellen

            fclose(fid);                        % Datei schliessen
            waitbar(1,h,'Complete.'); close(h);   % Waitbar schliessen
            toc

            
             % Scrollbar konfigurieren und aktivieren und Graphen neuzeichnen
            if Viewselect == 0
                if nr_channel>4
                    set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', size(M,2)-4, 'Value', size(M,2)-4,...
                    'SliderStep', [1/(size(M,2)-4) 4/(size(M,2)-4)]);
                end          
                redraw
             elseif Viewselect == 1
                set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...       
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
                redraw_allinone 
            end
            is_open = true;
            rawcheck = true;    % wird eins, wenn Rohdaten geladen wurden
        
           
            
        %---Falls die Datei eine Spiketraindatei ist---    
        elseif FileType(1) == 'S'            

            elresult = textscan(fid,'%5s',61,'whitespace','\b\t','headerlines',2);    % Elektrodennamen einlesen
            EL_NAMES = [elresult{:}];  
            EL_CHAR = char(EL_NAMES);                                   % Elektrodennamen erst in char..
            if is_open==1
                nr_channel_old = nr_channel;
            end  
            nr_channel = size(find(EL_CHAR(:,1)=='E'),1);
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);
            EL_NUMS=zeros(1,nr_channel);

            for n=1:nr_channel                                     % ...und dann in doubles umwandeln.
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end
            fseek(fid,0,'bof');                                         % Wieder zurück zum Anfang
            
            if file(length(file)-2)=='t'                                % Zu Zeile 5 springen (und einlesen)
                mresult = textscan(fid,'',1,'headerlines',4);           % ...falls .txt-Datei:
                M = [mresult{1:length(mresult)-1}];                     % Messdaten
            else
                %---Für neue Dateien mit Punkt-separation---
                mresult = textscan(fid,'',1,'headerlines',4);
                M = [mresult{1:length(mresult)}];
            end
                        
            clear M_temp;
            % Den Rest der Datei in Blöcke zu etwa 1/10 unterteilt einlesen,...
            % ...mit 'cat' zusammenhängen und zwischendurch die Statusanzeige... 
            % ...aktualisieren (a bit tricky):
            
            if filesize<10000       %Falls Dateigröße sehr klein ist (Spiketrain)
                divisor = 1000;
            else
                divisor = 10000;
            end
            
            
            while ftell(fid)<filesize
                if file(length(file)-2)=='t'                                    %txt-Dateien
                    mresult = textscan(fid,'',ceil(filesize/divisor));
                    M = cat(1,M,[mresult{1:length(mresult)-1}]);
                    waitbar(ftell(fid)*.7/filesize,h,['Please wait - analyzing Spiketrain file...(' int2str(ftell(fid)/1024) ' of ' int2str(filesize/1024),' kByte)']);
                else                                                             %dat-Dateien
                    mresult = textscan(fid,'',ceil(filesize/divisor));
                    M = cat(1,M,[mresult{1:length(mresult)}]);
                    waitbar(ftell(fid)*.7/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1024) ' of ' int2str(filesize/1024),' kByte)']);
                end
            end

            M = cat(2,EL_NUMS',M');             % Elektrodennummern an Messwertarray kleben
            M = sortrows(M);                    % Messwerte nach den Nummern sortieren
            M = M(:,2:size(M,2));               % M wieder in Ursprungsform bringen
            M = M';                             % "
            EL_NAMES = sortrows(EL_NAMES);      % Elektrodennamen sortieren
            EL_NUMS = sort(EL_NUMS);            % Elektrodennummern sortieren

            %Erstelle direkt das SPIKES-Array aus der eingelesenen Datei
            SPIKES_temp=M/1000; 
            SPIKESIZES = zeros(1,nr_channel);

            for n = 1:nr_channel                                         %Berechne die Anzahl der Spikes pro Elektrode
                SPIKESIZES(n) = length(nonzeros(SPIKES_temp(:,n)));
            end  
            MaxSpikes = max(SPIKESIZES);
            SPIKES = zeros(MaxSpikes,nr_channel);

            for n = 1:size(SPIKES_temp,2)                                         %Berechne die Anzahl der Spikes pro Elektrode
                if SPIKESIZES(n) ~= 0
                    SPIKES(1:SPIKESIZES(n),n) = nonzeros(SPIKES_temp(:,n));
                end
            end

            clear M_temp;     % Reste wegräumen
            clear mresult;
            fclose(fid);                        % Datei schliessen  
            T=0:1/SaRa:(ceil(max(SPIKES(:)))-1/SaRa);        %Erstelle künstlichen T-Vektor von 0 bis zur nächsten vollen Sekunde nach dem letzten Spike
            
            %Baue einen künstlichen M-Vektor bei dem zu jedem
            %Spikezeitpunkt -100müV gezsetzt wird.
            
            M=zeros(size(T,2),nr_channel);
            SP_TWO = round(SPIKES*SaRa);  %round damit integer rauskommen 
            
            for c = 1:nr_channel
                bin = nonzeros(SP_TWO(:,c));
                bin = bin+1;    %Positionen an denen ein Spike ist
                M(bin,c) = -100;
            end
            
            clear bin SP_TWO %Aufräumen
            
            rec_dur = ceil(T(length(T)));
            rec_dur_string = num2str(rec_dur);

            waitbar(1,h,'Complete.'); close(h);   % Waitbar schliessen
            spikedata = true;          % Ab jetzt sind offiziell Spikedaten vorhanden
            SPIKES_OR=SPIKES;       %Kopie von Spikes anlegen
            
            for n = 1:(nr_channel)                                % Für die Zusammenfassung:...
                NR_SPIKES(n) = length(find(SPIKES(:,n)));        % Anzahl der Spikes pro Elektrode
            end  

            %Daten stehen im Spiketrain nicht zur Verfügung, werden aber für Export benötigt
            THRESHOLDS = zeros(1,nr_channel);
            SNR = zeros(1,nr_channel);
            SNR_dB = zeros(1,nr_channel);         
            
            
            % Scrollbar konfigurieren und aktivieren und Graphen neuzeichnen
            if Viewselect == 0
                if nr_channel>4
                    set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                    'Min', 0, 'Max', size(M,2)-4, 'Value', size(M,2)-4,...
                    'SliderStep', [1/(size(M,2)-4) 4/(size(M,2)-4)]);
                end
                redraw
             elseif Viewselect == 1
                set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...       
                'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
                redraw_allinone
            end           
            is_open = true;
            spiketraincheck = true;    % wird eins, wenn Spiketrain geladen wurden    
        
        %---Falls da was ganz anderes im Header steht!---
        else
            waitbar(1,h,'Complete.'); close(h);
            msgbox('Unknown fileformat!','Dr.CELL´s hint','help');
            uiwait;
            return        
        end
        
        % Anzeige des Dateipfads und Fileinfo oben im Fenster aktualisieren:
        set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
        set(findobj(gcf,'Tag','CELL_fileInfo'),'String',fileinfo{1});

        %Anzeige der Filedetails aktualisieren
        set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
        set(findobj(gcf,'Tag','CELL_dataNrEl'),'String',nr_channel);
        set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
        set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
        set(findobj(gcf,'Tag','CELL_dataDur'),'String',rec_dur_string);
        
        %Anzeige der Spikes und Bursts pro El abschalten
        delete(findobj(0,'Tag','ShowSpikesBurstsperEL'));
        delete(findobj(0,'Tag','ShowSpikesBurstsperCell'));
             
        if nr_channel>1
             set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
        end
     
        if spiketraincheck == 1

           set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
           set(findobj(gcf,'Parent',t3,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t2,'Enable','on'),'Enable','off');
           
           %Anzeige der Filedetails aktualisieren 
           set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
           set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_scaleBox'),'value',2,'Enable','off');
           set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
           set(findobj(gcf,'Parent',radiogroup2),'Enable','off');
           set(findobj(gcf,'Parent',radiogroup3),'Enable','off');
           set(findobj(gcf,'Tag','time_start'),'Enable','off');
           set(findobj(gcf,'Tag','time_end'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_sensitivityBox'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'Enable','off');  
           set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t7,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t8,'Enable','off'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','on');       
           set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
           set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');    
           set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
           set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
           set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');  
           
           if nr_channel>1
               set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
           end
           
        else
           set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_highpassFilterCheckbox'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_lowpassFilterCheckbox'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
           set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_savitzkygolayButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_applyButton'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_scaleBox'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','on');
           set(findobj(gcf,'Parent',radiogroup2),'Enable','on');
           set(findobj(gcf,'Parent',radiogroup3),'Enable','on');
           set(findobj(gcf,'Tag','time_start'),'Enable','off');
           set(findobj(gcf,'Tag','time_end'),'Enable','off');
           set(findobj(gcf,'Parent',t4,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t7,'Enable','on'),'Enable','off');
           set(findobj(gcf,'Parent',t8,'Enable','off'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
           set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');        
           set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
           set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
           set(findobj(gcf,'Tag','CELL_exportButton'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_showExportCheckbox'),'Enable','off');
           set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
           set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
           set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');  
           
           if nr_channel>1
               set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
           end
        end   
        %Electrode Selection
        delete(findobj('Tag','S_Elektrodenauswahl'));
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 12 50 51],'Tag','S_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Enable','off','Value',1,'Style','popupmenu','callback',@recalculate);
        SubmitSorting(1:size(M,2)) = zeros; 
         
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        
        delete(findobj('Tag','S_pretime'));
        delete(findobj('Tag','S_posttime'));
        uicontrol('Parent',t6,'Units','Pixels','Position',[700 65 50 30],'Tag','S_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);
        uicontrol('Parent',t6,'Units','Pixels','Position',[760 65 50 30],'Tag','S_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','Enable','off','callback',@recalculate);

       
    end

    % --- McRack-Datei (in ASCII umgewandelt) öffnen (CN)------------------
    function openMcRackButtonCallback(source,event) %#ok<INUSD>
        % Mögliche Filter und Analyseergebnisse einer vorher geladenen Datei entfernen.
        
        clear BEGEND;
        waitbar_counter = 0;
        stimulidata     = false;    % 1, wenn Stimulidaten vorhanden
        thresholddata   = false;
        STIMULI_1       = 0;    % negative Flanken der Stimulation
        STIMULI_2       = 0;    % positive Flanken der Stimulation
        BEGEND          = 0;    % Timestamps der Stimuli (Anfänge und Enden)
        BEG             = 0;    % Timestamps der Stimulistarts
        END             = 0;    % Timestamps der Stimulienden
        cellselect      = 1; 
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0; 
        SPIKES          = 0;
        BURSTS          = 0;
        SI_EVENTS       = 0;
        spikedata       = false;
        M               = 0;
        EL_NUMS         = 0;
        first_open      = false;
        first_open4     = false; 
        spiketraincheck = false;    % wird eins, wenn eine Spiketrain geladen wurde
        rawcheck        = false;    % wird eins, wenn Rohdaten geladen wurden
        NR_SPIKES       = 0;
        NR_BURSTS       = 0;
        THRESHOLDS      = 0;
        kappa_mean      = 0;
        threshrmsdecide = 1; %As Default setting use rms for threshold calculation
        
        % 'McRack-Datei öffen' - Dialogfeld
        [file,path] = uigetfile({'*.txt','Data file (*.txt)'},'Open McRack file...');
        if file==0,return,end                                       % Falls auf 'Abbrechen', tue nichts
        full_path = [path,file];
        disp ('Importing McRack file:'); tic
        h = waitbar(0,'Please wait - importing McRack file...');
        fid = fopen([path file]);                                   % Datei öffnen...

        fseek(fid,0,'eof');                                         % answer Ende der Datei springen,
        filesize = ftell(fid);                                      % Dateigröße in Byte speichern,
        fseek(fid,0,'bof');                                         % zurück an den Anfang.
        fileinfo = textscan(fid,'%s',1,'delimiter','\n');           % erste Zeile entält Infos über Messung   
        Date = 'unknown';
        Time = 'unknown';
        fseek(fid,0,'bof');                                         
        
        textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);   % Nach Zeile 3, dort 1. Wort überlesen
        elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');    % Elektrodennamen einlesen
        EL_NAMES = [elresult{:}];
        
        if is_open==1
           nr_channel_old = nr_channel; 
        end
        
        nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
        EL_NAMES = EL_NAMES(1:nr_channel);
        EL_CHAR = char(EL_NAMES);                                   % Elektrodennamen erst in char..
        
        for n=1:size(EL_CHAR,1)                                     % ...und dann in doubles umwandeln.
            EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
        end
        fseek(fid,0,'bof');                                         % Wieder zurück zum Anfang

        mresult = textscan(fid,'',1,'headerlines',4);           
        T = [mresult{1}];                                       % Timestamps
        M = [mresult{2:length(mresult)-1}];                     % Messdaten
               
        % Den Rest der Datei in Blöcke zu etwa 1/10 unterteilt einlesen,...
        % ...mit 'cat' zusammenhängen und zwischendurch die Statusanzeige... 
        % ...aktualisieren (a bit tricky):

        while ftell(fid)<filesize
              mresult = textscan(fid,'',round(filesize/10000));
              T = cat(1,T,[mresult{1}]);
              M = cat(1,M,[mresult{2:length(mresult)-1}]);
              waitbar(ftell(fid)*.98/filesize,h,['Please wait - analyzing data file...(' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
        end
        T = (T')./1000;   % T in Zeilenvektor und Sekunden umwandeln
        SaRa = 1/T(2);      
        clear mresult;  
      
        M = cat(2,EL_NUMS',M');             % Elektrodennummern an Messwertarray kleben
        M = sortrows(M);                    % Messwerte nach den Nummern sortieren
        M = M(:,2:size(M,2));               % M wieder in Ursprungsform bringen
        M = M';                             % "
        EL_NAMES = sortrows(EL_NAMES);      % Elektrodennamen sortieren
        EL_NUMS = sort(EL_NUMS);            % Elektrodennummern sortieren
        rec_dur = ceil(T(length(T)));
        rec_dur_string = num2str(rec_dur);
         
        %falls benötigt wieder % entfernen
        %M_OR = M;                           % Sicherheitskopie M erstellen
        
        fclose(fid);                        % Datei schliessen
        waitbar(1,h,'Complete.'); close(h);   % Waitbar schliessen
        toc

        % Anzeige des Dateipfads und Fileinfo oben im Fenster aktualisieren:
        set(findobj(gcf,'Tag','CELL_dataFile'),'String',file);
        set(findobj(gcf,'Tag','CELL_fileInfo'),'String',fileinfo{1});
        
        %Anzeige der Filedetails aktualisieren
        set(findobj(gcf,'Tag','CELL_dataSaRa'),'String',SaRa);
        set(findobj(gcf,'Tag','CELL_dataNrEl'),'String',nr_channel);
        set(findobj(gcf,'Tag','CELL_dataDate'),'String',Date);
        set(findobj(gcf,'Tag','CELL_dataTime'),'String',Time);
        set(findobj(gcf,'Tag','CELL_dataDur'),'String',rec_dur_string);
  
        %set(findobj(gcf,'Parent',t2,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_highpassFilterCheckbox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_lowpassFilterCheckbox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_restoreButton'),'Enable','on')
        set(findobj(gcf,'Tag','CELL_ElnullenButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_invertButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_smoothButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_savitzkygolayButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_applyButton'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_scaleBox'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_scaleBoxLabel'),'Enable','on');
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
        set(findobj(gcf,'Parent',radiogroup2),'Enable','on');
        set(findobj(gcf,'Parent',radiogroup3),'Enable','on');
        set(findobj(gcf,'Tag','time_start'),'Enable','off');
        set(findobj(gcf,'Tag','time_end'),'Enable','off'); 
        set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t7,'Enable','on'),'Enable','off');
        set(findobj(gcf,'Parent',t8,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
        set(findobj(gcf,'Tag','CELL_exportButton'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','CELL_showExportCheckbox'),'Enable','off');
        set(findobj(gcf,'Tag','radio_allinone'),'Enable','on');
        set(findobj(gcf,'Tag','radio_fouralltime'),'Enable','on');
        set(findobj(gcf,'Tag','VIEWtext'),'Enable','on');
        set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
        
        if nr_channel>1
            set(findobj(gcf,'Tag','CELL_Crosscorrelation'),'Enable','on');
        end     
 
         % Scrollbar konfigurieren und aktivieren und Graphen neuzeichnen
        if Viewselect == 0
            if nr_channel>4
                set(findobj(gcf,'Tag','CELL_slider'),'Enable','on',...
                'Min', 0, 'Max', size(M,2)-4, 'Value', size(M,2)-4,...
                'SliderStep', [1/(size(M,2)-4) 4/(size(M,2)-4)]);
            end          
            redraw
         elseif Viewselect == 1
            set(findobj(gcf,'Tag','MEA_slider'),'Enable','on',...       
            'Min', 1, 'Max', rec_dur,'Value', 1, 'SliderStep',[1/rec_dur 1/rec_dur]);
            redraw_allinone 
        end
        is_open = true;
        rawcheck = true;    % wird eins, wenn Rohdaten geladen wurden
    end

    % --- Analyse der Netzwerkbursts aus xls.-Dateien (CN)-----------------
    function AnalyseNetworkburstxls(source,event) %#ok<INUSD>
        [file,path] = uigetfile({'*.xls','DR_CELL Reportdatei (*.xls)'},...
        'Reportdateien auswählen...','MultiSelect','on');
        if file==0,return,end                                       % Falls auf 'Abbrechen', tue nichts
           h_bar=waitbar(0.05,'Please wait - importing data file...');
        
        if iscell(file)==0
           numberfiles = 1;
        else
           numberfiles = length(file);
        end

        MinDuration(1:numberfiles) = 0; 
        MaxDuration(1:numberfiles) = 0;
        MeanDuration(1:numberfiles) = 0;
        stdMeanDuration(1:numberfiles) = 0;
        MinRise(1:numberfiles) = 0;
        MaxRise(1:numberfiles) = 0;
        Meanrise(1:numberfiles) = 0;
        stdMeanRise(1:numberfiles) = 0;
        MinFall(1:numberfiles) = 0;
        MaxFall(1:numberfiles) = 0;
        Meanfall(1:numberfiles) = 0;
        stdMeanFall(1:numberfiles) = 0;
        waitbarcounter = 0.05;
        ORDER = 0;
        
waitbar(0.05,h_bar,'Please wait - networkbursts are analysed...');
        %Messdauer einlesen
        for h=1:numberfiles
            if iscell(file)==0
                DUR_REC = xlsread([path file], 'Tabelle1','D6');
                T = 0:0.0002:(DUR_REC-0.0002);
                BIG = DUR_REC/0.0002;
                
                WORKSPACE = xlsread([path file], 'Tabelle1');
                BURSTS=WORKSPACE(30:size(WORKSPACE,1),:);
                clear WORKSPACE;
                [nums, txt] = xlsread([path file], 'Tabelle2'); %Einlesen der Datei
                SPIKES = nums;
                EL_NAMES = txt(:,4:length(txt));
            else
                DUR_REC = xlsread([path file{h}],'Tabelle1','D6');
                T = 0:0.0002:(DUR_REC-0.0002);
                BIG = DUR_REC/0.0002;
                
                WORKSPACE = xlsread([path file{h}], 'Tabelle1');
                BURSTS=WORKSPACE(30:size(WORKSPACE,1),:);
                clear WORKSPACE;
                SPIKES = xlsread([path file{h}],'Tabelle2');    
            end
             
waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
waitbar(waitbarcounter)

        sync_time = int32(.04*SaRa);                    % Zeit, während der 2 Spikes parallel gelten: 40ms
        max_time = int32(.4*SaRa);                      % Zeitspanne, in der nach dem Maximum des Ereignisses gesucht wird: 400ms
        wait_time = int32(.5*SaRa);                     % Minimale Zeit vom Maximum Beginn eines zum Beginn des nächsten Events: 500ms 

            ELECTRODE_ACTIVITY = zeros(BIG,60);          % Maßzahl für Aktivität an der jeweiligen Elektrode
            ACTIVITY = zeros(1,BIG);                     % Zum jeweiligen Zeitpunkt aktive Elektroden

                    for i = 1:size(BURSTS,2)                        % Für jeden einzelnen Burst...
                        for j = 1:length(nonzeros(BURSTS(:,i)))     
                            pos = int32(BURSTS(j,i)*SaRa);          % Umrechnung des Timestamps zurück in den Time-Array-Index 

                            if (pos>sync_time && pos<length(ACTIVITY)-sync_time)         % Die ersten und letzten 100 Samples vernachlässigen (i.d.R. 20 ms)
                                ELECTRODE_ACTIVITY(pos-sync_time:pos+sync_time,i) = 1;   % Für jeden Spike-Timestamp im Umkreis...
                            end                                                          % ...von 40ms ELECTRODE_ACTIVITY auf 1 setzen.
                        end
                    end

                    ACTIVITY = sum(ELECTRODE_ACTIVITY,2);
                    clear ELECTRODE_ACTIVITY;
                 
waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
waitbar(waitbarcounter)

           %Berechnung der Laufzeitunterschiede innerhalb der Netzwerkbursts
            i = 1; k = 1;
            while i <= length(ACTIVITY)
                if i+max_time < length(ACTIVITY)        % Diese if-Abfrage stellt sicher, dass bei der...
                    imax = i+max_time;                  % ...folgenden Suche des Maximums die Länge des Vektors...
                else                                    % ...ACTIVITY nicht überschritten wird.
                    imax = length(ACTIVITY);
                end
                              
                if ACTIVITY(i)>=5                      % Wenn ACTIVITY 20 Prozent der Elektroden überschreitet...
                    [~,I] = max(ACTIVITY(i:imax));      % ... ([C,I] vorher )wird das Maximum der Spitze gesucht...
                    maxlength = 0;
                    while ACTIVITY(i+I)==ACTIVITY(i+I+1)
                        maxlength = maxlength+1;
                        I = I+1;
                    end
                    I = I-int32(maxlength/2);
                    SI_EVENTS(k) = T(i+I);              % ...und der Timestamp in SI_EVENTS gepeichert.
                    k = k+1;
                    i = i+I+wait_time;
                end
                    i = i+1;
            end
                Nr_SI_EVENTS = size(SI_EVENTS,2);
                if (Nr_SI_EVENTS == 1) && (SI_EVENTS(1)==0)     %Korrektur, falls es keine simultanen Ereignisse gibt.
                    Nr_SI_EVENTS =0;
                end
    
                waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
                waitbar(waitbarcounter)
                %Berechnung der Kurvenform der Netzwerkbursts            
                [b,a] = butter(3,400*2/SaRa,'low');% Butterworth-TP 5.Grades glättet die Kurve       
                ACTIVITY = filter(b,a,ACTIVITY);    
                
                waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
                waitbar(waitbarcounter)
                %Berechnung der Anstiegszeit, Fallzeit und Dauer der Netzwerkbursts
                for k=1:Nr_SI_EVENTS
                    MAX(k) = ACTIVITY(int32(SI_EVENTS(k)*SaRa));      %suche y-Werte zu den Timestamps der Netzwerkbursts
                    UG(k) = 0.2*MAX(k);                               %80%-Grenze des Maximums
                    OG(k)= 0.8*MAX(k);                                %20%-Grenze des Maximums  

                    countlimit(k)=0;
                    for q=1:(10*wait_time)
                        if ACTIVITY(int32(SI_EVENTS(k)*SaRa-q))<0.5
                            countlimit(k)=int32(SI_EVENTS(k)*SaRa-q);
                                if countlimit(k)<= 0;
                                  countlimit(k) = 1;
                                end                
                            break
                        end
                    end

                    for p=1:int32(SI_EVENTS(k)*SaRa-countlimit(k));                          %Suche nach Timestamps der 20%-Grenze vor dem Peak                                     
                            if ACTIVITY(int32(countlimit(k)+p-1))>= UG(k)
                             time20_vor(k) = (double(countlimit(k)+p-1)/SaRa);
                             break
                            end
                    end

                    for p=1:int32(SI_EVENTS(k)*SaRa-time20_vor(k)*SaRa)  %Suche nach Timestamps der 80%-Grenze vor dem Peak
                        if ACTIVITY(int32(time20_vor(k)*SaRa+p-1))>= OG(k)
                            time80_vor(k) = (double(time20_vor(k)*SaRa+p-1))/SaRa;
                            break
                        end
                    end

                    for p=1:int32(wait_time)                         %Suche nach Timestamps der 80%-Grenze nach dem Peak
                        if ACTIVITY(int32(SI_EVENTS(k)*SaRa+p-1))<= OG(k)
                            time80_nach(k) = double(SI_EVENTS(k)*SaRa+p-1)/SaRa;
                            break
                        end
                    end

                    for p=1:int32((2*wait_time)-(time80_nach(k)*SaRa-SI_EVENTS(k)*SaRa))  %Suche nach Timestamps der 20%-Grenze nach dem Peak
                        if ACTIVITY(int32(time80_nach(k)*SaRa)+p-1)<= UG(k)
                            time20_nach(k) = double(time80_nach(k)*SaRa+p-1)/SaRa;
                            break
                        end
                    end

                    Duration(k)= time20_nach(k)-time20_vor(k);
                    Rise(k) = time80_vor(k)-time20_vor(k);
                    Fall(k) = time20_nach(k)-time80_nach(k);
                end

                waitbarcounter= waitbarcounter + 0.9/(8*numberfiles);
                waitbar(waitbarcounter)
                
                if SI_EVENTS ~= 0
                    MinDuration(h) = min(Duration); 
                    MaxDuration(h) = max(Duration);
                    MeanDuration(h) = mean(Duration);
                    stdMeanDuration(h) = std(Duration);
                    MinRise(h) = min(Rise);
                    MaxRise(h) = max(Rise);
                    Meanrise(h) = mean(Rise);
                    stdMeanRise(h) = std(Rise);
                    MinFall(h) = min(Fall);
                    MaxFall(h) = max(Fall);
                    Meanfall(h) = mean(Fall);
                    stdMeanFall(h) = std(Fall);

                    %Zwischenwerte werden gelöscht
                    clear Duration;
                    clear Rise;
                    clear Fall;
                end
        end 
      
         %Bestimmung der Laufzeiten
         if numberfiles == 1
              ORDER = cell(size(BURSTS,2),size(SI_EVENTS,2));
              BURSTTIME = zeros(size(BURSTS,2),size(SI_EVENTS,2));            
              if SI_EVENTS ~= 0
                       for n=1:size(SI_EVENTS,2)           %Für jedes SBE
                          eventpos = int32(SI_EVENTS(n)*SaRa);
                          eventbeg=double(eventpos);

                          while ACTIVITY(eventbeg) >= 1           %Suche nach dem Anfang des SI_Events
                             eventbeg = eventbeg-1;    
                          end

                          eventtime = eventbeg/SaRa;
                          xy = 0;
                          yz = 1;
                          t=1;
                          tol=1/(SaRa*2);

                          while(xy<=0.4)
                             zz=1;
                             [row,col] = find((BURSTS<(eventtime+xy+tol))&(BURSTS>(eventtime+xy-tol))); %Suche nach Elementen

                             if isempty(col)  
                             else
                                 while zz<=length(col)                                    %für den Fall dass zwei Bursts exakt zeitglich auftreten 
                                 ORDER(yz,n) = EL_NAMES(col(zz));
                                 BURSTTIME(yz,n) = BURSTS(row(zz),col(zz));
                                 yz = yz+1;                                             %nächster Burst
                                 zz=zz+1;   
                                 end
                             end
                             t=t+1;                    
                             xy = xy+1/SaRa;
                          end
                       end
              end
         end    
        
waitbar(1,h_bar,'Complete.'); close(h_bar);
        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','on');

        if ((iscell(file)==0) && (SI_EVENTS(1)~=0))
                        %Erstelle ein Fenster für die Zusammenfassung
                        mainNWB = figure('Position',[150 100 1000 500],'Name','Networkbursts','NumberTitle','off','Resize','off');
                        subplot(2,1,1); 
                        plot(T,ACTIVITY)
                        axis([0 T(size(T,2)) -10 60])
                        xlabel ('Zeit / s');
                        ylabel({'number of active electrodes (blue)';'Maximum/Peak (green)'});
                        title('Networkactivity','fontweight','b')

                        for n=1:length(SI_EVENTS)   %Zeichnet die Maxima in figure
                            line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[-10 60],'Color','green');
                        end   

                        %steigende Flanke 
                        Risepanel = uipanel('Parent',mainNWB,'Title','rising time 20%-80%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[130 40 256 200]);
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 130 120 30],'String','min time [s]');     
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 90 120 30],'String','max time [s]'); 
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 50 120 30],'String','average [s]'); 
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 10 140 30],'String','Standard deviation'); 

                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_1');
                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_2');         
                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_durch');         
                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_std');         

                        set(findobj(gcf,'Tag','trise_1'),'String',MinRise);
                        set(findobj(gcf,'Tag','trise_2'),'String',MaxRise);
                        set(findobj(gcf,'Tag','trise_durch'),'String',Meanrise);
                        set(findobj(gcf,'Tag','trise_std'),'String',stdMeanRise);

                        %fallende Flanke 
                        Fallpanel = uipanel('Parent',mainNWB,'Title','falling time 80%-20%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[390 40 256 200]);
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 130 120 30],'String','min time [s]');     
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 90 120 30],'String','max time [s]'); 
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 50 120 30],'String','average [s]'); 
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 10 140 30],'String','Standard deviation'); 

                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_1');
                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_2');         
                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_durch');         
                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_std');         

                        set(findobj(gcf,'Tag','tfall_1'),'String',MinFall);
                        set(findobj(gcf,'Tag','tfall_2'),'String',MaxFall);
                        set(findobj(gcf,'Tag','tfall_durch'),'String',Meanfall);
                        set(findobj(gcf,'Tag','tfall_std'),'String',stdMeanFall);

                        %Dauer     
                        Durationpanel = uipanel('Parent',mainNWB,'Title','duration 20%-20%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[650 40 256 200]);
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 130 120 30],'String','min time [s]');     
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 90 120 30],'String','max time [s]'); 
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 50 120 30],'String','average [s]'); 
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 10 140 30],'String','Standard deviation'); 

                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_1');
                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_2');         
                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_durch');         
                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_std');         

                        set(findobj(gcf,'Tag','tdur_1'),'String',MinDuration);
                        set(findobj(gcf,'Tag','tdur_2'),'String',MaxDuration);
                        set(findobj(gcf,'Tag','tdur_durch'),'String',MeanDuration);
                        set(findobj(gcf,'Tag','tdur_std'),'String',stdMeanDuration);
        end     
    end


    %Funktionen - Tab Preprocessing
    %----------------------------------------------------------------------

    % --- 50Hz-HP-Filter (MG)----------------------------------------------
    function highpassButtonCallback(source,event) %#ok<INUSD>
        waitbar_counter = waitbar_counter + waitbaradd;
        waitbar(waitbar_counter);
        
        [b,a]=cheby2(3,20,2*58/SaRa,'high');      % Tchebychew-HP 3.Grades bei 58Hz
        waitbar_counter = waitbar_counter + 2*waitbaradd;
        waitbar(waitbar_counter);
        M = filter(b,a,M);                        %(damit Max. Dämpfung bei 50Hz)
        
        %Der Filter macht aus dem ausgenullten Signal wieder Werte ungleich
        %Null. Daher muss das Signal während der Stimulation erneut genullt
        %werden.
        if stimulidata == 1
            for n = 1:(length(BEG))
                M((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
             end
        end    
    end

    % --- 500Hz-TP-Filter (MG)---------------------------------------------
    function lowpassButtonCallback(source,event) %#ok<INUSD>
        waitbar_counter = waitbar_counter + waitbaradd;
        waitbar(waitbar_counter);
        [b,a] = butter(5,580*2/SaRa,'low');       % Butterworth-TP 5.Grades
        waitbar_counter = waitbar_counter + 2*waitbaradd;
        waitbar(waitbar_counter);
        M = filter(b,a,M);                        % bei ca. 500 Hz
        
        %Der Filter macht aus dem ausgenullten Signal wieder Werte ungleich
        %Null. Daher muss das Signal während der Stimulation erneut genullt
        %werden.
        if stimulidata == 1
            for n = 1:(length(BEG))
                M((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
             end
        end
    end 
    
    % --- Zero Out an oder aus (CN)----------------------------------------
    function onofffkt(source,event)%#ok  
       if get(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'Value')==1 
            set(findobj(gcf,'Tag','headlines'),'enable','on');
            set(findobj(gcf,'Tag','threshstim'),'enable','on');
            set(findobj(gcf,'Tag','th_stim'),'String','700','enable','on');
            set(findobj(gcf,'Tag','CELL_selectelectrode'),'enable','on');
            set(findobj(gcf,'Tag','Elekstimname'),'enable','on');
            set(findobj(gcf,'Tag','text_aftertime'),'enable','on');
            set(findobj(gcf,'Tag','aftertime'),'String','0.005','enable','on'); 
            set(findobj(gcf,'Tag','textplus'),'enable','on');
            set(findobj(gcf,'Tag','textsek'),'enable','on');
       else 
            set(findobj(gcf,'Tag','headlines'),'enable','off');
            set(findobj(gcf,'Tag','threshstim'),'enable','off');
            set(findobj(gcf,'Tag','th_stim'),'String','-','enable','off');
            set(findobj(gcf,'Tag','CELL_selectelectrode'),'enable','off');
            set(findobj(gcf,'Tag','Elekstimname'),'enable','off');
            set(findobj(gcf,'Tag','text_aftertime'),'enable','off');
            set(findobj(gcf,'Tag','aftertime'),'String','-','enable','off'); 
            set(findobj(gcf,'Tag','textplus'),'enable','off');
            set(findobj(gcf,'Tag','textsek'),'enable','off'); 
       end
    end

    % --- ZeroOut Einlesen (CN)--------------------------------------------
    function ZeroOutcallfunction(source,event) %#ok<INUSD>
         PREF(9) = get(findobj(gcf,'Tag','CELL_selectelectrode'),'value');
         PREF(10) = str2double(get(findobj(gcf,'Tag','th_stim'),'string'));
         PREF(11) = str2double(get(findobj(gcf,'Tag','aftertime'),'string'));
         h_wait = waitbar(0,'Please Wait - busy...');
         buttonfunction;
    end

    % --- ZeroOut - Berechnung der Stimulitimestamps (CN)------------------
    function buttonfunction(source, event) %#ok<INUSD>
        M_Stim = M(:,PREF(9));
        M2 = (M_Stim<-(PREF(10)));
        M3 = (M_Stim>PREF(10));
        waitbar_counter = waitbar_counter + 10*waitbaradd;
        waitbar(waitbar_counter);
 
        if ((isempty(nonzeros(M2)))==0) %falls es überhaupt Stimuli gibt
             %Überprüfe ob der erste detektierte Stimulus zu nah am Anfang liegt
                BEGTEST = M_Stim(1:(int32(0.2*SaRa)));
                 if ((max(BEGTEST)>PREF(10) )||(min(BEGTEST)<-(PREF(10))));
                    M(1:int32(0.2*SaRa),:) = 0;
                 end
                 clear BEGTEST

                % Timestamps der Stimuli erstellen:
                k = 0;
                i = 0;
                q = 0;
                w = 0;
                for m = 2:size(M2)
                    if M2(m)>M2(m-1) %negative Flanken Start
                        k = k+1;
                        STIMULI_1(k) = T(m);
                    end 
                    if M2(m)<M2(m-1) %negative Flanken Ende
                        i = i+1;
                        STIMULI_2(i) = T(m);
                    end           
                    if M3(m)<M3(m-1) %positive Flanken Start
                        q = q+1;
                        STIMULI_3(q) = T(m);          
                    end
                    if M3(m)>M3(m-1) %positive Flanken Ende
                        w = w+1;
                        STIMULI_4(w) = T(m);          
                    end           
                end

                waitbar_counter = waitbar_counter + 5*waitbaradd;
                waitbar(waitbar_counter);
                STIMULI = sort(cat(2,STIMULI_1,STIMULI_2,STIMULI_3,STIMULI_4 ));

                if k > 0 || i > 0
                    BEGEND(1)= (STIMULI(1)-0.001);  %Anfang der ersten Stimulation
                    k=1;        
                    for m = 2:(size(STIMULI,2)-1)
                        if (STIMULI(m+1)-STIMULI(m))>0.075  %Liegen die Stimuli weiter als 0,075 auseinander so werden sie als getrennte Stimuli behandelt
                            k = k+1;
                            BEGEND(k) = (STIMULI(m)+(PREF(11)));
                            k = k+1;
                            BEGEND(k)= (STIMULI(m+1)-0.001);
                        end
                    end
                    k=k+1;
                    BEGEND(k) = (STIMULI(size(STIMULI,2))+(PREF(11))); %Ende der letzten Stimulation

                    % Schreibe Anfänge und Enden in verschiedene Arrays
                    TEMP = reshape (BEGEND,2,[]);
                    BEG = TEMP(1,:);
                    END = TEMP(2,:);
                    stimulidata = true;

                    %Überprüfe ob der letzte detektierte Stimulus zu nah am Ende liegt
                    if (T(size(T,2))-END(size(END,2))<= 0.6)
                        M((int32(BEG(size(BEG,2))*SaRa)):(size(M,1)),:) = 0;
                        BEG = BEG(1:(size(BEG,2)-1));
                        END = END(1:(size(END,2)-1));
                    end

                    %Artefaktentfernung
                    stTm = int32(END*SaRa);   % definiert die Punkte, an denen die Artefakte sind
                    samplTmMs=1/SaRa*1000;    % Abtastrate in ms
                    tmPre=200;                % Berücksichtigte Zeit vor dem Stimulus (up to 200)
                    tmPost=600;               % Berücksichtigte Zeit nach dem Stimulus (up to 800 - also 4000Werte)
                    stRemoval = 0;            % Zeitpunkt an dem der stimulus artefact entfernt wird  
                    ptPre=round(tmPre/samplTmMs);
                    ptPost=round(tmPost/samplTmMs);
                    
                    for ch=1:60                % mache die Berechnung für alle Kanäle eigentlich bis 60
                        time=(0:length(M(:,ch))-1)*samplTmMs;
                        signal=[];
                            for i=1:length(stTm) 
                             signal=[signal; M(stTm(i)-ptPre:stTm(i)+ptPost,ch)'];
                            end
                        signalaver=mean(signal);
                        timePr=time(1:length(signal))-tmPre;
                        TimeStartCor=find(timePr>=stRemoval);
                        TimeStopCor=find(timePr>=25+stRemoval-1 );
                        TimeStartCor0=find(timePr>=7.5+stRemoval-1 );
                        TimeStopCor0=find(timePr>=100+stRemoval-1 );
                        PuntFinTolti=17.5/samplTmMs;
                        anaBin=1;
                        prova_fit=polyfit(time(TimeStartCor(1):anaBin:TimeStopCor(1)),signalaver(TimeStartCor(1):anaBin:TimeStopCor(1)),9);
                        prova_corr=polyval(prova_fit,time(TimeStartCor(1):TimeStopCor(1)-PuntFinTolti));
                        prova_fit=polyfit(time(TimeStartCor0(1):anaBin:TimeStopCor0(1)),signalaver(TimeStartCor0(1):anaBin:TimeStopCor0(1)),9);
                        prova_corr2=polyval(prova_fit,time(TimeStartCor0(1):TimeStopCor0(1)-PuntFinTolti));
                        signalCorr=signal;

                        %in signalCorr wird das korrigierte Array abgespeichert  
                        for i=1:length(stTm)
                              signalCorr(i,(TimeStartCor(1):TimeStopCor(1)-PuntFinTolti))=signal(i,(TimeStartCor(1):TimeStopCor(1)-PuntFinTolti))-prova_corr;
                              signalCorr(i,(TimeStartCor0(1):TimeStopCor0(1)-PuntFinTolti))=signal(i,(TimeStartCor0(1):TimeStopCor0(1)-PuntFinTolti))-prova_corr2;
                        end

                        %schreibe signal und signalCorr in andere Arrays falls der Kanal dem ausgewählten Kanal entspricht
                        if(ch==PREF(9))     
                            %0 sek ist bei 200/samplTmMs+1
                            %(END(1)-BEG(1))*SaRa Dauer der Stimulation
                            signal_draw = signal(1,:);
                            signalCorr_draw = signalCorr(1,:);
                            signalCorr_draw(((200/samplTmMs)+1-(END(1)-BEG(1))*SaRa):((200/samplTmMs)+1)) = 0;                                
                        end
                        waitbar_counter = waitbar_counter+waitbaradd;
                        waitbar(waitbar_counter);

                        %für jeden Kanal werden die alten Daten durch die neuen Daten an der richtigen Stelle des Array M ersetzt.
                        for i=1:length(stTm)
                              ins(i,:) = signalCorr(i,1001:length(signalCorr)); 
                              M(stTm(i):(stTm(i)+length(ins)-1),ch)=(ins(i,:))'; 
                        end 
                    end             
                end    
                     % Erst nach Beseitigung der Artefakte werden die Stimulipulse genullt.     
                     for n = 1:(length(BEG))
                              M((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
                     end         
                    %Speicher aufräumen
                    clear signal;
                    clear stTm;                 
        end
    end

    % --- Apply Filter Funktion (CN)---------------------------------------
    function Applyfilter(source,event) %#ok
       PREF(12) = get(findobj(gcf,'Tag','CELL_highpassFilterCheckbox'),'value');    % 50Hz Hochpass
       PREF(13) = get(findobj(gcf,'Tag','CELL_lowpassFilterCheckbox'),'value');     % Tiefpass
       PREF(14) = get(findobj(gcf,'Tag','CELL_ZeroOutCheckbox'),'value');           % Zero Out
            
       if (PREF(12) || PREF(13)) && PREF(14)== 0 %ein Filter oder beide Filter
           waitbaradd = 0.15;
       elseif PREF(14) && PREF(12) == 0 && PREF(13) == 0 %nur Zero Out
           waitbaradd = 0.01275;
       elseif (PREF(14) && PREF(12) && PREF(13)== 0) || (PREF(14) && PREF(13) && PREF(12) == 0) %Ein Filter und ZeroOut
           waitbaradd = 0.012;
       elseif PREF(12) && PREF(13) && PREF(14) %alle drei
           waitbaradd = 0.012;       
       end
           
       if PREF(14)
           ZeroOutcallfunction;
       else
           h_wait = waitbar(0,'Please Wait - busy...');
       end
       
       if PREF(12)
           highpassButtonCallback
       end
       
       if PREF(13)
           lowpassButtonCallback
       end 
       waitbar(1); close(h_wait);
       waitbar_counter=0;
       
       if stimulidata
             figure (mainWindow);
             set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Enable','on');
             set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','on');
             set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','on');
       else
           BEG = 0;
           END = 0;
       end  
        redrawdecide;
    end

    % --- El nullen - Popup-Menü für Elektrodenwahl (CN)-------------------
    function ELnullenCallback(source,event) %#ok<INUSD>
       allorone = 0;
       fh = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');   
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'String','the signal of the selected electrodes is clear for the entire recording time. More than one electrode have to be separated be space.');
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
       uicontrol('Parent',fh,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string','');
       uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[175 20 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELnullencallfunction);
       uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[20 20 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
    end

    % --- El nullen einlesen (CN)------------------------------------------
    function ELnullencallfunction(source,event) %#ok<INUSD>
         correctcheck = 1; 
         EL_Auswahl = get(findobj(gcf,'Tag','CELL_electrode'),'string');
         ELEKTRODEN = strread(EL_Auswahl) ;
         for n = 1:length(ELEKTRODEN)
             i = find(EL_NUMS==ELEKTRODEN(n)); %#ok
             if isempty(i)  %falls eine Elektrode ausgewählt wurde, die nicht mit aufgenommen wurde
                  correctcheck = 0; %#ok
                  msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                  uiwait;
                  return     
             end         
         end
         if correctcheck == 1
             close(gcbf)
             Elnullenfunction;
         end
    end

    % --- El nullen einlesen (CN)------------------------------------------
    function Allornonecallfunction(source,event) %#ok<INUSD>
        if allorone == 0
            set(findobj(gcf,'Tag','CELL_electrode'),'string','12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87');
            allorone = 1;     
        elseif allorone == 1
            set(findobj(gcf,'Tag','CELL_electrode'),'string','');
            allorone = 0;    
        end        
    end

    % --- El nullen (CN)---------------------------------------------------
    function Elnullenfunction(source,event) %#ok<INUSD>
      if rawcheck == 1
         for n = 1:length(ELEKTRODEN)
             i = find(EL_NUMS==ELEKTRODEN(n));
             M(:,i)=0;  %#ok
         end
      elseif spiketraincheck == 1
         for n = 1:length(ELEKTRODEN)
             i = find(EL_NUMS==ELEKTRODEN(n));
             SPIKES(:,i)=0;
             BURSTS(:,i)=0;
         end
      end
         redrawdecide
    end

    % --- Elektroden Invertieren - Popup-Menü für Elektrodenwahl (AD)------
    function invertButtonCallback(source,event) %#ok<INUSD>
       allorone = 0;
       fh2 = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');   
       uicontrol('Parent',fh2,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'String','the signal of the selected electrodes is inverted for the entire recording time. More than one electrode have to be separated be space.');
       uicontrol('Parent',fh2,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
       uicontrol('Parent',fh2,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string',EL_invert_Auswahl);
       uicontrol(fh2,'Style','PushButton','Units','Pixels','Position',[175 20 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELinvertcallfunction);
       uicontrol(fh2,'Style','PushButton','Units','Pixels','Position',[20 20 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
    end

    % --- El invertieren Elektrode einlesen (AD)---------------------------
    function ELinvertcallfunction(source,event) %#ok<INUSD>       
     correctcheck = 1;
     EL_invert_Auswahl = get(findobj(gcf,'Tag','CELL_electrode'),'string');
     INV_ELEKTRODEN = strread(EL_invert_Auswahl);  
     
     for n = 1:length(INV_ELEKTRODEN)
             i = find(EL_NUMS==INV_ELEKTRODEN(n)); %#ok
             if isempty(i)  %falls eine Elektrode ausgewählt wurde, die nicht mit aufgenommen wurde
                  correctcheck = 0; %#ok
                  msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                  uiwait;
                  return     
             end         
      end
      if correctcheck == 1
          close(gcbf)
          Elinvertfunction;
      end 
    end

    % --- El invertieren (AD)----------------------------------------------
    function Elinvertfunction(source,event) %#ok<INUSD>  
       for n = 1:length(INV_ELEKTRODEN)
           i = find(EL_NUMS==INV_ELEKTRODEN(n)); 
           if rawcheck == 1  
                M(:,i)=M(:,i)*(-1);
           end
       end  
       redrawdecide;
    end

    % --- smooth electrode signal ---------------------------------------------
    function smoothButtonCallback(source,event)
       allorone = 0;    
       fh3 = figure('Units','Pixels','Position',[350 400 300 280],'Name','select electrodes','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');   
       uicontrol('Parent',fh3,'style','text','units','Pixels','position', [20 155 265 100],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'String','the signal of the selected electrodes is smoothed for the entire recording time. More than one electrode have to be separated be space.');
       uicontrol('Parent',fh3,'style','text','units','Pixels','position', [20 120 80 20],'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Tag','CELL_electrodeLabel','String','electrode');
       uicontrol('Parent',fh3,'style','edit','units','Pixels','position', [20 100 260 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','CELL_electrode','string','');
       uicontrol(fh3,'Style','PushButton','Units','Pixels','Position',[175 10 110 50],'String','apply','ToolTipString','clears the signals of selected electrodes now','CallBack',@ELsmoothcallfunction);
       uicontrol(fh3,'Style','PushButton','Units','Pixels','Position',[20 10 110 50],'String','all or none','ToolTipString','clears the signals of selected electrodes now','CallBack',@Allornonecallfunction);
       uicontrol('Parent',fh3,'Style', 'text','Position', [20 65 90 21],'HorizontalAlignment','left','String','Smoothing Nr.:','Enable','on','FontSize',9,'BackgroundColor',[0.8 0.8 0.8]);
       uicontrol ('Parent',fh3,'Units','Pixels','Position', [110 68 20 21],'Tag','smooth_Nr','HorizontalAlignment','right','FontSize',8,'Enable','on','Value',1,'String',1,'Style','edit');
    end

% --- smooth electrode signal ---------------------------------------------
    function ELsmoothcallfunction(source,event)
        
        correctcheck = 1;
        EL_smooth_choice = get(findobj(gcf,'Tag','CELL_electrode'),'string');
        Smooth_electrodes = strread(EL_smooth_choice);  
        
        for n = 1:length(Smooth_electrodes)
             i = find(EL_NUMS==Smooth_electrodes(n)); %#ok
             if isempty(i)  %falls eine Elektrode ausgewählt wurde, die nicht mit aufgenommen wurde
                  correctcheck = 0; %#ok
                  msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                  uiwait;
                  return     
             end         
      end
      if correctcheck == 1
          close(gcbf)
          Elsmoothfunction(Smooth_electrodes);
      end 
     
        
    end

 % --- El smoothing (AD)----------------------------------------------
    function Elsmoothfunction(Smooth_electrodes,event) %#ok<INUSD>  
       smooth_Nr = str2double(get(findobj(gcf,'Tag','smooth_Nr'),'string'));
       for n = 1:length(Smooth_electrodes)
           i = find(EL_NUMS==Smooth_electrodes(n)); 
           if rawcheck == 1 
              for ii = 1:smooth_Nr
                  M(:,i)= smooth(M(:,i));
              end
           end
       end  
       redrawdecide;
    end

% --- preprocessing empty ---------------------------------------------
    function preprocessingempty1Callback(~,~) 
           
        msgbox('Kommt bald ;)','Out of order');    

    end
  
    % --- Spike Overlay (FS) ----------------------------------------------
    function SpkOverlay(~,~)
        
        Elektrode = 1; %Gewählte Elektrode
        OverlayZoom = []; %Merkt sich für LockView den eingestellten Zoom des Overlaygraphen
        SingleZoom = []; %Merkt sich für LockView den eingestellten Zoom des SingleSpikegraphen
        Overlay = []; %Handle des Overlayplots (für LockView)
        Single = []; %Handle des SingleSpikeplots (für LockView)
        ZeroSingle = []; %Merkt sich, ob ein Nullgraph angezeigt wird (für Overlaygraphen)
        ZeroOverlay = []; %Merkt sich, ob ein Nullgraph angezeigt wird (für SingleSpikegraphen)
        
        SPIKESCOPY = SPIKES; %Erstellt Kopie der Spikedaten
        SPIKESDEL = zeros(size(SPIKES)); %Enthält Daten der ausgeblendeten Spikes
        SPIKESCUT = zeros(size(SPIKES,1),1); %Enthält Daten der Spikes, die nicht dargestellt werden können, weil das Zeitfenster über die Messung hinaus läuft
        
        Laenge = []; %Länge des Betrachtungsfensters für den Overlaygraphen in Sekunden
        Vorlauf = []; %Beginn des Betrachtungsfensters für den Overlaygraphen vor Spikedetektion in Sekunden
        OldSpike = 1;  %Behält sich die Nummer des zuletzt angezeigten SingleSpikes, damit beim Wechsel der Elektrode die Nummer des angezeigten Single-Spikes gleich bleibt (Bsp: Trotz durchschalten der Elektroden wird stets der 7. Spike angezeigt. Kein Rücksprung auf Spike 1)
        
        CharTime = []; %Enhält charakteristische Spikezeitstrukturen (Dimensionen: 1.Elektrode,2.Spike,3.Werte(1=1.Zeit,2=2.Zeit,3=1.Amplitude,4=2.Amplitude)
        DifTime = []; %Enthält Differenzen der SpikeZeitpunkte (also T2-T1) (Dimensionen: 1.Elektrode,2.Spike,3.Werte der Punkte 1-5)
        MinMax = []; %Enthält Zeitpunkte des Minimum und der beiliegenden Maxima jedes einzelnen Spikes (sofern diese einmal angewählt wurden) (Dimensionen: 1.Elektrode,2.Spike,3.Punkte(Max1,Min,Max2),4.Werte(1.X-Wert,2.Y-Wert))
        
        %Erstellen der UI-Paneele (Rahmen und Fenster)
        %Hauptfenster
        SpkOverlayPopup = figure('Name','Spike Overlay','NumberTitle','off','Position',[100 20 1000 740],'Toolbar','none','Resize','off');
        %Button-Bereich rechts neben Overlay-Grap
        ControlPanel=uipanel('Parent',SpkOverlayPopup,'Units','pixels','Position',[520 310 450 230],'BackgroundColor',[0.8 0.8 0.8]);
        %Rahmen,der Overlay-Graph und Single-Spike-Graph trennt
        uipanel('Parent',SpkOverlayPopup,'Units','pixels','Position',[20 286 960 5],'BackgroundColor',[0.8 0.8 0.8]);
        %Button-Bereich rechts neben Single-Spike-Graph
        SpikePanel=uipanel('Parent',SpkOverlayPopup,'Units','pixels','Position',[520 20 450 250],'BackgroundColor',[0.8 0.8 0.8]);
        
        %Sonstige UI-Elemente
        uicontrol(SpkOverlayPopup,'Style', 'text','Position', [60 535 125 25],'String','Overlay-Graph:' ,'FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(SpkOverlayPopup,'Position', [50 500 15 15],'String', '+','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8],'callback',@Zoom);
        %Elektrodenauswahl-Buttons
        uicontrol('Parent',SpkOverlayPopup,'Style', 'text','Position', [225 535 100 25],'String', 'Electrode: ','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [325 537 60 25],'Tag','Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu','callback',@SpkCount);
        LockViewOverlay = uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [400 538 70 25],'Tag','LockViewSingle','String','Lock view','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@LockOverlay);
        
        %Skalierungs-Button in ControlPanel
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [5 190 100 25],'String', 'y-Axis Scale','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        Skala = uicontrol('Parent',ControlPanel,'Style','popupmenu','Units','Pixels','Position', [105 193 75 25],'String',['  50 uV';' 100 uV';' 200 uV';' 500 uV';'1000 uV'],'Tag','Skala','HorizontalAlignment','right','FontSize',8,'Value',get(scalehandle,'value'),'callback',@DrawBoth);
        %Zeitfenster-Buttons in ControlPanel
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [5 145 75 25],'String', 'Range: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [77 149 50 25],'String',500,'Tag','Laenge','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit','callback',@DrawBoth);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [127 145 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [190 145 75 25],'String', 'Buffer:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [262 149 50 25],'String',100,'Tag','Vorlauf','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit','callback',@DrawBoth);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [312 145 25 25],'String', 'ms','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        %Spikeauswahl-Buttons in ControlPanel
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [5 90 125 25],'String', 'Spike selection:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Position', [15 65 60 25],'String', 'Select','FontSize',8,'callback',@Select);
        uicontrol('Parent',ControlPanel,'Position', [100 65 60 25],'String', 'Del','FontSize',8,'callback',@SpikeDel);
        uicontrol('Parent',ControlPanel,'Position', [165 65 60 25],'String', 'Add','FontSize',8,'callback',@SpikeAdd);
        
        uicontrol('Parent',ControlPanel,'Units','pixels','Position',[15 20 60 25],'Tag','Reset','String','Reset','FontSize',8,'BackgroundColor',[0.8 0.8 0.8],'Callback',@Reset);
        uicontrol('Parent',ControlPanel,'Units','pixels','Position',[132 20 60 25],'Tag','Clear','String','Clear','FontSize',8,'BackgroundColor',[0.8 0.8 0.8],'Callback',@Clear);
        
        %SingleSpike-Bereich
        uicontrol(SpkOverlayPopup,'Style', 'text','Position', [60 230 150 25],'String','SingleSpike-Graph:' ,'FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(SpkOverlayPopup,'Position', [50 200 15 15],'String', '+','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8],'callback',@Zoom);
        %Spikeauswahl-Buttons
        uicontrol('Parent',SpkOverlayPopup,'Style', 'text','Position', [260 230 65 25],'String', 'Spike: ','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        Spikeauswahl = uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [325 232 60 25],'Tag','Spikeauswahl','FontSize',8,'String','bla','Value',1,'Style','popupmenu','callback',@DrawSingleSpike);        
        LockViewSingle = uicontrol('Parent',SpkOverlayPopup,'Units','Pixels','Position', [400 233 70 25],'Tag','LockViewSingle','String','Lock view','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@LockSingle);
        
        %SpikePanel-Bereich        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [10 210 100 25],'String', 'Local extrema:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [210 215 40 25],'String', 'auto','FontSize',10,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [200 193 65 25],'Tag','MinMaxAuto','FontSize',8,'String','Autodetect','callback',@AutoMinMax);
        MinMaxShow = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150 193 15 25],'String','','Tag','MinMaxShow','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@DrawSingleSpike);
        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [140 218 30 15],'String', 'Show','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [335 215 45 25],'String', 'manual','FontSize',10,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol  ('Parent',SpikePanel,'Units','Pixels','Position', [280 193 50 25],'Tag','Max1','FontSize',8,'String','Max','callback',@Max1Det);
        uicontrol  ('Parent',SpikePanel,'Units','Pixels','Position', [335 193 50 25],'Tag','Min','FontSize',8,'String','Min','callback',@MinDet);
        uicontrol  ('Parent',SpikePanel,'Units','Pixels','Position', [390 193 50 25],'Tag','Max2','FontSize',8,'String','Max','callback',@Max2Det);
        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position',  [10 150 90 25],'String', 'Char periods:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);        
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [140 150 30 25],'String', 'Show','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [320 150 30 25],'String', 'Mean','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SpikePanel,'Style', 'text','Position', [390 150 30 25],'String', 'Std','BackgroundColor',[0.8 0.8 0.8]);

        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [35 191 85 25],'Tag','MinMaxPeriod','FontSize',8,'String','Set Period 1+2','callback',@MaxMinMaxPeriod);        
        
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [15 70 60 25],'Tag','TimeMeasure','FontSize',8,'String','Select','callback',@Select);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90 130 60 25],'Tag','Period1','FontSize',8,'String','Period 1','callback',@Period1);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90 100 60 25],'Tag','Period2','FontSize',8,'String','Period 2','callback',@Period2);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90  70 60 25],'Tag','Period3','FontSize',8,'String','Period 3','callback',@Period3);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90  40 60 25],'Tag','Period3','FontSize',8,'String','Period 4','callback',@Period4);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [90  10 60 25],'Tag','Period3','FontSize',8,'String','Period 5','callback',@Period5);
                
        Period1Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150 130 15 25],'String','','Tag','Show1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@Show1);
        Period2Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150 100 15 25],'String','','Tag','Show2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@Show2);
        Period3Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150  70 15 25],'String','','Tag','Show3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@Show3);
        Period4Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150  40 15 25],'String','','Tag','Show4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@Show4);
        Period5Show = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [150  10 15 25],'String','','Tag','Show5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8],'callback',@Show5);

        Period1panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170 130 60 25],'String','','Tag','Time1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170 100 60 25],'String','','Tag','Time2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170  70 60 25],'String','','Tag','Time3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170  40 60 25],'String','','Tag','Time4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5panel = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [170  10 60 25],'String','','Tag','Time5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [235 135 14 14],'Tag','ClearPeriod1','String','x','BackgroundColor',[0.8 0.8 0.8],'callback',@ClearPeriod1);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [235 105 14 14],'Tag','ClearPeriod2','String','x','BackgroundColor',[0.8 0.8 0.8],'callback',@ClearPeriod2);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [235  75 14 14],'Tag','ClearPeriod3','String','x','BackgroundColor',[0.8 0.8 0.8],'callback',@ClearPeriod3);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [235  45 14 14],'Tag','ClearPeriod3','String','x','BackgroundColor',[0.8 0.8 0.8],'callback',@ClearPeriod4);
        uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [235  15 14 14],'Tag','ClearPeriod3','String','x','BackgroundColor',[0.8 0.8 0.8],'callback',@ClearPeriod5);

        
        Period1Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 130 60 25],'String','','Tag','Mid1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305 100 60 25],'String','','Tag','Mid2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305  70 60 25],'String','','Tag','Mid3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305  40 60 25],'String','','Tag','Mid4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5Mid = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [305  10 60 25],'String','','Tag','Mid5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        Period1Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 130 60 25],'String','','Tag','Std1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period2Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375 100 60 25],'String','','Tag','Std2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period3Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375  70 60 25],'String','','Tag','Std3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period4Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375  40 60 25],'String','','Tag','Std4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        Period5Std = uicontrol ('Parent',SpikePanel,'Units','Pixels','Position', [375  10 60 25],'String','','Tag','Std5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        
        %Funktion zum Erstellen der Spike-Auswahl-Einträge
        SpkCount;
        %DrawSingleSpike;
        
        
        %Zeichnet den Overlay-Graphen
        function DrawOverlay(~,~)
            
            
            Laenge = str2double(get(findobj(gcf,'Tag','Laenge'),'string'))/1000; %Länge des Betrachtungsfensters in s
            Vorlauf = str2double(get(findobj(gcf,'Tag','Vorlauf'),'string'))/1000; %Beginn des Betrachtungsfensters vor Spikedetektion
            Elektrode=get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');    %Elektrode, die ausgewertet werden soll.
            
            
            %Erstellen des Datenarrays für den Overlay
            temp = []; %Erstellung wird benötigt, um ggf später ein isempty feststellen zu können
            SPIKESCUT = zeros(size(SPIKES,1),1);
            for k=1:size(SPIKESCOPY,1)
                if SPIKES(k,Elektrode)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                        SPIKES(k,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(M,1)
                    if SPIKESCOPY(k,Elektrode) > 0
                        temp(:,k) = M(SPIKESCOPY(k,Elektrode)*SaRa+1-(Vorlauf)*SaRa:SPIKESCOPY(k,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Elektrode); 
                    else
                        temp(1:SaRa*Laenge,k) = 0; 
                    end
                else
                    if SPIKESCOPY(k,Elektrode) ~= 0
                        SPIKESCUT(k) = SPIKESCOPY(k,Elektrode);
                    else
                        SPIKESCUT(k) = SPIKESDEL(k,Elektrode);
                    end
                end
            end
            clear k;
            
            
            %Orientiert sich bei der Skalierung am Hauptprogramm
            Scale = get(Skala,'value');   % Y-Skalierung festlegen
            switch Scale
                case 1, Scale = 50;
                case 2, Scale = 100;
                case 3, Scale = 200;
                case 4, Scale = 500;
                case 5, Scale = 1000;
            end
            
            
            %Erstellen des Original-Graphen
            uicontrol(SpkOverlayPopup,'Style', 'text','Position', [60 710 100 25],'String', ['Electrode: ' num2str(EL_NUMS(get(findobj(gcf,'Tag','Elektrodenauswahl'),'value')))],'FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
            subplot('Position',[0.1 0.8 0.87 0.15]);
            plot (linspace(0,size(M,1)/SaRa,size(M,1)),M(:,Elektrode)','Tag','');

            %get(findobj(gcf,'Tag','Mau'));
            xlabel ('time / s');
            ylabel ('voltage / µV');                        

            
            %Einfügen der Spikemarkierungen
            SP = nonzeros(SPIKESCOPY(:,Elektrode));                            % (grüne Dreiecke für aktivierte Spikes)
            if isempty(SP)==0
                y_axis = ones(length(SP),1).*Scale.*.92;                       %Skalierung ist hier 100
                line ('Xdata',SP,'Ydata', y_axis,'Tag','Green',...
                    'LineStyle','none','Marker','v',...
                    'MarkerFaceColor','green','MarkerSize',9);
            end
            
            SP = nonzeros(SPIKESDEL(:,Elektrode));                            % (rote Dreiecke für deaktivierte Spikes)
            if isempty(SP)==0
                y_axis = ones(length(SP),1).*Scale.*.92;                       %Skalierung ist hier 100
                line ('Xdata',SP,'Ydata', y_axis,'Tag','Red',...
                    'LineStyle','none','Marker','v',...
                    'MarkerFaceColor','red','MarkerSize',9);
            end
            
            SP = nonzeros(SPIKESCUT);                            % (graue Dreiecke für inaktive Spikes, die nicht dargestellt werden können)
            if isempty(SP)==0
                y_axis = ones(length(SP),1).*Scale.*.92;                       %Skalierung ist hier 100
                line ('Xdata',SP,'Ydata', y_axis,'Tag','Grey',...
                    'LineStyle','none','Marker','v',...
                    'MarkerFaceColor',[0.8 0.8 0.8],'MarkerSize',9);
            end
            
            
            xlim('auto');
            ylim([-Scale-50 Scale]);
            clear SP;
            
            
            %Erstellen des Overlay-Graphen
            subplot('Position',[0.1 0.455 0.37 0.26]);
            
            if isempty(temp)
                plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-');   %Nullgraph, falls keine SPIKESCOPY vorhanden sind
                axis([-Vorlauf Laenge-Vorlauf -Scale Scale]); %Ändert die Skala der X-Achse, so dass das Minimum (SPIKES-Wert) auf 0 liegt
                set(LockViewOverlay,'Enable','off');
                ZeroOverlay = true;
            else
                %Check, ob Zoom beibehalten werden soll. Wenn ja, wird Einstellung gespeichert
                LockOverlay;                
                for k=1:size(temp,2)
                    Overlay = plot(linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge),temp(:,k),'Tag',num2str(k));
                    hold all
                end
                ZeroOverlay = false;
                if isempty(OverlayZoom) == 0 %Check, ob LockView benutzt werden soll
                    SetView(Overlay,OverlayZoom)
                else
                    axis([-Vorlauf Laenge-Vorlauf -Scale Scale]);
                end
            end
            
            hold off
            xlabel ('time / s');
            ylabel ('voltage / µV');
        end
        
        
        %Zeichnet Single-Spike-Graphen
        function DrawSingleSpike (~,~)
                        
            subplot('Position',[0.1 0.1 0.37 0.2]);
            delete(findobj(0,'Tag','Yellow'));   %Löscht alte Spikemarkierungen (in gelb)
            
            %Orientiert sich bei der Skalierung am Hauptprogramm
            Scale = get(Skala,'value');   % Y-Skalierung festlegen
            switch Scale
                case 1, Scale = 50;
                case 2, Scale = 100;
                case 3, Scale = 200;
                case 4, Scale = 500;
                case 5, Scale = 1000;
            end
            
            %Setzt Werte in die bestimmten charakteristischen SpikeZeitpunkte (5 Durchläufe, da 5 Fenster)
            %Speichert zudem die Differenzen zwischen den Punkten in DifTime
            %Berechnet anschließend Mittelwert und Standartabweichungen der Zeitdifferenzen und fügt diese in die vorhergesehenen Felder ein
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            %Fenster 1
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 4 &&...
                    max(CharTime(Elektrode,Spike,1),CharTime(Elektrode,Spike,2)) > 0
                DifTime(Elektrode,Spike,1)=abs(CharTime(Elektrode,Spike,2)-CharTime(Elektrode,Spike,1));
                set(Period1panel,'string',DifTime(Elektrode,Spike,1)*1000);                
            else
                set(Period1panel,'string',[])
                DifTime(Elektrode,Spike,1)=0;
            end
            set(Period1Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,1)))));
            set(Period1Std,'string',std(nonzeros(DifTime(:,:,1)))*1000);
            %Fenster 2
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 8 &&...
                    max(CharTime(Elektrode,Spike,5),CharTime(Elektrode,Spike,6)) > 0
                DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,6)-CharTime(Elektrode,Spike,5));
                set(Period2panel,'string',DifTime(Elektrode,Spike,2)*1000);
            else
                set(Period2panel,'string',[])
                DifTime(Elektrode,Spike,2)=0;
            end
            set(Period2Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,2)))));
            set(Period2Std,'string',std(nonzeros(DifTime(:,:,2)))*1000);
            %Fenster 3
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 12 &&...
                    max(CharTime(Elektrode,Spike,9),CharTime(Elektrode,Spike,10)) > 0
                DifTime(Elektrode,Spike,3)=abs(CharTime(Elektrode,Spike,10)-CharTime(Elektrode,Spike,9));
                set(Period3panel,'string',DifTime(Elektrode,Spike,3)*1000);
            else
                set(Period3panel,'string',[])
                DifTime(Elektrode,Spike,3)=0;
            end
            set(Period3Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,3)))));
            set(Period3Std,'string',std(nonzeros(DifTime(:,:,3)))*1000);
            %Fenster 4
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 16 &&...
                    max(CharTime(Elektrode,Spike,13),CharTime(Elektrode,Spike,14)) > 0
                DifTime(Elektrode,Spike,4) = abs(CharTime(Elektrode,Spike,14)-CharTime(Elektrode,Spike,13));
                set(Period4panel,'string',DifTime(Elektrode,Spike,4)*1000);
            else
                set(Period4panel,'string',[])
                DifTime(Elektrode,Spike,4) = 0;
            end
            set(Period4Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,4)))));
            set(Period4Std,'string',std(nonzeros(DifTime(:,:,4)))*1000);
            %Fenster 5
            if size(CharTime,1) >= Elektrode && size(CharTime,2) >= Spike && size(CharTime,3) >= 20 &&...
                    max(CharTime(Elektrode,Spike,17),CharTime(Elektrode,Spike,18)) > 0
                DifTime(Elektrode,Spike,5) = abs(CharTime(Elektrode,Spike,18)-CharTime(Elektrode,Spike,17));
                set(Period5panel,'string',DifTime(Elektrode,Spike,5)*1000);              
            else
                set(Period5panel,'string',[])
                DifTime(Elektrode,Spike,5) = 0;
            end
            set(Period5Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,5)))));
            set(Period5Std,'string',std(nonzeros(DifTime(:,:,5)))*1000);
            
            
            
            %Check, ob überhaupt Spikes detektiert wurden
            if isempty(get(findobj(gcf,'Tag','Spikeauswahl'),'string'))
                plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-');   %Nullgraph, falls keine SPIKESCOPY vorhanden sind (ist der Fall, wenn keine Spikes detektiert wurden)
                set(LockViewSingle,'Enable','off');
                ZeroSingle = true;
            else
                Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
                if SPIKESCUT(Spike) > 0 %Check, ob in SPIKESCUT verzeichnet ist, dass der Spike inaktiv geschaltet ist
                    plot(linspace(-Vorlauf,Laenge-Vorlauf,5),linspace(-Vorlauf,Laenge-Vorlauf,5)*0,'-','Tag','Single');   %Nullgraph, falls Zeitfenster über Messzeitraum ragt
                    xlabel ('time / s');
                    ylabel ('voltage / µV');
                    msgbox ('Spike kann nicht angezeigt werden, da Betrachtungsfenster über Messzeitraum reicht.','Error','error');
                    set(LockViewSingle,'Enable','off');
                    ZeroSingle = true;
                else
                    %Check, ob Zoom beibehalten werden soll. Wenn ja, wird Einstellung gespeichert
                    LockSingle;
                    
                    SP = M(SPIKES(Spike,Elektrode)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,Elektrode)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,Elektrode);
                    Single = plot(linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge),SP,'Tag','Single');
                    ZeroSingle = false;
                    OldSpike = get(Spikeauswahl,'Value');   %Merkt sich, welcher Spike ausgewählt wurde, damit die Nummer des angezeigten SingleSpikes beim Wechsel der Elektroden beibehalten wird
                    xlabel ('time / s');
                    ylabel ('voltage / µV');
                    axis([-Vorlauf Laenge-Vorlauf -Scale-50 Scale]);
                    
                    %Check, ob ViewLock aktiviert ist (Wenn ja ist ein Wert
                    %in SingleZoom gespeichert
                    if isempty(SingleZoom) == 0
                        SetView(Single, SingleZoom);
                    end
                    
                    %Anzeige, des Spikezeitpunkts und den nächsten Maxima (je eines davor und danach)
                    if size(MinMax,1) < Elektrode || size(MinMax,2) < Spike || ...  %Notfalls noch Dimensionen 3 und 4 checken
                            MinMax(Elektrode,Spike, 1, 1) == 0 && MinMax(Elektrode,Spike, 2, 1) == 0 && MinMax(Elektrode,Spike, 3, 1) == 0
                        
                        [MinMax(Elektrode,Spike,2,2),MinMax(Elektrode,Spike,2,1)] = min(SP); %Minimum
                        %1. Maximum (Sucht im Idealfall nur 25ms vor Minimum, aber muss checken, ob das File so lang ist)
                        if MinMax(Elektrode,Spike,2,1)-SaRa*0.025 > 0 %0.025 entsprechen 25ms (ebenso in nächster Zeile)
                            [MinMax(Elektrode,Spike,1,2),MinMax(Elektrode,Spike,1,1)] = max(SP(MinMax(Elektrode,Spike,2,1)-SaRa*0.025:MinMax(Elektrode,Spike,2,1))); %1.Maximum (Sucht von Minimum-25ms bis Minimum)
                            MinMax(Elektrode,Spike,1,1) = MinMax(Elektrode,Spike,1,1) + MinMax(Elektrode,Spike,2,1)-SaRa*0.025;
                        else
                            [MinMax(Elektrode,Spike,1,2),MinMax(Elektrode,Spike,1,1)] = max(SP(1:MinMax(Elektrode,Spike,2,1))); %1.Maximum (Sucht von 0 bis Minimum)
                        end
                        %2. Maximum (Sucht im Idealfall nur 50ms nach Minimum, aber muss checken, ob das File so lang ist)
                        if MinMax(Elektrode,Spike,2,1)+SaRa*0.05 <= size(SP,1) %0.05 entsprechen 50ms (ebenso in nächster Zeile)
                            [MinMax(Elektrode,Spike,3,2),MinMax(Elektrode,Spike,3,1)] = max(SP(MinMax(Elektrode,Spike,2,1):MinMax(Elektrode,Spike,2,1)+SaRa*0.05)); %2.Maximum
                        else
                            [MinMax(Elektrode,Spike,3,2),MinMax(Elektrode,Spike,3,1)] = max(SP(MinMax(Elektrode,Spike,2,1):end)); %2.Maximum
                        end
                        a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                        
                        MinMax(Elektrode,Spike,3,1) = a(MinMax(Elektrode,Spike,3,1)+MinMax(Elektrode,Spike,2,1)-1);
                        MinMax(Elektrode,Spike,1,1) = a(MinMax(Elektrode,Spike,1,1));
                        MinMax(Elektrode,Spike,2,1) =  a(MinMax(Elektrode,Spike,2,1));
                        clear a;
                    end
                    
                    if get(MinMaxShow,'Value')
                        line ('Xdata',MinMax(Elektrode,Spike,1,1),'Ydata', MinMax(Elektrode,Spike,1,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Elektrode,Spike,2,1),'Ydata', MinMax(Elektrode,Spike,2,2),'Tag','Single',...
                            'LineStyle','none','Marker','^',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                        line ('Xdata',MinMax(Elektrode,Spike,3,1),'Ydata', MinMax(Elektrode,Spike,3,2),'Tag','Single',...
                            'LineStyle','none','Marker','v',...
                            'MarkerFaceColor','magenta','MarkerSize',9);
                    end
                    
                    Show12345;  %Check, ob charaktistische, zuvor vom User bestimmte SpikeZeitpunkte angezeigt werden sollen
                    
                    subplot('Position',[0.1 0.8 0.87 0.15]); %Einzeichnen eines gelben Dreiecks, welches den aktuell gewählten Single-Spike anzeigt
                    SP = SPIKES(Spike,Elektrode);
                    y_axis = ones(length(SP),1).*(-Scale).*.92;
                    line ('Xdata',SP,'Ydata', y_axis,'Tag','Yellow',...
                        'LineStyle','none','Marker','^',...
                        'MarkerFaceColor','yellow','MarkerSize',9);
                end
            end
        end
        
        
        %Ruft beide Zeichenfunktionen auf
        function DrawBoth (~,~)
            DrawOverlay;
            DrawSingleSpike;
        end
        
        
        function LockOverlay (~,~)
            set(LockViewOverlay,'Enable','on');
            if get(LockViewOverlay,'value') && ZeroOverlay == false
                OverlayZoom = get(get(Overlay,'Parent'));
            elseif ZeroOverlay == false
                OverlayZoom = [];
            end
        end        
        function LockSingle (~,~)            
            set(LockViewSingle,'Enable','on');
            if get(LockViewSingle,'value') && ZeroSingle == false
                SingleZoom = get(get(Single,'Parent'));
            elseif ZeroSingle == false
                SingleZoom = [];
            end
        end
                
        
        function SetView (Plot,ZoomMode)
            Plot = get(Plot,'Parent');                        
            set(Plot,'CameraPosition',ZoomMode.CameraPosition)
            set(Plot,'CameraPositionMode',ZoomMode.CameraPositionMode)
            set(Plot,'CameraTarget',ZoomMode.CameraTarget)
            set(Plot,'CameraTargetMode',ZoomMode.CameraTargetMode)
            set(Plot,'DataAspectRatio',ZoomMode.DataAspectRatio)
            set(Plot,'DataAspectRatioMode',ZoomMode.DataAspectRatioMode)
            set(Plot,'XLim',ZoomMode.XLim)
            set(Plot,'XLimMode',ZoomMode.XLimMode)
            set(Plot,'XTick',ZoomMode.XTick)
            set(Plot,'XTickMode',ZoomMode.XTickMode)
            set(Plot,'YLim',ZoomMode.YLim)
            set(Plot,'YTick',ZoomMode.YTick)
            set(Plot,'YTickMode',ZoomMode.YTickMode)            
        end
        
        function AutoMinMax (~,~) %Setzt evtl. zuvor manuell belegte Werte des Minimum und der Maxima auf 0 zurück und lässt sie anschließend automatisch detektieren.
            %Check, ob überhaupt Spikes detektiert wurden
            if isempty(get(findobj(gcf,'Tag','Spikeauswahl'),'string'))
                %Keine Spikes detektiert
            else
                Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
                if SPIKESCUT(Spike) > 0 %Check, ob in SPIKESCUT verzeichnet ist, dass der Spike inaktiv geschaltet ist
                    %Spike inaktiv
                else
                    MinMax(Elektrode,Spike,1:3,1) = 0;
                    DrawSingleSpike;
                end
            end
        end
        
        
        %Manuelle Bestimmung der Minima und Maxima
        function Max1Det(~,~)
            [XValue,YValue,Spike] = Determination;
            if isempty(XValue) == 0
                MinMax(Elektrode,Spike,1,1) = XValue;
                MinMax(Elektrode,Spike,1,2) = YValue;
                DrawSingleSpike;
            end
        end
        function MinDet(~,~)
            [XValue,YValue,Spike] = Determination;
            if isempty(XValue) == 0
                MinMax(Elektrode,Spike,2,1) = XValue;
                MinMax(Elektrode,Spike,2,2) = YValue;
                DrawSingleSpike;
            end
        end
        function Max2Det(~,~)
            [XValue,YValue,Spike] = Determination;
            if isempty(XValue) == 0
                MinMax(Elektrode,Spike,3,1) = XValue;
                MinMax(Elektrode,Spike,3,2) = YValue;
                DrawSingleSpike;
            end
        end
        
        function [XValue,YValue,Spike] = Determination (~,~)
            XValue = [];
            YValue = [];
            Spike = [];
            %Check, ob überhaupt Spikes detektiert wurden
            if isempty(get(findobj(gcf,'Tag','Spikeauswahl'),'string'))
                %Keine Spikes vorhanden
            else
                Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
                if SPIKESCUT(Spike) > 0 %Check, ob in SPIKESCUT verzeichnet ist, dass der Spike inaktiv geschaltet ist
                    %Spike inaktiv
                else
                    dcm_obj = datacursormode(SpkOverlayPopup);
                    c_info = getCursorInfo(dcm_obj);
                    if isempty(c_info) == 0  && size(c_info,2) == 1  %Wenn genau 1 Datenpunkt ausgewählt wurden
                        XValue = c_info(1).Position(1);
                        YValue = c_info(1).Position(2);
                    end
                end
            end
        end
        
        
        
        
        function Clear(~,~)
            delete(findall(SpkOverlayPopup,'Type','hggroup','HandleVisibility','off'));
            zoom off;
        end
        
        function Zoom(~,~)
            zoom;
        end
        
        
        
        function Select(~,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            set(dcm_obj,'DisplayStyle','datatip',...
                'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineTag)
        end
        
        function SpikeDel(~,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            if isempty(c_info) == 0  %Wird nur ausgeführt, wenn vom User mindestens ein Datenpunkt ausgewählt wurde
                for i=1:size(c_info,2)   %Durchläuft einzeln alle vom User ausgewählten Datenpunkte
                    Spike = get(c_info(i).Target,'Tag');
                    if isempty(Spike)== 0 && strcmp(Spike,'Red') == 0  && strcmp(Spike,'Grey') == 0  %Überprüfung, ob Graph eine Bezeichnung hat
                        %Falls Spikemarkierung (grünes Dreieck) gewählt wurde, muss Spikenummer in SPIKES gefunden werden(Vergleich X-Wert)
                        if strcmp(num2str(Spike),'Green') == 1
                            [Spike,~] = find(SPIKES(:,Elektrode)==c_info(i).Position(1));
                        else
                            Spike = str2double(Spike);
                        end
                        if SPIKESCOPY(Spike,Elektrode) ~= 0
                            SPIKESDEL(Spike,Elektrode) = SPIKESCOPY(Spike,Elektrode);
                            SPIKESCOPY(Spike, Elektrode) = 0;
                        end
                    end
                end
                %Neuzeichnen der Graphen nach getaner Arbeit
                DrawBoth;
                clear Spike;
            end
            datacursormode off;
        end
        
        
        function SpikeAdd(~,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            if isempty(c_info) == 0  %Wird nur ausgeführt, wenn vom User mindestens ein Datenpunkt ausgewählt wurde
                for i=1:size(c_info,2)   %Durchläuft einzeln alle vom User ausgewählten Datenpunkte
                    Spike = get(c_info(i).Target,'Tag');
                    if isempty(Spike)== 0 && strcmp(Spike,'Green') == 0  && strcmp(Spike,'Grey') == 0  %Überprüfung, ob Graph eine Bezeichnung hat
                        %Falls Spikemarkierung (rotes Dreieck) gewählt wurde, muss Spikenummer in SPIKES gefunden werden(Vergleich X-Wert)
                        if strcmp(num2str(Spike),'Red') == 1
                            [Spike,~] = find(SPIKES(:,Elektrode)==c_info(i).Position(1));
                        else
                            Spike = str2double(Spike);
                        end
                        if SPIKESDEL(Spike,Elektrode) ~= 0
                            SPIKESDEL(Spike,Elektrode) = 0;
                            SPIKESCOPY(Spike, Elektrode) = SPIKES(Spike,Elektrode);
                        end
                    end
                end
                %Neuzeichnen der Graphen nach getaner Arbeit
                DrawBoth;
                clear Spike;
            end
            datacursormode off;
        end
        
        
        function Reset(~,~)
            SPIKESCOPY(:,Elektrode)= SPIKES (:,Elektrode);
            SPIKESDEL(:,Elektrode) = 0;
            DrawBoth;
            datacursormode off;
        end

        
        %Erstellt individuelle Tags, wenn Graphen angewählt werden. (z.B. "Spike 7" oder zeigt Zeit und Amplitude)
        function txt = LineTag (~,event_obj)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            %size(c_info,2)
            Spike = get(c_info(1).Target,'Tag');
            if isempty(Spike) || strncmp(Spike,'Points',6)
                pos = get(event_obj,'Position');
                txt = {['Time: ',sprintf('%.4f',pos(1))],...
                    ['Amplitude: ',num2str(pos(2))]};
            elseif strcmp(Spike,'Single')
                pos = get(event_obj,'Position');
                txt = {['Time: ',sprintf('%.4f',pos(1))],...
                    ['Amplitude: ',num2str(pos(2))]};
            elseif strcmp(Spike,'Green') == 1 || strcmp(Spike,'Red') || strcmp(Spike,'Grey') || strcmp(Spike,'Yellow')
                [Spike,~] = find(SPIKES(:,Elektrode)==c_info(1).Position(1));
                txt = {['Spike: ' num2str(Spike)]};
            else
                txt = {['Spike: ' Spike]};
            end
            
            
        end
        
        
        %Bestimmt die Anzahl der detektierten Spikes für die gewählte Elektrode
        function SpkCount (~,~)
            k = 1;
            SpkString='';
            Elektrode=get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');    %Elektrode, die ausgewertet werden soll.
            while k<=size(SPIKES,1) && SPIKES(k,Elektrode)>0
                %Schreibt 'Spk' und die dazugehörige Nummer in Array und füllt mit Leerzeichen stets auf die gleiche Länge auf
                SpkString(k,:) = (['Spk ' num2str(k) blanks(  length(num2str(size(SPIKES,1))) - length(num2str(k))   )]);
                k = k+1;
            end
            
            set (Spikeauswahl,'String',SpkString);
            
            if OldSpike < k
                set (Spikeauswahl,'Value',OldSpike);
            elseif k>1 %zusätzlicher Check, ob auch Spikes vorhanden sind. Sonst Spikeauswahl gelöscht
                set (Spikeauswahl,'Value',1);
                OldSpike = 1;
            end
            DrawBoth;
        end
        
        
        
        function Period1(~,~)
            Time = TimeMeasure(0);
            if isempty(Time) == 0
                set(Period1panel,'String',Time*1000)
                set(Period1Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,1)))));                
                set(Period1Std,'string',std(nonzeros(DifTime(:,:,1)))*1000);
            end
        end
        function Period2(~,~)
            Time = TimeMeasure(4);
            if isempty(Time) == 0
                set(Period2panel,'String',Time*1000)
                set(Period2Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,2)))));
                set(Period2Std,'string',std(nonzeros(DifTime(:,:,2)))*1000);
            end
        end
        function Period3(~,~)
            Time = TimeMeasure(8);
            if isempty(Time) == 0
                set(Period3panel,'String',Time*1000)
                set(Period3Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,3)))));
                set(Period3Std,'string',std(nonzeros(DifTime(:,:,3)))*1000);
            end
        end
        function Period4(~,~)
            Time = TimeMeasure(12);
            if isempty(Time) == 0
                set(Period4panel,'String',Time*1000)
                set(Period4Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,4)))));
                set(Period4Std,'string',std(nonzeros(DifTime(:,:,4)))*1000);
            end
        end
        function Period5(~,~)
            Time = TimeMeasure(16);
            if isempty(Time) == 0
                set(Period5panel,'String',Time*1000)
                set(Period5Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,5)))));
                set(Period5Std,'string',std(nonzeros(DifTime(:,:,5)))*1000);
            end
        end
        
        
        function TimePeriod = TimeMeasure (Nr,~)
            dcm_obj = datacursormode(SpkOverlayPopup);
            c_info = getCursorInfo(dcm_obj);
            if isempty(c_info) == 0  && ... %Wird nur ausgeführt, wenn vom User mindestens ein Datenpunkt ausgewählt wurde
                    SPIKESCUT(get(findobj(gcf,'Tag','Spikeauswahl'),'value')) == 0 %und kein inaktiver Spike gewählt wurde
                if size(c_info,2) == 2  %Wenn genau 2 Datenpunkte ausgewählt wurden
                    TimePeriod = abs(c_info(2).Position(1)-c_info(1).Position(1)); %Speichert Zeitspanne
                    DifTime(Elektrode,OldSpike,Nr/4+1) = TimePeriod;
                    CharTime(Elektrode,OldSpike,1+Nr) = c_info(1).Position(1);
                    CharTime(Elektrode,OldSpike,2+Nr) = c_info(2).Position(1);
                    CharTime(Elektrode,OldSpike,3+Nr) = c_info(1).Position(2);
                    CharTime(Elektrode,OldSpike,4+Nr) = c_info(2).Position(2);
                    Show12345;
                else
                    TimePeriod = [];
                end
            else
                TimePeriod = [];
            end
            delete(findall(SpkOverlayPopup,'Type','hggroup','HandleVisibility','off'));
        end
        
       
        %Funktionen zum löschen der einzelnen Perioden
        function ClearPeriod1 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');            
            ClearCurrentPeriod(0,Spike);
            set(Period1panel,'String',''); %Trägt Nullwert in Periodfenster ein
            DifTime(Elektrode,Spike,1)=abs(CharTime(Elektrode,Spike,2)-CharTime(Elektrode,Spike,1));            
            set(Period1Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,1))))); %Neuberechnung des Mittelwerts
            set(Period1Std,'string',std(nonzeros(DifTime(:,:,1)))*1000); %Neuberechnung der Standartabweichung
        end
        function ClearPeriod2 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(4,Spike);
            set(Period2panel,'String',''); %Trägt Nullwert in Periodfenster ein
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,6)-CharTime(Elektrode,Spike,5));        
            set(Period2Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,2))))); %Neuberechnung des Mittelwerts
            set(Period2Std,'string',std(nonzeros(DifTime(:,:,2)))*1000); %Neuberechnung der Standartabweichung
        end       
        function ClearPeriod3 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(8,Spike);
            set(Period3panel,'String',''); %Trägt Nullwert in Periodfenster ein
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,10)-CharTime(Elektrode,Spike,9));                
            set(Period3Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,3))))); %Neuberechnung des Mittelwerts
            set(Period3Std,'string',std(nonzeros(DifTime(:,:,3)))*1000); %Neuberechnung der Standartabweichung
        end
        function ClearPeriod4 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(12,Spike);
            set(Period4panel,'String',''); %Trägt Nullwert in Periodfenster ein
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,14)-CharTime(Elektrode,Spike,13));                
            set(Period4Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,4))))); %Neuberechnung des Mittelwerts
            set(Period4Std,'string',std(nonzeros(DifTime(:,:,4)))*1000); %Neuberechnung der Standartabweichung
        end
        function ClearPeriod5 (~,~)
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');
            ClearCurrentPeriod(16,Spike);
            set(Period5panel,'String',''); %Trägt Nullwert in Periodfenster ein
            DifTime(Elektrode,Spike,2)=abs(CharTime(Elektrode,Spike,18)-CharTime(Elektrode,Spike,17));                
            set(Period5Mid,'string',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,5))))); %Neuberechnung des Mittelwerts
            set(Period5Std,'string',std(nonzeros(DifTime(:,:,5)))*1000); %Neuberechnung der Standartabweichung
        end        
        function ClearCurrentPeriod (Nr,CSpike)
            CharTime(Elektrode,CSpike,1+Nr:4+Nr) = 0;
            Show12345;            
        end
        
        function Show1(~,~)
            DrawSpikePoints(0,get(Period1Show,'value'));
        end
        function Show2(~,~)
            DrawSpikePoints(4,get(Period2Show,'value'));
        end
        function Show3(~,~)
            DrawSpikePoints(8,get(Period3Show,'value'));
        end
        function Show4(~,~)
            DrawSpikePoints(12,get(Period4Show,'value'));
        end
        function Show5(~,~)
            DrawSpikePoints(16,get(Period5Show,'value'));
        end
        function Show12345(~,~)
            Show1;
            Show2;
            Show3;
            Show4;
            Show5;
        end
        function DrawSpikePoints (Nr,Check)
            %Zeigt zuvor gewählte Punkte an, falls beim Drücken des Period-Buttons keine Punkte gewählt wurden
            
            %Überprüft vorher, ob bereits Punkte eingetragen wurden, in
            %dem die größe der Chartime-Matrix überprüft wird und schaut, ob die Zeitwerte nicht beide 0 sind
            
            delete(findobj(0,'Tag',['Points' Nr]));   %Löscht alte Spikemarkierungen (in gelb)
            if Check
                
                %Überprüft vorher, ob bereits Punkte eingetragen wurden, in
                %dem die größe der Chartime-Matrix überprüft wird und schaut, ob die Zeitwerte nicht beide 0 sind.
                %Zudem wird geprüft, ob der momentane Spike nicht inaktiv ist.
                
                if size(CharTime,1) >= Elektrode && size(CharTime,2) >= OldSpike && size(CharTime,3) >= 4+Nr &&...
                        max(CharTime(Elektrode,OldSpike,1+Nr),CharTime(Elektrode,OldSpike,2+Nr)) > 0 &&...
                        SPIKESCUT(get(findobj(gcf,'Tag','Spikeauswahl'),'value')) == 0
                    
                    subplot('Position',[0.1 0.1 0.37 0.2]);
                    for i=1:2
                        SP = CharTime(Elektrode,OldSpike,i+Nr);
                        y_axis = CharTime(Elektrode,OldSpike,i+2+Nr);
                        
                        %Fallunterscheidung, ob Punkt größer oder kleiner
                        %Null ist. Dementsprechend zeigt der Pfeil von oben oder unten auf den Punkt
                        if y_axis < 0
                            line ('Xdata',SP,'Ydata', y_axis,'Tag',['Points' Nr],...
                                'LineStyle','none','Marker','^',...
                                'MarkerFaceColor',[round(-Nr^4*7/6144+Nr^3*29/768-Nr^2*149/384+Nr*61/48),round(-Nr^4/6144+Nr^3/256-Nr^2*11/384+Nr/16+1),round(Nr^4/3072-Nr^3*5/384+Nr^2*29/192-Nr*5/12)],'MarkerSize',7);          %Werte aus Color entstammen einer DGL, welche für die Werte von Nr (0,4,8,12,16) genau die Farben [0 1 0],[1 1 0],[0 1 1],[1 1 1] und [1 0 0] ergibt
                            %Werte müssen gerundert werden, da Matlab geringfügige Rechenfehler einbringt
                        else
                            line ('Xdata',SP,'Ydata', y_axis,'Tag',['Points' Nr],...
                                'LineStyle','none','Marker','v',...
                                'MarkerFaceColor',[round(-Nr^4*7/6144+Nr^3*29/768-Nr^2*149/384+Nr*61/48),round(-Nr^4/6144+Nr^3/256-Nr^2*11/384+Nr/16+1),round(Nr^4/3072-Nr^3*5/384+Nr^2*29/192-Nr*5/12)],'MarkerSize',7);
                        end
                    end
                end
            end   
        end
        
        
%         CharTime = []; %Enhält charakteristische Spikezeitstrukturen (Dimensionen: 1.Elektrode,2.Spike,3.Werte(1=1.Zeit,2=2.Zeit,3=1.Amplitude,4=2.Amplitude)
%         DifTime = []; %Enthält Differenzen der SpikeZeitpunkte (also T2-T1) (Dimensionen: 1.Elektrode,2.Spike,3.Werte der Punkte 1-5)
%         MinMax = []; %Enthält Zeitpunkte des Minimum und der beiliegenden Maxima jedes einzelnen Spikes (sofern diese einmal angewählt wurden) (Dimensionen: 1.Elektrode,2.Spike,3.Punkte(Max1,Min,Max2),4.Werte(1.X-Wert,2.Y-Wert))
        
        
        function MaxMinMaxPeriod (~,~)
            for EL=1:size(SPIKES,2)
                for Spike=1:size(nonzeros(SPIKES(:,EL)),1)                                                          

                    if size(MinMax,1) < EL || size(MinMax,2) < Spike || ...  %Notfalls noch Dimensionen 3 und 4 checken
                            MinMax(EL,Spike, 1, 1) == 0 && MinMax(EL,Spike, 2, 1) == 0 && MinMax(EL,Spike, 3, 1) == 0

                        if SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa > 0 && ...
                            SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1 <= size(M,1)
                        
                            %Kopiert Datenarray SP des einzelnen Spikes aus M
                            SP = M(SPIKES(Spike,EL)*SaRa+1-(Vorlauf)*SaRa:SPIKES(Spike,EL)*SaRa+1+(Laenge-Vorlauf)*SaRa-1,EL); 
                            
                            %Findet Maxima und Minimum in Datenarray SP und
                            %speichert sie in MinMax-Matrix
                            [MinMax(EL,Spike,2,2),MinMax(EL,Spike,2,1)] = min(SP); %Minimum
                            %1. Maximum (Sucht im Idealfall nur 25ms vor Minimum, aber muss checken, ob das File so lang ist)
                            if MinMax(EL,Spike,2,1)-SaRa*0.025 > 0 %0.025 entsprechen 25ms (ebenso in nächster Zeile)
                                [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(MinMax(EL,Spike,2,1)-SaRa*0.025:MinMax(EL,Spike,2,1))); %1.Maximum (Sucht von Minimum-25ms bis Minimum)
                                MinMax(EL,Spike,1,1) = MinMax(EL,Spike,1,1) + MinMax(EL,Spike,2,1)-SaRa*0.025;
                            else
                                [MinMax(EL,Spike,1,2),MinMax(EL,Spike,1,1)] = max(SP(1:MinMax(EL,Spike,2,1))); %1.Maximum (Sucht von 0 bis Minimum)
                            end
                            %2. Maximum (Sucht im Idealfall nur 50ms nach Minimum, aber muss checken, ob das File so lang ist)
                            if MinMax(EL,Spike,2,1)+SaRa*0.05 <= size(SP,1) %0.05 entsprechen 50ms (ebenso in nächster Zeile)
                                [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):MinMax(EL,Spike,2,1)+SaRa*0.05)); %2.Maximum
                            else
                                [MinMax(EL,Spike,3,2),MinMax(EL,Spike,3,1)] = max(SP(MinMax(EL,Spike,2,1):end)); %2.Maximum
                            end
                            a = linspace(-Vorlauf,Laenge-Vorlauf,SaRa*Laenge);
                            
                            MinMax(EL,Spike,3,1) = a(MinMax(EL,Spike,3,1)+MinMax(EL,Spike,2,1)-1);
                            MinMax(EL,Spike,1,1) = a(MinMax(EL,Spike,1,1));
                            MinMax(EL,Spike,2,1) = a(MinMax(EL,Spike,2,1));
                            clear a;
                            
                            %Kopiert Werte aus MinMax in CharTime und DifTime
                            %Period1
                            CharTime(EL,Spike,1) = MinMax(EL,Spike,1,1);
                            CharTime(EL,Spike,3) = MinMax(EL,Spike,1,2);
                            CharTime(EL,Spike,2) = MinMax(EL,Spike,2,1);
                            CharTime(EL,Spike,4) = MinMax(EL,Spike,2,2);                            
                            DifTime(EL,Spike,1) = abs(CharTime(EL,Spike,2)-CharTime(EL,Spike,1));
                            
                            %Period2
                            CharTime(EL,Spike,5) = MinMax(EL,Spike,2,1);
                            CharTime(EL,Spike,7) = MinMax(EL,Spike,2,2);
                            CharTime(EL,Spike,6) = MinMax(EL,Spike,3,1);
                            CharTime(EL,Spike,8) = MinMax(EL,Spike,3,2);
                            DifTime(EL,Spike,2) = abs(CharTime(EL,Spike,6)-CharTime(EL,Spike,5));
                        end    
                   else
                       %Kopiert Werte aus MinMax in CharTime und DifTime
                       %Period1
                       CharTime(EL,Spike,1) = MinMax(EL,Spike,1,1);
                       CharTime(EL,Spike,3) = MinMax(EL,Spike,1,2);
                       CharTime(EL,Spike,2) = MinMax(EL,Spike,2,1);
                       CharTime(EL,Spike,4) = MinMax(EL,Spike,2,2);
                       DifTime(EL,Spike,1) = abs(CharTime(EL,Spike,2)-CharTime(EL,Spike,1));
                       
                       %Period2
                       CharTime(EL,Spike,5) = MinMax(EL,Spike,2,1);
                       CharTime(EL,Spike,7) = MinMax(EL,Spike,2,2);
                       CharTime(EL,Spike,6) = MinMax(EL,Spike,3,1);
                       CharTime(EL,Spike,8) = MinMax(EL,Spike,3,2);
                       DifTime(EL,Spike,2) = abs(CharTime(EL,Spike,6)-CharTime(EL,Spike,5));
                    end
                end
            end
            
            Elektrode=get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');    %Elektrode, die ausgewählt ist.
            Spike = get(findobj(gcf,'Tag','Spikeauswahl'),'value');   %Spike, der ausgewählt ist.
            
            set(Period1panel,'String',DifTime(Elektrode,Spike,1)*1000);
            set(Period2panel,'String',DifTime(Elektrode,Spike,2)*1000);
            set(Period1Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,1))))); %Neuberechnung des Mittelwerts
            set(Period1Std,'String',std(nonzeros(DifTime(:,:,1)))*1000); %Neuberechnung der Standartabweichung            
            set(Period2Mid,'String',sprintf('%.2f',1000*mean(nonzeros(DifTime(:,:,2))))); %Neuberechnung des Mittelwerts
            set(Period2Std,'String',std(nonzeros(DifTime(:,:,2)))*1000); %Neuberechnung der Standartabweichung
        end
                            
                        
    end

    % --- Alles zurücksetzen (MG)------------------------------------------
    function unfilterButtonCallback(~,~)
        clear BEGEND;
        waitbar_counter = 0;
        stimulidata     = false;    % 1, wenn Stimulidaten vorhanden
        cellselect      = 1; 
        Nr_SI_EVENTS    = 0;
        Mean_SIB        = 0;
        Mean_SNR_dB     = 0;
        MBDae           = 0;
        STDburstae      = 0;
        aeIBImean       = 0;
        aeIBIstd        = 0; 
        BURSTS          = 0;
        SI_EVENTS       = 0;
        
        if rawcheck ==1
            spikedata       = false;
            SPIKES          = 0;
            STIMULI_1       = 0;    % negative Flanken der Stimulation
            STIMULI_2       = 0;    % positive Flanken der Stimulation
            BEGEND          = 0;    % Timestamps der Stimuli (Anfänge und Enden)
            BEG             = 0;    % Timestamps der Stimulistarts
            END             = 0;    % Timestamps der Stimulienden
            set(findobj(gcf,'Parent',t4,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_Autocorrelation'),'Enable','on');
            
            % falls nicht benötigt % einfügen oder wieder entfernen
            %M = M_OR;
            msgbox('This Dr. Cell Version does not have a copy of the orignial Signal to speed up the process. If this function is necesarry please uncomment "M_OR" in sourcecode','Dr.CELL´s hint','help');
            uiwait;
        elseif spiketraincheck == 1
            SPIKES = SPIKES_OR;
            set(findobj(gcf,'Parent',t3,'Enable','off'),'Enable','on');
            set(findobj(gcf,'Tag','CELL_DefaultBox'),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','on');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','on');
            set(findobj(gcf,'Tag','CELL_sensitivityBoxtext'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_sensitivityBox'),'Enable','off');
            set(findobj(gcf,'Parent',radiogroup2),'Enable','off');
            set(findobj(gcf,'Parent',radiogroup3),'Enable','off');
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');
            set(findobj(gcf,'Tag','time_start'),'Enable','off');
            set(findobj(gcf,'Tag','time_end'),'Enable','off');     
            set(findobj(gcf,'Parent',t4,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t5,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Parent',t6,'Enable','on'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showMarksCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_showSpikesCheckbox'),'Enable','on');       
            set(findobj(gcf,'Tag','CELL_showBurstsCheckbox'),'Value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Value',0,'Enable','off');
         end
        redrawdecide;
    end



    %Funktionen - Tab Threshold
    %----------------------------------------------------------------------

    % --- Thresholdbrechnung automatisch oder manuell (CN)-----------------
    function handler2(~,event)
        t = get(event.NewValue,'Tag');
        switch(t)
        case 'thresh_auto'                                         % Automatisch
            set(findobj(gcf,'Tag','text_1'),'enable','off');
            set(findobj(gcf,'Tag','time_start'),'String','-','enable','off');
            set(findobj(gcf,'Tag','text_2'),'enable','off');
            set(findobj(gcf,'Tag','time_end'),'String','-','enable','off');
            set(findobj(gcf,'Tag','text_3'),'enable','off');     
            auto = true;
        case 'thresh_manu'                                          % Manueller Bereich auswählen
            set(findobj(gcf,'Tag','text_1'),'enable','on');
            set(findobj(gcf,'Tag','time_start'),'String','0','enable','on');
            set(findobj(gcf,'Tag','text_2'),'enable','on');
            set(findobj(gcf,'Tag','time_end'),'String',rec_dur_string,'enable','on');
            set(findobj(gcf,'Tag','text_3'),'enable','on');
            auto = false;
        end
    end

 % --- Calculate Threshold sigma or rms(CN)-----------------
    function handler3(~,event)
        t = get(event.NewValue,'Tag');
        switch(t)
        case 'thresh_rms'                                         % rms
             threshrmsdecide = true;
        case 'thresh_sigma'                                         % sigma
             threshrmsdecide = false;
        end
    end
    
    % --- Calculate Button - berechnet die Thresholds (CN)-----------------
    function CalculateThreshold(~,~)
        THRESHOLDS = 0; waitbar_counter2 = 0.05;
        PREF(1) = get(findobj(gcf,'Tag','CELL_sensitivityBox'),'value');            % Threshold
        h_wait = waitbar(.05,'Please wait - Thresholds are calculated...');

        disp ('Analysing...'); 
        switch PREF(1)
            case 1, multiplier = 14;
            case 2, multiplier = 11;
            case 3, multiplier = 9;
            case 4, multiplier = 7;
            case 5, multiplier = 6;
            case 6, multiplier = 5;
            case 7, multiplier = 4;
            case 8, multiplier = 3;
        end
         
        
        window_beg = 0.01*SaRa+1;      %10 ms die ersten 10ms werden ausgelassen, da sich da das Signal oft noch einschwingt.
        window_end = 0.06*SaRa;        %60 ms
        nr_win = 0;
        calc_beg = 1;
        calc_end = 0.05*SaRa;

        CALC = zeros((2*SaRa),(size(M,2)));         %Initilisierung 
        SNR = zeros(1,size(M,2));
        SNR_dB = zeros(1,size(M,2));
        
        if auto                             %automatische Thresholddetektion
            for n=1:size(M,2)               %für alle Elektroden
              while nr_win < 40             % es werden 2 Sekunden des Signals verwendet, um den Threshold zu berechnen 

              %Berechne aus 50ms-Fenster die Standardabweichung
                 [~,sigma] = normal(M(window_beg:window_end,n)); %Falls die Statistics-Toolbox vorhanden ist, kann anstatt normal auch
                 %die fertige Funktion "normfit" verwendet werden. Dies funktioniert genauso gut.

                 if((sigma < 5) && (sigma > 0))
                    %Das Fenster ist ok - schreibe es in ein Array - CALC, aus dem später
                    %die Thresholds berechnet werden.

                    CALC(calc_beg:calc_end,n) = M(window_beg:window_end,n);
                    calc_beg = calc_beg + 0.05*SaRa;
                    calc_end = calc_end + 0.05*SaRa;
                    window_beg = window_beg + 0.05*SaRa;
                    window_end = window_end + 0.05*SaRa;

                    if window_end>size(T,2) break; end %#ok 

                    ELEC_CHECK(n) = 1; % 1 -> Elektrode ist ok
                    nr_win = nr_win + 1;

                 else
                    window_beg = window_beg + 0.025*SaRa;
                    window_end = window_end + 0.025*SaRa;

                    if window_end>size(T,2) break; end %#ok 

                    if ((window_beg > 0.5*size(T,2)) && (nr_win == 0))
                       ELEC_CHECK(n) = 0; % 0 -> Elektrode ist verrauscht
                       break 
                    end
                end  
              end

               %Rücksetzen der Zähler
               nr_win = 0;
               window_beg = 0.01*SaRa+1;    %10 ms
               window_end = 0.06*SaRa;      %60 ms  
               calc_beg = 1;
               calc_end = 0.05*SaRa;

               waitbar_counter2 = waitbar_counter2+(0.7/nr_channel);
               waitbar(waitbar_counter2);
            end            
            %COL_MEAN = mean(CALC.^2);
            COL_RMS = sqrt(mean(CALC.^2));
            COL_SDT = std(CALC);

        elseif auto == 0                    %Manuelles berechnen der Thresholds
              waitbar(.6,h_wait,'Please wait - Thresholds are calculated...');  
              if (PREF(3)-rec_dur<1) && (PREF(2) == 0)
                    % COL_MEAN = mean(M.^2);                      % Quadratisches Mittel (RMS) pro Elektrode bilden
                    COL_RMS = sqrt(mean(M.^2));                 % RMS
                    COL_SDT = std(M);
              else
                    start = PREF(2)*SaRa+1;
                    finish = PREF(3)*SaRa;
                    % COL_MEAN = mean(M(start:finish,:).^2);
                    COL_RMS = sqrt(mean(M(start:finish,:).^2)); % RMS
                    COL_SDT = std(M(start:finish,:));
              end
        end
  
        if threshrmsdecide
            THRESHOLDS = -multiplier.*COL_RMS;
        else
            THRESHOLDS = -multiplier.*COL_SDT;
        end
        
      for n=1:size(THRESHOLDS,2)
          if ELEC_CHECK(n)== 0
              THRESHOLDS(n) = 10000;
          end
      end
        



        waitbar(1,h_wait,'Done.'), close(h_wait); 
        
        set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
        set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'Value',1,'Enable','on')
        set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String','');
        set(findobj(gcf,'Tag','Elsel_Thresh'),'String','');
        
        thresholddata = true;
        
        % Neuzeichnen der Graphen
        if Viewselect == 0
            redraw;
        elseif Viewselect == 1
            redraw_allinone;
        end
    end
    
    % --- Threshold einzelner Elektroden anzeigen--------------------------
    function ElgetThresholdfunction(source,event) %#ok<INUSD>
         EL_Auswahl = get(findobj(gcf,'Tag','Elsel_Thresh'),'string');
         CurElec = strread(EL_Auswahl);
         
               if rawcheck == 1
                     i = find(EL_NUMS==CurElec);
                     if isempty(i)  %falls eine Elektrode ausgewählt wurde, die nicht mit aufgenommen wurde
                            msgbox('This is not a recorded electrode!','Dr.CELL´s hint','help');
                            uiwait;
                            return   
                     end
                     set(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'String',THRESHOLDS(i));

              elseif spiketraincheck == 1
                      msgbox('Error','Dr.CELL´s hint','help');
                      uiwait;
                      return 
               end          
    end

    % --- Threshold einzelner Elektroden per Hand einstellen---------------
    function ELsaveThresholdfunction(source,event) %#ok<INUSD>
        i = find(EL_NUMS==CurElec); 
        THRESHOLDS(i) = str2num(get(findobj(gcf,'Tag','CELL_ShowcurrentThresh'),'string'));%#ok
        redrawdecide;
    end

    % --- variable Thresholdfunktion (AD) -------------------------------
    function CalculatevarThreshold(source,event) %#ok<INUSD>
        
        %i = find(EL_NUMS==CurElec);
        varmultiplier = str2double(get(findobj(gcf,'Tag','varTmultiplier'),'string'));
        varspan = str2double(get(findobj(gcf,'Tag','varTspan'),'string'));
        vardegree = str2double(get(findobj(gcf,'Tag','varTdegree'),'string'));
    % --- variablen Threshold berechnen
    
    varT=sgolayfilt(M,vardegree,varspan);
    varTdata=1;
    
    % --- Offset berechnen
    
    for n=1:size(M,2)               %für alle Elektroden
    varoffset(1,n)=median(M(:,n))-(MAD(M(:,n))/0.6745)*varmultiplier;
    varT(:,n)=varT(:,n)+varoffset(1,n);
    end
    
    for n=1:size(M,2) 
        THRESHOLDS(1,n)=0;
    end
    set(findobj(gcf,'Parent',t5,'Enable','off'),'Enable','on');  
    set(findobj(gcf,'Parent',t4,'Enable','off'),'Enable','on');
    thresholddata = true;
    redraw;
    
    end



    %Funktionen - Tab Analysis
    %----------------------------------------------------------------------

    % --- Default-Werte des Analysefensters (GH&CN)------------------------
    function handler(source,event) %#ok   
        defaultset = get(defaulthandle,'value');   % Y-Skalierung festlegen                                
        switch defaultset
            case 1, %Burstdefinition nach Tam - 
                set(findobj(gcf,'Tag','t_spike'),'String','1');
                set(findobj(gcf,'Tag','spike_no'),'String','3','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','10','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','20','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','500','enable','on');
                cellselect = 1;
                
            case 2, %Burstdefinition nach Baker - mindestens 3 Spikes mit einem Abstand von max 100ms
                set(findobj(gcf,'Tag','t_spike'),'String','0');
                set(findobj(gcf,'Tag','spike_no'),'String','3','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','100','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','100','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','0','enable','on');
                cellselect = 1;
                
            case 3 %Burstdefinition nach Wagenaar
                set(findobj(gcf,'Tag','t_spike'),'String','0');
                set(findobj(gcf,'Tag','spike_no'),'String','4','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','0','enable','on');
                cellselect = 2;      
                
            case 4 %Burstdefinition nach Wagenaar
                set(findobj(gcf,'Tag','t_spike'),'String','0');
                set(findobj(gcf,'Tag','spike_no'),'String','3','enable','on');
                set(findobj(gcf,'Tag','t_12'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_nn'),'String','0','enable','on');
                set(findobj(gcf,'Tag','t_dead'),'String','0','enable','on');
                cellselect = 3; 
                
            case 5, %Herzmuskel - 200ms Todzeit
                set(findobj(gcf,'Tag','t_spike'),'String','200');
                set(findobj(gcf,'Tag','spike_no'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_12'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_nn'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_dead'),'String','-','enable','off');
                cellselect = 0;
                
            case 6, %Herzmuskel - 100ms Todzeit
                set(findobj(gcf,'Tag','t_spike'),'String','100');
                set(findobj(gcf,'Tag','spike_no'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_12'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_nn'),'String','-','enable','off');
                set(findobj(gcf,'Tag','t_dead'),'String','-','enable','off');
                cellselect = 0;           
        end
    end
    
    % --- HelpBurst Button - Informationen über Burstdefinitionen (CN)-----
    function HelpBurstFunction(source,event) %#ok
        Burstinfo = figure('color',[1 1 1],'Position',[150 75 700 600],'NumberTitle','off','toolbar','none','Name','Burst definition');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 590],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Tam et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 570],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as at least 3 Spikes with a maximum idle time between Spike 1 and 2 of 10 ms and the other following spikes of 20 ms. The idle time between two spikes is set to 1 ms and that between two bursts to 500 ms.');   
    
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 520],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Baker et al.');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 500],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as at least 3 Spikes with a maximum idle time between all the Spikes of 100 ms. There is no idle time between two bursts.');   
    
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 450],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Wagenaar et al. [3]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 430],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as a core of at least 3 Spikes with a maximum idle time between those Spikes of 100 ms or 1/(4*f), which ever is smaller (f is the mean spike frequency). After a core is found, Spikes with a maximum time difference of 1/(3*f) or 200 ms (which ever is smaller) before or after the core are added to the burst. There is no idle time between two bursts.');   
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 350],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Neural burst definition by Wagenaar et al. [4]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 330],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','A Burst is defined as a core of at least 4 Spikes with a maximum idle time between those Spikes of 100 ms or 1/(4*f), which ever is smaller (f is the mean spike frequency). After a core is found, Spikes with a maximum time difference of 1/(3*f) or 200 ms (which ever is smaller) before or after the core are added to the burst. There is no idle time between two bursts.');   
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 250],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Cardiac spike definition [100 ms]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 230],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','The idle time between two Spikes os set to 100 ms. There are no bursts in cardiac cells.');   
        
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 200],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'FontWeight','bold','string','Cardiac spike definition [200 ms]');
        uicontrol('Parent',Burstinfo,'style','text','units','Pixels','position', [5 5 690 180],'backgroundcolor',[1 1 1],'FontSize',10,'HorizontalAlignment','left',...
            'String','The idle time between two Spikes os set to 200 ms. There are no bursts in cardiac cells.');  
        
    end
    
    % --- Analyse - Button (CN&MG)-----------------------------------------
    function Analysedecide(source,event) %#ok<INUSD>
        % Alle im Konfigurationsfenster gewählten Einstellungen werden in den
        % Vektor 'PREF' (Preferences) geschrieben:

        PREF(2)= str2double(get(findobj(gcf,'Tag','time_start'),'string'));
        PREF(3) = str2double(get(findobj(gcf,'Tag','time_end'),'string'));
        PREF(4) = str2double(get(findobj(gcf,'Tag','t_spike'),'string'));           % Totzeit Spike
        PREF(10) = str2double(get(findobj(gcf,'Tag','th_stim'),'string'));          % Zero Out-Threshold
        PREF(11) = str2double(get(findobj(gcf,'Tag','aftertime'),'string'));        % Nachschwingzeit der Stimulation
        
        if(get(findobj(gcf,'Tag','spike_no'),'string'))=='-' % Burst-Einstellungen zu Null setzen...
            PREF(5) = 0;                                     % ...falls HMZ ausgewählt wurden.
            PREF(6) = 0;
            PREF(7) = 0;
            PREF(8) = 0; 
        else 
            PREF(5) = str2double(get(findobj(gcf,'Tag','spike_no'),'string'));     % min. Anzahl von Spikes pro Burst   
            PREF(6) = str2double(get(findobj(gcf,'Tag','t_12'),'string'));         % max. Zeit zw. Spike 1 und 2 [ms]
            PREF(7) = str2double(get(findobj(gcf,'Tag','t_nn'),'string'));         % max. Zeit zw. weiteren Spikes
            PREF(8) = str2double(get(findobj(gcf,'Tag','t_dead'),'string'));       % min. Zeit zw. 2 Bursts [ms]
            if PREF(5)<3
                msgbox('A burst consists of at least 3 Spikes...','Dr.CELL´s hint','error');
                uiwait;
                PREF(5)=3;
            end        
        end
                
        if spiketraincheck == 1
            h_wait = waitbar(.25,'Please wait - data is analyzed...');
            CohenKappa;
            waitbar(.5,h_wait,'Please wait - Burstdetection in progress...')
            
            SIB = zeros(1,nr_channel);
            BURSTS = zeros(1,size(SPIKES,2));                                   % Leere Vektoren...
            SPIKES_IN_BURSTS = zeros(1,size(SPIKES,2));                         % ...erstellen
            BURSTDUR = zeros(1,size(SPIKES,2));
            IBIstd = zeros(1,size(SPIKES,2));
            IBImean = zeros(1,size(SPIKES,2));
            NR_BURSTS = zeros(1,size(SPIKES,2));
            meanburstduration = zeros(1,size(SPIKES,2));
            STDburst = zeros(1,size(SPIKES,2));
            
            Burstdetection;
            waitbar(.7,h_wait,'Please wait - SBE analysis in progress...')
            if nr_channel>1 
               SBEdetection;
            end  
            
            waitbar(1,h_wait,'Done.'), close(h_wait);  
             
            set(findobj(gcf,'Parent',t5),'Enable','on');
            set(findobj(gcf,'Parent',t6),'Enable','on');
            set(findobj(gcf,'Parent',t7),'Enable','on');
            set(findobj(gcf,'Tag','CELL_showThresholdsCheckbox'),'value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'value',0,'Enable','off');
            set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','off');
            set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','off');
            set(findobj(gcf,'Tag','SpikeSorting'),'Enable','off');

        elseif rawcheck == 1
            Analyse;
        end  
    end

    % --- Normalkurvenanpassung des Histogramms (CN)-----------------------
    function [mu, sigm] = normal(x)
        if ~isvector(x)
            [n,ncols] = size(x);
        else
            n = numel(x);
            ncols = 1;
        end

        classX = class(x);
        sumx = sum(x);
        if n == 0
            mu = NaN(1,ncols,classX);
            sigm = NaN(1,ncols,classX);
            return 
        else
            mu = sumx ./ n;
            if n > 1
                if numel(mu) == 1
                    xc = x - mu;
                else
                    xc = x - repmat(mu,[n 1]);
                end
                sigm = sqrt(sum(conj(xc).*xc) ./ (n-1));
            else
                sigm = zeros(1,ncols,classX);
            end
            return
        end
    end

    % --- Spikedetection bei Rohdaten (CN,MG,AD)------------------------------
    function Analyse(source,event) %#ok<INUSD>
        SI_EVENTS = 0; spikedata = false; waitbar_counter2 = 0.1;
        SPIKES = zeros(1,nr_channel);    % Spike- und Burstvektoren mit Nullen vorbeschreiben,
        BURSTS = zeros(1,size(M,2));    % damit sie immer die gleiche Breite haben

       % --- falls der variable Threshold gewählt wurde
       
        if varTdata==1
             h_wait = waitbar(.05,'Please wait - Thresholds are calculated...');
        
             tic
           M2 = zeros(size(M,1),size(M,2));            % Nullarray der Größe der Messdaten erstellen
             
           for n = 1:size(M2,2)
                   M2(:,n) = M(:,n)-varT(:,n);         % Daten um Thresholds nach oben verschieben,...
           end                                         % .. damit liegt der Theshold auf der x-Achse
        
               M2 = (M2<0);                            % 1, falls Threshold (nach unten) überschritten wurde    

            
        %ansonsten standard-Vorgehen:    
        else
        
             h_wait = waitbar(.05,'Please wait - Thresholds are calculated...');
        
             tic
              M2 = zeros(size(M,1),size(M,2));            % Mullarray der Größe der Messdaten erstellen
              for n = 1:size(M2,2)
                   M2(:,n) = M(:,n)-THRESHOLDS(n);         % Daten um Thresholds nach oben verschieben,...
               end                                         % .. damit liegt der Theshold auf der x-Achse
        
               M2 = (M2<0);                                % 1, falls Threshold (nach unten) überschritten wurde
        end
        
        % Timestamps der Spikes erstellen:
        waitbar(.1,h_wait,'Please wait - spikedetection in progress...')
        
            for n = 1:size(M2,2)                        % n: Aktuelle Spalte in M2 und SPIKES                      
                k = 0;                                  % k: Aktuelle Zeile in SPIKES
                m = 2;                                  % m: Aktuelle Zeile in M2
                potspikebeg = 0;
                potspikeend = 0;
                
                while m <= size(M2,1) 
                    %Anfänge der Spikes
                    if M2(m,n)>M2(m-1,n)                % Bei Übertreten des Thresholds...                                
                        potspikebeg = m;               %...Intervallanfang speichern
                    end
                    %Enden der Spikes
                    if (M2(m,n)<M2(m-1,n) && (potspikebeg ~= 0))               % Bei Übertreten des Thresholds...                                
                        potspikeend = m;                %...Intervallende speichern
                    end    
                    %Tatsächlicher Spiketimestamp = Peak
                    if potspikeend ~= 0
                        SEARCH = M(potspikebeg:potspikeend,n);
                        k=k+1;
                        [~,I]= min(SEARCH); %vorher [C,I]
                        SPIKES(k,n) = T((m-size(SEARCH,1)+I+1));
                        INDIES(k,n) = I + potspikebeg+1;
                        potspikebeg = 0;
                        potspikeend = 0;
                    end
                    m = m + 1;
                end
               waitbar_counter2 = waitbar_counter2+(0.45/nr_channel);
               waitbar(waitbar_counter2);
            end
            
        % --- Ermittlung der Timestamps bei eingegebener Refraktärzeit    

        clear SPIKES_NEW INDIES_NEW;          
        if PREF(4)~= 0   
           waitbar(.6,h_wait,'Please wait - spikedetection in progress...') %falls es eine Totzeit gibt werden die Spikes nochmal sortiert
           n = 1;
           SPIKES(size(SPIKES,1)+1,:)= 0;
           while (n <= size(SPIKES,2)) %für alle Elektroden 
                 k = 1;
                 h = 1;
                 i = 1; 
                 if (size(nonzeros(SPIKES(:,n)),1))==1;
                   SPIKES_NEW(h,n) = SPIKES(k,n);
                   INDIES_NEW(h,n) = INDIES(k,n);
                 else
                    while (k <=(size(nonzeros(SPIKES(:,n)),1)))  %für alle Spikes 
                         if ((SPIKES(k+i,n) - SPIKES(k,n)) <= (PREF(4)/1000 - 1/(SaRa*4))) && ((SPIKES(k+i,n)~= 0) &&  (SPIKES(k,n) ~= 0)) % Abfrage auf 0 nötig, da ansonsten versucht wird auf M(0,n) zuzugreifen
                            [~,I] = min(M(round(SPIKES(k,n)*SaRa)+1:(round(SPIKES(k+i,n)*SaRa)+1),n)); %(+1) nötig, um den richtigen Wert aus M zu erhalten
                            if I==1                           % Falls Minimum bei SPIKES(k,n) liegt
                               i = i + 1;
                            else                              % lokales Minimum liegt bei SPIKES(k+1.n) 
                               k = k + i;
                               i = 1;
                            end
                       
                         else
                            SPIKES_NEW(h,n) = SPIKES(k,n);    % endgültiges Minimum gefunden
                            INDIES_NEW(h,n) = INDIES(k,n);
                            k = k + i;
                            h = h + 1;
                            i = 1;
                         end
                    end
                 end
                 n = n + 1; 
           end
           SPIKES=[];   % Um Probleme mit der Matrix-Dimension zu vermeiden
           INDIES=[];
        
           if size(SPIKES_NEW,2) == size(THRESHOLDS,2) % Überprüfung ob SPIKES_NEW alle Elektroden beinhaltet (Da Nullen nicht geschrieben werden)
              SPIKES = SPIKES_NEW;     % aktualisieren von SPIKES
              INDIES = INDIES_NEW;
           else
              SPIKES_NEW(:,size(THRESHOLDS,2))= 0; % Hinzufügen der restlichen Elektroden (Wenn nötig)
              SPIKES = SPIKES_NEW;
              INDIES = INDIES_NEW;
           end
        end
        for n = 1:(nr_channel)                                % Für die Zusammenfassung:...
            NR_SPIKES(n) = length(find(SPIKES(:,n)));        % Anzahl der Spikes pro Elektrode
        end  
        waitbar(.65,h_wait,'Please wait - spikedetection in progress...')      
        clear M2;  % Arbeitsspeicher freimachen
        
        SIB = zeros(1,nr_channel);
        BURSTS = zeros(1,size(SPIKES,2));                                   % Leere Vektoren...
        SPIKES_IN_BURSTS = zeros(1,size(SPIKES,2));                         % ...erstellen
        BURSTDUR = zeros(1,size(SPIKES,2));
        IBIstd = zeros(1,size(SPIKES,2));
        IBImean = zeros(1,size(SPIKES,2));
        NR_BURSTS = zeros(1,size(SPIKES,2));
        meanburstduration = zeros(1,size(SPIKES,2));
        STDburst = zeros(1,size(SPIKES,2));
            
        if (get(findobj('Tag','Burst_Box'),'value')) == 1
            CohenKappa;
            waitbar(.75,h_wait,'Please wait - Burstdetection in progress...')

            if cellselect ~= 0  %nur für Neurone
                Burstdetection;          
            end
            
            waitbar(.9,h_wait,'Please wait - SBE analysis in progress...')
            if nr_channel>1
               SBEdetection;
            end
        end
        spikedata = true;          % Ab jetzt sind offiziell Spikedaten vorhanden       
        
        toc
        waitbar(1,h_wait,'Done.'), close(h_wait);   

        set(findobj(gcf,'Parent',t5),'Enable','on');
        set(findobj(gcf,'Parent',t6),'Enable','on');
        set(findobj(gcf,'Parent',t7),'Enable','on');

        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','off');
        
        if stimulidata ==0
           set(findobj(gcf,'Tag','CELL_ShowZeroOutExample'),'Enable','off');
           set(findobj(gcf,'Tag','CELL_showStimuliCheckbox'),'Enable','off');
        end
        
        %Berechnung des Signal-to-Noise Ratio
       
        for i=1:size(M,2) %for all electrodes
           
           if NR_SPIKES(i) > 0    
                for k=1:NR_SPIKES(i) %for i-th electrode
                 amptemp(k) = - M((ceil(SPIKES(k,i)*SaRa)),i);
                end   
            
                SNR(i) = mean(amptemp)/COL_SDT(i);
                
                amptemp=[];
            else
                SNR(i) = 1;
            end
        end
        
        for n = 1:size(SNR,2)  %In einigen Fällen kann der RMS-Wert 0.99xx betragen. In diesen Fällen wird der RMS auf 1 gesetzt.
          if (SNR(n)<1 || THRESHOLDS(n) == 10000)
              SNR(n)=1;
          end
        end

        SNR_dB = 20*log(SNR);
        Mean_SNR_dB = mean(SNR_dB);
        
        % Neuzeichnen der Graphen
        if Viewselect == 0
            redraw;
        elseif Viewselect == 1
            redraw_allinone;
        end
    end

    % --- Burstdetektion (aus den Spike-Timestamps)(MG&CN)-----------------
    function Burstdetection(source,event) %#ok     
   
        if cellselect == 1 %wenn es Neurone sind
            for n = 1:size(SPIKES,2)                                            % n: Aktuelle Spalte (=Elektrode)       
                k = 1; m = 1;                                                   % k: Zeile in BURSTS, m: Zeile in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % ...bis zum drittletzten Eintrag in SPIKES:
                    if ((SPIKES(m+1,n)-SPIKES(m,n) <= (PREF(6)/1000)) && (SPIKES(m+2,n)-SPIKES(m+1,n) <= (PREF(7)/1000))) % Überprüfe die Bedingungen an den ersten 3 Spikes
                        candidate = SPIKES(m,n);   % Möglichen Timestamp-Kandidat für Burstbeginn zwischenspeichern
                        m = m+2;
                        o = 3;                     % o: Aktuelle Anzahl der Spikes im Burst
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end     % Wenn das Ende erreicht ist -> raus
                        while SPIKES(m+1,n)-SPIKES(m,n) <= (PREF(7)/1000)       % Wenn weitere Spikes in kurzem...
                            m = m+1;                                            % ...Abstand gefunden werden: ...  
                            o = o+1;                                            % ...-> Mitzählen.                                               
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end

                        if o >= PREF(5)                                         % Burst registrieren, wenn...
                            BURSTS(k,n)= candidate;                             % ...die minimale Spikezahl...
                                                                                % ...errreicht wurde.
                            %Burstdauer berechnen
                            BURSTDUR(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            k = k+1;
                            SPIKES_IN_BURSTS(n) = SPIKES_IN_BURSTS(n)+o;

                            while SPIKES(m,n)-BURSTS(k-1,n)<=(PREF(8)/1000)     % Dann um die angegebene Zeit...
                                m = m+1;                                        % ...zwischen 2 Bursts weitergehen.
                             if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end   
                        end
                    else
                        m = m+1;
                    end
                end
            end
            
             %Mittlere Burstdauer pro Elektrode berechnen
             for count=1:size(BURSTS,2)
                  if BURSTDUR(1,count) ~= 0
                    meanburstduration(count) = mean(nonzeros(BURSTDUR(:,count)));
                    STDburst(count) = std(nonzeros(BURSTDUR(:,count)));
                  end
             end

            MBDae =  mean(nonzeros(meanburstduration)); %Mean Burst Duration all electrodes
            STDburstae = mean(nonzeros(STDburst));
            if isnan(MBDae)
                MBDae = 0;
            end
            if isnan(STDburstae)
                STDburstae =0;
            end
            
        %---Burstalgorithmus wie in MEA-Bench nach Wagenaar mit 4 Spikes im Kern---   
        elseif cellselect == 2                         
            Spikerate = NR_SPIKES.*(1/rec_dur);
            tau1 = zeros(1,size(SPIKES,2));            % Leere Vektoren...
            tau2 = zeros(1,size(SPIKES,2));
            Spikedelay1 = zeros(1,size(SPIKES,2));     % Delay für den Kern
            Spikedelay2 = zeros(1,size(SPIKES,2));     % Delay um den Kern

            for n = 1:nr_channel   
                tau1(n) = 1/(4*Spikerate(n));
                tau2(n) = 1/(3*Spikerate(n));

                   if tau1(n) > 1/10
                     Spikedelay1(n) = 1/10;
                   else
                     Spikedelay1(n) = tau1(n);  
                   end

                  if tau2(n) > 2/10
                     Spikedelay2(n) = 2/10;
                  else
                     Spikedelay2(n) = tau2(n);  
                  end
                  

                k = 1; m = 1;                                                   % k: Zeile in BURSTS, m: Zeile in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % -2 bei 4 Spikes im Kern...bis zum drittletzten Eintrag in SPIKES:
                    %Original Definition nach Wagenaar mit 4 Spikes im Kern
                    if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n))) % Überprüfe die Bedingungen an den ersten 4 Spikes
                        candidate = SPIKES(m,n);                                % Möglichen Timestamp-Kandidat für Burstbeginn zwischenspeichern
                        FirstSpike = m;
                        m = m+3;
                        o = 4;                     % o: Aktuelle Anzahl der Spikes im Burst
                                     
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end     % Wenn das Ende erreicht ist -> raus

                        %Suche nach weiteren Spikes nach dem Kern
                        while SPIKES(m+1,n)-SPIKES(m,n) <= Spikedelay2(n)       % Wenn weitere Spikes in kurzem...
                            m = m+1;                                            % ...Abstand gefunden werden: ...  
                            o = o+1;                                            % ...-> Mitzählen.                                               
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end

                        %Suche nach weiteren Spikes vor dem Kern
                        if FirstSpike > 1 %Nur wenn vor dem ersten Spike in einem Burst überhaupt weitere Spikes gibt, macht das Sinn.
                            while SPIKES(FirstSpike,n) - SPIKES(FirstSpike-1,n) <= Spikedelay2(n)
                                FirstSpike = FirstSpike - 1;
                                o=o+1;
                                if FirstSpike <= 1, break, end 
                            end
                        end

                        if o >= PREF(5)                                         % Burst registrieren, wenn...
                            BURSTS(k,n)= candidate;                             % ...die minimale Spikezahl...
                                                                                % ...errreicht wurde.
                            %Burstdauer berechnen
                            BURSTDUR(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            SPIKES_IN_BURSTS(n) = SPIKES_IN_BURSTS(n)+o;                       
                            k = k+1;                   

                            while SPIKES(m,n)-BURSTS(k-1,n)<=(PREF(10)/1000)     % Dann um die angegebene Zeit...
                                m = m+1;                                        % ...zwischen 2 Bursts weitergehen.
                             if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end   
                        end
                    else
                        m = m+1;
                    end
                end
            end

             %Mittlere Burstdauer pro Elektrode berechnen
             for count=1:size(BURSTS,2)
                  if BURSTDUR(1,count) ~= 0
                    meanburstduration(count) = mean(nonzeros(BURSTDUR(:,count)));
                    STDburst(count) = std(nonzeros(BURSTDUR(:,count)));
                  end
             end

            MBDae =  mean(nonzeros(meanburstduration)); %Mean Burst Duration all electrodes
            STDburstae = mean(nonzeros(STDburst));
            if isnan(MBDae)
                MBDae = 0;
            end
            if isnan(STDburstae)
                STDburstae =0;
            end
            cellselect = 1; %Rücksetzen von cellselect, damit es keine Probleme gibt.
              
            
        %---Burstalgorithmus wie in MEA-Bench nach Wagenaar mit 3 Spikes im Kern---   
        elseif cellselect == 3                         
            Spikerate = NR_SPIKES.*(1/rec_dur);
            tau1 = zeros(1,size(SPIKES,2));            % Leere Vektoren...
            tau2 = zeros(1,size(SPIKES,2));
            Spikedelay1 = zeros(1,size(SPIKES,2));     % Delay für den Kern
            Spikedelay2 = zeros(1,size(SPIKES,2));     % Delay um den Kern

            for n = 1:nr_channel   
                tau1(n) = 1/(4*Spikerate(n));
                tau2(n) = 1/(3*Spikerate(n));

                   if tau1(n) > 1/10
                     Spikedelay1(n) = 1/10;
                   else
                     Spikedelay1(n) = tau1(n);  
                   end

                  if tau2(n) > 2/10
                     Spikedelay2(n) = 2/10;
                  else
                     Spikedelay2(n) = tau2(n);  
                  end
                  

                k = 1; m = 1;                                                   % k: Zeile in BURSTS, m: Zeile in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-1                      % ...bis zum zweitletzten Eintrag in SPIKES:
                                          
                     %Test mit mindestens 3 Spikes im Kern   
                     if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n))) % Überprüfe die Bedingungen an den ersten 3 Spikes
                        candidate = SPIKES(m,n);                                % Möglichen Timestamp-Kandidat für Burstbeginn zwischenspeichern
                        FirstSpike = m;
                        m = m+2;
                        o = 3;                     % o: Aktuelle Anzahl der Spikes im Burst                      
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end     % Wenn das Ende erreicht ist -> raus

                        %Suche nach weiteren Spikes nach dem Kern
                        while SPIKES(m+1,n)-SPIKES(m,n) <= Spikedelay2(n)       % Wenn weitere Spikes in kurzem...
                            m = m+1;                                            % ...Abstand gefunden werden: ...  
                            o = o+1;                                            % ...-> Mitzählen.                                               
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end

                        %Suche nach weiteren Spikes vor dem Kern
                        if FirstSpike > 1 %Nur wenn vor dem ersten Spike in einem Burst überhaupt weitere Spikes gibt, macht das Sinn.
                            while SPIKES(FirstSpike,n) - SPIKES(FirstSpike-1,n) <= Spikedelay2(n)
                                FirstSpike = FirstSpike - 1;
                                o=o+1;
                                if FirstSpike <= 1, break, end 
                            end
                        end

                        if o >= PREF(5)                                         % Burst registrieren, wenn...
                            BURSTS(k,n)= candidate;                             % ...die minimale Spikezahl...
                                                                                % ...errreicht wurde.
                            %Burstdauer berechnen
                            BURSTDUR(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            SPIKES_IN_BURSTS(n) = SPIKES_IN_BURSTS(n)+o;                       
                            k = k+1;                   

                            while SPIKES(m,n)-BURSTS(k-1,n)<=(PREF(10)/1000)     % Dann um die angegebene Zeit...
                                m = m+1;                                        % ...zwischen 2 Bursts weitergehen.
                             if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end   
                        end
                    else
                        m = m+1;
                    end
                end
            end


             %Mittlere Burstdauer pro Elektrode berechnen
             for count=1:size(BURSTS,2)
                  if BURSTDUR(1,count) ~= 0
                    meanburstduration(count) = mean(nonzeros(BURSTDUR(:,count)));
                    STDburst(count) = std(nonzeros(BURSTDUR(:,count)));
                  end
             end

            MBDae =  mean(nonzeros(meanburstduration)); %Mean Burst Duration all electrodes
            STDburstae = mean(nonzeros(STDburst));
            if isnan(MBDae)
                MBDae = 0;
            end
            if isnan(STDburstae)
                STDburstae =0;
            end
            cellselect = 1; %Rücksetzen von cellselect, damit es keine Probleme gibt.  
        
        else
           
        end
        
  
            for n = 1:(nr_channel)                                % Für die Zusammenfassung:...
                NR_BURSTS(n) = length(find(BURSTS(:,n)));        % - Anzahl der Bursts pro Elektrode

                if(NR_BURSTS(n)>0)           
                    SIB(n) = SPIKES_IN_BURSTS(n)/NR_BURSTS(n);       % - Durchschnittl. Anzahl der Spikes pro Burst  
                end
            end
            
            if isempty(nonzeros(SIB))
                Mean_SIB = 0;
            else
                Mean_SIB = mean(nonzeros(SIB));     %Durchschnitt (über 60 El) Anzahl der Spikes pro Burst. Nur Els mit Bursts werden berücksichtigt
            end
      
            %Berechnung der Interburstintervalle für jede Elektrode Mittelwert und STD  
            if (size(BURSTS,1) > 1)                                 %stellt sicher, dass auf irgendeiner Elektrode mehr als einen Burst gibt.
                for z=1:size(BURSTS,2)                              %für alle Elektroden
                    if (BURSTS(1,z) == 0) || (BURSTS(2,z) == 0)     %Für den Fall, dass es nur 0 oder 1 Burst gibt
                        IBImean(z) = 0;                
                    else
                        for i = 1:size(nonzeros(BURSTS(:,z)),1)-1
                            IBI(i,z) = BURSTS(i+1,z)-(BURSTS(i,z)+BURSTDUR(i,z));
                        end 
                        IBImean(z) = mean(nonzeros(IBI(:,z)));
                        IBIstd(z) = std(nonzeros(IBI(:,z)));
                    end
                end    
            end
            
            %Für alle Elektroden zusammen Mittelwert und STD
            if isempty(nonzeros(IBImean))
                aeIBImean =0;
            else
                aeIBImean = mean(nonzeros(IBImean));
            end
            
            if isempty(nonzeros(IBIstd))
                aeIBIstd =0;
            else
                aeIBIstd =  mean(nonzeros(IBIstd));
            end            
        spikedata = true;          % Ab jetzt sind offiziell Spikedaten vorhanden           
    end

    % --- SBE-detektion (MG&CN)--------------------------------------------
    function SBEdetection(source,event)     %#ok        
        % Parallele Ereignisse auf mehreren Elektroden:
        
        if cellselect == 1  %Falls es Neuronen sind
           BASE = BURSTS; 
        else                %Falls HMZ
           BASE = SPIKES;
        end
        
        sync_time = int32(.04*SaRa);                    % Zeit, während der 2 Spikes parallel gelten: 40ms
        max_time = int32(.4*SaRa);                      % Zeitspanne, in der nach dem Maximum des Ereignisses...
                                                        % ... gesucht wird: 400ms
        wait_time = int32(.5*SaRa);                     % Minimale Zeit vom Maximum Beginn eines...
                                                        % ... zum Beginn des nächsten Events: 500ms                           

        ELECTRODE_ACTIVITY = zeros(size(T,2),nr_channel); % Maßzahl für Aktivität an der jeweiligen Elektrode
        ACTIVITY = zeros(1,length(T));                    % Zum jeweiligen Zeitpunkt aktive Elektroden
               
        for i = 1:size(BASE,2)                        % Für jeden einzelne Elektrode...
            for j = 1:length(nonzeros(BASE(:,i)))     % für jeden einzelnen Spike oder Burst...    
                pos = int32(BASE(j,i)*SaRa);          % Umrechnung des Timestamps zurück in den Time-Array-Index 
        
                if (pos>sync_time && pos<length(ACTIVITY)-sync_time)         % Die ersten und letzten 100 Samples vernachlässigen (i.d.R. 20 ms)
                    ELECTRODE_ACTIVITY(pos-sync_time:pos+sync_time,i) = 1;   % Für jeden Spike-Timestamp im Umkreis...
                end                                                          % ...von 80ms ELECTRODE_ACTIVITY auf 1 setzen.
            end
        end
        
        ACTIVITY = sum(ELECTRODE_ACTIVITY,2);  
        
        clear ELECTRODE_ACTIVITY;
        
        i = 1; k = 1;
        while i <= length(ACTIVITY)
            if i+max_time < length(ACTIVITY)        % Diese if-Abfrage stellt sicher, dass bei der...
                imax = i+max_time;                  % ...folgenden Suche des Maximums die Länge des Vektors...
            else                                    % ...ACTIVITY nicht überschritten wird.
                imax = length(ACTIVITY);
            end

            if ACTIVITY(i)>=5                      % Wenn ACTIVITY 20 Prozent der Elektroden überschreitet...
                [~,I] = max(ACTIVITY(i:imax));      % ...wird das Maximum der Spitze gesucht...
                maxlength = 0;
                while ACTIVITY(i+I)==ACTIVITY(i+I+1)
                    maxlength = maxlength+1;
                    I = I+1;
                end
                I = I-int32(maxlength/2);
                SI_EVENTS(k) = T(i+I);              % ...und der Timestamp in SI_EVENTS gepeichert.
                k = k+1;
                i = i+I+wait_time;
            end
            i = i+1;
        end
        
        Nr_SI_EVENTS = size(SI_EVENTS,2);
        if (Nr_SI_EVENTS == 1) && (SI_EVENTS(1)==0)     %Korrektur, falls es keine simultanen Ereignisse gibt.
            Nr_SI_EVENTS =0;
        end     
    end

    % --- Berechnung von Cohnes Kappa -------------------------------------
    function CohenKappa(source,event) %#ok
        SPIKES_COHEN = SPIKES;              %Kopie von Spikes anlegen
        SPM = NR_SPIKES/rec_dur*60;         %Anzahl der Spikes pro Minute (spikes per minute) berechnen
        Too_Low = SPM<50;               
        DEL = find(Too_Low==1);             %Indices der Elektroden die weniger als 50spm haben
        SPIKES_COHEN(:,DEL)=[]; %#ok        %Diese Elektroden löschen
        N = floor(size(T,2)/(0.01*SaRa));   %Anzahl der bins

        %size(SPIKES_COHEN,2);               %Anzahl der Elektroden
        COHENKAPPA = zeros(size(SPIKES_COHEN,2)-1,size(SPIKES_COHEN,2)-1);

        %Berechnung Cohens Kappa für alle möglichen Elektrodenpaare
        for firstEl=1:(size(SPIKES_COHEN,2)-1)
            for n=1:(size(SPIKES_COHEN,2)-firstEl)    
                COHENBIN = zeros(2,N);     %vergleich von zwei Elektroden

                %erste Elektrode
                wosp=ceil(nonzeros(SPIKES_COHEN(:,firstEl))*100);   %workspace zwischenablage
                COHENBIN(1,wosp)=1;
                s1 = size(nonzeros(COHENBIN(1,:)),1);

                %zweite Elektrode
                wosp=ceil(nonzeros(SPIKES_COHEN(:,(firstEl+n)))*100);
                COHENBIN(2,wosp)=1;
                s2 = size(nonzeros(COHENBIN(2,:)),1);

                p_exp = ((N-s1)*(N-s2) + s1*s2)/N^2;                            %Erwartungswert - zufällige Übereinstimmung
                p_obs = (N-size(nonzeros(COHENBIN(2,:)-COHENBIN(1,:)),1))/N;    %Beobachtung - Wenn in den jeweiligen bins das gleiche steht, ist die Differenz null

                COHENKAPPA(firstEl,firstEl+n-1) = (p_obs-p_exp)/(1-p_exp);        %Berechnung Cohens Kappa
            end
        end

        kappa_mean = mean(nonzeros(COHENKAPPA));                                  %Mittelwert ausrechnen

        %Signifikanztest Nullhypothese cohenskappa=0
        %sigmakappa = sqrt((p_exp+p_exp^2-(((N-s1)*(N-s2)/N^2) * ((N-s1)/N + (N-s2)/N) + (s1*s2/N^2) * (s1/N + s2/N)))/(N*(1-p_exp)^2));

        %Berechnung der Prüfgröße, um diese mit Standardverteilung abzugleichen und Signifikanzniveau zu bestimmen.
        %Pruefgr = cohenskappa/sigmakappa;
    end


    %Funktionen - Tab Postprocessing
    %----------------------------------------------------------------------

    % --- Rasterplot Zeichnen (MG)-----------------------------------------
    function rasterplotButtonCallback(source,event) %#ok 
        rasterplot = figure('Position',[150 50 700 660],'Name','Rasterplot Spikes',...
            'NumberTitle','off','Resize','off');
        axes('Units','pixels','Position',[20 40 660 600],'YDir','reverse',...
            'YLim',[0 size(SPIKES,2)+1],'YColor',[.8 .8 .8],'YMinorGrid','on');

        for n=1:length(SI_EVENTS)
            line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[0 nr_channel],...
                'Color','green');
        end    
        for n=1:size(BURSTS,2)
            line ('Xdata',nonzeros(SPIKES(:,n)),...
                'Ydata', n.*ones(1,length(nonzeros(SPIKES(:,n)))),...
                'LineStyle','none','Marker','*',...
                'MarkerFaceColor','green','MarkerSize',3);
            text(0,n,EL_NAMES(n),'HorizontalAlignment','right','FontSize',6);
        end
        xlabel ('time / s');
        figure (rasterplot);  % Zusammenfassung in den Vordergrund.
    end

    % --- Autokorrelation erstellen (CN)-----------------------------------
    function correlationButtonCallback(source,event) %#ok<INUSD>
        autocorrelationWindow = figure('Position',[100 100 700 600],'Tag','Autocorrelation','Name','Autocorrelation','NumberTitle','off','Toolbar','none','Resize','off'); 
        autopaneltop=uipanel('Parent',autocorrelationWindow,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[5 515 690 80]);
        uicontrol('Parent',autopaneltop,'style','text','units','Pixels','position', [10 35 300 30],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String','Shows autocorrelation of selected electrode. Please select one electrode and press "Apply..."!');
        uicontrol('Parent',autopaneltop,'style','edit','units','Pixels','position', [10 10 300 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Selectautocorr_electrode','string','12');
        uicontrol('Parent',autopaneltop,'Style','PushButton','Units','Pixels','Position',[550 10 130 30],'FontSize',10,'FontWeight','bold','String','Apply...','ToolTipString','Calculates the autocorrelation of the selected electrode','CallBack',@redrawcorrelation);
        autopanelbot = uipanel('Parent',autocorrelationWindow,'BackgroundColor',[.8 .8 .8],'Units','pixels','Position',[5 5 690 510]);

        AC_EL_Select = strread(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'));     
        AutoCorr = find(EL_NUMS==AC_EL_Select);
       
        subplot(1,1,1,'Parent',autopanelbot)
        xlabel('lags')
        ylabel('Probability Autocorrelation')   
        
            if isempty(AutoCorr)
                msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                uiwait;
                return    
            end
            
            binsize = 0.05*SaRa;    %50 ms binsize                   
            TEST = M(:,AutoCorr);
            TESTsq = TEST.^2;
            
            %Erstellen eines Arrays in bins
            k=1;
            j=binsize;
            endfor=ceil(size(T,2)/binsize);
            for i=1:endfor
               CORRBIN(i) = sum(TESTsq(k:j));                     
               j=(i+1)*binsize;
               k = j-binsize+1;
               if j > size(T,2) %falls das Signal nicht in 50 ms aufgeht, mache das letzte bin kleiner
                   j= size(T,2);
               end
            end

            Lagboarder = int32(size(CORRBIN,2)/3);
            [r,p] = xcorr(CORRBIN,CORRBIN,Lagboarder ,'coeff');
            plot(p,r)
            axis([-Lagboarder Lagboarder 0 1]);
            grid on
     end
        
    % --- Autokorrelationredraw erstellen (CN)-----------------------------
    function redrawcorrelation(source,event) %#ok<INUSD> 
        CORRBIN = 0;
        AC_EL_Select = strread(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'));

        if length(AC_EL_Select)==1
                AutoCorr = find(EL_NUMS==AC_EL_Select);
                if isempty(AutoCorr)
                    msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                    uiwait;
                    return 
                end
                
                binsize = 0.05*SaRa;    %50 ms binsize 
                TEST = M(:,AutoCorr);
                TESTsq = TEST.^2;
                
            %Erstellen eines Arrays in bins
            k=1;
            j=binsize;
            endfor=ceil(size(T,2)/binsize);
            for i=1:endfor
               CORRBIN(i) = sum(TESTsq(k:j));                     
               j=(i+1)*binsize;
               k = j-binsize+1;
               if j > size(T,2) %falls das Signal nicht in 50 ms aufgeht, mache das letzte bin kleiner
                   j= size(T,2);
               end
            end
            
            Lagboarder = int32(size(CORRBIN,2)/3);
            subplot(1,1,1,'replace')
            [r,p] = xcorr(CORRBIN,CORRBIN,Lagboarder ,'coeff');
            plot(p,r)
            axis([-Lagboarder Lagboarder 0 1]);
            grid on
            xlabel('lags')
            ylabel('Probability Autocorrelation')    
                 
        else %wenn mehrere Elektroden markiert werden
                    for n = 1:length(AC_EL_Select)            
                        Check = find(EL_NUMS==AC_EL_Select(n)); %#ok
                            if isempty(Check)
                            msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                            uiwait;
                            return 
                            end
                    end
            
                binsize = 0.05*SaRa;    %50 ms binsize 
                subplot(1,1,1,'replace');
                cla;
                for n = 1:length(AC_EL_Select)            
                    AutoCorr(n) = find(EL_NUMS==AC_EL_Select(n));
                    TEST(:,n) = M(:,AutoCorr(n));  
                    TESTsq(:,n)=TEST(:,n).^2;
                    
                    k=1;
                    j=binsize;
                    endfor=ceil(size(T,2)/binsize);
                    
                    for i=1:endfor
                       CORRBIN(i,n) = sum(TESTsq(k:j,n));                     
                       j=(i+1)*binsize;
                       k = j-binsize+1;
                       if j > size(T,2) %falls das Signal nicht in 50 ms aufgeht, mache das letzte bin kleiner
                           j= size(T,2);
                       end
                    end
                    TESTcorr = CORRBIN;
                    Lagboarder = int32(size(CORRBIN,1)/3);
                    Lags = -Lagboarder:1:Lagboarder;
                    r(:,n) = xcorr(CORRBIN(:,n),CORRBIN(:,n),Lagboarder,'coeff');
                    z(1:size(Lags,2),n)=n;

                    if n == 1
                        subplot(1,1,1,'replace')
                    end
                    plot3(z(:,n),Lags,r(:,n))
                    hold on

                end
                 axis([1 length(strread(get(findobj(gcf,'Tag','CELL_Selectautocorr_electrode'),'string'))) -Lagboarder Lagboarder 0 1]);
                 grid on
                 xlabel('El No')
                 ylabel('lags')
                 zlabel('Probability Autocorrelation')
        end
    end

    % --- Crosscorrelation (CN)--------------------------------------------
    function crosscorrelationButtonCallback(source,event) %#ok 
        crosscorrelationWindow = figure('Position',[100 100 700 600],'Tag','Crosscorrelation','Name','Crosscorrelation','NumberTitle','off','Toolbar','none','Resize','off');
        crosspaneltop=uipanel('Parent',crosscorrelationWindow,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[5 515 690 80]);
        uicontrol('Parent',crosspaneltop,'style','text','units','Pixels','position', [10 35 300 30],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String','Please select two electrodes and press "Apply..."!');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [10 10 80 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Selectcrosscorr_electrode1','string','12');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [120 10 80 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_Selectcrosscorr_electrode2','string','13');
        uicontrol('Parent',crosspaneltop,'Style','PushButton','Units','Pixels','Position',[550 10 130 30],'FontSize',10,'FontWeight','bold','String','Apply...','ToolTipString','Calculates the autocorrelation of the selected electrode','CallBack',@redrawcrosscorrelation);
        crosspanelbot = uipanel('Parent',crosscorrelationWindow,'BackgroundColor',[.8 .8 .8],'Units','pixels','Position',[5 5 690 510]);  
        uicontrol('Parent',crosspaneltop,'style','text','units','Pixels','position', [370 35 150 35],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String','Mean (all electrodes) Cohen´s Kappa');
        uicontrol('Parent',crosspaneltop,'style','edit','units','Pixels','position', [370 10 100 20],'HorizontalAlignment','left','FontSize',9,'Tag','CELL_cokap','string',kappa_mean);
        
            
        CORRBIN = 0;
        CC_EL_Select1 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode1'),'string'));
        CC_EL_Select2 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode2'),'string'));
        
            if length(CC_EL_Select1)==1 && length(CC_EL_Select2)==1
                 CrossCorr1 = find(EL_NUMS==CC_EL_Select1);
                 CrossCorr2 = find(EL_NUMS==CC_EL_Select2);

                 subplot(1,1,1,'parent',crosspanelbot)
                 xlabel('lags')
                 ylabel('Probability Crosscorrelation')
                 
                 if isempty(CrossCorr1) || isempty(CrossCorr2)
                     msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                     uiwait;
                     return 
                 end

                 binsize = 0.05*SaRa;    %50 ms binsize 
                 TEST1 = M(:,CrossCorr1); 
                 TESTsq1 = TEST1.^2;
                 TEST2 = M(:,CrossCorr2); 
                 TESTsq2 = TEST2.^2;

                %Erstellen eines Arrays in bins
                k=1;
                j=binsize;
                endfor=ceil(size(T,2)/binsize);
                for i=1:endfor
                   CORRBIN1(i) = sum(TESTsq1(k:j));
                   CORRBIN2(i) = sum(TESTsq2(k:j));
                   j=(i+1)*binsize;
                   k = j-binsize+1;
                   if j > size(T,2) %falls das Signal nicht in 50 ms aufgeht, mache das letzte bin kleiner
                       j= size(T,2);
                   end
                end

                Lagboarder = int32(size(CORRBIN1,2)/3);  
                [r,p] = xcorr(CORRBIN1,CORRBIN2,Lagboarder ,'coeff');
                plot(p,r)
                axis([-Lagboarder Lagboarder 0 1]);
                grid on
                
            else
                msgbox('please only select two electrodes!')
            end
    end
       
    % --- Neuzeichnen der Crosscorrelation (CN)----------------------------
    function redrawcrosscorrelation(source,event) %#ok        
        CORRBIN = 0;
        CC_EL_Select1 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode1'),'string'));
        CC_EL_Select2 = strread(get(findobj(gcf,'Tag','CELL_Selectcrosscorr_electrode2'),'string'));   
        
        if length(CC_EL_Select1)==1 && length(CC_EL_Select2)==1
             CrossCorr1 = find(EL_NUMS==CC_EL_Select1);
             CrossCorr2 = find(EL_NUMS==CC_EL_Select2);
             
             if isempty(CrossCorr1) || isempty(CrossCorr2)
                 msgbox('One of the entered electrodes was not recorded! Please check!','Dr.CELL´s hint','help');
                 uiwait;
                 return 
             end
                
             binsize = 0.05*SaRa;    %50 ms binsize 
             TEST1 = M(:,CrossCorr1);  
             TESTsq1 = TEST1.^2;
             TEST2 = M(:,CrossCorr2);  
             TESTsq2 = TEST2.^2;
                       
            %Erstellen eines Arrays in bins
            k=1;
            j=binsize;
            endfor=ceil(size(T,2)/binsize);
            for i=1:endfor
               CORRBIN1(i) = sum(TESTsq1(k:j));
               CORRBIN2(i) = sum(TESTsq2(k:j));
               j=(i+1)*binsize;
               k = j-binsize+1;
               if j > size(T,2) %falls das Signal nicht in 50 ms aufgeht, mache das letzte bin kleiner
                   j= size(T,2);
               end
            end
            
            Lagboarder = int32(size(CORRBIN1,2)/3);
          

            subplot(1,1,1,'replace')  
            [r,p] = xcorr(CORRBIN1,CORRBIN2,Lagboarder ,'coeff');
            plot(p,r)
            axis([-Lagboarder Lagboarder 0 1]);
            grid on
            xlabel('lags')
            ylabel('Probability Crosscorrelation')
                
        else
             msgbox('please only select two electrodes!')
        end  
    end

    % --- Timing-Funktion für HMZ Pop-Up (HAKO)----------------------------
    function timingButtonCallback(source,event) %#ok<INUSD>
           fh = figure('Units','Pixels','Position',[300 360 400 200],'Name','Spike auswählen','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');   
           uicontrol('Parent',fh,'style','text','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','Pixels', 'position', [20 80 300 100],'String','Analyse für einen bestimmten Spike, oder eine Übersicht über die ersten zwanzig auftretenden Spikes');
           uicontrol('Parent',fh,'Units','Pixels','Position',[200 64 60 20],'Tag','SpikeChoice','FontSize',8,'String',[' 1';' 2';' 3';' 4';' 5';' 6';' 7';' 8';' 9';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24'],'Style','popupmenu');
           radiogroup = uibuttongroup('visible','on','Units','Pixels','Position',[18 32 140 20],'BackgroundColor',[0.8 0.8 0.8],'BorderType','none','SelectionChangeFcn',@timinghandler);
           uicontrol('Parent',radiogroup,'Units','pixels','Position',[18 32 140 20],'Style','radio','HorizontalAlignment','left','Tag','CELL_singleSpike','String','Bestimmter Spike','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Bitte wählen Sie den zu analysierenden Spike aus');
           uicontrol('Parent',radiogroup,'Units','pixels','Position',[18 0 140 20],'Style','radio','HorizontalAlignment','left','Tag','CELL_multiSpikes','String','Ersten 20 Spikes','FontSize',9,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Es werden automatisch die ersten 20 Spikes angezeigt');
           uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[280 30 110 50],'String','Auswahl bestätigen','CallBack',@delaycallfunction);
 
        function timinghandler(source,event) %#ok<INUSL>
            t = get(event.NewValue,'Tag');
            switch(t)
            case 'CELL_singleSpike'
                set(findobj(gcf,'Tag','SpikeChoice'),'enable','on');
            case 'CELL_multiSpikes'                                          % Herzmuskelzellen
                set(findobj(gcf,'Tag','SpikeChoice'),'enable','off');
            end
        end
    end

    % --- Timing-Funktion für HMZ(HAKO)------------------------------------
    function delaycallfunction (source,event) %#ok
        en = get(findobj(gcf,'Tag','SpikeChoice'),'enable');
        TF = strcmp(en, 'on');
        ELS=char(EL_NAMES);                   % herauslesen der Elektroden-Namen
        ELS=ELS(:,4:5);
        ELS = str2num(ELS); %#ok<ST2NM>
        RANK(1,:)= ELS';
        clear en;

        
        %Ordnet SPIKES, so dass die Nullen bei nicht detektierten
        %Spikes nicht am Ende, sondern an der korrekten Position,
        %sprich der Spikenummer stehen
        SPIKESCOPY  = SPIKES;
        Max = 0.2; %Maximale Abweichung des Spikes von SI_EVENTS in Sekunden
        x=1;
        y=1;
        while x < size(SPIKESCOPY,1)
            while y <= size(SPIKESCOPY,2)
                if x < size(SI_EVENTS,2) && abs(SPIKESCOPY(x,y)-SI_EVENTS(x)) > abs(SPIKESCOPY(x,y)-SI_EVENTS(x+1))
                    SPIKESCOPY(end+1,y) = SPIKESCOPY(end,y); 
                    SPIKESCOPY(x+1:end-1,y) = SPIKESCOPY(x:end-2,y);
                    SPIKESCOPY(x,y) = 0;
                elseif abs(SPIKESCOPY(x,y)-SI_EVENTS(x)) > Max || x < size(SI_EVENTS,2) && ...
                       abs(SPIKESCOPY(x,y)-SI_EVENTS(x)) > abs(SPIKESCOPY(x+1,y)-SI_EVENTS(x))
                       
                    SPIKESCOPY(x:end-1,y) = SPIKESCOPY(x+1:end,y);
                    SPIKESCOPY(end,y) = 0;
                    if SPIKESCOPY(x,y) ~= 0
                        y = y-1;
                    end
                end
                while isempty(nonzeros(SPIKESCOPY(end,:)))
                    SPIKESCOPY(end,:) = [];
                end
                y = y+1;
            end
            x = x+1;
            y = 1;
        end
        clear x y;
        
        if TF==1;                           % Routine für einen bestimmten Spike
            
            spikenr = get(findobj(gcf,'Tag','SpikeChoice'),'value');
            close(gcbf);
            RANK(2,:) = SPIKESCOPY(spikenr,:);        % ausgewählten Spike betrachten
            %clear SPIKESCOPY;
            

            %Füllt in RANK fehlende Elektroden auf
            ELSALL = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
            for n=1:size(ELSALL,2)
               if isempty(find(RANK(1,:) == ELSALL(n), 1))
                   RANK(:,n+1:end+1) = RANK(:,n:end);
                   RANK(1,n) = ELSALL(n);
                   RANK(2,n) = 0;        
               end
            end
            clear n;
            
            
            
            Min = min(nonzeros(RANK(2,:)));

            
            RANK(3,:) = RANK(2,:)-Min;
            clear Min;

            % Ab hier die entsprechenden Maßnahmen für den cellplot!
            
            RANK(3,:)=RANK(3,:)*1000; % Die Zeitdifferenzen mal 1000, um sie in ms anzeigen zu können.
            
            % Markiert alle Elektroden anfangs mit Wert -999. Falls diese nicht belegt wurden, so kann später die -999 wiedererkannt werden
            R(1:8,1:8) = -999;

            
            
            figure('Name','Ausbreitungsrichtung eines Spikes','Color',[1 1 1])
            for n=1:size(RANK,2)
                EL = RANK(1,n);
                if RANK(3,n) < 0
                    %Checkt, welche Nachbarelektroden vorhanden sind und
                    %merkt sich dies in Left,Right,Up,Down
                    if EL > 30 || EL > 20 && mod(EL,10) > 1 && mod(EL,10) < 8
                        Left = true;
                    else
                        Left = false;
                    end
                    if EL < 70 || EL < 80 && mod(EL,10) > 1 && mod(EL,10) < 8
                        Right = true;
                    else
                        Right = false;
                    end
                    if mod(EL,10) > 2 || mod(EL,10) > 1 && EL > 20 && EL < 80
                        Up = true;
                    else
                        Up = false;
                    end
                    if mod(EL,10) < 6 || mod(EL,10) < 8 && EL > 10 && EL < 80
                        Down = true;
                    else
                        Down = false;
                    end
                    
                    %Ermittelt Mittelwert aus benachbarten Elektroden (nur,
                    %wenn diese nicht auch inaktiv sind)
                    Summe = 0;
                    m = 0;
                    if Left
                        x = find(RANK(1,:) == EL-10);
                        if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if Right
                        x = find(RANK(1,:) == EL+10);
                        if isempty(x) == 0 && RANK(3,x) >= 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if Up
                        x = find(RANK(1,:) == EL-1);
                        if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if Down
                        x = find(RANK(1,:) == EL+1);
                        if isempty(x) == 0 && RANK(3,x) >= 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if m <= 1 %Ist der Fall, falls höchstens 1 Nachbar vorhanden war
                        RANK(3,n) = -999;
                    else
                        RANK(3,n) = Summe/m;
                    end
                    RANK(4,n) = 1; %Merkt sich, dass Elektrode inaktiv war

                else
                    RANK(4,n) = 0;

                end
                %Überträgt Wert in R-Matrix
                R(mod(EL,10),fix(EL/10)) = RANK(3,n);

            end

            RI=interp2(R,5); %Interpolieren der Werte, damit ein "weicheres" Bild entsteht
           
      
            
            for x=1:8
                for y=1:8
                    if R(y,x) == -999
                        if y > 1
                            Up = true;
                        else
                            Up = false;
                        end
                        if y < 8
                            Down = true;
                        else
                            Down = false;
                        end
                        if x > 1
                            Left = true;
                        else
                            Left = false;
                        end
                        if x < 8
                            Right = true;
                        else
                            Right = false;
                        end
                        RI(y*32-31-Up*31:y*32-31+Down*31,x*32-31-Left*31:x*32-31+Right*31) = NaN;
                    end
                end
            end
                        
            
            
            % Plot anzeigen
            %figure('Name','Ausbreitungsrichtung eines Spikes','Color',[1 1 1])
            pcolor(RI);shading flat; colormap(jet);
            axis ij;
            axis off;
            title(['Spike ',num2str(spikenr)]);
            colorbar('location','EastOutside')          



            for n=1:size(RANK,2)             
                EL = RANK(1,n);
                if RANK(4,n) == 0
                    line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Tag','',...
                        'LineStyle','none','Marker','o',...
                        'MarkerSize',9);
                else                
                    line ('Xdata',fix(EL/10)*32-31,'Ydata', mod(EL,10)*32-31,'Tag','',...
                        'LineStyle','none','Marker','o',...
                        'MarkerFaceColor',[0 0 0],'MarkerSize',9);
                end                
            end



            dcm_obj = datacursormode(gcf);
            set(dcm_obj,'DisplayStyle','datatip',...
                'SnapToDataVertex','on','Enable','on','UpdateFcn',@DelayTag)            
        end
        
        
        if TF==0;                               % Routine für die Betrachtung der ersten 20 Spikes
            
            figure('Name','Ausbreitungsrichtung der ersten 20. Spikes');
            ELSALL = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
            spikenr = 1;
            while spikenr <= size(SPIKESCOPY,1) && spikenr <= 20
                close(gcbf);
                RANK(2,:) = SPIKESCOPY(spikenr,:);        % ausgewählten Spike betrachten
                
                
                %Füllt in RANK fehlende Elektroden auf
                
                for n=1:size(ELSALL,2)
                    if isempty(find(RANK(1,:) == ELSALL(n), 1))
                        RANK(:,n+1:end+1) = RANK(:,n:end);
                        RANK(1,n) = ELSALL(n);
                        RANK(2,n) = 0;
                    end
                end
                clear n;
                
                
                Min = min(nonzeros(RANK(2,:)));
                
                RANK(3,:) = RANK(2,:)-Min;
                
                % Ab hier die entsprechenden Maßnahmen für den cellplot!
                
                RANK(3,:) = RANK(3,:)*1000; % Die Zeitdifferenzen mal 1000 um sie in ms anzeigen zu können.
                
                
                % Markiert alle Elektroden anfangs mit Wert -999. Falls diese nicht belegt wurden, so kann später die -999 wiedererkannt werden
                R(1:8,1:8) = -999;
                
               
            for n=1:size(RANK,2)
                EL = RANK(1,n);
                if RANK(3,n) < 0
                    %Checkt, welche Nachbarelektroden vorhanden sind und
                    %merkt sich dies in Left,Right,Up,Down
                    if EL > 30 || EL > 20 && mod(EL,10) > 1 && mod(EL,10) < 8
                        Left = true;
                    else
                        Left = false;
                    end
                    if EL < 70 || EL < 80 && mod(EL,10) > 1 && mod(EL,10) < 8
                        Right = true;
                    else
                        Right = false;
                    end
                    if mod(EL,10) > 2 || mod(EL,10) > 1 && EL > 20 && EL < 80
                        Up = true;
                    else
                        Up = false;
                    end
                    if mod(EL,10) < 6 || mod(EL,10) < 8 && EL > 10 && EL < 80
                        Down = true;
                    else
                        Down = false;
                    end
                    
                    %Ermittelt Mittelwert aus benachbarten Elektroden (nur,
                    %wenn diese nicht auch inaktiv sind)
                    Summe = 0;
                    m = 0;
                    if Left
                        x = find(RANK(1,:) == EL-10);
                        if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if Right
                        x = find(RANK(1,:) == EL+10);
                        if isempty(x) == 0 && RANK(3,x) >= 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if Up
                        x = find(RANK(1,:) == EL-1);
                        if isempty(x) == 0 && RANK(3,x) >= 0 && RANK(4,x) == 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if Down
                        x = find(RANK(1,:) == EL+1);
                        if isempty(x) == 0 && RANK(3,x) >= 0
                            Summe = Summe + RANK(3,x);
                            m = m+1;
                        end
                    end
                    if m <= 1 %Ist der Fall, falls höchstens 1 Nachbar vorhanden war
                        RANK(3,n) = -999;
                    else
                        RANK(3,n) = Summe/m;
                    end
                    RANK(4,n) = 1; %Merkt sich, dass Elektrode inaktiv war

                else
                    RANK(4,n) = 0;
                    
                end
                %Überträgt Wert in R-Matrix
                R(mod(EL,10),fix(EL/10)) = RANK(3,n);
            end
            
            RI=interp2(R,5); %Interpolieren der Werte, damit ein "weicheres" Bild entsteht
            
            for x=1:8
                for y=1:8
                    if R(y,x) == -999
                        if y > 1
                            Up = true;
                        else
                            Up = false;
                        end
                        if y < 8
                            Down = true;
                        else
                            Down = false;
                        end
                        if x > 1
                            Left = true;
                        else
                            Left = false;
                        end
                        if x < 8
                            Right = true;
                        else
                            Right = false;
                        end
                        RI(y*32-31-Up*31:y*32-31+Down*31,x*32-31-Left*31:x*32-31+Right*31) = NaN;
                    end
                end
            end
            
            % Plot anzeigen
            subplot (4,5,spikenr);
            pcolor(RI);shading flat; colormap(jet);
            axis ij;
            axis off;
            title(['Spike Nr:',num2str(spikenr)]);
            
            spikenr = spikenr+1;
            end
            clear SPIKESCOPY Min;
            
        end
        clear RANK;
        clear m n Summe;
        clear Up Down Left Right;
        
        
        %Zeigt auf Mausklick Zeitdifferenz des gewählten Punktes zum rel.
        %Nullpunkt an
        function txt = DelayTag (~,event_obj)
            dcm_obj = datacursormode(gcf);
            %c_info = getCursorInfo(dcm_obj);
            pos = get(event_obj,'Position');
            txt = {RI(pos(2),pos(1))};                                               
        end
        
        
        
    end

    % --- ZeroOut - Anzeige eines Beispiels (CN)---------------------------
    function ZeroOutExampleButtonCallback(source,event) %#ok<INUSD>
          %Zeichne eine Beispieländerung von der zu Stimulierkennung ausgewählten Elektrode
          figure('Position',[150 50 1000 550],'Name','Example of artefactsupression of the first Stimuli','NumberTitle','off','Resize','off');                       
          plot(timePr,signal_draw(1,:),'k-')
          hold on
          plot(timePr,signalCorr_draw(1,:))
          title(['Electrode ' num2str(EL_NUMS(PREF(9))) ' - Artefactsupression - Black: original signal, Blue: signal after artefaktsupression']);
    end

    % --- Frequenzanalyse HMZ - Popupmenu für Parameterwahl (AD)----------- 
    function frequenzanalyseButtonCallback(source,event) %#ok 
      %alte ISIs löschen
      clear ISI
      
       fh = figure('Units','Pixels','Position',[350 400 400 500],'Name','Beating Rate','NumberTitle','off','Toolbar','none','Resize','off','menubar','none');   
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 370 360 100],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'String','Beating rate analysis for cardiac myocytes. Please select single, multi or complete analysis.');
       %---Einzelanalyse
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 360 200 20],'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Tag','CELL_electrodeLabel','String','Single Electrode Analysis','FontWeight','bold');
       uicontrol('Parent',fh,'Units','Pixels','Position', [20 330 75 25],'Tag','ISIcall1','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
       uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 320 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Einzelanalysecallfunction);
       %---Multianalyse für 5 Elektroden
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 265 200 30],'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Tag','CELL_electrodeLabel','String','Multi Electrode Analysis','FontWeight','bold');
       uicontrol('Parent',fh,'Units','Pixels','Position', [20 250 75 25],'Tag','ISIcall2','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',1,'Style','popupmenu');
       uicontrol('Parent',fh,'Units','Pixels','Position', [95 250 75 25],'Tag','ISIcall3','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',2,'Style','popupmenu');
       uicontrol('Parent',fh,'Units','Pixels','Position', [170 250 75 25],'Tag','ISIcall4','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',3,'Style','popupmenu');
       uicontrol('Parent',fh,'Units','Pixels','Position', [245 250 75 25],'Tag','ISIcall5','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',4,'Style','popupmenu');
       uicontrol('Parent',fh,'Units','Pixels','Position', [320 250 75 25],'Tag','ISIcall6','FontSize',8,'String',['El 12';'El 13';'El 14';'El 15';'El 16';'El 17';'El 21';'El 22';'El 23';'El 24';'El 25';'El 26';'El 27';'El 28';'El 31';'El 32';'El 33';'El 34';'El 35';'El 36';'El 37';'El 38';'El 41';'El 42';'El 43';'El 44';'El 45';'El 46';'El 47';'El 48';'El 51';'El 52';'El 53';'El 54';'El 55';'El 56';'El 57';'El 58';'El 61';'El 62';'El 63';'El 64';'El 65';'El 66';'El 67';'El 68';'El 71';'El 72';'El 73';'El 74';'El 75';'El 76';'El 77';'El 78';'El 82';'El 83';'El 84';'El 85';'El 86';'El 87'],'Value',5,'Style','popupmenu');
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 170 200 50],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',10, 'String','Select five electrodes.');
       uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 190 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Multianalysecallfunction);
       %---Komplettanalyse (alle Elektroden
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 140 200 20],'HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',9,'Tag','CELL_electrodeLabel','String','Complete Analysis','FontWeight','bold');
       uicontrol('Parent',fh,'style','text','units','Pixels','position', [20 65 200 50],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize',10, 'String','Analysis of all measured electrodes. Results will be shown tabular.');
       uicontrol(fh,'Style','PushButton','Units','Pixels','Position',[290 50 100 30],'String','Analyze','ToolTipString','Start Analysis','CallBack',@Komplettanalysecallfunction);
   
    
    end

    % --- Einzelanalyse der Frequenzen (AD)--------------------------------
    function Einzelanalysecallfunction(source,event) %#ok       
        %Hier die Parameter eingeben/ ermitteln

        ISI_elektrode=get(findobj(gcf,'Tag','ISIcall1'),'value');    %Elektrode, die ausgewertet werden soll.
        ISI_bin=0.1;       %Timebin für das Histogramm
     
        close(gcbf)

    % Dann gehts los: -----------------------------------------------
        ISI=zeros(2,3);
        n=1;
        ni=size(SPIKES);
        while(SPIKES(n+1,ISI_elektrode)>0 && n+1<ni(1,1))

          ISI(n,1)=SPIKES(n+1,ISI_elektrode);                                      %das sind die "Timestamps" 
          ISI(n,2)=(SPIKES(n+1,ISI_elektrode))-(SPIKES(n,ISI_elektrode));          %das sind die ISIs
          ISI(n,3)=1/(ISI(n,2));                                                   %und das die Frequenz zum jeweiligen Timestamp, ermittelt aus dem ISI

          n=n+1;
        end
 
        
       
% Artefaktentfernung: -----------------------------------------------
%      n=1;
% ni=size(SPIKES);
% while(n+1<ni(1,1))
      
%     i=1;
%     ii=size(ISI);
%     while(i+1<ii(1,1))
%         %if(ISI(i,1)==(SPIKES(n,ISI_elektrode-2)))
%         if ((ISI(i,1)>(SPIKES(n,ISI_elektrode+1)-2)) && (ISI(i,1)<(SPIKES(n,ISI_elektrode+1)+1)))
%       ISI(i,:)=[];
%         end
           
  
%       i=i+1;
%     end
       
% n=n+1;
% end        


% Und der Graph: --------------------------------------------------

figure('Position',[50 50 850 900]);

% Überschrift und Infos
        subplot(22,2,[1 2]);
        axis off;
        text(0,3,['Beating Rate Analysis (Cardiac Myocytes). Electrode:' num2str(EL_NUMS(ISI_elektrode))],'FontWeight','demi', 'Fontsize',12);
        text(0,2.2,num2str(full_path),'Fontsize',9);
        text(0,1.5,[fileinfo{1}],'Fontsize',9);
        
% das Messsignal
    scale = get(scalehandle,'value');   % Y-Skalierung festlegen                                
        switch scale
            case 1, scale = 50;
            case 2, scale = 100;
            case 3, scale = 200;
            case 4, scale = 500;
            case 5, scale = 1000;
        end
            subplot(22,2,[3 10]);
            plot(T,M(:,ISI_elektrode),'color','black');    
            xlabel('time / s'); ylabel('voltage / mV');
            axis([0 T(size(T,2)) -1*scale scale]);
            grid on;
            if spikedata==1
                    line ('Xdata',[0 T(length(T))],...                            
                        'Ydata',[THRESHOLDS(ISI_elektrode) THRESHOLDS(ISI_elektrode)],...
                        'LineStyle',':','Color','blue');
            end     

% den Spiketrain
        subplot(22,2,[13 14]);
        axis off;
        isi_dim=50;
        axis([0 T(size(T,2)) -1*isi_dim isi_dim]);
        SP = nonzeros(SPIKES(:,ISI_elektrode));
        y_axis = ones(length(SP),1).*isi_dim.*.9;
        line ([0 ;T(size(T,2))],[5 ; 5],...
             'LineStyle','-','Linewidth',20,'color','white','Marker','none');           
        for n=1:15
            line ('Xdata',SP,'Ydata', y_axis-(4*n+10),...
             'LineStyle','none','Marker','.',...
             'MarkerEdgeColor','black','MarkerSize',1); 
         end
         text(-3.5,-70,'spike-','rotation',90);
         text(-2.1,-70,'train','rotation',90);

% die Frequenz
        subplot(22,2,[15 22]);
        plot(ISI(:,1),ISI(:,3),'-k.')
        axis([0 T(size(T,2)) 0 (0.1+max(ISI(:,3)))*2]);
        xlabel('time / s'); ylabel('frequency / Hz');
        line([0 ;T(size(T,2))],[mean(ISI(:,3)) ; mean(ISI(:,3))],'LineStyle',':')

%die ISIs               
        subplot(22,2,[25 32]);
        plot(ISI(:,1),ISI(:,2),'-k.')
        axis([0 T(size(T,2)) 0 (0.1+max(ISI(:,2)))*2]);
        xlabel('time / s'); ylabel('ISI / s');
        line([0 ;T(size(T,2))],[max(ISI(:,2)) ; max(ISI(:,2))],'LineStyle',':')
        line([0 ;T(size(T,2))],[min(ISI(:,2)) ; min(ISI(:,2))],'LineStyle',':')

%die Messwerte
        subplot(22,2,[36 42]);
        axis off;
        text(0,0.9,['frequency (mean): ' num2str(mean(ISI(:,3))) 'Hz']);
        text(0,0.8,['frequency (sd): ' num2str(std(ISI(:,3)))]);
       
        %Berechnung des MADs:
            n=1; mad_temp=0;
            ni=size(ISI);
            while n+1<ni(1,1)
              mad_temp(n,1)=abs(ISI(n,3)-median(ISI(:,3)));
               n=n+1;
            end
            MAD_Andy=median(mad_temp);
        %ende
        
        text(0,0.6,['frequency (median): ' num2str(median(ISI(:,3))) 'Hz']);
        text(0,0.5,['frequency (MAD): ' num2str(MAD_Andy)]);     
        
        text(0,0.3,['ISI (mean): ' num2str(mean(ISI(:,2))) 's']);
        text(0,0.2,['ISI (sd): ' num2str(std(ISI(:,2)))]);
        text(0,0.0,['time bin: ' num2str(ISI_bin)]);

%das Histogramm        
        edges=0:ISI_bin:3;
        answer=histc(ISI(:,2), edges);
        subplot(22,2,[35 41]);
        bar(edges, answer)
        xlabel('ISI / s'); ylabel('counts /bin');
        %axis([(min(ISI(:,2)))*0.8 (max(ISI(:,2)))*1.2 0 (max(answer))*1.2]);

  
%Speicher aufräumen
            clear ISI;
            clear ISI_bin;
            clear ISI_elektrode;
            clear edges;
            clear answer;
            clear isi_dim;
     
        end

    % --- Frequenz vs. Zeit für bis zu 5 Kanäle (Multianalyse) (AD)--------
    function Multianalysecallfunction(source,event) %#ok<INUSD>
 
    %Hier die Parameter eingeben (Elektroden, die ausgewertet werden sollen
    %ISI_elektrode=[17;23;27;47;49]

    ISI_elektrode(1,1)=get(findobj(gcf,'Tag','ISIcall2'),'value');   
    ISI_elektrode(2,1)=get(findobj(gcf,'Tag','ISIcall3'),'value'); 
    ISI_elektrode(3,1)=get(findobj(gcf,'Tag','ISIcall4'),'value'); 
    ISI_elektrode(4,1)=get(findobj(gcf,'Tag','ISIcall5'),'value'); 
    ISI_elektrode(5,1)=get(findobj(gcf,'Tag','ISIcall6'),'value');        
    close(gcbf)
    
    % Dann gehts los: -----------------------------------------------
    for i=1:5
       ISI(1,1,i)=0; ISI(1,2,i)=0; ISI(1,3,i)=0; 
       ISI(2,1,i)=0; ISI(2,2,i)=0; ISI(2,3,i)=0;  
        
        n=1;
        ni=size(SPIKES);
        while(SPIKES(n+1,ISI_elektrode(i,1))>0 && n+1<ni(1,1))
          ISI(n,1,i)=SPIKES(n+1,ISI_elektrode(i,1));                                         %das sind die "Timestamps" 
          ISI(n,2,i)=(SPIKES(n+1,ISI_elektrode(i,1)))-(SPIKES(n,ISI_elektrode(i,1)));        %das sind die ISIs
          ISI(n,3,i)=1/(ISI(n,2,i));                                                           %und das die Frequenz zum jeweiligen Timestamp, ermittelt aus dem ISI
          n=n+1;
        end
    end
    
    % Und das "Ergebnisblatt"
    figure('Position',[60 60 850 900]);

    % Überschrift und Infos
    subplot(31,4,[1 4]);
    axis off;
    text(0,3,['Beating Rate Analysis (Cardiac Myocytes). Electrodes:' num2str(EL_NUMS(ISI_elektrode(:,1)))],'FontWeight','demi', 'Fontsize',12);
    text(0,2.2,num2str(full_path),'Fontsize',9);
    text(0,1.5,fileinfo{1},'Fontsize',9);

        for i=1:5
            % den Spiketrain
            subplot(31,4,[(9+(24*(i-1))) (11+(24*(i-1)))]);
            axis off;
            isi_dim=50;
            axis([0 T(size(T,2)) -1*isi_dim isi_dim]);
            SP = nonzeros(SPIKES(:,ISI_elektrode(i,1)));
            y_axis = ones(length(SP),1).*isi_dim.*.9;
            line ([0 ;T(size(T,2))],[5 ; 5],...
            'LineStyle','-','Linewidth',20,'color','white','Marker','none');           
            for n=1:15
                line ('Xdata',SP,'Ydata', y_axis-(4*n+10),...
                'LineStyle','none','Marker','.',...
                'MarkerEdgeColor','black','MarkerSize',1); 
            end
            text(-2.5,-50,'spike-','rotation',90,'Fontsize',7);
            text(-1.1,-50,'train','rotation',90,'Fontsize',7);
            
            % die Frequenz
            subplot(31,4,[13+24*(i-1) 23+24*(i-1)]);
            ISI_NZ1=nonzeros(ISI(:,1,i));
            % ISI_NZ2=nonzeros(ISI(:,2,i));    evtl für ISI Anzeige(?)
            ISI_NZ3=nonzeros(ISI(:,3,i));
            plot (ISI_NZ1(:,1),ISI_NZ3(:,1),'-k.')
            axis([0 T(size(T,2)) 0 ((max(ISI(:,3,i)))*2)+0.1]);
            xlabel('time / s'); ylabel('frequency / Hz');
            line([0 ;T(size(T,2))],[mean(ISI_NZ3(:,1)) ; mean(ISI_NZ3(:,1))],'LineStyle',':')
        
            %die Messwerte
            subplot(31,4,[16+24*(i-1) 28+24*(i-1)]);
            axis off;
            text(0,1.2,['Electrode ' num2str(EL_NUMS(ISI_elektrode(i,1)))],'FontWeight','demi');
            text(0,1,['frequency (mean): ' num2str(mean(ISI_NZ3(:,1))) 'Hz']);
            text(0,0.8,['frequency (sd): ' num2str(std(ISI_NZ3(:,1)))]);
            
            %Berechnung des MADs:
            mad_temp=0;
            n=1;
            ni=size(ISI_NZ3);
            while n+1<ni(1,1)
               mad_temp(n,1)=abs(ISI_NZ3(n,1)-median(ISI_NZ3(:,1)));
               n=n+1;
            end
            MAD_Andy=median(mad_temp);
       
            text(0,0.5,['frequency (median): ' num2str(median(ISI_NZ3(:,1))) 'Hz']);
            text(0,0.3,['frequency (MAD): ' num2str(MAD_Andy)]);    
            clear MAD_Andy mad_temp
        end
    end
  
    % --- Komplettanalyse der Rate für alle Kanäle (AD)--------------------
    function Komplettanalysecallfunction(source,event) %#ok<INUSD>
       close(gcbf)
       % Ergebnisblatt (Kopfzeilen)
          figure('Position',[60 60 850 900]);  
          axis off;
          text(-0.1,1.06,'Complete Analysis','FontWeight','demi', 'HorizontalAlignment', 'left');
          text(0.1,1.02,'mean (f)','FontWeight','demi', 'HorizontalAlignment', 'center');
          text(0.3,1.02,'sd (f)','FontWeight','demi', 'HorizontalAlignment', 'center');
          text(0.5,1.02,'median (f)','FontWeight','demi', 'HorizontalAlignment', 'center');      
          text(0.7,1.02,'mad (f)','FontWeight','demi', 'HorizontalAlignment', 'center');
          text(0.9,1.02,'no of spikes','FontWeight','demi', 'HorizontalAlignment', 'center');
        
          m=size(SPIKES);

        for i=1:m(1,2)
            n=1;
            ni=size(SPIKES);
            ISI(1,1,i)=0;
            ISI(1,2,i)=0;
            ISI(1,3,i)=0;
           while(SPIKES(n+1,i)>0 && n+1<ni(1,1))
              ISI(n,1,i)=SPIKES(n+1,i);                                          %das sind die "Timestamps" 
              ISI(n,2,i)=(SPIKES(n+1,i))-(SPIKES(n,i));                          %das sind die ISIs
              ISI(n,3,i)=1/(ISI(n,2,i));                                         %und das die Frequenz zum jeweiligen Timestamp, ermittelt aus dem ISI
              n=n+1;
           end


        %Berechnung des MADs:
           mad_temp=0;
           k=1;
           ki=size(nonzeros(ISI(:,3,i)));
            while k+1<ki(1,1)
               mad_temp(k,1)=abs(ISI(k,3,i)-median(ISI(:,3,i)));
               k=k+1;
            end
            MAD_Andy=median(mad_temp);
        %ende           
                 
        % --- Ergebnissdarstellung           
            tmpc=0.2; 
            if mod (i,2)==0  %Für bessere Lesbarkeit: unterschiedliche Farben
                tmpc=1;  
            end;  

            text(-0.1,(1-0.018*i),['El ' num2str(EL_NUMS(i))],'FontWeight','demi', 'HorizontalAlignment', 'left', 'color', [tmpc tmpc tmpc]);
            text(0.1,(1-0.018*i),[num2str(mean(ISI(:,3,i))) 'Hz'], 'HorizontalAlignment', 'right', 'color', [tmpc tmpc tmpc]);
            text(0.3,(1-0.018*i),num2str(std(ISI(:,3,i))), 'HorizontalAlignment', 'right', 'color', [tmpc tmpc tmpc]);
            text(0.5,(1-0.018*i),[num2str(median(ISI(:,3,i))) 'Hz'], 'HorizontalAlignment', 'right', 'color', [tmpc tmpc tmpc]);
            text(0.7,(1-0.018*i),num2str(MAD_Andy), 'HorizontalAlignment', 'right', 'color', [tmpc tmpc tmpc]);            
            text(0.9,(1-0.018*i),num2str(ki(1,1)), 'HorizontalAlignment', 'right', 'color', [tmpc tmpc tmpc]); 

        end
   clear MAD_Andy mad_temp

    end

    % --- Spiketrain (AD)--------------------------------------------------- 
    function spiketrainButtonCallback(source,event) %#ok<INUSD>
       ST_EL_Auswahl=0;
       spiketrainWindow = figure('Position',[25 40 600 700],'Tag','Spiketrain','Name','Spiketrain','NumberTitle','off','Toolbar','none','Resize','off','color','w');
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [0 580 600 120],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String',' ');
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [0 0 20 700],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String',' ');
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [580 0 20 700],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String',' ');
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [0 0 600 50],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String',' ');
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [25 620 300 50],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10, 'HorizontalAlignment','left','String','Enter electrode numbers (separated by space) for creating individual spiketrains!');
       
       %--- Elektrodeneingabe und Aktualisieren Button

       ST_ENDE_TAT=(T(size(T,2))+T(size(T,2))-T((size(T,2)-1)));       %erst Tatsächliches Ende der Messung ermitteln (letzter Zeitwert idR
                                                                        %59,9998sec nicht 60sec)
       uicontrol('Parent',spiketrainWindow,'style','edit','units','Pixels','position', [20 600 300 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','ST_CELL_electrode','string','12 13 14 15 16 17 21 22 23 24 25');
       uicontrol('Parent',spiketrainWindow,'Units','Pixels','Position', [450 660 130 20],'Tag','ST_WN','FontSize',8,'String','wide | narrow','Value',2,'Style','popupmenu');
       uicontrol(spiketrainWindow,'Style','PushButton','Units','Pixels','Position',[450 600 130 30],'String','Create...','ToolTipString','Creates Spiketrain','CallBack',@redrawspiketrain);
       uicontrol('Parent',spiketrainWindow,'style','edit','units','Pixels','position', [450 635 45 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','ST_start','string','0');
       uicontrol('Parent',spiketrainWindow,'style','edit','units','Pixels','position', [515 635 45 20],'HorizontalAlignment','left','FontSize',9,'FontSize',9,'Tag','ST_ende','string',ST_ENDE_TAT);
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [498 630 15 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',7, 'HorizontalAlignment','left','String','to');
       uicontrol('Parent',spiketrainWindow,'style','text','units','Pixels','position', [565 630 15 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',7, 'HorizontalAlignment','left','String','sec');
      
       % ---alle Spiketrains anzeigen (erste Ansicht/ Standard)---
       for i=1:nr_channel
           %anz_spikes=size(nonzeros(SPIKES(:,i)));
           subplot(70,5,[47+i*5 49+i*5]);
           axis off;
           axis([0 T(size(T,2)) -1*50 50]);
             line([0;0],[-100;100],...
                  'LineStyle',':','Linewidth',1,'color','blue','Marker','none'); 
             line([T(size(T,2));T(size(T,2))],[-100;100],...
                  'LineStyle',':','Linewidth',1,'color','blue','Marker','none'); 
           if SPIKES(1,i)>0;
                for m=1:size(nonzeros(SPIKES(:,i)))
                 line([nonzeros(SPIKES(m,i));nonzeros(SPIKES(m,i))],[-50;50],...
                  'LineStyle','-','Linewidth',1,'color','black','Marker','none'); 
                end
           end      
              subplot(70,5,46+5*i);
              axis off;
              text(0.8,-13.5,EL_NAMES(i),'FontSize',7);   
       end
    end 

    % --- Aktualisieren Button lässt individuelle Ansichten zu (AD)---------
    function redrawspiketrain(source,event) %#ok<INUSD>    
       ST_EL_Auswahl = get(findobj(gcf,'Tag','ST_CELL_electrode'),'string');   
       ST_view=get(findobj(gcf,'Tag','ST_WN'),'value');  
       ST_ELEKTRODEN = strread(ST_EL_Auswahl);  
       ST_EL_WAHL=zeros(60,2);
       ST_START=get(findobj(gcf,'Tag','ST_start'),'string');
       ST_ENDE=get(findobj(gcf,'Tag','ST_ende'),'string');

       for n = 1:length(ST_ELEKTRODEN)
             i = find(EL_NUMS==ST_ELEKTRODEN(n));
             
             if isempty(i)==1 
               errordlg('    Elektrodeneingabe fehlerhaft!');
               return
            end
             
             ST_EL_WAHL(n,1)=i;
             ST_EL_WAHL(n,2)=ST_ELEKTRODEN(n);
        end
       
        % alte Daten löschen
            subplot(70,5,[31 350]);
            cla;
            
    % --- selektiv Spiketrains anzeigen ---
        subplot(70,5,40+ST_view); axis off; cla;
        text(-0.2,0,[num2str(ST_START) ' sec'],'FontSize',8); 
        subplot(70,5,46-ST_view); axis off; cla;
        text(0.75,0,[num2str(ST_ENDE) ' sec'],'FontSize',8);          
          
      for i=1:length(ST_ELEKTRODEN)
        temp=ST_EL_WAHL(i,1);
        subplot(70,5,[45+ST_view+i*5 51+i*5-ST_view]);
        cla; axis off;
        axis([str2double(ST_START) str2double(ST_ENDE) -1*50 50]);
        
          
          if temp>0;       
            line([str2double(ST_START);str2double(ST_START)],[-100;100],...
                  'LineStyle',':','Linewidth',1,'color','blue','Marker','none'); 
            line([str2double(ST_ENDE);str2double(ST_ENDE)],[-100;100],...
                  'LineStyle',':','Linewidth',1,'color','blue','Marker','none');            
              
              if SPIKES(1,temp)>0;          
                for m=1:size(nonzeros(SPIKES(:,temp)))
                     line([nonzeros(SPIKES(m,temp));nonzeros(SPIKES(m,temp))],[-45;45],...
                       'LineStyle','-','Linewidth',1,'color','black','Marker','none'); 
                end
              end
          end
             if ST_view == 2
              subplot(70,5,51+5*i);
              axis off;
              text(0.8,-3.5,['El ' num2str(ST_ELEKTRODEN(i))],'FontSize',7);
             end 
       end

    end

    % --- Analyse der Netzwerkbursts in geöffneter Datei (CN)--------------
    function AnalyseNetworkburst(source,event) %#ok 
    h_bar2=waitbar(0.05,'Please wait - networkbursts are analysed...');
    numberfiles = 1;
    if SI_EVENTS ~= 0
        ORDER = cell(size(BURSTS,2),size(SI_EVENTS,2));
        BURSTTIME = zeros(size(BURSTS,2),size(SI_EVENTS,2));
 waitbar(0.1)
        for n=1:size(SI_EVENTS,2)           %Für jedes SBE
          eventpos = int32(SI_EVENTS(n)*SaRa);
          eventbeg=double(eventpos);
          while ACTIVITY(eventbeg) >= 1           %Suche nach dem Anfang des SI_Events
             eventbeg = eventbeg-1;    
          end
          eventtime = eventbeg/SaRa;
          xy = 0;
          yz = 1;
          t=1;
          tol = 1/(2*SaRa);
waitbar(0.25)   
            while(xy<=0.4)
                zz=1;
                [row,col] = find((BURSTS<(eventtime+xy+tol))&(BURSTS>(eventtime+xy-tol))); %Suche nach Elementen
                if isempty(col)  
                else
                    while zz<=length(col)                                    %für den Fall dass zwei Bursts exakt zeitglich auftreten 
                     ORDER(yz,n) = EL_NAMES(col(zz));
                     BURSTTIME(yz,n) = BURSTS(row(zz),col(zz));
                     yz = yz+1;                                             %nächster Burst
                     zz=zz+1;   
                    end
                end
                t=t+1;                    
                xy = xy+1/SaRa;
             end
        end  
waitbar(0.4)  
        %Berechnung der Kurvenform der Netzwerkbursts            
        [b,a] = butter(3,400*2/SaRa,'low');    % Butterworth-TP 5.Grades glättet die Kurve   
        ACTIVITY = filter(b,a,ACTIVITY);                                                                                 
        wait_time = int32(.5*SaRa);                     
        MAX = 0;
        time20_vor = 0;
        time80_vor = 0;
        time80_nach = 0;
        time20_nach = 0;
        Rise = 0;
        Duration = 0;
waitbar(0.5)     
        %Berechnung der Anstiegszeit, Fallzeit und Dauer der Netzwerkbursts
        for k=1:Nr_SI_EVENTS
            MAX(k) = ACTIVITY(int32(SI_EVENTS(k)*SaRa));      %suche y-Werte zu den Timestamps der Netzwerkbursts
            UG(k) = 0.2*MAX(k);                               %80%-Grenze des Maximums
            OG(k)= 0.8*MAX(k);                                %20%-Grenze des Maximums  
            
            countlimit(k)=0;
            for q=1:(10*wait_time)
                if ACTIVITY(int32(SI_EVENTS(k)*SaRa-q))<0.5
                    countlimit(k)=int32(SI_EVENTS(k)*SaRa-q); %#ok<*AGROW>
                        if countlimit(k)<= 0;
                          countlimit(k) = 1;
                        end                
                    break
                end
            end
waitbar(0.55)      
            for p=1:int32(SI_EVENTS(k)*SaRa-countlimit(k));                          %Suche nach Timestamps der 20%-Grenze vor dem Peak                                     
                    if ACTIVITY(int32(countlimit(k)+p-1))>= UG(k)
                     time20_vor(k) = (double(countlimit(k)+p-1)/SaRa);
                     break
                    end
            end
            
            for p=1:int32(SI_EVENTS(k)*SaRa-time20_vor(k)*SaRa)  %Suche nach Timestamps der 80%-Grenze vor dem Peak
                if ACTIVITY(int32(time20_vor(k)*SaRa+p-1))>= OG(k)
                    time80_vor(k) = (double(time20_vor(k)*SaRa+p-1))/SaRa;
                    break
                end
            end
waitbar(0.6)
            for p=1:int32(wait_time)                         %Suche nach Timestamps der 80%-Grenze nach dem Peak
                if ACTIVITY(int32(SI_EVENTS(k)*SaRa+p-1))<= OG(k)
                    time80_nach(k) = double(SI_EVENTS(k)*SaRa+p-1)/SaRa;
                    break
                end
            end
            
            for p=1:int32((2*wait_time)-(time80_nach(k)*SaRa-SI_EVENTS(k)*SaRa))  %Suche nach Timestamps der 20%-Grenze nach dem Peak
                if ACTIVITY(int32(time80_nach(k)*SaRa)+p-1)<= UG(k)
                    time20_nach(k) = double(time80_nach(k)*SaRa+p-1)/SaRa;
                    break
                end
            end
waitbar(0.7)
            Duration(k)= time20_nach(k)-time20_vor(k);
            Rise(k) = time80_vor(k)-time20_vor(k);
            Fall(k) = time20_nach(k)-time80_nach(k);
        end
 waitbar(0.8)       
        %Die interessanten Werte werden in einem Array gespeichert
        MinDuration = min(Duration); 
        MaxDuration = max(Duration);
        MeanDuration = mean(Duration);
        stdMeanDuration = std(Duration);
        MinRise = min(Rise);
        MaxRise = max(Rise);
        Meanrise = mean(Rise);
        stdMeanRise = std(Rise);
        MinFall = min(Fall);
        MaxFall = max(Fall);
        Meanfall = mean(Fall);
        stdMeanFall = std(Fall);
 waitbar(0.9)       
        %Zwischenwerte werden gelöscht
        clear Duration;
        clear Rise;
        clear Fall;

   end
 waitbar(1,h_bar2,'Complete.'); close(h_bar2);
        set(findobj(gcf,'Tag','CELL_exportNWBButton'),'Enable','on');
        
        if SI_EVENTS ~= 0
                %Erstelle ein Fenster für die Zusammenfassung
                mainNWB=figure('Position',[150 100 1000 500],'Name','Networkbursts','NumberTitle','off','Resize','off');

                subplot(2,1,1); 
                plot(T,ACTIVITY)
                axis([0 T(size(T,2)) -10 60])
                xlabel ('time / s');
                ylabel({'Number of active electrodes (blue)';'Maximum activity (green)'});
                title('Networkactivity','fontweight','b')

                for n=1:length(SI_EVENTS)   %Zeichnet die Maxima in figure
                     line ('Xdata',[SI_EVENTS(n) SI_EVENTS(n)],'YData',[-10 60],'Color','green');
                end   

                 %steigende Flanke 
                        Risepanel = uipanel('Parent',mainNWB,'Title','rising time 20%-80%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[130 40 256 200]);
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 130 120 30],'String','min time [s]');     
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 90 120 30],'String','max time [s]'); 
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 50 120 30],'String','average [s]'); 
                        uicontrol('Parent',Risepanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels', 'position', [5 10 140 30],'String','Standard deviation'); 

                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_1');
                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_2');         
                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_durch');         
                        uicontrol('Parent',Risepanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','trise_std');         

                        set(findobj(gcf,'Tag','trise_1'),'String',MinRise);
                        set(findobj(gcf,'Tag','trise_2'),'String',MaxRise);
                        set(findobj(gcf,'Tag','trise_durch'),'String',Meanrise);
                        set(findobj(gcf,'Tag','trise_std'),'String',stdMeanRise);

                        %fallende Flanke 
                        Fallpanel = uipanel('Parent',mainNWB,'Title','falling time 80%-20%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[390 40 256 200]);
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 130 120 30],'String','min time [s]');     
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 90 120 30],'String','max time [s]'); 
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 50 120 30],'String','average [s]'); 
                        uicontrol('Parent',Fallpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 10 140 30],'String','Standard deviation'); 

                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_1');
                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_2');         
                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_durch');         
                        uicontrol('Parent',Fallpanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tfall_std');         

                        set(findobj(gcf,'Tag','tfall_1'),'String',MinFall);
                        set(findobj(gcf,'Tag','tfall_2'),'String',MaxFall);
                        set(findobj(gcf,'Tag','tfall_durch'),'String',Meanfall);
                        set(findobj(gcf,'Tag','tfall_std'),'String',stdMeanFall);

                        %Dauer     
                        Durationpanel = uipanel('Parent',mainNWB,'Title','duration 20%-20%','FontSize',10,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[650 40 256 200]);
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 130 120 30],'String','min time [s]');     
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 90 120 30],'String','max time [s]'); 
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 50 120 30],'String','average [s]'); 
                        uicontrol('Parent',Durationpanel,'style','text','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'units','pixels','position', [5 10 140 30],'String','Standard deviation'); 

                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 142 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_1');
                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 102 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_2');         
                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 62 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_durch');         
                        uicontrol('Parent',Durationpanel,'Units','pixels','BackgroundColor','w','Position',[160 22 90 20],'style','edit','HorizontalAlignment','left','FontSize',10,'units','pixels','Tag','tdur_std');         

                        set(findobj(gcf,'Tag','tdur_1'),'String',MinDuration);
                        set(findobj(gcf,'Tag','tdur_2'),'String',MaxDuration);
                        set(findobj(gcf,'Tag','tdur_durch'),'String',MeanDuration);
                        set(findobj(gcf,'Tag','tdur_std'),'String',stdMeanDuration);
        end
    end

    %%%-----------------SPIKESORTING TIMO AREND-------------------------%%%
    %%%---------------------SPIKESORTING--------------------------------%%%

   % --- Maske für Spike Sorting (TA)-------------------------------------- 
   function sortingButtonCallback(source,event)%#ok<INUSD> 
        ClusterZuordnung_Assign=0;
        stellenberechnung=1;
        msec=1; %1,falls nichts ausgewählt wird, Standardeinstellung,andernfalls passt sich "msec" in Funktion "fensterbreite" an
        hSortingPopup = figure('Name','Spike Sorting','NumberTitle','off','Position',[200 300 720 320],'Toolbar','none');
        optionpanel=uipanel('Parent',hSortingPopup,'Units','pixels','Position',[290 0 430 320],'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(hSortingPopup,'Style', 'text','Position', [60 265 160 25],'String','Number of electrode','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(hSortingPopup,'Style', 'edit','Position', [105 230 40 25],'BackgroundColor',[1 1 1],'Tag','SpSoInputElNr');
        uicontrol(hSortingPopup,'Style', 'pushbutton','Position', [30 190 215 25],'String','Sort Spikes for chosen electrode','FontWeight','bold','Tag','choseelek','FontSize',10,'CallBack', @SpSoResults);
        uicontrol(hSortingPopup,'Style', 'pushbutton','Position', [30 85 210 25],'String','Spike Sorting: more Information','FontSize',10,'TooltipString','Get more Information about the applied method','CallBack',@moreInfo);
        uicontrol(hSortingPopup,'Style', 'pushbutton','Position', [105 40 60 25],'String','Cancel','FontSize',10,'CallBack', 'close');
        uicontrol (optionpanel,'Style','edit','Position',[260 25 40 20],'BackgroundColor',[1 1 1],'string','0','Tag','Fensterverschiebung');
        uicontrol(optionpanel,'Style', 'text', 'Position', [25 5 233 40],'String', 'Shift time window around spike-maximum:','FontSize',9,'TooltipString','Shifts time window around the entered time lag (e.g. 400µs). Positive time lag or negative time lag are possible, both relate to spike-maximum','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(optionpanel,'Style', 'text','Position', [300 30 25 15],'String','µs','FontSize',9,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(optionpanel,'Style', 'text','Position', [10 85 330 30],'String','Check whether spikes appear in refractory period within','FontSize',9,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(optionpanel,'Style', 'pushbutton','Position', [20 70 45 25],'String','Check','FontSize',9,'TooltipString','Checks how many spikes appear in a refractory period (entered time relates to spike-maximum!)','callback',@refractorycheck);
        uicontrol(optionpanel,'Style','edit','Position',[335 95 40 20],'BackgroundColor',[1 1 1],'string','1.5','Tag','checkrefractory');
        uicontrol(optionpanel,'Style', 'text','Position', [375 100 25 15],'String','ms','FontSize',9,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(optionpanel,'Style','edit','Position',[290 210 40 20],'BackgroundColor',[1 1 1],'BackgroundColor',[1 1 1],'string','5','Tag','overlappededit');
        uicontrol(optionpanel,'Style', 'text','Position', [330 215 25 15],'String','ms','FontSize',9,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol(hSortingPopup,'Style', 'text','Position', [360 265 140 25],'String', 'More options....','FontSize',11,'BackgroundColor',[0.8 0.8 0.8]);
        radiogroupwindow=uibuttongroup('Parent',optionpanel,'Visible','on','Units','Pixels','Position',[20 130 100 40],'BackgroundColor',[0.8 0.8 0.8],'BorderType','none','SelectionChangeFcn',@fensterbreite);%'BorderType','none'
        uicontrol('Parent',radiogroupwindow,'Units','pixels','Position',[1 25 220 25],'Style','radio','HorizontalAlignment','left','Tag','fensterbreite','String','window width 2ms','FontSize',9,'TooltipString','All spike data within 2ms are collected','BackgroundColor', [0.8 0.8 0.8],'value',1);
        uicontrol('Parent',radiogroupwindow,'Units','pixels','Position',[1 1 220 25],'Style','radio','HorizontalAlignment','left','Tag','fensterbreit','String','window width 1ms','FontSize',9,'TooltipString','All spike data within 1ms are collected','BackgroundColor', [0.8 0.8 0.8]);
        radiogroupoverlapped=uibuttongroup('Parent',optionpanel,'Visible','on','Units','Pixels','Position',[20 210 150 40],'BackgroundColor',[0.8 0.8 0.8],'BorderType','none','SelectionChangeFcn',@overlappedspikes);
        uicontrol('Parent',radiogroupoverlapped,'Units','pixels','Position',[1 25 220 20],'Style','radio','HorizontalAlignment','left','Tag','withoverlapped','String','with overlapped spikes','FontSize',9,'TooltipString','Includes all detected spikes','BackgroundColor', [0.8 0.8 0.8],'value',1);
        uicontrol('Parent',radiogroupoverlapped,'Units','pixels','Position',[1 1 265 20],'Style','radio','HorizontalAlignment','left','Tag','withoutoverlapped','String','remove overlapped spikes that appear within','FontSize',9,'TooltipString','Remove overlapped spikes within the entered time. Time relates to spike-maximum','BackgroundColor', [0.8 0.8 0.8]);
   end

   % --- Spike Sorting mit oder ohne überlappende Spikes (TA)--------------        
   function overlappedspikes(source,event)%#ok
         t=get(event.NewValue,'Tag');
         switch(t)
            case 'withoutoverlapped'
            stellenberechnung=2;              
            case 'withoverlapped' %alle Spikes gehen in die Analyse mit rein
            stellenberechnung=1;
         end 
   end
     
   % --- Größe Datenfenster Zusammenstellung der Spike-Vektoren (TA)-------
   function fensterbreite(source,event)%#ok
         t=get(event.NewValue,'Tag');
         switch(t)
            case 'fensterbreit'
            msec=0.5;
            case 'fensterbreite'
            msec=1;
         end
   end
         
   % --- Überprüfung welche Spikes in einer Refraktärzeit erscheinen (TA)--
   function refractorycheck(source,event)%#ok<INUSD>        
       ElNr=get(findobj(gcf,'Tag','SpSoInputElNr'),'String');
       ElekSPSO=strread(ElNr);
        if isempty (ElekSPSO)|| ElekSPSO >=88 ||ElekSPSO <12 ||ElekSPSO==18||ElekSPSO==81 %Wenn keine Elektrodennummer eingegeben wurde: Meldung.
           wrongedit=figure('Name','Error','NumberTitle','OFF','Position',[300 300 400 160]);
           uicontrol(wrongedit,'Style','Pushbutton','Position', [105 45 190 25],'String','OK','FontSize',10,'Callback','close');
           uicontrol(wrongedit,'Style','text','String','Entered no or not existing number of electrode!','Position', [50 100 300 35],'FontSize',11,'BackgroundColor',[0.8 0.8 0.8])
        else
           editrefrac=get(findobj(gcf,'Tag','checkrefractory'),'String');
           refractory=strread(editrefrac);%Ermittlung der Refraktärzeit welche vom Benutzer in msec eingegeben wurde
           refractory=refractory/1000;
           ElekSPSO=strread(ElNr);
           r=find(EL_NUMS==ElekSPSO);
           V=nonzeros(SPIKES(:,r)); %#ok
       
           if isempty(V)
                    nospikes=figure('Name','No Spikes!','NumberTitle','OFF','Position',[300 300 400 200]);
                    uicontrol(nospikes,'Style','Pushbutton','Position', [100 50 190 25],'String','OK','Callback','close');
                    uicontrol(nospikes,'Style','text','String','No spikes at this electrode!','Position', [50 100 300 35],'FontSize',11,'BackgroundColor',[0.8 0.8 0.8])
                else
                    tol=T(2)/100;
                    refractoryspikes=0;      
                    for i=1:1:length(V)
                        S(i,:)=find((T<(V(i,:)+tol))&(T>(V(i,:)-tol)));
                    end
                j=1;
                timelags=0;
                length(V);
                for u=2:1:length(V)
                diff=V(u)-V(u-1);
                    if diff <=refractory
                        refractoryspikes=refractoryspikes+1;%Zähler für Bestimmung der Anzahl von Spikes innerhalb einer Refraktärzeit
                        timelags(j,:)=diff;
                        RefracTimeStamp(j,:)=V(u);
                        j=j+1;
                    end
                end
                timelags=timelags*1000;
                [y,x]=size(timelags);%#ok
                if timelags==0
                      norefractorySpikes=figure('NumberTitle','OFF','Position',[300 300 400 200]);
                      uicontrol(norefractorySpikes,'Style','Pushbutton','Position', [100 50 190 25],'String','OK','Callback','close');
                      uicontrol(norefractorySpikes,'Style','text','String','No spikes appear during refractory period!','Position', [50 100 300 35],'FontSize',11,'BackgroundColor',[0.8 0.8 0.8])
                    elseif y<=20
                      refracfigure = figure('Name','Details of refractory periods','color',[1 1 1],'NumberTitle','off','Position',[350 200 410 450],'Toolbar','none');
                      uicontrol(refracfigure,'Style','Text','String','Time lag(s) to previous spike- maximum/ms','Position',[180 310 190 90],'BackgroundColor',[1 1 1],'Fontsize',9);
                      ui0=uicontrol(refracfigure,'Style','Text','String','spikes appear during a refractory period.','Position',[45 410 330 20],'BackgroundColor',[1 1 1],'Fontsize',11);
                      uicontrol(refracfigure,'Style','Text','String','Point(s) in time/s','Position',[40 380 120 20],'BackgroundColor',[1 1 1],'Fontsize',11);
                        if y==1
                           set(ui0,'String','spike appears during a refractory period.');
                        end
                      ui=uicontrol(refracfigure,'Style','Text','Position',[50 410 20 20],'BackgroundColor',[1 1 1], 'Fontsize',11,'FontWeight','bold');
                      set(ui,'String', refractoryspikes);
                      ui2=uicontrol(refracfigure,'Style','Text','Position',[240 0 50 355],'BackgroundColor',[1 1 1],'Fontsize',10);
                      set(ui2,'String', timelags);
                      ui3=uicontrol(refracfigure,'Style','Text','Position',[70 0 70 355],'BackgroundColor',[1 1 1],'Fontsize',10);
                      set(ui3,'String',RefracTimeStamp);
                    elseif y>21
                      refracfigure = figure('Name','Details of refractory periods','color',[1 1 1],'NumberTitle','off','Position',[350 50 410 650],'Toolbar','none');
                      uicontrol(refracfigure,'Style','Text','String','Time lag(s) to previous spike maximum/ms','Position',[180 500 190 90],'BackgroundColor',[1 1 1],'Fontsize',9);
                      uicontrol(refracfigure,'Style','Text','String','spikes appear during a refractory period.','Position',[45 610 330 20],'BackgroundColor',[1 1 1],'Fontsize',11);
                      uicontrol(refracfigure,'Style','Text','String','Point(s) in time/s','Position',[40 570 120 20],'BackgroundColor',[1 1 1],'Fontsize',11);
                      ui=uicontrol(refracfigure,'Style','Text','Position',[50 610 20 20],'BackgroundColor',[1 1 1], 'Fontsize',11,'FontWeight','bold');
                      set(ui, 'String', refractoryspikes);
                      ui2=uicontrol(refracfigure,'Style','Text','Position',[240 0 50 555],'BackgroundColor',[1 1 1],'Fontsize',9);
                      set(ui2, 'String', timelags);
                      ui3=uicontrol(refracfigure,'Style','Text','Position',[70 0 70 555],'BackgroundColor',[1 1 1],'Fontsize',9);
                      set(ui3,'String',RefracTimeStamp);
                    if y>40
                      set(ui2,'Fontsize',8);
                      set(ui3,'Fontsize',8);
                    end
                    if y>45
                      set(ui2,'Fontsize',7);
                      set(ui3,'Fontsize',7);
                    end
                end
           end
        end
   end
   
   % --- Hilfefunktion für Spike Sorting ("first page" ohne Inhalt)(TA)----
   function moreInfo(source,event) %#ok<INUSD>
       deleteCheck=0;
       infoFirstpage=figure('color',[1 1 1],'Position',[150 25 710 700],'NumberTitle','off','toolbar','none');
       info
   end

   % --- Hilfefunktion für Spike Sorting 1. Seite (TA)--------------------- 
   function info(source,event)%#ok<INUSD>
        if deleteCheck==1
          clf(infoFirstpage)
        end
        set(infoFirstpage,'Name','Applied Spike Sorting method (page 1/2)')
        uicontrol(infoFirstpage,'Position',[10 10 690 670],'HorizontalAlignment','left','style','text','String','Spike Sorting is a method to identify the number of neurons which generate signals on an electrode and to assign the detected spikes to corresponding neurons. Important for this task is the fact that detected spikes of one neuron are still identical concerning its shape features. The identification of the number of neurons needs a feature extraction of the spikes, so that equal spikes, belonging to one neuron, are sorted together. There are several mathematical models to realize this coherence, amongst others the principal Component Analysis. This kind of mathematical transformation is applied here.','FontSize',10,'BackgroundColor', [1 1 1]);
        uicontrol(infoFirstpage,'Position',[10 10 650 550],'style','text','String','Principal component analysis (PCA)','FontSize',10,'FontWeight','bold','BackgroundColor', [1 1 1])
        uicontrol(infoFirstpage,'Position',[10 10 690 520],'HorizontalAlignment','left','style','text','String','Starting point of the PCA is a matrix containing objects and features (e.g. temperatures or voltage values). Each column contains a feature (here a voltage sample), the rows equates to the number of the examine objects (here the spikes). Depending on the sample rate, every spike consists of a corresponding number of voltage samples. The PCA summarizes the features per object (spike) on condition that essential features, which distinguish the spikes, are more weighted. The most important feature to distinguish the spikes is the amplitude. After the first principal component analysis every single spike is characterized by a single value. This value makes a distinction best of all. Under mathematical conditions, the second principal component analysis also calculates a single value per spike. This value makes also a distinction, but not as good as the first value. Two or maximal three values per spike suffice to account at least 85 per cent of the variance. Depending on the number of values per spike the result will be 2 or 3-dimensional scatterplot. Every dot equates to a spike. Generated by one neuron there are sorted in one cluster. Ideally, one cluster only consists of spikes generated by the same neuron. To get better graphical results the options before the PCA should be changed. The more values per Spike exist the more exactly is the graphical result. Furthermore, this result can be improved by changing the options in the “Spike Sorting”-Popup.','FontSize',9,'BackgroundColor', [1 1 1])
        uicontrol(infoFirstpage,'Position',[10 10 690 320],'style','text','String','Pop-up „Spike Sorting“','FontSize',9,'FontWeight','bold','BackgroundColor', [1 1 1])
        uicontrol(infoFirstpage,'Position',[10 10 690 290],'HorizontalAlignment','left','style','text','String','The figure called “spike sorting“ (opens after the click on the Spike sorting button) allows to select the electrode and to choose more options:','FontSize',9,'BackgroundColor', [1 1 1])        %Hier auch rein das kritisch überlappende Spikes, die sich als Ausreißer bemerkbar
        uicontrol(infoFirstpage,'Position',[10 10 690 255],'HorizontalAlignment','left','style','text','String','Overlapped spikes','FontSize',9,'BackgroundColor', [1 1 1])        %Hier auch rein das kritisch überlappende Spikes, die sich als Ausreißer bemerkbar
        uicontrol(infoFirstpage,'Position',[10 10 690 235],'HorizontalAlignment','left','style','text','String','Outliers in the Scatterplot (dots, which clearly do not belong to a cluster) are mostly the consequence of overlapping spikes. This basic spike sorting problem occurs if signals of two close-by neurons fired synchrone or with a small delay. Both spikes sum up and as a result, a new spike shape appear. These kinds of spikes will probably appear as outliers in scatterplot and contain no information. Problems occur at cluster analysis because an outlier will be detected as a single cluster. At least, this function removes spikes which appear within the entered time and delete them in the scatterplot. Maybe the entered time must be changed.','FontSize',9,'BackgroundColor', [1 1 1])   
        uicontrol(infoFirstpage,'Position',[10 10 690 130],'HorizontalAlignment','left','style','text','String','Window width','FontSize',9,'BackgroundColor', [1 1 1])
        uicontrol(infoFirstpage,'Position',[10 10 690 110],'HorizontalAlignment','left','style','text','String','The window width indicates which time range covers a spike to collect its voltage values. Relating to the spike maximum, the time window collects all voltage values 1ms forward and 1ms back. The number of these values depends on the sample rate. With a 10 kHz sample rate for example, one Spike consists of 21 values: The maximum and 10 values per millisecond forward and back, respectively. Depending on the spike shape, the 2ms time range maybe contains some noise. For a high sample rate, the "1ms –window“ is more appropriate. Related to the spike maximum it covers only the spike and nearly no noise. Because of the high sample rate, there are enough values per spike to collect important features.','FontSize',9,'BackgroundColor', [1 1 1])
        uicontrol(infoFirstpage,'Position',[650 10 60 20],'HorizontalAlignment','left','style','pushbutton','string','Next page','callback',@infoNextpage)
        deleteCheck=0;
   end

   % --- Hilfefunktion für Spike Sorting 2. Seite (TA)---------------------      
   function infoNextpage(source,event)%#ok<INUSD>
         deleteCheck=1;
         clf(infoFirstpage)
         set(infoFirstpage,'Name','Applied Spike Sorting method (page 2/2)')
         uicontrol(infoFirstpage,'Position',[10 10 690 670],'HorizontalAlignment','left','style','text','String','Check refractory period','FontSize',9,'BackgroundColor', [1 1 1])
         uicontrol(infoFirstpage,'Position',[10 10 690 650],'HorizontalAlignment','left','style','text','String','Not important for the algorithm but this function allows getting an idea whether spikes occur in a refractory period. This check is primarily an assistance to assert that there are definitely more than one neuron. As a result, the times are shown when a spike occurs in a refractory period and also the time lag between both spike maxima. Furthermore, it allows to analyze whether one signal is always followed by another, probably a communicating adjacent neuron.','FontSize',9,'BackgroundColor',[1 1 1])     
         uicontrol(infoFirstpage,'Position',[10 10 690 570],'HorizontalAlignment','left','style','text','String','Shift time window','FontSize',9,'BackgroundColor', [1 1 1])
         uicontrol(infoFirstpage,'Position',[10 10 690 550],'HorizontalAlignment','left','style','text','String','By default, the time window relates to the spike maximum. Shifting the time window allows to cover spike features that appear at the end or the beginning of the spike trace. Considered physiological, the end of a spike trace contains the biological hyperpolarization of the action potential. If all spikes nearly have the same amplitude (that means neurons have the same distance to the electrode) the trace of the hyperpolarization will probably be an important feature to classify. A negative value will shift the time window back and a positive value will shift the time window forward. A click on the "Details"-button will show the covered spike shapes.','FontSize',9,'BackgroundColor',[1 1 1])  
         uicontrol(infoFirstpage,'Position',[10 10 690 450],'style','text','String','Pop-up "Spike Sorting: Scatterplot"','FontSize',9,'FontWeight','bold','BackgroundColor', [1 1 1])    
         uicontrol(infoFirstpage,'Position',[10 10 690 420],'HorizontalAlignment','left','style','text','String','This 2 or 3-dimensional scatterplot shows the results of the PCA. The plot should be viewed from different angles to find distinguishable clusters. The resulting number must be entered by the user and the „Apply cluster analysis“-Button will sort the dots in terms of colour. After cluster analysis, the user can handle the result and change the assignments. All dots that should be assigned to another cluster must be collected. Therefore every click on a dot (the coordinates are shown) must be followed by the button „Add dot“. The number of the clusters can be decreased around one, so that a cluster can completely dissolving and all dots assigned to other clusters. Afterwards, the dot is marked so that the user knows which dot is collected. The „Restore“-button allows to delete the choice. When all chosen dots are marked, the new number of cluster must be entered followed by a click on „Assign & draw new“. To improve the results, the PCA must be started again and the options or the entered number of distinguishable clusters must be varied.','FontSize',9,'BackgroundColor', [1 1 1]) 
         uicontrol(infoFirstpage,'Position',[10 10 690 260],'style','text','String','Pop-up "Assign cluster to corresponding neuron"','FontSize',9,'FontWeight','bold','BackgroundColor', [1 1 1])     
         uicontrol(infoFirstpage,'Position',[10 10 690 230],'HorizontalAlignment','left','style','text', 'String','Depending on the number of clusters, the real results of spike sorting show the signals of every neuron. The number of clusters equates to the number of neurons, each with its own waveform. As additional options the user can choose to draw the threshold, to mark the signals of the neurons in the original waveform and to change the y-axis or zoom the x-axis.','FontSize',9,'BackgroundColor',[1 1 1])     
         uicontrol(infoFirstpage,'Position',[10 10 690 140],'HorizontalAlignment','left','style','text','String','Remarks','FontSize',9,'BackgroundColor', [1 1 1],'FontWeight','bold')
         uicontrol(infoFirstpage,'Position',[10 10 690 120],'HorizontalAlignment','left','style','text','String','The number of values of the spike trace should be at least 20. Otherwise putative clusters get too merged. Furthermore, a high number of spikes at the electrode will form better clusters. Spike Sorting can only be done with some degree of reliability.','FontSize',9,'BackgroundColor', [1 1 1])
         uicontrol(infoFirstpage,'Position',[650 10 60 20],'HorizontalAlignment','left','style','pushbutton','string','Back','callback',@info)
   end

   % --- Ermittlung aller relevanten Parameter für die Berechung des...----
   % --- ...Streudiagramms als Ergebnis der Hauptkomponentenanalyse (TA)---
   function SpSoResults(source, event)%#ok<INUSD>
         ElNr= get (findobj(gcf,'Tag','SpSoInputElNr'),'String');
         ElekSPSO = strread(ElNr);
         Copy_ElekSPSO=ElekSPSO;
         empt=isempty(ElekSPSO); 
         editrefrac=get(findobj(gcf,'Tag','checkrefractory'),'String');
         Copy_refractory=strread(editrefrac);%Ermittlung der Refraktärzeit welche vom Benutzer in msec eingegeben wurde
         Copy_refractory=Copy_refractory/1000;
          r=find(EL_NUMS==ElekSPSO);
          V=nonzeros(SPIKES(:,r)); %#ok
            if stellenberechnung==1 && empt==0 && ElekSPSO <88 && ElekSPSO >=12 && ElekSPSO~=18 && ElekSPSO~=81 
               ElNr= get(findobj(gcf,'Tag','SpSoInputElNr'),'String');
               ElekSPSO=strread(ElNr);
               r=find(EL_NUMS==ElekSPSO);
               SpikeTimes=nonzeros(SPIKES(:,r)); %#ok
               tol=T(2)/100; %Toleranz-Berechung zum Finden der Stellen...
               S=0; %Muss genullt werden damit im weiteren Durchlauf wieder komplett neu aufgefüllt wird
                    for i=1:1:length(V)
                        S(i,:)=find((T<(V(i,:)+tol))&(T>(V(i,:)-tol)));%S enthält die Stellen an denen Spike Maxima gefunden werder
                    end
               SpikeMaxima_Stellen=S;
            elseif stellenberechnung==2 && empt==0 && ElekSPSO <88 && ElekSPSO >=12 && ElekSPSO~=18 && ElekSPSO~=81 
               overl= get(findobj(gcf,'Tag','overlappededit'),'String'); 
               overlapptime=strread(overl);
               overlapptime=overlapptime/1000;
               ElNr=get(findobj(gcf,'Tag','SpSoInputElNr'),'String');
               ElekSPSO=strread(ElNr);
               r=find(EL_NUMS==ElekSPSO);
               V=nonzeros(SPIKES(:,r)); %#ok
               tol=T(2)/100;
        
                    for i=1:1:length(V)
                     S(i,:)=find((T<(V(i,:)+tol))&(T>(V(i,:)-tol)));
                    end
                    for u=2:1:length(V)
                    diff=V(u)-V(u-1);
                        if diff <=overlapptime
                        S(u)=0;
                        end
                    end
                S=nonzeros(S);
            end          
         %----Es folgt die Berechnung der Verschiebung um das negative Spike-Maximum               
         v=get(findobj(gcf,'Tag','Fensterverschiebung'),'String');
         verschiebung=strread(v);
         verschiebung=round((verschiebung*(1/T(2))/1000)/1000); %Umrechung der eingegebenen Zeitdifferenz in die entsprechende Anzahl der zu rückenden Stellen      
         if isempty(verschiebung)
            verschiebung=0;
         end
        
         ElNr=get(findobj(gcf,'Tag','SpSoInputElNr'),'String');
         ElekSPSO=strread(ElNr) ; %ElekSPSO ist die eingegebene Nummer der Elektrode.
          if isempty(ElekSPSO)|| ElekSPSO >=88 ||ElekSPSO <12 ||ElekSPSO==18||ElekSPSO==81 %Wenn keine Elektrodennummer eingegeben wurde: Meldung.
            wrongedit=figure('Name','Error','NumberTitle','OFF','Position',[300 300 400 160]);
            uicontrol(wrongedit,'Style','Pushbutton','Position', [105 45 190 25],'String','OK','FontSize',10,'Callback','close');
            uicontrol(wrongedit,'Style','text','String','Entered no or not existing number of electrode!','Position', [50 100 300 35],'FontSize',11,'BackgroundColor',[0.8 0.8 0.8])
          else
          SPIKESORTING %Wenn korrekte Elektrodennumer eingegeben wurde, wird Funktion SPIKESORTING aufgerufen
          end
   end

   % --- Durchführung der Hauptkomponentenanalyse (PCA)...-----------------
   % --- ...der die Extraktion der Spike-Merkmale (TA)---------------------
   function SPIKESORTING(source, event)%#ok<INUSD>   
       r=find(EL_NUMS==ElekSPSO); %entsprechend eingebener Elektrodenname umwandeln in Spalte der Messdaten Matrix M
       %r ist Spalte der Matrix M
       V=nonzeros(SPIKES(:,r));%in entsprechende Spalte in Timestamps (globaler Vektor SPIKES) werden alle Nullen entfernt           
         if isempty (V)
            noElectrode=figure('Name','No spikes!','NumberTitle','OFF','Position',[300 300 400 160]);
            uicontrol(noElectrode,'Style','Pushbutton','Position', [100 50 190 25],'String','OK','Callback','close');
            uicontrol(noElectrode,'Style','text','String','No spikes at this electrode!','Position', [50 100 300 35],'FontSize',11,'BackgroundColor',[0.8 0.8 0.8])
         else
        %Es folgt die Berechung des "data-Window": Gefundene Spannungswerte werden in Matrix (Name: "D") gespeichert für PCA
            [a,b]=size(S);%#ok
            S=S+verschiebung;%Verschiebung kommt nur hier in Frage, alle anderen Funktionen die die Stellen benötigen sind von Verschiebung unabhängig 
            dv=M(:,r);%Datenvektor dv enthält Rauschen+Spikes der ausgewählten Elektrode
            chosenThreshold=THRESHOLDS(:,r);%Für später in de Darstellung der einzelenen Wellenformen nach Clusteranalyse wichtig
            k=msec/(T(2)*1000);%Bestimmung der Werte innerhalb einer Fensterbreite abh. von der Abtastfrequenz
            k=round(k); % k ist die Anzahl der Werte die nach einer Seite hin vom negat. Spike-Maximum aus aufgenommen werden (Breite des Datenfensters)
            ValuesinWindow=k*2+1; %Globale Variable für später der einzelenen Spikedarstellungen notwendig.
            
        % Es folgt eine große For-Schleife, die nach und nach die einzelnen Stellen der auftretenden Spikes abarbeitet
                for p=1:1:a %läuft so oft durch wie "S" Zeilen a hat, also die Anzahl der Spike-Stellen
                    u=S(p,:); 
                    z=1;
                        for j=(S(p,:)-k):1:u %Schleife läuft vom Anfang des Spikes bis zum Maximalwert,(S(p,:)-k) ist der Maximalwert (Spitze des Spikes) minus die Fensterbreite, also Startpunkt
                            s(z,:)=dv(j,:); %Vektor s enthält nach Schleifendurchläufe alle Werte "links" neben dem Maximum bis zur Fensterbreite
                            z=z+1;
                        end
                    z=1;
                        for i=(u+1):1:(u+k) %diese Schleife ist für den "rechten" Teil neben dem Maximum zuständig: Startwert ist ein Wert weiter als der Maximalwert, daher r+1,Endwert ist der MAximalwert plus Fensterbreite
                            f(z,:)=dv(i,:); %Vektor f enthält nach Schleifendurchläufe alle Werte "rechts" neben dem Maximum bis zur Fensterbreite
                            z=z+1;
                        end                 
                        L((1:(k+k+1)))=[s(:,1); f(:,1)]; %Vektor L fügt f und s so zusammen, dass die Werte in entsprechd richtiger Reihenfolge sind, d.h. Spike Startwert über Maximum bis Spike Endwert.                           
                        R(p,:)=L'; %R wird zeilenweise mit "L-Vektoren" aufgefüllt. Die einzelnen "L-Vektoren" sind die Daten der Spikes. 
                end 
                A=R; %notwending, sonst gibt es Probleme
                SpikeShapes=A';

        %---------- Es folgt die Hauptkomponentenanalyse-------------------
        [n,p] = size(A);%#ok
        %n ist die Anzahl der Spikes, 
        %p ist die Anzahl der Merkmale pro Spike, das heißt die Abtatstungen
        Am=mean(A);%Mittelwertberechnung von Ausgangsmatrix
        Ac=A-repmat(Am,n,1);            %Mittenzentrierung der Ausgangsmatrix
        [~,sigma,coeff] = svd(Ac);      %(vorher [U,sigma,coeff]) Aufruf Funktion "Singulärwertzerlegung"
        S=diag(sigma);                  %S ist ein Vektor und enthält die Diagonalelemente der Matrix sigma. S wird später benötigt für die Berechnung der Eigenwerte.
        eigv=coeff;

        %Es folgt eine verschachtelte Schleife für die Score-Berechnung (basiert auf die Bildung einer Linearkombination, eigentliche Ergebnisse der Hauptkomponentenanalyse)
         [q,w]=size(eigv);
                for j=1:1:w
                    s=0;
                    p=eigv(:,j);
                        for i=1:1:q
                            t=Ac(:,i); %t ist jeweils die entsprechende i-te Spalte der mittenzentrierten Matric Ac
                            s=s+t*p(i);%Berechnung der Linearkombination, dh. hier wird pro Durchlauf ein "s"-Vektor berechnet
                        end
                    score(:,j)=s; %hier wird "score" als Matrix  mit den einzelnen "s"-Vektoren aufgefüllt. Wichtig für plotten.  
                end
         latent=S.^2; %Berechnung der Eigenwerte aus den Singulärwerten (für weitere Informationen siehe Quellcode von svd.m)
         %Es folgt die Berechnung der erklärten Varianz, verbunden mit der entsprechenden graphischen Darstellung (entweder 2D oder 3D, d.h. entweder die ersten beiden oder die ersten 3 Hauptkomponenten)
         [x,y]=size(latent);%#ok
         Score_values=score;%Für Funktion in Clusteranalyse notwendig
         h=0;
         delete(gcf)
               for j=1:1:x
                    v=(latent./sum(latent))*100; %Aufsummierung der erklärten Varianzen pro Hauptkomponente  
                    t=cumsum(latent./sum(latent))*100;
                    h=h+v(j,1);
                    accountedVariance2=round(t(2).*10)/10;
                    accountedVariance3=round(t(3).*10)/10;                  
                    if h>=85 %Es müssen mindestens 85% der gesamten Verianz der Ausgangsdaten durch Hauptkomponenten abdeckt sein, sonst zweite if-Schleife mit einer weiteren Hauptkomponente im 3D-Plot.
                              if j<=2  %maximal zwei Schleifendurchläufe: dann erklären dieie ersten beiden Hauptkomponenten bereits mindestens 85% der Varianz
                                Anzahl_Score=score(:,1:2);
                                %es folgt die Figure für Clusteranalyse, hier schon notwendig    
                                scatterwindow=figure('Position',[100 100 700 600],'Name','Spike Sorting: Scatterplot','NumberTitle','off');
                                Clusterpaneltop=uipanel('Parent',scatterwindow ,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[0 490 700 110]);
                                uicontrol('Parent',Clusterpaneltop,'style','text','units','Pixels','position', [5 65 260 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',12, 'HorizontalAlignment','left','String','Number of distinguishable clusters:','ToolTipString','For clusteranalysis enter the number of distinguishable Clusters (minimum from 2, maximum 4)');
                                uicontrol('Parent',Clusterpaneltop,'style','edit','string','2','units','Pixels','position', [255 60 35 25],'BackgroundColor',[1 1 1],'FontSize',9,'Tag','NumberCluster');
                                uicontrol('Parent',Clusterpaneltop,'Style','PushButton','Units','Pixels','Position',[5 20 150 25],'FontSize',9,'FontWeight','bold','Tag','Apply_Cluster','String','Apply cluster analysis','ToolTipString','Performs clusteranalysis in respect of the entered number of cluster ','CallBack',@ClusterAnalysis);
                                handle_Add=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[430 20 65 25],'string','Add dot','FontWeight','bold','ToolTipString','Every dot that should be assigned to the new cluster must be clicked on (coordinates are shown) and followed by a click on this button.');
                                handle_restore=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[600 10 55 25],'string','restore');
                                handle_draw=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[570 48 120 25],'string','Assign & draw again');
                                handle_assign=uicontrol('Parent',Clusterpaneltop,'Style','PushButton','Units','Pixels','Position',[160 20 155 25],'FontSize',9,'FontWeight','bold','enable','off','String','Show single waveforms','ToolTipString','Assign every cluster to a single waveform');
                                uicontrol('Parent',Clusterpaneltop,'style','edit','units','Pixels','position', [530 50 20 20],'BackgroundColor',[1 1 1],'enable','off','FontSize',9,'Tag','ToCluster');
                                uicontrol('Parent',Clusterpaneltop,'style','text','units','Pixels','position', [360 55 170 15],'BackgroundColor',[.8 .8 .8],'FontSize',9,'Tag','stringMarkedDots','enable','off','HorizontalAlignment','left','String','Assign marked dots to cluster:');
                                uicontrol('Parent',Clusterpaneltop,'style','text','units','Pixels','position', [440 85 250 20],'BackgroundColor',[.8 .8 .8],'FontSize',12,'Tag','string_HandleCluster','enable','off','HorizontalAlignment','left','String','Handle cluster assignement');            
                                Clusterpanelbot=uipanel('Parent',scatterwindow ,'BackgroundColor',[.8 .8 .8],'Units','pixels','Position',[0 0 700 490]); 
                                uicontrol('Parent',Clusterpanelbot,'Style','PushButton','String','Details','Units','Pixels','Position',[10 450 50 30],'FontSize',9,'FontWeight','bold','String','Details','ToolTipString','Show details concerning spike sorting results','CallBack',@DetailSpikeSorting);
                                subplot(1,1,1,'Parent',Clusterpanelbot)
                                scatter(score(:,1),score(:,2),30,'filled');
                                rotate3d on 
                                xlabel('1. principal component')
                                ylabel('2. principal component')
                                title('The first 2 principal components');
                              end
           
                              if j>=3%mindestens drei Schleifendurchläufe: die ersten drei Hauptkomponenten werden im 3D-Scatterplot dargestellt.
                                Anzahl_Score=score(:,1:3);
                                %es folgt die Figure für Clusteranalyse, hier schon notwendig          
                                scatterwindow=figure('Position',[100 100 700 600],'Name','Spike Sorting: Scatterplot','NumberTitle','off');
                                Clusterpaneltop=uipanel('Parent',scatterwindow ,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[0 490 700 110]);
                                uicontrol('Parent',Clusterpaneltop,'style','text','units','Pixels','position', [5 65 260 20],'BackgroundColor',[0.8 0.8 0.8],'FontSize',12, 'HorizontalAlignment','left','String','Number of distinguishable clusters:','ToolTipString','For clusteranalysis enter the number of distinguishable Clusters (minimum from 2, maximum 4)');
                                uicontrol('Parent',Clusterpaneltop,'style','edit','string','2','units','Pixels','position', [255 60 35 25],'BackgroundColor',[1 1 1],'FontSize',9,'Tag','NumberCluster');
                                uicontrol('Parent',Clusterpaneltop,'Style','PushButton','Units','Pixels','Position',[5 20 150 25],'FontSize',9,'FontWeight','bold','Tag','Apply_Cluster','String','Apply cluster analysis','ToolTipString','Performs cluster analysis in respect of the entered number of clusters ','CallBack',@ClusterAnalysis);
                                handle_Add=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[430 20 65 25],'string','Add dot','FontWeight','bold','ToolTipString','Every dot that should be assigned to the new cluster must be clicked on(coordinates are shown) and followed by a click on this button.');
                                handle_restore=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[600 10 55 25],'string','Restore');
                                handle_draw=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[570 48 120 25],'string','Assign & draw again');
                                handle_assign=uicontrol('Parent',Clusterpaneltop,'Style','PushButton','Units','Pixels','Position',[160 20 155 25],'FontSize',9,'FontWeight','bold','enable','off','String','Show single waveforms','ToolTipString','Assign every cluster to a single waveform');
                                uicontrol('Parent',Clusterpaneltop,'style','edit','units','Pixels','position', [530 50 20 20],'BackgroundColor',[1 1 1],'enable','off','FontSize',9,'Tag','ToCluster');
                                uicontrol('Parent',Clusterpaneltop,'style','text','units','Pixels','position', [360 55 170 15],'BackgroundColor',[.8 .8 .8],'FontSize',9,'Tag','stringMarkedDots','enable','off','HorizontalAlignment','left','String','Assign marked dots to cluster:');
                                uicontrol('Parent',Clusterpaneltop,'style','text','units','Pixels','position', [440 85 250 20],'BackgroundColor',[.8 .8 .8],'FontSize',12,'Tag','string_HandleCluster','enable','off','HorizontalAlignment','left','String','Handle cluster assignement');            
                                Clusterpanelbot=uipanel('Parent',scatterwindow ,'BackgroundColor',[.8 .8 .8],'Units','pixels','Position',[0 0 700 490]); 
                                uicontrol('Parent',Clusterpanelbot,'Style','PushButton','Units','Pixels','Position',[10 450 50 30],'FontSize',9,'FontWeight','bold','String','Details','ToolTipString','Show details concerning spike sorting results','CallBack',@DetailSpikeSorting);
                                subplot(1,1,1,'Parent',Clusterpanelbot)
                                scatter3(score(:,1),score(:,2),score(:,3),30,'filled')
                                rotate3d on 
                                xlabel('1. principal component')
                                ylabel('2. principal component')
                                zlabel('3. principal component')
                                title('The first 3 principal components');
                                hold on
                              end
                        break;%aus der for-Schleife wenn h>85 (entspricht 85%) erfüllt und Anweisung ausgeführt
                    end
               end
         end
   end

   % --- Darstellung der Details bezüglich der Spikes und...--------------- 
   % --- ...zu den Ergebnissen der Hauptkomponentenanalyse (TA)------------   
   function DetailSpikeSorting(source, event)%#ok<INUSD>
         xachse=0;
         if msec==0.5               
             xachse=0:1/(ValuesinWindow-1):1;
         end     
         if msec==1
             xachse=0:2/(ValuesinWindow-1):2;
         end
         amplitudes=0;
         [x,y]=size(Anzahl_Score);
         detailFigure=figure('NumberTitle','off','Name','Details','Position',[320 50 550 650],'Toolbar','none');
         detailpanelbot= uipanel('Parent',detailFigure,'BackgroundColor',[.8 .8 .8],'Units','Pixels','Position',[0 0 550 500]);
         subplot(1,1,1,'Parent',detailpanelbot),plot(xachse,SpikeShapes),title('Covered spike shapes','fontsize',11)
         ylabel('voltage/µV')
         xlabel('period of time/ms')
         uicontrol('Parent',detailpanelbot,'style','pushbutton','string','Show scores','Position',[465 627 75 20],'FontSize',8,'ToolTipString','Shows scores in the command window. These values are the linear combinations of each spike data.','callback',@ShowScores)        
         detailpaneltop=uipanel('Parent',detailFigure,'BackgroundColor',[1 1 1],'Units','Pixels','Position',[0 500 550 150]);
         ui1=uicontrol('Parent',detailpaneltop,'Style','Text','Position',[260 110 33 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
         ui2=uicontrol('Parent',detailpaneltop,'Style','Text','Position',[182 90 30 20],'Fontsize',10,'BackgroundColor',[1 1 1]);            
         if y==3
           uicontrol('Parent',detailpaneltop,'Style','Text','String','1. The first 3 principal components explain','Position',[10 110 250 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
           set(ui1,'String',accountedVariance3);
                if accountedVariance3<85
                   uicontrol('Parent',detailpaneltop,'Style','Text','FontWeight','bold','String','Attention! Possibly no adequate results. At least 85 per cent of the total variance should be explained. Maybe a change of the options produces better results.','Position',[353 5 185 75],'HorizontalAlignment','left','Fontsize',8,'BackgroundColor',['red']);%#ok
                end
         end         
         if y==2
           uicontrol('Parent',detailpaneltop,'Style','Text','String','1. The first 2 principal components explain','Position',[10 110 250 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
           set(ui1,'String',accountedVariance2);
         end
         set(ui2,'String',x);         
         uicontrol('Parent',detailpaneltop,'Style','Text','String','per cent of the total variance.','HorizontalAlignment','left','Position',[288 110 175 20],'Fontsize',10,'BackgroundColor',[1 1 1]);      
         uicontrol('Parent',detailpaneltop,'Style','Text','String','2. The scatterplot consists of','Position',[10 90 175 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');            uicontrol('Parent',detailpaneltop,'Style','Text','String','dots (equates to the number of spikes).','Position',[208 90 230 20],'Fontsize',10,'BackgroundColor',[1 1 1]);  
         uicontrol('Parent',detailpaneltop,'Style','Text','String','3. Highest amplitude in µV:','Position',[10 70 165 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');            
         uicontrol('Parent',detailpaneltop,'Style','Text','String','4. Least amplitude in µV:','Position',[10 50 155 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');                             
         uicontrol('Parent',detailpaneltop,'Style','Text','String','5. Average amplitude in µV:','Position',[10 30 160 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');                                         
         for i=1:1:x %Berechnung der Amplitudenwerte
             amplitudes(i,:)=min(SpikeShapes(:,i));
         end
         HighestAmplitude=min(amplitudes);
         LeastAmplitude=max(amplitudes);
         AverageAmplitude=mean(amplitudes);
         ui3=uicontrol('Parent',detailpaneltop,'Style','Text','Position',[175 70 80 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');                        
         set(ui3,'String',HighestAmplitude);          
         ui4=uicontrol('Parent',detailpaneltop,'Style','Text','Position',[175 50 80 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');                        
         set(ui4,'String', LeastAmplitude);    
         ui5=uicontrol('Parent',detailpaneltop,'Style','Text','Position',[175 30 80 20],'Fontsize',10,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');                        
         set(ui5,'String', AverageAmplitude);
   end

   % --- Score-Werte (Ergebnisse der Hauptkomponentenanalyse) im... -------
   % --- ...Command Window anzeigen lassen (zur Kontrolle, Analyse...)(TA)-
   function ShowScores(source,event)%#ok<INUSD>
         disp('The number of rows equates to the number of spikes, since each column contains the linear combinations (scores) of the detected spikes. The first column contains the results of the first principal component analysis, and so on.')
         disp(Score_values)
   end

   % --- Clusteranalyse, angewendet auf den Scatterplot (TA)---------------
   function ClusterAnalysis(source,event)%#ok<INUSD>
         set(findobj(gcf,'Tag','string_HandleCluster'),'Enable','on');
         set(findobj(gcf,'Tag','ToCluster'),'Enable','on');
         set(findobj(gcf,'Tag','stringMarkedDots'),'Enable','on');
         merker=0; %wichtig später zum Anzeigen der Wellenform           
         delete(handle_Add)
         delete(handle_draw)
         delete(handle_restore)
         delete(handle_assign)
         handle_Add=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','Position',[430 20 65 25],'string','Add dot','tag','Add_Dot','FontWeight','bold','ToolTipString','Every dot that should be assigned to the new cluster must be clicked on (coordinates are shown) and followed by a click on this button.','callback',@neuzuordung);
         handle_restore=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[600 10 55 25],'tag','restorescatter','string','Restore','ToolTipString','Will draw the scatterplot again if wrong dots are marked.','callback',@restorefigure);
         handle_draw=uicontrol('Parent',Clusterpaneltop,'Style','pushbutton','enable','off','Position',[570 48 120 25],'tag','drawnew','string','Assign & draw again','ToolTipString','Assign all marked dots to the new cluster.', 'callback',@neuzeichnung);
         handle_assign=uicontrol('Parent',Clusterpaneltop,'Style','PushButton','Units','Pixels','Position',[160 20 155 25],'FontSize',9,'FontWeight','bold','String','Show single waveforms','ToolTipString','Assign every cluster to a single waveform','CallBack',@AssignCluster);
         REST=0;
         KOORDINATEN=0;
         datacluster=1;
         COPYX=Anzahl_Score;
         ClNr=get(findobj(gcf,'Tag','NumberCluster'),'String');
         Cluster=strread(ClNr);
         [~,sizescore]=size(Anzahl_Score); %vorher [f,sizescore]
         subplot(1,1,1,'Parent',Clusterpanelbot)

         if isempty(Cluster)
           NoCluster=figure('Name','Error','NumberTitle','OFF','Position',[300 300 400 160]);
           uicontrol(NoCluster,'Style','Pushbutton','Position', [105 45 190 25],'String','OK','FontSize',10,'Callback','close');
           uicontrol(NoCluster,'Style','text','String','Enter a number of Cluster! Minimum 2, Maximum 4','Position',[50 100 300 35],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8])
         else
          delete(gca)
          NumberCluster=Cluster;
                  if Cluster==2
                     Cluster_Zuordnung=clusterdata(Anzahl_Score,'maxclust',2);
                        for i=1:1:length(Cluster_Zuordnung)
                             if Cluster_Zuordnung(i)==1
                                y=find(Cluster_Zuordnung==1);
                             end
                             if Cluster_Zuordnung(i)==2
                                x=find(Cluster_Zuordnung==2);
                             end
                        end  
                        for i=1:1:length(y)
                            K(i,:)=Anzahl_Score(y(i),:);
                        end                   
                        for i=1:1:length(x)
                            J(i,:)=Anzahl_Score(x(i),:);
                        end
                        subplot(1,1,1,'Parent',Clusterpanelbot)  
                        if sizescore==2
                            h1=scatter(K(:,1),K(:,2),30,y,'r','filled','Tag','datainfo');
                            hold on
                            h2=scatter(J(:,1),J(:,2),30,x,'g','filled','Tag','datainfo');
                            hold on
                            legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                            xlabel('1. principal component')
                            ylabel('2. principal component')
                            title('The first 2 principal components'); 
                            hold on
                            datacursormode on
                        end
                        if sizescore==3
                            h1=scatter3(K(:,1),K(:,2),K(:,3),30,y,'r','filled','Tag','datainfo');
                            hold on
                            h2=scatter3(J(:,1),J(:,2),J(:,3),30,x,'g','filled','Tag','datainfo');
                            hold on
                            legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                            xlabel('1. principal component')
                            ylabel('2. principal component')
                            zlabel('3. principal component')
                            title('The first 3 principal components');
                            hold on
                            datacursormode on
                        end
                        menu=findall(get(gcf,'Children'),'Type','uicontextmenu');
                        menuCallback=get(menu,'Callback');
                        dataCursor=menuCallback{2};
                        copy_x=x;
                        copy_y=y;
                  end
                  if Cluster==3
                     Cluster_Zuordnung=clusterdata(Anzahl_Score,'maxclust',3);
                        for i=1:1:length(Cluster_Zuordnung)
                            if Cluster_Zuordnung(i)==1
                               y=find(Cluster_Zuordnung==1);
                            end
                            if Cluster_Zuordnung(i)==2
                               x=find(Cluster_Zuordnung==2);
                            end
                            if Cluster_Zuordnung(i)==3
                                z=find(Cluster_Zuordnung==3);
                            end
                        end
                        for i=1:1:length(y)
                            K(i,:)=Anzahl_Score(y(i),:);
                        end               
                        for i=1:1:length(x)
                            J(i,:)=Anzahl_Score(x(i),:);
                        end
                        for i=1:1:length(z)
                             N(i,:)=Anzahl_Score(z(i),:);
                        end
                        subplot(1,1,1,'Parent',Clusterpanelbot)  
                        if sizescore==2
                            h1=scatter(K(:,1),K(:,2),30,y,'r','filled','Tag','datainfo');
                            hold on
                            h2=scatter(J(:,1),J(:,2),30,x,'g','filled','Tag','datainfo');
                            hold on
                            h3=scatter(N(:,1),N(:,2),30,z,'b','filled','Tag','datainfo');
                            legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                            xlabel('1. principal component')
                            ylabel('2. principal component')
                            hold on
                            datacursormode on
                        end
                        if sizescore==3
                            h1=scatter3(K(:,1),K(:,2),K(:,3),30,y,'r','filled','Tag','datainfo');
                            hold on
                            h2=scatter3(J(:,1),J(:,2),J(:,3),30,x,'g','filled','Tag','datainfo');
                            hold on
                            h3=scatter3(N(:,1),N(:,2),N(:,3),30,z,'b','filled','Tag','datainfo');
                            legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                            xlabel('1. principal component')
                            ylabel('2. principal component')
                            zlabel('3. principal component')
                            hold on
                            datacursormode on
                        end     
                        menu=findall(get(gcf,'Children'),'Type','uicontextmenu');
                        menuCallback = get(menu,'Callback');
                        dataCursor = menuCallback{2};
                        copy_x=x;
                        copy_y=y;
                        copy_z=z;
                  end                 
                  if Cluster==4
                    Cluster_Zuordnung=clusterdata(Anzahl_Score,'maxclust',4);
                        for i=1:1:length(Cluster_Zuordnung)
                            if Cluster_Zuordnung(i)==1
                                y=find(Cluster_Zuordnung==1);
                            end
                            if Cluster_Zuordnung(i)==2
                                x=find(Cluster_Zuordnung==2);
                            end
                            if Cluster_Zuordnung(i)==3
                                z=find(Cluster_Zuordnung==3);
                            end
                            if Cluster_Zuordnung(i)==4
                                w=find(Cluster_Zuordnung==4);
                            end
                       end
                        for i=1:1:length(y)
                            K(i,:)=Anzahl_Score(y(i),:);
                        end                    
                        for i=1:1:length(x)
                            J(i,:)=Anzahl_Score(x(i),:);
                        end
                        for i=1:1:length(z)
                            N(i,:)=Anzahl_Score(z(i),:);
                        end
                        for i=1:1:length(w)
                            H(i,:)=Anzahl_Score(w(i),:);
                        end
                        subplot(1,1,1,'Parent',Clusterpanelbot)  
                        if sizescore==2
                            h1=scatter(K(:,1),K(:,2),30,y,'r','filled','Tag','datainfo');
                            hold on
                            h2=scatter(J(:,1),J(:,2),30,x,'g','filled','Tag','datainfo');
                            hold on
                            h3=scatter(N(:,1),N(:,2),30,z,'b','filled','Tag','datainfo');
                            hold on
                            h4=scatter(H(:,1),H(:,2),30,w,'k','filled','Tag','datainfo');
                            legend([h1 h2 h3 h4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','Best');
                            xlabel('1. principal component')
                            ylabel('2. principal component')
                            hold on
                            datacursormode on
                        end
                       if sizescore==3
                            h1=scatter3(K(:,1),K(:,2),K(:,3),30,y,'r','filled','Tag','datainfo');
                            hold on
                            h2=scatter3(J(:,1),J(:,2),J(:,3),30,x,'g','filled','Tag','datainfo');
                            hold on
                            h3=scatter3(N(:,1),N(:,2),N(:,3),30,z,'b','filled','Tag','datainfo');
                            hold on
                            h4=scatter3(H(:,1),H(:,2),H(:,3),30,w,'k','filled','Tag','datainfo');
                            legend([h1 h2 h3 h4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','Best')
                            xlabel('1. principal component')
                            ylabel('2. principal component')
                            zlabel('3. principal component')
                            hold on
                            datacursormode on
                       end
                        menu=findall(get(gcf,'Children'),'Type','uicontextmenu');
                        menuCallback=get(menu,'Callback');
                        dataCursor=menuCallback{2};
                        copy_w=w; 
                        copy_x=x;
                        copy_y=y;
                        copy_z=z;
                  end
         end
         copy_i=i; %Die "copy_.."-Variablen sind global....
         Copy_Cluster_Zuordnung=Cluster_Zuordnung;
         ClusterZuordnung_Assign=Cluster_Zuordnung;
   end

   % --- Ursprüngliche Clusteranalyse wieder herstellen (TA)---------------
   function restorefigure(source,event)%#ok<INUSD>    
         REST=1;
         delete(gca)
         Cluster_Zuordnung=clusterdata(COPYX,'maxclust',Cluster);
         datainfo=0;
         K=[];
         J=[];
         N=[];
         subplot(1,1,1,'Parent',Clusterpanelbot)
         if Cluster==2
            x=copy_x;
            y=copy_y;
            if Cluster_Zuordnung(copy_i)==1
               y=find(Cluster_Zuordnung==1);
            end
            if Cluster_Zuordnung(copy_i)==2
               x=find(Cluster_Zuordnung==2);
            end  
            for i=1:1:length(y)
                K(i,:)=COPYX(y(i),:);
            end
            for i=1:1:length(x)
                J(i,:)=COPYX(x(i),:);
            end
            if sizescore==2
                h1=scatter(K(:,1),K(:,2),30,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter(J(:,1),J(:,2),30,x,'g','filled','Tag','datainfo');
                hold on
                legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
            end    
            if sizescore==3
                h1=scatter3(K(:,1),K(:,2),K(:,3),30,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter3(J(:,1),J(:,2),J(:,3),30,x,'g','filled','Tag','datainfo');
                hold on
                legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
                zlabel('3. principal component')
            end
         end
         if Cluster==3
           x=copy_x;
           y=copy_y;
           z=copy_z;
           Cluster_Zuordnung=clusterdata(Anzahl_Score,'maxclust',3);
                for i=1:1:length(Cluster_Zuordnung)
                    if Cluster_Zuordnung(copy_i)==1
                        y=find(Cluster_Zuordnung==1);
                    end
                    if Cluster_Zuordnung(copy_i)==2
                        x=find(Cluster_Zuordnung==2);       
                    end
                    if Cluster_Zuordnung(copy_i)==3
                        z=find(Cluster_Zuordnung==3);
                    end
                end
                for i=1:1:length(y)
                    K(i,:)=COPYX(y(i),:);
                end       
                for i=1:1:length(x)
                    J(i,:)=COPYX(x(i),:);
                end
                for i=1:1:length(z)
                    N(i,:)=COPYX(z(i),:);
                end
                if sizescore==2
                    h1=scatter(K(:,1),K(:,2),30,y,'r','filled','Tag','datainfo');
                    hold on
                    h2=scatter(J(:,1),J(:,2),30,x,'g','filled','Tag','datainfo');
                    hold on
                    h3=scatter(N(:,1),N(:,2),30,z,'b','filled','Tag','datainfo');
                    legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                    xlabel('1. principal component')
                    ylabel('2. principal component')
                end
                if sizescore==3
                    h1=scatter3(K(:,1),K(:,2),K(:,3),30,y,'r','filled','Tag','datainfo');
                    hold on
                    h2=scatter3(J(:,1),J(:,2),J(:,3),30,x,'g','filled','Tag','datainfo');
                    hold on
                    h3=scatter3(N(:,1),N(:,2),N(:,3),30,z,'b','filled','Tag','datainfo');
                    legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                    xlabel('1. principal component')
                    ylabel('2. principal component')
                    zlabel('3. principal component')
                end
         end
         if Cluster==4
             w=copy_w;
             x=copy_x;
             y=copy_y;
             z=copy_z;
             Cluster_Zuordnung = clusterdata(Anzahl_Score,'maxclust',4);
            for i=1:1:length(Cluster_Zuordnung)
                if Cluster_Zuordnung(copy_i)==1
                    y=find(Cluster_Zuordnung==1);
                end
                if Cluster_Zuordnung(copy_i)==2
                    x=find(Cluster_Zuordnung==2);
                end
                if Cluster_Zuordnung(copy_i)==3
                    z=find(Cluster_Zuordnung==3);
                end
                if Cluster_Zuordnung(copy_i)==4
                    w=find(Cluster_Zuordnung==4);
                end
            end
            for i=1:1:length(y)
                K(i,:)=Anzahl_Score(y(i),:);
            end
            for i=1:1:length(x)
                J(i,:)=Anzahl_Score(x(i),:);
            end
            for i=1:1:length(z)
                N(i,:)=Anzahl_Score(z(i),:);
            end
            for i=1:1:length(w)
                H(i,:)=Anzahl_Score(w(i),:);
            end
            if sizescore==2
                h1=scatter(K(:,1),K(:,2),30,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter(J(:,1),J(:,2),30,x,'g','filled','Tag','datainfo');
                hold on
                h3=scatter(N(:,1),N(:,2),30,z,'b','filled','Tag','datainfo');
                hold on
                h4=scatter(H(:,1),H(:,2),30,w,'k','filled','Tag','datainfo');
                legend([h1 h2 h3 h4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','Best');
                xlabel('1. principal component')
                ylabel('2. principal component')
                hold on
                datacursormode on
            end
            if sizescore==3
                h1=scatter3(K(:,1),K(:,2),K(:,3),30,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter3(J(:,1),J(:,2),J(:,3),30,x,'g','filled','Tag','datainfo');
                hold on
                h3=scatter3(N(:,1),N(:,2),N(:,3),30,z,'b','filled','Tag','datainfo');
                hold on
                h4=scatter3(H(:,1),H(:,2),H(:,3),30,w,'k','filled','Tag','datainfo');
                legend([h1 h2 h3 h4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
                zlabel('3. principal component')
                hold on
                datacursormode on
            end
         end
         ClusterZuordnung_Assign=Cluster_Zuordnung; 
   end
       
   % --- Manuelle Änderung der Clusteranalyse (TA)------------------------- 
   function neuzuordung(source,event)%#ok<INUSD>
         set(findobj(gcf,'Tag','drawnew'),'Enable','on')
         set(findobj(gcf,'Tag','restorescatter'),'Enable','on')
        if REST==1
            KOORDINATEN=[];
            f=[];%#ok
            datacluster=1;
        end
        REST=0;%sonst bleibt REST auf 1 und bei jedem weiterem Klick bleibt Matlab in der obigen if-Abfrage hängen
        datainfo=getCursorInfo(dataCursor);%Datainfo sind die Koordinaten, also die Scorewerte eines Dots, die der Benutzer angeklickt und demnach markiert hat
        if isempty(datainfo)
            NoData=figure('Name','Error','NumberTitle','OFF','Position',[300 300 400 160]);
            uicontrol( NoData,'Style','Pushbutton','Position', [105 45 190 25],'String','OK','FontSize',10,'Callback','close');
            uicontrol( NoData,'Style','text','String','First a dot must be clicked on (coordinates are shown)!','Position', [35 100 330 35],'FontSize',10,'BackgroundColor',[.8 .8 .8])
        else
            f=getfield(datainfo,'Position');%#ok
            [b,v]=size(datacluster);%#ok 
              while b==1
                    if sizescore==2
                        plot(f(1,1),f(1,2),'Linestyle','none','Marker','x','Tag','xy','LineWidth',2,'Markersize',15,'Color','k');
                    end
                    if sizescore==3
                        plot3(f(1,1),f(1,2),f(1,3),'Linestyle','none','Marker','x','Tag','xy','LineWidth',2,'Markersize',15,'Color','k');
                    end
                    KOORDINATEN(datacluster,1)=f(:,1);%Mit jedem Klick auf "Add Dot" wird der Vektor "KOORDINATEN" mit der x-Koordinate eines Dots gefüllt
                    if b==1
                        datacluster=datacluster+1;
                        break
                    end
              end
        end
    end

   % --- Neuzeichnung der Cluster wenn vom Benutzer manuell geändert (TA)--
   function neuzeichnung(source,event)%#ok<INUSD>  
         delete(gca)
         subplot(1,1,1,'Parent',Clusterpanelbot)
         set(findobj(gcf,'Tag','restorescatter'),'Enable','off');%"Restore" macht nur die markierten Dots wieder rückgängig...
         tol=0.005;
         bpoint=get(findobj(gcf,'Tag','ToCluster'),'String');
         newcluster=strread(bpoint);
         x=0;
         y=0;
         
         for i=1:1:length(KOORDINATEN)    
             [a,b]=find(Anzahl_Score<(KOORDINATEN(i)+tol)&(Anzahl_Score>(KOORDINATEN(i)-tol)));%#ok
             Copy_Cluster_Zuordnung(a)=newcluster;%neues Cluster_Zuordnung mit geänderten Stellen
         end
      
        %Die nachfolgenden "error.." sind überprüfen on der Benutzer durch manuelle Änderung der Clusterzuweisung einen kompletten Cluster aufgelöst hat (Wenn zB. nur ein Dot ein Cluster ist, kann er diesen dem nächsten LCuster zuordnen und die Anzahl der CLuster verringert sich...
         error4=find(Copy_Cluster_Zuordnung==4);
         if isempty(error4)&& Cluster==3 || Cluster==2
            error4=0;
         end
         error3=find(Copy_Cluster_Zuordnung==3);
         if isempty(error3)&& Cluster==2
         error3=0;
         end
         error2=find(Copy_Cluster_Zuordnung==2); 
         error1=find(Copy_Cluster_Zuordnung==1);
         if isempty(error4)||isempty(error3)||isempty(error2)||isempty(error1)        
            if Cluster==4  
                if isempty (error4)
                    Cluster=Cluster-1;
                end
            end
            if isempty(error3)
                Cluster=Cluster-1;
            end      
            if isempty(error2)
                Cluster=Cluster-1;
            end
            if isempty(error1)
                Cluster=Cluster-1;
            end
            CopyCluster_Zuordnung= Copy_Cluster_Zuordnung;
            deleteCluster %Funktionsaufruf, falls Benutzer einen Cluster komplett einem anderem zuordnen möchte
         else
             if isempty(newcluster) 
                 NoCluster=figure('Name','Error','NumberTitle','OFF','Position',[300 300 400 160]);
                 uicontrol(NoCluster,'Style','Pushbutton','Position', [105 45 190 25],'String','OK','FontSize',10,'Callback','close');
                 uicontrol(NoCluster,'Style','text','String','A number of distinguishable clusters must be entered! Minimum 2, maximum 4','Position', [50 100 300 35],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8])
             else
                if Cluster==2
                    for i=1:1:length(Copy_Cluster_Zuordnung)
                        if Copy_Cluster_Zuordnung(i)==1
                            y=find(Copy_Cluster_Zuordnung==1);
                        end
                        if Copy_Cluster_Zuordnung(i)==2
                            x=find(Copy_Cluster_Zuordnung==2); 
                        end
                    end
                    for i=1:1:length(y) 
                        P(i,:)=Anzahl_Score(y(i),:);    
                    end
                    for i=1:1:length(x)
                        Q(i,:)=Anzahl_Score(x(i),:);
                    end
                    if sizescore==2
                        h1=scatter(P(:,1),P(:,2),50,y,'r','filled','Tag','datainfo');
                        hold on
                        h2=scatter(Q(:,1),Q(:,2),50,x,'g','filled','Tag','datainfo');
                        legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                        xlabel('1. principal component')
                        ylabel('2. principal component')
                    end
                    if sizescore==3
                        h1=scatter3(P(:,1),P(:,2),P(:,3),50,y,'r','filled','Tag','datainfo');
                        hold on
                        h2=scatter3(Q(:,1),Q(:,2),Q(:,3),50,x,'g','filled','Tag','datainfo');
                        legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                        xlabel('1. principal component')
                        ylabel('2. principal component')
                        zlabel('3. principal component')
                    end
                end   
                if Cluster==3
                    J=[];
                    K=[];
                    N=[];
                    for i=1:1:length(Copy_Cluster_Zuordnung)
                        if Copy_Cluster_Zuordnung(i)==1
                            y=find(Copy_Cluster_Zuordnung==1);
                        end      
                        if Copy_Cluster_Zuordnung(i)==2  
                            x=find(Copy_Cluster_Zuordnung==2);
                        end 
                        if Copy_Cluster_Zuordnung(i)==3
                            z=find(Copy_Cluster_Zuordnung==3);
                        end
                    end
                   for i=1:1:length(y)
                        K(i,:)=Anzahl_Score(y(i),:);
                   end
                   for i=1:1:length(x) 
                        J(i,:)=Anzahl_Score(x(i),:);
                   end
                   for i=1:1:length(z)
                        N(i,:)=Anzahl_Score(z(i),:);
                   end
                   if sizescore==2
                        h1=scatter(K(:,1),K(:,2),50,y,'r','filled','Tag','datainfo');
                        hold on
                        h2=scatter(J(:,1),J(:,2),50,x,'g','filled','Tag','datainfo');
                        hold on
                        h3=scatter(N(:,1),N(:,2),50,z,'b','filled','Tag','datainfo');
                        legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                        xlabel('1. principal component')
                        ylabel('2. principal component')
                   end
                   if sizescore==3
                        h1=scatter3(K(:,1),K(:,2),K(:,3),50,y,'r','filled','Tag','datainfo');
                        hold on
                        h2=scatter3(J(:,1),J(:,2),J(:,3),50,x,'g','filled','Tag','datainfo');
                        hold on
                        h3=scatter3(N(:,1),N(:,2),N(:,3),50,z,'b','filled','Tag','datainfo');
                        legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                        xlabel('1. principal component')
                        ylabel('2. principal component')
                        zlabel('3. principal component')
                    end
                end
                if Cluster==4
                 J=[];
                 K=[];
                 N=[];
                 H=[];
                    for i=1:1:length(Copy_Cluster_Zuordnung)
                        if Copy_Cluster_Zuordnung(i)==1
                            y=find(Copy_Cluster_Zuordnung==1);
                        end             
                        if Copy_Cluster_Zuordnung(i)==2
                            x=find(Copy_Cluster_Zuordnung==2);
                        end
                        if Copy_Cluster_Zuordnung(i)==3
                            z=find(Copy_Cluster_Zuordnung==3);
                        end   
                        if Copy_Cluster_Zuordnung(i)==4
                            w=find(Copy_Cluster_Zuordnung==4);
                        end
                    end
                    for i=1:1:length(y)
                         K(i,:)=Anzahl_Score(y(i),:);
                    end
                    for i=1:1:length(x)
                        J(i,:)=Anzahl_Score(x(i),:);
                    end
                    for i=1:1:length(z)
                        N(i,:)=Anzahl_Score(z(i),:);
                    end
                    for i=1:1:length(w)
                        H(i,:)=Anzahl_Score(w(i),:);
                    end
                    if sizescore==2
                         h1=scatter(K(:,1),K(:,2),50,y,'r','filled','Tag','datainfo');
                         hold on
                         h2=scatter(J(:,1),J(:,2),50,x,'g','filled','Tag','datainfo');
                         hold on
                         h3=scatter(N(:,1),N(:,2),50,z,'b','filled','Tag','datainfo');
                         hold on
                         h4= scatter(H(:,1),H(:,2),50,w,'k','filled','Tag','datainfo');
                         legend([h1 h2 h3 h4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','Best')
                         xlabel('1. principal component')
                         ylabel('2. principal component')
                    end    
                    if sizescore==3
                         h1=scatter3(K(:,1),K(:,2),K(:,3),50,y,'r','filled','Tag','datainfo');
                         hold on
                         h2=scatter3(J(:,1),J(:,2),J(:,3),50,x,'g','filled','Tag','datainfo');
                         hold on
                         h3=scatter3(N(:,1),N(:,2),N(:,3),50,z,'b','filled','Tag','datainfo');
                         hold on
                         h4=scatter3(H(:,1),H(:,2),H(:,3),50,w,'k','filled','Tag','datainfo');
                         legend([h1 h2 h3 h4],'Cluster 1','Cluster 2','Cluster 3','Cluster 4','Location','Best')
                         xlabel('1. principal component')
                         ylabel('2. principal component')
                         zlabel('3. principal component')
                    end
                end
             end
         end
        REST=1;
        ClusterZuordnung_Assign=Copy_Cluster_Zuordnung; %Wenn Funktion "neuzeichnung" durchlaufen, ergibt sich neue Clusterzuordnung
   end

   % --- Man. Auflösung eines kompletten Clusters nach Clusteranalyse (TA)-
   function deleteCluster(source,event)%#ok<INUSD>   
         k=find(CopyCluster_Zuordnung==1);%#ok
         g=find(CopyCluster_Zuordnung==2);%#ok
         h=find(CopyCluster_Zuordnung==3);%#ok
         if isempty(k) %Wenn Cluster 1 aufgelöst....
             for i=1:1:length(CopyCluster_Zuordnung)
                  CopyCluster_Zuordnung(i)=CopyCluster_Zuordnung(i)-1;
             end
         end
         if isempty(g) %Wenn Cluster 2 aufgelöst...
             for i=1:1:length(CopyCluster_Zuordnung)
                 if CopyCluster_Zuordnung(i)>2
                     CopyCluster_Zuordnung(i)=CopyCluster_Zuordnung(i)-1;
                 end
             end
         end         
         if isempty(h) %Wenn CLuster 3 aufgelöst..
             for i=1:1:length(CopyCluster_Zuordnung)
                  if CopyCluster_Zuordnung(i)>3
                      CopyCluster_Zuordnung(i)=CopyCluster_Zuordnung(i)-1;
                  end
             end
         end      
         %Wenn CLuster 4 aufgelöst bleiben alle restlichen Ziffern von 1 bis max 3 erhalten...das heißt es muss nichts geändert werden
         J=[];
         K=[];
         N=[];
         if Cluster==2
            for i=1:1:length(CopyCluster_Zuordnung)
                if CopyCluster_Zuordnung(i)==1
                    y=find(CopyCluster_Zuordnung==1);
                end
                if CopyCluster_Zuordnung(i)==2
                    x=find(CopyCluster_Zuordnung==2);
                end
            end
            for i=1:1:length(y)
                K(i,:)=Anzahl_Score(y(i),:);
            end
            for i=1:1:length(x)
               J(i,:)=Anzahl_Score(x(i),:);
            end
            if sizescore==2
                h1=scatter(K(:,1),K(:,2),50,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter(J(:,1),J(:,2),50,x,'g','filled','Tag','datainfo');
                hold on
                legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
                hold on
                datacursormode on
            end
            if sizescore==3
                h1=scatter3(K(:,1),K(:,2),K(:,3),50,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter3(J(:,1),J(:,2),J(:,3),50,x,'g','filled','Tag','datainfo');
                hold on
                legend([h1 h2],'Cluster 1','Cluster 2','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
                zlabel('3. principal component')
                hold on
                datacursormode on
            end
            menu=findall(get(gcf,'Children'),'Type','uicontextmenu');
            menuCallback=get(menu,'Callback');
            dataCursor=menuCallback{2};
         end
        if Cluster==3
            for i=1:1:length(CopyCluster_Zuordnung)
                if CopyCluster_Zuordnung(i)==1
                    y=find(CopyCluster_Zuordnung==1);
                end
                if CopyCluster_Zuordnung(i)==2
                    x=find(CopyCluster_Zuordnung==2);
                end
                if CopyCluster_Zuordnung(i)==3
                    z=find(CopyCluster_Zuordnung==3);
                end
            end
            for i=1:1:length(y)
                K(i,:)=Anzahl_Score(y(i),:); 
            end
            for i=1:1:length(x)
                J(i,:)=Anzahl_Score(x(i),:);
            end
            for i=1:1:length(z)
                N(i,:)=Anzahl_Score(z(i),:);
            end 
            if sizescore==2
                h1=scatter(K(:,1),K(:,2),50,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter(J(:,1),J(:,2),50,x,'g','filled','Tag','datainfo');
                hold on
                h3=scatter(N(:,1),N(:,2),50,z,'b','filled','Tag','datainfo');
                legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
                hold on
                datacursormode on
            end
            if sizescore==3
                h1=scatter3(K(:,1),K(:,2),K(:,3),50,y,'r','filled','Tag','datainfo');
                hold on
                h2=scatter3(J(:,1),J(:,2),J(:,3),50,x,'g','filled','Tag','datainfo');
                hold on
                h3=scatter3(N(:,1),N(:,2),N(:,3),50,z,'b','filled','Tag','datainfo');
                legend([h1 h2 h3],'Cluster 1','Cluster 2','Cluster 3','Location','Best')
                xlabel('1. principal component')
                ylabel('2. principal component')
                zlabel('3. principal component')
                hold on
                datacursormode on
            end      
            menu=findall(get(gcf,'Children'),'Type','uicontextmenu');
            menuCallback=get(menu,'Callback');
            dataCursor=menuCallback{2};
        end
        ClusterZuordnung_Assign=CopyCluster_Zuordnung;
        NumberCluster=Cluster;
   end

   % --- Maske für Darstellung der Spike Trains (TA)-----------------------
   function AssignCluster(source,event)%#ok<INUSD>             
         bscale=50;
         if merker==0
             AssignCluster_Figure=figure('Toolbar','None','Position',[100 20 850 680],'Name','Assign cluster to corresponding neuron','NumberTitle','off');
             waveformspaneltop=uipanel('Parent',AssignCluster_Figure,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[0 600 850 80]);
             waveformspanelbot=uipanel('Parent',AssignCluster_Figure,'BackgroundColor',[.8 .8 .8],'fontweight','b','Units','pixels','Position',[0 0 850 600]);
             uicontrol('Parent',waveformspaneltop,'Position',[655 45 140 20],'Style','text','String','Show waveforms from...','FontSize',10,'BackgroundColor',[.8 .8 .8])
             uicontrol('Parent',waveformspaneltop,'Position',[655 15 45 20],'Style','edit','String','0','Tag','zoomstart','BackgroundColor',[1 1 1 ])                    
             uicontrol('Parent',waveformspaneltop,'Position',[725 15 45 20],'Style','edit','String',T(size(T,2)),'Tag','zoomend','BackgroundColor',[1 1 1 ]) 
             uicontrol('Parent',waveformspaneltop,'Position',[705 18 15 15],'Style','text','String','to','FontSize',9,'BackgroundColor',[.8 .8 .8])                    
             uicontrol('Parent',waveformspaneltop,'Position',[775 18 10 15],'Style','text','String','s','FontSize',9,'BackgroundColor',[.8 .8 .8])                                         
             uicontrol('Parent',waveformspaneltop,'Position',[790 15 40 25],'Style','pushbutton','String','Show','TooltipString','Shows the waveforms for the entered range of time','callback',@ZoomOption)    
             uicontrol('Parent',waveformspaneltop,'Position',[500 25 120 20],'BackgroundColor',[.8 .8 .8],'Style','checkbox','Tag','checkboxThresh','value',0,'FontSize',10,'String','Show threshold','TooltipString','Shows the threshold in the original waveform','callback',@Show_Threshold) ; 
             scaleSingleWaves=uicontrol('Parent',waveformspaneltop,'Position',[40 15 100 25],'Tag','SingleWaveformScale','String',['50 uV  ';'100 uV ';'200 uV ';'500 uV '],'Tooltipstring','Change Y-Scale','Value',1,'TooltipString','A change of the y-Axis scale will remove all chosen settings','Style','popupmenu','callback',@YScale);
             uicontrol('Parent',waveformspaneltop,'Position',[10 45 150 20],'Style','text','String','Change y-Axis Scale','FontSize',10,'BackgroundColor',[.8 .8 .8])                    
             uicontrol('Parent',waveformspaneltop,'Position',[240 45 180 20],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Mark in original waveform...','FontSize',10);
             uicontrol('Parent',waveformspaneltop,'Position',[230 25 20 20],'BackgroundColor',[.8 .8 .8],'Style','checkbox','Tag','showwaveform1','FontSize',8,'Value',0,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Markes the corresponding spikes in original waveform', 'CallBack',@showSpikes);
             uicontrol('Parent',waveformspaneltop,'Position',[230 5 20 20],'Style','checkbox','Tag','showwaveform2','FontSize',8,'Value',0,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Markes the corresponding spikes in original waveform', 'CallBack',@showSpikes);
             uicontrol('Parent',waveformspaneltop,'Position',[245 28 60 15],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 1','FontSize',9);
             uicontrol('Parent',waveformspaneltop,'Position',[245 7 60 15],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 2','FontSize',9);
             uicontrol('Parent',waveformspaneltop,'Position',[360 25 20 20],'BackgroundColor',[.8 .8 .8],'Style','checkbox','Tag','showwaveform3','FontSize',8,'Value',0,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Markes the corresponding spikes in original waveform', 'CallBack',@showSpikes);
             uicontrol('Parent',waveformspaneltop,'Position',[360 5 20 20],'Style','checkbox','Tag','showwaveform4','FontSize',8,'Value',0,'BackgroundColor', [0.8 0.8 0.8],'TooltipString','Markes the corresponding spikes in original waveform', 'CallBack',@showSpikes);
             uicontrol('Parent',waveformspaneltop,'Position',[380 28 60 15],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 3','Tag','StringShow3','FontSize',9);
             uicontrol('Parent',waveformspaneltop,'Position',[380 7 60 15],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 4','Tag','StringShow4','FontSize',9);                     
             uicontrol('Parent',waveformspaneltop,'Position',[500 5 120 20],'BackgroundColor',[.8 .8 .8],'Style','checkbox','String','Show stimuli','Tag','checkboxShowstim','FontSize',10,'Value',0,'BackgroundColor', [0.8 0.8 0.8],'enable','off','TooltipString','Shows stimuli in original waveform', 'CallBack',@showstim);
                  if stimulidata==1
                      set(findobj(gcf,'Tag','checkboxShowstim'),'Enable','on'); 
                  end
             neuroncluster %Funktionsaufruf
         end
   end

   % --- Zuweisung Cluster zu Spikes der korrespondierenden Neuronen (TA)--
   function neuroncluster(source,event)%#ok<INUSD> 
         if NumberCluster==2
            set(findobj(gcf,'Tag','showwaveform3'),'Enable','off');
            set(findobj(gcf,'Tag','showwaveform4'),'Enable','off');
            set(findobj(gcf,'Tag','StringShow3'),'Enable','off');
            set(findobj(gcf,'Tag','StringShow4'),'Enable','off');
            uicontrol(AssignCluster_Figure,'Position',[10 515 70 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Original waveform','FontWeight','bold','FontSize',10);
            uicontrol(AssignCluster_Figure,'Position',[10 315 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 1','FontWeight','bold','FontSize',10);
            uicontrol(AssignCluster_Figure,'Position',[10 120 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 2','FontWeight','bold','FontSize',10);
            subplot(3,1,1,'Parent',waveformspanelbot),plot(T,dv); %Original Wellenform wird geplottet
            axis([0 T(size(T,2)) -bscale bscale]);
            hold on
            subplot(3,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','thresh','visible','off','LineStyle','--','Color','red');%Threshold einzeichnen, wenn gewählt, wird dieser "visible" gesetzt
            hold on        
            for k=1:length(BEGEND)                                       
                subplot(3,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimu','visible','off','Color','red', 'LineWidth', 1);%Stimuli einzeichnen, wenn gewählt, werden diese "visible" gesetzt
            end
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==1);
            end
            Maxima_Spikes2_1=0;   
            for z=1:1:length(y)
                subplot(3,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                axis([0 T(size(T,2)) -bscale 20]);
                hold on
                Maxima_Spikes2_1(z,:)=dv(SpikeMaxima_Stellen(z));
            end
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==2);
            end
            Maxima_Spikes2_2=0;
            for z=1:1:length(y)
                subplot(3,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                axis([0 T(size(T,2)) -bscale 20]);
                hold on
                Maxima_Spikes2_2(z,:)=dv(SpikeMaxima_Stellen(z));
            end
         end        
        if NumberCluster==3
            set(findobj(gcf,'Tag','showwaveform4'),'Enable','off');
            set(findobj(gcf,'Tag','StringShow4'),'Enable','off');            
            uicontrol(AssignCluster_Figure,'Position',[10 535 70 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Original waveform','FontWeight','bold','FontSize',10);
            uicontrol(AssignCluster_Figure,'Position',[10 388 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 1','FontWeight','bold','FontSize',10);
            uicontrol(AssignCluster_Figure,'Position',[10 245 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 2','FontWeight','bold','FontSize',10);
            uicontrol(AssignCluster_Figure,'Position',[10 102 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 3','FontWeight','bold','FontSize',10);
            subplot(4,1,1,'Parent',waveformspanelbot),plot(T,dv);
            axis([0 T(size(T,2)) -bscale bscale]);
            hold on
            subplot(4,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','thresh','visible','off','LineStyle','--','Color','red');
            hold on
            for k=1:length(BEGEND)                                       
                subplot(4,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimu','visible','off','Color','red', 'LineWidth', 1);
            end                    
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==1);
            end
            Maxima_Spikes3_1=0;
            for z=1:1:length(y)
            subplot(4,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
            axis([0 T(size(T,2)) -bscale 20]);
            hold on
            Maxima_Spikes3_1(z,:)=dv(SpikeMaxima_Stellen(z));
            end
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==2);
            end
            Maxima_Spikes3_2=0;           
            for z=1:1:length(y)
                subplot(4,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                axis([0 T(size(T,2)) -bscale 20]);
                hold on
                Maxima_Spikes3_2(z,:)=dv(SpikeMaxima_Stellen(z));
            end                        
            for i=1:1:length(ClusterZuordnung_Assign)
                 y=find(ClusterZuordnung_Assign==3);
            end
            Maxima_Spikes3_3=0;
            for z=1:1:length(y)
                subplot(4,1,4,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','b')
                axis([0 T(size(T,2)) -bscale 20]);
                hold on
                Maxima_Spikes3_3(z,:)=dv(SpikeMaxima_Stellen(z));
            end
        end       
        if NumberCluster==4
            uicontrol(AssignCluster_Figure,'Position',[10 545 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Original waveform','FontWeight','bold','FontSize',9);
            uicontrol(AssignCluster_Figure,'Position',[10 426 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 1','FontWeight','bold','FontSize',9);
            uicontrol(AssignCluster_Figure,'Position',[10 315 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 2','FontWeight','bold','FontSize',9);
            uicontrol(AssignCluster_Figure,'Position',[10 202 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 3','FontWeight','bold','FontSize',9);
            uicontrol(AssignCluster_Figure,'Position',[10 90 60 30],'BackgroundColor',[.8 .8 .8],'Style','Text','String','Cluster 4','FontWeight','bold','FontSize',9);
            subplot(5,1,1,'Parent',waveformspanelbot),plot(T,dv);
            axis([0 T(size(T,2)) -bscale bscale]);
            hold on
            subplot(5,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','thresh','visible','off','LineStyle','--','Color','red');
            hold on
            for k=1:length(BEGEND)                                       
            subplot(5,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimu','visible','off','Color','red', 'LineWidth', 1);
            end 
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==1);
            end
            	Maxima_Spikes4_1=0;
            for z=1:1:length(y)
                subplot(5,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                axis([0 T(size(T,2)) -bscale 20]);
                hold on
                Maxima_Spikes4_1(z,:)=dv(SpikeMaxima_Stellen(z));
            end
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==2);
            end                   
            Maxima_Spikes4_2=0;
            for z=1:1:length(y)
                 subplot(5,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                 axis([0 T(size(T,2)) -bscale 20]);
                 hold on
                 Maxima_Spikes4_2(z,:)= dv(SpikeMaxima_Stellen(z));
            end
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==3);
            end           
            Maxima_Spikes4_3=0;
            for z=1:1:length(y)
                 subplot(5,1,4,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','b')
                 axis([0 T(size(T,2)) -bscale 20]);
                 Maxima_Spikes4_3(z,:)=dv(SpikeMaxima_Stellen(z));
                 hold on
            end
            for i=1:1:length(ClusterZuordnung_Assign)
                y=find(ClusterZuordnung_Assign==4);
            end                       
            Maxima_Spikes4_4=0;
            for z=1:1:length(y)
                 subplot(5,1,5,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','k')
                 axis([0 T(size(T,2)) -bscale 20]);
                 hold on
                 Maxima_Spikes4_4(z,:)=dv(SpikeMaxima_Stellen(z));
            end
        end
   end

   % --- Spikes eines Neurons in Originalwellenform markieren (TA)---------
   function showSpikes(source,event)%#ok<INUSD> 
         yAxis=bscale;    
         if NumberCluster==2
                for i=1:1:length(ClusterZuordnung_Assign)
                    x=find(ClusterZuordnung_Assign==1);
                end 
                for i=1:1:length(ClusterZuordnung_Assign)
                    y=find(ClusterZuordnung_Assign==2);
                end
                for z=1:1:length(x)
                    subplot(3,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','r')
                    line ('Xdata',SpikeTimes(x(z)),'Ydata',yAxis,'Tag','dreiecke','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','red','MarkerSize',9);
                end
                for z=1:1:length(y)
                subplot(3,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','g')
                line ('Xdata',SpikeTimes(y(z)),'Ydata',yAxis,'Tag','dreiecke2','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                end
                if get(findobj(gcf,'Tag','showwaveform1'),'Value')==1 
                    set(findobj(gcf,'Tag','dreiecke'),'Visible','on');
                else
                     set(findobj(gcf,'Tag','dreiecke'),'Visible','off');
                end
                if get(findobj(gcf,'Tag','showwaveform2'),'Value')==1
                     set(findobj(gcf,'Tag','dreiecke2'),'Visible','on');
                else
                    set(findobj(gcf,'Tag','dreiecke2'),'Visible','off');
                end
         end  
         if NumberCluster==3
                for i=1:1:length(ClusterZuordnung_Assign)
                    x=find(ClusterZuordnung_Assign==1);
                end  
                for i=1:1:length(ClusterZuordnung_Assign)
                    y=find(ClusterZuordnung_Assign==2);
                end
                for i=1:1:length(ClusterZuordnung_Assign)
                    w=find(ClusterZuordnung_Assign==3);
                end      
                for z=1:1:length(x)
                    subplot(4,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','r')
                    line ('Xdata',SpikeTimes(x(z)),'Ydata',yAxis,'Tag','3dreiecke1','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','red','MarkerSize',9);
                end
                for z=1:1:length(y)
                    subplot(4,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','g')
                    line ('Xdata',SpikeTimes(y(z)),'Ydata',yAxis,'Tag','3dreiecke2','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',9);
                end
                for z=1:1:length(w)
                    subplot(4,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','g')
                    line ('Xdata',SpikeTimes(w(z)),'Ydata',yAxis,'Tag','3dreiecke3','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','blue','MarkerSize',9);
                end     
                if get(findobj(gcf,'Tag','showwaveform1'),'Value')==1
                   set(findobj(gcf,'Tag','3dreiecke1'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','3dreiecke1'),'Visible','off');
                end                 
                if get(findobj(gcf,'Tag','showwaveform2'),'Value')==1 
                   set(findobj(gcf,'Tag','3dreiecke2'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','3dreiecke2'),'Visible','off');
                end
                if get(findobj(gcf,'Tag','showwaveform3'),'Value')==1 
                   set(findobj(gcf,'Tag','3dreiecke3'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','3dreiecke3'),'Visible','off');
                end       
          end
          if NumberCluster==4
                for i=1:1:length(ClusterZuordnung_Assign)
                    x=find(ClusterZuordnung_Assign==1);
                end
                for i=1:1:length(ClusterZuordnung_Assign)
                    y=find(ClusterZuordnung_Assign==2);
                end
                for i=1:1:length(ClusterZuordnung_Assign)
                    w=find(ClusterZuordnung_Assign==3);
                end
                for i=1:1:length(ClusterZuordnung_Assign)
                    v=find(ClusterZuordnung_Assign==4);
                end                       
                for z=1:1:length(x)
                    subplot(5,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','r')
                    line ('Xdata',SpikeTimes(x(z)),'Ydata',yAxis,'Tag','4dreiecke1','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','red','MarkerSize',8);
                end
                for z=1:1:length(y)
                     subplot(5,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','g')
                     line ('Xdata',SpikeTimes(y(z)),'Ydata',yAxis,'Tag','4dreiecke2','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','green','MarkerSize',8);
                end
                for z=1:1:length(w)
                    subplot(5,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','g')
                    line ('Xdata',SpikeTimes(w(z)),'Ydata',yAxis,'Tag','4dreiecke3','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','blue','MarkerSize',8);
                end
                for z=1:1:length(v)
                    subplot(5,1,1,'Parent',waveformspanelbot)%, plot(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'markertype','d','color','g')
                    line ('Xdata',SpikeTimes(v(z)),'Ydata',yAxis,'Tag','4dreiecke4','visible','off','LineStyle','none','Marker','v','MarkerFaceColor','black','MarkerSize',8);
                end
                if get(findobj(gcf,'Tag','showwaveform1'),'Value')==1
                   set(findobj(gcf,'Tag','4dreiecke1'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','4dreiecke1'),'Visible','off');
                end                 
                if get(findobj(gcf,'Tag','showwaveform2'),'Value')==1 
                   set(findobj(gcf,'Tag','4dreiecke2'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','4dreiecke2'),'Visible','off');
                end
                if get(findobj(gcf,'Tag','showwaveform3'),'Value')==1 
                   set(findobj(gcf,'Tag','4dreiecke3'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','4dreiecke3'),'Visible','off');
                end
                if get(findobj(gcf,'Tag','showwaveform4'),'Value')==1 
                   set(findobj(gcf,'Tag','4dreiecke4'),'Visible','on');
                else
                   set(findobj(gcf,'Tag','4dreiecke4'),'Visible','off');
                end 
          end
   end

   % --- Zoom-Funktion der Spike Train Ansicht des Spike Sortings (TA)-----
   function ZoomOption(source,event)%#ok<INUSD> 
         set(findobj(gcf,'Tag','showwaveform1'),'value',0);
         set(findobj(gcf,'Tag','showwaveform2'),'value',0);
         set(findobj(gcf,'Tag','showwaveform3'),'value',0);
         set(findobj(gcf,'Tag','showwaveform4'),'value',0);
         ZOOM_START=get(findobj(gcf,'Tag','zoomstart'),'string');
         ZOOM_END=get(findobj(gcf,'Tag','zoomend'),'string');
         if str2num(ZOOM_START)>=str2num(ZOOM_END)||str2num(ZOOM_START)<0||str2num(ZOOM_END)>T(size(T,2))%#ok
            wrongtime=figure('Name','Error','NumberTitle','OFF','Position',[300 300 400 160]);
            uicontrol(wrongtime,'Style','Pushbutton','Position', [105 45 190 25],'String','OK','FontSize',10,'Callback','close');
            uicontrol(wrongtime,'Style','text','String','Entered time out of range!','Position', [50 100 300 35],'FontSize',10,'BackgroundColor',[0.8 0.8 0.8])
         else
            for i=1:1:(NumberCluster+1)
                cla( subplot((NumberCluster+1),1,i,'Parent',waveformspanelbot))     
                if NumberCluster==2
                    subplot(3,1,1,'Parent',waveformspanelbot),plot(T,dv); %Original Wellenform wird geplottet
                    axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale bscale]);%#ok
                    hold on
                    subplot(3,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','threshZoom','visible','off','LineStyle','--','Color','red');
                    hold on
                    for k=1:length(BEGEND) 
                        subplot(3,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimuzoom','visible','off','Color','red', 'LineWidth', 1);
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==1);
                    end               
                    for z=1:1:length(y)
                        subplot(3,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==2);
                    end
                    for z=1:1:length(y)
                        subplot(3,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                end                   
                if NumberCluster==3
                    subplot(4,1,1,'Parent',waveformspanelbot),plot(T,dv);
                    axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale bscale]);%#ok
                    hold on
                    subplot(4,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','threshZoom','visible','off','LineStyle','--','Color','red');
                    hold on
                    for k=1:length(BEGEND) 
                        subplot(4,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimuzoom','visible','off','Color','red', 'LineWidth', 1);
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==1);
                    end                  
                    for z=1:1:length(y)
                        subplot(4,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==2);
                    end
                    for z=1:1:length(y)
                        subplot(4,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end                       
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==3);
                    end
                    for z=1:1:length(y)
                        subplot(4,1,4,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','b')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                         hold on
                    end
                end
                if NumberCluster==4
                    subplot(5,1,1,'Parent',waveformspanelbot),plot(T,dv);
                    axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale bscale]);%#ok
                    hold on
                    subplot(5,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','threshZoom','visible','off','LineStyle','--','Color','red');
                    hold on
                    for k=1:length(BEGEND) 
                        subplot(5,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimuzoom','visible','off','Color','red', 'LineWidth', 1);
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==1);
                    end               
                    for z=1:1:length(y)
                        subplot(5,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==2);
                    end
                    for z=1:1:length(y)
                        subplot(5,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==3);
                    end
                    for z=1:1:length(y)
                        subplot(5,1,4,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','b')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==4);
                    end                 
                    for z=1:1:length(y)
                        subplot(5,1,5,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','k')
                        axis([str2num(ZOOM_START) str2num(ZOOM_END) -bscale 20]);%#ok
                        hold on
                    end
                end
            end
         end
         Show_Threshold %muss in diese Funtion springen, damit überprüft wird ob Threshold auch in gezoomter Ansicht gezeigt wird.
   end

   % --- Y-Scale Spike Train & Originalwellenform des Spike Sortings (TA)--
   function YScale(source,event)%#ok<INUSD>                    
         set(findobj(gcf,'Tag','showwaveform1'),'value',0);
         set(findobj(gcf,'Tag','showwaveform2'),'value',0);
         set(findobj(gcf,'Tag','showwaveform3'),'value',0);
         set(findobj(gcf,'Tag','showwaveform4'),'value',0);
         set(findobj(gcf,'Tag','checkboxShowstim'),'value',0); 
         set(findobj(gcf,'Tag','checkboxThresh'),'value',0); 
         set(findobj(gcf,'Tag','zoomstart'),'string',0); 
         set(findobj(gcf,'Tag','zoomend'),'string',T(size(T,2)));  
         bscale = get(scaleSingleWaves ,'value');   % Y-Skalierung festlegen                                
         switch bscale
            case 1, bscale = 50;
            case 2, bscale = 100;
            case 3, bscale = 200;
            case 4, bscale = 500;
         end
         for i=1:1:(NumberCluster+1)
              cla( subplot((NumberCluster+1),1,i,'Parent',waveformspanelbot))                      
                if NumberCluster==2
                   subplot(3,1,1,'Parent',waveformspanelbot),plot(T,dv); %Original Wellenform wird geplottet
                   axis([0 T(size(T,2)) -bscale bscale]);
                   hold on
                   subplot(3,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','threshZoom','visible','off','LineStyle','--','Color','red');
                   hold on
                    for k=1:length(BEGEND)                                       
                        subplot(3,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimuzoom','visible','off','Color','red', 'LineWidth', 1);
                    end                        
                    for a=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==1);
                    end                
                    for z=1:1:length(y)
                        subplot(3,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
                    for b=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==2);                        
                    end
                    for z=1:1:length(y)
                        subplot(3,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
                end                   
                if NumberCluster==3
                   subplot(4,1,1,'Parent',waveformspanelbot),plot(T,dv);%Original Wellenform wird geplottet.
                   axis([0 T(size(T,2)) -bscale bscale]);
                   hold on
                   subplot(4,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','threshZoom','visible','off','LineStyle','--','Color','red');
                   hold on
                    for k=1:length(BEGEND)                                       
                        subplot(4,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimuzoom','visible','off','Color','red', 'LineWidth', 1);
                    end                         
                    for a=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==1);
                    end                  
                    for z=1:1:length(y)
                        subplot(4,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
                    for b=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==2);
                    end
                    for z=1:1:length(y)
                        subplot(4,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end                         
                    for c=1:1:length(ClusterZuordnung_Assign)
                         y=find(ClusterZuordnung_Assign==3);
                    end
                    for z=1:1:length(y)
                        subplot(4,1,4,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','b')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
                end                  
               if NumberCluster==4
                  subplot(5,1,1,'Parent',waveformspanelbot),plot(T,dv);%Original Wellenform wird geplottet
                  axis([0 T(size(T,2)) -bscale bscale]);
                  hold on
                  subplot(5,1,1,'Parent',waveformspanelbot),line ('Xdata',[ 0 T(length(T))],'Ydata',[chosenThreshold chosenThreshold],'Tag','threshZoom','visible','off','LineStyle','--','Color','red');
                     hold on
                    for k=1:length(BEGEND)                                       
                        subplot(5,1,1,'Parent',waveformspanelbot), line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],'Tag','stimuzoom','visible','off','Color','red', 'LineWidth', 1);
                    end 
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==1);
                    end                    
                    for z=1:1:length(y)
                        subplot(5,1,2,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','r')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==2);
                    end
                    for z=1:1:length(y)
                        subplot(5,1,3,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','g')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end                         
                    for k=1:1:length(ClusterZuordnung_Assign)
                         y=find(ClusterZuordnung_Assign==3);
                    end
                    for z=1:1:length(y)
                        subplot(5,1,4,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','b')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
                    for k=1:1:length(ClusterZuordnung_Assign)
                        y=find(ClusterZuordnung_Assign==4);
                    end
                    for z=1:1:length(y)
                        subplot(5,1,5,'Parent',waveformspanelbot), stem(SpikeTimes(y(z)),dv(SpikeMaxima_Stellen(z)),'marker','none','color','k')
                        axis([0 T(size(T,2)) -bscale 20]);
                        hold on
                    end
               end
         end
   end

   % --- Thresholdanzeige in Originalsignal der Spike Trains Ansicht (TA)--
   function Show_Threshold(source,event)  %#ok<INUSD>     
         if get(findobj(gcf,'Tag','checkboxThresh'),'Value')==1 
            set(findobj(gcf,'Tag','thresh'),'Visible','on');
            set(findobj(gcf,'Tag','threshZoom'),'Visible','on');
         else
            set(findobj(gcf,'Tag','thresh'),'Visible','off');
            set(findobj(gcf,'Tag','threshZoom'),'Visible','off');
         end
   end

   % --- Stimulianzeige in Originalsignal der Spike Trains Ansicht (TA)----
   function showstim(source,event)%#ok<INUSD> 
         if get(findobj(gcf,'Tag','checkboxShowstim'),'Value')==1 
             set(findobj(gcf,'Tag','stimu'),'Visible','on');
              set(findobj(gcf,'Tag','stimuzoom'),'Visible','on');
         else
             set(findobj(gcf,'Tag','stimu'),'Visible','off');
             set(findobj(gcf,'Tag','stimuzoom'),'Visible','off');
         end
   end
%----ENDE SPIKE SORTING---------------
%########################################################################
  % -------------------- Spike Analyse (RB)-------------------------------
   function Spike_Analyse (~,~)
        
        Variables = [{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'}];
                
        Variables_var =[{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};
                    {'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
                
         Var_Hist = [{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'}]; 
                
         Var_var_Hist =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'};{'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};
                    {'Right Spk. Angle(Neg./var.)'}];
                
       Var_both = [{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'}];
                
       Var_Hist_both =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'}];         
       
       Var_no_wave =[{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
       
       Var_Hist_no_wave =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Max-Min-Max ratio'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
                
       units = [{'Voltage / µV'};{'Voltage / µV'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
                {'Scalar'};{'Scalar'};{'Gradient µV / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
                {'Voltage / µV'};{'Time / ms'};{'Scalar'};{'Scalar'};];
                 
%         if varTdata~=1
             V = Variables;
             VH = Var_Hist;
%         else
%              V = Variables_var;
%              VH =  Var_var_Hist;
%         end
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);
        Spike = 0;
        first = true;
        first2 = false;
        Elektrode=[];
        Variable1=1;
        Variable2=1;
        pretime=1;
        posttime=1;
        ST = 1; 
        Min(1:(size(SPIKES,1))) = zeros;
        Max(1:(size(SPIKES,1))) = zeros;
        XX=[];
        Class(1:size(SPIKES,1))= zeros;
        count = 0;
        check = [];
        SPIKES_Discrete = [];
        k_old=-1; % muss "global sein da sie ansonsten nicht gespeichert wird!!
        
        %Hauptfenster
        SpikeAnalyseWindow = figure('Name','Spike Analyse','NumberTitle','off','Position',[45 30 1270 750],'Toolbar','none','Resize','off');
        uicontrol('Parent',SpikeAnalyseWindow,'Style', 'text','Position', [1082 398 200 20],'HorizontalAlignment','left','String', 'Spike Visualization:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SpikeAnalyseWindow,'Style', 'text','Position', [697 398 120 20],'HorizontalAlignment','left','String', 'Clustering:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        
        %Button-Bereich 
        ControlPanel=uipanel('Parent',SpikeAnalyseWindow,'Units','pixels','Position',[10 360 615 360],'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 331 100 20],'HorizontalAlignment','left','String', 'General:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 228 100 20],'HorizontalAlignment','left','String', 'Histogram:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 331 100 20],'HorizontalAlignment','left','String', 'Statistics:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
            
        %Elektroden Auswahl
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 312 100 20],'HorizontalAlignment','left','String', 'Electrode: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [93 284 50 50],'Tag','A_Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu');
        
        %Auswahl der betrachteten Zeit vor und nach dem Spike-Minimum
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 290 100 20],'HorizontalAlignment','left','String', 'Spike Time: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position',[93 262 70 50],'Tag','pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','callback',@recalc);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position',[168 262 70 50],'Tag','posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','callback',@recalc);
        
        %Auswahl Variable 1
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 268 100 20],'HorizontalAlignment','left','String', 'Variable 1: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [93 240 147 50],'HorizontalAlignment','left','Tag','Variable 1','FontSize',8,'String',V,'Value',1,'Style','popupmenu');

        %Auswahl Variable 2
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [10 247 100 20],'HorizontalAlignment','left','String', 'Variable 2: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [93 219 147 50],'HorizontalAlignment','left','Tag','Variable 2','FontSize',8,'String',V,'Value',1,'Style','popupmenu');

        %Cluster Übersicht anzeigen
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [100 228 20 20],'HorizontalAlignment','left','FontSize',8,'Tag','Cluster','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position',[120 228 150 14],'HorizontalAlignment','left','String','Cluster Summary','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        %Wavelets an/aus
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position',[260 16 20 15],'HorizontalAlignment','left','FontSize',8,'Tag','Wavelet','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position',[280 16 150 14],'HorizontalAlignment','left','String','Wavelet Packet Analysis','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        %Signal integrieren/differenzieren
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [260 1 15 15],'Tag','Int_dif','HorizontalAlignment','right','FontSize',8,'Value',1,'String',0,'Style','edit','callback',@recalc);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position',[280 1 150 14],'HorizontalAlignment','left','String','Derivation','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
       
        %Berechnung Starten
        uicontrol('Parent',ControlPanel,'Position', [509 5 80 20],'String', 'Start','FontSize',11,'FontWeight','bold','callback',@Start);
        
        %Histogramm Auswahl
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 208 147 20],'HorizontalAlignment','left','Tag','H1','FontSize',8,'String',VH,'Value',2,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 210 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph1','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units', 'Pixels','Position', [10 186 147 20],'HorizontalAlignment','left','Tag','H2','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 188 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph2','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 164 147 20],'HorizontalAlignment','left','Tag','H3','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 166 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph3','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 142 147 20],'HorizontalAlignment','left','Tag','H4','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 144 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph4','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units', 'Pixels','Position', [10 120 147 20],'HorizontalAlignment','left','Tag','H5','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 122 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph5','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 98 147 20],'HorizontalAlignment','left','Tag','H6','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 100 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph6','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 76 147 20],'HorizontalAlignment','left','Tag','H7','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 78 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph7','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 54 147 20],'HorizontalAlignment','left','Tag','H8','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 56 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph8','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 32 147 20],'HorizontalAlignment','left','Tag','H9','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 34 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph9','BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ControlPanel,'Units','Pixels','Position', [10 10 147 20],'HorizontalAlignment','left','Tag','H10','FontSize',8,'String',VH,'Value',1,'Style','popupmenu');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [162 12 10 10],'HorizontalAlignment','left','FontSize',8,'Tag','Hgraph10','BackgroundColor',[0.8 0.8 0.8]);
       
        %Statistiken
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [420 329 40 20],'HorizontalAlignment','left','String','Mean','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [468 329 30 20],'HorizontalAlignment','left','String','Var','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [511 329 30 20],'HorizontalAlignment','left','String','Min','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [554 329 30 20],'HorizontalAlignment','left','String','Max','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 303 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H1'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 306 40 20],'Tag','Mean1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 306 40 20],'Tag','Var1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 306 40 20],'Tag','Min1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 306 40 20],'Tag','Max1','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 273 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H2'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 276 40 20],'Tag','Mean2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 276 40 20],'Tag','Var2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 276 40 20],'Tag','Min2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 276 40 20],'Tag','Max2','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 243 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H3'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 246 40 20],'Tag','Mean3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 246 40 20],'Tag','Var3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 246 40 20],'Tag','Min3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 246 40 20],'Tag','Max3','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 213 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H4'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 216 40 20],'Tag','Mean4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 216 40 20],'Tag','Var4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 216 40 20],'Tag','Min4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 216 40 20],'Tag','Max4','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 183 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H5'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 186 40 20],'Tag','Mean5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 186 40 20],'Tag','Var5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 186 40 20],'Tag','Min5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 186 40 20],'Tag','Max5','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
       
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 153 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H6'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 156 40 20],'Tag','Mean6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 156 40 20],'Tag','Var6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 156 40 20],'Tag','Min6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 156 40 20],'Tag','Max6','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
       
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 123 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H7'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 126 40 20],'Tag','Mean7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 126 40 20],'Tag','Var7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 126 40 20],'Tag','Min7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 126 40 20],'Tag','Max7','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 93 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H8'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 96 40 20],'Tag','Mean8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 96 40 20],'Tag','Var8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 96 40 20],'Tag','Min8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 96 40 20],'Tag','Max8','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 63 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H9'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 66 40 20],'Tag','Mean9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 66 40 20],'Tag','Var9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 66 40 20],'Tag','Min9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 66 40 20],'Tag','Max9','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        uicontrol ('Parent',ControlPanel,'Style', 'text','Position', [260 33 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H10'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [420 36 40 20],'Tag','Mean10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [463 36 40 20],'Tag','Var10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [506 36 40 20],'Tag','Min10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        uicontrol ('Parent',ControlPanel,'Units','Pixels','Position', [549 36 40 20],'Tag','Max10','HorizontalAlignment','right','FontSize',8,'Value',1,'Style','edit');
        
        %Select-Button-Bereich 
        SelectPanel = uipanel('Parent',SpikeAnalyseWindow,'Units','pixels','Position',[1085 342 175 55],'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',SelectPanel,'Position', [5 30 80 20],'String', 'Select','FontSize',11,'FontWeight','bold','callback',@Sel);
        uicontrol('Parent',SelectPanel,'Position', [90 30 80 20],'String', 'Reset','FontSize',11,'FontWeight','bold','callback',@Start);
        uicontrol('Parent',SelectPanel,'Position', [5 5 80 20],'String', 'Spike','FontSize',11,'FontWeight','bold','callback',@ShowSpike);
        uicontrol('Parent',SelectPanel,'Position', [90 5 80 20],'String', 'Class','FontSize',11,'FontWeight','bold','callback',@ShowClass);
        
        %Cluster-Bereich
        ClusterPanel = uipanel('Parent',SpikeAnalyseWindow,'Units','pixels','Position',[695 342 385 55],'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [5 30 80 20],'HorizontalAlignment','left','String', 'Parameters:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [100 40 20 11],'HorizontalAlignment','left','FontSize',8,'Tag','Histogram','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [100 27 20 11],'HorizontalAlignment','left','FontSize',8,'Tag','Variables','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [118 38 50 14],'HorizontalAlignment','left','String', 'Histogram','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [118 27 50 11],'HorizontalAlignment','left','String', 'Variables','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [5 5 95 20],'HorizontalAlignment','left','String', 'Bin_Nr:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [100 5 40 20],'Tag','Bin_Nr','HorizontalAlignment','right','FontSize',10,'Value',1,'Style','edit');
        
        uicontrol('Parent',ClusterPanel,'Style', 'text','Position', [194 30 61 20],'HorizontalAlignment','left','String', 'Class Nr.:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol ('Parent',ClusterPanel,'Units','Pixels','Position', [255 30 40 20],'Tag','K_Nr','HorizontalAlignment','right','FontSize',8,'Value',1,'String',2,'Style','edit');
        
        uicontrol('Parent',ClusterPanel,'Position', [300 30 80 20],'String', 'K-Means','FontSize',11,'FontWeight','bold','callback',@K_Means_choice);
        uicontrol('Parent',ClusterPanel,'Position', [300 5 80 20],'String', 'EM','FontSize',11,'FontWeight','bold','callback',@EM_choice);
        uicontrol('Parent',ClusterPanel,'Position', [215 5 80 20],'String', 'Discretize','FontSize',11,'FontWeight','bold','callback',@Diskretize);
        
        %Shapes Graph
        Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]);
        axis([0 2 -100 50]);
        
        %Histogramm
        histogramm = subplot('Position',[0.045 0.06 0.445 0.41]);
        
        %Scatterplot
        scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]);  
        recalc;
        
   

        function recalc(~,~) % set data to false if Window is (re-)opened
            data =false;
        end

       function calc(~,~) %Amplitude, Neo, Shapes
    
       %     SPIKES3D:      % Blatt 1: Timestamp des Spikes; Blatt 2: Negative Amplitude des Spikes;
                            % Blatt 3: Positive Amplitude des Spikes; Blatt 4: Ergebnis des NEO des Spikes;
                            % Blatt 5: Negative Signalenergie des Spikes; % Blatt 6: Positive Signalenergie des Spikes;
                            % Blatt 7: Spikedauer; Blatt 8: Öffnungswinkel nach links; 
                            % Blatt 9: Öffnungswinkel nach rechts; Blatt 10: 1. Hauptkomponente; Blatt 11: 2. Hauptkomponente;
                            % Blatt 12: 3. Hauptkomponente; Blatt 13: 4. Hauptkomponente; Blatt 14: Max-Min-Max ratio; 
                            % Blatt 15: Wavelet Coefficients (höchste Varianz); Blatt 16: Wavelet Coefficients (höchste Energy-Varianz);
                            % Blatt 17: varAmplitude; Blatt 18: varSpikedauer; 
                            % Blatt 19: varÖffnungswinkel nach links; Blatt 20: varÖffnungswinkel nach rechts;
        
        SPIKES3D=SPIKES;
        SPI =SPIKES3D(:,:,1)*SaRa;
        SPIKES3D(:,size(SPIKES,2),2:16)=zeros; 
        pretime = preti(get(findobj(gcf,'Tag','pretime'),'value'));
        posttime = postti(get(findobj(gcf,'Tag','posttime'),'value'));
        
        Neo(1:size(M,1),size(M,2))=zeros;
        order = str2double(get(findobj(gcf,'Tag','Int_dif'),'String'));
       
        for m=1:size(M,2)
            for i=2:1:(size(M,1)-1)
                Neo(i,m)= M(i,m)^2-(M(i-1,m)*M(i+1,m));
            end
        end
        
    
        for n=1:size(SPIKES3D,2)%für jede Elektrode   
            
            
           SPI1=nonzeros(SPI(:,n));
           
           for i=1:size(SPI1,1)
            if ((SPI1(i)+1+floor(SaRa*posttime/1000))>size(M,1))||((SPI1(i)+1-ceil(SaRa*pretime/1000)) <=0) % Anpassung da Spikelänge insgesamt 2*0.5 msec!!!
               S_orig(i,n,1:1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))= zeros;
            else
                S_orig(i,n,:)=M(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n); % Shapes variabler Länge
                S_old = S_orig;
                Shapes(i,n,:) = S_orig(i,n,:);
                Neo_Shapes(i,n,:)=Neo(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n); 
                
                
                %Amplitude: bei variablem Threshold offset
                %berücksichtigen
                if varTdata~=1
                   SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2))); %modifieziert um nicht überlagerte Spikes zu verwechseln
                else
                   clear temp_datal temp_datar temp_pl temp_pr
                   Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes der Länge 2ms  
                   Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
                   Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
                   SPIKES3D(i,n,2)=(Shapesvar(i,n,SaRa/1000+1)); 
                end
                % Ende Amplitudenberechnung
                    
                SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2))); %modifieziert um nicht überlagerte Spikes zu verwechseln
                SPIKES3D(i,n,3)=max(Shapes(i,n,ceil(0.25*SaRa/1000):size(Shapes,3)-ceil(0.25*SaRa/1000))); % modifizierter Bereich um nicht überlagerte Spikes zu verwechseln!
                SPIKES3D(i,n,4)=(Neo_Shapes(i,n,ceil((size(Shapes,3))/2))); %modifieziert um nicht überlagerte Spikes zu verwechseln
                [C(1),I(1)]= max(Shapes(i,n,1:ceil((size(Shapes,3))/2)));
                [C(2),I(2)]= max(Shapes(i,n,floor(0.25*SaRa/1000):size(Shapes,3)-ceil(0.25*SaRa/1000)));
                % Di = Shapes(i,n,:)-SPIKES3D(i,n,2); % Berechnung der Differenz zwischen den einzelnen Punkten und dem Minimum                 
                % Pre=find(Di(1,1,1:SaRa/1000+1)>= 0.8*(C(1)-SPIKES3D(i,n,2))); % eingefügte Berechnung, um Zeitpunkt mit 80% des gefundenen Maximums zu ermitteln
                % Post=find(Di(1,1,SaRa/1000+1:size(Shapes,3))>= 0.8*(C(2)-SPIKES3D(i,n,2))); % ev. dadurch robuster gegen Rauschen
                % C(1)=Shapes(i,n,max(Pre));
                % I(1)= max(Pre);
                % C(2)=Shapes(i,n,min(Post));
                % I(2)= min(Post);
                SPIKES3D(i,n,14)=(-(C(1)-SPIKES3D(i,n,2))/((SaRa/1000)+1-I(1)))+((C(2)-SPIKES3D(i,n,2))/(I(2))); % Differenz der Steigungen zwischen lokalem Max vor dem Spike und Min)
                % SPIKES3D(i,n,12)=((C(1)-SPIKES3D(i,n,2))/((SaRa/1000)+1-I(1)))/((C(2)-SPIKES3D(i,n,2))/(I(2)));  % Version mit Verhältnis anstatt Differenz                                                                                              % und  lokalem Max nach dem Spike und Min (Max-Min-Max ratio)
                clear Neo_Shapes;


                templeft = [];
                tempright = [];

            % Berechnung des Öffnungswinkels (Andy)/(Robert)

                % Punkte finden, an denen 50% überschritten wurden
                % 1. nach "links"
                %figure(100+i)
                %X_temp(:,:)= Shapes(i,n,:);
                %plot(X_temp)
               for j = ceil((size(Shapes,3))/2):-1:1
                   if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                      templeft =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % Steigung von Min zu 50% von Min
                      SPIKES3D(i,n,8) = atand(templeft); % Umrechnung in Grad
                      templeft = j; %umspeicherung des Indexes;
                      break
                   end
               end
               % 2. nach "rechts"
               for j = ceil((size(Shapes,3))/2):1:size(Shapes,3)
                   if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                      tempright =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % Steigung von Min zu 50% von Min
                      SPIKES3D(i,n,9) = atand(tempright); % Umrechnung in Grad
                      tempright = j;
                      break
                   end
               end
               if size(templeft) == 0
                  [~,templeft] = max(Shapes(i,n,ceil(0.25*SaRa/1000):ceil((size(Shapes,3))/2)));
                  SPIKES3D(i,n,8) = abs((Shapes(i,n,templeft)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(templeft-ceil((size(Shapes,3))/2))); 
               end
               if size(tempright) == 0
                  [~,tempright] = max(ceil((size(Shapes,3))/2):(size(Shapes,3)-ceil(0.25*SaRa/1000)));
                  SPIKES3D(i,n,9) = abs((Shapes(i,n,tempright)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(tempright-ceil((size(Shapes,3))/2)));
               end

               % Spikedauer (interpolation der Winkel auf y = 0)
               % SPIKES3D(i,n,7)=((0-Shapes(i,n,SaRa/1000+1))/templeft)+((0-Shapes(i,n,SaRa/1000+1))/SPIKES3D(i,n,8)); 

               SPIKES3D(i,n,7) = tempright-templeft;
        
            % Wurden die Spikes über den variablen Threshold ermittelt,
            % stehen noch weitere Parameter zu Verfügung:

%                 if varTdata==1
%                     clear temp_datal temp_datar temp_pl temp_pr
%                     Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes der Länge 2ms  
%                     Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
%                     Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
% 
%                                     if Shapesvar(i,n,SaRa/1000+1)< 0 
%                                     j=0;
%                                     while Shapesvar(i,n,SaRa/1000+1-j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1-j)>1;  % 50% des Amplitudenwertes
% 
%                                         temp_datal(j+1,1)=-1000*j*(1/SaRa);
%                                         temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
%                                      j=j+1;  %nach "links"
%                                     end
%                                         temp_datal(j+1,1)=-1000*j*(1/SaRa);
%                                         temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
% 
%                                    % 2. nach "rechts"
% 
%                                     j=0;
%                                     while Shapesvar(i,n,SaRa/1000+1+j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1+j)<(size(Shapesvar,3)-1);  % 50% des Amplitudenwertes
% 
%                                         temp_datar(j+1,1)=1000*j*(1/SaRa);
%                                         temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
%                                         j=j+1;  %nach "rechts"
%                                     end               
%                                         temp_datar(j+1,1)=1000*j*(1/SaRa);
%                                         temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
% 
%                                         % Gerade aus Punkten ermitteln; wann schneidet diese
%                                         % die y-Achse
% 
%                                         temp_pl = polyfit(temp_datal(:,1),temp_datal(:,2),1);
%                                         temp_pr = polyfit(temp_datar(:,1),temp_datar(:,2),1);
% 
%                                             % varAmplitude in 12
%                                             SPIKES3D(i,n,21)=(Shapesvar(i,n,SaRa/1000+1));    
% 
%                                             % varSpikedauer in 13                   
%                                             SPIKES3D(i,n,22)= roots(temp_pl)*(-1) + roots(temp_pr);
% 
%                                             % varÖffnungswinkel nach links in 14
%                                             SPIKES3D(i,n,23)=atan((roots(temp_pl)*(-1))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
% 
%                                             % varÖffnungswinkel nach rechts in 15
%                                             SPIKES3D(i,n,24)=atan((roots(temp_pr))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
%                                     end    
%                 end
              end
              clear temp_datal temp_datar temp_pl temp_pr
           end
        end
    end 
    
    function calc_PCA(~,~) %calculate principal components
        
            XX(1:size(Shapes,1),1:size(Shapes,3))=Shapes(:,n,:); %Shapes muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!
            [~,Score]=princomp(XX);
        
            SPIKES3D(:,n,10)=Score(:,1); %HK 1
            SPIKES3D(:,n,11)=Score(:,2); %HK 2
            SPIKES3D(:,n,12)=Score(:,3); %HK 3
            SPIKES3D(:,n,13)=Score(:,4); %HK 4
            clear Score I; 
    end
        
              
    
    function calc_area(~,~) %positive und negative Flächen berechnen
        k=1;
        Temp=0;
        clear MU S i n ZPOS ZNEG POS NEG;
        MU(1:size(Shapes,1),1:size(Shapes,2),1:size(Shapes,3))=zeros;
        
         for n=1:size(Shapes,2)%für jede Elektrode
            for i=1:size(Shapes,1)%Vorzeichenwechsel in Shapes bestimmen
                for j=1:size(Shapes,3)%alle Spike Werte durchlaufen
                    if Shapes(i,n,j)~=0
                        if sign(Shapes(i,n,j))~= sign(Temp(1,1))  
                            if Temp~=0
                                MU(i,n,k)=j-1;
                                k=k+1;
                            else
                            end
                            Temp=Shapes(i,n,j);
                        else
                        end
                    else 
                    end
                end
                Temp=0;
                k=1;
            end
            i=1;
         end


         for n=1:size(Shapes,2) %Spannungswerte Quadrieren um Signalenergie zu berechnen
            for i=1:size(Shapes,1)
                for j=1:size(Shapes,3)
                    S(i,n,j)=sign(Shapes(i,n,j))*(Shapes(i,n,j))^2;
                end
            end
         end

        for n=1:size(S,2)

             POS=0;  %Benötigt um zu testen, ob ZPOS bzw. ZNEG schon beschrieben wurden
             NEG=0;
             ZPOS(1:size(MU,3),1:size(MU,1))=zeros;
             ZNEG(1:size(MU,3),1:size(MU,1))=zeros;
             for i=1:size(S,1) %POS und NEG Flächen einzeln berechnen
                    for j=1:size(MU,3)
                        if (MU(i,n,j)<= 0) && (j>1) %Da MU immer mit Nullen aufgefüllt wird muss so geprüft werden
                            TMP=((1/SaRa)*(trapz(S(i,n,MU(i,n,j-1)+1:size(S,3)))));  
                            if(TMP>=0)
                                if(POS~=0)
                                    POS=POS+1;
                                    ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                else
                                    POS=1;
                                    ZPOS(POS,i)=TMP; 
                                end
                                break
                            else
                                if(NEG~=0)
                                    NEG=NEG+1;
                                    ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                else
                                    NEG=1;
                                    ZNEG(NEG,i)=TMP;
                                end
                            end
                            break
                        elseif(MU(i,n,j)<=0) && (j<=1) %Fall dass gar kein Vorzeichenwechsel erfolgt
                            TMP=(1/SaRa)*((trapz(S(i,n,1:size(S,3)))));
                            if(TMP>=0)
                                POS=1;
                                ZPOS(POS,i)=TMP; 
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                            break
                        else
                            if j==1
                                TMP=(1/SaRa)*((trapz(S(i,n,1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))); % die Zwischenfläche beim Vorzeichenwechsel!  
                                if(TMP>=0)
                                    if(POS~=0)
                                        POS=POS+1;
                                        ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                    else
                                        POS=1;
                                        ZPOS(POS,i)=TMP;   
                                    end
                                else
                                    if(NEG~=0)
                                        NEG=NEG+1;
                                        ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                    else
                                        NEG=1;
                                        ZNEG(NEG,i)=TMP;
                                    end
                                end
                            elseif j>=size(MU,3)  
                                TMP=(1/SaRa)*(trapz(S(i,n,MU(i,n,j)+1:size(S,3)))); %Restfläche des Graphen(SpikeShape mit den meisten Vorzeichenwechseln) (Muss gemacht werden da die Anzahl der Flächen immer um 1 größer ist als die Anzahl der Vorzeichenwechsel!    
                                if(TMP>=0)
                                    if(POS~=0)
                                        POS=POS+1;
                                        ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                    else
                                        POS=1;
                                        ZPOS(POS,i)=TMP;   
                                    end
                                else
                                    if(NEG~=0)
                                        NEG=NEG+1;
                                        ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                    else
                                        NEG=1;
                                        ZNEG(NEG,i)=TMP;
                                    end
                                end
                            else
                                TMP=(1/SaRa)*((trapz(S(i,n,MU(i,n,j-1)+1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))+(0.5*(1-(-S(i,n,MU(i,n,j-1))/(S(i,n,MU(i,n,j-1)+1)-S(i,n,MU(i,n,j-1)))))*S(i,n,MU(i,n,j-1)+1))); 
                                if(TMP>=0)
                                    if(POS~=0)
                                        POS=POS+1;
                                        ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                                    else
                                        POS=1;
                                        ZPOS(POS,i)=TMP;   
                                    end
                                else
                                    if(NEG~=0)
                                        NEG=NEG+1;
                                        ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                                    else
                                        NEG=1;
                                        ZNEG(NEG,i)=TMP;
                                    end
                                end
                            end
                        end
                    end
                    POS=0;
                    NEG=0;
            end
            if size(ZPOS,1)~=i
               ZPOS(1,i)=0;
            end
            if size(ZNEG,1)~=i
               ZNEG(1,i)=0;
            end

            for i=1:size(Shapes,1) % Ergebnis der Flächenberechnung für jeden Spike der Elektrode
               SPIKES3D(i,n,6)=max(ZPOS(:,i));
               SPIKES3D(i,n,5)=min(ZNEG(:,i));
            end
            i=1;
        end
        data= true;
    end

    function calc_mean(~,~)
        
        Objekts = [{'Mean1'} {'Var1'} {'Min1'} {'Max1'};{'Mean2'} {'Var2'} {'Min2'} {'Max2'};{'Mean3'} {'Var3'} {'Min3'} {'Max3'};
                  {'Mean4'} {'Var4'} {'Min4'} {'Max4'};{'Mean5'} {'Var5'} {'Min5'} {'Max5'};{'Mean6'} {'Var6'} {'Min6'} {'Max6'};
                  {'Mean7'} {'Var7'} {'Min7'} {'Max7'};{'Mean8'} {'Var8'} {'Min8'} {'Max8'};{'Mean9'} {'Var9'} {'Min9'} {'Max9'};
                  {'Mean10'} {'Var10'} {'Min10'} {'Max10'};];
             
        H = [{'H1'} {'H2'} {'H3'} {'H4'} {'H5'} {'H6'} {'H7'} {'H8'} {'H9'} {'H10'}];
        
        for i=1:size(H,2)
            
            check(i) = get(findobj(gcf,'Tag',char(H(i))),'value');
            
            if check(i)~= 1
                set(findobj(gcf,'Tag',char(Objekts(i,1))),'String',mean(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)))); %Einlesen in das entsprechende edit Feld; erfolgt Zeilenweise
                set(findobj(gcf,'Tag',char(Objekts(i,2))),'String',var(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                set(findobj(gcf,'Tag',char(Objekts(i,3))),'String',min(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                set(findobj(gcf,'Tag',char(Objekts(i,4))),'String',max(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
            else
                set(findobj(gcf,'Tag',char(Objekts(i,1))),'String',''); %Einlesen in das entsprechende edit Feld; erfolgt Zeilenweise
                set(findobj(gcf,'Tag',char(Objekts(i,2))),'String','');
                set(findobj(gcf,'Tag',char(Objekts(i,3))),'String','');
                set(findobj(gcf,'Tag',char(Objekts(i,4))),'String','');
            end
        end
        
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 303 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H1'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 273 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H2'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 243 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H3'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 213 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H4'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 183 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H5'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 153 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H6'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 123 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H7'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 93 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H8'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 63 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H9'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',ControlPanel,'Style', 'text','Position', [260 33 160 20],'HorizontalAlignment','left','String',VH(get(findobj(gcf,'Tag','H10'),'value')),'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        
        clear H Objekts check;
    end
  function Wave_Coeff(~,~)

       Energy(1:size(Shapes,1),1:8)=zeros;
       for n=1:size(Shapes,2)
           if size(nonzeros(SPIKES(:,n)),1)<=1
              continue
           else
                
            for Nr=1:3
                  
              if Nr==1    
               for i=1:1:size(nonzeros(SPIKES(:,n)),1)
                   
                   MX(:,:)=(Shapes(i,n,:));
                   TREE1 = wpdec(MX,3,'db4');
                   Energy(i,:) = wenergy(TREE1);
                   if isnan(Energy(i,:))==1
                      Energy(i,:)=zeros;
                   end
                      Coeff(i,:)=read(TREE1,'data');
               end
              else
               for i=1:1:size(nonzeros(SPIKES(:,n)),1)
                   
                  Coeff(i,I1)=zeros;
                  TREE = write(TREE1,'data',Coeff(i,:));
                  MX(:,:)=wprec(TREE);     
                  TREE = wpdec(MX,3,'db4');
                  Energy(i,:) = wenergy(TREE);
                  if isnan(Energy(i,:))==1
                      Energy(i,:)=zeros;
                  end
                      Coeff(i,:)=read(TREE,'data');
               end
                  
              end
               
               for i=1:size(Coeff,2)
                   [y,z] = hist(Coeff(:,i),100); % histogramm plot
                   for nn=1:6
                       y = smooth(y);    % plot smoothing  
                   end
                   [~,I(1)]=max(y);  % 1. Extremum globales Maximum der Verteilung!!
                   
                   y = y-min(y); % Norm the plots in x and y
                   z = z-min(z);
                   y = y/max(y);
                   z = z/max(z);
                   
                   k=2;
                   %figure(10+i) %Test der Verteilungen
                   %plot(z,y);
                   ERG = 0;
                   for j=1:size(y)-1
                       dy(j,1)= (y(j+1,1)-y(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
                       if j>1
                          if (dy(j,1)<0 && dy(j-1,1)>=0)
                              I(k)= j;                                              % X-Komponente von Maximum über Steigung bestimmt  
                              [~,best]=min(ERG);
                              if (y(I(best),1)-y(I(k),1))/(z(1,I(best))-z(1,I(k)))~=0 && (I(best)~=I(k))
                                 if I(best)<I(k)
                                    [~,MIN] = min(y(I(best):I(k)));
                                     MIN = I(best)+MIN;
                                 else
                                    [~,MIN] = min(y(I(k):I(best)));
                                     MIN = I(k)+MIN;
                                 end
                                 ERG(k-1)=((y(I(best),1)-y(I(k),1))/(z(1,I(best))-z(1,I(k))))/((y(I(best),1)-y(MIN,1))/(z(1,I(best))-z(1,MIN)))/(y(I(k))-y(MIN))*y(I(1));
                                 if isnan(ERG(k-1))
                                    ERG(k-1) =0;
                                 else
                                    k=k+1;
                                 end
                              end
                          else
                              RES(i)=1000;
                          end
                       end
                   end        
                   if max(ERG)~=0
                      RES(i) = min(abs(ERG)); %best Result divided by Nr. of extrema found in the distribution
                   end
                   ERG = [];
                   I=[];
                   y = [];
                     
                   if i<=8
                      Variance(i)=var(Energy(:,i)); % Berechnung für Energie-koeffizienten
                      Mean(i,2)=mean(Energy(:,i));
                      RESE(i)=abs(Variance(i)/Mean(i,2)); 
                   end
               end
               [~,I1]=min(RES); % Allgemein bester Koeffizient hinsichtlich Verteilung
               SPIKES3D(1:size(Coeff,1),n,14+Nr) = Coeff(:,I1);
               if Variance(8)~=0 
                  Variance(8)=1;
               end
               [~,I]=max(RESE); % beste Energie-koeffizienten
               if Nr>1
                  SPIKES3D(:,n,17+Nr)=Energy(:,I);
                  RESE(I) = 0;
               else
                   SPIKES3D(:,n,17+Nr)=Energy(:,I);
                  RESE(I) = 0;
               end
                             
            end
           end
       end
       clear Mean Variance Energy MX RES RESE RESV TREE k I I1 Nr ERG Coeff;
    end
    function Start (~,~)
        
        Class(:,:) = [];
        tic
        Hgraph = [{'Hgraph1'} {'Hgraph2'} {'Hgraph3'} {'Hgraph4'} {'Hgraph5'} {'Hgraph6'} {'Hgraph7'} {'Hgraph8'} {'Hgraph9'} {'Hgraph10'}];
        H = [{'H1'} {'H2'} {'H3'} {'H4'} {'H5'} {'H6'} {'H7'} {'H8'} {'H9'} {'H10'}];
        Elektrode=get(findobj(gcf,'Tag','A_Elektrodenauswahl'),'value');
        Variable1=get(findobj(gcf,'Tag','Variable 1'),'value');
        Variable2=get(findobj(gcf,'Tag','Variable 2'),'value');
        pretime=preti(get(findobj(gcf,'Tag','pretime'),'value'));
        posttime=postti(get(findobj(gcf,'Tag','posttime'),'value'));
        
        if size(nonzeros(SPIKES(:,Elektrode)),1) >= 9
           uicontrol('Parent',ControlPanel,'Style', 'text','Position', [150 321 50 15],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','k','BackgroundColor',[0.8 0.8 0.8]); 
           uicontrol('Parent',ControlPanel,'Style', 'text','Position', [200 321 50 15],'HorizontalAlignment','left','String',size(nonzeros(SPIKES(:,Elektrode))),'FontSize',10,'FontWeight','bold','ForegroundColor','k','BackgroundColor',[0.8 0.8 0.8]);
        else
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [150 321 50 15],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor',[0.8 0.8 0.8]); 
            uicontrol('Parent',ControlPanel,'Style', 'text','Position', [200 321 50 15],'HorizontalAlignment','left','String',size(nonzeros(SPIKES(:,Elektrode))),'FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor',[0.8 0.8 0.8]);
        end
        
%         if varTdata~=1
            if get(findobj(gcf,'Tag','Wavelet'),'value')== 0
                set(findobj(gcf,'Tag','Variable 1'),'String',Var_both);
                set(findobj(gcf,'Tag','Variable 2'),'String',Var_both);
                for i=1:size(H,2)
                    set(findobj(gcf,'Tag',char(H(i))),'String',Var_Hist_both);
                end
                set(findobj(gcf,'Tag','Wavelet'),'enable','off')
            else
                set(findobj(gcf,'Tag','Variable 1'),'String',Variables);
                set(findobj(gcf,'Tag','Variable 2'),'String',Variables);
                for i=1:size(H,2)
                    set(findobj(gcf,'Tag',char(H(i))),'String',Var_Hist);
                end
            end
%         elseif get(findobj(gcf,'Tag','Wavelet'),'value')==0
%             set(findobj(gcf,'Tag','Variable 1'),'String',Var_no_wave);
%             set(findobj(gcf,'Tag','Variable 2'),'String',Var_no_wave);
%             for i=1:size(H,2)
%                     set(findobj(gcf,'Tag',char(H(i))),'String',Var_Hist_no_wave);
%             end
%             set(findobj(gcf,'Tag','Wavelet'),'enable',off)
%         else
%             set(findobj(gcf,'Tag','Variable 1'),'String',Variables_var);
%             set(findobj(gcf,'Tag','Variable 1'),'String',Variables_var);
%             for i=1:size(H,2)
%                 set(findobj(gcf,'Tag',char(H(i))),'String',Var_var_Hist);
%             end
%         end
         
        if data == false %Überprüfung ob Daten schon berechnet wurden
            Shapes=[]; 
            XX=[];
            Shapes(1:size(SPIKES,1),1:size(SPIKES,2),1:(((pretime+posttime)*SaRa))/1000+1)=zeros;

            calc; %Berechnungen durchführen
            calc_area;
            calculate_PCA;
            if get(findobj(gcf,'Tag','Wavelet'),'value')==1
               Wave_Coeff;
            end
                            
            %Shapes Graph
            ST = (-pretime:1000/SaRa:posttime); %Max(1) und Min(1) explizit für den Shapes Graph; Merkmale erst ab i=2!!!
            MAX2D = max(Shapes);
            MAX1D = max(MAX2D);
            Max(1) = max(MAX1D);
            MIN2D = min(Shapes);
            MIN1D = min(MIN2D);
            Min(1) = min(MIN1D);
           
            for i=2:(size(SPIKES3D,3))
                MIN2D = min(nonzeros(SPIKES3D(:,:,i))); 
                MAX2D = max(nonzeros(SPIKES3D(:,:,i)));
                MIN1D = min(MIN2D);
                MAX1D = max(MAX2D);
                if size(MIN1D) ~= 0
                    Min(i) = min(MIN1D);
                else
                    Min(i)=0;
                end
                if size(MAX1D) ~= 0
                    Max(i) = max(MAX1D);
                else
                    Max(i)=0;
                end
            end
             clear MIN2D MIN1D MAX2D MAX1D;
        end
        calc_mean;
        XX=[];
        XX(1:size(nonzeros(SPIKES(:,Elektrode)),1),1:size(Shapes,3))= Shapes(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,:); %Shapes muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!
        Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]); 
        if size(XX,1)~=0
           Spikeplot = plot(ST,XX); 
           axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
        else
            Spikeplot = plot(zeros);
        end
           xlabel ('time / ms');
           ylabel({'Voltage / µV'});

        %Histogramm
        histogramm = subplot('Position',[0.045 0.06 0.445 0.41]);
        CMAP = Colormap;
        count = 0;
        for i=1:size(H,2)
            check(i) = get(findobj(gcf,'Tag',char(H(i))),'value');
            if check(i)== 1;
                count = count + 1;
            end
        end    
        if count < 9 % falls mehrere Merkmale aktiviert sind
            SPIKES3D_Norm=[];
            count2 = 1;
            for i=1:size(check,2)
                if check(i)~=1
                    if size(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)),1)~=0
                       SPIKES3D_Norm(:,count2) = (SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))-min(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))))/(max(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)))-min(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i))));
                       if min(SPIKES3D_Norm(:,count2))~=0
                          SPIKES3D_Norm(:,count2) = SPIKES3D_Norm(:,count2)*(-1);
                       end
                    end
                   count2 = count2 +1;
                end
            end
            hist(SPIKES3D_Norm,20);
            color = round(linspace(1,size(Colormap,1),count2-1));
            count2 = 1;
            for i=1:size(check,2)
                if check(i) ~= 1
                    set(findobj(gcf,'Tag',char(Hgraph(i))),'BackgroundColor',[CMAP(color(count2),1) CMAP(color(count2),2) CMAP(color(count2),3)]);
                    count2 = count2 + 1;
                else 
                    set(findobj(gcf,'Tag',char(Hgraph(i))),'BackgroundColor',[0.8 0.8 0.8]);
                end
            end
        xlabel ('Normalized Scale');
        ylabel({'Nr. of Hits'});
        else
            [C,I]=max(check); % falls nur ein Merkmal aktiviert ist
            v= Min(C):(Max(C)-Min(C))/100:Max(C);
            hist(nonzeros(SPIKES3D(:,Elektrode,C)),v);
            for i=1:size(check,2)
                set(findobj(gcf,'Tag',char(Hgraph(i))),'BackgroundColor',[0.8 0.8 0.8]);
            end
            set(findobj(gcf,'Tag',char(Hgraph(I))),'BackgroundColor',[CMAP(1,1) CMAP(1,2) CMAP(1,3)]);
            xlabel (char(units(I)));
            ylabel({'Nr. of Hits'});
        end
        
        %Scatterplot
        scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]);  
        scatterplot = scatter(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,Variable1+1),SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,Variable2+1),18,'filled');
        axis([Min(Variable1+1) Max(Variable1+1) Min(Variable2+1) Max(Variable2+1)]);
        xlabel (char(units(Variable1)));
        ylabel(char(units(Variable2)));
        first = true;
        
        if get(findobj(gcf,'Tag','Cluster'),'value')==1
           cluster_view;
        end
        toc
    end
    
       function cluster_view(~,~)

       H = [{'H1'} {'H2'} {'H3'} {'H4'} {'H5'} {'H6'} {'H7'} {'H8'} {'H9'} {'H10'}];    
       
       Cluster_Window = figure('Name','Cluster','NumberTitle','off','Position',[10 30 1350 750],'Toolbar','none','Resize','off');
       
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [152 660 120 30],'HorizontalAlignment','left','String',VH(check(1)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 550 80 80],'HorizontalAlignment','left','String',VH(check(1)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);

       uicontrol('Parent',Cluster_Window,'Style','text','Position', [310 660 120 30],'HorizontalAlignment','left','String',VH(check(2)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 455 80 80],'HorizontalAlignment','left','String',VH(check(2)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
 
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [510 660 120 30],'HorizontalAlignment','left','String',VH(check(3)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 360 80 80],'HorizontalAlignment','left','String',VH(check(3)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);

       uicontrol('Parent',Cluster_Window,'Style','text','Position', [650 660 120 30],'HorizontalAlignment','left','String',VH(check(4)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 270 80 80],'HorizontalAlignment','left','String',VH(check(4)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
 
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [810 660 120 30],'HorizontalAlignment','left','String',VH(check(5)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 180 80 80],'HorizontalAlignment','left','String',VH(check(5)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
 
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [985 660 120 30],'HorizontalAlignment','left','String',VH(check(6)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 90 80 80],'HorizontalAlignment','left','String',VH(check(6)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
 
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [1140 660 120 30],'HorizontalAlignment','left','String',VH(check(7)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       uicontrol('Parent',Cluster_Window,'Style','text','Position', [15 -10 80 80],'HorizontalAlignment','left','String',VH(check(7)),'FontSize',8,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
      
       XPOS = [0.1 0.22 0.34 0.46 0.58 0.7 0.82];
       YPOS = [0.81 0.68 0.55 0.42 0.29 0.16 0.03];
       
       for i = 1:7
           
           for j = 1:7
               
               subplot('Position',[XPOS(i) YPOS(j) 0.1 0.1]);
               scatter(SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i)),SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(j)),1,'filled');
               axis([Min(check(i)) Max(check(i)) Min(check(j)) Max(check(j))]);
               
           end
       end
       
       clear H YPOS XPOS;
       
       end

    function Sel(~,~)
        dc_obj = datacursormode(SpikeAnalyseWindow);
        set(dc_obj,'DisplayStyle','datatip',...
           'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineT);
    end
    
    function [txt] = LineT (~,~)
        dc_obj = datacursormode(SpikeAnalyseWindow);
        c_inf = getCursorInfo(dc_obj);
        Spike1 = find(SPIKES3D(:,Elektrode,Variable1+1)==c_inf(1).Position(1)); 
        Spike2 = find(SPIKES3D(:,Elektrode,Variable2+1)==c_inf(1).Position(2));
        for i=1:size(Spike1,1)
            Spike = find(Spike1(i) == Spike2);
            if Spike > 0
                break;
            end
        end
        Spike = Spike2(Spike);
        txt = [{num2str(Spike)} {SPIKES3D(Spike,Elektrode,Variable1+1)} {SPIKES3D(Spike,Elektrode,Variable2+1)}];
        datacursormode off; 
    end
    
    function ShowSpike (~,~)
        if first == 1
            XX=[]; % Bereinigung der Arbeitsvariablen XX
            first = false;
        end
        size(XX,1);
        XX(size(XX,1)+1,:)=Shapes(Spike,Elektrode,:); 
        Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]); 
        Spikeplot = plot(ST,XX); 
        axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
        xlabel ('time / ms');
        ylabel({'Voltage / µV'});
    end
    
    function ShowClass (~,~)
        
        XX=[]; % Bereinigung der Arbeitsvariablen XX
        if size(Class,1)==0
           Class(1:size(nonzeros(SPIKES(:,Elektrode)),1),1)= zeros;
        end	
        XX(:,:)=Shapes((Class==Class(Spike)),Elektrode,:);
        Spikeplot = subplot('Position',[0.545 0.615 0.445 0.375]);  
        Spikeplot = plot(ST,XX); 
        axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
        xlabel ('time / ms');
        ylabel({'Voltage / µV'});
        
        XX=[]; % Damit ShowSpike problemlos funktioniert!
    end
    
     function K_Means_choice(~,~) % Auswahl K-Means Button
        
        Method = 0;
        k_mean([],[],Method);
    end
    
    function EM_choice(~,~) % Auswahl EM Button
        
        Method = 1;
        k_mean([],[],Method);
    end
    
    function k_mean(~,~,Method)

        tic
        
        if (get(findobj(gcf,'Tag','Variables'),'value')==1) || (get(findobj(gcf,'Tag','Histogram'),'value') == (get(findobj(gcf,'Tag','Variables'),'value')))
            
            if isnan(str2double(get(findobj(gcf,'Tag','Variables'),'String')))
               X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]);
               discrete = 0; % Auswahl_Variable
            else
                X(:,1:2)= SPIKES_Discrete(:,:);
                discrete = 1; % Auswahl_Variable
            end
        else
           discrete = 0; % Auswahl_Variable
           if count < 9 % falls mehrere Merkmale aktiviert sind
              count = 1;
              for i=1:size(check,2)
                  if check(i)~=1
                     X(:,count) = SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,check(i));
                     count = count +1;
                  end
              end
              count = 0;
           else
               X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]);
           end
        end
        
        XX_N(1:size(nonzeros(SPIKES(:,Elektrode)),1),1:size(X,2))=zeros;
        
        
        if discrete == 0;
           for i=1:size(X,2)
               XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i))); % Problem: Funktioniert nur dann, wenn beide Merkmale in etwa die selbe Dimension haben, ansonsten gibt es Probleme mit Epsilon
           end
        else
           XX_N = X;
        end
        
        X(:,1:2)=SPIKES3D(1:size(nonzeros(SPIKES(:,Elektrode)),1),Elektrode,[Variable1+1 Variable2+1]); % Muss nach der Erstellung von XX_N gemacht werden, damit Darstellung im Scatterplot wieder konsistent ist
        
        k=get(findobj(gcf,'Tag','K_Nr'),'String');
        k=str2double(k)
        if k== 0
           Y = pdist(XX_N,'mahalanobis'); 
           Z = linkage(Y,'weighted'); 
           Temp = cluster(Z,'cutoff',1.1); 
           k = max(Temp);
           clear Temp
           set(findobj(gcf,'Tag','K_Nr'),'String',k);
        end
        
        if Method == 0 
            [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),k,[],[],1,[]);
       
            [Class,~] = kmeans(XX_N,k,'start',M_EM','emptyaction','singleton');
            Probability(size(XX_N)) = 1;
            
          
           
               
        elseif Method == 1
            
            BIC_old = 0;
            for i = 1:k
                
                [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),i,[],[],1,[]);
                BIC = abs((-2*L_EM)+(2*i*log(size(XX_N,1)*size(XX_N,2))));
                if BIC < BIC_old %abs für das Vorzeichen siehe L_old
                   break;
                end
                BIC_old = abs(BIC);
            end
        
            obj = gmdistribution(M_EM',V_EM,W_EM');
            
            [Class,~,Probability]  = cluster(obj,XX_N);
        end
            scatterplot = subplot('Position',[0.545 0.06 0.445 0.41]); 
        
            for i=1:k
                scatter(X(Class==i,1),X(Class==i,2),18,'filled');
                hold on
            end
            axis([Min(Variable1+1) Max(Variable1+1) Min(Variable2+1) Max(Variable2+1)]);
            xlabel (char(units(Variable1)));
            ylabel(char(units(Variable2)));
            hold off
            toc
        end
    
    function Diskretize(~,~)
        
        SPIKES_temp(:,:) = SPIKES3D(:,Elektrode,[check(1) check(2)]);
        GRID_Resolution(1,1) = str2double(get(findobj(gcf,'Tag','Bin_Nr'),'String'));
        GRID_Resolution(1,2) = str2double(get(findobj(gcf,'Tag','Bin_Nr'),'String'));

        [N(1:GRID_Resolution(1,1),1:GRID_Resolution(1,2)),C]=hist3(SPIKES_temp,GRID_Resolution(1,:));

        C= cell2mat(C); %Conversion of returned cell C to matrix
        CC(1,:) = C(1,1:GRID_Resolution(1,1)); % rearrangement of C into different rows
        CC(2,:) = C(1,GRID_Resolution(1,1)+1:(2*GRID_Resolution(1,1))); 
        
        
        SPIKES_Discrete(1:sum(sum(N(:,1))),1) = CC(1,1); % Vorverarbeitung damit Schleife richtig durchlaufen kann!!
        SPIKES_Discrete(1:sum(sum(N(:,1))),2)= CC(2,1);
        for i=2:GRID_Resolution(1,1)
            if (sum(sum(N(:,1:i-1)))> 0)
               SPIKES_Discrete(sum(sum(N(:,1:i-1))):sum(sum((N(:,1:i)))),1) = CC(1,i);
            end
            if (sum(sum(N(1:i-1,:)))> 0)
               SPIKES_Discrete(sum(sum(N(1:i-1,:))):sum(sum((N(1:i,:)))),2) = CC(2,i);
            end

        end
     
        figure(27)
        pcolor((N(1:GRID_Resolution(1,1),1:GRID_Resolution(1,2),1)'));
        colormap(jet);
        
        clear GRID_Resolution SPIKES_temp C CC;
    end
   end

%----ENDE Spike Analyse---------------
%########################################################################

% -------------------- Detektion Refinement (RB)-------------------------------
   function Detektion_Refinement (~,~)
       
        Var = [{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'}]; 
                
         Var_var_ =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};
                    {'Right Spk. Angle(Neg./var.)'}];

       Var_neither =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    ];         
       
       Var_no_wave =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
                
        units = [{'Voltage / µV'};{'Voltage / µV'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
                {'Scalar'};{'Scalar'};{'Gradient µV / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
                {'Voltage / µV'};{'Time / ms'};{'Scalar'};{'Scalar'};];
                
%         if varTdata~=1
             V = Var;
%         else
%              V =  Var_var;
%         end
        
        data = 0;
        Feature_Nr = 2; % default value 
        Spike = 0;
        Elektrode=[];
        ST = 1; 
        Min(1:(size(SPIKES,1))) = zeros;
        Max(1:(size(SPIKES,1))) = zeros;
        XX=[];
        Class(1:size(SPIKES,1)) = zeros;
        check = [];
        cln = [];
        k = 2;
        pretime = 0.5;
        posttime = 0.5;
        SPIKES3D_discard = [];
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);

        %Main Window
        DetektionRefinementWindow = figure('Name','Detektion_Refinement','NumberTitle','off','Position',[45 100 1200 600],'Toolbar','none','Resize','off');
        
        
        %Main Window header
        uicontrol('Parent', DetektionRefinementWindow,'Style', 'text','Position', [180 460 250 20],'HorizontalAlignment','center','String','Identified Clusters','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent', DetektionRefinementWindow,'Style', 'text','Position', [800 460 250 20],'HorizontalAlignment','center','String','Refined Spikes','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent', DetektionRefinementWindow,'Style', 'text','Position', [800 235 250 20],'HorizontalAlignment','center','String','Detected Noise Events','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);

        %Button-Area
        RefinementPanel=uipanel('Parent',DetektionRefinementWindow,'Units','pixels','Position',[10 500 590 100],'BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'General:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       
        %Start Calculation
        uicontrol('Parent',RefinementPanel,'Position',[455 30 80 20],'String','Start','FontSize',11,'FontWeight','bold','callback',@Start_SR);
        
        %Submit data to Dr_Cell
        uicontrol('Parent',RefinementPanel,'Position',[415 5 160 20],'String','Submit to Dr.Cell','FontSize',11,'FontWeight','bold','callback',@Submit);
        
        %Electrode Selection
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[15 52 100 20],'HorizontalAlignment','left','String','Electrode: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[98 25 50 50],'Tag','Elektrodenauswahl','FontSize',8,'String',EL_NAMES,'Value',1,'Style','popupmenu','callback',@recalculate);

        %Selection of Number of Freatures used for Clustering
        %uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[15 13 100 20],'HorizontalAlignment','left','String', 'Feature Nr.: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        %uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[98 -15 50 50],'Tag','Feature_Nr','FontSize',8,'HorizontalAlignment','center','String',[2 3 4 5 6],'Value',1,'Style','popupmenu','callback',@recalculate);
       
        %Apply Expectation Maximation Algorithm
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[15 23 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','EM_GM','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[40 25 150 14],'HorizontalAlignment','left','String','Expectation Maximation','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        %Apply EM k-means Algorithm
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[15 4 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','EM_k-means','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[40 6 150 14],'HorizontalAlignment','left','String','EM k-means','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        %FPCA Features
        uicontrol ('Parent',RefinementPanel,'Units','Pixels','Position',[190 61 20 15],'HorizontalAlignment','left','FontSize',8,'Tag','FPCA','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style','text','Position',[215 63 150 14],'HorizontalAlignment','left','String','FPCA Features','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        %Wavelets on/off
        uicontrol ('Parent',RefinementPanel,'Units','Pixels','Position',[190 42 20 15],'HorizontalAlignment','left','FontSize',8,'Tag','Wavelet','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[215 44 150 14],'HorizontalAlignment','left','String','Wavelet Packet Analysis','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        %Manual or automatic Features
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[190 23 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','manual','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[215 25 150 14],'HorizontalAlignment','left','String','Manual Features','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
        
        % Shapes Window Dimension
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [392 55 80 20],'HorizontalAlignment','left','String', 'Spike Time: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[472 48 50 30],'Tag','SR_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','callback',@recalculate);
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[527 48 50 30],'Tag','SR_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','callback',@recalculate);
        
        %Refine discarded Events
        uicontrol('Parent',RefinementPanel,'Units','Pixels','Position',[190 4 20 20],'HorizontalAlignment','left','FontSize',10,'Tag','discard','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',RefinementPanel,'Style', 'text','Position',[215 6 150 14],'HorizontalAlignment','left','String','Refine discarded Signals','FontSize',8,'BackgroundColor',[0.8 0.8 0.8]);
       
        %Feature-Area
        FeaturePanel=uipanel('Parent',DetektionRefinementWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor',[0.8 0.8 0.8],'Tag','FeaturePanel','Visible','on');
        uicontrol('Parent',FeaturePanel,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
       
        FeaturePanel2=uipanel('Parent',DetektionRefinementWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor',[0.8 0.8 0.8],'Tag','FeaturePanel2','Visible','off');
        uicontrol('Parent',FeaturePanel2,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
        uicontrol('Parent',FeaturePanel2,'Style', 'text','Position', [200 10 200 50],'HorizontalAlignment','left','String', 'FPCA Features','FontSize',18,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                
        %Automated Feature Selection 
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [15 50 150 20],'HorizontalAlignment','left','Tag','F1','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units', 'Pixels','Position', [15 15 150 20],'HorizontalAlignment','left','Tag','F2','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [190 50 150 20],'HorizontalAlignment','left','Tag','F3','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
       
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [190 15 150 20],'HorizontalAlignment','left','Tag','F4','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
        
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [365 50 150 20],'HorizontalAlignment','left','Tag','F5','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');
       
        uicontrol('Parent',FeaturePanel,'Units','Pixels','Position', [365 15 150 20],'HorizontalAlignment','left','Tag','F6','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

        %Shapes Graph of Refined Spikes
        Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28]);
        axis([0 2 -100 50]);
        
        %Shapes Graph of Filtered Events
        Filtered = subplot('Position',[0.55 0.09 0.44 0.28]);
        axis([0 2 -100 50]);
        
        
        %Scatterplot
        scatterplot = subplot('Position',[0.05 0.09 0.44 0.66]);  
        
        function Start_SR (~,~)
             
            tic
            w = waitbar(.1,'Please wait - Spikes Refinment in progress...');
            F = [{'F1'} {'F2'} {'F3'} {'F4'} {'F5'} {'F6'}];
            
            SPIKES3D_temp = [];
            Shapes_temp = [];
            Class(:,:) = [];
            Sorting = 0; % Variable to discriminate between calls from Sorting and Refinement tool
            
            if get(findobj('Tag','manual'),'value') == 1
               for i = 1:6
                   if get(findobj('Tag',char(F(i))),'value') ~=1 
                      check(i) = get(findobj('Tag',char(F(i))),'value');
                   else
                      check(i) = 0;
                   end
               end
               check = nonzeros(check);
               check = check';
            end
         
            Elektrode = get(findobj('Tag','Elektrodenauswahl','parent',RefinementPanel),'value');
            
            Shapes=[]; 
            XX=[];
            
            pretime = preti(get(findobj('Tag','SR_pretime'),'value'));
            posttime = postti(get(findobj('Tag','SR_posttime'),'value'));
            
            if get(findobj('Tag','discard'),'value') == 1 &&  size(SPIKES3D_discard,1) ~= 0
               Shapes(1:size(SPIKES3D_discard,1),1:size(SPIKES3D_discard,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
               
            else
               Shapes(1:size(SPIKES,1),1:size(SPIKES,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
            end
            
            Shape(pretime,posttime);
            waitbar(.15,w,'Please wait - Features being calculated...')
            if data == false %Überprüfung ob Daten schon berechnet wurden
               
                
%                 if varTdata~=1 % selection of right set of Feature Strings
                   if get(findobj('Tag','Wavelet'),'value')==1
                      V = Var;
                   else
                       V = Var_neither;
                   end
%                 else
%                     if get(findobj('Tag','Wavelet'),'value')==1
%                        V =  Var_var;
%                     else
%                        V = Var_no_wave;
%                     end
%                 end
                
                calculate(V,pretime,posttime); %claculate basic Features (Amplitude, NEO, PCA, Spike Angles, Min-Max-Ratio, Spike Duration) 
                calculate_area; %calculate Areas of Spikes
            end
            
            if SubmitRefinement ~= 0 || size(nonzeros(SPIKES3D(:,Elektrode,14)),1) == 0
                calculate_PCA; %calculate principal components
                waitbar(.3,w,'Please wait - Wavelet Features being calculated...')
                if get(findobj('Tag','Wavelet'),'value')==1
                   calculate_Wave_Coeff; %calculate Wavelet Coefficients (Energy and Variance Criteria)
                end
                SubmitRefinement = 0;
            end
            
            if get(findobj('Tag','FPCA'),'value')== 0
               set(findobj('Tag','FeaturePanel'),'Visible','on');
               set(findobj('Tag','FeaturePanel2'),'Visible','off');
            else
               set(findobj('Tag','FeaturePanel'),'Visible','off');
               set(findobj('Tag','FeaturePanel2'),'Visible','on');
            end
            
            waitbar(.6,w,'Please wait - Clustering...')
            Class = Clusterfunction;
            waitbar(.9,w,'Please wait - Clustering complete')
            %Shapes Graph
            ST = (-pretime:1000/SaRa:posttime);
            MAX1D = max(Shapes(:,Elektrode,:));
            Max(1) = max(MAX1D);
            MIN1D = min(Shapes(:,Elektrode,:));
            Min(1) = min(MIN1D);
         
            if get(findobj('Tag','FPCA'),'value') == 0
               if get(findobj('Tag','discard'),'value') == 1 &&  size(SPIKES3D_discard,1) ~= 0
                  SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
               else
                  SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
               end
            else
               SPIKES3D_temp(:,1,:) = SPIKES_FPCA;
            end
            
            Shapes_temp = Shapes(:,Elektrode,:);
            
            for i=2:(size(SPIKES3D_temp,3))
                
                MIN1D = min(nonzeros(SPIKES3D_temp(:,1,i))); 
                MAX1D = max(nonzeros(SPIKES3D_temp(:,1,i)));
                if size(MIN1D) ~= 0
                    Min(i) = min(MIN1D);
                else
                    Min(i)=0;
                end
                if size(MAX1D) ~= 0
                    Max(i) = max(MAX1D);
                else
                    Max(i)=0;
                end
            end
            clear MAX1D MIN1D;
            
            XX1=[];
            XX2=[];
            
            %Plot Refined Spikes and Noise Events
            XX1(:,:) = Shapes_temp(Class~=1,1,:); %Shapes muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!
            XX2(:,:) = Shapes_temp(Class==1,1,:); 
            %Spike_Cluster = (mean(min(XX1,[],2))<= (mean(min(XX2,[],2))));
            Spike_Cluster =mean(SPIKES3D_temp(Class~=1,1,2))<= mean(SPIKES3D_temp(Class==1,1,2));
            
            uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [100 75 130 18],'HorizontalAlignment','left','String','Original Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor',[0.8 0.8 0.8]); 
            uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [210 75 50 18],'HorizontalAlignment','left','String',size(nonzeros(SPIKES3D_temp(:,1,1))),'FontSize',10,'FontWeight','bold','ForegroundColor','r','BackgroundColor',[0.8 0.8 0.8]);
            waitbar(1,w,'Done');
            close(w); 
           
           if size(XX1,1)== 0 
               
              Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow); 
              Spikeplot = plot(ST,XX2); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              ylabel({'Voltage / µV'});
              
              Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              ylabel({'Voltage / µV'});
              
           elseif size(XX2,1)== 0 
               
              Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow); 
              Spikeplot = plot(ST,XX1); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              ylabel({'Voltage / µV'});
              
              Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              ylabel({'Voltage / µV'});
              
            
           elseif Spike_Cluster == 1
               
              Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow); 
              Spikeplot = plot(ST,XX1); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              ylabel({'Voltage / µV'});

              subplot('Position',[0.55 0.09 0.44 0.28],'parent',DetektionRefinementWindow);
              Spikeplot = plot(ST,XX2); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              xlabel ('time / ms');
              ylabel({'Voltage / µV'});

              uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [290 75 130 20],'HorizontalAlignment','left','String','Refined Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor',[0.8 0.8 0.8]); 
              uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [395 75 50 20],'HorizontalAlignment','left','String',size(XX1,1),'FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor',[0.8 0.8 0.8]);


              XX1=[];
              XX2=[];

           elseif Spike_Cluster == 0

              Spikeplot = subplot('Position',[0.55 0.47 0.44 0.28],'parent',DetektionRefinementWindow); 
              Spikeplot = plot(ST,XX2); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              ylabel({'Voltage / µV'});

              subplot('Position',[0.55 0.09 0.44 0.28],'parent',DetektionRefinementWindow);
              Spikeplot = plot(ST,XX1); 
              axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
              xlabel ('time / ms');
              ylabel({'Voltage / µV'});
              
              uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [290 75 130 20],'HorizontalAlignment','left','String','Refined Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor',[0.8 0.8 0.8]); 
              uicontrol('Parent',RefinementPanel,'Style', 'text','Position', [395 75 50 20],'HorizontalAlignment','left','String',size(XX2,1),'FontSize',10,'FontWeight','bold','ForegroundColor','b','BackgroundColor',[0.8 0.8 0.8]);

              XX1=[];
              XX2=[];

           else
              Spikeplot = plot(zeros);
              XX1=[];
              XX2=[];
           end
           
           %Scatterplot 
           X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1)),1),1,[(check(1)) (check(2))]); 
            
           scatterplot = subplot('Position',[0.05 0.09 0.44 0.66],'parent',DetektionRefinementWindow); 
           for i=1:max(Class)
               scatter(X(Class==i,1),X(Class==i,2),18,'filled');
               hold on
           end
            
           axis([Min(check(1)) Max(check(1)) Min(check(2)) Max(check(2))]); % richtig so, da +1 und -1 durch Max(i) und F(i) sich aufheben
           if get(findobj('Tag','FPCA'),'value') == 0 
              axis(gca,[Min(check(1)) Max(check(1)) Min(check(2)) Max(check(2))]); % richtig so, da +1 und -1 durch Max(i) und F(i) sich aufheben
              xlabel (gca,char(units(check(1)-1)));
              ylabel(gca,char(units(check(2)-1)));
           else
              axis(gca,[min(SPIKES3D_temp(:,1)) max(SPIKES3D_temp(:,1)) min(SPIKES3D_temp(:,2)) max(SPIKES3D_temp(:,2))]); 
              xlabel (gca,'Scalar');
              ylabel(gca,'Scalar');
           end
           
           hold off
           toc
        end
        
    end

%----ENDE Detektion Refinement---------------
%########################################################################

% -------------------- recalculate (RB)-------------------------------
    function recalculate(~,~) % set data to false if Window is (re-)opened
        SPIKES3D_discard = [];
        data = false;
        cln = [];
        Sorting = 0;
        Elektrode = get(findobj(gcf,'Tag','Elektrodenauswahl'),'value');
        SubmitSorting(Elektrode) = 0;
        Shapes = [];
        if isnan(get(findobj('Tag','Sort_pretime'),'value')) == 0
           set(findobj('Tag','S_pretime'),'value',get(findobj('Tag','Sort_pretime'),'value'));
           set(findobj('Tag','S_posttime'),'value',get(findobj('Tag','Sort_posttime'),'value'));
        else
           Window = 0;
        end
    end

%----ENDE recalculate---------------
%########################################################################

% -------------------- Shape (RB)-------------------------------

   function Shape(pretime,posttime,~)
       
       SPI = [];
       SPI1 =[];

       n = Elektrode; %if only 1 Elektrode is calculated ( falls for Schleife für alle Elektroden mit Variable n wieder eingeführt wird)
       
      if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
         discard = 0;
      else
         discard = get(findobj('Tag','discard'),'value');
      end   

       if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
          SPI(:,n) = SPIKES3D_discard(:,1,1)*SaRa;
          if SubmitSorting(Elektrode) >= 1
             M_temp(:,n) = M_old;
          else
             M_temp(:,n) = M(:,n);
          end
       else
          SPI =SPIKES*SaRa;
          M_temp(:,n) = M(:,n);
       end

       SPI1=nonzeros(SPI(:,n));

       for i=1:size(SPI1,1)
           if ((SPI1(i)+1+floor(SaRa*posttime/1000))>size(M_temp,1))||((SPI1(i)+1-ceil(SaRa*pretime/1000)) <=0) % Anpassung da Spikelänge insgesamt 2*0.5 msec!!!
              S_orig(i,n,1:1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))= zeros;
           else
              S_orig(i,n,:)=M_temp(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n); % Shapes variabler Länge
              S_old = S_orig;
              Shapes(i,n,:) = S_orig(i,n,:);
           end
       end
   end

%----ENDE Shape---------------
%########################################################################

% -------------------- Calculate (RB)-------------------------------
       
   function calculate(V,pretime,posttime,~) %Amplitude, Neo, Shapes

    %     SPIKES3D:      % Blatt 1: Timestamp des Spikes; Blatt 2: Negative Amplitude des Spikes;
                         % Blatt 3: Positive Amplitude des Spikes; Blatt 4: Ergebnis des NEO des Spikes;
                         % Blatt 5: Negative Signalenergie des Spikes; % Blatt 6: Positive Signalenergie des Spikes;
                         % Blatt 7: Spikedauer; Blatt 8: Öffnungswinkel nach links; 
                         % Blatt 9: Öffnungswinkel nach rechts; Blatt 10: 1. Hauptkomponente; 
                         % Blatt 11: 2. Hauptkomponente;  Blatt 12: 3.Hauptkomponente
                         % Blatt 13: 3.Hauptkomponente Blatt 
                         % Blatt 14-16: Wavelet Coefficients (höchste Varianz); Blatt 17-19: Wavelet Coefficients (höchste Energy-Varianz);
                         % Blatt 20: varAmplitude; Blatt 21: varSpikedauer; 
                         % Blatt 22: varÖffnungswinkel nach links; Blatt 23: varÖffnungswinkel nach rechts;
        
        Shapesvar = [];
        SPIKES3D=SPIKES;
        SPI =SPIKES3D(:,:,1)*SaRa;
        SPIKES3D(:,size(SPIKES,2),2:size(V,1))=zeros; 
        n = Elektrode; %if only 1 Elektrode is calculated ( falls for Schleife für alle Elektroden mit Variable n wieder eingeführt wird)
        Neo(1:size(M,1),size(M,2))=zeros;

        for m=1:size(M,2)
            for i=2:1:(size(M,1)-1)
                Neo(i,m)= M(i,m)^2-(M(i-1,m)*M(i+1,m));
            end
        end

        SPI1=nonzeros(SPI(:,n));

        for i=1:size(SPI1,1)
            if ((SPI1(i)+1+floor(SaRa*posttime/1000))<=size(M,1))&&((SPI1(i)+1-ceil(SaRa*pretime/1000)) >0)

                Neo_Shapes(i,n,:)=Neo(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n); 
                
                %Amplitude: bei variablem Threshold offset
                %berücksichtigen
                if varTdata~=1
                    SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2))); %modifieziert um nicht überlagerte Spikes zu verwechseln
                else
                 clear temp_datal temp_datar temp_pl temp_pr
                 Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes der Länge 2ms  
                 Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
                 Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
                    SPIKES3D(i,n,2)=(Shapesvar(i,n,SaRa/1000+1)); 
                end
                % Ende Amplitudenberechnung
                
                SPIKES3D(i,n,2)=(Shapes(i,n,ceil((size(Shapes,3))/2))); %modifieziert um nicht überlagerte Spikes zu verwechseln
                SPIKES3D(i,n,3)=max(Shapes(i,n,ceil(0.25*SaRa/1000):(size(Shapes,3)-ceil(0.25*SaRa/1000)))); % modifizierter Bereich um nicht überlagerte Spikes zu verwechseln!
                SPIKES3D(i,n,4)=(Neo_Shapes(i,n,ceil((size(Shapes,3))/2))); %modifieziert um nicht überlagerte Spikes zu verwechseln
                [C(1),I(1)]= max(Shapes(i,n,1:ceil((size(Shapes,3))/2)));
                [C(2),I(2)]= max(Shapes(i,n,floor(0.25*SaRa/1000):size(Shapes,3)-ceil(0.25*SaRa/1000)));

                templeft = [];
                tempright = [];

                % Berechnung des Öffnungswinkels (Andy)/(Robert)

                % Punkte finden, an denen 50% überschritten wurden
                % 1. nach "links"
                %figure(100+i)
                %X_temp(:,:)= Shapes(i,n,:);
                %plot(X_temp)
                for j = ceil((size(Shapes,3))/2):-1:1
                    if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                       templeft =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % Steigung von Min zu 50% von Min
                       SPIKES3D(i,n,8) = atand(templeft); % Umrechnung in Grad
                       templeft = j/SaRa*1000; %umspeicherung des Indexes;
                       break
                    end
                end
                % 2. nach "rechts"
                for j = ceil((size(Shapes,3))/2):1:size(Shapes,3)
                    if Shapes(i,n,j)>=(0.5*Shapes(i,n,ceil((size(Shapes,3))/2)))
                       tempright =  abs((Shapes(i,n,j)-Shapes(i,n,ceil((size(Shapes,3))/2)))/(j-ceil((size(Shapes,3))/2))); % Steigung von Min zu 50% von Min
                       SPIKES3D(i,n,9) = atand(tempright); % Umrechnung in Grad
                       tempright = j/SaRa*1000;
                       break
                    end
                end
                if size(templeft) == 0
                   templeft = tand(89);
                   SPIKES3D(i,n,8) = 90; 
                end
                if size(tempright) == 0
                   tempright = tand(89);
                   SPIKES3D(i,n,9) = 90;
                end

                % Spikedauer (interpolation der Winkel auf y = 0)
                % SPIKES3D(i,n,7)=((0-Shapes(i,n,SaRa/1000+1))/templeft)+((0-Shapes(i,n,SaRa/1000+1))/SPIKES3D(i,n,8)); 

                SPIKES3D(i,n,7) = tempright-templeft;

            % Wurden die Spikes über den variablen Threshold ermittelt,
            % stehen noch weitere Parameter zu Verfügung:
%                 if varTdata==1
%                     clear temp_datal temp_datar temp_pl temp_pr;
%                     Shapesvar(i,n,:)=varT(SPI1(i)+1-SaRa*pretime/1000:SPI1(i)+1+SaRa*posttime/1000,n); % Shapes der Länge 2ms  
%                     Shapesvar(i,n,:)=Shapesvar(i,n,:)-varoffset(1,n);
%                     Shapesvar(i,n,:)=Shapes(i,n,:)-Shapesvar(i,n,:);
% 
%                                     if Shapesvar(i,n,SaRa/1000+1)< 0 
%                                     j=0;
%                                     while Shapesvar(i,n,SaRa/1000+1-j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1-j)>1;  % 50% des Amplitudenwertes
% 
%                                         temp_datal(j+1,1)=-1000*j*(1/SaRa);
%                                         temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
%                                      j=j+1;  %nach "links"
%                                     end
%                                         temp_datal(j+1,1)=-1000*j*(1/SaRa);
%                                         temp_datal(j+1,2)=Shapesvar(i,n,SaRa/1000+1-j);
% 
%                                    % 2. nach "rechts"
% 
%                                     j=0;
%                                     while Shapesvar(i,n,SaRa/1000+1+j) <= 0.5*(Shapesvar(i,n,SaRa/1000+1)) && (SaRa/1000+1+j)<(size(Shapesvar,3)-1);  % 50% des Amplitudenwertes
% 
%                                         temp_datar(j+1,1)=1000*j*(1/SaRa);
%                                         temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
%                                         j=j+1;  %nach "rechts"
%                                     end               
%                                         temp_datar(j+1,1)=1000*j*(1/SaRa);
%                                         temp_datar(j+1,2)=Shapesvar(i,n,SaRa/1000+1+j);
% 
%                                         % Gerade aus Punkten ermitteln; wann schneidet diese
%                                         % die y-Achse
% 
%                                         temp_pl = polyfit(temp_datal(:,1),temp_datal(:,2),1);
%                                         temp_pr = polyfit(temp_datar(:,1),temp_datar(:,2),1);
% 
%                                             % varAmplitude in 12
%                                             SPIKES3D(i,n,20)=(Shapesvar(i,n,SaRa/1000+1));    
% 
%                                             % varSpikedauer in 13                   
%                                             SPIKES3D(i,n,21)= roots(temp_pl)*(-1) + roots(temp_pr);
% 
%                                             % varÖffnungswinkel nach links in 14
%                                             SPIKES3D(i,n,22)=atan((roots(temp_pl)*(-1))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
% 
%                                             % varÖffnungswinkel nach rechts in 15
%                                             SPIKES3D(i,n,23)=atan((roots(temp_pr))/(Shapesvar(i,n,SaRa/1000+1)*(-1)));
%                                     end    
%                 end
                SPIKES3D(SPIKES3D(:,n,8)== 90,n,8) = mean(SPIKES3D(SPIKES3D(:,n,8)~= 90,n,8));
                SPIKES3D(SPIKES3D(:,n,9)== 90,n,9) = mean(SPIKES3D(SPIKES3D(:,n,9)~= 90,n,9));
                SPIKES3D(SPIKES3D(:,n,7)== 0,n,7) = mean(SPIKES3D(SPIKES3D(:,n,7)~= 0,n,7));
                clear temp_datal temp_datar temp_pl temp_pr templeft tempright;
            end            
        end
   end
    
%----ENDE calculate---------------
%########################################################################

% -------------------- calculate_PCA (RB)-------------------------------

    function calculate_PCA(~,~) %calculate principal components
        
        n = Elektrode;
        XX(1:size(Shapes,1),1:size(Shapes,3))=Shapes(:,n,:); %Shapes muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!
        [~,Score]=princomp(XX);
        
        if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
           discard = 0;
        else
           discard = get(findobj('Tag','discard'),'value');
        end   

        if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1 % calculation an recalculation of PCA
           SPIKES3D_discard(:,n,10:13)=Score(:,1:4); %HK 1:4      
        else
           SPIKES3D(:,n,10:13)=Score(:,1:4); %HK 1:4
        end
        
        clear Score I; 
    end

%----ENDE calculate_PCA---------------
%########################################################################

% -------------------- calculate_area (RB)-------------------------------

    function calculate_area(~,~) %positive und negative Flächen berechnen
        k=1;
        Temp=0;
        clear MU S i n ZPOS ZNEG POS NEG;
        MU(1:size(Shapes,1),1:size(Shapes,2),1:size(Shapes,3))=zeros;
        n = Elektrode; %if only 1 Elektrode is calculated ( falls for Schleife für alle Elektroden mit Variable n wieder eingeführt wird)

        for i=1:size(Shapes,1)%Vorzeichenwechsel in Shapes bestimmen
            for j=1:size(Shapes,3)%alle Spike Werte durchlaufen
                if Shapes(i,n,j)~=0
                    if sign(Shapes(i,n,j))~= sign(Temp(1,1))  
                        if Temp~=0
                            MU(i,n,k)=j-1;
                            k=k+1;
                        else
                        end
                        Temp=Shapes(i,n,j);
                    else
                    end
                else 
                end
            end
            Temp=0;
            k=1;
        end
        i=1;

        for i=1:size(Shapes,1)
            for j=1:size(Shapes,3)
                S(i,n,j)=sign(Shapes(i,n,j))*(Shapes(i,n,j))^2;
            end
        end

         POS=0;  %Benötigt um zu testen, ob ZPOS bzw. ZNEG schon beschrieben wurden
         NEG=0;
         ZPOS(1:size(MU,3),1:size(MU,1))=zeros;
         ZNEG(1:size(MU,3),1:size(MU,1))=zeros;
         for i=1:size(S,1) %POS und NEG Flächen einzeln berechnen
            for j=1:size(MU,3)
                if (MU(i,n,j)<= 0) && (j>1) %Da MU immer mit Nullen aufgefüllt wird muss so geprüft werden
                    TMP=((1/SaRa)*(trapz(S(i,n,MU(i,n,j-1)+1:size(S,3)))));  
                    if(TMP>=0)
                        if(POS~=0)
                            POS=POS+1;
                            ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                        else
                            POS=1;
                            ZPOS(POS,i)=TMP; 
                        end
                        break
                    else
                        if(NEG~=0)
                            NEG=NEG+1;
                            ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                        else
                            NEG=1;
                            ZNEG(NEG,i)=TMP;
                        end
                    end
                    break
                elseif(MU(i,n,j)<=0) && (j<=1) %Fall dass gar kein Vorzeichenwechsel erfolgt
                    TMP=(1/SaRa)*((trapz(S(i,n,1:size(S,3)))));
                    if(TMP>=0)
                        POS=1;
                        ZPOS(POS,i)=TMP; 
                    else
                        NEG=1;
                        ZNEG(NEG,i)=TMP;
                    end
                    break
                else
                    if j==1
                        TMP=(1/SaRa)*((trapz(S(i,n,1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))); % die Zwischenfläche beim Vorzeichenwechsel!  
                        if(TMP>=0)
                            if(POS~=0)
                                POS=POS+1;
                                ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                            else
                                POS=1;
                                ZPOS(POS,i)=TMP;   
                            end
                        else
                            if(NEG~=0)
                                NEG=NEG+1;
                                ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                        end
                    elseif j>=size(MU,3)  
                        TMP=(1/SaRa)*(trapz(S(i,n,MU(i,n,j)+1:size(S,3)))); %Restfläche des Graphen(SpikeShape mit den meisten Vorzeichenwechseln) (Muss gemacht werden da die Anzahl der Flächen immer um 1 größer ist als die Anzahl der Vorzeichenwechsel!    
                        if(TMP>=0)
                            if(POS~=0)
                                POS=POS+1;
                                ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                            else
                                POS=1;
                                ZPOS(POS,i)=TMP;   
                            end
                        else
                            if(NEG~=0)
                                NEG=NEG+1;
                                ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                        end
                    else
                        TMP=(1/SaRa)*((trapz(S(i,n,MU(i,n,j-1)+1:MU(i,n,j))))+(0.5*(-S(i,n,MU(i,n,j))/(S(i,n,MU(i,n,j)+1)-S(i,n,MU(i,n,j))))*S(i,n,MU(i,n,j)))+(0.5*(1-(-S(i,n,MU(i,n,j-1))/(S(i,n,MU(i,n,j-1)+1)-S(i,n,MU(i,n,j-1)))))*S(i,n,MU(i,n,j-1)+1))); 
                        if(TMP>=0)
                            if(POS~=0)
                                POS=POS+1;
                                ZPOS(POS,i)=ZPOS(POS-1,i)+TMP;
                            else
                                POS=1;
                                ZPOS(POS,i)=TMP;   
                            end
                        else
                            if(NEG~=0)
                                NEG=NEG+1;
                                ZNEG(NEG,i)=ZNEG(NEG-1,i)+TMP;
                            else
                                NEG=1;
                                ZNEG(NEG,i)=TMP;
                            end
                        end
                    end
                end
            end
            POS=0;
            NEG=0;
         end
            if size(ZPOS,1)~=i
               ZPOS(1,i)=0;
            end
            if size(ZNEG,1)~=i
               ZNEG(1,i)=0;
            end

            for i=1:size(Shapes,1) % Ergebnis der Flächenberechnung für jeden Spike der Elektrode
               SPIKES3D(i,n,6)=max(ZPOS(:,i));
               SPIKES3D(i,n,5)=min(ZNEG(:,i));
            end
            i=1;
            data= true;
    end

%----ENDE calculate_area---------------
%########################################################################

% -------------------- calculate_Wave_Coeff (RB)-------------------------------


 function calculate_Wave_Coeff(~,~)

   Coeff =[];
   Entropy = [];
   MX = [];
   SPIKES3D_t = [];
   n = Elektrode; %if only 1 Elektrode is calculated ( falls for Schleife für alle Elektroden mit Variable n wieder eingeführt wird)
   
   if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
      discard = 0;
   else
      discard = get(findobj('Tag','discard'),'value');
   end   
   
   if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1 
      SPIKES3D_t(:,1,1:6) = SPIKES3D_discard(:,n,13:18);
   else
      SPIKES3D_t(:,1,1:6) = SPIKES3D(:,n,13:18);
   end
   
   for Nr=1:1

      if Nr==1   
       for i=1:1:size(nonzeros(Shapes(:,n,1)),1)

           MX(:,:)=(Shapes(i,n,:));
           TREE1 = wpdec(MX,3,'db1');
           Coeff(i,:)=read(TREE1,'data');
           Entropy(1:size(Coeff,1),15)=zeros; % 15 because of 15 nodes in the wavelet packet tree
           Entropy(i,:) = read(TREE1,'ent');
           if isnan(Entropy(i))==1
              Entropy(i)=0;
           end
           
       end
      else
       for i=1:1:size(nonzeros(Shapes(:,n,1)),1)

          Coeff(i,I1)=zeros; % delete found Coefficients from Signal and repeat WPT
          TREE = write(TREE1,'data',Coeff(i,:));
          MX(:,:)=wprec(TREE);     
          TREE = wpdec(MX,3,'db1');
          Coeff(i,:)=read(TREE,'data');
          Entropy(i,:) = read(TREE,'ent');
          if isnan(Entropy(i,:))
              Entropy(i,:)=0;
          end
           
       end
      end

       for i=1:size(Coeff,2)
           
           if i<= size(Entropy,2) % Entropy node feature extraction
              Entropy_Norm(:,i) = (Entropy(1:size(Entropy(:,1),1),i)-min(Entropy(1:size(Entropy(:,1),1),i)))/(max(Entropy(1:size(Entropy(:,1),1),i))-min(Entropy(1:size(Entropy(:,1),1),i)));
              if min(Entropy_Norm(:,i))~=0
                 Entropy_Norm(:,i) = Entropy_Norm(:,i)*(-1);
              end
           
              if isnan(Entropy_Norm(:,i)) % if all Coeffs are 0 Coeff_Norm becomes NaN, therefore correction term is needed
                 Entropy_Norm(:,i) = zeros;
                 Entropy(:,i) = zeros; % just in case that already Entropy itself is problematic
              end 
           
             [y_E,z] = hist(Entropy_Norm(:,i),100); % histogramm plot

             y_E = y_E-min(y_E); % Norm the plots in x and y
             z = z-min(z);
             y_E = y_E/max(y_E);
             z = z/max(z);

             for nn=1:10 %smoothing iterations
                 y_E = smooth(y_E);    % plot smoothing  
             end
             [~,I_E(1)]=max(y_E);              % 1. Extremum globales Maximum der Verteilung!!
             k=2;
           
             %figure(10+i) %Test der Verteilungen
             %plot(z,y_E);
             
             ERG_E = 0;
             for j=1:size(y_E)-1
                 dy_E(j,1)= (y_E(j+1,1)-y_E(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
                 if j>1
                    if (dy_E(j,1)<0 && dy_E(j-1,1)>=0)
                        if j~=I_E(1)
                           I_E(k) = j;  % X-Komponente von Maximum über Steigung bestimmt  
                           k = k+1;
                        end
                    end
                 end
             end
             Mean1_E = I_E./100;
             k = k-1;
             for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                 [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Entropy_Norm(:,i),k,[],[],1,Mean1_E);
                 if ~isnan(L_EM)
                    break
                 end
             end
             Mean1_E = [];
             Mean1_E_new = [];
             I_E_new=[];
             ERG_E = [];
             I_E=[];
             y_E = [];
           
             if min(min(min(V_EM)))~= 0 && min(W_EM) ~= 0;

                ob = gmdistribution(M_EM',V_EM,W_EM');
                Gauss = pdf(ob,z');
                Gauss = Gauss/max(Gauss); % normalize for better comparing

                [~,I_E_new(1)]=max(Gauss);
                k_new = 1;

                for j=1:size(Gauss)-1
                    dGauss(j,1)= (Gauss(j+1,1)-Gauss(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
                    if j>1
                       if (dGauss(j,1)<0 && dGauss(j-1,1)>=0)
                          if j~=I_E_new(1)
                             I_E_new(k_new+1) = j;  % X-Komponente von Maximum über Steigung bestimmt  
                             k_new = k_new+1;
                          end
                       end
                    end
                end
                Mean1_E_new = [];
                Mean1_E_new = I_E_new./100;
                k_new = size(Mean1_E_new,2);

                if k_new ~= k;
                   for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                     k = k_new;
                     Mean1_E = [];
                     Mean1_E = Mean1_E_new;
                     [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Entropy_Norm(:,i),k,[],[],1,Mean1_E);
                     if ~isnan(L_EM)
                        break
                     end
                   end
                end

                if isnan(M_EM(1))
                   M_EM(1) = 1e-10; % if EM fails and is nan change to low value in order to continue process but exclude feature
                end

                for j = 1:k_new

                    if j == 1
                       ERG_E(j) = abs((1/V_EM(1,1,j)) / Gauss(ceil(M_EM(1)*100)));
                    elseif abs(L_EM) > 1e5
                       ERG_E(j) = 1e9;
                    else
                       if M_EM(1) < M_EM(j)
                          Min = min(Gauss(ceil(M_EM(1)*100):ceil(M_EM(j)*100)));
                       else
                          Min = min(Gauss(ceil(M_EM(j)*100):ceil(M_EM(1)*100)));
                       end
                       ERG_E(j) = abs(sum(V_EM(1,1,:)) / (M_EM(1)-M_EM(j)) / W_EM(j) * exp(Min));
                    end
                end
                RES_E(i) = min(ERG_E);

                %figure(10+i) %plot Gaussian approximation 
                %hold all;
             	%plot(z,Gauss)
             else
                RES_E(i) = 1e9;
             end
             Max_Nr(i) = size(ERG_E,2)+1;
 
           end

           Coeff_Norm(:,i) = (Coeff(1:size(Coeff(:,1),1),i)-min(Coeff(1:size(Coeff(:,1),1),i)))/(max(Coeff(1:size(Coeff(:,1),1),i))-min(Coeff(1:size(Coeff(:,1),1),i)));
           if min(Coeff_Norm(:,i))~=0
              Coeff_Norm(:,i) = Coeff_Norm(:,i)*(-1);
           end
           
           if isnan(Coeff_Norm(:,i)) % if all Coeffs are 0 Coeff_Norm becomes NaN, therefore correction term is needed
              Coeff_Norm(:,i) = zeros;
           end
           
           [y,z] = hist(Coeff_Norm(:,i),100); % histogramm plot

           y = y-min(y); % Norm the plots in x and y
           z = z-min(z);
           y = y/max(y);
           z = z/max(z);

           for nn=1:10 %smoothing iterations
               y = smooth(y);    % plot smoothing  
           end
           [~,I(1)]=max(y);              % 1. Extremum globales Maximum der Verteilung!!
           k=2;
           
           %figure(10+i) %Test der Verteilungen
           %plot(z,y);
           ERG = 0;
           for j=1:size(y)-1
               dy(j,1)= (y(j+1,1)-y(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
               if j>1
                  if (dy(j,1)<0 && dy(j-1,1)>=0)
                      if j~=I(1)
                         I(k) = j;  % X-Komponente von Maximum über Steigung bestimmt  
                         k = k+1;
                      end
                  end
               end
           end
           Mean1 = I./100;
           k = k-1;
           for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
               [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Coeff_Norm(:,i),k,[],[],1,Mean1);
               if ~isnan(L_EM)
                  break
               end
           end
           Mean1 = [];
           Mean1_new = [];
           I_new=[];
           ERG = [];
           I=[];
           y = [];
           
           if k >= 2 % Speeding up the process by ignoring monopolar distributions
               if min(min(min(V_EM)))~= 0 && min(W_EM) ~= 0;

                  ob = gmdistribution(M_EM',V_EM,W_EM');
                  Gauss = pdf(ob,z');
                  Gauss = Gauss/max(Gauss); % normalize for better comparing

                  [~,I_new(1)]=max(Gauss);
                  k_new = 1;

                  for j=1:size(Gauss)-1
                      dGauss(j,1)= (Gauss(j+1,1)-Gauss(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
                      if j>1
                         if (dGauss(j,1)<0 && dGauss(j-1,1)>=0)
                            if j~=I_new(1)
                               I_new(k_new+1) = j;  % X-Komponente von Maximum über Steigung bestimmt  
                               k_new = k_new+1;
                            end
                         end
                      end
                  end
                  Mean1_new = [];
                  Mean1_new = I_new./100;
                  k_new = size(Mean1_new,2);

                 if k_new ~= k;
                    for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                        k = k_new;
                        Mean1 = [];
                        Mean1 = Mean1_new;
                        [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(Coeff_Norm(:,i),k,[],[],1,Mean1);
                        if ~isnan(L_EM)
                           break
                        end
                    end
                 end

                 if isnan(M_EM(1))
                    M_EM(1) = 1e-10; % if EM fails and is nan change to low value in order to continue process but exclude feature
                 end

                 for j = 1:k_new

                     if j == 1
                        ERG(j) = abs((1/V_EM(1,1,j)) / Gauss(ceil(M_EM(1)*100)));
                     elseif abs(L_EM) > 1e5
                        ERG(j) = 1e9;
                     else
                        if M_EM(1) < M_EM(j)
                           Min = min(Gauss(ceil(M_EM(1)*100):ceil(M_EM(j)*100)));
                        else
                           Min = min(Gauss(ceil(M_EM(j)*100):ceil(M_EM(1)*100)));
                        end
                        ERG(j) = abs(sum(V_EM(1,1,:)) / (M_EM(1)-M_EM(j)) / W_EM(j)); %  * exp(Min)
                     end
                 end
                 RES(i) = min(ERG);

                 %figure(10+i) %plot Gaussian approximation 
                 %hold all;
                 %plot(z,Gauss)
               else
                 RES(i) = 1e9;
               end
              
           else
              RES(i) = 1e9;
           end
           Max_Nr(i) = size(ERG,2)+1;
       end
   end
       
   for Nr=1:3
       
       for m=1:size(RES_E,2)
           [~,I1_E]=min(RES_E); % Allgemein bester Entropy Koeffizient hinsichtlich Verteilung
           for mm=1:Nr-1
               R = corrcoef(Entropy(:,I1_E),(SPIKES3D_t(1:size(Entropy,1),1,mm)));
               if (abs(R(1,2)) > 0.2) % Auswertung Korrelationskoeffizienten Schwellwert willkürlich!!!
                  RES_E(I1_E) = 1e9;
                  break
               end
           end
           if RES_E(I_E)<1e9;
              break
           end
       end

       SPIKES3D_t(1:size(Coeff,1),1,3+Nr) = Entropy(:,I1_E); 
       Entropy(:,I1_E) = 0;
       RES_E(I1_E) = max(RES_E)*2;
       Mean1_E = [];
       Mean1_E_new = [];
       I_E_new=[];
       ERG_E = [];
       I_E=[];
       I1_E=[];
       y_E = [];

       for m=1:size(RES,2)
           [~,I1]=min(RES); % Allgemein bester Koeffizient hinsichtlich Verteilung
           for mm=1:Nr-1
               R = corrcoef(Coeff(:,I1),(SPIKES3D_t(1:size(Coeff,1),1,mm)));
               if (abs(R(1,2)) > 0.2) % Auswertung Korrelationskoeffizienten Schwellwert willkürlich!!!
                  RES(I1) = 1e9;
                  break
               end
           end
           if RES(I)<1e9;
              break
           end
       end
       SPIKES3D_t(1:size(Coeff,1),1,Nr) = Coeff(:,I1); 
       RES(I1) = max(RES)*2;
       R = [];

       if discard == 1 && size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1 %
          SPIKES3D_discard(1:size(Coeff,1),n,13+Nr) = SPIKES3D_t(1:size(Coeff,1),1,Nr);
          SPIKES3D_discard(1:size(Coeff(:,I),1),n,16+Nr)= SPIKES3D_t(1:size(Coeff,1),1,3+Nr);
       else
          SPIKES3D(1:size(Coeff,1),n,13+Nr) = SPIKES3D_t(1:size(Coeff,1),1,Nr);
          SPIKES3D(1:size(Coeff(:,I),1),n,16+Nr)= SPIKES3D_t(1:size(Coeff,1),1,3+Nr);
       end
   end
   
   
   clear Mean Variance Entropy MX RES RESV TREE k I I1 Nr ERG Coeff R;
 end

%----ENDE calculate_Wave_Coeff---------------
%########################################################################

% -------------------- Feature_choice (RB)-------------------------------

 
       
   function  cln = Feature_choice(~,~) %choose Features to Refine Spikes (select the best 6 Features based on their distribution)
       
     if Sorting == 0
        manual = get(findobj('Tag','manual'),'value');
        F = [{'F1'} {'F2'} {'F3'} {'F4'} {'F5'} {'F6'}];
     else
        if isempty(get(findobj('Tag','SortingPanel'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
             manual = 0;
        else
             manual = get(findobj('Tag','S2_manual'),'value');
        end   
        F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
     end
     discard = 0;


     check = [];

       
     mean_Max_Nr = 0; 
     SPIKES3D_Norm=[];
     Max_Nr = [];
     Max_Nr_sort =[];
     check_sort = [];
     RES = [];
     ERG = [];
     I = [];
     I1 = [];
     active = 0;
     SPIKES3D_temp = []; % temporary array added to enable re-refinement of discarded Spike events
     SPIKES3D_Norm = [];


     if (discard == 1 && size(SPIKES3D_discard,1) ~= 0)||SubmitSorting(Elektrode) >= 1
        SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:); 
     else
        SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
     end
         
     for i=2:size(SPIKES3D_temp,3)
         %Norm the different features to secure comparability
         SPIKES3D_Norm(:,i) = (SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)-min(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)))/(max(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i))-min(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)));
         if min(SPIKES3D_Norm(:,i))~=0
            SPIKES3D_Norm(:,i) = SPIKES3D_Norm(:,i)*(-1);
         end
         
         if max(isnan(SPIKES3D_Norm(:,i))) >= 1 % if all Coeffs are 0 Coeff_Norm becomes NaN, therefore correction term is needed
            SPIKES3D_Norm(:,i) = zeros;
            SPIKES3D_temp(:,Elektrode,i) = zeros;
         end
         
         [y,z] = hist(SPIKES3D_Norm(:,i),100); % histogramm plot
         y = y-min(y); % Norm the plots in x and y
         z = z-min(z);
         y = y/max(y);
         z = z/max(z);

         for nn=1:10 %smoothing iterations
             y = smooth(y);    % plot smoothing  
         end

         %figure(10+i) %Test der Verteilung
         [~,I(1)]=max(y);              % 1. Extremum globales Maximum der Verteilung!!
         k=2;

         ERG = 0;
         for j=1:size(y)-1
             dy(j,1)= (y(j+1,1)-y(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
             if j>1
                if (dy(j,1)<0 && dy(j-1,1)>=0)
                    if j~=I(1)
                       I(k) = j;  % X-Komponente von Maximum über Steigung bestimmt  
                       k = k+1;
                    end
                end
             end
         end
         Mean1 = I./100;
         k = k-1;
         for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case

             if i == 15
                  xxx = 1;
             end
             [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(SPIKES3D_Norm(:,i),k,[],[],1,Mean1);
             if ~isnan(L_EM)
                 break
             end
         end
         Mean1 = [];
         Mean1_new = [];
         I_new=[];
         ERG = [];
         I=[];
         y = [];

         if (min(min(min(V_EM)))~= 0 && min(W_EM) ~= 0);

            ob = gmdistribution(M_EM',V_EM,W_EM');
            Gauss = pdf(ob,z');
            Gauss = Gauss/max(Gauss); % normalize for better comparing

            [~,I_new(1)]=max(Gauss);
            k_new = 1;

            for j=1:size(Gauss)-1
                dGauss(j,1)= (Gauss(j+1,1)-Gauss(j,1))/(z(1,j+1)-z(1,j)); % 1.Ableitung um Extremum zu finden
                if j>1
                   if (dGauss(j,1)<0 && dGauss(j-1,1)>=0)
                       if j~=I_new(1)
                          I_new(k_new+1) = j;  % X-Komponente von Maximum über Steigung bestimmt  
                          k_new = k_new+1;
                       end
                   end
                end
            end
            Mean1_new = [];
            Mean1_new = I_new./100;
            % figure(40+i);
            % hold all;
            % plot(z,Gauss);
            
            k_new = size(Mean1_new,2);

            if k_new ~= k;
               for m = 1:1 %iterative loop as EM_GM does "not always" give the same result five loops just  in case
                   k = k_new;
                   Mean1 = [];
                   Mean1 = Mean1_new;
                   [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(SPIKES3D_Norm(:,i),k,[],[],1,Mean1);
                   if ~isnan(L_EM)
                      break
                   end
               end
            end

            if isnan(M_EM(1))
               M_EM(1) = 1e-10; % if EM fails and is nan change to low value in order to continue process but exclude feature
            end

            for j = 1:k_new
                
                if abs(L_EM) > 1e5 || isnan(L_EM)
                   ERG(j) = 1e9;
                else
                    if j == 1
                       ERG(j) = abs((1/V_EM(1,1,j)) / Gauss(ceil(M_EM(1)*100)));
                    else
                        if M_EM(1) < M_EM(j)
                           Min = min(Gauss(ceil(M_EM(1)*100):ceil(M_EM(j)*100)));
                        else
                           Min = min(Gauss(ceil(M_EM(j)*100):ceil(M_EM(1)*100)));
                        end
                        ERG(j) = abs(sum(V_EM(1,1,:)) / (M_EM(1)-M_EM(j)) / W_EM(j)); %* exp(Min)
                    end
                end
            end
            RES(i-1) = min(ERG);

            % figure(100+i) %plot Gaussian approximation 
            % hold all;
            % plot(z,Gauss)
            %XXXXX =1;
        else
           RES(i-1) = 1e9;
        end
        Max_Nr(i-1) = size(ERG,2)+1;
     end
     for i=1:6% best Features %min(((get(findobj(gcf,'Tag','Feature_Nr'),'value'))+1),size(check,2))
         if min(RES)< 1e9
             for m=1:size(RES,2)
                 [~,I1]=min(RES); % Allgemein bester Koeffizient hinsichtlich Verteilung
                 for mm=1:i-1
                     R = corrcoef(SPIKES3D_temp(:,1,I1+1),SPIKES3D_temp(:,1,check(mm)));
                     if (abs(R(1,2)) > 0.5) % Auswertung Korrelationskoeffizienten Schwellwert willkürlich (0.2 allgemein als Grenze zur schwachen Korrelation angesehen)!!!
                        RES(I1) = 1e9;
                        break
                     end
                 end
                 if RES(I1) < 1e9
                    break
                 end
             end
             if min(RES) >= 1e9
                break
             end
             check(i) = I1+1;
         else
             break
         end
         RES(I1) = max(RES)*2;
         set(findobj('Tag',char(F(i))),'value',1);
         if i <= size(check,2) 
            set(findobj('Tag',char(F(i))),'value',check(i));
            mean_Max_Nr = (mean_Max_Nr + Max_Nr(check(i)-1));
            active = active +1;
         end
     end

     mean_Max_Nr = mean_Max_Nr/active;
     cln = floor(mean_Max_Nr);
     Mean1 = [];
     Mean1_new = [];
     I_new=[];
     ERG = [];
     I=[];
     y = [];
   end

%----ENDE Feature_choice---------------
%########################################################################

% -------------------- Clusterfunction (RB)-------------------------------
       
   function Class = Clusterfunction(~,~)

     class = [];   %Extra Zwischenvariable, da ansonsten Fehler bei cluster-Funktion!!
     k_means = 0;

     if Sorting == 0
        k_means = get(findobj('Tag','EM_k-means'),'value');
        discard = get(findobj('Tag','discard'),'value');
        manual = get(findobj('Tag','manual'),'value');
        FPCA = get(findobj('Tag','FPCA'),'value');
        F = [{'F1'} {'F2'} {'F3'} {'F4'} {'F5'} {'F6'}];
     else
        if Window == 0
           k_means  = get(findobj('Tag','S_EM_k-means'),'value');
           discard = 0;
           manual = 0;
           FPCA = get(findobj('Tag','S_FPCA'),'value');
           
        else
           manual = get(findobj('Tag','S2_manual'),'value');
           k_means  = get(findobj('Tag','S2_EM_k-means'),'value');
           discard = 0;
           FPCA = get(findobj('Tag','S2_FPCA'),'value');
        end  
        F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
     end
     if FPCA == 0
        if manual == 0 || size(cln,1)== 0
           cln = Feature_choice;
        end
     else
        cln = 2; % as real number can not be approximated by EM algorithm CLusternukmber is simply set to 2  
        SPIKES_FPCA = []; % reset size of SPIKES_FPCA
        if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
           XX(1:size(SPIKES3D_discard,1),1:size(SPIKES3D_discard,3)) = SPIKES3D_discard(:,1,:); %SPIKES3D muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!
        else
           XX(1:size(SPIKES3D,1),1:size(SPIKES3D,3)) = SPIKES3D(:,Elektrode,:); %SPIKES3D muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!  
        end
        
        [~,Score,latent] = princomp(XX);
        clear XX;
        sum_latent = sum(latent);
        for i=1:size(Score,2)
            if (latent(i)/sum_latent) >= 0.1 || i < 3 % Evaluation of explained variance
                SPIKES_FPCA(:,i) = Score(:,i); %HK 1:n 
            end
        end
     end
     
     if Sorting == 0
        k = cln; 
     else
        if Window == 0
           if str2double(get(findobj('Tag','S_K_Nr','parent',t6),'string')) ~= 0
              k = str2double(get(findobj('Tag','S_K_Nr','parent',t6),'string'));
           else
              k = cln; 
           end
        else
           if str2double(get(findobj('Tag','S2_K_Nr'),'string')) ~= 0
              k = str2double(get(findobj('Tag','S2_K_Nr'),'string'));
           else
              k = cln; 
           end
        end
     end
         
     clear W_EM M_EM V_EM L_EM;
     W_EM = [];
     M_EM = [];
     V_EM = [];
     L_EM = [];
     SPIKES3D_temp = [];

     % Elektrode = get(findobj('Tag','Elektrodenauswahl'),'value');
    if FPCA == 0
       if discard == 1 &&  size(SPIKES3D_discard,1) ~= 0 || SubmitSorting(Elektrode) >= 1
          SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
       else
          SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
       end
    else
       SPIKES3D_temp(:,1,:) = SPIKES_FPCA(:,1:size(SPIKES_FPCA,2));
       check = 1:size(SPIKES_FPCA,2); % convert check, so that the algorithm also works for FPCA
    end
        
     
     if isempty(get(findobj('Tag','F(1)'),'value')) == 1
         
         for i=1:size(check,2)
             X(:,i) = SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1, check(i));
             XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i))); % Problem: Funktioniert nur dann, wenn beide Merkmale in etwa die selbe Dimension haben, ansonsten gibt es Probleme mit Epsilon
         end
         X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,[check(1) check(2)]); % Muss nach der Erstellung von XX_N gemacht werden, damit Darstellung im Scatterplot wieder konsistent ist
     else
         
        for i=1:6

             if (get(findobj('Tag',char(F(i))),'value'))~= 1
                X(:,i) = SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1, get(findobj('Tag',char(F(i))),'value'));
                XX_N(:,i) = (X(:,i)-min(X(:,i)))/(max(X(:,i))-min(X(:,i))); % Problem: Funktioniert nur dann, wenn beide Merkmale in etwa die selbe Dimension haben, ansonsten gibt es Probleme mit Epsilon
             end
        end
        X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,[(get(findobj('Tag','F1'),'value')) (get(findobj('Tag','F2'),'value'))]); % Muss nach der Erstellung von XX_N gemacht werden, damit Darstellung im Scatterplot wieder konsistent ist
     end

    
    if k_means == 1
       [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),k,[],[],1,[]);

       [Class,~] = kmeans(XX_N,k,'start',M_EM','emptyaction','singleton');
       Probability(size(XX_N)) = 1;

    else 

       BIC_old = 0;
       C_EM = 0;

      for i = 1:5 %iterative loop as bad Features can be present in first loops
           [W_EM,M_EM,V_EM,L_EM] = EM_GM_Dr_cell(XX_N(:,:),k,[],[],1,[]);
           obj = gmdistribution(M_EM',V_EM,W_EM');
           sig = obj.Sigma;
           e(:,:) =abs(mean(sig,1));

           if min(min(e))==0
              [~,I] = min(min(e,[],2));
              if I == 1
                  XX_temp = XX_N(:,I+1:size(XX_N,2));
              elseif I == size(XX_N,2)
                  XX_temp = XX_N(:,1:I-1);
              else
                  XX_temp = XX_N(:,1:I-1);
                  XX_temp(:,I:size(XX_N,2)-1) = XX_N(:,I+1:size(XX_N,2));
              end

              XX_N = [];
              XX_N = XX_temp;
              clear XX_temp;

              check_temp = check(check ~= check(I));
              check = [];
              check = check_temp;
              e = [];

              for i = 1:6     % correct Feature selection         
                  set(findobj('Tag',char(F(i))),'value',1);
                  if i <= size(check,2) 
                     set(findobj('Tag',char(F(i))),'value',check(i));
                  end
              end

           else
               if ~isnan(L_EM)
                   break;
               end
           end
       end
           %BIC = abs((-2*L_EM)+(2*i*log(size(XX_N,1)*size(XX_N,2))));
           %if BIC < BIC_old %abs für das Vorzeichen siehe L_old
           %break;
           %end
           %BIC_old = abs(BIC);
       %end


%            Gauss = pdf(obj,Z); 
%            figure(100+i)
%            plot(Z,Gauss)

       if Window == 0
          p = 0;
       else
          p = str2double(get(findobj('Tag','confidence'),'string'))/100;
       end
       
       [class,~,~,ln]  = cluster(obj,XX_N);
       Class = [];
       Class =class;
       if p >= 0
          Class(exp(ln)<=p) = max(Class)+1;
       end
    end
    
    if Sorting == 0

        Cl = k;

        while (Cl>2)

           for i=1:k-1
               for n=1:k-i
                   DIST(i,n) = sum(abs(M_EM(:,i)-M_EM(:,i+n))); 
               end
           end
           DIST(DIST==0)=max(max(DIST))*10;
           C = min(min(DIST));
           [I(1),I(2)] =find(DIST==C);
           Class(Class==I(2)+I(1),1)=I(1);
           M_EM(:,I(2)+I(1)) = max(max(DIST))*10; 
           Cl = Cl-1;
        end
        Class(Class == min(Class))= 1;
        Class(Class~=1) = 2; % Setting Clusternumbers to 1 and 2
    end

   end

%----ENDE Clusterfunction---------------
%########################################################################

% -------------------- Submit (RB)-------------------------------
       
   function Submit(~,~)

    if isempty(get(findobj('Tag','discard'),'value')) == 1 % Test if checkbox discard exists for first Spike Sorting cycle
       discard = 0;
    else
       discard = get(findobj('Tag','discard'),'value');
    end   

    if discard == 0 || size(SPIKES3D_discard,1) == 0 

        n = Elektrode;
        I = (mean(SPIKES3D(Class~=1,n,2))<= mean(SPIKES3D(Class==1,n,2))); % determining the Spike Cluster based on mean neg. Amplitude
        spikes = I+1;
        SPIKES3D_OLD = SPIKES3D;
        SPIKES_OLD = SPIKES;
        SPIKES3D_NEW(:,n,:) = SPIKES3D((Class == spikes),n,:);
        SPIKES_NEW(:,n) = SPIKES((Class == spikes),n);
        SPIKES3D_discard(1:size(SPIKES3D(Class ~= spikes),1),1,:) = SPIKES3D((Class ~= spikes),n,:);
        SPIKES3D = [];
        SPIKES = [];
        s = size(SPIKES3D_OLD,1);

        if  s > size(SPIKES3D_OLD(:,n,:),1)
            SPIKES3D = SPIKES3D_OLD(1:s,:,:);
            SPIKES = SPIKES_OLD(1:s,:);
        else
            for i=1:size(SPIKES3D_OLD,2)
                New_Size(i) = size(nonzeros(SPIKES3D_OLD(:,i,1)),1);
                if i == n
                   New_Size(i) = 0;
                end
            end
            New_Size(1) = max(New_Size);
            if size(SPIKES3D_NEW,1)> New_Size(1)
               SPIKES3D = SPIKES3D_OLD(1:size(SPIKES3D_NEW,1),:,:);
               SPIKES = SPIKES_OLD(1:size(SPIKES_NEW,1),:);
            else
               SPIKES3D = SPIKES3D_OLD(1:New_Size(1),:,:);
               SPIKES = SPIKES_OLD(1:New_Size(1),:);
            end
        end
        SPIKES3D(:,n,:) = zeros; 
        SPIKES3D(1:size(SPIKES3D_NEW,1),n,:) = SPIKES3D_NEW(:,n,:);
        SPIKES3D_NEW = []; 
        SPIKES3D_OLD = [];
        
        SPIKES(:,n) = zeros; 
        SPIKES(1:size(SPIKES_NEW,1),n) = SPIKES_NEW(:,n);
        SPIKES_NEW = []; 
        SPIKES_OLD = [];
        NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
        clear SPIKES3D_NEW SPIKES3D_OLD s spikes SPIKES_NEW SPIKES_OLD;
        Class = [];
        Class(1:size(nonzeros(SPIKES(:,n)),1),1) = 1;
    else
       n = Elektrode;
       I = (mean(SPIKES3D_discard(Class~=1,n,2))<= mean(SPIKES3D_discard(Class==1,n,2))); % determining the Spike Cluster based on mean neg. Amplitude
       spikes = I+1; 
       SPIKES3D_NEW(:,n,:) = SPIKES3D_discard((Class == spikes),1,:);
       SPIKES_NEW(:,n) = SPIKES3D_discard((Class == spikes),1,1);
       SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = zeros;
       SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = zeros;
       SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = SPIKES3D_NEW(:,n,:);
       SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = SPIKES_NEW(:,n);

       X_temp(:,:) = SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:);
       X_temp = sortrows(X_temp,1);
       SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:)= X_temp;
       SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n)= sortrows(SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n),1);

       NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
       SPIKES3D_discard = [];
       clear SPIKES3D_NEW SPIKES3D_OLD s spikes SPIKES_NEW SPIKES_OLD X_temp;
    end
    scale = get(scalehandle,'value');   % Y-Skalierung festlegen                                
    switch scale
        case 1, scale = 50;
        case 2, scale = 100;
        case 3, scale = 200;
        case 4, scale = 500;
        case 5, scale = 1000;
   end

   BURSTS(:,n) = zeros;
   NR_BURSTS(n) = 0;
   if Viewselect == 0   
       
       scroll_bar = (size(EL_NAMES,1)-Elektrode);
       
       if size(EL_NAMES,1)<=4

           delete (SubMEA_vier(Elektrode));
           SubMEA_vier(Elektrode)=subplot(4,1,Elektrode,'Parent',mainWindow);
           set(SubMEA_vier(Elektrode),'Parent',bottomPanel);
           plot(T,M(:,Elektrode),'Parent',SubMEA_vier(Elektrode));
           hold all;
           axis(SubMEA_vier(Elektrode),[0 T(size(T,2)) -1*scale scale]); 
           set(SubMEA_vier(Elektrode),'XGRID','on');
           set(SubMEA_vier(Elektrode),'YGRID','on');
           Plot_type = SubMEA_vier(Elektrode);

           Graph =Elektrode;

       elseif scroll_bar < 3 % special case if selected Electrode can't be set as top graph
           
           set(findobj('Tag','CELL_slider'),'value',size(M,2)-Elektrode - scroll_bar);   % Position der Scrollbar
           for v = 1:4
               uicontrol('style', 'text',...                       
                         'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-(v-1)*120 50 25],...
                         'Parent', bottomPanel, 'Tag', 'ShowElNames','String', EL_NAMES(Elektrode+v-1-(3-scroll_bar)));
               delete (SubMEA_vier(v));
               SubMEA_vier(v)=subplot(4,1,v,'Parent',mainWindow);
               set(SubMEA_vier(v),'Parent',bottomPanel);
               plot(T,M(:,Elektrode+v-1-(3-scroll_bar)),'Parent',SubMEA_vier(v));
               hold on;
               axis(SubMEA_vier(v),[0 T(size(T,2)) -1*scale scale]); 
               set(SubMEA_vier(v),'XGRID','on');
               set(SubMEA_vier(v),'YGRID','on');
               hold off;
               Plot_type = SubMEA_vier(v);
               Graph = scroll_bar;
               
               if varTdata==1
                  line ('Xdata',T,'Ydata',varT(:,Elektrode+v-1),...
                        'LineStyle','--','Color','red','Parent',Plot_type);  
               % variablen Threshold zeichnen (AD)   
               end
               if thresholddata
                  if varTdata==0;                                                     %variabler threshold?                                             
                     if get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t6),'value');   % Thresholds
                        line ('Xdata',[0 T(length(T))],...                              % (gestrichelte Linie)
                              'Ydata',[THRESHOLDS(Elektrode+v-1-(3-scroll_bar)) THRESHOLDS(Elektrode+v-1-(3-scroll_bar))],...
                              'LineStyle','--','Color','red','Parent',Plot_type);
                     end
                  end
               end 

               if spikedata==1
                  set(findobj('Tag','ShowSpikesBurstsperEL','Parent',t5),'Visible','on');

                  %Anzahl der Spikes anzeigen (Änderungen Andy, OK?)
                  uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-(v-1)*120 30 20],...
                  'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(Elektrode+v-1-(3-scroll_bar)));

                  %Anzahl der Bursts anzeigen
                  uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-(v-1)*120 30 20],...
                  'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', 0);    

                  if get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes
                     SP = nonzeros(SPIKES(:,Elektrode+v-1-(3-scroll_bar)));                            % (grüne Dreiecke)
                     if isempty(SP)==0
                        y_axis = ones(length(SP),1).*scale.*.9;
                        line ('Xdata',SP,'Ydata', y_axis,...
                              'LineStyle','none','Marker','v',...
                              'MarkerFaceColor','green','MarkerSize',9,'Parent',Plot_type);
                      end
                   end
                end
                if stimulidata==1
                   if get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t6),'value');  % Stimuli
                      for k=1:length(BEGEND)                                       % (Rote Linien)
                          line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                'Color','red', 'LineWidth',1,'Parent',Plot_type);
                      end 
                   end
                end
           end

       else

           set(findobj('Tag','CELL_slider'),'value',size(M,2)-Elektrode - 3);   % Position der Scrollbar
           for v = 1:4
               uicontrol('style', 'text',...                       
                         'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 12,'units', 'pixels', 'position', [25 450-(v-1)*120 50 25],...
                         'Parent', bottomPanel, 'Tag', 'ShowElNames','String', EL_NAMES(Elektrode+v-1));
               delete (SubMEA_vier(v));
               SubMEA_vier(v)=subplot(4,1,v,'Parent',mainWindow);
               set(SubMEA_vier(v),'Parent',bottomPanel);
               plot(T,M(:,Elektrode+v-1),'Parent',SubMEA_vier(v));
               hold on;
               axis(SubMEA_vier(v),[0 T(size(T,2)) -1*scale scale]); 
               set(SubMEA_vier(v),'XGRID','on');
               set(SubMEA_vier(v),'YGRID','on');
               hold off;
               Plot_type = SubMEA_vier(v);
               Graph = 1;

               if varTdata==1
                  line ('Xdata',T,'Ydata',varT(:,Elektrode+v-1),...
                        'LineStyle','--','Color','red','Parent',Plot_type);  
               % variablen Threshold zeichnen (AD)   
               end
               if thresholddata
                  if varTdata==0;                                                     %variabler threshold?                                             
                     if get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t6),'value');   % Thresholds
                        line ('Xdata',[0 T(length(T))],...                              % (gestrichelte Linie)
                              'Ydata',[THRESHOLDS(Elektrode+v-1) THRESHOLDS(Elektrode+v-1)],...
                              'LineStyle','--','Color','red','Parent',Plot_type);
                     end
                  end
               end 

               if spikedata==1
                  set(findobj('Tag','ShowSpikesBurstsperEL','Parent',t5),'Visible','on');

                  %Anzahl der Spikes anzeigen (Änderungen Andy, OK?)
                  uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-(v-1)*120 30 20],...
                  'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(Elektrode+v-1));

                  %Anzahl der Bursts anzeigen
                  uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-(v-1)*120 30 20],...
                  'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', 0);    

                  if get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes
                     SP = nonzeros(SPIKES(:,Elektrode+v-1));                            % (grüne Dreiecke)
                     if isempty(SP)==0
                        y_axis = ones(length(SP),1).*scale.*.9;
                        line ('Xdata',SP,'Ydata', y_axis,...
                              'LineStyle','none','Marker','v',...
                              'MarkerFaceColor','green','MarkerSize',9,'Parent',Plot_type);
                      end
                   end
                end
                if stimulidata==1
                   if get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t6),'value');  % Stimuli
                      for k=1:length(BEGEND)                                       % (Rote Linien)
                          line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                                'Color','red', 'LineWidth',1,'Parent',Plot_type);
                      end 
                   end
                end
           end

       end

   elseif Viewselect == 1;

       set(findobj('Tag','CELL_BottomPanel'),'Visible','off');
       set(findobj('Tag','CELL_BottomPanel_zwei'),'Visible','on');
       MEAslider_pos = double(int8(get(findobj('Tag','MEA_slider'),'value')));

       ALL_CHANNELS = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
       %ZUORDNUNG = [7 15 23 31 39 47 1 8 16 24 32 40 48 55 2 9 17 25 33 41 49 56 3 10 18 26 34 42 50 57 4 11 19 27 35 43 51 58 5 12 20 28 36 44 52 59 6 13 21 29 37 45 53 60 14 22 30 38 46 54];
       ZUORDNUNG2= [9 17 25 33 41 49 2 10 18 26 34 42 50 58 3 11 19 27 35 43 51 59 4 12 20 28 36 44 52 60 5 13 21 29 37 45 53 61 6 14 22 30 38 46 54 62 7 15 23 31 39 47 55 63 16 24 32 40 48 56];

       subplotposition = ZUORDNUNG2(find(ALL_CHANNELS==EL_NUMS(Elektrode)));%#ok 
       delete(SubMEA(subplotposition)); 
       showend = MEAslider_pos*SaRa + 1;
       showstart = showend - SaRa;

       if Elektrode == 49
          set(gca,'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
       end        

       SubMEA(Elektrode) = subplot(8,8,subplotposition,'Parent',mainWindow);
       set(SubMEA(Elektrode),'Parent',bottomPanel_zwei);
       %Ansprechen der korrekten Subplots
       plot(T(showstart:showend),M(showstart:showend,Elektrode),'Parent',SubMEA(Elektrode))                   %Zeichen in diesen Subplot
       hold all;
       axis(SubMEA(Elektrode),[T(showstart) T(showend) -1*scale scale])
       set(SubMEA(Elektrode),'XTickLabel',[],'YTickLabel',[]);
       hold off;
       if (EL_NUMS(Elektrode) == 17)
          set(SubMEA(Elektrode),'xlim',([T(showstart) T(showend)]),'XTickLabel',T(showstart):0.5:T(showend+1),'YTickLabel',[-1*scale 0 scale], 'FontSize',6);
       end   

       if Elektrode <= 8
           Elzeile = strcat('El X ',num2str(Elektrode));
           uicontrol('style', 'text','BackgroundColor', [0.8 0.8 0.8],'FontSize', 11,'units', 'pixels', 'position', [30 525-Elektrode*57 60 25],...
                     'Parent', bottomPanel_zwei, 'String', Elzeile);
       end

       if Elektrode <= 8
           Elspalte = strcat({'El '}, num2str(Elektrode),{'X'});
           uicontrol('style', 'text','BackgroundColor', [0.8 0.8 0.8],'FontSize', 11,'units', 'pixels', 'position', [54+Elektrode*121 520 60 25],...
                     'Parent', bottomPanel_zwei, 'String', Elspalte);
       end

       %uicontrol('style', 'text','BackgroundColor', [0.8 0.8 0.8],'FontSize', 7,'units', 'pixels', 'position', [180 94 40 15],...
                 %'Parent', bottomPanel_zwei, 'String', 'time / s');    

      Plot_type = SubMEA(Elektrode);

      Graph = Elektrode;
   end
   if varTdata==1
      line ('Xdata',T,'Ydata',varT(:,Elektrode),...
            'LineStyle','--','Color','red','Parent',Plot_type);  
      % variablen Threshold zeichnen (AD)   
   end
   if thresholddata
      if varTdata==0;                                                     %variabler threshold?                                             
         if get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showThresholdsCheckbox','Parent',t6),'value');   % Thresholds
            line ('Xdata',[0 T(length(T))],...                              % (gestrichelte Linie)
                  'Ydata',[THRESHOLDS(Elektrode) THRESHOLDS(Elektrode)],...
                  'LineStyle','--','Color','red','Parent',Plot_type);
         end
      end
   end 

   if spikedata==1
      set(findobj('Tag','ShowSpikesBurstsperEL','Parent',t5),'Visible','on');

      %Anzahl der Spikes anzeigen (Änderungen Andy, OK?)
      uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 462-(Graph-1)*120 30 20],...
      'Parent', bottomPanel, 'Tag', 'ShowSpikesBurstsperEL','String', NR_SPIKES(Elektrode));

      %Anzahl der Bursts anzeigen
      uicontrol('style', 'text', 'BackgroundColor', [0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 8,'units', 'pixels', 'position', [1150 432-(Graph-1)*120 30 20],...
      'Parent', bottomPanel,'Tag', 'ShowSpikesBurstsperEL','String', 0);    

      if get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showSpikesCheckbox','Parent',t6),'value');       % Spikes
         SP = nonzeros(SPIKES(:,Elektrode));                            % (grüne Dreiecke)
         if isempty(SP)==0
            y_axis = ones(length(SP),1).*scale.*.9;
            line ('Xdata',SP,'Ydata', y_axis,...
                  'LineStyle','none','Marker','v',...
                  'MarkerFaceColor','green','MarkerSize',9,'Parent',Plot_type);
          end
       end
    end
    if stimulidata==1
       if get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t5),'value') && get(findobj('Tag','CELL_showStimuliCheckbox','Parent',t6),'value');  % Stimuli
          for k=1:length(BEGEND)                                       % (Rote Linien)
              line ('Xdata',[BEGEND(k) BEGEND(k)],'YData',[-2500 2500],...
                    'Color','red', 'LineWidth',1,'Parent',Plot_type);
          end 
       end
    end
    SubmitRefinement = 1; 
   end

%----ENDE Submit---------------
%########################################################################

% -------------------- Expectation Maximation(RB)-------------------------------

    % Written by
    %   Patrick P. C. Tsui,
    %   PAMI research group
    %   Department of Electrical and Computer Engineering
    %   University of Waterloo, 
    %   March, 2006
    % Quelle Orignial Quellcode von mir editiert und angepasst 
    
    function [W,M,V,L] = EM_GM_Dr_cell(XX_N,k,ltol,maxiter,pflag,Mean1)
    % [W,M,V,L] = EM_GM(X,k,ltol,maxiter,pflag,Init) 

        if nargin <= 1,
            return
        elseif nargin == 2,
            ltol = 1e-12; maxiter = 1000; pflag = 0; Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            if err_X || err_k, return; end
        elseif nargin == 3,
            maxiter = 1000; pflag = 0; Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);    
            if err_X || err_k || err_ltol, return; end
        elseif nargin == 4,
            pflag = 0;  Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);    
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            if err_X || err_k || err_ltol || err_maxiter, return; end
        elseif nargin == 5,
             Init = [];
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);    
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            [pflag,err_pflag] = Verify_pflag(pflag);
            if err_X || err_k || err_ltol || err_maxiter || err_pflag, return; end
        elseif nargin == 6,
            err_X = Verify_X(XX_N);
            err_k = Verify_k(k);
            [ltol,err_ltol] = Verify_ltol(ltol);    
            [maxiter,err_maxiter] = Verify_maxiter(maxiter);
            [pflag,err_pflag] = Verify_pflag(pflag);
            err_Init = 0;
            Init = [];
            if err_X || err_k || err_ltol || err_maxiter || err_pflag ||err_Init , return; end %  rausgenommen
        else
            return
        end

        %%%% Initialize W, M, V,L %%%%
        t = cputime;

        if isempty(Init)  
            Mean1 = Mean1;
            [W,M,V] = Init_EM(XX_N,k,Mean1);
            L = 0;    
        else
            W = Init.W;
            M = Init.M;
            V = Init.V;
            Mean1 = Mean1;
        end
        Ln = Likelihood(XX_N,k,W,M,V); % Initialize log likelihood
        Lo = 2*Ln;

        %%%% EM algorithm %%%%
        niter = 0;

        while (abs(100*(Ln-Lo)/Lo)>ltol) && (niter<=maxiter)
              E = Expectation(XX_N,k,W,M,V); % E-step    
              [W,M,V] = Maximization(XX_N,k,E);  % M-step
              Lo = Ln;
              Ln = Likelihood(XX_N,k,W,M,V);
              niter = niter + 1;
        end
        L = Ln;
    end
    %%%% End of EM_GM %%%%

    function E = Expectation(XX_N,k,W,M,V)
        [n,d] = size(XX_N);
        a = (2*pi)^(0.5*d);
        S = zeros(1,k);
        iV = zeros(d,d,k);
        for j=1:k,
            if V(:,:,j)==zeros(d,d), V(:,:,j)=ones(d,d)*eps; end
            S(j) = sqrt(det(V(:,:,j)));
            iV(:,:,j) = inv(V(:,:,j));    
        end
        E = zeros(n,k);
        for i=1:n,    
            for j=1:k,
                dXM = XX_N(i,:)'-M(:,j);
                pl = exp(-0.5*dXM'*iV(:,:,j)*dXM)/(a*S(j));
                E(i,j) = W(j)*pl;
            end
            E(i,:) = E(i,:)/sum(E(i,:));
        end
    end
   
    %%%% End of Expectation %%%%

    function [W,M,V] = Maximization(XX_N,k,E)
        [n,d] = size(XX_N);
        W = zeros(1,k); M = zeros(d,k);
        V = zeros(d,d,k);
        for i=1:k,  % Compute weights
            for j=1:n,
                W(i) = W(i) + E(j,i);
                M(:,i) = M(:,i) + E(j,i)*XX_N(j,:)';
            end
            M(:,i) = M(:,i)/W(i);
        end
        for i=1:k,
            for j=1:n,
                dXM = XX_N(j,:)'-M(:,i);
                V(:,:,i) = V(:,:,i) + E(j,i)*dXM*dXM';
            end
            V(:,:,i) = V(:,:,i)/W(i);
        end
        W = W/n;
    end
    %%%% End of Maximization %%%%

    function L = Likelihood(XX_N,k,W,M,V)
        
    % Compute L based on K. V. Mardia, "Multivariate Analysis", Academic Press, 1979, PP. 96-97
    % to enchance computational speed
        [n,d] = size(XX_N);
        U = mean(XX_N)';
        S = cov(XX_N);
        L = 0;
        for i=1:k,
            iV = inv(V(:,:,i));
            L = L + W(i)*(-0.5*n*log(det(2*pi*V(:,:,i))) ...
                -0.5*(n-1)*(trace(iV*S)+(U-M(:,i))'*iV*(U-M(:,i))));
        end
    end

    %%%% End of Likelihood %%%%


    function err_X = Verify_X(XX_N)
        err_X = 1;
        [n,d] = size(XX_N);
        if n<d,
            return
        end
        err_X = 0;
    end

    %%%% End of Verify_X %%%%


    function err_k = Verify_k(k)
        err_k = 1;
        if ~isnumeric(k) || ~isreal(k) || k<1,
            return
        end
        err_k = 0;
    end

    %%%% End of Verify_k %%%%

    function [ltol,err_ltol] = Verify_ltol(ltol)
        err_ltol = 1;
        if isempty(ltol),
            ltol = 0.1;
        elseif ~isreal(ltol) || ltol<=0
            return
        end
        err_ltol = 0;
    end

    %%%% End of Verify_ltol %%%%

    function [maxiter,err_maxiter] = Verify_maxiter(maxiter)
        err_maxiter = 1;
        if isempty(maxiter),
            maxiter = 1000;
        elseif ~isreal(maxiter) || maxiter<=0,
            return
        end
        err_maxiter = 0;
    end

    %%%% End of Verify_maxiter %%%%

    function [pflag,err_pflag] = Verify_pflag(pflag)
        err_pflag = 1;
        if isempty(pflag),
            pflag = 0;
        elseif pflag~=0 & pflag~=1,
            return
        end
        err_pflag = 0;
    end

    %%%% End of Verify_pflag %%%%

    function [Init,err_Init] = Verify_Init(Init)
        err_Init = 1;
        if isempty(Init)
        elseif isstruct(Init)
            [Wd,Wk] = size(Init.W);
            [Md,Mk] = size(Init.M);
            [Vd1,Vd2,Vk] = size(Init.V);
            if Wk~=Mk || Wk~=Vk || Mk~=Vk
                return
            end
            if Md~=Vd1 || Md~=Vd2 || Vd1~=Vd2,
                return
            end
        else
            return
        end
        err_Init = 0;
    end

    %%%% End of Verify_Init %%%%

    function [W,M,V] = Init_EM(XX_N,k,Mean1)
        [n,d] = size(XX_N);
        if size(Mean1) == 0
            [Ci,C] = kmeans(XX_N,k,'Start','cluster', ...
            'Maxiter',100, ...
            'EmptyAction','drop', ...
            'Display','off'); 
        else
            [Ci,C] = kmeans(XX_N,k,'Start',Mean1', ...
            'Maxiter',100, ...
            'EmptyAction','drop', ...
            'Display','off'); % Ci(nx1) - cluster indeices; C(k,d) - cluster centroid (i.e. mean)
        
            while sum(isnan(C))>0,
                [Ci,C] = kmeans(XX_N,k,'Start',Mean1', ...
                    'Maxiter',100, ...
                    'EmptyAction','drop', ...
                    'Display','off');
            end
        end
        M = C';
        Vp = repmat(struct('count',0,'X',zeros(n,d)),1,k);
        for i=1:n, % Separate cluster points
            Vp(Ci(i)).count = Vp(Ci(i)).count + 1;
            Vp(Ci(i)).XX_N(Vp(Ci(i)).count,:) = XX_N(i,:);
        end
        V = zeros(d,d,k);
        for i=1:k,
            W(i) = Vp(i).count/n;
            V(:,:,i) = cov(Vp(i).XX_N(1:Vp(i).count,:));
        end
    end

%%%% End of Init_EM %%%%

%----ENDE Expectation Maximation---------------
%######################################################################## 

% -------------------- Spike Sorting (RB)-------------------------------

    function Spike_Sorting(~,~)
        
        Var = [{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'}]; 
                
         Var_var =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Wavelet Variance 1'};{'Wavelet Variance 2'};{'Wavelet Variance 3'};{'Wavelet Energy 1'};
                    {'Wavelet Energy 2'};{'Wavelet Energy 3'};{'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};
                    {'Right Spk. Angle(Neg./var.)'}];

       Var_neither =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    ];         
       
       Var_no_wave =[{'------------------------'};{'Negative Amplitude'};{'Positive Amplitude'};{'NEO'};{'Negative Signal Energy'};{'Positive Signal Energy'};{'Spike Duration'};
                    {'Left Spk. Angle(Neg.)'};{'Right Spk. Angle(Neg.)'};{'1.Principal Component'};{'2.Principal Component'};{'3.Principal Component'};{'4.Principal Component'};
                    {'Neg. Amplitude(var.)'};{'Spike Duration(var.)'};{'Left Spk. Angle(Neg./var.'};{'Right Spk. Angle(Neg./var.)'}];
                
        units = [{'Voltage / µV'};{'Voltage / µV'};{'Scalar'};{'Energy / V ^2 / s'};{'Energy / V ^2 / s'};{'Time / ms'};{'Scalar'};{'Scalar'};
                {'Scalar'};{'Scalar'};{'Gradient µV / s'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};{'Scalar'};
                {'Voltage / µV'};{'Time / ms'};{'Scalar'};{'Scalar'};];
                
%         if varTdata~=1
             V = Var;
%         else
%              V =  Var_var;
%         end
        
        F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
        
        data = 0;
        Spike = 0;
        Elektrode = [];
        ST = 1; 
        Min(1:(size(SPIKES,1))) = zeros;
        Max(1:(size(SPIKES,1))) = zeros;
        XX=[];
        Class(1:size(SPIKES,1)) = zeros;
        check = [];
        cln = [];
        k = 2;
        pretime = 0.5;
        posttime = 0.5;
        SPIKES3D_discard = [];
        Window = 0;
        Spkplot1 = [];
        Spkplot2 = [];
        spikes = [];
        SPIKES3D_temp = [];
        M_old = [];
        all = 0;
        
        preti = (0.5:1000/SaRa:2);
        postti = (0.5:1000/SaRa:2);

        start_sorting;

        function start_sorting(~,~)
            
            tic
            w = waitbar(.1,'Please wait - Spike Sorting in progress...');
            F = [{'S_F1'} {'S_F2'} {'S_F3'} {'S_F4'} {'S_F5'} {'S_F6'}];
            
            SPIKES3D_temp = [];
            Shapes_temp = [];
            Class(:,:) = [];
            
            Elektrode = get(findobj('Tag','S_Elektrodenauswahl'),'value');
            Sorting = 1; % Variable to discriminate between calls from Sorting and Refinement tool
            
            if size(SPIKES3D_discard,1) == 0
               SubmitSorting(Elektrode) = 0;
            end
            
            pretime = preti(get(findobj('Tag','S_pretime'),'value'));
            posttime = postti(get(findobj('Tag','S_posttime'),'value'));
            
            Shapes=[]; 
            if SubmitSorting(Elektrode) >= 1
               Shapes(1:size(SPIKES3D_discard,1),1:size(SPIKES3D_discard,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
               SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
            else
               Shapes(1:size(SPIKES,1),1:size(SPIKES,2),1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))=zeros;
            end

            Shape(pretime,posttime);
            waitbar(.15,w,'Please wait - Features being calculated...')
            if data == false %Überprüfung ob Daten schon berechnet wurden
               
                
                if varTdata~=1 % selection of right set of Feature Strings
                   if get(findobj('Tag','S_Wavelet'),'value')==1
                      V = Var;
                   else
                       V = Var_neither;
                   end
                else
                    if get(findobj('Tag','S_Wavelet'),'value')==1
                       V =  Var_var;
                    else
                       V = Var_no_wave;
                    end
                end

                calculate(V,pretime,posttime); %claculate basic Features (Amplitude, NEO, PCA, Spike Angles, Min-Max-Ratio, Spike Duration) 
                calculate_area; %calculate Areas of Spikes
            end
            % calculate PCA and Wavelet for each sorting stage  
            if submit_data == 1 || Window == 0
                calculate_PCA; %calculate principal components
                waitbar(.3,w,'Please wait - Wavelet Features being calculated...')
                if get(findobj('Tag','S_Wavelet'),'value')==1
                   calculate_Wave_Coeff; %calculate Wavelet Coefficients (Energy and Variance Criteria)
                end
                submit_data = 0;
            end    
            
            waitbar(.6,w,'Please wait - Clustering...')
            
            if Window == 1
               for i = 1:6
                   if get(findobj('Tag',char(F(i))),'value') ~=1 
                      check(i) = get(findobj('Tag',char(F(i))),'value');
                   else
                       check(i) = 0;
                   end
               end
               check = nonzeros(check);
               check = check';
            end

            Class = Clusterfunction;
            k =max(Class);
          
            if  Window == 0
                %Main Window
                SpikeSortingWindow = figure('Name','Spike Sorting','NumberTitle','off','Position',[45 100 1200 600],'Toolbar','none','Resize','off','Tag','SpikeSortingWindow');


                %Main Window header
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [180 455 250 20],'HorizontalAlignment','center','String','Identified Clusters','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [600 455 250 20],'HorizontalAlignment','center','String','Cluster 1','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [600 230 250 20],'HorizontalAlignment','center','String','Cluster 2','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',SpikeSortingWindow,'Position', [1120 460 70 20],'String','Submit','FontSize',11,'FontWeight','bold','callback',@ S_Submitbutton_top);
                uicontrol('Parent',SpikeSortingWindow,'Position', [1120 235 70 20],'String','Submit','FontSize',11,'FontWeight','bold','callback',@ S_Submitbutton_bottom);

                %Button-Area
                SortingPanel=uipanel('Parent',SpikeSortingWindow,'Units','pixels','Position',[10 500 590 100],'BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [15 73 100 20],'HorizontalAlignment','left','String', 'General:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);

                %Start Calculation
                uicontrol('Parent',SortingPanel,'Position',[490 5 80 20],'String','Start','FontSize',11,'FontWeight','bold','callback',@start_sorting);
                
                %Submit all Button
                uicontrol('Parent',SortingPanel,'Position',[490 25 80 20],'String','Submit all','FontSize',11,'FontWeight','bold','callback',@S_Submitbutton_all);

                %Apply Expectation Maximation Algorithm
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 70 170 20],'HorizontalAlignment','left','String','Expectation Maximation','FontSize',9,'Tag','S2_EM_GM','Value',1,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);

                %Apply EM k-means Algorithm
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 50 150 20],'HorizontalAlignment','left','String','EM k-means','FontSize',9,'Tag','S2_EM_k-means','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);

                
                % Shapes Window Dimension
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [385 45 80 20],'HorizontalAlignment','left','String', 'Window: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[465 38 50 30],'Tag','Sort_pretime','FontSize',8,'String',preti,'Value',1,'Style','popupmenu','callback',@recalculate);
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[520 38 50 30],'Tag','Sort_posttime','FontSize',8,'String',postti,'Value',1,'Style','popupmenu','callback',@recalculate);
        
                %Manual or automatic Features
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 30 150 20],'HorizontalAlignment','left','String','Manual Features','FontSize',9,'Tag','S2_manual','Value',0,'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);

                %FPCA Features
                uicontrol('Parent',SortingPanel,'Units','Pixels','Position',[270 10 150 20],'HorizontalAlignment','left','String','FPCA Features','FontSize',9,'Tag','S2_FPCA','Value',get(findobj('Tag','S_FPCA'),'value'),'Style','checkbox','BackgroundColor',[0.8 0.8 0.8]);
                
                %Feature-Area
                SortingFeaturePanel=uipanel('Parent',SpikeSortingWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor',[0.8 0.8 0.8],'Tag','SortingFeaturePanel');
                uicontrol('Parent',SortingFeaturePanel,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);

                SortingFeaturePanel2=uipanel('Parent',SpikeSortingWindow,'Units','pixels','Position',[600 500 590 100],'BackgroundColor',[0.8 0.8 0.8],'Tag','SortingFeaturePanel2');
                uicontrol('Parent',SortingFeaturePanel2,'Style', 'text','Position', [15 75 100 20],'HorizontalAlignment','left','String', 'Features:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',SortingFeaturePanel2,'Style', 'text','Position', [200 10 200 50],'HorizontalAlignment','left','String', 'FPCA Features','FontSize',18,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                
                %Cluster Number Selection
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [140 68 70 20],'HorizontalAlignment','left','String', 'Cluster Nr.:','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol ('Parent',SortingPanel,'Units','Pixels','Position', [220 71 30 20],'Tag','S2_K_Nr','HorizontalAlignment','right','FontSize',9,'Value',1,'String',0,'Style','edit');
                
                %Confidence in %
                uicontrol('Parent',SortingPanel,'Style', 'text','Position', [430 68 105 20],'HorizontalAlignment','left','String', 'Confidence in %','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol ('Parent',SortingPanel,'Units','Pixels','Position', [540 71 30 20],'Tag','confidence','HorizontalAlignment','right','FontSize',9,'Value',1,'String',0,'Style','edit');

                %Select-Button-Area
                S_SelectPanel = uipanel('Parent',SortingPanel,'Units','pixels','Position',[1 1 250 65],'BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',S_SelectPanel,'Style','text','Position', [13 40 150 20],'HorizontalAlignment','left','String','Select Cluster:','FontSize',11,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);

                uicontrol('Parent',S_SelectPanel,'Position', [15 13 80 20],'String','Select','FontSize',11,'FontWeight','bold','callback',@S_Sel);
                uicontrol('Parent',S_SelectPanel,'Position', [155 13 80 20],'String','Show','FontSize',11,'FontWeight','bold','callback',@S_ShowClass);
                
                %Electrode Selection
                uicontrol('Parent',S_SelectPanel,'Style', 'text','Position',[135 38 50 20],'HorizontalAlignment','left','String','Graph: ','FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8]);
                uicontrol('Parent',S_SelectPanel,'Units','Pixels','Position',[185 10 50 50],'Tag','S_Graph_choice','FontSize',8,'String',[{'Top'} {'Bottom'}],'Value',1,'Style','popupmenu','callback',@recalculate);


                %Automated Feature Selection 
                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [15 50 150 20],'HorizontalAlignment','left','Tag','S_F1','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [15 15 150 20],'HorizontalAlignment','left','Tag','S_F2','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [190 50 150 20],'HorizontalAlignment','left','Tag','S_F3','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [190 15 150 20],'HorizontalAlignment','left','Tag','S_F4','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [365 50 150 20],'HorizontalAlignment','left','Tag','S_F5','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

                uicontrol('Parent',SortingFeaturePanel,'Units','Pixels','Position', [365 15 150 20],'HorizontalAlignment','left','Tag','S_F6','FontSize',8,'String',V,'Value',1,'Style','popupmenu','Enable','on');

                %Shapes Graph of Cluster 1
                Spikeplot1 = subplot('Position',[0.55 0.47 0.44 0.28],'Parent',SpikeSortingWindow);
                axis([0 2 -100 50]);

                %Shapes Graph of Cluster 2
                Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28],'Parent',SpikeSortingWindow);
                axis([0 2 -100 50]);

                %Scatterplot
                Scatterplot = subplot('Position',[0.05 0.09 0.44 0.66],'Parent',SpikeSortingWindow);  
                Window = 1;
                
                set(findobj('Tag','Sort_pretime'),'value',(get(findobj('Tag','S_pretime'),'value')));
                set(findobj('Tag','Sort_posttime'),'value',(get(findobj('Tag','S_posttime'),'value')));
            else
                SpikeSortingWindow = findobj('Tag','SpikeSortingWindow');
            end
            
            if get(findobj('Tag','S2_FPCA'),'value')== 0
               set(findobj('Tag','SortingFeaturePanel'),'Visible','on');
               set(findobj('Tag','SortingFeaturePanel2'),'Visible','off');
            else
               set(findobj('Tag','SortingFeaturePanel'),'Visible','off');
               set(findobj('Tag','SortingFeaturePanel2'),'Visible','on');
            end
               
            set(findobj('Tag','S2_K_Nr'),'String',k);
            set(findobj('Tag','S_K_Nr','parent',t6),'string',k);
            
            %Shapes Graphen
            ST = (-pretime:1000/SaRa:posttime);
            MAX1D = max(Shapes(:,Elektrode,:));
            Max(1) = max(MAX1D);
            MIN1D = min(Shapes(:,Elektrode,:));
            Min(1) = min(MIN1D);

            if get(findobj('Tag','S2_FPCA'),'value') == 0
               if SubmitSorting(Elektrode) >= 1
                  SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
               else
                  SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
               end
            else
               SPIKES3D_temp = []; 
               SPIKES3D_temp(:,1,:) = SPIKES_FPCA; 
            end

            Shapes_temp = Shapes(:,Elektrode,:);

            for i=2:(size(SPIKES3D_temp,3))

                MIN1D = min(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)); 
                MAX1D = max(SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1,1)),1),1,i)); 
                if size(MIN1D) ~= 0
                    Min(i) = min(MIN1D);
                else
                    Min(i)=0;
                end
                if size(MAX1D) ~= 0
                    Max(i) = max(MAX1D);
                else
                    Max(i)=0;
                end
            end
            clear MAX1D MIN1D;

            XX1=[];
            XX2=[];

            %Plot Spike Clusters
            XX1(:,:) = Shapes_temp(Class == 1,1,:); %Shapes muss auf 2D runtergestuft werden, da ansonsten Fehler bei plot "(:,Elektrode,:)"!!!
            XX2(:,:) = Shapes_temp(Class == 2,1,:); 
            Spike_Cluster = (mean(min(XX1,[],2))<= (mean(min(XX2,[],2))));

            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [850 455 70 20],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor',[0.8 0.8 0.8]); 
            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 455 70 20],'HorizontalAlignment','left','String',size(XX1,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor',[0.8 0.8 0.8]);

            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [850 230 70 20],'HorizontalAlignment','left','String','Spikes:','FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor',[0.8 0.8 0.8]); 
            uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 230 70 20],'HorizontalAlignment','left','String',size(XX2,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor',[0.8 0.8 0.8]);

            waitbar(1,w,'Done');
            close(w); 
            
            figure(SpikeSortingWindow); % sets current figure
            
            Spikeplot1 = subplot('Position',[0.55 0.47 0.44 0.28],'Parent',SpikeSortingWindow,'replace');
            
            Spikeplot1 = plot(ST,XX1,'Parent',Spikeplot1); 
            axis(gca,[ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            ylabel({'Voltage / µV'});
            Spkplot1 = 1; % storage of displayed Cluster Number


            Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28],'Parent',SpikeSortingWindow,'replace');

            Spikeplot2 = plot(ST,XX2,'Parent',Spikeplot2); 
            axis(gca,[ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            xlabel (gca,'time / ms');
            ylabel(gca,{'Voltage / µV'});
            Spkplot2 = 2; % storage of displayed Cluster Number


            XX1=[];
            XX2=[];
            
            if get(findobj('Tag','S2_FPCA'),'value') == 0
               for i = 1:6     % correct Feature selection         
                   set(findobj('Tag',char(F(i))),'value',1);
                   if i <= size(check,2) 
                      set(findobj('Tag',char(F(i))),'value',check(i));
                   end
               end
            end
                

           %Scatterplot 
           X(:,1:2)=SPIKES3D_temp(1:size(nonzeros(SPIKES3D_temp(:,1)),1),1,[(check(1)) (check(2))]); 
           
           Scatterplot = subplot('Position',[0.05 0.09 0.44 0.66],'Parent',SpikeSortingWindow,'replace');  

           for i=1:max(Class)
               Scatterplot = scatter(X(Class==i,1),X(Class==i,2),18,'filled');
               hold on
           end
           if get(findobj('Tag','S2_FPCA'),'value') == 0 
              axis(gca,[Min(check(1)) Max(check(1)) Min(check(2)) Max(check(2))]); % richtig so, da +1 und -1 durch Max(i) und F(i) sich aufheben
              xlabel (gca,char(units(check(1)-1)));
              ylabel(gca,char(units(check(2)-1)));
           else
              axis(gca,[min(SPIKES3D_temp(:,1)) max(SPIKES3D_temp(:,1)) min(SPIKES3D_temp(:,2)) max(SPIKES3D_temp(:,2))]); 
              xlabel (gca,'Scalar');
              ylabel(gca,'Scalar');
           end
           hold off
           toc
        end
        
        function S_Sel(~,~)
            dc_obj = datacursormode(findobj('Tag','SpikeSortingWindow'));
            set(dc_obj,'DisplayStyle','datatip',...
               'SnapToDataVertex','on','Enable','on','UpdateFcn',@LineT);
        end

        function [txt] = LineT (~,~)
            dc_obj = datacursormode(findobj('Tag','SpikeSortingWindow'));
            c_inf = getCursorInfo(dc_obj);
            Spike1 = find(SPIKES3D_temp(:,1,check(1))==c_inf(1).Position(1)); 
            Spike2 = find(SPIKES3D_temp(:,1,check(2))==c_inf(1).Position(2));
            for i=1:size(Spike1,1)
                Spike = find(Spike1(i) == Spike2);
                if Spike > 0
                    break;
                end
            end
            Spike = Spike2(Spike);
            txt = [{num2str(Spike)} {SPIKES3D_temp(Spike,1,check(1))} {SPIKES3D_temp(Spike,1,check(2))}];
            datacursormode off; 
        end

        function S_ShowClass (~,~)
            
            Elektrode = get(findobj('Tag','S_Elektrodenauswahl'),'value');
            SpikeSortingWindow = findobj('Tag','SpikeSortingWindow');
            XX=[]; % Bereinigung der Arbeitsvariablen XX
            if size(Class,1)==0
               Class(1:size(nonzeros(SPIKES(:,Elektrode)),1),1)= zeros;
            end	
            XX(:,:)=Shapes((Class==Class(Spike)),Elektrode,:);
            if get(findobj('Tag','S_Graph_choice'),'value') == 1
               Spikeplot1 = subplot('Position',[0.55 0.47 0.44 0.28]);
               uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 455 70 20],'HorizontalAlignment','left','String',size(XX,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor',[0.8 0.8 0.8]);
               Spkplot1 = Class(Spike); % storage of displayed Cluster Number
            else
               Spikeplot2 = subplot('Position',[0.55 0.09 0.44 0.28]);
               uicontrol('Parent',SpikeSortingWindow,'Style', 'text','Position', [925 230 70 20],'HorizontalAlignment','left','String',size(XX,1),'FontSize',10,'FontWeight','bold','ForegroundColor','black','BackgroundColor',[0.8 0.8 0.8]);
               Spkplot2 = Class(Spike); % storage of displayed Cluster Number
               xlabel ('time / ms');
            end
            Spikeplot = plot(ST,XX); 
            axis([ST(1) ST(size(ST,2)) Min(1) Max(1)]);
            ylabel({'Voltage / µV'});
            
            if get(findobj('Tag','S_Graph_choice'),'value') == 2
               xlabel ('time / ms');
            end

            XX=[]; % Damit ShowSpike problemlos funktioniert!
            
        end
        
        function S_Submitbutton_top(~,~) % detector function for top Submit button
            
            all = 0;
            spikes = Spkplot1;
            S_Submit;
        end
        
        function S_Submitbutton_bottom(~,~)  % detector function for bottom Submit button
            
            all = 0;
            spikes = Spkplot2;
            S_Submit;
        end
        
        function S_Submitbutton_all(~,~)
            
            all = 1;
            S_Submit;
        end
        
        function S_Submit(~,~) % extra Submit function for Sorting to reduce complexity
            
            set(findobj('Tag','S_K_Nr','parent',t6),'String',0);
            set(findobj('Tag','S2_K_Nr'),'String',0);
            n = Elektrode;
            submit_data = 1;
           
            
            if SubmitSorting(Elektrode) >= 1 && size(SPIKES3D_discard,1) >= 1 % overwrite SPIKES3D_temp to initialize Submit function correctly
                 SPIKES3D_temp = SPIKES3D_discard(1:size(nonzeros(SPIKES3D_discard(:,1,1)),1),1,:);
            else
               SPIKES3D_temp = SPIKES3D(1:size(nonzeros(SPIKES3D(:,Elektrode,1)),1),Elektrode,:);
            end
            
            if SubmitSorting(Elektrode) == 0
               NR_SPIKES_temp = 0;
            else
                NR_SPIKES_temp = NR_SPIKES_Sorted(1,n);
            end
            
            NR_SPIKES_Sorted(1,1:size(SPIKES,2)) = NR_SPIKES;
            NR_BURSTS_Sorted(1,1:size(SPIKES,2)) = NR_BURSTS;
            NR_SPIKES_Sorted(1,n)=  NR_SPIKES_temp;
            clear  NR_SPIKES_temp;
            
            if all
               if SubmitSorting(Elektrode) == 0
                   
                  if size(SPIKES_Class,1)~= 0 && size(SPIKES_Class,2)>= n
                     SPIKES_Class = []; % reset the data Array if sorted Elektrode is sorted again
                  end 
                   
                  SPIKES_Class(:,n,1) = SPIKES(:,n);
                  SPIKES_Class(1:size(Class,1),n,2) = Class(:);
                  SPIKES_NEW = SPIKES(:,n);
                  NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
                 
                  SPIKES3D_discard = [];
                  SPIKES3D_OLD = [];
                  SPIKES_OLD = [];
                  
                  M_old(:,1) =M(:,Elektrode); % clear original Signal of the Electrode at the first Submission
                  M(:,Elektrode) = zeros;
                  
               else
                  SPIKES3D_NEW(:,n,:) = SPIKES3D_temp(:,1,:);
                  SPIKES_NEW(:,1) = SPIKES3D_temp(:,1,1);
                  SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = zeros;
                  SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = zeros;
                  SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = SPIKES3D_NEW(:,n,:);
                  SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = SPIKES_NEW(:,1);

                  X_temp(:,:) = SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:);
                  SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n)= sortrows(SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n),1);
                  Size = size(SPIKES_Class,1);
                  SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,1) = SPIKES3D_NEW(:,n,1);
                  SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,2) =SubmitSorting(Elektrode)+Class(1:size(SPIKES3D_NEW(:,n,1),1));
                  clear Size;

               end
               
               
               
               for i= 1:max(Class)
                   NR_SPIKES_Sorted(SubmitSorting(Elektrode)+i,n) = size(SPIKES_NEW(Class==i),1);
                   NR_BURSTS_Sorted(SubmitSorting(Elektrode)+i,n) = 0;
               end
               
               SubmitSorting(Elektrode) = max(Class)+SubmitSorting(Elektrode);
               
               Class = [];
               Class(1:size(nonzeros(SPIKES(:,n)),1),1) = 1;
              

            else
                if SubmitSorting(Elektrode) == 0
                   SPIKES3D_discard = [];
                   SPIKES3D_OLD = [];
                   SPIKES_OLD = [];
                   SPIKES3D_OLD = SPIKES3D;
                   SPIKES_OLD = SPIKES3D(:,:,1);
                   SPIKES3D_NEW(:,n,:) = SPIKES3D_temp((Class == spikes),1,:);
                   SPIKES_NEW(:,1) = SPIKES3D_temp((Class == spikes),1,1);
                   SPIKES3D_discard(1:size(SPIKES3D_temp(Class ~= spikes),1),1,:) = SPIKES3D_temp((Class ~= spikes),1,:);
                   SPIKES3D = [];
                   SPIKES = [];

                   if size(SPIKES_Class,1)~= 0 && size(SPIKES_Class,2)>= n
                      SPIKES_Class(:,n,:)= zeros; % reset the data Array if sorted Elektrode is sorted again
                   end

                   s = size(SPIKES3D_OLD,1);

                   if s > size(SPIKES3D_OLD(:,n,:),1)
                      SPIKES3D = SPIKES3D_OLD(1:s,:,:);
                      SPIKES = SPIKES_OLD(1:s,:);
                   else
                      for i=1:size(SPIKES3D_OLD,2)
                          I(i) = size(nonzeros(SPIKES3D_OLD(:,i,1)),1);
                          if i == n
                             I(i) = 0;
                          end
                      end
                      I(1) = max(I);
                      if size(SPIKES3D_NEW,1)> I(1)
                         SPIKES3D = SPIKES3D_OLD(1:size(SPIKES3D_NEW,1),:,:);
                         SPIKES = SPIKES_OLD(1:size(SPIKES_NEW,1),:);
                      else
                         SPIKES3D = SPIKES3D_OLD(1:I(1),:,:);
                         SPIKES = SPIKES_OLD(1:I(1),:);
                      end
                   end
                   SPIKES3D(:,n,:) = zeros; 
                   SPIKES3D(1:size(SPIKES3D_NEW,1),n,:) = SPIKES3D_NEW(:,n,:);
                   SPIKES_NEW = SPIKES3D_NEW(:,n,1);
                   SPIKES_Class(1:size(SPIKES3D_NEW(:,n,1),1),n,1) = SPIKES3D_NEW(:,n,1);
                   SPIKES_Class(1:size(SPIKES3D_NEW(:,n,1),1),n,2) = SubmitSorting(Elektrode)+1;
                   SPIKES3D_NEW = []; 
                   SPIKES3D_OLD = [];

                   SPIKES(:,n) = zeros; 
                   SPIKES(1:size(SPIKES_NEW,1),n) = SPIKES_NEW(:,1);
                   NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
                   Class = [];
                   Class(1:size(nonzeros(SPIKES(:,n)),1),1) = 1;

                   M_old(:,1) =M(:,Elektrode); % clear original Signal of the Electrode at the first Submission
                   M(:,Elektrode) = zeros;

                else
                    
                   SPIKES3D_discard = [];
                   SPIKES3D_discard(1:size(SPIKES3D_temp(Class ~= spikes),1),1,:) = SPIKES3D_temp((Class ~= spikes),1,:);
                   SPIKES3D_NEW(:,n,:) = SPIKES3D_temp((Class == spikes),1,:);
                   SPIKES_NEW(:,1) = SPIKES3D_temp((Class == spikes),1,1);
                   SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = zeros;
                   SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = zeros;
                   SPIKES3D(size(nonzeros(SPIKES3D(:,n,1)),1)+1:(size(nonzeros(SPIKES3D(:,n,1)),1)+ size(SPIKES3D_NEW(:,n,1),1)),n,:) = SPIKES3D_NEW(:,n,:);
                   SPIKES(size(nonzeros(SPIKES(:,n)),1)+1:(size(nonzeros(SPIKES(:,n)),1)+size(SPIKES3D_NEW(:,n,1),1)),n) = SPIKES_NEW(:,1);

                   X_temp(:,:) = SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:);
                   X_temp = sortrows(X_temp,1);
                   SPIKES3D(1:size(nonzeros(SPIKES3D(:,n,1)),1),n,:)= X_temp;
                   SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n)= sortrows(SPIKES(1:size(nonzeros(SPIKES(:,n)),1),n),1);
                   Size = size(SPIKES_Class,1);
                   SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,1) = SPIKES3D_NEW(:,n,1);
                   SPIKES_Class(Size+1:(Size+size(SPIKES3D_NEW(:,n,1),1)),n,2) = SubmitSorting(Elektrode)+1;
                   clear Size;

                end
                
                NR_SPIKES(n) = size(nonzeros(SPIKES(:,n)),1);
                NR_SPIKES_Sorted(SubmitSorting(Elektrode)+1,n) = size(SPIKES_NEW(:,1),1);
                NR_BURSTS_Sorted(SubmitSorting(Elektrode)+1,n) = 0;
                SubmitSorting(Elektrode) = SubmitSorting(Elektrode) + 1; % Parameter to show how many Clusters have already been submitted 
                            
            end

            set(findobj('Tag','radio_allinone'),'value',0)
            set(findobj('Tag','radio_fouralltime'),'value',1)
            Viewselect = 0;
            n = Elektrode;
            pretime = 0.5;
            posttime = 0.5;
            SPI =SPIKES_NEW*SaRa;
            SPI1=nonzeros(SPI(:,1));

            for i=1:size(SPI1,1)
                if ((SPI1(i)+1+floor(SaRa*posttime/1000))<= size(M,1))&& ((SPI1(i)+1-ceil(SaRa*pretime/1000)) >= 0) % test if 
                   M(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),n) = M_old(SPI1(i)+1-floor(SaRa*pretime/1000):SPI1(i)+1+ceil(SaRa*posttime/1000),1); % Shapes variabler Länge
                end
            end

            BURSTS(:,n) = zeros;
            NR_BURSTS(n) = 0;
            
            clear SPIKES3D_NEW SPIKES3D_OLD s spikes SPIKES_NEW SPIKES_OLD X_temp;
            SPIKES3D_temp = [];
            redrawdecide;
            
            if all
               SpikeSortingWindow = findobj('Tag','SpikeSortingWindow');
               close(SpikeSortingWindow);
            else
               start_sorting;
            end
        end
    end

%----ENDE Spike Sorting---------------
%######################################################################## 

% -------------------- Burst and SBE Analysis after SPike Refinement (RB)-------------------------------

    function Re_Burst(~,~)
        
        h_wait_Burst = waitbar(.05,'Please wait - Burst detection in progress...');
        SIB = zeros(1,nr_channel);
        BURSTS = zeros(1,size(SPIKES,2));                                   % Leere Vektoren...
        SPIKES_IN_BURSTS = zeros(1,size(SPIKES,2));                         % ...erstellen
        BURSTDUR = zeros(1,size(SPIKES,2));
        IBIstd = zeros(1,size(SPIKES,2));
        IBImean = zeros(1,size(SPIKES,2));
        NR_BURSTS = zeros(1,size(SPIKES,2));
        meanburstduration = zeros(1,size(SPIKES,2));
        STDburst = zeros(1,size(SPIKES,2));
            
        CohenKappa;
        waitbar(.35,h_wait_Burst,'Please wait - Burst detection in progress...')

        if cellselect ~= 0  %nur für Neurone
            Burstdetection;          
        end

        waitbar(.65,h_wait_Burst,'Please wait - SBE analysis in progress...')
        if nr_channel>1
           SBEdetection;
        end
        waitbar(.95,h_wait_Burst,'Please wait - SBE analysis in progress...')
        if Viewselect == 0
           redraw;
        elseif Viewselect == 1
           redraw_allinone;
        end
        waitbar(1,h_wait_Burst,'Done.'), close(h_wait_Burst);   

    end
    
%----ENDE Burst and SBE Analysis after SPike Refinement ---------------
%######################################################################## 

    %Funktionen - Tab Export
    %----------------------------------------------------------------------

    % --- Export xls-Button (CN)-------------------------------------------
    function safexlsButtonCallback(source,event)  %#ok<INUSD>
       
        title = [full_path(1:(length(full_path)-4)),'.xls'];  % Name und Pfad der xls-Export-Datei

        if (length(nonzeros(SI_EVENTS)) >= 5)
            for n=1:(length(SI_EVENTS)-1)                % Die Abstände der parallelen Events in DELAYS speichern.
                DELAYS(n) = SI_EVENTS(n+1)-SI_EVENTS(n); %#ok<AGROW>
            end
            si_events_per_min = 60/mean(DELAYS);         % Aus den Abständen die Events/Minute berechnen (Mittelwert)
            std_dev_si_events_per_min = std(60./DELAYS); % Standardabweichung des Mittelwerts berechnen

            n = length(DELAYS)-1;                        % n entspricht der "Anzahl der Stichproben" minus 1

            % Lookup-Table für die t-Verteilung des 95%-Vertrauensbereichs:
            ttable95 = [12.71   4.303 3.182	2.776 2.571	2.447 2.365	2.306 2.262	2.228...
                2.201 2.179 2.16  2.145	2.131 2.12	2.11  2.101	2.093 2.086...
                2.08  2.074	2.069 2.064 2.06  2.056	2.052 2.048	2.045 2.042...
                2.021 2.009	2.00  1.99	1.984 1.98	1.96];

            if n<30                             % Den passemden Wert für die Anzahl der Stichproben...
                t=ttable95(n-1);                % ...aus der Lookup-Table holen.
                elseif n<40; t=ttable95(30);
                elseif n<50; t=ttable95(31);
                elseif n<60; t=ttable95(32);
                elseif n<80; t=ttable95(33);
                elseif n<100; t=ttable95(34);
                elseif n<120; t=ttable95(35);
                elseif n==120; t=ttable95(36);
                elseif n>120; t=ttable95(37);
            end

            dev95 = t*std_dev_si_events_per_min/sqrt(length(DELAYS));           % 95%-Vertrauensbereich nach Formel...
            dev95_limits = [si_events_per_min-dev95 dev95+si_events_per_min];   % ...berechnen.
        
        else    
            si_events_per_min = 0;
            std_dev_si_events_per_min = 0;
            dev95_limits(1) = 0;                        %Vertrauensbereich
            dev95_limits(2) = 0;                        %Grenzen des VB    
        end
        
        % Hier beginnt der eigentliche EXCEL_export...
       if (get(findobj(gcf,'Tag','CELL_exportAllCheckbox'),'value'))
                 i = 16;
            else i = 12;
       end

        [filename, pathname] = uiputfile ('*.xls','save as...',title);
        if filename==0, return,end

        h = waitbar(0,'please wait, save data...');
         waitbar(0.2/i)
         xlswrite([pathname filename], {full_path}, 'Tabelle1','A2');
         xlswrite([pathname filename], fileinfo{1}, 'Tabelle1','A3');
         
         waitbar(0.5/i);
         COLUMN_A = cell(25,1);
         COLUMN_A(1) = {'Duration of recording [s]'};
         COLUMN_A(2) = {'Mean number of events per minute'};
         COLUMN_A(3) = {'95%-confidence interval'};
         COLUMN_A(4) = {'Standard deviation (STD)'};
         COLUMN_A(5) = {'Mean number of spikes/burst'};       
         COLUMN_A(6) = {'Burst-duration (mean of all bursts)[s]'};       
         COLUMN_A(7) = {'STD burst-duration (mean of all bursts)'};
         COLUMN_A(8) = {'InterBurstInterval (mean of all bursts)[s]'};       
         COLUMN_A(9) = {'STD IBI (mean of all bursts)'};
         COLUMN_A(10) = {'Number SBEs'};
         COLUMN_A(11) = {'Mean SNR [dB]'};
         COLUMN_A(12) = {''};
         COLUMN_A(13) = {'Electrode'};
         COLUMN_A(14) = {'Threshold [uV]'};
         COLUMN_A(15) = {'Number of Spikes'};
         COLUMN_A(16) = {'Number of Bursts'};
         COLUMN_A(17) = {'Burstrate [burst per second]'};
         COLUMN_A(18) = {'Mean spikes per burst'};
         COLUMN_A(19) = {'Mean burst-duration [s]'};
         COLUMN_A(20) = {'STD burst-duration'};
         COLUMN_A(21) = {'Mean IBI [s]'};
         COLUMN_A(22) = {'STD IBI'};         
         COLUMN_A(23) = {'Signal-to-Noise Ratio'};
         COLUMN_A(24) = {'Signal-to-Noise Ratio [dB]'};
         COLUMN_A(25) = {'Timestamps SBEs'};
         COLUMN_A(26) = {'Beginnings of stimulation'};
         COLUMN_A(27) = {'Endings of stimulation'};
         
         waitbar(1/i);
         
         COLUMN_B = cell(11,1);
         COLUMN_B(1) = {rec_dur};
         COLUMN_B(2) = {si_events_per_min};
         COLUMN_B(3) = {dev95_limits(1)};
         COLUMN_B(4) = {std_dev_si_events_per_min};
         COLUMN_B(5) = {Mean_SIB};
         COLUMN_B(6) = {MBDae};
         COLUMN_B(7) = {STDburstae};
         COLUMN_B(8) = {aeIBImean};
         COLUMN_B(9) = {aeIBIstd};
         COLUMN_B(10) = {Nr_SI_EVENTS};
         COLUMN_B(11) = {Mean_SNR_dB};         
         
         DATAarray = cat(1,THRESHOLDS,NR_SPIKES,NR_BURSTS,NR_BURSTS./rec_dur,SIB,meanburstduration,STDburst,IBImean,IBIstd,SNR,SNR_dB);    
                  
         xlswrite([pathname filename], COLUMN_A, 'Tabelle1','A6');
         xlswrite([pathname filename], COLUMN_B, 'Tabelle1','D6');
           
         waitbar(3/i);
         xlswrite([pathname filename], {'to...'}, 'Tabelle1','E8');
         waitbar(4/i);
         xlswrite([pathname filename], dev95_limits(2), 'Tabelle1','F8');
         waitbar(5/i);
         xlswrite([pathname filename], (EL_NAMES'), 'Tabelle1','D18');
         waitbar(6/i);
         xlswrite([pathname filename], DATAarray, 'Tabelle1','D19');
         waitbar(7/i);
         xlswrite([pathname filename], SI_EVENTS, 'Tabelle1','D30');
         xlswrite([pathname filename], BEG, 'Tabelle1','D31');
         xlswrite([pathname filename], END, 'Tabelle1','D32');

         waitbar(10/i);

         if i==16
             % Schreibe Überschrift für die Spikes in folgendes Feld
             d1=size(BURSTS,1);
             counter=36+d1;
             rowUEBER2 = num2str(counter);
             UEBER2title=strcat('A',rowUEBER2);
             % Schreibe obere linke Ecke des "Spikes"-Arrays in folgendes Feld
             xlswrite([pathname filename], {'Bursts (Timestamps)'}, 'Tabelle1','A34');
             xlswrite([pathname filename], (EL_NAMES'), 'Tabelle1','D34');
             xlswrite([pathname filename], BURSTS, 'Tabelle1','D35');
             waitbar(12/i);
             xlswrite([pathname filename], {'Spikes (Timestamps) are saved in worksheet 2'}, 'Tabelle1',UEBER2title);
             %Die Timestamps des Spikes werden in ein gesondertes Tabellenblatt geschrieben
             xlswrite([pathname filename], {'Spikes (Timestamps)'}, 'Tabelle2','A1');    
             xlswrite([pathname filename], (EL_NAMES'), 'Tabelle2','D1');
             xlswrite([pathname filename], SPIKES, 'Tabelle2','D2');
             waitbar(14/i);
         end

         % Überschrift erst jetzt schreiben, damit die Datei beim Öffnen in der obersten Zeile beginnt
         xlswrite([pathname filename], {'Summary of analysis'}, 'Tabelle1','A1'); 
         waitbar(i/i);
         close(h);
         
         % Datei gleich in Excel öffnen, wenn entsprechender Haken gesetzt
         if (get(findobj(gcf,'Tag','CELL_showExportCheckbox'),'value'))
             winopen([pathname filename]);
         end
    end

    % --- Export des Netzwerkbursts Analyseergebnisses (CN)----------------
    function ExportNWBCallback(source,event) %#ok 
         [filename, pathname] = uiputfile('*.xls','Speichern unter...', 'Auswertung');
         if filename==0, return,end 
         
         row_1 = cell(1,numberfiles);

         if numberfiles == 1
                 row_1(1) = {file};  
         else
             for r=1:numberfiles   
                row_1(r) = {file{r}};
             end
         end
h_wait=waitbar(0.05,'exporting data...');
waitbar(0.15)

         line_1 = cell(1,7);
         line_1(1) = {'Messung'};
         line_1(2) = {'Mittelwert steigende Flanke'};
         line_1(3) = {'STD steigende Flanke'};
         line_1(4) = {'Mittelwert fallende Flanke'};
         line_1(5) = {'STD fallende Flanke'};
         line_1(6) = {'Mittelwert Dauer'};
         line_1(7) = {'STD Dauer'};
waitbar(0.25)
        if numberfiles ==1
         NWBdata = cat(1,row_1',Meanrise',stdMeanRise',Meanfall',stdMeanFall',MeanDuration',stdMeanDuration');          
         xlswrite([pathname filename], line_1, 'Tabelle1','A1');
         xlswrite([pathname filename], NWBdata', 'Tabelle1','A2');
        else
        xlswrite([pathname filename], line_1, 'Tabelle1','A1');
        xlswrite([pathname filename], row_1', 'Tabelle1','A2');
        xlswrite([pathname filename], Meanrise', 'Tabelle1','B2');
        xlswrite([pathname filename], stdMeanRise', 'Tabelle1','C2');
        waitbar(0.35)
        xlswrite([pathname filename], Meanfall', 'Tabelle1','D2');
        xlswrite([pathname filename], stdMeanFall', 'Tabelle1','E2');
        xlswrite([pathname filename], MeanDuration', 'Tabelle1','F2');
        xlswrite([pathname filename], stdMeanDuration', 'Tabelle1','G2');
        end
                         
waitbar(0.5)
waitbaradd = 0.5;

         count = 1;
         
         if iscell(ORDER) == 1
            if isempty(ORDER{1}) ~= 0
            else
                for n=1:size(ORDER,2)                  %gehe jeden Netzwerkburst durch
                	El = strcat('A',(num2str(count)));
                    Time = strcat('A',(num2str(count+1)));
                    xlswrite([pathname filename], ORDER(:,n)', 'Tabelle2',El);     
                    xlswrite([pathname filename], BURSTTIME(:,n)', 'Tabelle2',Time);     
                    count=count+3;
                    waitbaradd = waitbaradd + (0.45/size(ORDER,2));
                    waitbar(waitbaradd) 
                end
            end
         end
         
        waitbar(1,h_wait,'Complete.'); close(h_wait);
end




%%%%%% Änderungen ab Version 1.03
%--------------------------------------------------------------------------
%MG = Michael Goldhammer
%CN = Christoph Nick
%AD = Andreas Daus
%MH = Mathias Hasenkopf
%TA = Timo Arend
%FS = Frederik Steger
%RB = Robert Bestel

% Datum    % Name    % Änderung

%14.11.2009 - CN - Die Anzahl der aufgenommenen Kanäle wird
%gesucht, indem 61 Elemente der dritte Spalten des Rohfiles eingelesen werden, 
%wobei der erste Element ('time') nicht mitgerechnet wird. Dies bedeutet, 
%dass bei 60 eingelesenene Elektroden alle Elektrodennamen plus 'ms, das bereits in der nächsten Spalte steht,
%eingelesen wird. Werden weniger Elektroden eingelesen so wird entsprechend
%mehr eingelesen. In diesem Array wird die Position von 'ms' gesucht. 
%Diese Position-1 entspricht gerade der Anzahl der Elektroden.

%16.11.2009 - CN - Die Samplerate wird nicht mehr aus dem
%Timearray berechnet, sondern aus dem file eingelesen. Dabei wird
%vorausgesetzt, dass die Samplerate das dritte "Wort" in der zweiten Zeile
%des Rohfiles ist.

%17.11.2009 - CN - Die Burstdetektion und die Detektion der
%SBEs wurde in zwei Funktionen extrahiert, um diese Funktionen sowohl bei
%Rohdaten alsauch bei Spiketraindaten leicht aufrufen zu können.

%18.11.2009 - CN - Wird eine Spiketrain eingelesen so wird jeder
%Spike als ein vertikaler Strich dargestellt. Das Array "SPIKES" steht nach dem Einlesen
%sofort zu Verfügung. Die Bursts und SBEs allerdings erst nach der
%Analyse. Funktionen wie Spiketrain, Rasterplot und Netzwerkbursts
%funktionieren auch mit Spiketraindaten. Alle anderen Funktionen werden
%disabled und können daher nicht aufgerufen werden.

%20.11.2009 - CN - Für den Export von Spiketrains werden einige
%Variablen wie z.B. SNR auf Null gesetzt, da diese nicht berechnet werden
%können.

%13.01.2010 - CN - Für die Fälle, dass weniger als 4 Elektroden
%aufgebommen wurden, mussten Fallunterscheidungen eingefügt werden, damit
%die Scrollbar nicht mehr auf die Werte zurückgreifen will, da es keine
%Scrollbar mehr gibt.

%26.01.2010 - CN - Das Panel fileinfo wurde eingefügt, in dem
%z.B. die Zeit, Datum, Aufnahmedauer, Anzahl der Elektroden etc. angezeigt
%wird. Dr. Cell wurde auf Version 1.04 geändert.

%28.01.2010 - AD - Funktion "Ausnullen" überarbeitet. 

%28.01.2010 - AD - Parameter der Spike und Burstdetektion geändert.
%(maximale Intervalle innerhalb eines Bursts nach Kujawski [Tam 2002]) geändert.

%29.01.2010 - CN - Die Import-funktion wurde überarbeitet. Über eine
%Funktion können Rawdaten(sowohl punktsepariert alsauch kommasepariert) 
%und Spiketraindaten eingelesen werden. Für die Unterscheidung: 
%Punktsepariert steht "Raw" im Header, Kommasepariert steht nichts im 
%Header, Spiketrain steht "Spiketrain" im Header. Falls etwas ganz anderes
%im Header steht, kommt eine Warnung.

%17.02.2010 - CN - die Funktion Cohens Kappa wurde geschrieben, mit der
%der Mittelwert von Kappa von allen Elektroden mit mind. 50Spikes pro Minute 
%berechnet und bei der Crosscorelation angezeigt wird. Maximal kann der Wert
%1 werden - je höher, desto gleichzeitiger kommen die Signale (z.B. bei Bic)

%20.02.2010 - AD - Dr_Cell goes Mac ;-)
% Dr_Cell für Mac OS X angepasst
% Fehler in der Beating-Rate-Funktion behoben

%25.03.2010 - TA - Spike Sorting wurde eingebunden

%10.05.2010 - AD - variabler Threshold
% Um eine Tiefpassfilterung zu umgehen wurde eine variabler
% Thresholdfunktion implementiert, die sich das niederfrequente Nachschwingen nach Bursts berücksichtig. 
% Berechung des offsets nun über Median

%18.05.2010 -RB - verbesserte Timestamp Ermittlung
%Der Algorithmus überprüft sämtliche gefundenen Spikes auf Einhaltung der 
%Refraktärzeit. Wird diese verletzt wird der minimale Spannungswert im 
%betroffenen Intervall gesucht und dessen Timestamp gespeichert. Alle 
%anderen gefundenen Spikes im Intervall werden vernachlässigt und gelöscht.
%betroffene Variable: SPIKES

%27.05.2010 - FS
% Spike-Overlay
%   - Umordnung der Paneele
%   - y-Skala-Button eingefügt
%   - Lock-View-Buttons eingebaut (frag nicht nach Sonnenschein)
%   - Delete-Buttons eingefügt
%   - Automatische Bestimmung der Perioden 1 und 2 eingebaut (Perioden
%   jeweils zwischen Maximum1-Minimum-Maximum2 des Signals
% Eventtracing
%   - Errorbeseitigung "First 20 Spikes", falls keine 20 vorhanden sind
%   - Dynamische Anzeige der Spikeauswahl (es werden nur die Spikes
%   angezeigt, die detektiert wurden. Nicht 20 als feste Anzahl
%   - Fehlerbehebung, falls nicht alle Kanäle aufgezeichnet wurden
%   - Problem des automatischen Interpolieren (für Var RI) behoben
%   (streicht
%   beim Interpolieren letzte Datenzeile, sollte ein NaN angrenzen
%   - Keine Interpolierung von Werten mit bereits interpolierten Werten
%   - Somit Ausblendung von Elektroden, sollte keine Interpolierung möglich
%   sein. (Fragmentbilder möglich)
%   - Mittelwertbildung bei fehlenden Spikes nur noch ab mindestens 2
%   angrenzenden aufgenommen Werten

%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
    
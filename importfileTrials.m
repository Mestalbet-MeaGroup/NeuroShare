
filepath='C:\CalciumImagingMEArecordings\10Jun2010\';
fileToRead1='RatioTable_4. CH22_centered_baseline-2.csv';
macpath='C:\NeuroShare\';
macro='ConvertTimeFormat.xlsm';

[~,~,raw] = xlsread([filepath fileToRead1]);
xlswrite([macpath macro],raw);
h = actxserver('Excel.Application');
Workbooks = h.Workbooks;
Workbook = invoke(Workbooks, 'Open', [macpath macro]);
h.Visible = 1;
Application = Workbook.Application;
invoke(Application,'Run','ConvertTimeFormat');
[data,~,~] = xlsread([macpath macro]);
Workbook.Saved = 1;
Workbook.Close;
h.Quit;
h.delete;

% h = actxserver('Excel.Application');
% h.Visible = 1;
% Workbooks = h.Workbooks;
% Workbook = invoke(Workbooks, 'Open', [filepath fileToRead1]);
% sheets = Workbook.Sheets;
% sheet1 = sheets.Item(fileToRead1(1:31));
% range =  sheet1.get('Range', 'B3', 'B5');
% values=range.value;
% invoke(Application,'Run',['"' filepath fileToRead1 '!ConvertTimeFormat"']);

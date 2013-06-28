function DataFile = newParamLoading(paramfile,handles)
% Load Parameter File correcting for incompability on older Versions

load(paramfile);

if ~isempty(DataFile)

    DataFile.FileName = handles.DataFile.FileName;
    DataFile.OutPath = handles.DataFile.OutPath;
    DataFile.UEMWAFigure.FileName = handles.DataFile.UEMWAFigure.FileName;
    DataFile.SignFigure.FileName = handles.DataFile.SignFigure.FileName;

    % Update PVM Parameters
    if ~isfield(DataFile,'AllScratchesDir')
        PVMParams = load('PVMParameters_Update');
        DataFile.PVM = PVMParams.DataFile.PVM;
    end

end
function A = cssm(S,parent,level);
% Creates a variable containing an array with name, length, an data for input parameter
% Helper Function called by the helper function cssm2cell
%
% %%%%% Obligatory parameters: %%%%%
% A : <CELL of ARRAYs> get the answer from running the cssm function to
%     use it on cssm2cell.
% S : <STRUCT> data input 
% parent : <CELL of ARRAYs> gives the name of a component on s structure
%          and how long it is.
% level, i : <NUMERIC : DOUBLE> it acts as a loop counter
%
% %%%%% Optional parameters: none %%%%%
% Example of use:
% function A = cssm(S,parent,level);
% 
% Further comments:
% when applying numel(A) if result is less than 1, an empty variable is obtained.
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

if isstruct(S),
    level=level+1;
    A = fieldnames(S);
    for i=1:numel(A),
        if numel(A)>1;return;end
        if isstruct(S.(A{i})),
            parent=[A{i},'.',num2str(level)];
            S.(A{i});
            A = [A ; parent;cssm(S.(A{i}),parent,level)];
        end
    end
else
    A = [] ;
end

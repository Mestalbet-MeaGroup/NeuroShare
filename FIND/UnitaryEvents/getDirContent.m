function Names = getDirContent(Dir)
% getDirContent returns a strings cell Names containing the names of all
% files and directories within the directory Dir.

Names = squeeze(struct2cell(dir(Dir)));
Names(:,1:2) = [];  % remove the . and .. directories
Names(2:4,:) = [];  % remove other informations than names
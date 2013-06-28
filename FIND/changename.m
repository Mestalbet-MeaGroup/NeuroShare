% FOR DEVELOPERS ONLY!!!
% changename is a script to rename functions

%tauschliste aus datei einlesen
fid=fopen('namensliste.txt');
myline=0;
while 1
    tline=fgetl(fid)
    if ~ischar(tline),   break,   end
    myline=myline+1;
    semicolon=strfind(tline,';')
    tauschtabelle{myline,1}=tline(1:semicolon-1);
    tauschtabelle{myline,2}=tline((semicolon+1):end)
end
fclose(fid)

%der laenge nach sortieren

for ii = 1:size(tauschtabelle,1)
    laengen(ii,1)=length(tauschtabelle{ii,1});
    laengen(ii,2)=length(tauschtabelle{ii,2});
end
laengen(:,3)=1:ii;
laengen=sortrows(laengen);
laengen=flipud(laengen);
links=tauschtabelle(laengen(:,3),1);
rechts=tauschtabelle(laengen(:,3),2);
tauschtabelle=[links,rechts];

% datei einlesen
for dateipointer=1:size(tauschtabelle,1)
    fid=fopen(tauschtabelle{dateipointer,1});
%    disp(tauschtabelle{dateipointer,1})
    myline=0;
    getauscht={};
    while 1
        myline=myline+1;
        tline = fgetl(fid);
        if ~ischar(tline),   break,   end
        %ersetzen
 %       disp(tline)
        for originalpointer=1:size(tauschtabelle,1)
            tline=strrep(tline,tauschtabelle{originalpointer,1}(1:end-2),tauschtabelle{originalpointer,2}(1:end-2));
        end
        getauscht{myline}=tline;
    end
    fclose(fid);
  %  getauscht

    % datei schreiben
    fid=fopen(['../renametest/',tauschtabelle{dateipointer,2}],'w');
    for ii=1:myline-1
        fprintf(fid,'%s\n',getauscht{ii});
    end
    fclose(fid);
end

%end of changename
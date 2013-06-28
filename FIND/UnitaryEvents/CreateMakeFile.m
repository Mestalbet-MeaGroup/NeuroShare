function CreateMakeFile(scratchdirname,NWindows,WindowShift,NJobs,Priority,Randomize)

f = fopen('Makefile','w');

for j = 1:NJobs
    arrJob{j}=['job' num2str(j) ' '];
end
arrJob=strvcat(arrJob);

fprintf(f,'%s\n',['all: ' reshape(arrJob',1,prod(size(arrJob)))]);

switch Randomize

    case 'off'      % no balancing

        start = 1;
        adder = floor(NWindows/NJobs);
        rem   = mod(NWindows,NJobs);
        for i = 1:NJobs
            if i==NJobs
                if rem > 0
                    adder = adder + rem;
                end
            end
            for j = 1:adder
                arrNum(j) = start+(j-1)*WindowShift  ;
            end
            start = arrNum(floor(NWindows/NJobs)) + WindowShift;
            fprintf(f,'%s\n',[arrJob(i,:) ':']);
            fprintf(f,'\t%s\n',[ 'nice -n' num2str(Priority) ' ' getenv('PWD') '/runmatlab ' getenv('PWD') '/UEMainAnalyseWindow ' scratchdirname ' ' num2str(i) ' ' num2str(arrNum) ]);
            arrNum=[];
        end

    case 'on'       % balancing by randomizing windows
        
        wins_per_job = floor(NWindows/NJobs);
        nr_rem       = mod(NWindows,NJobs);
        permutation  = ((randperm(NWindows))*WindowShift)-(WindowShift-1);
        perm_matrix  = reshape(permutation(1:end-(nr_rem)),wins_per_job,NJobs)';
        remaining    = [];
        for i = 1:NJobs
            if isequal(i,NJobs)
                if nr_rem > 0
                    remaining = permutation(abs((nr_rem-1)-end):end);
                end
                last = [ perm_matrix(i,:) remaining ];
                fprintf(f,'%s\n',[arrJob(i,:) ':']);
                fprintf(f,'\t%s\n',[ 'nice -n' num2str(Priority) ' ' getenv('PWD') '/runmatlab ' getenv('PWD') '/UEMainAnalyseWindow ' scratchdirname ' ' num2str(i) ' ' num2str(last) ]);
            else
                fprintf(f,'%s\n',[arrJob(i,:) ':']);
                fprintf(f,'\t%s\n',[ 'nice -n' num2str(Priority) ' ' getenv('PWD') '/runmatlab ' getenv('PWD') '/UEMainAnalyseWindow ' scratchdirname ' ' num2str(i) ' ' num2str(perm_matrix(i,:))]);
            end
        end

end


fclose(f);

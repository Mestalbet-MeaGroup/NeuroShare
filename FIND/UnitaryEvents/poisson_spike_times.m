function spike_times= poisson_spike_times(length_trains,rate)

lambda=length_trains*rate/1000;
spike_count = poissrnd(lambda);
if spike_count>0
    spike_times=rand(1,spike_count)*length_trains/1000;
else
    spike_times=[];
end


close all;

blank_sig = zeros(1,40000).'; % second is 8192, pkts 2048 long, so 4 pkts per second, 2.5 seconds in sim

pps.time = [];
pps.signals.values = blank_sig;

start_pps = 30;

% determine periods involved
second = 8192; % fpga clocks per second
duration = 1; % on for 10 clocks

% create a vector of actual periods in the pps pulse
npulses = floor(length(blank_sig)/second)+1;
periods = second*ones(1,npulses); 

% create pps input signal, start at 30, end at 39
start_ind = start_pps;
stop_ind  = start_ind+duration-1;

for p = 1:length(periods)
    if stop_ind<length(blank_sig)
        pps.signals.values(start_ind:stop_ind) = 1;
    end
    start_ind = start_ind+periods(p);
    stop_ind  = start_ind+duration-1;
end


% set enable signal
enable.time = [];
enable.signals.values = blank_sig;
enable.signals.values(401:end)=1;
%enable.signals.values(401:10000)=1;
%enable.signals.values(20000:end)=1;

% make data
% 16 pieces of data per clock cycle
% initalize data0-data15 values
x.time = [];
x.signals.values = blank_sig;

% set data values to something, data stream 16 times the length of ind data
% data set to single pulse with pps timing, so data0 at each pulse is a 1
data_stream = repmat(blank_sig,16,1);
data_stream(start_pps*16:second*16:end)=1;

% limit data to 2 bit value
data_stream=mod(data_stream,4);

% distribute data_stream into the 16 matlab variables
d_stream = reshape(data_stream,16,length(data_stream)/16).';
for k=0:15
    x.signals.values = d_stream(:,k+1);
    eval(['data',num2str(k),'=x;'])
end

% set breakpoint, run simulation

% get data
x = [];
for k=0:15
    eval(['x = [x data_out',num2str(k),'.Data];'])
end
data_stream_out = reshape(x.',1,length(data_out0.Data)*16);


dt = 1/16;
ti = [1:length(data_stream)]*dt;
to = [1:length(data_stream_out)]*dt;
figure
hold all
stairs(ti,data_stream,'b')
stairs(to,data_stream_out,'r')
stairs(pps.signals.values,'k:')
stairs(sync_out.Data,'k:')
ylim([-1 2])
legend('input data','output data','pps in','pps out')
title('vdif: hdr block input and output timing, latency of 2 clocks ')
xlim([8220 8228])
xlabel('fpga clocks (16 data samples each clock)')


secs_ref_ep.Data(frame_out.Data==0)=0;
fnum.Data(frame_out.Data==0)=0;

figure
hold all
stairs(sync_out.Data/3,'k:')
x = find(sync_out.Data==1);
for k=1:length(x)
    text(x(k),1/3,'pps')
end

stairs(fnum.Data,'color',[0.5 0 0.5])
x = find(frame_out.Data==1);
for k=1:length(x)
    text(x(k),fnum.Data(x(k)),['f=',num2str(fnum.Data(x(k)))],'color',[.5 0 .5])
end

stairs(secs_ref_ep.Data,'color',[0 0.5 0])
for k=1:length(x)
    text(x(k),secs_ref_ep.Data(x(k))-.2,['s=',num2str(secs_ref_ep.Data(x(k)))],'color',[.5 0 .5])
end

stairs(frame_out.Data/2)
legend('pps out','frame num','secs since ref','start of frame')
xlim([0 40000])



% ()



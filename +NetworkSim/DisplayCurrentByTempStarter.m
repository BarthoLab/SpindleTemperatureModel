function DisplayCurrentByTempStarter(varargin)
    % DISPLAYCURRENTBYTEMPSTARTER - Settings for temperature dependence displays
    %   Runs <a href="matlab:help NetworkSim.DisplayCurrentByTemp">DisplayCurrentByTemp</a> with different parameters
    %   Every display and setting starts after a wait period (default 1000 ms)
    %   to reach steady state, times should be interpreteed after that
    %   Select display
    %       0 - TC cell default     
    %       1 - TC cell spike at 50
    %       2 - TC cell burst at 50 with 5 spike and 2ms spike interval
    %       3 - TC cell 400 long hiperpolarization after 50 delay with 0.1
    %       4 - TC cell 400 long hiperpolarization after 50 delay with 0.15
    %       5 - TC cell 400 long hiperpolarization after 50 delay with 0.20
    SelectedDisplay = 2;
    if(~isempty(varargin)); SelectedDisplay = varargin{1}; end;
    % Default settings
    settings.CellType = 1; % 1 = TC, 2 = nRT
    settings.Temperatures = 34:37;    
    settings.WaitPeriod = 4000;
    settings.Spikes = [];
    settings.StimDelay = 50;
    settings.StimLength = 200;
    settings.StimAmp = 0;
    settings.tstop = 1000;
    settings.v_init = -80;
    % Change settings to selected
    switch SelectedDisplay
        case 1
            settings.Spikes = 50;
            settings.StimAmp = 0;
        case 2
            settings.Spikes = 50:2.5:60;
            settings.StimAmp = 0;            
        case 3 
            settings.Spikes = [];
            settings.StimDelay = 50;
            settings.StimLength = 400;
            settings.StimAmp = -0.1;        
        case 4 
            settings.Spikes = [];
            settings.StimDelay = 50;
            settings.StimLength = 400;
            settings.StimAmp = -0.15;  
        case 5
            settings.Spikes = [];
            settings.StimDelay = 50;
            settings.StimLength = 400;
            settings.StimAmp = -0.2; 
    end
    % Run selected
    NetworkSim.DisplayCurrentByTemp(settings);
    
    % a = load('C:\Users\dburka\Dropbox\dburka\+NetworkSim\@Sim\stim_test2.txt'); figure; plot(a);
end
function result = CellStim(sim, CellType, spikes, varargin)       
    % CELLSTIM - Sets up cell stimulation test with <a href="matlab:type('NetworkSim\Help\hoclist\stimtest.txt')">stimtest.hoc</a>

    stimDelay = 0;
    stimLength = 0;
    stimAmp = 0;
    currentList = ListHandler();
    
    if(length(varargin) >= 3)
        stimDelay = varargin{1};
        stimLength = varargin{2};
        stimAmp = varargin{3};
        if(length(varargin) >= 4)
            currentList = varargin{4};
        end       
    end
    
    spikeThreshold = 0;
    % Burst detection
    if(~isempty(spikes))
        detectStart = spikes(1)/sim.dt;
    else
        detectStart = 1;
    end
    minSilenceBeforeBurst = 40;
    maxSilenceBetweenBurstSpikes = 10;
    minSpikesPerburst = 2;
    %----------------                   
    sim.simFileName = 'stimtest.hoc';
    sim.defaultCommand = strcat(sim.defaultCommand, [' -c "CellType=' num2str(CellType) '" ' ]);        
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "baseStimPotential=', num2str(sim.v_init), '" ');  
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "stimDelay=', num2str(stimDelay), '" ');
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "stimLength=', num2str(stimLength), '" ');
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "stimAmp=', num2str(stimAmp), '" ');  
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "objref ncVec" ');               
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "ncVec= new Vector(', num2str(length(spikes)), ')" ');
    for s = 1:length(spikes)
        sim.defaultCommand = strcat(sim.defaultCommand, ' -c "ncVec.x(', num2str(s-1), ')=', num2str(spikes(s)), '" ');
    end        
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "objref currentList" ');               
    sim.defaultCommand = strcat(sim.defaultCommand, ' -c "currentList = new List()" ');       
    for cID = 1:currentList.Length
        listValue = currentList.List(cID);
        if(isempty(strfind(listValue, 'Receptor')))
            listValue = [listValue '(0.5)'];
        end
        sim.defaultCommand = strcat(sim.defaultCommand, ' -c "{currentList.append(new String(\"', listValue,'\"))}" ');
    end
    
    % Simulation
    sim.Run();         
    a = load('stim_test.txt');  
            
    % Get other currents
    for i=1:currentList.Length
        result.Currents.(strrep(currentList.List(i), '.', '')) = a(:,i+1);
    end
    
    % Get main membrane potential
    a = a(:,1);    
    result.Potential = a;
    
    % Bursts    
    result.BurstStarts = NaN;
    result.SpikePerBurst = NaN;
    result.OnsetDelay = NaN;
    result.NbrOfSpikes = 0;
    burstStarts = ListHandler();
    spikePerBurst = ListHandler();
    silenceCounter = minSilenceBeforeBurst;
    for i=detectStart:length(a)
        if a(i) > spikeThreshold
            result.NbrOfSpikes = result.NbrOfSpikes + 1;
            if(silenceCounter >= minSilenceBeforeBurst)
                if(spikePerBurst.Length > 0 && spikePerBurst.List(end) < minSpikesPerburst)
                    burstStarts.Remove(burstStarts.Length);
                    spikePerBurst.Remove(spikePerBurst.Length);
                end
                burstStarts.Add(i*sim.dt);                
                spikePerBurst.Add(1);                                
            elseif(silenceCounter > 0 && ...
                   silenceCounter < maxSilenceBetweenBurstSpikes && ...
                   spikePerBurst.Length > 0)                    
                spikePerBurst.Modify(spikePerBurst.Length, spikePerBurst.List(end) + 1);                
            end
            silenceCounter = 0;
        else
            silenceCounter = silenceCounter + sim.dt;
        end
    end  
    if(spikePerBurst.Length > 0 && spikePerBurst.List(end) < minSpikesPerburst)
        burstStarts.Remove(burstStarts.Length);
        spikePerBurst.Remove(spikePerBurst.Length);
    end
    if(burstStarts.Length > 0)
        result.OnsetDelay = burstStarts.List(1) - detectStart*sim.dt;
    end
    result.BurstStarts = burstStarts.List();
    result.SpikePerBurst = spikePerBurst.List();    
    result.BurstFrequencies = 1000./(diff(result.BurstStarts));
end

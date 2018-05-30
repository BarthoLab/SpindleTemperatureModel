function CellDisplay()  
    % CELLDISPLAY - Display the characteristics of a single cell simulation
    
    % Variables    
    plotHeight = 170;    
    network = NetworkSim.Network();
    sim = NetworkSim.Sim(network);              
        
    % Base settings
    CellType = 2; % TC = 1, nRT = 2
    %basePotentials = [-74 -70 -69 -68 -67 -63 -61 -59 -57 -55];
    basePotentials = -76:6:-50;
    stimDelay = 100;
    stimLength = 100;
    % stimAmp = -0.01;
    stimAmp = -0.01; spikes = []; % nRT version         
    % CellType = 1; stimAmp = 0; spikes = 1000 + (0:3:15); % TC version
            
    % Params    
%     sim.nRT.kshift = 7;
%     sim.nRT.gmax_it2 = 0.001575;
%     sim.nRT.gkbar_sk = 0.02;
%     sim.nRT.cac_sk = 0.025;
    % sim.nRT.leak_g = 3e-5;   
    sim.temperature.default = 36;
    sim.TC.k_leak = 0.00015;
    sim.TC.gabaa_gmax = 0.0085;
    sim.TC.gabab_gmax = 0.0;                      
    sim.nRT.ampa_gmax = 0.0028;
    sim.nRT.cadecayTau = 200;        
    sim.tstop = 1500;    
    
    % Other
    currentList = ListHandler();
    % currentList.Add('ica');
    
    % Loop
    figure('Name', getCellType(), 'NumberTitle', 'off', 'units', 'normalized', 'outerposition', [0 0 1 1]);
    ax = axes;
    for bp = 1:length(basePotentials)
        sim.v_init = basePotentials(bp);
        result = NetworkSim.CellStim(sim, CellType, spikes, stimDelay, stimLength, stimAmp, currentList);
        t = (1:ceil(sim.tstop/sim.dt))*sim.dt;
        shift = (bp - 1) * plotHeight;
        hold on;        
        plot(t, shift + result.Potential(1:length(t)), 'k');        
        %plot(result.BurstStarts, shift + zeros(1, length(result.BurstStarts)), 'r.', 'MarkerSize', 10);        
        hold off;   
        axis tight;            
    end
    
    % Display
    shift = 100;
    ylim = [0 length(basePotentials) * plotHeight] - shift;
    set(ax, 'ylim', ylim);
    
    for currentSpike = spikes
        s = currentSpike;        
        line([s s], ylim, 'Color', 'r');
    end  
    
    yTick = ((plotHeight / 2) - shift) + 0:plotHeight:(plotHeight*length(basePotentials));
    yTickLabel = basePotentials;
    
    set(ax, 'ylim', ylim, 'yTick', yTick, 'yTickLabel', yTickLabel);
    xlabel('Time (ms)');
    ylabel('Starting membrane potential (mV)');
    title([getCellType() ' cell potentials']);       
     
    function result = getCellType()
        switch CellType
            case 1; result = 'TC';
            case 2; result = 'nRT';        
        end
    end
end

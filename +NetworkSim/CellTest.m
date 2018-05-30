function CellTest()
    % CELLTEST - Display the characteristics of a complex cell simulation
    
    plotHeight = 170;
    iteration = 1:5;

    CellType = 1; % TC = 1, nRT = 2
    spikes = [];
    %defaultBurst = 1:2:5;
    defaultBurst = [0 3];
    defaultBursDelay = 1000;
    responseTime = 90;
    network = NetworkSim.Network();
    sim = NetworkSim.Sim(network);     
    sim.v_init = -64;    
    sim.temperature.default = 36;
    sim.TC.k_leak = 0.00015;
    sim.TC.gabaa_gmax = 0.0085;
    sim.TC.gabab_gmax = 0.0;                      
    sim.nRT.ampa_gmax = 0.0028;
    sim.nRT.cadecayTau = 200;        
    sim.tstop = 1500;    
        
    
    figure('name', getCellType(), 'units', 'normalized', 'outerposition', [0 0 1 1]);  
    ax = axes; 
    for i = iteration
        if i==1            
            newSpikes = defaultBursDelay + defaultBurst;
        else            
            newStart = NaN;
            for burstID = 1:length(result.BurstStarts)
                if(result.BurstStarts(burstID) > newSpikes(1))
                    newStart = result.BurstStarts(burstID);
                    break;
                end
            end
            newSpikes = (newStart + responseTime) + defaultBurst;
        end
        if(~isempty(spikes)); newSpikes = spikes(end) + [3 6]; end; % TEST!!!!!!!!
        if ~isnan(newSpikes)            
            spikes = [spikes newSpikes]; %#ok<AGROW>
        end        
        sim.defaultCommand = '';                                  
        hold on;
        result = NetworkSim.CellStim(sim, CellType, spikes);         
        t = (1:ceil(sim.tstop/sim.dt))*sim.dt;    
        shift = (length(iteration) - i) * plotHeight;
        plot(t, shift + result.Potential(1:length(t)), 'k');
        %plot(result.BurstStarts, shift + zeros(1, length(result.BurstStarts)), 'r.', 'MarkerSize', 10);        
        shift = shift - 100;
        for currentSpike = spikes
            s = currentSpike;        
            line([s s], [shift + 10 shift + plotHeight - 10], 'Color', 'r');
        end            
        hold off;   
        axis tight;    
    end
    
    % Display    
    shift = 100;
    ylim = [0 length(iteration) * plotHeight] - shift;

    iteration = flip(iteration);
    iteration = iteration * 2; % TEST!!!!!!!!
    yTick = ((plotHeight / 2) - shift) + 0:plotHeight:(plotHeight*length(iteration));
    yTickLabel = iteration;
    
    set(ax, 'ylim', ylim, 'yTick', yTick, 'yTickLabel', yTickLabel);
    xlabel('Time (ms)');
    ylabel('Number of spikes'); % TEST!!!!!!!!
    title([getCellType() ' cell potentials']);  
    
    set(ax, 'xlim', [800 sim.tstop]);
    
    function result = getCellType()
        switch CellType
            case 1; result = 'TC';
            case 2; result = 'nRT';        
        end
    end
end
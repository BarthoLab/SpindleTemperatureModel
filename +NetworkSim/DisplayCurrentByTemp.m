function DisplayCurrentByTemp(settings)    
    % DISPLAYCURRENTBYTEMP - Display currents of a single cell
    %   Run by starting <a href="matlab:help NetworkSim.DisplayCurrentByTempStarter">DisplayCurrentByTempStarter</a>
    
    list = ListHandler();
    list.Add('Receptor.i');
    if(settings.CellType == 1)
        list.Add('ica_it');
        list.Add('ih_iar');
    end
    if(settings.CellType == 2)
        list.Add('ica_it2');        
    end
    figure('Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    currentColors = flipud(colormap('autumn'));
    currentColors = currentColors(round(linspace(1, size(currentColors, 1)-10, length(settings.Temperatures))), :);           
    axList = ListHandler();    
    for i = 1:(list.Length + 1)
        currentAx = subplot(list.Length + 1, 1, i, 'ColorOrder', currentColors);
        axList.Add(currentAx);
        hold(currentAx);
    end
    axList = axList.List();    
    for tempID = 1:length(settings.Temperatures)        
        % Sim settings
        network = NetworkSim.Network();
        sim = NetworkSim.Sim(network);    
        sim.v_init = settings.v_init;
        sim.tstop = settings.WaitPeriod + settings.tstop;
        sim.TC.k_leak = 0.00015;        
        sim.TC.gabaa_gmax = 0.0088;
        sim.TC.gabab_gmax = 0.0;              
        sim.nRT.ampa_gmax = 0.0028;
        sim.nRT.cadecayTau = 200;        
        sim.temperature.default = settings.Temperatures(tempID);        
        t = -settings.WaitPeriod:sim.dt:sim.tstop;
        % Run sim
        result = NetworkSim.CellStim(sim, ...
            settings.CellType, ...
            settings.Spikes + settings.WaitPeriod, ...
            settings.StimDelay + settings.WaitPeriod, ...
            settings.StimLength, ...
            settings.StimAmp, list);                         
        % Plot results
        plot(axList(1), t(1:size(result.Potential, 1)), result.Potential);               
        for i = 1:list.Length                       
            actualCurrent = result.Currents.(strrep(list.List(i), '.', ''));
            plot(axList(i + 1), t(1:size(actualCurrent, 1)), actualCurrent);            
        end
    end
    % Display settings
    legend(axList(1), cellstr(num2str(settings.Temperatures(:))));
    ylabel(axList(1), 'Membrane potential (mV)', 'interpreter', 'none');   
    ylabel(axList(3), 'T current (nA)');
    if(settings.CellType == 1)
        ylabel(axList(2), 'GABAa current (nA)');
        ylabel(axList(4), 'h current (nA)');
    end
    if(settings.CellType == 2)
        ylabel(axList(2), 'AMPA current (nA)');
    end
    xlabel(axList(end), 'Time (ms)');
    for i = 1:(list.Length + 1)
        set(axList(i), 'xlim', [0 sim.tstop - settings.WaitPeriod]);
    end
end

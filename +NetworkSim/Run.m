function Run(varargin)
    % RUN - Network Simulation start script
    %   <a href="matlab:help NetworkSim.Network">Network</a>
    %       Configure network with the struct in network.Create
    %       Create the network with the network.CreateNetwork() function
    %   <a href="matlab:help NetworkSim.Sim">Sim</a>
    %       Configure with the public properties
    %       Run with sim.Run() function
    %   IMPORTANT NOTE
    %       MatLab parallel pool random number generation is different from
    %       normal rng thus if Run is called from the parallel pool, the
    %       results can only be reproduced by another parallel call of the
    %       function
    %   Optional Parameters
    %       SEED - default 1234
    %           Random seed of the simulation
    %       Network - default []
    %           Network to run the simulation on. If omitted a default
    %           sample Network will be used
    %       disableJPGs - default true
    %           (Obsolete) If false. frequency and spindle statistics are 
    %           printed to output directory in jpg format
    %       saveData - default true
    %           If true, saves the Netwrok and the result MUA to the output
    %           directory in a mat file
    %       temperatures - default [36]
    %           Array of temperature values to run the simulation on.
    %           Partially obsolete. It is advised to call Run with a single
    %           temperature value and handle multiple temperature settings
    %           on higher level
    %       varTemps - default []
    %           Array of the names of currents or receptors that should
    %           have temperature dependency. Given objects will use the
    %           given temperature. Others will use the default temperature
    %           setting of the simulation. If omitted everything will use
    %           the default tempreature of the simulation
    %       ResultPath - default 'E:\SimResults\'
    %           Output directory, result files will end up here
    %       subFolder - default []
    %           SubFolder to use inside ResultPath. Only useful if multiple
    %           Run functions are called from higher level.    
    %       GABAa - default 0.0088
    %           Maximum conductance of the GABAa receptor. Other receptor
    %           properties have to be set in the hoc files in the @Sim
    %           folder    

    % PARALLEL RNG IS DIFFERENT, USE THIS CODE FOR TESTING
    % parfor (i=1:1, 6); NetworkSim.Run(); end;
    % parfor (i=1:1, 6); NetworkSim.Run('SEED', 7627, 'temperatures', 37.00); NetworkSim.Run('SEED', 7502, 'temperatures', 35.14); end;
    % seeds = [7697, 7627]; temperatures = [35.51, 37.00]; parfor (i=1:length(seeds), 6); NetworkSim.Run('SEED', seeds(i), 'temperatures', temperatures(i));  end;
    SEED = 1234;
    temperatures = 36.00;
    ResultPath = 'E:\SimResults\';    
    % ResultPath = 'c:\Users\dburk\Desktop\SimTest\';        
    % temperatures = 34:0.5:39;    
    %temperatures = 25:40;    
           
    p = inputParser;
    addOptional(p,'SEED', [], @isnumeric);
    addOptional(p,'disableJPGs', true);
    addOptional(p,'saveData', true); % MUA and Network
    addOptional(p,'temperatures', [], @isnumeric);
    addOptional(p,'varTemps', []);
    addOptional(p,'subFolder', []);
    addOptional(p,'ResultPath', ResultPath);
    addOptional(p,'Network', []);
    addOptional(p,'GABAa', 0.0088);
    parse(p,varargin{:}); p = p.Results;
    if(~isempty(p.temperatures)); temperatures = p.temperatures; end;
    if(~isempty(p.SEED)); SEED = p.SEED; end;
    disableJPGs = p.disableJPGs;
    saveData = p.saveData;
    ResultPath = p.ResultPath;
    if(~isempty(p.subFolder))        
        ResultPath = [ResultPath p.subFolder '\'];
    else
        ResultPath = [ResultPath datestr(date, 'yyyy.mm.dd') '\'];
    end
    if ~exist(ResultPath, 'dir'); mkdir(ResultPath); end;
    
    if(~isempty(p.Network))
        network = p.Network;
    else
        network = NetworkSim.Network(); 
        network.RandomSeed = SEED;    
        network.ampaWeightStd = 0.3; % 0.3 !!!!!!!!!
        network.gabaWeightStd = 0;
        network.nRT_Connect = false;
        % network.RandomSeed = 15; network.Create = struct('TC_count', 1, 'nRT_count', 1, 'TC_to_nRT', 0, 'nRT_to_TC', 1, 'nRT_to_nRT', 0); gabaa_teszt = cell(length(temperatures),1);
        % network.nRT_AutoConnect = true; network.Create = struct('TC_count', 2, 'nRT_count', 2, 'TC_to_nRT', 2, 'nRT_to_TC', 2, 'nRT_to_nRT', 2);    
        % network.Create = struct('TC_count', 2, 'nRT_count', 2, 'TC_to_nRT', 2, 'nRT_to_TC', 2, 'nRT_to_nRT', 0);        
        %network.Create = struct('TC_count', 100, 'nRT_count', 10, 'TC_to_nRT', 1, 'nRT_to_TC', 8, 'nRT_to_nRT', 0);    
        % network.Create = struct('TC_count', 100, 'nRT_count', 15, 'TC_to_nRT', 0.1, 'nRT_to_TC', 4, 'nRT_to_nRT', 0);    
        % network.Create = struct('TC_count', 100, 'nRT_count', 20, 'TC_to_nRT', 0.1, 'nRT_to_TC', 4, 'nRT_to_nRT', 0);    
        % network.Create = struct('TC_count', 100, 'nRT_count', 20, 'TC_to_nRT', 0.2, 'nRT_to_TC', 8, 'nRT_to_nRT', 0);    
        network.Create.TC_count = 100;
        network.Create.nRT_count = 20;
        % network.Create.TC_to_nRT = 10;
        % network.Create.TC_to_nRT_max = 10;
        network.Create.TC_to_nRT = 8;
        network.Create.TC_to_nRT_max = 20;
        network.Create.nRT_to_TC = 20;
        network.Create.nRT_to_TC_max = 50;
        network.Create.nRT_to_nRT = 0;
        network.AllowReciprocal = false;      
        network.UseCircularNetwork = false;

%         network.Create.TC_count = 10;
%         network.Create.nRT_count = 5;
%         network.Create.TC_to_nRT = 3;
%         network.Create.TC_to_nRT_max = 4;
%         network.Create.nRT_to_TC = 0;
%         network.Create.nRT_to_TC_max = 6;
%         network.Create.nRT_to_nRT = 0;
%         network.AllowReciprocal = false;      
%         network.UseCircularNetwork = true;
    end
    
    network.CreateNetwork();
    
    % Useful graph functions
    %graphallshortestpaths(adjacency(network.NetworkGraph), 'directed', true) % Shortest paths between nodes!!!
    %graphisdag(adjacency(network.NetworkGraph)) % false if there are cycles!!!
    
    %network.Show(figure); return;
    % Save network image
%     f = figure('Visible', 'off', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); 
%     network.Show(f);     
%     General.SaveFigure(f, [ResultPath network.GetCreateSettings() 'network.jpg']); 
%     close(f);
    
    % return;
    sim = NetworkSim.Sim(network);  
    sim.ResultPath = ResultPath;
    %sim.TC.TC_disable_delay = 1000;
    sim.SaveCurrent = 0;
    sim.tstop = 2000;           
%    sim.temperature.it = 36;
%    sim.temperature.it2 = 36;
%    sim.temperature.ih = 36;
%     sim.temperature.ampa = 36;
%     sim.temperature.gabaa = 36;
%     sim.temperature.gabab = 36;
    frequencies = zeros(1, length(temperatures));
    spindleLengths = zeros(1, length(temperatures));
    troughList = ListHandler();
    tempID = 1;       
    for temp = temperatures
        displayID = 2;
        % currentName = num2str(temp, '%.1f'); disp(currentName);
        % sim.v_init = -50;                
        % currentName = [num2str(-sim.v_init) '_' network.GetCreateSettings() num2str(temp, '%.1f')]; disp(currentName);        
        currentName = [network.GetCreateSettings() num2str(temp, '%.2f') '_' num2str(network.RandomSeed)]; disp(currentName);        
        sim.temperature.default = temp;
        if ~isempty(p.varTemps)
            for varTempID = 1:numel(p.varTemps)
                sim.temperature.(p.varTemps{varTempID}) = temp;
            end
            sim.temperature.default = NetworkSim.Sim.temperature_default.default;
        end
        
        sim.TC.k_leak = 0.00015;
        sim.TC.gabaa_gmax = p.GABAa;
        sim.TC.gabab_gmax = 0.0;              
        % sim.nRT.ampa_gmax = 0.0041;
        sim.nRT.ampa_gmax = 0.0028;

%         sim.TC.k_leak = 0.00015;
%         sim.TC.gabaa_gmax = 0.0082;
%         sim.TC.gabab_gmax = 0.0;              
%         sim.nRT.ampa_gmax = 0.0041;
%         sim.nRT.leak_g = 5e-5;  
%         sim.nRT.cac_sk = 0.025;        
%         sim.nRT.kshift = 0;
        
        sim.nRT.cadecayTau = 200;               
        
        %sim.TC.gabaa_gmax = 0.01;
        % sim.temperature.gabab = 34; 
        % sim.temperature.gabaa = temp;          
        % sim.temperature.ampa = 32; sim.temperature.gabaa = 34;        
        sim.Run();             
        fig1 = figure('Name', currentName, 'Visible', 'off', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);        
%         networkParamDisplay(fig1, network);        
%         [frequencies(tempID), spindleLengths(tempID)] = DisplayResults(fig1);
        [frequencies(tempID), spindleLengths(tempID)] = DisplayResultsTEMP(fig1);
        tempID = tempID + 1;        
    end  
    
    if(disableJPGs); return; end;
    fig2 = figure('Name', 'frequencies', 'Visible', 'off', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    plot(temperatures, frequencies);
    General.SaveFigure(fig2, [ResultPath 'frequencies.jpg']); 
    close(fig2);
    %return;
    fig3 = figure('Name', 'lengths', 'Visible', 'off', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    plot(temperatures, spindleLengths);
    General.SaveFigure(fig3, [ResultPath 'lengths.jpg']); 
    close(fig3);
    return;
    fig4 = figure('Name', 'intervals', 'Visible', 'off', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    intervals = troughList.Data;
    hold on;
    for tempID = 1:length(temperatures)
        plot(intervals{tempID});
    end
    hold off;
    General.SaveFigure(fig4, [ResultPath 'intervals.jpg']); 
    close(fig4);
    
    % OLD DISPLAY
    function [currentFreq, spindleLength] = DisplayResultsOld(f)
        set(0,'CurrentFigure', f);
        a = load([sim.SubFolder sim.TC_Results]);    
        subplot(3, 2, 1); plot(a(:, displayID));
        TC_res = zeros(size(a,2), sim.tstop / sim.dt);
        subplot(3, 2, 3, 'xlim', [0 sim.tstop / sim.dt], 'ylim', [1 size(a, 2)]);
        title('TC');
        hold on;
        for i = 1:size(a, 2)        
            res = getRes(a(:,i));
            e0 = zeros(sim.tstop / sim.dt,1); 
            e0(res)=1;
            e0 = e0(1:size(TC_res, 2));            
            TC_res(i,:) = e0;
            plot(res, ones(length(res), 1)*i, '.b');
        end     
        hold off;       
        currentSum_TC = sum(TC_res);
        currentSum_TC(currentSum_TC > 1) = 1;
        fMUA_TC=Filter0(ones(501,1)/501, currentSum_TC);

        a = load([sim.SubFolder sim.nRT_Results]);   
        subplot(3, 2, 2); plot(a(:, displayID));
        nRT_res = zeros(size(a,2), sim.tstop / sim.dt);    
        subplot(3, 2, 4, 'xlim', [0 sim.tstop / sim.dt], 'ylim', [1 size(a, 2)]);
        title('nRT');
        hold on;
        for i = 1:size(a, 2)        
            res = getRes(a(:,i));
            e0 = zeros(sim.tstop / sim.dt,1); 
            e0(res)=1;
            e0 = e0(1:(sim.tstop / sim.dt));
            nRT_res(i,:) = e0;
            plot(res, ones(length(res), 1)*i, '.b');
        end     
        hold off;       
        currentSum_nRT = sum(nRT_res);
        currentSum_nRT(currentSum_nRT > 1) = 1;
        fMUA_nRT=Filter0(ones(501,1)/501, currentSum_nRT);


        currentSum = currentSum_TC + currentSum_nRT;
        currentSum(currentSum > 1) = 1;
        fMUA_SUM = Filter0(ones(501,1)/501, currentSum);
        currentTroughsRel = getFrequency(fMUA_SUM);        
        currentFreq = mean(1000./(diff(currentTroughsRel)*sim.dt));   
        troughList.Add(diff(currentTroughsRel)*sim.dt);
        % fMUA_SUM=bpfilter(fMUA_SUM, 1000 / sim.dt, 7, 20, 2^15);
                
        currentSumIDs = find(currentSum == 1);
        if(~isempty(currentSumIDs))
            spindleLength = (currentSumIDs(end) - currentSumIDs(1))*sim.dt;
        end

        % Bottom Display
        subplot(3, 2, 5:6);
        hold on;            
        plot(fMUA_TC * max(fMUA_nRT) / max(fMUA_TC), 'k');    
        plot(fMUA_nRT, 'r');
        plot(currentTroughsRel, (max(fMUA_SUM) / 2) * ones(length(currentTroughsRel)), 'g+');
        hold off;
        legend('TC', 'nRT');
        distances = 1000./(diff(currentTroughsRel')*sim.dt);
        title(num2str(round(distances)));
       
        if(saveData)
            MUA.TC = fMUA_TC;
            MUA.nRT = fMUA_nRT;
            MUA.Sum = fMUA_SUM; %#ok<STRNU>
            fileBase = [ResultPath get(f, 'Name')]; %#ok<NASGU>
            save([ResultPath get(f, 'Name') '.mat'], ...
                'temperatures', ...                
                'MUA', ...
                'distances', ...
                'network', ...
                'sim', ...
                'currentFreq');
        end
        General.SaveFigure(f, [ResultPath get(f, 'Name') '.jpg']);        
        close(f);        
        
        if(~disableJPGs)
            saveCellData('TC', 10, true);
            saveCellData('nRT', 10, true);
        end
    end 
    % END OF OLD DISPLAY

    function saveCellData(name, nbrOfOutput, isMerged)        
        fig = figure('Name', [name '_' currentName], 'Visible', 'off', 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);               
        a = load([sim.SubFolder name '_Results.txt']);   
        if (isMerged); a(a > 0) = 0; end;
        plotHeight = 150;
        t = (1:(ceil(sim.tstop/sim.dt)+1))*sim.dt;
        ax = axes;
        hold on;
        for i = 1:min(size(a, 2), nbrOfOutput)            
            if(isMerged)
                plot(t, a(:, i));
            else
                plot(t, a(:, i) + (i-1)*plotHeight, 'b');
            end
        end
        set(ax, 'ylim', [-90 0]);
        hold off;
        General.SaveFigure(fig, [ResultPath get(fig, 'Name') '.jpg']);
        close(fig);        
    end
    
    function res = getRes(currentData)
        spikeThreshold = 30;
        res = ListHandler();
        for dataID = 2:length(currentData)
            if currentData(dataID - 1) < spikeThreshold && ...
               currentData(dataID) > spikeThreshold
                res.Add(dataID);
            end
        end
        res = ceil(res.List());
    end
    
    function currentTroughsRel = getFrequency(fMUA)                      
        %SfMUA=bpfilter(fMUA, 1000 / sim.dt, 7, 20);
        currentTroughsRel = ListHandler();        
        currentMin = Other.LocalMinima(-fMUA, 50 / sim.dt, -max(fMUA)/4);
%         tempMin = findpeaks(fMUA, max(fMUA) / 10); tempMin = tempMin.loc;                       
%         currentMin = ListHandler();            
%         currentMin.Add(tempMin(1));
%         currentDiff = diff(tempMin);
%         diffThreshold = 80;
%         for minID = 1:(length(tempMin) - 1)
%             if currentDiff(minID) > diffThreshold
%                 currentMin.Add(tempMin(minID + 1));
%             end
%         end        
%         currentMin = currentMin.List();
        for currentID = 1:length(currentMin)
            currentTroughsRel.Add(currentMin(currentID));
        end                        
        currentTroughsRel = currentTroughsRel.List();
    end

    function networkParamDisplay(fig, network)
        txtWidth = 0.1;
        displayText = ListHandler();
        fieldNames = fieldnames(network.Create);
        for fID = 1:numel(fieldNames)
            displayText.Add([fieldNames{fID} ': ' num2str(network.Create.(fieldNames{fID}))]);
        end
        displayText.Add(['TC_recive: ' num2str(network.Create.nRT_count * network.Create.nRT_to_TC / network.Create.TC_count)]);
        displayText.Add(['nRT_recive: ' num2str(network.Create.TC_count * network.Create.TC_to_nRT / network.Create.nRT_count)]);
        displayText = displayText.Data;
        uicontrol( ...
            'Parent', fig, ...
            'Style', 'text', ... 
            'String', displayText, ...
            'Units', 'normalized', ...
            'FontSize', 10, ...
            'BackGroundColor', 'w', ...
            'HorizontalAlignment', 'left', ...
            'Position', [(1-txtWidth)/2+0.02 0.6 txtWidth 0.3]);
    end

    % START OF NEW DISPLAY
    function [currentFreq, spindleLength] = DisplayResults(f)                     
        SaveEPS = false;
        % DisplayDegreeOfConnectivity = true;
        DisplayDegreeOfConnectivity = false;
        
        t = (1:ceil(sim.tstop/sim.dt))*sim.dt; 
        
        set(0,'CurrentFigure', f);
        a = load([sim.SubFolder sim.TC_Results]);    
        b = load([sim.SubFolder sim.nRT_Results]);   
        TC_res = zeros(size(a,2), sim.tstop / sim.dt);
        nRT_res = zeros(size(b,2), sim.tstop / sim.dt);    
        if(DisplayDegreeOfConnectivity)
            plotPosition = [1 2 4 5];
        else
            plotPosition = 1:6;
        end
        subplot(4, 3, plotPosition, 'xlim', [0 sim.tstop], 'ylim', [1 max(size(a, 2), size(b, 2))]);        
        hold on;
        for i = 1:size(a, 2)        
            res = getRes(a(:,i));
            e0 = zeros(sim.tstop / sim.dt,1); 
            e0(res)=1;
            e0 = e0(1:size(TC_res, 2));            
            TC_res(i,:) = e0;
            plot(res * sim.dt, ones(length(res), 1)*i, '.k');
        end         
        currentSum_TC = sum(TC_res);
        currentSum_TC(currentSum_TC > 1) = 1;
        fMUA_TC=Filter0(ones(501,1)/501, currentSum_TC);
                
        for i = 1:size(b, 2)        
            res = getRes(b(:,i));
            e0 = zeros(sim.tstop / sim.dt,1); 
            e0(res)=1;
            e0 = e0(1:(sim.tstop / sim.dt));
            nRT_res(i,:) = e0;
            plot(res * sim.dt, ones(length(res), 1)*i * 5, '.r');
        end                 
        currentSum_nRT = sum(nRT_res);
        currentSum_nRT(currentSum_nRT > 1) = 1;
        fMUA_nRT=Filter0(ones(501,1)/501, currentSum_nRT);
        hold off;   
        
        title('Raster plot of TC and nRT firing');

        currentSum = currentSum_TC + currentSum_nRT;
        currentSum(currentSum > 1) = 1;
        fMUA_SUM = Filter0(ones(501,1)/501, currentSum);
        currentTroughsRel = getFrequency(fMUA_SUM);        
        currentFreq = mean(1000./(diff(currentTroughsRel)*sim.dt));   
        troughList.Add(diff(currentTroughsRel)*sim.dt);
        % fMUA_SUM=bpfilter(fMUA_SUM, 1000 / sim.dt, 7, 20, 2^15);
                
        currentSumIDs = find(currentSum == 1);
        if(~isempty(currentSumIDs))
            spindleLength = (currentSumIDs(end) - currentSumIDs(1))*sim.dt;
        end

        % Bottom Display
        if(DisplayDegreeOfConnectivity)
            plotPosition = [7 8 10 11]; 
        else
            plotPosition = 7:12;
        end
        subplot(4, 3, plotPosition);
        hold on;            
        plot(t, fMUA_TC * max(fMUA_nRT)/ max(fMUA_TC), 'k');    
        plot(t, fMUA_nRT, 'r');
        plot(currentTroughsRel * sim.dt, (max(fMUA_SUM) / 2) * ones(length(currentTroughsRel)), 'g+');
        hold off;
        legend('TC', 'nRT');
        distances = 1000./(diff(currentTroughsRel')*sim.dt);
        title(num2str(round(distances)));
        
        if(DisplayDegreeOfConnectivity); DisplayConnectivityBars(); end;
       
        if(saveData)            
            MUA.TC = fMUA_TC;
            MUA.nRT = fMUA_nRT;
            MUA.Sum = fMUA_SUM; %#ok<STRNU>
            fileBase = [ResultPath get(f, 'Name')]; %#ok<NASGU>
            if(sim.SaveCurrent)
                detailedResults = getDetailedData(); %#ok<NASGU>
                save([ResultPath get(f, 'Name') '.mat'], ...
                    'temperatures', ...                
                    'MUA', ...
                    'distances', ...
                    'network', ...
                    'currentFreq', ...
                    'detailedResults');
            else
                save([ResultPath get(f, 'Name') '.mat'], ...
                    'temperatures', ...                
                    'MUA', ...
                    'distances', ...
                    'network', ...
                    'currentFreq');
            end
        end
        General.SaveFigure(f, [ResultPath get(f, 'Name') '.jpg']);
        if(SaveEPS)
            saveas(f, [ResultPath get(f, 'Name') '.eps'], 'epsc2');
        end;
        close(f);        
        
        if(~disableJPGs)
            saveCellData('TC', 10, true);
            saveCellData('nRT', 10, true);
        end
        
        function result = getDetailedData()            
            cEdges = network.NetworkGraph.Edges.EndNodes;            
            % TC
            result.TC = ListHandler();
            membrane_potential = load([sim.SubFolder sim.TC_Results]);
            it_current = load([sim.SubFolder 'it.txt']);
            ih_current = load([sim.SubFolder 'ih.txt']);
            gabaa_current = load([sim.SubFolder 'gabaa.txt']);
            gabab_current = load([sim.SubFolder 'gabab.txt']);            
            colCounter = 1;            
            for TC_ID = 1:sim.Network.TC_count
                currTC = [];
                currTC.MembranePotential = membrane_potential(:, TC_ID);
                currTC.IT = it_current(:, TC_ID);
                currTC.Ih = ih_current(:, TC_ID);
                currTC.GABAa = ListHandler();
                currTC.GABAb = ListHandler();
                % Count the number of synapses the given cell GETS
                synCount = size(cEdges(ismember(cEdges(:, 2), ['TC' num2str(TC_ID)]), :), 1);
                for syn_ID = colCounter:(colCounter + synCount - 1)                    
                    currTC.GABAa.Add(gabaa_current(:, syn_ID));
                    currTC.GABAb.Add(gabab_current(:, syn_ID));
                end                
                colCounter = colCounter + synCount;
                currTC.GABAa = currTC.GABAa.Data;
                currTC.GABAb = currTC.GABAb.Data;
                result.TC.Add(currTC);
            end
            result.TC = result.TC.Data;
            % nRT
            result.nRT = ListHandler();
            membrane_potential = load([sim.SubFolder sim.nRT_Results]);
            it2_current = load([sim.SubFolder 'it2.txt']);                        
            ampa_current = load([sim.SubFolder 'ampa.txt']);            
            colCounter = 1;            
            for nRT_ID = 1:sim.Network.nRT_count
                currnRT = [];
                currnRT.MembranePotential = membrane_potential(:, nRT_ID);
                currnRT.IT2 = it2_current(:, nRT_ID);                
                currnRT.AMPA = ListHandler();                
                % Count the number of synapses the given cell GETS
                synCount = size(cEdges(ismember(cEdges(:, 2), ['nRT' num2str(nRT_ID)]), :), 1);
                for syn_ID = colCounter:(colCounter + synCount - 1)                    
                    currnRT.AMPA.Add(ampa_current(:, syn_ID));                    
                end                
                colCounter = colCounter + synCount;
                currnRT.AMPA = currnRT.AMPA.Data;                
                result.nRT.Add(currnRT);
            end
            result.nRT = result.nRT.Data;
        end
        
        function DisplayConnectivityBars()
            subplot(4, 3, [3 6]);
            network.PlotBars('TC');
            subplot(4, 3, [9 12]);
            network.PlotBars('nRT');          
        end
    end 
    % END OF NEW DISPLAY
    
    % START OF SFN DISPLAY
    function [currentFreq, spindleLength] = DisplayResultsTEMP(f)                     
        SaveEPS = true;        
        xlim = [400 1500];
        ylim = [0 0.16];
        % DisplayDegreeOfConnectivity = true;
        DisplayDegreeOfConnectivity = false;
        
        t = (1:ceil(sim.tstop/sim.dt))*sim.dt; 
        
        set(0,'CurrentFigure', f);
        a = load([sim.SubFolder sim.TC_Results]);    
        b = load([sim.SubFolder sim.nRT_Results]);   
        TC_res = zeros(size(a,2), sim.tstop / sim.dt);
        nRT_res = zeros(size(b,2), sim.tstop / sim.dt);    
        if(DisplayDegreeOfConnectivity)
            plotPosition = [1 2 4 5];
        else
            plotPosition = 1:6;
        end
        subplot(4, 3, plotPosition, 'xlim', xlim, 'ylim', [1 max(size(a, 2), size(b, 2))]);   
        currMarkSize = 15;
        hold on;
        for i = 1:size(a, 2)        
            res = getRes(a(:,i));
            e0 = zeros(sim.tstop / sim.dt,1); 
            e0(res)=1;
            e0 = e0(1:size(TC_res, 2));            
            TC_res(i,:) = e0;
            plot(res * sim.dt, ones(length(res), 1)*i, '.k', 'MarkerSize', currMarkSize);
        end         
        currentSum_TC = sum(TC_res);
        currentSum_TC(currentSum_TC > 1) = 1;
        fMUA_TC=Filter0(ones(501,1)/501, currentSum_TC);
                
        for i = 1:size(b, 2)        
            res = getRes(b(:,i));
            e0 = zeros(sim.tstop / sim.dt,1); 
            e0(res)=1;
            e0 = e0(1:(sim.tstop / sim.dt));
            nRT_res(i,:) = e0;
            plot(res * sim.dt, ones(length(res), 1)*i * 5, '.r', 'MarkerSize', currMarkSize);
        end                 
        currentSum_nRT = sum(nRT_res);
        currentSum_nRT(currentSum_nRT > 1) = 1;
        fMUA_nRT=Filter0(ones(501,1)/501, currentSum_nRT);
        hold off;   
        axis off;
        % title('Raster plot of TC and nRT firing');

        currentSum = currentSum_TC + currentSum_nRT;
        currentSum(currentSum > 1) = 1;
        fMUA_SUM = Filter0(ones(501,1)/501, currentSum);
        currentTroughsRel = getFrequency(fMUA_SUM);        
        currentFreq = mean(1000./(diff(currentTroughsRel)*sim.dt));   
        troughList.Add(diff(currentTroughsRel)*sim.dt);
        % fMUA_SUM=bpfilter(fMUA_SUM, 1000 / sim.dt, 7, 20, 2^15);
                
        currentSumIDs = find(currentSum == 1);
        if(~isempty(currentSumIDs))
            spindleLength = (currentSumIDs(end) - currentSumIDs(1))*sim.dt;
        end

        % Bottom Display
        if(DisplayDegreeOfConnectivity)
            plotPosition = [7 8 10 11]; 
        else
            plotPosition = 7:12;
        end
        subplot(4, 3, plotPosition, 'xlim', xlim, 'ylim', ylim);
        currLineWidth = 3;
        hold on;            
        plot(t, fMUA_TC * max(fMUA_nRT)/ max(fMUA_TC), 'k', 'LineWidth', currLineWidth);    
        plot(t, fMUA_nRT, 'r', 'LineWidth', currLineWidth);
        plot(currentTroughsRel * sim.dt, 0.155 * ones(length(currentTroughsRel)), 'g+');
        % ScaleBar
        plot([1300 1500], [0.12 0.12], 'k', 'LineWidth', currLineWidth); 
        text(1400, 0.13, '200 ms');
        hold off;
        legend('TC', 'nRT', 'Location', 'southeast');
        axis off;
        distances = 1000./(diff(currentTroughsRel')*sim.dt);
        title(num2str(round(distances)));
        
        if(DisplayDegreeOfConnectivity); DisplayConnectivityBars(); end;                     
        
        if(saveData)            
            MUA.TC = fMUA_TC;
            MUA.nRT = fMUA_nRT;
            MUA.Sum = fMUA_SUM; %#ok<STRNU>
            fileBase = [ResultPath get(f, 'Name')]; %#ok<NASGU>
            if(sim.SaveCurrent)
                detailedResults = getDetailedData(); %#ok<NASGU>
                save([ResultPath get(f, 'Name') '.mat'], ...
                    'temperatures', ...                
                    'MUA', ...
                    'distances', ...
                    'network', ...
                    'currentFreq', ...
                    'detailedResults');
            else
                save([ResultPath get(f, 'Name') '.mat'], ...
                    'temperatures', ...                
                    'MUA', ...
                    'distances', ...
                    'network', ...
                    'currentFreq');
            end
        end
        General.SaveFigure(f, [ResultPath get(f, 'Name') '.jpg']);
        if(SaveEPS)
            saveas(f, [ResultPath get(f, 'Name') '.eps'], 'epsc2');
        end;
        close(f);        
        
        if(~disableJPGs)
            saveCellData('TC', 10, true);
            saveCellData('nRT', 10, true);
        end
        
        function result = getDetailedData()            
            cEdges = network.NetworkGraph.Edges.EndNodes;            
            % TC
            result.TC = ListHandler();
            membrane_potential = load([sim.SubFolder sim.TC_Results]);
            it_current = load([sim.SubFolder 'it.txt']);
            ih_current = load([sim.SubFolder 'ih.txt']);
            gabaa_current = load([sim.SubFolder 'gabaa.txt']);
            gabab_current = load([sim.SubFolder 'gabab.txt']);            
            colCounter = 1;            
            for TC_ID = 1:sim.Network.TC_count
                currTC = [];
                currTC.MembranePotential = membrane_potential(:, TC_ID);
                currTC.IT = it_current(:, TC_ID);
                currTC.Ih = ih_current(:, TC_ID);
                currTC.GABAa = ListHandler();
                currTC.GABAb = ListHandler();
                % Count the number of synapses the given cell GETS
                synCount = size(cEdges(ismember(cEdges(:, 2), ['TC' num2str(TC_ID)]), :), 1);
                for syn_ID = colCounter:(colCounter + synCount - 1)                    
                    currTC.GABAa.Add(gabaa_current(:, syn_ID));
                    currTC.GABAb.Add(gabab_current(:, syn_ID));
                end                
                colCounter = colCounter + synCount;
                currTC.GABAa = currTC.GABAa.Data;
                currTC.GABAb = currTC.GABAb.Data;
                result.TC.Add(currTC);
            end
            result.TC = result.TC.Data;
            % nRT
            result.nRT = ListHandler();
            membrane_potential = load([sim.SubFolder sim.nRT_Results]);
            it2_current = load([sim.SubFolder 'it2.txt']);                        
            ampa_current = load([sim.SubFolder 'ampa.txt']);            
            colCounter = 1;            
            for nRT_ID = 1:sim.Network.nRT_count
                currnRT = [];
                currnRT.MembranePotential = membrane_potential(:, nRT_ID);
                currnRT.IT2 = it2_current(:, nRT_ID);                
                currnRT.AMPA = ListHandler();                
                % Count the number of synapses the given cell GETS
                synCount = size(cEdges(ismember(cEdges(:, 2), ['nRT' num2str(nRT_ID)]), :), 1);
                for syn_ID = colCounter:(colCounter + synCount - 1)                    
                    currnRT.AMPA.Add(ampa_current(:, syn_ID));                    
                end                
                colCounter = colCounter + synCount;
                currnRT.AMPA = currnRT.AMPA.Data;                
                result.nRT.Add(currnRT);
            end
            result.nRT = result.nRT.Data;
        end
        
        function DisplayConnectivityBars()
            subplot(4, 3, [3 6]);
            network.PlotBars('TC');
            subplot(4, 3, [9 12]);
            network.PlotBars('nRT');          
        end
    end 
    % END OF SFN DISPLAY
end
                                                                                                                                                                                                                                                                    
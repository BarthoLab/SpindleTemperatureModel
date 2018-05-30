function AutoRun2(varargin)
    % AUTORUN2 - Network Simulation start script
    %   Run the same simulation with multiple seeds and temperatures
    
    EvalOnly = false;
    showAsHist = true;
    showAllFreq = true;
    lastKey = 'return'; fID = 1; disableKeyPress = false;
    boolTxt = {'false', 'true'};
    subFolderOriginal = '2017.06.22\';
    textDisplay = [];
    TypeName = 'Test'; %#ok<NASGU>
    if(~isempty(varargin)); EvalOnly = varargin{1}; end;
    
    sourceFolder = 'e:\SimResults\';
    rng(1);
    
    iterations = 100;
    tempLimit = [37 37];        
    TC_to_nRT = [8 10 12];  
    nRT_to_TC_max = [50 25];
    nRT_to_TC = [10 20];
    gabaa = [0.0082 0.0085 0.0088];     
    AllowReciprocal = true;
    UseCircularNetwork = false;    
    
    temps = tempLimit(1) + (tempLimit(2)-tempLimit(1))*rand(iterations, 1);
    seeds = randi(10000, iterations, 1);
    
    % Presentation stuff TEMP
%     temps = [33 33 33 35 35 35 37 37.01 37.02];
%     seeds = [3475 6107 151 2261 2311 243 8709 3670 1294];
    
    if(~EvalOnly)
        resultFig = figure('Visible', 'Off', 'NumberTitle', 'Off');        
        for j = 1:length(TC_to_nRT)                                 
            for k = 1:length(nRT_to_TC_max)                                 
                for l = 1:length(nRT_to_TC)                                 
                    for m = 1:length(gabaa)                                 
                        subFolder = [];
                        subFolder = [subFolder boolTxt{AllowReciprocal + 1}];
                        subFolder = [subFolder '_' boolTxt{UseCircularNetwork + 1}];
                        subFolder = [subFolder '_' num2str(TC_to_nRT(j))]; %#ok<*AGROW>
                        subFolder = [subFolder '_' num2str(nRT_to_TC_max(k))]; %#ok<*AGROW>
                        subFolder = [subFolder '_' num2str(nRT_to_TC(l))]; %#ok<*AGROW>
                        subFolder = [subFolder '_' num2str(gabaa(m))]; %#ok<*AGROW>
                        network = NetworkSim.Network();                 
                        network.ampaWeightStd = 0.3;
                        network.gabaWeightStd = 0;
                        network.nRT_Connect = false;
                        network.Create.TC_count = 100;
                        network.Create.nRT_count = 20;            
                        network.Create.TC_to_nRT = TC_to_nRT(j);
                        network.Create.TC_to_nRT_max = 20;
                        network.Create.nRT_to_TC = nRT_to_TC(l);
                        network.Create.nRT_to_TC_max = nRT_to_TC_max(k);
                        network.Create.nRT_to_nRT = 0;
                        network.AllowReciprocal = AllowReciprocal;      
                        network.UseCircularNetwork = UseCircularNetwork;
                        for i=1:length(temps)    
                            network.RandomSeed = seeds(i);    
                            NetworkSim.Run( ...
                                'temperatures', round(temps(i), 2), ...
                                'Network', network, ...
                                'GABAa', gabaa(m), ...
                                'saveData', true, ...
                                'disableJPGs', true, ...
                                'subFolder', [subFolderOriginal subFolder]);                
                        end                        
                        EvaluateResults(subFolder, false);
                    end
                end
            end            
        end
        fclose(resultFig);
    else        
        directories = dir([sourceFolder subFolderOriginal]); 
        directories = directories([directories.isdir]);
        directories(1:2) = []; % Remove . and ..     
        resultFig = figure('Units', 'Normalized', 'OuterPosition', [0 0 1 1], 'Visible', 'On', 'NumberTitle', 'Off', 'WindowKeyPressFcn', @KeyPress);        
        DisplayNext();
    end
    
    function EvaluateResults(currFolder, displayOn)
        clf(resultFig);
        fName = 'result_data';
        sourceFolder2 = [sourceFolder subFolderOriginal currFolder '\'];
        displayResultExists = exist([sourceFolder2 fName '.mat'], 'file') == 2;
        if(~displayOn || ~displayResultExists)            
            % Load exclusions             
            if(exist([sourceFolder2 'Exclude.list'], 'file') == 2)
                eList = load([sourceFolder2 'Exclude.list'], '-mat'); 
                eList = eList.files;
            end
            % Get values
            files = dir([sourceFolder2 '*.mat']);        
            temperatures = ListHandler();
            frequencies = ListHandler();
            frequenciesAll = ListHandler();
            temperaturesEx = ListHandler();
            frequenciesEx = ListHandler();
            frequenciesAllEx = ListHandler();
            for f = 1:numel(files)            
                if(strfind(files(f).name, 'result_data')); continue; end;            
                result = load([sourceFolder2 files(f).name]);            
                % frequencies(f) = result.currentFreq;            
                currFreqAll = getFrequency(result.MUA.Sum);
                currFreq = mean(currFreqAll);
                % if(result.temperatures(1) > 36.5 && currFreq < 12); continue; end;
                % if(result.temperatures(1) > 36); continue; end;
                % if(sum(result.MUA.TC) == 0); continue; end;              
                % eList(f).exclude = false;
    %             if(length(result.distances) > 3 && (result.distances(3) < 10 || result.distances(4) < 10)); 
    %                 eList(f).exclude = true; else eList(f).exclude = false; end;
                if(exist([sourceFolder2 'Exclude.list'], 'file') == 2 && eList(f).exclude)
                    for freqID = 1:length(currFreqAll)
                        frequenciesAll.Add(currFreqAll(freqID));    
                    end
                    frequenciesEx.Add(currFreq);
                    temperaturesEx.Add(result.temperatures(1));
                else
                    for freqID = 1:length(currFreqAll)
                        frequenciesAllEx.Add(currFreqAll(freqID));    
                    end
                    frequencies.Add(currFreq);
                    temperatures.Add(result.temperatures(1));
                end
            end
            if(exist([sourceFolder2 'Exclude.list'], 'file') == 2)
                % Resave excludelist even if no change happened, so testing is easier
                files = eList;  %#ok<NASGU>
                save([sourceFolder2 'Exclude.list'], 'files', '-mat'); 
            end

            temperatures = temperatures.List();
            frequencies = frequencies.List();
            frequenciesAll = frequenciesAll.List();
            temperaturesEx = temperaturesEx.List();
            frequenciesEx = frequenciesEx.List();
            frequenciesAllEx = frequenciesAllEx.List();
        else
            tempFig = resultFig;
            set(0, 'DefaultFigureCreateFcn', @(s,e)delete(s));
            load([sourceFolder2 fName '.mat']);
            set(0, 'DefaultFigureCreateFcn', '');
            resultFig = tempFig;
        end
        
        [correlation, p] = corrcoef(temperatures, frequencies); 
        
        set(resultFig, 'Name', currFolder);        
        currLimit = [7 17];
        if(showAsHist)
            % Plot Histogram
            ax = axes;
            if (showAllFreq)
                currLimit = [0 20];
                currX = currLimit(1):0.5:currLimit(2);
                histogram([frequenciesAll frequenciesAllEx], currX);           
                set(ax, 'ylim', [0 200]); % TEMP
            else                
                currX = currLimit(1):0.5:currLimit(2);
                histogram([frequencies frequenciesEx], currX);           
                set(ax, 'ylim', [0 50]); % TEMP
            end                        
            xlabel('Spindle frequency');
        else
            % Plot scatter        
            ax = axes;
            hold on;                
            scatter(temperatures, frequencies, 'filled');
            scatter(temperaturesEx, frequenciesEx, 'filled', 'r');        
            hold off;
            set(ax, 'ylim', currLimit);
            xlabel('Temperature');
            ylabel('Spindle frequency');                   
            title({['Correlation: ' num2str(correlation(1,2))]; ['P: ' num2str(p(1,2))]});
        end
        ParamDisplay(resultFig);
                
        % Save data
        if(~displayOn || ~displayResultExists)            
            warning('off', 'MATLAB:Figure:FigureSavedToMATFile');            
            if(exist([sourceFolder2 'Exclude.list'], 'file') == 2); fName = [fName '_filtered']; end;
            save([sourceFolder2 fName '.mat'], ...
                'temperatures', ...
                'frequencies', ...
                'frequenciesAll', ...
                'temperaturesEx', ...
                'frequenciesEx', ...
                'frequenciesAllEx', ...
                'correlation', ...
                'p', ...
                'resultFig', ...
                'TypeName');        
            warning('on', 'MATLAB:Figure:FigureSavedToMATFile');
        end
    end

    function ParamDisplay(fig)
        if(~isempty(textDisplay)); delete(textDisplay); end;
        txtWidth = 0.1;
        dirParts = strsplit(directories(fID).name, '_');
        displayText = ListHandler();       
        displayText.Add(['AutoCorrelation: ' dirParts{1}]);
        displayText.Add(['CircularNetwork: ' dirParts{2}]);
        displayText.Add(['TC to nRT: ' dirParts{3}]);
        displayText.Add(['nRT to TC max: ' dirParts{4}]);
        displayText.Add(['nRT to TC: ' dirParts{5}]);
        displayText.Add(['GABAa: ' dirParts{6}]);
        displayText = displayText.Data;
        textDisplay = uicontrol( ...
            'Parent', fig, ...
            'Style', 'text', ... 
            'String', displayText, ...
            'Units', 'normalized', ...
            'FontSize', 10, ...
            'BackGroundColor', 'w', ...
            'HorizontalAlignment', 'left', ...
            'Position', [(1-txtWidth)/2+0.02 0.6 txtWidth 0.3]);
    end

    % TEMP TESTING OF FREQUENCY DETECT
    function result = getFrequency(fMUA)
        currentTroughsRel = ListHandler();        
        currentMin = Other.LocalMinima(-fMUA, 50 / 0.1, -max(fMUA)/4);
        for currentID = 1:length(currentMin)
            currentTroughsRel.Add(currentMin(currentID));
        end          
        freqs = 1000./(diff(currentTroughsRel.List())*0.1);
        %freqs = freqs(freqs > 9);  
        result = freqs;
    end

   function KeyPress(~, e) 
        if(disableKeyPress); return; end;
        lastKey = e.Key;
        switch e.Key
           case 'leftarrow';  
               fID = fID - 1;
               DisplayNext();
           case 'rightarrow'; 
               fID = fID + 1;
               DisplayNext();
        end        
   end

    function DisplayNext()        
        if(fID < 1); fID = 1; return; end;
        if(fID > length(directories)); fID = length(directories); return; end;                     
        disableKeyPress = true;        
        if(filterDir)
            if(strcmp(lastKey, 'leftarrow'))
                fID = fID - 1;
            else
                fID = fID + 1;
            end
            DisplayNext();
            return;
        end
        EvaluateResults(directories(fID).name, true);
        disableKeyPress = false;
    end

    function isExclude = filterDir()
        isExclude = false;
        dirParts = strsplit(directories(fID).name, '_');
        %if(strcmp(dirParts{3}, '10')); isExclude = true; end;        
    end
end

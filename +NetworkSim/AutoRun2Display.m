function AutoRun2Display()
    % AUTORUN2DISPLAY - Display the results of AutoRun2

    fixedVarID1 = 2;
    fixedVarID2 = 6;
    varValues1 = ListHandler();
    varValues2 = ListHandler();
    sortedDirectories = ListHandler();

    showAsHist = true;
    showAllFreq = true;
    lastKey = 'return'; fID = 1; disableKeyPress = false;
    fIDmax = Inf;
    subFolderOriginal = '2017.05.30\';
    textDisplay = [];
    TypeName = 'Test'; %#ok<NASGU>
    
    sourceFolder = 'e:\SimResults\'; 
    
    directories = dir([sourceFolder subFolderOriginal]); 
    directories = directories([directories.isdir]);
    directories(1:2) = []; % Remove . and ..     
    resultFig = figure('Units', 'Normalized', 'OuterPosition', [0 0 1 1], 'Visible', 'On', 'NumberTitle', 'Off', 'WindowKeyPressFcn', @KeyPress);        
    getVarValues()
    DisplayNext();
    
    
    function EvaluateResults(currFolder, displayOn, ax)        
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
        
        % set(resultFig, 'Name', currFolder);        
        currLimit = [7 17];
        if(showAsHist)
            % Plot Histogram            
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
            title(currFolder, 'Interpreter', 'none');
        else
            % Plot scatter        
            hold on;                
            scatter(temperatures, frequencies, 'filled');
            scatter(temperaturesEx, frequenciesEx, 'filled', 'r');        
            hold off;
            set(ax, 'ylim', currLimit);
            xlabel('Temperature');
            ylabel('Spindle frequency');                   
            title({['Correlation: ' num2str(correlation(1,2))]; ['P: ' num2str(p(1,2))]});
        end
        % ParamDisplay(resultFig);
                
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
        if(fID > fIDmax); fID = fIDmax; return; end;                     
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
        clf(resultFig);              
        plotID = 0;
        currentDirectories = sortedDirectories{fID};
        for v1 = 1:length(varValues1)
            for v2 = 1:length(varValues2)
                plotID = plotID + 1;              
                EvaluateResults(...
                    currentDirectories{v1, v2}.name, ...
                    true, ...
                    subplot(length(varValues1), length(varValues2), plotID));
            end
        end                
        disableKeyPress = false;
    end

    function isExclude = filterDir()
        isExclude = false;
        dirParts = strsplit(directories(fID).name, '_');
        %if(strcmp(dirParts{3}, '10')); isExclude = true; end;        
    end

    function getVarValues()
        varValues1 = ListHandler();
        varValues2 = ListHandler();
        for i = 1:length(directories)
            dirParts = strsplit(directories(i).name, '_');
            if(~strcmp(varValues1.List(), dirParts(fixedVarID1)))
                varValues1.Add(dirParts(fixedVarID1));
            end
            if(~strcmp(varValues2.List(), dirParts(fixedVarID2)))
                varValues2.Add(dirParts(fixedVarID2));
            end
        end
        varValues1 = varValues1.Data;
        varValues2 = varValues2.Data;
        
        for i = 1:length(directories)
            dirParts = strsplit(directories(i).name, '_');
            if(strcmp(varValues1{1}, dirParts(fixedVarID1)) && ...
               strcmp(varValues2{1}, dirParts(fixedVarID2)))
                currentDirectories = cell(length(varValues1), length(varValues2));
                for j = 1:length(directories)
                    dirParts2 = strsplit(directories(j).name, '_');
                    for v1 = 1:length(varValues1)
                        for v2 = 1:length(varValues2)
                            isOK = true;
                            for dp = 1:length(dirParts)
                                if(dp == fixedVarID1)
                                    checkValue = varValues1{v1};
                                elseif(dp == fixedVarID2)
                                    checkValue = varValues2{v2};
                                else
                                    checkValue = dirParts(dp);
                                end
                                if(~strcmp(checkValue, dirParts2(dp)))
                                    isOK = false;
                                end
                            end 
                            if(isOK)
                                currentDirectories{v1, v2} = directories(j);
                            end
                        end
                    end
                end
                sortedDirectories.Add(currentDirectories);
            end                        
        end
        sortedDirectories = sortedDirectories.Data;
        
        fIDmax = length(directories) / (numel(varValues1) * numel(varValues2));
    end
end

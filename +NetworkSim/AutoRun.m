function AutoRun(varargin)
    % ----------------------------OBSOLETE---------------------------------
    % AUTORUN - Network Simulation start script
    %   Run the same simulation with multiple seeds and temperatures
    % ----------------------------OBSOLETE---------------------------------
    
    EvalOnly = true;
    % sourceFolder = 'e:\SimResults\2017.06.13\false_true_8_20_15_0.0085\';
    sourceFolder = 'e:\SimResults\';
    % SubFolder = datestr(date, 'yyyy.mm.dd');    
    % SubFolder = [datestr(date, 'yyyy.mm.dd') '\false_false' ];    
    SubFolder = ['2017.07.27\'];
    UseExcludeList = exist([sourceFolder 'Exclude.list'], 'file') == 2;    
    ShowTrendLine = false;
    TypeName = 'Normal'; %#ok<NASGU>
    tempType = []; % 'default' is []
    % SubFolder = [SubFolder TypeName];
    if(~isempty(varargin)); EvalOnly = varargin{1}; end;       
    if(length(varargin) > 1); SubFolder = [SubFolder '\' varargin{2}]; end;       

    rng(1);
    iterations = 2000;
    tempLimit = [32 39];    
%     iterations = 5;
%     tempLimit = [36 38];        

    temps = tempLimit(1) + (tempLimit(2)-tempLimit(1))*rand(iterations, 1);
    seeds = randi(10000, iterations, 1);
    
    % Presentation stuff TEMP
%     temps = [37.14 37.17 37.22 37.26 37.26];
%     seeds = [8747 3675 241 5985 8275];
    %seeds = 1:20; temps = ones(1, length(seeds)) * 37; 
    temps = [35 36 37]; seeds = ones(1, length(temps)) * 1;
    
    if(~EvalOnly)
        network = NetworkSim.Network();                 
        network.ampaWeightStd = 0.3;
        network.gabaWeightStd = 0;
        network.nRT_Connect = false;
        network.Create.TC_count = 100;
        network.Create.nRT_count = 20;
        network.AllowReciprocal = false;      
        network.UseCircularNetwork = true;
        network.Create.TC_to_nRT = 8;
        network.Create.TC_to_nRT_max = 20;
        network.Create.nRT_to_TC = 20;
        network.Create.nRT_to_TC_max = 50;
        network.Create.nRT_to_nRT = 0;        
        for i=1:length(temps);
            network.RandomSeed = seeds(i);
            NetworkSim.Run( ...
                'temperatures', round(temps(i), 2), ...
                'Network', network, ...
                'saveData', true, ...
                'GABAa', 0.0088, ...
                'disableJPGs', true, ...
                'varTemps', tempType, ...
                'subFolder', SubFolder);
        end
    end
        
    if(EvalOnly); EvaluateResults([sourceFolder SubFolder '\']); end;
    
    function EvaluateResults(sourceFolder)
        % Load exclusions 
        if(UseExcludeList)
            eList = load([sourceFolder 'Exclude.list'], '-mat'); 
            eList = eList.files;
        end
        % Get values
        files = dir([sourceFolder '*.mat']);        
        temperatures = ListHandler();
        frequencies = ListHandler();
        temperaturesEx = ListHandler();
        frequenciesEx = ListHandler();
        for f = 1:numel(files)            
            if(strfind(files(f).name, 'result_data')); continue; end;             
            result = load([sourceFolder files(f).name]);            
            % frequencies(f) = result.currentFreq;            
            [currFreq, currentExclude] = getFrequency(result.MUA.Sum);
            eList(f).exclude = currentExclude;
            % if(result.temperatures(1) > 36.5 && currFreq < 12); continue; end;
            %if(result.temperatures(1) > 38); continue; end;
            % if(sum(result.MUA.TC) == 0); continue; end;              
            % eList(f).exclude = false;
%             if(length(result.distances) > 3 && (result.distances(3) < 10 || result.distances(4) < 10)); 
%                 eList(f).exclude = true; else eList(f).exclude = false; end;
            if(UseExcludeList && eList(f).exclude)
                frequenciesEx.Add(currFreq);
                temperaturesEx.Add(result.temperatures(1));
            else
                frequencies.Add(currFreq);
                temperatures.Add(result.temperatures(1));
            end
        end
        if(UseExcludeList)
            % Resave excludelist even if no change happened, so testing is easier
            files = eList;  %#ok<NASGU>
            save([sourceFolder 'Exclude.list'], 'files', '-mat'); 
        end
        
        temperatures = temperatures.List();
        frequencies = frequencies.List();
        temperaturesEx = temperaturesEx.List();
        frequenciesEx = frequenciesEx.List();
        [correlation, p] = corrcoef(temperatures, frequencies);
        % Plot scatter
        resultFig = figure('Name', sourceFolder, 'Visible', 'on', 'Units', 'Normalized','OuterPosition', [0 0 1 1]); %#ok<NASGU>
        ax = axes;
        hold on;                
        scatter(temperatures, frequencies, 'filled');  
        scatter(temperaturesEx, frequenciesEx, 'filled', 'r');        
        if(ShowTrendLine)
            myfit = polyfit(temperatures, frequencies, 1);
            plot([min(temperatures) max(temperatures)], ...
                 [myfit(1)*min(temperatures)+myfit(2) myfit(1)*max(temperatures)+myfit(2)], ...
                 'b', 'Linewidth', 5);
        end        
        hold off;
        % set(ax, 'ylim', [10.5 14]);
        fontSize = 12;
        set(ax, 'FontSize', fontSize);
        xlabel('Temperature', 'FontSize', fontSize);
        ylabel('Spindle frequency', 'FontSize', fontSize);                
        title({['Correlation: ' num2str(correlation(1,2))]; ['P: ' num2str(p(1,2))]}, 'FontSize', fontSize);
        
        % Save data
        warning('off', 'MATLAB:Figure:FigureSavedToMATFile');
        fName = 'result_data';
        if(UseExcludeList); fName = [fName '_filtered']; end;
        saveas(resultFig, [sourceFolder fName '.eps'], 'epsc2'); % Save Figure as .eps
        save([sourceFolder fName '.mat'], ...
            'temperatures', ...
            'frequencies', ...
            'temperaturesEx', ...
            'frequenciesEx', ...
            'correlation', ...
            'p', ...
            'resultFig', ...
            'TypeName');        
        warning('on', 'MATLAB:Figure:FigureSavedToMATFile');
    end

    % TEMP TESTING OF FREQUENCY DETECT
    function [result, excludeCurrent] = getFrequency(fMUA)
        excludeCurrent = false;
        currentTroughsRel = ListHandler();        
        currentMin = Other.LocalMinima(-fMUA, 50 / 0.1, -max(fMUA)/4);
        for currentID = 1:length(currentMin)
            currentTroughsRel.Add(currentMin(currentID));
        end          
        freqs = 1000./(diff(currentTroughsRel.List())*0.1);
        %freqs = freqs(freqs > 9);
        %if(min(freqs) < 8); excludeCurrent = true; end;
        result = mean(freqs);
    end
end

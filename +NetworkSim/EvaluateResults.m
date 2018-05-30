function ax = EvaluateResults(sourceFolder, tempLimit, UseExcludeList, ShowTrendLine, SavePlot, varargin)
    % EVALUEATERESULTS - Evaluates a result file
    %   This is a subfunction used by other displays
    %   Calculates the temperature - frequency table of multiple
    %   simulations
    %   Displays or returns the scatter plot of the calculated values

    % figure; ax1 = NetworkSim.EvaluateResults('e:\SimResults\2017.10.20\1\Normal\', 37.5, true, true, axes); a = get(ax1, 'Children');  set(a(2), 'Visible', 'off');
    
    parser = inputParser;
    validTypes = {'frequency', 'spindleLength', 'throughCount'};
    addOptional(parser,'Type', validTypes{1}, @(x) any(validatestring(x, validTypes)));
    parse(parser,varargin{:}); parser = parser.Results;
    
    % Load exclusions 
    if(UseExcludeList)
        excludeFileName = [sourceFolder 'Exclude.list'];
        if (exist(excludeFileName, 'file') == 2)
            eList = load(excludeFileName, '-mat'); 
            eList = eList.files;
        else
            eList = dir([sourceFolder '*.mat']);
            for i = 1:length(eList)
                eList(i).exclude = false;
            end
        end
    end
    % Get values
    files = dir([sourceFolder '*.mat']);        
    temperatures = ListHandler();
    output = ListHandler();
    temperaturesEx = ListHandler();
    outputEx = ListHandler();
    for f = 1:numel(files)            
        if(strfind(files(f).name, 'result_data')); continue; end;             
        result = load([sourceFolder files(f).name], 'MUA', 'temperatures');             
        % output(f) = result.currentFreq;            
        [currFreq, currentExclude, currTroughs] = getFrequency(result.MUA.Sum);
        eList(f).exclude = currentExclude;
        % if(result.temperatures(1) > 36.5 && currFreq < 12); continue; end;
        if ~isempty(tempLimit)
            if(result.temperatures(1) > tempLimit); continue; end;
        end
        % if(sum(result.MUA.TC) == 0); continue; end;              
        % eList(f).exclude = false;
%             if(length(result.distances) > 3 && (result.distances(3) < 10 || result.distances(4) < 10)); 
%                 eList(f).exclude = true; else eList(f).exclude = false; end;
        
        switch parser.Type
            case validTypes{1}
                currValue = currFreq;
            case validTypes{2}
                currValue = currTroughs(end) - currTroughs(1);
            case validTypes{3}
                currValue = length(currTroughs);
            otherwise
                currValue = 0;
        end
        if(UseExcludeList && eList(f).exclude)
            outputEx.Add(currValue);
            temperaturesEx.Add(result.temperatures(1));
        else
            output.Add(currValue);
            temperatures.Add(result.temperatures(1));
        end
    end
    if(UseExcludeList)
        % Resave excludelist even if no change happened, so testing is easier
        files = eList;  %#ok<NASGU>
        save(excludeFileName, 'files', '-mat'); 
    end

    temperatures = temperatures.List();
    output = output.List();
    temperaturesEx = temperaturesEx.List();
    outputEx = outputEx.List();
    [correlation, p] = corrcoef(temperatures, output);
    % Plot scatter   
    if(isstruct(SavePlot))
        resultFig = figure('Name', sourceFolder, 'Visible', 'off', 'Units', 'Normalized','OuterPosition', [0 0 1 1]); %#ok<NASGU>                        
        ax = axes(resultFig);
    else
        ax = SavePlot;
    end    
    hold on;                
    scatter(temperatures, output, 'filled');  
    scatter(temperaturesEx, outputEx, 'filled', 'r');        
    if(ShowTrendLine)
        myfit = polyfit(temperatures, output, 1);
        plot([min(temperatures) max(temperatures)], ...
             [myfit(1)*min(temperatures)+myfit(2) myfit(1)*max(temperatures)+myfit(2)], ...
             'b', 'Linewidth', 5);
    end        
    hold off;
    % set(ax, 'ylim', [10.5 14]);
    fontSize = 12; % 32;
    set(ax, 'FontSize', fontSize);
    xlabel('Temperature', 'FontSize', fontSize);    
    switch parser.Type
        case validTypes{1}
            yLabelText = 'Spindle frequency';
        case validTypes{2}
            yLabelText = 'Spindle length';
        case validTypes{3}
            yLabelText = 'Spindle trough count';
        otherwise
            yLabelText = 'Values';
    end
    ylabel(yLabelText, 'FontSize', fontSize);                
    title({['Correlation: ' num2str(correlation(1,2))]; ['P: ' num2str(p(1,2))]}, 'FontSize', fontSize);

    % Save data
    if(isstruct(SavePlot))        
        warning('off', 'MATLAB:Figure:FigureSavedToMATFile');
        fName = [SavePlot.TypeName '_' num2str(tempLimit)];
        if(UseExcludeList); fName = [fName '_filtered']; end;
        saveas(resultFig, [sourceFolder fName '.eps'], 'epsc2'); % Save Figure as .eps     
        saveas(resultFig, [sourceFolder fName '.jpg']); % Save Figure as .eps     
        copyfile([sourceFolder fName '.jpg'], [SavePlot.OutputFolder fName '.jpg']);
        TypeName = SavePlot.TypeName; %#ok<NASGU>
        save([sourceFolder 'result_data' '.mat'], ...
            'temperatures', ...
            'output', ...
            'temperaturesEx', ...
            'outputEx', ...
            'correlation', ...
            'p', ...
            'resultFig', ...
            'TypeName');        
        warning('on', 'MATLAB:Figure:FigureSavedToMATFile');
        close(resultFig);
    end

    % TEMP TESTING OF FREQUENCY DETECT
    function [result, excludeCurrent, troughs] = getFrequency(fMUA)
        excludeCurrent = false;
        currentTroughsRel = ListHandler();        
        currentMin = Other.LocalMinima(-fMUA, 50 / 0.1, -max(fMUA)/4);
        for currentID = 1:length(currentMin)
            currentTroughsRel.Add(currentMin(currentID));
        end                  
        troughs = currentTroughsRel.List();
        freqs = 1000./(diff(troughs)*0.1);
        %freqs = freqs(freqs > 9);        
        if(min(freqs) < 8); excludeCurrent = true; end;
        result = mean(freqs);
    end
end

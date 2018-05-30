function DisplaySummary(varargin)
    % DISPLAYSUMMARY - Display the summary of an AutoRun
    
    mainPath = 'e:\SimResults\2017.09.19\6\Normal\';    
    tempLimit = 39;
    displayTag = 'Summary';
    currentID = 10;
    lastSelected = [];
    ax1Xlim = [];
    ax1Ylim = [];

    p = inputParser;
    validTypes = {'frequency', 'spindleLength', 'throughCount'};
    addOptional(p,'Type', validTypes{1}, @(x) any(validatestring(x, validTypes)));
    addOptional(p,'mainPath', mainPath);
    addOptional(p,'tempLimit', tempLimit, @isnumeric);
    addOptional(p,'displayTag', displayTag);
    parse(p, varargin{:}); p = p.Results;
    mainPath = p.mainPath;
    tempLimit = p.tempLimit;
    displayTag = p.displayTag;    
    
    figure('Name', displayTag, 'NumberTitle', 'Off', 'Visible', 'On', 'Units', 'Normalized', ...
           'OuterPosition', [0 0 1 1], ...
           'KeyPressFcn', @keyPress, ...
           'KeyReleaseFcn', @keyRelease);    
    ax1 = NetworkSim.EvaluateResults(mainPath, tempLimit, true, false, subplot(1, 2, 1), 'Type', p.Type);
    
    hold(ax1, 'on');
    scatterPlot = get(ax1, 'Children'); 
    scatterPlotEx = scatterPlot(1);   
    scatterPlot = scatterPlot(2);   
    set(scatterPlot, 'ButtonDownFcn', @scatterPointClick);
    set(scatterPlotEx, 'ButtonDownFcn', @scatterPointClick);
    x = [get(scatterPlot, 'xData') get(scatterPlotEx, 'xData')];
    y = [get(scatterPlot, 'yData') get(scatterPlotEx, 'yData')];
    ax2 = subplot(1, 2, 2);
    set(ax1, 'OuterPosition', [0 0 0.5 1]);
    set(ax2, 'OuterPosition', [0.5 0 0.5 1]);    
    ax1Xlim = get(ax1, 'Xlim');
    ax1Ylim = get(ax1, 'Ylim');
    selectPoint(1);        
    
    function scatterPointClick(~, e)
        [~, pid] = min((e.IntersectionPoint(1)-x).^2 + (e.IntersectionPoint(2)-y).^2);        
        selectPoint(pid);
    end

    function displaySubPlot(temperature, value)
        cla(ax2);
        jpgFileName = dir([mainPath '*_' num2str(temperature, '%.2f') '_*.jpg']);                
        matFileName = dir([mainPath '*_' num2str(temperature, '%.2f') '_*.mat']);
        jpgID = 1;        
        if(length(matFileName) > 1)            
            for i = 1:length(matFileName)
                result = load([mainPath matFileName(i).name]);                
                if(result.currentFreq == value)
                    jpgID = i;
                end
            end
        end
        result = load([mainPath matFileName(jpgID).name]);        
        image(ax2, imread([mainPath jpgFileName(jpgID).name]), 'HitTest', 'Off');       
        title(ax2, [num2str(temperature, '%.2f') ' - ' num2str(result.network.RandomSeed)]);        
        % SetUp click function        
        set(ax2, 'ButtonDownFcn', {@DoubleClickCallBack, matFileName(jpgID).name});            
    end

    function DoubleClickCallBack(~, ~, matFileName)
        seltype = get(gcf,'SelectionType');
        if(~strcmp(seltype, 'open')); return; end;
        result = load([mainPath matFileName], 'network');
        figure('Name', [displayTag ' - ' matFileName], 'NumberTitle', 'Off', 'Visible', 'On', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        subplot(2,2,[1 3]);
        result.network.Examine();
        subplot(2,2,2);
        result.network.PlotBars('TC');
        subplot(2,2,4);
        result.network.PlotBars('nRT');
        % result.network.Show(figure);
    end

    function selectPoint(pid)
        currentID = pid;               
        if(~isempty(lastSelected)); delete(lastSelected); end;
        lastSelected = scatter(ax1, x(pid), y(pid), 'filled', 'g', 'HitTest', 'Off');
        displaySubPlot(x(pid), y(pid));        
    end

    function keyPress(~, e)
        currID = currentID;
        switch e.Key
            case 'rightarrow'
                currID = currID + 1;
            case 'leftarrow'
                currID = currID - 1;
            case 'h'                
                set(scatterPlotEx, 'Visible', 'Off');
                set(ax1, 'Xlim', ax1Xlim, 'Ylim', ax1Ylim);            
            otherwise  
        end
        if(currID < 1); currID = 1; end;
        if(currID > length(x)); currID = length(x); end;
        selectPoint(currID);
    end

    function keyRelease(~, e)
        switch e.Key
            case 'h'
                set(scatterPlotEx, 'Visible', 'On');                
            otherwise  
        end
    end
end
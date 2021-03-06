function AutoRunSummary2(varargin)    
    % AUTORUNSUMMARY2 - Summarize result of the different AutoRun type
    % functions    

    % [2 4 5 6 8 9 10]
    % IDs = [4 6 22 25 30 32 40 44 48 89]; for i=1:length(IDs); NetworkSim.AutoRunSummary(IDs(i), scrollsubplot(3, 3, i)); end;

    getFilteredData = false;
    reCalc = false;
    mainSeed = 1;    
    tempLimit = 37.5;
    parentAxes = [];
    fontSize = 12; % 30;
    if(~isempty(varargin)); mainSeed = varargin{1}; end;
    if(length(varargin) > 1); parentAxes = varargin{2}; end;

    filtered = '';
    if(getFilteredData); filtered = '_filtered'; end; %#ok<UNRCH>

    sourceFolder = 'e:\SimResults\2017.10.20\';
    sourceFolder = [sourceFolder num2str(mainSeed) '\'];
    folderList = ListHandler();
    % TODO sorrend!!!
    folderList.Add('Normal'); % Normal
    folderList.Add('IT'); % IT
    folderList.Add('IT2'); % IT2
    folderList.Add('Ih'); % Ih
    folderList.Add('AMPA'); % AMPA
    folderList.Add('GABAa'); % GABAa

%     folderList.Add('2017.03.14'); % Normal
%     folderList.Add('2017.03.24'); % IT
%     folderList.Add('2017.03.27'); % IT2
%     folderList.Add('2017.03.29'); % Ih
%     folderList.Add('2017.03.31'); % AMPA
%     folderList.Add('2017.04.02'); % GABAa
%     folderList.Add('2017.03.22'); % IT ex
%     folderList.Add('2017.04.05'); % IT2 ex
%     folderList.Add('2017.04.07'); % Ih ex
%     folderList.Add('2017.04.09'); % AMPA ex
%     folderList.Add('2017.04.12'); % GABAa ex
    
    typeList = ListHandler();
    corrList = ListHandler();    
    pList = ListHandler();    
    
    if reCalc
        NetworkSim.AutoRunParallel(true, mainSeed); %#ok<UNRCH>
    end
    
    for i = 1:folderList.Length                        
        set(0, 'DefaultFigureCreateFcn', @(s,e)delete(s)); % CAREFUL!!!
        try
            data = load([sourceFolder folderList.List(i) '\result_data' filtered '.mat'], 'TypeName', 'correlation', 'p');
        catch ME
            set(0, 'DefaultFigureCreateFcn', ''); % CAREFUL!!!
            throw(ME);
        end               
        set(0, 'DefaultFigureCreateFcn', ''); % CAREFUL!!!
        typeList.Add(data.TypeName);
        corrList.Add(data.correlation(1,2));
        pList.Add(data.p(1,2));
    end
    
    if isempty(parentAxes) 
        f = figure('Name', ['Correlation Bar Plot ' num2str(mainSeed)], 'NumberTitle', 'Off', 'Units', 'Normalized', 'OuterPosition', [0 0 0.6 0.7]); 
        parentAxes = axes(f);
    end
    title(num2str(mainSeed));
    hold on;
    for i=1:typeList.Length
        b = bar(parentAxes, i, corrList.List(i), 0.7, ...            
            'ButtonDownFcn', {@DoubleClickCallBack, [sourceFolder folderList.List(i) '\'], mainSeed});  
        if pList.List(i) > 0.05
            b.FaceColor = 'r';
        end
    end
    hold off;
    corrValues = corrList.List();
    corrValues(corrValues < 0) = 0;
    text(1:length(corrValues), ...
         corrValues, ...
         num2str(corrList.List(),'%0.2f'),...
         'HorizontalAlignment','center',...
         'VerticalAlignment','bottom', ...
         'Parent', parentAxes, ...
         'FontSize', fontSize);
    set(parentAxes, 'xTick', 1:length(corrValues), 'xTickLabel', typeList.Data, 'FontSize', fontSize, 'XLim', [0.5 typeList.Length + 0.5]);
    
    % saveas(f, [pwd '\' get(f, 'Name') '.eps'], 'epsc2');
    
    % Click function
    function DoubleClickCallBack(~, ~, currPath, i)
        seltype = get(gcf,'SelectionType');                
        if(~strcmp(seltype, 'open')); return; end;
        disp(['Opening ' currPath]);
        NetworkSim.DisplaySummary('mainPath', currPath, 'tempLimit', tempLimit, 'displayTag', num2str(i));
    end
end

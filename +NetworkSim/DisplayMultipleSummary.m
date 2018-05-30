function DisplayMultipleSummary(varargin)   
    % DISPLAYMULTIPLESUMMARY - Display the summary of multiple AutoRuns

    mainPath = 'e:\SimResults\2017.09.19\';
    subFolder = 'Normal\';
    showExclude = true;
    tempLimit = 38;
    useList = true; % If true, goodList is used as reference, if false, program reads the numbered folders in mainPath
    includeList = [0 0 0 1];
    topList = [4 6 22 25 30 32 40 44 48 89];
    goodList = [5 8 10 31 34 39 61 63 64 66 79];    
    maybeList = [2 46 47 59 68];
    otherList = [1 2 3 4 5 6];
    
    p = inputParser;
    addOptional(p,'useList', useList);
    addOptional(p,'includeList', includeList);
    parse(p, varargin{:}); p = p.Results;
    useList = p.useList;       
    includeList = p.includeList;
    
    figure('Name', ['MultiDisplay - ' num2str(tempLimit)], 'NumberTitle', 'Off', 'Visible', 'On', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    folderIDs = ListHandler();        
    
    % Get list
    if(useList)
        folderIDs = [];
        if(includeList(1)); folderIDs = [folderIDs topList]; end;
        if(includeList(2)); folderIDs = [folderIDs goodList]; end;
        if(includeList(3)); folderIDs = [folderIDs maybeList]; end;
        if(includeList(4)); folderIDs = [folderIDs otherList]; end;
        folderIDs = sort(folderIDs);
    else
        % Get folder ids
        files = dir(mainPath); 
        folders = files([files.isdir]);
        for i=1:length(folders)
            folderIDs.Add(str2double(folders(i).name));
        end
        folderIDs = folderIDs.List();
        folderIDs = sort(folderIDs(folderIDs == folderIDs));
    end
    
    % Loop through folders
    pWidth = 3;
    pHeight = 3;
    for i = 1:length(folderIDs)
        % if(i>3); break; end;
        ax = scrollsubplot(pWidth, pHeight, i);        
        currPath = [mainPath num2str(folderIDs(i)) '\' subFolder];
        set(ax, 'ButtonDownFcn', {@DoubleClickCallBack, currPath, folderIDs(i)});
        NetworkSim.EvaluateResults(currPath, tempLimit, showExclude, false, ax);
        title(num2str(folderIDs(i)));
        disp([num2str(folderIDs(i)) ' loaded']);
    end
    
    % Click function
    function DoubleClickCallBack(~, ~, currPath, i)
        seltype = get(gcf,'SelectionType');
        if(~strcmp(seltype, 'open')); return; end;
        disp(['Opening ' currPath]);
        NetworkSim.DisplaySummary('mainPath', currPath, 'tempLimit', tempLimit, 'displayTag', num2str(i));
    end
end

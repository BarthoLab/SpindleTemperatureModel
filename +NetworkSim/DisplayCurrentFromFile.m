function DisplayCurrentFromFile()   
    % DISPLAYCURRENTFROMFILE - Display the results of a single simulation

    currentPath = 'e:\SimResults\2017.08.16\Normal\';
    files = dir([currentPath '*985.mat']);
    % 8833
    % 985
    % 3596
    % 2345
    % 1797
    CellType = 'nRT';   
    % CellRange = 49:50;
    CellRange = [];    
    dt = 0.1;    
    
    figure('Visible', 'On', 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);  
    
    if(strcmp(CellType, 'TC'))
        PlotSize = 4; 
    end            
    if(strcmp(CellType, 'nRT')) 
        PlotSize = 3;
    end    
    
    ax1 = subplot(PlotSize, 1, 1); hold(ax1);
    ax2 = subplot(PlotSize, 1, 2); hold(ax2);
    if(strcmp(CellType, 'TC'))
        ax3 = subplot(PlotSize, 1, 3); hold(ax3);
    end
    ax4 = subplot(PlotSize, 1, PlotSize); hold(ax4);  
    legendString = ListHandler();
        
    for fileID = 1:length(files)  
        if(strcmp(files(fileID).name, 'result_data.mat')); continue; end;
        a = load([currentPath files(fileID).name]);  
        a = a.detailedResults.(CellType);
        if(isempty(CellRange))
            CellRange = 1:numel(a);
        end
        a = [a{CellRange}];        
        legendText = strsplit(files(fileID).name, '.');
        legendText = strsplit(char(legendText(1)), '_'); 
        legendText = char(legendText(end));        
        legendString.Add(legendText);             
        
        for cellID = 1:numel(a)
            if(strcmp(CellType, 'TC'))
                a(cellID).GABAa = sum(cell2mat(a(cellID).GABAa), 2);
                a(cellID).GABAb = sum(cell2mat(a(cellID).GABAb), 2);
            end
            if(strcmp(CellType, 'nRT'))
                a(cellID).AMPA = sum(cell2mat(a(cellID).AMPA), 2);
            end
        end
        
        t = dt:dt:(size([a.MembranePotential], 1)*dt);
        
        plot(ax1, t, mean([a.MembranePotential], 2));         
        if(strcmp(CellType, 'TC'))
            plot(ax2, t, mean([a.IT], 2)); 
            plot(ax3, t, mean([a.Ih], 2));             
            plot(ax4, t, mean([a.GABAa], 2));             
        end
        if(strcmp(CellType, 'nRT'))
            plot(ax2, t, mean([a.IT2], 2)); 
            plot(ax4, t, mean([a.AMPA], 2));             
        end                   
        
        % Plot settings
        set(ax1, 'xlim', [0 t(end)]);  ylabel(ax1, 'Membrane Potential (mV)');            
        set(ax2, 'xlim', [0 t(end)]); ylabel(ax2, 'T current (nA)');
        if(strcmp(CellType, 'TC'))
           set(ax3, 'xlim', [0 t(end)]); ylabel(ax3, 'h current (nA)');
        end        
        set(ax4, 'xlim', [0 t(end)]);       
        if(strcmp(CellType, 'TC')); ylabel(ax4, 'GABAa Current (nA)'); end;
        if(strcmp(CellType, 'nRT')); ylabel(ax4, 'AMPA Current (nA)'); end;   
    end
    
    legend(ax1, legendString.Data);
    title(ax1, [CellType ' cell currents']);
end

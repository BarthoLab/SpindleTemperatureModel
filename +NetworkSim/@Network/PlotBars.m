function PlotBars(obj, type)        
    outDeg = outdegree(obj.NetworkGraph);
    inDeg = indegree(obj.NetworkGraph);
    outList = ListHandler();            
    inList = ListHandler();
    for degID = 1:length(outDeg)
        currName = obj.NetworkGraph.Nodes{degID, 'Name'}{:};
        if (~isempty(strfind(currName, type)))
            outList.Add(outDeg(degID));
            inList.Add(inDeg(degID));
        end                                    
    end    
    outList = outList.List();            
    inList = inList.List();            
            
    if (~isempty(strfind(type, 'TC')))
        outColor = obj.TC_to_nRT_color;
        inColor = obj.nRT_to_TC_color;
    end
    if (~isempty(strfind(type, 'nRT')))
        outColor = obj.nRT_to_TC_color;
        inColor = obj.TC_to_nRT_color;
    end
    
    % Plot
    hold on;    
    bar(outList, 1,'facecolor', outColor, 'LineWidth', 0.01);
    bar(-inList, 1,'facecolor', inColor, 'LineWidth', 0.01);            
    axis tight;
    labels = get(gca, 'YTick');    
    set(gca, 'FontSize', 15, 'YTickLabel', cellstr(num2str(abs(labels(:)))));
    hold off;
end

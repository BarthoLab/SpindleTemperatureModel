classdef Network < handle
    % Network class
    %   Used as an input for the <a href="matlab:help NetworkSim.Sim">Sim</a> class
    %   Creates a network of TC and nRT cells for simulation purposes
    % Network properties
    %   Create
    %       Struct - <a href="matlab:display('  Network Create default'); display(NetworkSim.Network.Create_default)">default</a>             
    %       Network creation settings. CreateNetwork method runs based on this
    %       TC_count, nRT_count
    %           Integer values
    %       TC_to_nRT, nRT_to_TC, nRT_to_nRT
    %           Number of connections from the given cell type to the
    %           target cell type
    %       TC_to_nRT_max, nRT_to_TC_max
    %           The closest number of cells the connection is allowed to 
    %           target
    %       TC_to_nRT_sigma, nRT_to_TC_sigma 
    %           Sigma of the normal distribution that decides which cells
    %           will be targeted from the available set
    %   RandomSeed         
    %       Integer - default 1234
    %       Random seed responsible for the synaptic weights 
    %   ampaWeightStd      
    %       Integer - default 0
    %       Standard deviation of the AMPA synaps weights 
    %   gabaWeightStd      
    %       Integer - default 0
    %       Standard deviation of the GABA synaps weights 
    %   nRT_AutoConnect	
    %       Boolean - default false
    %       Allow the nRT cells to connect to themselves 
    %   nRT_Connect
    %       Boolean - default true
    %       Allow the connection between nRT cells     
    %   AllowReciprocal
    %       Boolean - default true
    %       If false disable reciprocal connections between TC and nRT
    %       cells by randomly deleting one of the receptor sites
    %   UseCircularNetwork
    %       Boolean - default false
    %       If true the network creates a circular topology instead of the
    %       parallel topology
    %   UseRandomNetwork
    %       Boolean - default false
    %       (Obsolete) Create a randomly connected network without rules
    % Network properties (Read only)
    %   NetworkGraph       
    %       <a href="matlab:help digraph">digraph</a>
    %       Object for display purposes 
    %   TC_count           
    %       Integer
    %       Number of TC cells in the network 
    %   TypeCounts
    %       Integer array (1, 3)
    %       Number of the different connections in the system
    %       TC_to_nRT, nRT_to_TC, nRT_to_nRT
    %   nRT_count          
    %       Integer
    %       Number of nRT cells in the network 
    % Network methods  
    %   Add_Edge(fromName, toName, weight)	
    %       Add a new directed connection to the network 
    %       fromName - The name of the source cell
    %       toName - The name of the target cell
    %       weight - Relative value of the synaptic weight
    %  	Add_TC()
    %       Add a TC cell to the network 
    %  	Add_nRT()	
    %       Add an nRT cell to the network 
    %  	Clear()
    %       Clear the cells and connections in the network 
    %  	CreateNetwork()
    %       Create network based on Network.Create Struct
    %  	GetCreateSettings()
    %       Get the current settings as a concatenated string 
    %   Show(parent, )
    %       Display an interactive directed graph (<a href="matlab:help digraph">digraph</a>) of the network
    %       parent - Figure or axes object holding the plot
    %       AllowEdit - (Optional) Allows editing of plot in gui
    %       FixedPositions - (Optional) Overwrites Layout with the fixed 
    %                        parallel positions of the cells
    %       Layout - (Optional) Layout option of digraph plot. Only works 
    %                if FixedPositions is false
    %   Examine
    %       Display cell connections in a colored matrix on the current
    %       axes
    %   PlotBars
    %       Display the in and out connections of the cells of the given
    %       cell type on the current axes
    %       Type - TC or nRT string
    %
    %   <a href="matlab:type('NetworkSim\Help\NetworkExample.m')">Example</a>             
    %   <a href="matlab:type('NetworkSim\Help\NetworkExample2.m')">Example2</a>             
    
    %% Public properties
    properties(SetAccess = public)                
        nRT_AutoConnect = false, % (Boolean) Allow the nRT cells to connect to themselves
        nRT_Connect = true, % (Boolean) Allow the connection between nRT cells
        RandomSeed = 1234, % Random seed responsible for the weights
        ampaWeightStd = 0, % Standard deviation of the AMPA synaps weights
        gabaWeightStd = 0, % Standard deviation of the GABA synaps weights
        % Struct of network creation settings (<a href="matlab:display('  Network Create default'); display(NetworkSim.Network.Create_default)">default</a>)               
        Create,
        AllowReciprocal = true, % Allow reciprocal connections between TC and nRT cells
        UseCircularNetwork = false, % Create circular or parallel topology
        UseRandomNetwork = false % (Obsolete) Create network without rules
    end
    
    %% Constant properties
    properties(Constant=true, Hidden=true)   
        Create_default = struct(...
            'TC_count', 2, ...
            'nRT_count', 2, ...
            'TC_to_nRT', 2, ...
            'TC_to_nRT_max', 0, ...
            'TC_to_nRT_sigma', [], ...
            'nRT_to_TC', 2, ...
            'nRT_to_TC_max', 0, ...
            'nRT_to_TC_sigma', [], ...
            'nRT_to_nRT', 1);
    end
    
    %% Read only properties
    properties(SetAccess = private)
        TC_count = 0, % Number of TC cells in the network
        nRT_count = 0, % Number of nRT cells in the network
        % Number of the different connections in the system
        %   TC_to_nRT
        %   nRT_to_TC
        %   nRT_to_nRT
        TypeCounts = zeros(1, 3),
        NetworkGraph = digraph % <a href="matlab:web('www.mathworks.com\help\matlab\ref\digraph.html')">digraph</a> object for display purposes
    end
    
    %% Private properties
    properties(Access = private, Hidden=true)   
        % Colors
        TC_color = 'r';
        nRT_color = 'b';
        TC_to_nRT_color = 'r'; % EdgeType = 1
        nRT_to_TC_color = 'b'; % EdgeType = 2
        nRT_to_nRT_color = 'g'; % EdgeType = 3        
    end
    
    %% Public methods
    methods
        function obj = Network()          
            % Constructor
             obj.Create = obj.Create_default;
             obj.TC_color = 'k';
             obj.nRT_color = 'r';
             obj.TC_to_nRT_color = 'k'; % EdgeType = 1
             obj.nRT_to_TC_color = 'r'; % EdgeType = 2
        end
        
        Examine(obj);
        PlotBars(obj, type);
        
        % Display network
        function Show(obj, parent, varargin)
            % Display an interactive directed graph (<a href="matlab:web('www.mathworks.com\help\matlab\ref\digraph.html')">digraph</a>) of the network
            
            p = inputParser;
            addOptional(p,'AllowEdit', true, @islogical);
            addOptional(p,'FixedPositions', true, @islogical); % Overwrites Layout
            addOptional(p,'Layout', 'auto');                   % Only works if FixedPositions is false
            parse(p,varargin{:}); p = p.Results;
            
            a = axes(parent);
            h = plot(obj.NetworkGraph, 'Parent', a, 'Layout', p.Layout);                                    
            SetNodes();    
            SetEdges();
            axis off;
             
            % Set network controllers
            if(p.AllowEdit)
                f = General.GetParentFigure(parent);                        
                set(f, 'WindowButtonDownFcn', @(f,~)edit_graph(f,h));            
            end
            
            % Edit functions
            function edit_graph(~,~)
                pt = a.CurrentPoint(1,1:2);
                dx = h.XData - pt(1);
                dy = h.YData - pt(2);
                len = sqrt(dx.^2 + dy.^2);
                [lmin,idx] = min(len);
                tol = max(diff(a.XLim),diff(a.YLim))/20;
                if isempty(idx) || lmin > tol
                    return;
                end
                node = idx(1);
                f.WindowButtonMotionFcn = @motion_fcn;
                f.WindowButtonUpFcn = @release_fcn;
                            
                function motion_fcn(~,~)
                  newx = a.CurrentPoint(1,1);
                  newy = a.CurrentPoint(1,2);
                  h.XData(node) = newx;
                  h.YData(node) = newy;
                  drawnow;
                end
                            
                function release_fcn(~,~)
                  f.WindowButtonMotionFcn = [];
                  f.WindowButtonUpFcn = [];
                end
            end
            
            % Set Nodes
            function SetNodes()                
                nRT_x = 0; nRT_y = 0; TC_x = 0; TC_y_min = 1; TC_y_max = 1; TC_y = TC_y_min;
                currentXData = zeros(1, height(obj.NetworkGraph.Nodes));
                currentYData = zeros(1, height(obj.NetworkGraph.Nodes));                
                for nodeID = 1:height(obj.NetworkGraph.Nodes)
                    highlight(h, nodeID,'NodeColor', obj.NetworkGraph.Nodes.NodeColor(nodeID), 'MarkerSize', 7);                    
                    if ~isempty(cell2mat(strfind(obj.NetworkGraph.Nodes.Name(nodeID), 'TC')))
                        if(TC_y > TC_y_max); TC_y = TC_y_min; end; 
                        currentXData(nodeID) = TC_x;
                        % currentYData(nodeID) = normrnd(TC_y, 0.03);
                        currentYData(nodeID) = TC_y;
                        TC_y = TC_y + (TC_y_max - TC_y_min) / 4;
                        TC_x = TC_x + 1 / obj.TC_count;
                    end
                    if ~isempty(cell2mat(strfind(obj.NetworkGraph.Nodes.Name(nodeID), 'nRT')))
                        currentXData(nodeID) = nRT_x;
                        currentYData(nodeID) = nRT_y;
                        nRT_x = nRT_x + 1 / obj.nRT_count;
                    end
                end 
                if(~p.FixedPositions); return; end;
                set(h, 'XData', currentXData, 'YData', currentYData);
            end
            % Set Edges
            function SetEdges()                                                
                ColorEdge('TC', 'nRT', obj.TC_to_nRT_color);
                ColorEdge('nRT', 'TC', obj.nRT_to_TC_color);                
                function ColorEdge(from, to, currentColor)
                    fromIDs = strfind(cellstr(obj.NetworkGraph.Edges.EndNodes(:, 1)), from);
                    toIDs = strfind(cellstr(obj.NetworkGraph.Edges.EndNodes(:, 2)), to);
                    tf = cellfun('isempty', fromIDs); fromIDs(tf) = {0};
                    tf = cellfun('isempty', toIDs); toIDs(tf) = {0};
                    colorIDs = cell2mat(fromIDs) + cell2mat(toIDs);
                    colorIDs(colorIDs > 0) = 1;
                    colorIDs = find(colorIDs);
                    highlight(h, ...
                        obj.NetworkGraph.Edges.EndNodes(colorIDs, 1), ...
                        obj.NetworkGraph.Edges.EndNodes(colorIDs, 2), ...
                        'EdgeColor', currentColor, ...
                        'LineWidth', 1);
                end
%                 % set(h, 'EdgeLabel', obj.NetworkGraph.Edges.Weight);
%                 maxWeight = max(obj.NetworkGraph.Edges.Weight);      
%                 for edgeID = 1:height(obj.NetworkGraph.Edges)
%                     StartNode = obj.NetworkGraph.Edges.EndNodes(edgeID, 1);
%                     EndNode = obj.NetworkGraph.Edges.EndNodes(edgeID, 2);
%                     currentColor = obj.NetworkGraph.Edges.EdgeColor(edgeID);                    
% %                     highlight(h, StartNode, EndNode, ...
% %                               'LineWidth', 3 * obj.NetworkGraph.Edges.Weight(edgeID) / maxWeight, ...
% %                               'EdgeColor', currentColor);
%                 end
            end
        end             
        
        % Create Network
        function CreateNetwork(obj)
            % Clear network at start
            obj.Clear();
            % Create nRT
            for nRT_id = 1:obj.Create.nRT_count
                obj.Add_nRT();
            end
            % Create TC
            for TC_id = 1:obj.Create.TC_count
                obj.Add_TC();
            end 
            % Create Edges
            if(obj.UseRandomNetwork)
                obj.CreateNetworkRandom();
            else
                obj.CreateNetworkNeighbours();
            end
        end
                
        function Add_TC(obj)
            % Add a TC cell to the network
            obj.TC_count = obj.TC_count + 1;
            currentNode = table;
            currentNode.Name = {['TC' num2str(obj.TC_count)]}; 
            currentNode.NodeColor = obj.TC_color;
            obj.NetworkGraph = addnode(obj.NetworkGraph, currentNode);
        end
                
        function Add_nRT(obj)
            % Add an nRT cell to the network
            obj.nRT_count = obj.nRT_count + 1;
            currentNode = table;
            currentNode.Name = {['nRT' num2str(obj.nRT_count)]};            
            currentNode.NodeColor = obj.nRT_color;
            obj.NetworkGraph = addnode(obj.NetworkGraph, currentNode);
        end
                
        function Add_Edge(obj, fromName, toName, weight)
            % Add a new directed connection to the network
            % Add_Edge(fromName, toName, weight)
            %   fromName - The name of the source cell
            %   toName - The name of the target cell
            %   weight - Weight of the connection
            
            currentEdge = table;
            currentEdge.EndNodes = {fromName toName};
            currentEdge.Weight = weight;
            if ~isempty(cell2mat(strfind({fromName}, 'nRT')))                
                if ~isempty(cell2mat(strfind({toName}, 'nRT')))
                    currentEdge.EdgeColor = obj.nRT_to_nRT_color;
                    currentEdge.EdgeType = 3;
                else
                    if ~isempty(cell2mat(strfind({toName}, 'TC')))
                        currentEdge.EdgeColor = obj.nRT_to_TC_color;
                        currentEdge.EdgeType = 2;
                    end
                end               
            else
                if ~isempty(cell2mat(strfind({fromName}, 'TC')))
                    currentEdge.EdgeColor = obj.TC_to_nRT_color;
                    currentEdge.EdgeType = 1;
                end
            end
            obj.NetworkGraph = addedge(obj.NetworkGraph, currentEdge);
            obj.TypeCounts(currentEdge.EdgeType) = obj.TypeCounts(currentEdge.EdgeType) + 1;
        end
        
        function Clear(obj)
            % Clear the cells and connections in the network
            obj.NetworkGraph = rmnode(obj.NetworkGraph, 1:height(obj.NetworkGraph.Nodes));
            obj.TC_count = 0;
            obj.nRT_count = 0;
            obj.TypeCounts = zeros(1, 3);
        end
        
        function currentNetworkSettings = GetCreateSettings(obj)
            % Get the current settings as a concatenated string
            currentNetworkSettings = '';
            currentNetworkSettings = [currentNetworkSettings num2str(obj.Create.TC_count) '_'];
            currentNetworkSettings = [currentNetworkSettings num2str(obj.Create.nRT_count) '_'];
            currentNetworkSettings = [currentNetworkSettings num2str(obj.Create.TC_to_nRT) '_'];
            currentNetworkSettings = [currentNetworkSettings num2str(obj.Create.nRT_to_TC) '_'];
            currentNetworkSettings = [currentNetworkSettings num2str(obj.Create.nRT_to_nRT) '_'];
        end
    end
    
    %% Private methods
    methods (Access = private)
        % Create Network
        function CreateNetworkRandom(obj)
            % Random Number Generator
            rng(obj.RandomSeed);
            % Create TC->nRT edges
            Add_Edges('TC', 'nRT', obj.Create.TC_count, obj.Create.nRT_count, obj.Create.TC_to_nRT);
            % Create nRT->TC edges    
            Add_Edges('nRT', 'TC', obj.Create.nRT_count, obj.Create.TC_count, obj.Create.nRT_to_TC);
            % Create nRT->nRT edges
            Add_Edges('nRT', 'nRT', obj.Create.nRT_count, obj.Create.nRT_count, obj.Create.nRT_to_nRT);            
            
            function Add_Edges(from, to, from_count, to_count, connect_count)
                isProbability = (connect_count < 1);                
                if (strcmp(to,'nRT')); sigma = obj.ampaWeightStd; end;
                if (strcmp(to,'TC')); sigma = obj.gabaWeightStd; end;                
                weights = normrnd(1, sigma, from_count, to_count);
                for from_id = 1:from_count
                    if isProbability
                        for to_id = 1:to_count
                            if strcmp(from, to) && ~obj.nRT_AutoConnect && from_id == to_id; continue; end;
                            if rand() < connect_count
                                obj.Add_Edge([from num2str(from_id)], [to num2str(to_id)], weights(from_id, to_id));
                            end
                        end
                    else                                            
                        if strcmp(from, to) && ~obj.nRT_AutoConnect
                            connections = datasample(1:to_count - 1, connect_count, 'Replace', false);
                            connections(connections >= from_id) = connections(connections >= from_id) + 1;
                        else
                            connections = datasample(1:to_count, connect_count, 'Replace', false);
                        end
                        for to_id = connections
                            obj.Add_Edge([from num2str(from_id)], [to num2str(to_id)], weights(from_id, to_id));
                        end
                    end
                end
            end
        end
        
        % Create Network Neighbours
        function CreateNetworkNeighbours(obj)
            rng(obj.RandomSeed);
            % Create nRT->TC edges                       
            Add_Edges('nRT', 'TC', obj.Create.nRT_count, obj.Create.TC_count, obj.Create.nRT_to_TC, obj.Create.nRT_to_TC_max, obj.Create.nRT_to_TC_sigma);
            % Create TC->nRT edges
            Add_Edges('TC', 'nRT', obj.Create.TC_count, obj.Create.nRT_count, obj.Create.TC_to_nRT, obj.Create.TC_to_nRT_max, obj.Create.TC_to_nRT_sigma);
            
            % Delete reciprocal
            if(obj.AllowReciprocal); return; end;
            edgeIDs = randperm(height(obj.NetworkGraph.Edges));
            rmStarts = ListHandler;
            rmEnds = ListHandler;            
            edgeExclude = ListHandler;
            for edgeID = edgeIDs
                if(sum(find(edgeExclude.List() == edgeID)) > 0); continue; end;
                StartNode = obj.NetworkGraph.Edges.EndNodes(edgeID, 1);
                EndNode = obj.NetworkGraph.Edges.EndNodes(edgeID, 2);
                reciprocalEdge = findedge(obj.NetworkGraph, EndNode, StartNode);
                if(reciprocalEdge ~= 0)                           
                    edgeExclude.Add(reciprocalEdge);
                    rmStarts.Add(StartNode);
                    rmEnds.Add(EndNode);    
                end
            end                            
            rmStarts = [rmStarts.Data{:}];
            rmEnds = [rmEnds.Data{:}];
            obj.NetworkGraph = rmedge(obj.NetworkGraph, rmStarts, rmEnds);
            
            % Create nRT->nRT edges
            % TODO
            %if(obj.nRT_Connect); Add_nRT_to_nRT_Edges(); end;

            % Edge functions
            function Add_Edges(from, to, from_count, to_count, count, count_max, targetSigma)  
                if(count == 0); return; end;
                
                  % Weight
                if (strcmp(to,'nRT')); sigma = obj.ampaWeightStd; end;
                if (strcmp(to,'TC')); sigma = obj.gabaWeightStd; end;   
                maxDeviation = 0.9;
                meanWeight = 1;
                weights = normrnd(meanWeight, sigma, from_count, to_count);
                weights(weights < meanWeight - maxDeviation) = meanWeight - maxDeviation;
                weights(weights > meanWeight + maxDeviation) = meanWeight + maxDeviation;              
                
                % Connection
                if(count_max == 0); count_max = to_count; end;               
                for from_id = 1:from_count            
                    % Sigma
                    if(isempty(targetSigma))                        
                        targetSigma2 = count_max / 6; 
                    else
                        targetSigma2 = targetSigma; 
                    end
                    
%                     % Target IDs to chose from                    
%                     closest = (from_id - 1) * (to_count - 1) / (from_count - 1) + 1;                    
%                     targetStart = max(1, floor(closest - (count_max - 1) / 2));
%                     targetEnd = min(to_count, ceil(closest + (count_max - 1) / 2));
%                     targetIDs = targetStart:targetEnd;                    
%                     
%                         
%                     % Get probability distriution mean and circular targetIDs 
%                     probDistMean = (count_max + 1) / 2; 
%                     if(targetIDs(end) == to_count)
%                         targetIDsCircular = [targetIDs 1:(count_max - length(targetIDs))];                                                
%                     elseif(targetIDs(1) == 1)
%                         targetIDsCircular = [(to_count + 1 - (count_max - length(targetIDs))):to_count targetIDs];                        
%                         probDistMean = probDistMean - (count_max - length(targetIDs));                        
%                     else
%                         targetIDsCircular = targetIDs;                        
%                     end                           
%                     
%                     % Circular network settings                
%                     if(obj.UseCircularNetwork) 
%                         targetIDs = targetIDsCircular;                        
%                     end    
                    targetIDs = 1:to_count;
                    probDistMean = (from_id - 1) * (to_count - 1) / (from_count - 1) + 1; 
                    if(obj.UseCircularNetwork)                                         
                        targetStart = max(1, floor(probDistMean - (count_max - 1) / 2));
                        targetEnd = min(to_count, floor(probDistMean + (count_max - 1) / 2));
                        targetIDs = targetStart:targetEnd; 
                        if(targetIDs(end) == to_count)
                            targetIDsCircular = [targetIDs 1:(count_max - length(targetIDs))];                                                
                        elseif(targetIDs(1) == 1)
                            targetIDsCircular = [(to_count + 1 - (count_max - length(targetIDs))):to_count targetIDs];                                                
                        else
                            targetIDsCircular = targetIDs;                        
                        end 
                        targetIDs = targetIDsCircular;      
                        probDistMean = (count_max + 1) / 2; 
                    end                        
                    
                    % Select ids from target based on normal distribution
                    targetIDs = datasample(targetIDs, min(count, length(targetIDs)), ...
                                           'Weight', normpdf(1:length(targetIDs), probDistMean, targetSigma2), ...
                                           'Replace', false);  
                                       
                    % Add edges based on selected targets
                    for to_id = targetIDs
                        obj.Add_Edge([from num2str(from_id)], [to num2str(to_id)], weights(from_id, to_id));
                    end                    
                end     
               % figure; plot(tempGaussSum);
            end
        end
        
        % Obsolate, weights do not work
        function CreateNetworkNeighboursOld(obj)
            rng(obj.RandomSeed);
            % Create nRT->TC edges                       
            Add_Edges('nRT', 'TC', obj.Create.nRT_count, obj.Create.TC_count, obj.Create.nRT_to_TC, obj.Create.nRT_to_TC_max, obj.Create.nRT_to_TC_sigma);
            % Create TC->nRT edges
            Add_Edges('TC', 'nRT', obj.Create.TC_count, obj.Create.nRT_count, obj.Create.TC_to_nRT, obj.Create.TC_to_nRT_max, obj.Create.TC_to_nRT_sigma);
            
            % Delete reciprocal
            if(obj.AllowReciprocal); return; end;
            edgeIDs = randperm(height(obj.NetworkGraph.Edges));
            rmStarts = ListHandler;
            rmEnds = ListHandler;            
            edgeExclude = ListHandler;
            for edgeID = edgeIDs
                if(sum(find(edgeExclude.List() == edgeID)) > 0); continue; end;
                StartNode = obj.NetworkGraph.Edges.EndNodes(edgeID, 1);
                EndNode = obj.NetworkGraph.Edges.EndNodes(edgeID, 2);
                reciprocalEdge = findedge(obj.NetworkGraph, EndNode, StartNode);
                if(reciprocalEdge ~= 0)                           
                    edgeExclude.Add(reciprocalEdge);
                    rmStarts.Add(StartNode);
                    rmEnds.Add(EndNode);    
                end
            end                            
            rmStarts = [rmStarts.Data{:}];
            rmEnds = [rmEnds.Data{:}];
            obj.NetworkGraph = rmedge(obj.NetworkGraph, rmStarts, rmEnds);
            
            % Create nRT->nRT edges
            % TODO
            %if(obj.nRT_Connect); Add_nRT_to_nRT_Edges(); end;

            % Edge functions
            function Add_Edges(from, to, from_count, to_count, count, count_max, targetSigma)                
                if(count == 0); return; end;
                
                % Weight
                if (strcmp(to,'nRT')); sigma = obj.ampaWeightStd; end;
                if (strcmp(to,'TC')); sigma = obj.gabaWeightStd; end;   
                maxDeviation = 0.9;
                meanWeight = 1;
                weights = normrnd(meanWeight, sigma, from_count, to_count);
                weights(weights < meanWeight - maxDeviation) = meanWeight - maxDeviation;
                weights(weights > meanWeight + maxDeviation) = meanWeight + maxDeviation;                
                
                % Connection
                if(count_max == 0); count_max = to_count; end;               
                for from_id = 1:from_count                    
                    closest = from_id * (to_count + 1) / (from_count + 1);
                    targetStart = max(1, floor(closest - (count_max - 1) / 2));
                    targetEnd = min(to_count, ceil(closest + (count_max - 1) / 2));
                    targetIDs = targetStart:targetEnd;
                    if(isempty(targetSigma))                        
                        targetSigma2 = length(targetIDs) / 10; 
                    else
                        targetSigma2 = targetSigma; 
                    end
                    targetIDs = datasample(targetIDs, min(count, length(targetIDs)), ...
                                           'Weight', normpdf(1:length(targetIDs), (length(targetIDs) + 1) / 2, targetSigma2), ...
                                           'Replace', false);
                    for to_id = targetIDs
                        obj.Add_Edge([from num2str(from_id)], [to num2str(to_id)], weights(from_id, to_id));
                    end                    
                end                            
            end
            function Add_nRT_to_nRT_Edges()                
                if(obj.Create.nRT_count < 2); return; end;                
                for nRTid = 2:obj.Create.nRT_count
                    obj.Add_Edge(['nRT' num2str(nRTid)], ['nRT' num2str(nRTid - 1)]);
                    obj.Add_Edge(['nRT' num2str(nRTid - 1)], ['nRT' num2str(nRTid)]);
                    if obj.nRT_AutoConnect
                        obj.Add_Edge(['nRT' num2str(nRTid)], ['nRT' num2str(nRTid)]);
                    end
                end
                if obj.nRT_AutoConnect
                    obj.Add_Edge(['nRT' num2str(1)], ['nRT' num2str(1)]);
                end
            end
        end
    end
end

classdef ListHandler < handle     
    properties (SetAccess = protected)
        Data
    end
    
    % Events
    events
        ElementModified
        ElementAdded
        ElementRemoved        
    end
    
    methods
        % Constructor
        function obj = ListHandler()
            obj.Data = {};
        end
        
        % List
        function element = List(obj, varargin)
            % TODO - Error messages
            p = inputParser;
            addOptional(p,'id',[],@isnumeric);
            parse(p,varargin{:});
            id = p.Results.id;
            if isempty(id)
                element = [obj.Data{:}]';
            else
                element = [obj.Data{id}];
            end
        end
        
        % Modify
        function Modify(obj, id, element)
            obj.Data{id} = element;
            notify(obj, 'ElementModified', ListHandlerEDC(id, element));
        end
        
        % Add
        function Add(obj, element)
            obj.Data{end + 1} = element;
            notify(obj, 'ElementAdded', ListHandlerEDC(length(obj.Data), element));
        end
        
        % Remove
        function Remove(obj, id)
            % TODO - Error messages            
            notify(obj, 'ElementRemoved', ListHandlerEDC(id, obj.Data{id}));
            obj.Data{id} = [];
            tempData = cell(1, length(obj.Data)-1);
            tempCounter = 1;
            for i = 1:length(obj.Data)
                if ~isempty(obj.Data{i})
                    tempData{tempCounter} = obj.Data{i};
                    tempCounter = tempCounter + 1;
                end
            end
            obj.Data = tempData;                        
        end % Remove
        
        % Length
        function len = Length(obj)
            len = length(obj.Data);
        end
    end % methods
end % class

function Start(obj)
    % Starts the simulation

    % Create SubFolder
    obj.SubFolder = [datestr(date, 'YYYYMMDD') datestr(now,'HHMMSSFFF') '_' dicomuid '\' ];
    obj.SubFolder = [obj.ResultPath obj.SubFolder];
    mkdir(obj.SubFolder);
        
    % Create Network files
    if(sum(obj.Network.TypeCounts) > 0)
        CreateNetworkFiles();
    end
    
    % Start        
    [~, result] = system(CreateCommand()); 
    disp(result);       
    
    % Functions
    function startCommand = CreateCommand()
        % Set up input commands
        path = [fileparts(mfilename('fullpath')) '\']; 
        commands = ' -c "{load_file(\"nrngui.hoc\")}" ';
        commands = strcat(commands, obj.defaultCommand);    
        % Original arguments
        commands = strcat(commands, ' -c "dt_arg=', num2str(obj.dt),'" ');
        commands = strcat(commands, ' -c "v_init_arg=', num2str(obj.v_init),'" ');        
        commands = strcat(commands, ' -c "tstop_arg=', num2str(obj.tstop),'" ');
        setTemperatures()
        setStructs(obj.nRT);
        setStructs(obj.TC);
        % Variables
        commands = strcat(commands, ' -c "TC_count=', num2str(obj.Network.TC_count),'" ');
        commands = strcat(commands, ' -c "nRT_count=', num2str(obj.Network.nRT_count),'" ');    
        commands = strcat(commands, ' -c "RandomSeed=', num2str(obj.Network.RandomSeed),'" ');    
        commands = strcat(commands, ' -c "startDelay=', num2str(obj.startDelay),'" ');
        commands = strcat(commands, ' -c "SaveCurrent=', num2str(obj.SaveCurrent),'" ');
        commands = strcat(commands, ' -c "UseGaussNoise=', num2str(obj.UseGaussNoise),'" ');        
        % Filenames
        f = strrep(obj.SubFolder, '\', '\\');
        commands = strcat(commands, ' -c "strdef OutputFolder" -c "OutputFolder=\"', f(1:end-2),'\"" ');        
        commands = strcat(commands, ' -c "strdef TC_nRT_Edges" -c "TC_nRT_Edges=\"', [f obj.TC_nRT_Edges],'\"" ');        
        commands = strcat(commands, ' -c "strdef nRT_TC_Edges" -c "nRT_TC_Edges=\"', [f obj.nRT_TC_Edges],'\"" ');
        commands = strcat(commands, ' -c "strdef nRT_nRT_Edges" -c "nRT_nRT_Edges=\"', [f obj.nRT_nRT_Edges],'\"" ');
        commands = strcat(commands, ' -c "strdef TC_Results" -c "TC_Results=\"', [f obj.TC_Results],'\"" ');
        commands = strcat(commands, ' -c "strdef nRT_Results" -c "nRT_Results=\"', [f obj.nRT_Results],'\"" ');                
        startCommand = strcat(obj.nrnivPath, '  -nobanner -nogui ', commands, [' ' path], obj.simFileName, ' -c quit()');        
        
        function setStructs(currentStruct)
            fields = fieldnames(currentStruct);                        
            for fID = 1:numel(fields)
                commands = strcat(commands, ' -c "', fields{fID}, '=', num2str(currentStruct.(fields{fID})),'" ');
            end
        end
        function setTemperatures()
            fields = fieldnames(obj.temperature);                        
            for fID = 1:numel(fields)
                if strcmp(fields{fID}, 'default')
                    commands = strcat(commands, ' -c "celsius_arg=', num2str(obj.temperature.default),'" ');
                else
                    currentValue = obj.temperature.(fields{fID});
                    if isempty(currentValue); currentValue = obj.temperature.default; end;
                    commands = strcat(commands, ' -c "temperature_', fields{fID} ,'=', num2str(currentValue),'" ');
                end
            end
        end
    end
    
    function CreateNetworkFiles()        
        f = obj.SubFolder;
        fid1 = fopen([f obj.TC_nRT_Edges],'wt'); fprintf(fid1, '%s\n', num2str(obj.Network.TypeCounts(1)));
        fid2 = fopen([f obj.nRT_TC_Edges],'wt'); fprintf(fid2, '%s\n', num2str(obj.Network.TypeCounts(2)));
        fid3 = fopen([f obj.nRT_nRT_Edges],'wt'); fprintf(fid3, '%s\n', num2str(obj.Network.TypeCounts(3)));
        fid = 0;
        for edgeID = 1:height(obj.Network.NetworkGraph.Edges)
            StartNode = obj.Network.NetworkGraph.Edges.EndNodes(edgeID, 1); StartNode = StartNode{1};
            EndNode = obj.Network.NetworkGraph.Edges.EndNodes(edgeID, 2); EndNode = EndNode{1};            
            EdgeType = obj.Network.NetworkGraph.Edges.EdgeType(edgeID);  
            Weight = obj.Network.NetworkGraph.Edges.Weight(edgeID);  
            switch EdgeType
                case 1
                    StartID = str2num(StartNode(3:end)); %#ok<ST2NM>
                    EndID = str2num(EndNode(4:end)); %#ok<ST2NM>
                    fid = fid1;
                case 2                    
                    StartID = str2num(StartNode(4:end)); %#ok<ST2NM>
                    EndID = str2num(EndNode(3:end)); %#ok<ST2NM>
                    fid = fid2;
                case 3                    
                    StartID = str2num(StartNode(4:end)); %#ok<ST2NM>
                    EndID = str2num(EndNode(4:end)); %#ok<ST2NM>
                    fid = fid3;
            end
            fprintf(fid,'%s\t%s\t%s\n', ...
                        num2str(StartID - 1), ...
                        num2str(EndID - 1), ...
                        num2str(Weight));
        end
        fclose(fid1);
        fclose(fid2);
        fclose(fid3);
    end
end
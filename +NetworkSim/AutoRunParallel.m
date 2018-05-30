function AutoRunParallel(varargin)
    % AUTORUNPARALLEL - Network Simulation start script
    %   Runs on multiple cpu cores, thus it is significantly faster than
    %   <a href="matlab:help NetworkSim.AutoRun2">AutoRun2</a>
    %   Run the same simulation with seperate temperature dependency
    %   settings for different current    
    %   Other settings can be changed inside the inner function 
    %   <a href="matlab:help NetworkSim.AutoRunParallelSub">AutoRunParallelSub</a>
    
    % for i=1:10; NetworkSim.AutoRunParallel(false, i); end;
    % for i=[4 6 22 25 30 32 40 44 48 89]; NetworkSim.AutoRunParallel(false, i); end;
    EvalOnly = false;
    seed = 1;
    if(~isempty(varargin)); EvalOnly = varargin{1}; end;
    if(length(varargin) > 1); seed = varargin{2}; end;
    
    folderList = ListHandler();
    folderList.Add('Normal'); % Normal
    folderList.Add('IT'); % IT
    folderList.Add('IT2'); % IT2
    folderList.Add('Ih'); % Ih
    folderList.Add('AMPA'); % AMPA
    folderList.Add('GABAa'); % GABAa
%     folderList.Add('IT ex'); % IT ex
%     folderList.Add('IT2 ex'); % IT2 ex
%     folderList.Add('Ih ex'); % Ih ex
%     folderList.Add('AMPA ex'); % AMPA ex
%     folderList.Add('GABAa ex'); % GABAa ex
    folderList = folderList.Data;

    tempList = ListHandler();    
    tempList.Add([]); % Normal
    tempList.Add({'it'}); % IT
    tempList.Add({'it2'}); % IT2
    tempList.Add({'ih'}); % Ih
    tempList.Add({'ampa'}); % AMPA
    tempList.Add({'gabaa'}); % GABAa
%     a = NetworkSim.Sim.temperature_default; % a = rmfield(a, 'default');
%     tempList.Add(fields(rmfield(a, 'it'))); % IT ex
%     tempList.Add(fields(rmfield(a, 'it2'))); % IT2 ex
%     tempList.Add(fields(rmfield(a, 'ih'))); % Ih ex
%     tempList.Add(fields(rmfield(a, 'ampa')));   % AMPA ex
%     tempList.Add(fields(rmfield(a, 'gabaa'))); % GABAa ex
    tempList = tempList.Data;
    
    for fid = 1:length(folderList)
        NetworkSim.AutoRunParallelSub(EvalOnly, folderList{fid}, tempList{fid}, seed);
    end
end

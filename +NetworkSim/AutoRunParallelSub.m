function AutoRunParallelSub(varargin)   
    % AUTORUNPARALLELSUB - Sub function of <a href="matlab:help NetworkSim.AutoRunParallel">AutoRunParallel</a>
    %   Run the same simulation with multiple seeds and temperatures
    
    EvalOnly = false;
    mainSeed = 1;
    if(~isempty(varargin)); EvalOnly = varargin{1}; end;       
    if(length(varargin) > 1); TypeName = varargin{2}; end;
    if(length(varargin) > 2); tempType = varargin{3}; end;
    if(length(varargin) > 3); mainSeed = varargin{4}; end;
    % sourceFolder = 'e:\SimResults\2017.06.13\false_true_8_20_15_0.0085\';
    sourceFolder = 'e:\SimResults\';    
    SubFolder = datestr(date, 'yyyy.mm.dd');    
    SubFolder = '2017.10.20';    
    outputFolder = [sourceFolder SubFolder '\Results\' num2str(mainSeed) '\'];
    if ~exist(outputFolder,'dir'); mkdir(outputFolder); end;
    SubFolder = [SubFolder '\' num2str(mainSeed)];    
    % SubFolder = [datestr(date, 'yyyy.mm.dd') '\false_false' ];    
    % SubFolder = ['2017.09.04\'];
    % UseExcludeList = exist([sourceFolder 'Exclude.list'], 'file') == 2;    
    UseExcludeList = true;
    ShowTrendLine = false;                    
    SubFolder = [SubFolder '\' TypeName];

    rng(1);
    tempLimit = [34 39];
%     iterations = 6;   
%     temps = tempLimit(1) + (tempLimit(2)-tempLimit(1))*rand(iterations, 1);
%     seeds = randi(10000, iterations, 1);
    
    % Fixed Seed
%     temps = 34:0.01:39;  
%     seeds = ones(1, length(temps)) * mainSeed;
    
    % All Seeds
    currSize = 1000;
    seeds = (mainSeed - 1) * currSize  + [1:currSize];
    temps = tempLimit(1) + (tempLimit(2)-tempLimit(1))*rand(length(seeds), 1);
    
    if(~EvalOnly)
        parfor (i=1:length(temps), 6)            
            network = NetworkSim.Network();                 
            network.ampaWeightStd = 0.3;
            network.gabaWeightStd = 0;
            network.nRT_Connect = false;
            network.Create.TC_count = 100;
            network.Create.nRT_count = 20;
            network.AllowReciprocal = false;      
            network.UseCircularNetwork = false;
            network.Create.TC_to_nRT = 8;
            network.Create.TC_to_nRT_max = 20;
            network.Create.nRT_to_TC = 20;
            network.Create.nRT_to_TC_max = 50;
            network.Create.nRT_to_nRT = 0;        
            network.RandomSeed = seeds(i);
            NetworkSim.Run( ...
                'temperatures', round(temps(i), 2), ...
                'Network', network, ...
                'saveData', true, ...
                'GABAa', 0.0088, ...
                'disableJPGs', true, ...
                'varTemps', tempType, ...
                'subFolder', SubFolder);
        end
    end
    
    SaveSettings.TypeName = TypeName;
    SaveSettings.OutputFolder = outputFolder;
    NetworkSim.EvaluateResults([sourceFolder SubFolder '\'], 37.5, UseExcludeList, ShowTrendLine, SaveSettings);
    NetworkSim.EvaluateResults([sourceFolder SubFolder '\'], 39, UseExcludeList, ShowTrendLine, SaveSettings);
    copyfile(outputFolder, ['Z:\dburka\NetworkSim\' num2str(mainSeed)]);
end
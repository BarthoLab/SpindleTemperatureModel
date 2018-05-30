classdef Sim < handle
    % Sim(network) class
    %   network - <a href="matlab:help NetworkSim.Network">Network</a> object, the simulation will be based off
    %   Controller class of network simulations
    %   Simulation settings are saved in the following files:
    %       settings.log
    %       settings_extended.log
    %   Sim properties    
    %       Network	
    %           <a href="matlab:help NetworkSim.Network">Network</a>
    %           Network object of cells to run the simulation on 
    %       TC	
    %           Struct - <a href="matlab:display('  Sim TC default'); display(NetworkSim.Sim.TC_default)">default</a>
    %           TC related settings  
    %               TC_disable_delay - Shuts down the respective cell type 
    %                                  after the given delay if it is 
    %                                  greater than 0, otherwise this value
    %                                  is ignored
    %       UseGaussNoise	
    %           Boolean - default false
    %           Enable the use of Gauss noise in the simulation 
    %       defaultCommand	
    %           String - defalult ''
    %           Extra parameters to pass to the hoc file (See <a href="matlab:type('NetworkSim\Help\SimExample2.m')">Example2</a>)
    %       dt	
    %           Real - default 0.1
    %           The time step (ms) of the Neuron simulation 
    %       nRT
    %           Struct - <a href="matlab:display('  Sim nRT default'); display(NetworkSim.Sim.nRT_default)">default</a>
    %           nRT related settings  
    %               nRT_disable_delay - Shuts down the respective cell type 
    %                                   after the given delay if it is 
    %                                   greater than 0, otherwise this value
    %                                   is ignored
    %       simFileName	
    %           String - default 'network_simulation.hoc'
    %           Neuron .hoc filename to run. <a href="matlab:type('NetworkSim\Help\hoclist\list.txt')">Change</a> this if you want to run
    %           a different type of simulation        
    %       startDelay	
    %           Real - default 500
    %           Delay of the starting spikes (ms), basicly the start of the
    %           simulation
    %       temperature	
    %           Struct - <a href="matlab:display('  Sim temperature default'); display(NetworkSim.Sim.temperature_default)">default</a> 
    %           Temperature settings. If non default value is left empty, it 
    %           will be set to the default temperature
    %       tstop	
    %           Integer - default 2000
    %           Length of the simulation (ms) to run in Neuron
    %       v_init	
    %           Integer - default -70
    %           Initial membrane potential 
    %       SaveCurrent
    %           Boolean - default false
    %           Save Current data of every cell in the network. Increases
    %           runtime significantly
    %       ResultPath
    %           String - default ''
    %           Directory where outputs and temporary files are stored
    %   Sim methods
    %       Run()
    %           Start the simulation
    %           Always changes the working directory for Neuron simulation!
    %
    %   <a href="matlab:type('NetworkSim\Help\SimExample.m')">Example</a>            
    
    %% Public properties
    properties(SetAccess = public)
        Network,   % <a href="matlab:doc NetworkSim.Network">Network</a> of cells to run the simulation on
        startDelay = 500, % Delay of the starting spikes (ms)
        dt = 0.1,    % Time step (ms)
        v_init = -70,    % Initial membrane potential
        tstop = 2000,    % Simulation length (ms)
        % Struct of <a href="matlab:display('  Temperature default'); display(NetworkSim.Sim.temperature_default)">temperature</a> settings
        % If non default value is left empty, it will be set to the default value
        temperature,
        % Struct of <a href="matlab:display('  nRT default'); display(NetworkSim.Sim.nRT_default)">nRT</a> settings
        % nRT_disable_delay 
        %   Shuts down the respective cell type after the given delay if it is greater than 0, otherwise this value is ignored
        nRT,
        % Struct of <a href="matlab:display('  TC default'); display(NetworkSim.Sim.TC_default)">TC</a> settings        
        % TC_disable_delay 
        %   Shuts down the respective cell type after the given delay if it is greater than 0, otherwise this value is ignored
        TC,
        % Save Current data of every cell in the network. Increases runtime
        % significantly
        SaveCurrent = 0,
        UseGaussNoise = false, % Enable the use of Gauss noise in the simulation
        ResultPath = '', % Output and temporary storage directory
        simFileName = 'network_simulation.hoc', % Neuron .hoc filename to run
        defaultCommand = '' % Extra parameters to pass to the hoc file             
    end
    
    %% Private properties
    properties(SetAccess = private, Hidden=true)        
        nrnivPath = 'c:\nrn73w64\bin64\nrniv.exe';        
        % FileNames
        SubFolder = '';
        TC_nRT_Edges = 'connections_TC_nRT.txt';
        nRT_TC_Edges = 'connections_nRT_TC.txt';
        nRT_nRT_Edges = 'connections_nRT_nRT.txt';
        TC_Results = 'TC_Results.txt';
        nRT_Results = 'nRT_Results.txt';
    end
    
    %% Constant properties
    properties(Constant=true, Hidden=true)        
       temperature_default = struct(...
             'default', 36, ...
             'it', '', ...
             'it2', '', ...
             'ih', '', ...
             'ampa', '', ...
             'gabaa', '', ...
             'gabab', '' ...
            )        
        nRT_default = struct(...
             'nRT_disable_delay', 0, ... 
             'leak_g', 5e-5, ... 
             'kshift', 0, ...
             'cadecayTau', 30, ...
             'ampa_gmax', 0.02,  ...
             'gkbar_sk', 0.01,  ...
             'cac_sk', 0.025,  ...
             'gmax_it2', 0.00175)
        TC_default = struct(...
             'TC_disable_delay', 0, ...
             'k_leak', 0.002, ...
             'gabaa_gmax', 0.02, ...
             'gabab_gmax', 0.04)
    end
    
    %% Public methods
    methods
        % Constructor
        function obj = Sim(network)
            obj.Network = network;
            obj.nRT = obj.nRT_default;
            obj.TC = obj.TC_default;
            obj.temperature = obj.temperature_default;
            if(strcmp(getenv('USERNAME'), 'dburk'))
                obj.nrnivPath = 'c:\nrn\bin\nrniv.exe';
            end
        end
        
        % Destructor
        function delete(obj)     
            rmdir(obj.SubFolder, 's');
        end
        
        % Start the simulation
        function Run(obj)
            % Start the simulation
            
            % Change Matlab working directory to NetworkSim.Sim
            % This is necessary for the .hoc files to find templates and mods
            % Also necessary for createInput.m file creation
            cd(fileparts(mfilename('fullpath')));
            Start(obj);            
        end
    end
    
    %% Private methods
    methods(Access = private)
        % Functions in different files
        Start(obj);
    end
end

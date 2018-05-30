    % <a href="matlab:run NetworkSim.Help.SimExample.m">Run SimExample</a>, <a href="matlab:open('+NetworkSim/+Help/SimExample.m')">Open SimExample</a>
    % Simple simulation setup with original Destexhe network
        
    function SimExample()
        %% Network to run the simulation on
        network = NetworkSim.Network();    
        network.nRT_AutoConnect = true;
        network.Create.TC_count = 10;
        network.Create.nRT_count = 3;
        network.Create.TC_to_nRT = 2;
        network.Create.nRT_to_TC = 3;
        network.Create.nRT_to_nRT = 0;        
        network.CreateNetwork();

        %% Simulation class
        sim = NetworkSim.Sim(network);        
        sim.Run();

        %% Process results
        % Result txt-s are based on the Neuron simulation file
        % network_simulation.hoc by default
        t = sim.dt:sim.dt:sim.tstop;    % Time vector for display
        TC = load([sim.SubFolder 'TC_Results.txt']);   % Membrane potential of the 2 TC cell 
        nRT = load([sim.SubFolder 'nRT_Results.txt']); % Membrane potential of the 2 nRT cell  
        subplot(2,2,1); plot(t, TC(:,1));
        subplot(2,2,2); plot(t, TC(:,2));
        subplot(2,2,3); plot(t, nRT(:,1));
        subplot(2,2,4); plot(t, nRT(:,2));
    end
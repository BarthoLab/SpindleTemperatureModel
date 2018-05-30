    % <a href="matlab:run NetworkSim.Help.NetworkExample2.m">Run NetworkExample2</a>, <a href="matlab:open('+NetworkSim/+Help/NetworkExample2.m')">Open NetworkExample2</a>
    % Destexhe original setup
    function NetworkExample2()
        network = NetworkSim.Network();    
        network.nRT_AutoConnect = true;
        network.nRT_Connect = true;
        network.Create.TC_count = 2;
        network.Create.nRT_count = 2;
        network.Create.TC_to_nRT = 2;
        network.Create.nRT_to_TC = 2;
        network.Create.nRT_to_nRT = 2;        
        network.CreateNetwork();
        network.Show(figure); % Optional
    end
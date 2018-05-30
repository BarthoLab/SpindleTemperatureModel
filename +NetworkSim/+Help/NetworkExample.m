    % <a href="matlab:run NetworkSim.Help.NetworkExample.m">Run NetworkExample</a>, <a href="matlab:open('+NetworkSim/+Help/NetworkExample.m')">Open NetworkExample</a>
    function NetworkExample()
        network = NetworkSim.Network();    
        network.ampaWeightStd = 0.3;
        network.gabaWeightStd = 0;
        network.nRT_Connect = false;
        network.Create.TC_count = 10;
        network.Create.nRT_count = 3;
        network.Create.TC_to_nRT = 2;
        network.Create.nRT_to_TC = 3;
        network.Create.nRT_to_nRT = 0;        
        network.CreateNetwork();
        network.Show(figure); % Optional
    end
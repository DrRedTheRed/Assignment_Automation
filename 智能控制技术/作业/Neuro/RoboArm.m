function RoboArm(block)
    % Level-2 MATLAB S-Function for the Robotic Arm

    setup(block);

    % Function: setup ============================================================
    function setup(block)
        % Register the number of ports
        block.NumInputPorts = 2; % Two input: Voltage tau_1,tau_2
        block.NumOutputPorts = 2; % Two output: q1,q2

        % Setup port dimensions
        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;
        block.InputPort(1).Dimensions = 1; % Scalar input (tau_1)
        block.InputPort(2).Dimensions = 1; % Scalar output (tau_2)
        block.OutputPort(1).Dimensions = 1; % Scalar output (q1)
        block.OutputPort(2).Dimensions = 1; % Scalar output (q2)

        % Setup block parameters
        block.NumDialogPrms = 4; % Initial states: [q1(0),q1_dot(0),q2(0),q2_dot(0)]

        % Continuous states
        block.NumContStates = 4; % [q1,q1_dot,q2,q2_dot]

        % Sample times
        block.SampleTimes = [0 0]; % Continuous time

        % Block characteristics
        block.SimStateCompliance = 'DefaultSimState';

        % Register methods
        block.RegBlockMethod('InitializeConditions', @InitializeConditions);
        block.RegBlockMethod('Outputs', @Outputs);
        block.RegBlockMethod('Derivatives', @Derivatives);
    end

    % Function: InitializeConditions =============================================
    function InitializeConditions(block)
        % Set initial conditions
        q1 = block.DialogPrm(1).Data;
        q1_dot = block.DialogPrm(2).Data;
        q2 = block.DialogPrm(3).Data;
        q2_dot = block.DialogPrm(4).Data;

        block.ContStates.Data = [q1,q1_dot,q2,q2_dot];
    end

    % Function: Outputs ==========================================================
    function Outputs(block)
        % Output only Theta
        block.OutputPort(1).Data = block.ContStates.Data(1); % q1
        block.OutputPort(2).Data = block.ContStates.Data(3); % q2
    end

    % Function: Derivatives ======================================================
    function Derivatives(block)
        % States
        q1 = block.ContStates.Data(1);
        q1_dot = block.ContStates.Data(2);
        q2 = block.ContStates.Data(3);
        q2_dot = block.ContStates.Data(4);

        % Input force
        tau_1 = block.InputPort(1).Data;
        tau_2 = block.InputPort(2).Data;

        % Parameters
        h1 = 0.0308;
        h2 = 0.0106;
        h3 = 0.0095;
        h4 = 0.2086;
        h5 = 0.0631;

        g = 9.8;
        
        %Matrix that derives on it
        M = [h1+h2+2*h3*cos(q2),h2+h3*cos(q2);h2+h3*cos(q2),h2];
        C = [-h3*sin(q2)*q2_dot,-h3*sin(q2)*(q1_dot+q2_dot);h3*sin(q2)*q1_dot,0];
        G = [h4*g*cos(q1) + h5*g*cos(q1+q2);h5*g*cos(q1+q2)];
        T = [tau_1;tau_2];

        % Construct state derivatives
        dQ = [q1_dot; q2_dot]; % Velocities are the derivatives of positions

        % Solve for angular accelerations (q1_dotdot, q2_dotdot)
        dQ_dot = M \ (T - C * dQ - G);

        block.Derivatives.Data = [dQ(1) dQ_dot(1) dQ(2) dQ_dot(2)]; % Concatenate to form state derivatives
    end
end
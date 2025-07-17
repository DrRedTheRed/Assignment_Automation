function InvertedPendulum(block)
    % Level-2 MATLAB S-Function for the inverted pendulum dynamics
    % Outputs only Theta (pendulum angle)

    setup(block);

    % Function: setup ============================================================
    function setup(block)
        % Register the number of ports
        block.NumInputPorts = 1; % One input: Force F
        block.NumOutputPorts = 2; % Two output: Theta, y0

        % Setup port dimensions
        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;
        block.InputPort(1).Dimensions = 1; % Scalar input (Force)
        block.OutputPort(1).Dimensions = 1; % Scalar output (Theta)
        block.OutputPort(2).Dimensions = 1; % Scalar output (Theta)

        % Setup block parameters
        block.NumDialogPrms = 4; % Initial states: [Theta0, Omega0, y0, v0]

        % Continuous states
        block.NumContStates = 4; % [Theta, Omega, y, v]

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
        Theta0 = block.DialogPrm(1).Data;
        Omega0 = block.DialogPrm(2).Data;
        y0 = block.DialogPrm(3).Data;
        v0 = block.DialogPrm(4).Data;

        block.ContStates.Data = [Theta0; Omega0; y0; v0];
    end

    % Function: Outputs ==========================================================
    function Outputs(block)
        % Output only Theta
        block.OutputPort(1).Data = block.ContStates.Data(1); % Theta
        block.OutputPort(2).Data = block.ContStates.Data(3); % y0
    end

    % Function: Derivatives ======================================================
    function Derivatives(block)
        % States
        Theta = block.ContStates.Data(1);
        Omega = block.ContStates.Data(2);
        y = block.ContStates.Data(3);
        v = block.ContStates.Data(4);

        % Input force
        F = block.InputPort(1).Data;

        % Parameters
        M = 1.0;   % Cart mass (kg)
        m = 0.5;   % Pendulum mass (kg)
        l = 0.5;   % Length to pendulum center of mass (m)
        g = 9.8;   % Gravitational acceleration (m/s^2)

        % Intermediate calculations
        sin_Theta = sin(Theta);
        cos_Theta = cos(Theta);

        % Equations of motion
        dTheta = Omega;
        dy = v;
        dv = (F - m*g*sin_Theta*cos_Theta - m*l*(dTheta)^2*sin_Theta) / ...
      (M + m - m*(cos_Theta^2));
        dOmega = (g*sin_Theta - (dv*cos_Theta))/l;

        % State derivatives
        block.Derivatives.Data = [dTheta; dOmega; dy; dv];
    end
end
function TwoWheel(block)
    % Level-2 MATLAB S-Function for Two Wheel

    setup(block);

    % Function: setup ============================================================
    function setup(block)
        % Register the number of ports
        block.NumInputPorts = 2; % Two input: theta_f, alpha_x 
        block.NumOutputPorts = 2; % Two output: Xdot, Ydot

        % Setup port dimensions
        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;
        block.InputPort(1).Dimensions = 1; % Scalar input (theta_f)
        block.InputPort(2).Dimensions = 1; % Scalar input (alpha_x)
        block.OutputPort(1).Dimensions = 1; % Scalar output (Xdot)
        block.OutputPort(2).Dimensions = 1; % Scalar output (Ydot)

        % Setup block parameters
        block.NumDialogPrms = 4; % Initial states: [xdot(0),ydot(0),yaw(0),yaw_dot(0)]

        % Continuous states
        block.NumContStates = 4; % [xdot,ydot,yaw,yaw_dot]

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
        xdot = block.DialogPrm(1).Data;
        ydot = block.DialogPrm(2).Data;
        yaw = block.DialogPrm(3).Data;
        yaw_dot = block.DialogPrm(4).Data;

        block.ContStates.Data = [xdot,ydot,yaw,yaw_dot];
    end

    % Function: Outputs ==========================================================
    function Outputs(block)
        % Output Xdot,Ydot
        xdot = block.ContStates.Data(1);
        ydot = block.ContStates.Data(2);
        yaw = block.ContStates.Data(3);

        block.OutputPort(1).Data = xdot*cos(yaw) - ydot*sin(yaw); % Xdot
        block.OutputPort(2).Data = xdot*sin(yaw) + ydot*cos(yaw); % Ydot
    end

    % Function: Derivatives ======================================================
    function Derivatives(block)
        % States
        xdot = block.ContStates.Data(1);
        ydot = block.ContStates.Data(2);
        yaw_dot = block.ContStates.Data(4);

        % Input
        theta_f = block.InputPort(1).Data;
        alpha_x = block.InputPort(2).Data;

        % Parameters
        M = 2045; %Car weight
        Lf = 1.488; %The distance between the center of mass And the front wheel
        Lr = 1.712; %The distance between the center of mass And the rear wheel
        Cf = -38925; %Tire Cornering Stiffness
        Cr = -39255; %Tire Cornering Stiffness
        Iz = 5428; %Vehicle Inertia
        
        %Some medium parameters that derives on it
        beta = atan(ydot/xdot);

        alpha_f = beta + Lf * yaw_dot / xdot - theta_f;
        alpha_r = beta - Lr * yaw_dot / xdot;

        F_y1 = Cf * alpha_f;
        F_y2 = Cr * alpha_r;

        % Construct state derivatives
        xdot_dot = yaw_dot * ydot + alpha_x;
        ydot_dot = -yaw_dot * xdot + 2*(F_y1*cos(theta_f)+F_y2)/M;
        yawdot_dot = 2*(Lf*F_y1-Lr*F_y2)/Iz;

        block.Derivatives.Data = [xdot_dot ydot_dot yaw_dot yawdot_dot]; % Concatenate to form state derivatives
    end
end
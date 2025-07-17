% This MATLAB code implements a BP (Back Propagation) neural network - based PID control algorithm.
% The BP neural network is used to adjust the PID parameters online.

function [sys,x0,str,ts,simStateCompliance] = BP(t,x,u,flag)
    T = 0.001;
    j = 5;
    xite = 0.3;
    alfa = 0.05;
    switch flag
        case 0
            % Initialize the model
            [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(T,j);
        case 3
            % Calculate the outputs
            sys=mdlOutputs(t,x,u,xite,alfa);
        case {1,2,4,9}
            sys = [];
        otherwise
            DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
    end

function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(T,j)
    % Call the initialization function. T is the step size and j is the number of hidden layer neurons.
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 4;
    % Define the output variables, including the control variable u and three PID parameters: Kp, Ki, Kd
    sizes.NumInputs      = 8;
    % Define the input variables, including 7 parameters [e(k);e(k-1);e(k-2);y(k);y(k-1);r(k);u(k-1)] and the bias u(8)=1
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1; 
    sys = simsizes(sizes);
    x0  = [];
    str = [];
    ts  = [T 0];
    global wi_2 wi_1 wo_2 wo_1
    wi_2 =rand(j,4).*2-1;
    % The weight coefficient matrix of the hidden layer at time (k - 2), with dimension j*4 and range [-1, 1]
    wo_2 = rand(3,j);
    % The weight coefficient matrix of the output layer at time (k - 2), with dimension 3*j and range [0, 1]
    wi_1 = wi_2;
    % The weight coefficient matrix of the hidden layer at time (k - 1), with dimension j*4
    wo_1 = wo_2;
    % The weight coefficient matrix of the output layer at time (k - 1), with dimension 3*j
    simStateCompliance = 'UnknownSimState';

function sys=mdlOutputs(t,x,u,xite,alfa)
    % Call the output function
    M=[100;2;25];
    % PID weights
    global wi_2 wi_1 wo_2 wo_1
    xi = [u(6),u(4),u(1),u(8)];
    % The input of the neural network xi=[u(6),u(4),u(1),u(8)]=[r(k),y(k),e(k),1] with dimension 1*4
    xx = [u(1)-u(2);u(1);u(1)+u(3)-2*u(2)];
    % xx=[u(1)-u(2);u(1);u(1)+u(3)-2*u(2)]=[e(k)-e(k-1);e(k);e(k)+e(k-2)-2*e(k-1)] with dimension 3*1
    I = xi*wi_1';
    % Calculate the input of the hidden layer. I = the input of the neural network * the transpose of the hidden layer weight coefficient matrix wi_1'
    Oh = (exp(I)-exp(-I))./(exp(I)+exp(-I));
    % Activation function to calculate the output of the hidden layer, which is a 1*j matrix
    O = wo_1*Oh';
    % Calculate the input of the output layer, with dimension 3*1
    K =exp(O)./(exp(O)+exp(-O));
    % Activation function to calculate the output of the output layer K=[Kp,Ki,Kd], with dimension 3*1
    K(1)=M(1)*K(1);K(2)=M(2)*K(2);K(3)=M(3)*K(3);
    uu = u(7)+K'*xx;
    % Calculate the control variable u(k) according to the incremental PID control algorithm, with dimension 1*1
    if uu>15
        uu=15;
    end
    if uu<-15
        uu=-15;
    end
    % Limit the output u
    dyu = sign((u(4)-u(5))/(uu-u(7)+0.0001));
    % Calculate the sgn in the output layer weight coefficient correction formula
    % sign((y(k)-y(k-1))/(u(k)-u(k-1)+0.0001)) approximately represents the partial derivative, with dimension 1*1
    dO = (2./(exp(O)+exp(-O))).^2;
    % Activation function, with dimension 3*1
    delta3 = u(1)*dyu*xx.*dO;
    wo = wo_1+xite*delta3*Oh+alfa*(wo_1-wo_2);
    % Correction of the output layer weight coefficient matrix
    dI = 2./(exp(I)+exp(-I)).^2;
    % Activation function, with dimension 1*j
    wi = wi_1+xite*(dI.*(delta3'*wo))'*xi+alfa*(wi_1-wi_2);
    % Correction of the hidden layer weight coefficient
    wi_2=wi_1;
    wi_1=wi;
    wo_2=wo_1;
    wo_1=wo;
    sys = [uu;K(:)];
    % The output of the output layer sys=[uu;Kp;Ki;Kd]
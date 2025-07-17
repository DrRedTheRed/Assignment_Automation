function [] = ekf_localization()
 
% Homework for ekf localization
% Modified by YH on 09/09/2019, thanks to the original open source
% Any questions please contact: zjuyinhuan@gmail.com

    close all;
    clear all;

    disp('EKF Start!')

    time = 0;
    global endTime; % [sec]
    endTime = 60;
    global dt;
    dt = 0.1; % [sec]

    removeStep = 5;

    nSteps = ceil((endTime - time)/dt);

    estimation.time=[];
    estimation.u=[];
    estimation.GPS=[];
    estimation.xOdom=[];
    estimation.xEkf=[];
    estimation.xTruth=[];

    % State Vector [x y yaw]'
    xEkf=[0 0 0]';
    PxEkf = eye(3);

    % Ground True State
    xTruth=xEkf;

    % Odometry Only
    xOdom=xTruth;

    % Observation vector [x y yaw]'
    z=[0 0 0]';

    % Simulation parameter
    global noiseR
    noiseR = diag([0.1 0 degreeToRadian(10)]).^2; %[Vx Vy yawrate]

    global noiseQ
    noiseQ = diag([0.5 0.5 degreeToRadian(5)]).^2;%[x y yaw]
    
    % Covariance Matrix for motion
    convR= noiseR;

    % Covariance Matrix for observation
    convQ= noiseQ;

    % Other Intial
     xPred = 0;
     PxPred = eye(3);
     zPred = 0;
     %Just to make space for these fellas. I mean, where else could they
     %be?


    % Main loop
    for i=1 : nSteps
        time = time + dt;
        % Input
        u=robotControl(time);
        % Observation
        [z,xTruth,xOdom,u]=prepare(xTruth, xOdom, u);

        % ------ Kalman Filter --------
        % Predict
        xPred = doMotion(xEkf,u);
        G = jacobF(xEkf,u);
        PxPred = G * PxEkf *transpose(G) + convR;

        zPred = doObservation(z,xPred);
        H = jacobH(z-xPred);

        K = PxPred*transpose(H)/(H*PxPred*transpose(H)+convQ);
        
        % Update
        xEkf = xPred + K*(z-zPred);%for there's only one point one the map that robot follows
        PxEkf = (eye(3) - K*H)*PxPred;

        % -----------------------------

        % Simulation estimation
        estimation.time=[estimation.time; time];
        estimation.xTruth=[estimation.xTruth; xTruth'];
        estimation.xOdom=[estimation.xOdom; xOdom'];
        estimation.xEkf=[estimation.xEkf;xEkf'];
        estimation.GPS=[estimation.GPS; z'];
        estimation.u=[estimation.u; u'];

        % Plot in real time
        % Animation (remove some flames)
        if rem(i,removeStep)==0
            %hold off;
            plot(estimation.GPS(:,1),estimation.GPS(:,2),'*m', 'MarkerSize', 5);hold on;
            plot(estimation.xOdom(:,1),estimation.xOdom(:,2),'.k', 'MarkerSize', 10);hold on;
            plot(estimation.xEkf(:,1),estimation.xEkf(:,2),'.r','MarkerSize', 10);hold on;
            plot(estimation.xTruth(:,1),estimation.xTruth(:,2),'.b', 'MarkerSize', 10);hold on;
            axis equal;
            grid on;
            drawnow;
            %movcount=movcount+1;
            %mov(movcount) = getframe(gcf);
        end 
    end
    close
    
    finalPlot(estimation);
 
end

% control
function u = robotControl(time)
    global endTime;

    T = 10; % sec
    Vx = 1.0; % m/s
    Vy = 0.2; % m/s
    yawrate = 5; % deg/s
    
    % half
    if time > (endTime/2)
        yawrate = -5;
    end
    
    u =[ Vx*(1-exp(-time/T)) Vy*(1-exp(-time/T)) degreeToRadian(yawrate)*(1-exp(-time/T))]';
    
end

% all observations for 
function [z, xTruth, xOdom, u] = prepare(xTruth, xOdom, u)
    global noiseR;
    global noiseQ;

    % Ground Truth
    xTruth=doMotion(xTruth, u);
    % add Motion Noises
    u=u+noiseR*randn(3,1);
    % Odometry Only
    xOdom=doMotion(xOdom, u);
    % add Observation Noises
    z=xTruth+noiseQ*randn(3,1);
end


% Motion Model
function x = doMotion(x, u)
    %feed in the position and the control in the past, output the
    %deducted current position. 
    global dt;
    A = eye(3); %state matrix
    
    v = sqrt((u(1))^2+(u(2))^2);%velocity scalar
    w = u(3);%angular velocity scalar
    B = [-v / w * (sin(x(3))-sin(x(3)+w*dt)); ...
        v / w * (cos(x(3))-cos(x(3)+w*dt)); ...
        w * dt]; %control vector.
    x = A * x + B;
end


% Jacobian of Motion Model
function jF = jacobF(x, u)
    %solved from directy differentiating doMotion function F.
    global dt;
    
    v = sqrt((u(1))^2+(u(2))^2);%velocity scalar
    w = u(3);%angular velocity scalar

    jF = [1 0 v / w * (-cos(x(3))+cos(x(3)+w*dt));
        0 1 v / w * (-sin(x(3))+sin(x(3)+w*dt));
        0 0 1]; % 
end


%Observation Model
function x = doObservation(z, xPred)
    % Here, x means zPred. Could be misleading. It is also H.
    x = xPred;
end

%Jacobian of Observation Model
function jH = jacobH(x)
    %x means z - xPred.

    jH = eye(3,3); 
end

% finally plot the results
function []=finalPlot(estimation)
    figure;
    
    plot(estimation.GPS(:,1),estimation.GPS(:,2),'*m', 'MarkerSize', 5);hold on;
    plot(estimation.xOdom(:,1), estimation.xOdom(:,2),'.k','MarkerSize', 10); hold on;
    plot(estimation.xEkf(:,1), estimation.xEkf(:,2),'.r','MarkerSize', 10); hold on;
    plot(estimation.xTruth(:,1), estimation.xTruth(:,2),'.b','MarkerSize', 10); hold on;
    legend('GPS Observations','Odometry Only','EKF Localization', 'Ground Truth');

    xlabel('X (meter)', 'fontsize', 12);
    ylabel('Y (meter)', 'fontsize', 12);
    grid on;
    axis equal;
    
    % calculate error
    
    err_ekf = estimation.xEkf - estimation.xTruth;
    err_odom = estimation.xOdom - estimation.xTruth;

    rmse_ekf = sqrt(mean(err_ekf.^2));
    rmse_odom = sqrt(mean(err_odom.^2));

    disp(['EKF Localization Result - RMSE: [' num2str(rmse_ekf(1), '%.2f') ', ' num2str(rmse_ekf(2), '%.2f') ', ' num2str(rmse_ekf(3), '%.2f') ']']);
    disp(['Odometry Result - RMSE: [' num2str(rmse_odom(1), '%.2f') ', ' num2str(rmse_odom(2), '%.2f') ', ' num2str(rmse_odom(3), '%.2f') ']']);

end

function radian = degreeToRadian(degree)
    radian = degree/180*pi;
end
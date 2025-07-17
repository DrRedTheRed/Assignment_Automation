clear
clc

% Define transfer functions
G1 = tf(1, [1 1]);  % 1/(s+1)
G2 = tf(1, [1 2]);  % 1/(s+2)
G3 = tf(1, [1 3]);  % 1/(s+3)
G4 = tf(1, [1 7 12]);  % 1/(s+3)(s+4)
G5 = tf(1, [1 5]);  % 1/(s+5)

G_feedback_1 = feedback(G2,G4);
G_1 = series(G1,G_feedback_1);
G_feedback_2 = feedback(G_1,G5,+1);
G_2 = G_feedback_2 * G3;
T = feedback(G_2,1);
% Display the final transfer function
T_simplified = minreal(T);
T_simplified



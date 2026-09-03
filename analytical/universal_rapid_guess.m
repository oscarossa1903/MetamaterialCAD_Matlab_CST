function [f_resonance, L_eff, C_eff] = universal_rapid_guess(...
        V, width, thickness, gap, layer_type, substrate_er)
    % UNIVERSAL_RAPID_GUESS - PEEC & Babinet Duality EM Estimator
    %
    % Inputs:
    %   V             - Centerline coordinate matrix [x, y] in meters
    %   width         - Trace/slot width in meters
    %   thickness     - Copper cladding thickness in meters
    %   gap           - Physical split gap size in meters
    %   layer_type    - 'SRR' or 'CSRR'
    %   substrate_er  - Substrate relative permittivity (FR4 = 4.4)
    
    eps0 = 8.854187817e-12;
    mu0 = 1.256637061e-6;
    
    % Effective dielectric constant of microstrip/ground environment
    er_eff = (substrate_er + 1) / 2;
    
    % Segment Decomposition of the arbitrary curve skeleton
    N = size(V, 1) - 1;
    lengths = zeros(N, 1);
    angles = zeros(N, 1);
    for idx = 1:N
        dx = V(idx+1, 1) - V(idx, 1);
        dy = V(idx+1, 2) - V(idx, 2);
        lengths(idx) = sqrt(dx^2 + dy^2);
        angles(idx) = atan2(dy, dx);
    end
    
    % Initialize Loop Inductance Components using PEEC Method
    L_self_sum = 0;
    M_mutual_sum = 0;
    
    % 1. Self-inductance of rectangular cross-section segments
    for idx = 1:N
        if lengths(idx) > 1e-9
            L_self_sum = L_self_sum + (mu0 * lengths(idx) / (2*pi)) *...
                (log((2 * lengths(idx)) / (width + thickness)) + 0.5);
        end
    end
    
    % 2. Mutual coupling calculation (Neumann formula double sum)
    for idx = 1:N
        for jdx = 1:N
            if idx ~= jdx
                dist = sqrt((V(idx,1) - V(jdx,1))^2 + (V(idx,2) - V(jdx,2))^2);
                if dist > 1e-9
                    M_ij = (mu0 * cos(angles(idx) - angles(jdx)) * lengths(idx) * lengths(jdx)) / (4 * pi * dist);
                    M_mutual_sum = M_mutual_sum + M_ij;
                end
            end
        end
    end
    L_trace = L_self_sum + M_mutual_sum;
    
    % Solve Capacitances (Gap Capacitance + Distributed Surface Charge)
    if gap > 1e-9
        % Fringing field-corrected parallel plate split-ring gap capacitance
        C_gap = eps0 * er_eff * (thickness * width / gap) + eps0 * (thickness + width + gap);
    else
        C_gap = 1e-15; % Default numeric minimum for closed loops
    end
    
    total_perimeter = sum(lengths);
    R_eq = total_perimeter / (2 * pi);
    
    if gap > 1e-9
        % Distributed trace capacitance along surface path length
        C_dist = 20 * eps0 * er_eff * (total_perimeter / pi^2) * log((4 * R_eq) / gap);
    else
        C_dist = eps0 * er_eff * total_perimeter;
    end
    C_trace = C_gap + C_dist;
    
    % Duality Inversion Branching (Babinet Duality Principle)
    if strcmp(layer_type, 'SRR')
        L_eff = L_trace;
        C_eff = C_trace;
    elseif strcmp(layer_type, 'CSRR')
        % Swap inductances and capacitances via Babinet scaling
        C_eff = L_trace * (4 * eps0 * er_eff / mu0);
        L_eff = C_trace * (mu0 / (4 * eps0 * er_eff));
    else
        L_eff = L_trace;
        C_eff = C_trace;
    end
    
    % Calculate resonance frequency of the lumped circuit
    f_resonance = 1 / (2 * pi * sqrt(L_eff * C_eff));
end
% 11-15-19: Cahnge name from XYZ2lab to f_XYZ2lab

function [LAB, CovLAB] = f_XYZ2lab (XYZ, XYZ_white, CovXYZ)
    % XYZ is k-by-3
    % XYZ_white is 1-by-3
    k = size(XYZ,1);
    XYZn = repmat(XYZ_white,k,1);
    XYZ_over_XYZn = XYZ./XYZn;
          
    % CIELab values
    disp('    calculate values...');
    
    lstar = 116 * helpf(XYZ_over_XYZn(:,2)) - 16;
    astar = 500 * (helpf(XYZ_over_XYZn(:,1)) - helpf(XYZ_over_XYZn(:,2)));
    bstar = 200 * (helpf(XYZ_over_XYZn(:,2)) - helpf(XYZ_over_XYZn(:,3)));
    
    LAB = [lstar astar bstar];
    
    if ~isempty(CovXYZ)
        
        % Covarinace matrix of CIELab values
        disp('    calculate uncertainties...');

        % Elements of Jacobian matrix for one pixel
        CovLAB =  zeros(3, 3, k);

        % Tanspose of Jacobian
        J_x_t = [zeros(k, 1)'; (116 ./ XYZn(:, 2) .* helpf_p (XYZ_over_XYZn(:,2)))';...
            zeros(k, 1)']; % First row of jacobian, transposed
        J_y_t = [(500 ./ XYZn(:, 1) .* helpf_p (XYZ_over_XYZn(:, 1)))'; ...
            (-500 ./ XYZn(:, 2) .* helpf_p (XYZ_over_XYZn(:, 2)))'; zeros(k, 1)']; % Second row of jacobian, transposed
        J_z_t = [zeros(k, 1)'; (200 ./ XYZn(:, 2) .* helpf_p (XYZ_over_XYZn(:, 2)))';...
            (-200 ./ XYZn(:, 3) .* helpf_p (XYZ_over_XYZn(:, 3)))']; % Third row of jacobian, transposed

        % First product, CovXYZ * J'
        CovXYZ_x = reshape(CovXYZ(1, :, :), 3, k); % First row of CovXYZ
        CovXYZ_Jt_11 = sum(CovXYZ_x .* J_x_t);
        CovXYZ_Jt_12 = sum(CovXYZ_x .* J_y_t);
        CovXYZ_Jt_13 = sum(CovXYZ_x .* J_z_t);

        CovXYZ_y = reshape(CovXYZ(2, :, :), 3, k); % Second row of CovXYZ
        CovXYZ_Jt_21 = sum(CovXYZ_y .* J_x_t);
        CovXYZ_Jt_22 = sum(CovXYZ_y .* J_y_t);
        CovXYZ_Jt_23 = sum(CovXYZ_y .* J_z_t);

        CovXYZ_z = reshape(CovXYZ(3, :, :), 3, k); % Third row of CovXYZ
        CovXYZ_Jt_31 = sum(CovXYZ_z .* J_x_t);
        CovXYZ_Jt_32 = sum(CovXYZ_z .* J_y_t);
        CovXYZ_Jt_33 = sum(CovXYZ_z .* J_z_t);

        CovXYZ_Jt = permute(cat(3, [CovXYZ_Jt_11' CovXYZ_Jt_12' CovXYZ_Jt_13'], ...
            [CovXYZ_Jt_21', CovXYZ_Jt_22', CovXYZ_Jt_23'], [CovXYZ_Jt_31' CovXYZ_Jt_32' CovXYZ_Jt_33']), [3 2 1]); % Permutation of array dimensions

        % CovLAB
        % First col
        CovXYZ_Jt_col1 = reshape(CovXYZ_Jt(:, 1, :), 3, k);
        CovLAB(1, 1, :) = sum(J_x_t .* CovXYZ_Jt_col1);
        CovLAB(2, 1, :) = sum(J_y_t .* CovXYZ_Jt_col1);
        CovLAB(3, 1, :) = sum(J_z_t .* CovXYZ_Jt_col1);

        % Second col
        CovXYZ_Jt_col2 = reshape(CovXYZ_Jt(:, 2, :), 3, k);
        CovLAB(1, 2, :) = sum(J_x_t .* CovXYZ_Jt_col2);
        CovLAB(2, 2, :) = sum(J_y_t .* CovXYZ_Jt_col2);
        CovLAB(3, 2, :) = sum(J_z_t .* CovXYZ_Jt_col2);

        % Third col
        CovXYZ_Jt_col3 = reshape(CovXYZ_Jt(:, 3, :), 3, k);
        CovLAB(1, 3, :) = sum(J_x_t .* CovXYZ_Jt_col3);
        CovLAB(2, 3, :) = sum(J_y_t .* CovXYZ_Jt_col3);
        CovLAB(3, 3, :) = sum(J_z_t .* CovXYZ_Jt_col3);
    
    else
        CovLAB = [];
    end
    
    return
    
    % Domain function
    function ys = helpf (t)
        % conditional mask
        t_greater = (t > power(6/29,3));
        
        % conditional assignment
        t(t_greater) = t(t_greater) .^ (1/3);
        t(~t_greater) = t(~t_greater) * (((29/6)^2)/3) + 4/29;

        ys = t;
    end

    % Derivative of domain function
    function ys = helpf_p (t)
        % conditional mask
        t_greater = (t > power(6/29,3));
        
        % conditional assignment
        t(t_greater) = 1 ./ (3 *(t(t_greater) .^ (2/3) ) );
        t(~t_greater) = ((29/6)^2)/3;
                
        ys = t;
    end
end
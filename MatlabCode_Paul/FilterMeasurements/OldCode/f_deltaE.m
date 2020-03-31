function [dE, s_dE] = f_deltaE(LAB_1, LAB_2, CovLAB_1, CovLAB_2)
    
    % Computes DeltaE and its uncertainty
    DeltaE = @(LAB_1, LAB_2) sqrt((LAB_1(1) - LAB_2(1)).^2 + ...    % L
    (LAB_1(2) - LAB_2(2)).^2 + ...                                  % a
    (LAB_1(3) - LAB_2(3)).^2);                                      % b

    dE = DeltaE(LAB_1, LAB_2);

    s_dE = sqrt(1./dE.^2*[(LAB_1(1) - LAB_2(1)) (LAB_1(2) - LAB_2(2)) (LAB_1(3) -...
        LAB_2(3)) -(LAB_1(1) - LAB_2(1)) -(LAB_1(2) - LAB_2(2)) -(LAB_1(3) - LAB_2(3))] *...
        blkdiag(CovLAB_1, CovLAB_2)*...
        [(LAB_1(1) - LAB_2(1)) (LAB_1(2) - LAB_2(2)) (LAB_1(3) - LAB_2(3)) -...
        (LAB_1(1) - LAB_2(1)) -(LAB_1(2) - LAB_2(2)) -(LAB_1(3) - LAB_2(3))]');

end


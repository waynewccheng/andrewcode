% 09-13-19: Outputs only DeltaE

function dE = f_deltaE_3(LAB_1, LAB_2)
    
    % Computes DeltaE
    dE =  sqrt((LAB_1(1) - LAB_2(1)).^2 + ...    % L
    (LAB_1(2) - LAB_2(2)).^2 + ...               % a
    (LAB_1(3) - LAB_2(3)).^2);                   % b

end

function [t_m, t_s] = f_transmittance(s_m, w_m, b_m, s_s, w_s, b_s)
    % Compute the transmittace value and the uncertainty
    
    % Transmittance
    t_m = (s_m - b_m)./ (w_m - b_m);
    
    % Uncertainty
    t_s = sqrt((1./(w_m-b_m)).^2 .* s_s.^2 + ...
        ((s_m - w_m)./(w_m-b_m).^2).^2 .* b_s.^2 + ...
        ((b_m - s_m)./(w_m-b_m).^2).^2 .* w_s.^2);

end


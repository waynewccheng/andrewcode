% 12-6-19: Checks in the Inf values in T are3 at the last wavelength (780
% nm)
% Uses the T values at the 2 nearest wavelengths to extrapolate at 780 nm

function [t_m_out, t_s_out] = f_interp_infTval(varargin)

    % Load the input values
    default_properties = struct(...
      't_m_in', [], ...     % Mean transmittance values
      't_s_in', []);        % Std transmittance values
  
    % Check to make sure values are numeric arrays larger than 1x1 
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.t_m_in = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.t_s_in = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & ~ischar(varargin{1})
      error('Invalid parameter/value pair arguments.') 
    end

    % Attributes the input values to the variables
    prop = f_getopt(default_properties, varargin{:});
    t_m_in= prop.t_m_in; t_s_in = prop.t_s_in;
    
    % Determine the poisiotn of the Inf values
    sizewl = size(t_m_in, 1);
    all_inf_pos = find(isinf(t_m_in));
    
    % Copy of input table
    t_m_out = t_m_in;
    
    if ~isempty(t_s_in)
        t_s_out = t_s_in;
    else
        t_s_out = [];
    end
    
    % Interpolation if the Inf values are at the last wavelength position
    for i = 1:size(all_inf_pos, 1)

        if ~mod(all_inf_pos(i), sizewl)
            x = sizewl-2:sizewl-1;
            xq = sizewl-2:sizewl;
            pos_in_tbl = all_inf_pos(i)/41;

            % Mean values
            spectrum_m = t_m_in(:, pos_in_tbl);
            v = spectrum_m(x);
            vq = interp1(x,v,xq,'linear','extrap');
            spectrum_mq = spectrum_m;
            spectrum_mq(sizewl) = vq(end);
            t_m_out(:, pos_in_tbl) = spectrum_mq;
            
            % Uncertainties
            if ~isempty(t_s_in)
                spectrum_s = t_s_in(:, pos_in_tbl);
                v = spectrum_s(x);
                vq = interp1(x,v,xq,'linear','extrap');
                spectrum_sq = spectrum_s;
                spectrum_sq(sizewl) = vq(end);
                t_s_out(:, pos_in_tbl) = spectrum_sq;
            end
            
        end
    end
end
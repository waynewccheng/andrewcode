% 11-14-19: List of argument as input

% Compute the transmittance value and the uncertainty
% Substract the background light from the sample and the 100% transmittance

function [t_m, t_s] = f_transmittance(varargin)

    % Load the input values
    default_properties = struct(...
      's_m', [], ...    % Sample mean value
      'w_m', [],...     % White (100% Transmittance) mean value
      's_bg_m', [], ... % Sample background mean value
      'w_bg_m', [],...  % White background mean value
      's_s', [], ...    % Sample std dev value
      'w_s', [],...     % White std dev value
      's_bg_s', [], ... % Sample background std dev value
      'w_bg_s', []);    % White background std dev value

    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.s_m = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.w_m = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.s_bg_m = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.w_bg_m = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.s_s = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.w_s = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.s_bg_s = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & isnumeric(varargin{1})
      default_properties.w_bg_s = varargin{1};
      varargin(1) = [];
    end
    if length(varargin) >= 1 & ~ischar(varargin{1})
      error('Invalid parameter/value pair arguments.') 
    end
    
    % Attributes the inpout values to the variables
    prop = f_getopt(default_properties, varargin{:});
    s_m = prop.s_m; w_m = prop.w_m; s_bg_m = prop.s_bg_m; w_bg_m = prop.w_bg_m;

    % Compute uncertainties if the standard deviations are present as
    % input arguments
    if isequal(nargin, 8)
        s_s = prop.s_s; w_s = prop.w_s; s_bg_s = prop.s_bg_s; w_bg_s = prop.w_bg_s;
           
        % Uncertainty
        t_s = sqrt((1./(w_m - w_bg_m)).^2.* s_s.^2 + ...
            (-1./(w_m - w_bg_m)).^2.* s_bg_s.^2 + ...
            ((s_m - s_bg_m)./(w_m - w_bg_m).^2).^2.* w_bg_s.^2 + ...
            (-(s_m - s_bg_m)./(w_m - w_bg_m).^2).^2 .* w_s.^2);
    else
        t_s = [];
    end

    % Transmittance
    t_m = (s_m - s_bg_m )./ (w_m - w_bg_m);
    
end


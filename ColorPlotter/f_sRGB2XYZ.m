% ACL 2/2/2021

function XYZ = f_sRGB2XYZ(RGB)
    %% convert an sRGB vector into XYZ
     % https://en.wikipedia.org/wiki/SRGB
     % The CIE XYZ values must be scaled so that the Y of D65 ("white")
     % is 1.0 (X,Y,Z = 0.9505, 1.0000, 1.0890). This is usually true but
     % some color spaces use 100 or other values (such as in the Lab
     % article).
        
     % Normalize values to 1
     sRGB = double(RGB) / 255;
            
     %% declare constants
     m = [0.4124 0.3576 0.1805; 0.2126 0.7152 0.0722; 0.0193 0.1192 0.9505];
     a = 0.055;
            
     %% conditional mask
     rgb_lessorequal = (sRGB <= 0.04045);
            
     %% conditional assignment
     sRGB(rgb_lessorequal) = sRGB(rgb_lessorequal) / 12.92;
     sRGB(~rgb_lessorequal) = ((sRGB(~rgb_lessorequal)+ a)./(1+a)).^2.4;
            
     %% linearize
     XYZ = m * sRGB';
            
     %% comply with the old form
     XYZ = XYZ';
            
end
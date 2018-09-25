% fooof() - run the fooof model on a neural power spectrum
%
% Usage:
%   >> fooof_results = fooof(freqs, psd, f_range, settings);
%
% Inputs:
%   freqs           = row vector of frequency values
%   psd             = row vector of power values
%   f_range         = fitting range (Hz)
%   settings        = fooof model settings, in a struct, including:
%       settings.peak_width_limts
%       settings.max_n_peaks
%       settings.min_peak_amplitude
%       settings.peak_threshold
%       settings.background_mode
%       settings.verbose
%   return_model    = boolean of whether to return actual model, optional 
%
% Outputs:
%   fooof_results   = fooof model ouputs, in a struct, including:
%       fooof_results.background_params
%       fooof_results.peak_params
%       fooof_results.gaussian_params
%       fooof_results.error
%       fooof_results.r_squared
%
% Notes
%   Not all settings need to be set. Any settings that are not 
%     provided as set to default values. To run with all defaults, 
%     input settings as an empty struct. 

function fooof_results = fooof(freqs, psd, f_range, settings, return_model)

    % Check settings - get defaults for those not provided
    settings = fooof_check_settings(settings);

    % Convert inputs
    freqs = py.numpy.array(freqs);
    psd = py.numpy.array(psd);
    f_range = py.list(f_range);
    
    % Initialize FOOOF object
    fm = py.fooof.FOOOF(settings.peak_width_limits, ...
                        settings.max_n_peaks, ...
                        settings.min_peak_amplitude, ...
                        settings.peak_threshold, ...
                        settings.background_mode, ...
                        settings.verbose);
    
    % Run FOOOF fit
    fm.fit(freqs, psd, f_range)

    % Extract outputs
    fooof_results = fm.get_results();
    fooof_results = fooof_unpack_results(fooof_results);
    
    % Also return the actual model fit, if requested
    %   This will default to not return model, if variable not set
    if exist('return_model', 'var') && return_model
        
        % Get the model, and add outputs to foof_results
        model_out = fooof_get_model(fm);
        for field = fieldnames(model_out)'
            fooof_results.(field{1}) = model_out.(field{1});
        end
        
    end
    
end

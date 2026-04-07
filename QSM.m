function run_QSM_pipeline_bold(subID)
% run_QSM_pipeline_bold(subID)
%
% Performs full QSM reconstruction for a given subject ID using STISuite,
% following your BOLD naming convention and processed directory structure.
%
% Example:
%   run_QSM_pipeline_bold('pilot13')

    %% --- Setup ---
    clearvars -except subID
    close all
    clc

    % Add STISuite to path
    %% ADJUST THIS PATH WITH STISsuite DIRECTORY
    addpath(genpath('/projects/b1108/studies/BD2/scripts/QSM_libraries/STISuite_V3.0'))

    %% --- Parameters ---
    B0 = 3;
    B0_dir = [0 0 1];
    voxelsize = [0.70 0.70 1.3];
    padsize = [12 12 12];
    TE = [3.01, 7.83, 12.65, 17.08, 21.12, 25.21, 29.25, 33.34];

    %% --- Output File paths ---
    %% ADJUST THIS PATH WITH OUTPUT DIRECTORY
    proc_dir = fullfile('/projects/b1108/studies/BD2/data/processed/neuroimaging/STI_TIM', ...
        ['sub-' subID], 'ses-1');

    % Input files
    mag_path   = fullfile(proc_dir, ['sub-' subID '_ses-1_mag_bold.nii']);
    phase_path = fullfile(proc_dir, ['sub-' subID '_ses-1_phase_bold.nii']);
    mask_path  = fullfile(proc_dir, ['sub-' subID '_ses-1_mag_bold_brainmask.nii']); %resampled

    %% --- Load data ---
    fprintf('Loading data for sub-%s ...\n', subID);

    if ~isfile(mag_path)
        error('Magnitude file not found: %s', mag_path);
    end
    if ~isfile(phase_path)
        error('Phase file not found: %s', phase_path);
    end
    if ~isfile(mask_path)
        error('Mask file not found: %s', mask_path);
    end

    mag_nii   = load_untouch_nii(mag_path);
    phase_nii = load_untouch_nii(phase_path);
    mask_nii  = load_untouch_nii(mask_path);

    mag   = double(mag_nii.img);
    phase = double(phase_nii.img);
    mask  = double(mask_nii.img);

    %% --- Dimension check ---
    if ~isequal(size(mask), size(mag(:,:,:,1)))
        error('Mask and magnitude dimensions do not match for sub-%s.', subID);
    end

    %% --- Initialize arrays ---
    ph_scaled = zeros(size(phase));
    Unwrapped_Phase = zeros(size(mag));
    TissuePhase = zeros(size(mag));
    NewMask = zeros(size(mag));
    QSM = zeros(size(mag));

    %% --- QSM processing per echo ---
    for tt = 1:length(TE)
        fprintf('Processing echo %d/%d (TE = %.2f ms)\n', tt, length(TE), TE(tt));

        % Phase scaling
        ph_scaled(:,:,:,tt) = rescale(squeeze(phase(:,:,:,tt)), -pi, pi);

        % Laplacian unwrapping
        Unwrapped_Phase(:,:,:,tt) = MRPhaseUnwrap(ph_scaled(:,:,:,tt), ...
            'voxelsize', voxelsize, 'padsize', padsize);

        % Background field removal
        [TissuePhase(:,:,:,tt), NewMask(:,:,:,tt)] = V_SHARP(Unwrapped_Phase(:,:,:,tt), ...
            mask, 'voxelsize', voxelsize);

        % Dipole inversion
        QSM(:,:,:,tt) = QSM_iLSQR(TissuePhase(:,:,:,tt), NewMask(:,:,:,tt), ...
            'TE', TE(tt), 'B0', B0, 'H', B0_dir, ...
            'padsize', padsize, 'voxelsize', voxelsize);
    end

    %% --- Average susceptibility ---
    QSM_avg = mean(QSM, 4);
    
    %% ADJUST THIS PATH WITH OUTPUT DIRECTORY
    out_path = fullfile('/projects/b1108/studies/BD2/data/processed/neuroimaging/STI_TIM',['sub-' subID], 'ses-1', ['sub-', subID,'_QSM_avg.nii']);

    niftiwrite(QSM_avg, out_path);

end

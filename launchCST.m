function launchCST()

    % ============================================================
    % MODIFY THIS PATH
    % ============================================================
    cstPath = ...
        'C:\Program Files\CST Studio Suite 2025\AMD64\CST DESIGN ENVIRONMENT.exe';

    % ============================================================
    % CHECK IF CST EXISTS
    % ============================================================
    if ~isfile(cstPath)

        error('CST executable not found.');

    end

    % ============================================================
    % OPEN CST ONLY
    % ============================================================
    command = sprintf('"%s"', cstPath);

    system(command);

    disp('CST opened successfully.');
    disp('Run metamaterial_export.vba manually inside CST.');
end
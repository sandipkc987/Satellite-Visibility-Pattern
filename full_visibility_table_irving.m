%% FULL STARLINK VISIBILITY TABLE FROM IRVING TEXAS
% ========================================================================
% PURPOSE
% ========================================================================
% This script:
%   1) Loads the Walker-Delta constellation and tleTable from File-1
%   2) Adds Irving, Texas as a ground station
%   3) Computes access/visibility for ALL satellites
%   4) Builds the full paper-style visibility table
%   5) Tracks progress so runtime can be monitored
%   6) Exports results to Excel and MAT
%
% ========================================================================

clc;
clear;
close all;

%% ========================================================================
% 1) LOAD FILE-1 WORKSPACE
% ========================================================================

saveFolder = 'C:\Users\sandy\Downloads\Starlink Visiblity Pattern';
matFileName = fullfile(saveFolder,'starlink_first_shell_workspace.mat');

load(matFileName);

fprintf('Workspace loaded successfully.\n');

%% ========================================================================
% SETTING UP IRVING TEXAS GROUND STATION
% ========================================================================

gsLat = 32.8140;
gsLon = -96.9489;
gsAlt = 0;

% Setting up Minimum Elevation
minElevation = 10;

irvingGS = groundStation(sc, ...
    "Name","Irving Texas", ...
    "Latitude",gsLat, ...
    "Longitude",gsLon, ...
    "Altitude",gsAlt, ...
    "MinElevationAngle",minElevation);

fprintf('Ground station created at Irving, Texas.\n');

%% ========================================================================
% 3) PREPARE FOR FULL ACCESS COMPUTATION
% ========================================================================

numSat = numel(walkerSats);

% Result accumulator
allRows = table();

% Timing
tStart = tic;

fprintf('\n============================================================\n');
fprintf('Starting full visibility computation...\n');
fprintf('Total satellites to process: %d\n', numSat);
fprintf('Minimum elevation angle    : %.1f deg\n', minElevation);
fprintf('============================================================\n\n');

%% ========================================================================
% 4) LOOP THROUGH ALL SATELLITES
% ========================================================================

for k = 1:numSat

    % Current satellite metadata
    satObj   = walkerSats(k);
    satRow   = tleTable(k,:);
    satLabel = satRow.SatelliteLabel;

    % Compute access
    ac = access(satObj, irvingGS);
    T = accessIntervals(ac);

    % If any passes exist, convert to rows
    if ~isempty(T)

        nPass = height(T);

        StartTime = T.StartTime;
        EndTime   = T.EndTime;

        Duration_sec = round(seconds(EndTime - StartTime));

        % Orbit numbers estimated from reference TLE epoch
        StartOrbit = estimateOrbitNumber(tleEpoch, StartTime, ...
            satRow.MeanMotion_rev_per_day(1), satRow.RevAtEpoch(1));

        EndOrbit = estimateOrbitNumber(tleEpoch, EndTime, ...
            satRow.MeanMotion_rev_per_day(1), satRow.RevAtEpoch(1));

        Source = repmat(satLabel, nPass, 1);
        Target = repmat("Irving Texas", nPass, 1);
        Interval = (1:nPass).';

        PlaneNumber = repmat(satRow.PlaneNumber, nPass, 1);
        SatelliteInPlane = repmat(satRow.SatelliteInPlane, nPass, 1);
        CatalogNumber = repmat(satRow.CatalogNumber, nPass, 1);
        GlobalID = repmat(satRow.GlobalID, nPass, 1);
        IsHandler = repmat(satRow.IsHandler, nPass, 1);

        newRows = table( ...
            GlobalID, ...
            IsHandler, ...
            CatalogNumber, ...
            Source, ...
            Target, ...
            PlaneNumber, ...
            SatelliteInPlane, ...
            Interval, ...
            StartTime, ...
            EndTime, ...
            Duration_sec, ...
            StartOrbit, ...
            EndOrbit);

        newRows.Properties.VariableNames = { ...
            'GlobalID', ...
            'IsHandler', ...
            'CatalogNumber', ...
            'Source', ...
            'Target', ...
            'PlaneNumber', ...
            'SatelliteInPlane', ...
            'Interval', ...
            'StartTime', ...
            'EndTime', ...
            'Duration_sec', ...
            'StartOrbit', ...
            'EndOrbit'};

        allRows = [allRows; newRows]; %#ok<AGROW>
    end

    %% --------------------------------------------------------------------
    % PROGRESS DISPLAY
    % ---------------------------------------------------------------------
    elapsedSec = toc(tStart);
    pct = 100 * k / numSat;

    avgTimePerSat = elapsedSec / k;
    remainingSec = avgTimePerSat * (numSat - k);

    fprintf(['Processed satellite %4d / %4d | %6.2f%% | ' ...
             'Elapsed: %8.1f s | Remaining est.: %8.1f s | ' ...
             'Rows so far: %6d\n'], ...
             k, numSat, pct, elapsedSec, remainingSec, height(allRows));
end

%% ========================================================================
% 5) SORT RESULTS CHRONOLOGICALLY
% ========================================================================

if ~isempty(allRows)
    allRows = sortrows(allRows, "StartTime");
else
    warning('No visibility rows found for the current settings.');
end

%% ========================================================================
% 6) CREATE DISPLAY TABLE
% ========================================================================
% This version is easier to read and closer to the paper format.

if ~isempty(allRows)

    startStr = string(datestr(allRows.StartTime, 'dd-mmm-yyyy HH:MM:SS'));
    endStr   = string(datestr(allRows.EndTime,   'dd-mmm-yyyy HH:MM:SS'));

    visibilityTable = table( ...
        allRows.Source, ...
        allRows.Target, ...
        allRows.Interval, ...
        startStr, ...
        endStr, ...
        allRows.Duration_sec, ...
        allRows.StartOrbit, ...
        allRows.EndOrbit, ...
        allRows.PlaneNumber, ...
        allRows.SatelliteInPlane, ...
        'VariableNames', { ...
            'Source', ...
            'Target', ...
            'Interval', ...
            'StartTime', ...
            'EndTime', ...
            'Duration', ...
            'StartOrbit', ...
            'EndOrbit', ...
            'PlaneNumber', ...
            'SatelliteInPlane'} ...
        );

else
    visibilityTable = table();
end

%% ========================================================================
% 7) DISPLAY SUMMARY
% ========================================================================

totalElapsed = toc(tStart);

fprintf('\n============================================================\n');
fprintf('FULL VISIBILITY COMPUTATION COMPLETE\n');
fprintf('============================================================\n');
fprintf('Total satellites processed : %d\n', numSat);
fprintf('Total visibility rows      : %d\n', height(visibilityTable));
fprintf('Total runtime              : %.2f seconds\n', totalElapsed);
fprintf('============================================================\n\n');

if ~isempty(visibilityTable)
    disp('First 30 rows of visibility table:');
    disp(visibilityTable(1:min(30,height(visibilityTable)), :));
end

%% ========================================================================
% 8) EXPORT RESULTS
% ========================================================================

excelOut = fullfile(saveFolder, 'full_visibility_table_irving.xlsx');
matOut   = fullfile(saveFolder, 'full_visibility_table_irving.mat');

try
    writetable(visibilityTable, excelOut, 'Sheet', 'VisibilityTable');
    writetable(allRows, excelOut, 'Sheet', 'RawDateTimeTable');
    fprintf('Excel file saved successfully:\n%s\n', excelOut);
catch ME
    warning('Excel export failed: %s', ME.message);
end

save(matOut, 'visibilityTable', 'allRows', 'minElevation', 'totalElapsed');
fprintf('MAT file saved successfully:\n%s\n', matOut);

%% ========================================================================
% LOCAL FUNCTION
% ========================================================================

function orbitNum = estimateOrbitNumber(tleEpoch, t, n_rev_day, revAtEpoch)
    dt_days = days(t - tleEpoch);
    orbitNum = floor(revAtEpoch + n_rev_day .* dt_days);
end
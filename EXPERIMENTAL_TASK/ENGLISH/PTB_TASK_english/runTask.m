% % runTasK
%__________________________________________________________________________
%--------------------------------------------------------------------------
%
% Free operant task with outcome devaluation procedure Tricomi et al., (2009)
% PTB 3.0.12 on matlab 2015b
%__________________________________________________________________________
%-------------------------------------------------------------------------
% last modified on JANUARY 2018 by Eva

% added country variable to load the snacks according to local preferences
% main code changed, 1 function changed (uploadImages), new images added

% session = different sessions collected on different days
% run = different runs run on the same days
% button to answer: -d- -f- -j- -k- -left arrow- -right arrow- and -space-
% Press space to start runs



%**************************************************************************
%       PTB INITIALIZATION/PARAMETER SETUP
%**************************************************************************
try
    
    clear all
    
    % add the function folder to the path just for this session
    path(path, 'functions');
    
    % define variables
    var.country = input('***input*** USA (=1) or AUSTRALIA (=2): ' ); %
    var.real    = input('***input*** real experiment (=1) or testing (=0)?: '); % 1 = real experiment; 0 testing
    
    % get the response device index
    [id, names] = GetKeyboardIndices();
    disp ('list of devices:' )
    for i = 1:length(id)
        
        nameX = cellstr(names(i));
        idX   = id(i);
        disp (['ID number: ' idX  nameX])
        
    end
    var.deviceIndex = input('***input*** response device ID number (check list of devices above): ');
    
    % enter the task variables
    var.sub_ID = input('***input*** SUBJECT NUMBER: ');
    var.session = input('***input*** SESSION NUMBER (1,2 or 3 session day): '); % 1,2,or 3 session
    var.training = input('***input*** TRAINING SCHEDULE (1= 1-day group, 3= 3-day group): '); % 1 day or 3 days
    
    
    % check that task variable make sense
    var = inputCheck (var,1); % first check
    var = inputCheck (var,2); % second check (after variable have been adjusted)
    
    % enter the snack the participant prefers
    switch var.country
        
        case 1 % California
            var.salty= input('***input*** SWEET REWARD (1=M&M, 2=chocorice; 3=skittles): ');
            var.sweet = input('***input*** SALTY REWARD (4=cashew, 5=goldfish; 6=cheez-it): ');
        case 2 % Australia
            var.salty= input('***input*** SWEET REWARD (1=M&M, 2=maltesers; 3=skittles): ');
            var.sweet = input('***input*** SALTY REWARD (4=cashew, 5=doritos; 6=chips): ');
            
    end
    
    % initialize task parameters
    [var, data] = initTask(var);
    save(var.resultFile,'data');
    
    %**************************************************************************
    %        INITIAL HUNGER AND PLEASANTNESS RATINGS
    %**************************************************************************
    showInstruction(var,'instructions/ratings.txt')
    WaitSecs(0.4);
    while 1
        [~, ~, keycode] = KbCheck(-3,2);
        keyresp = find(keycode);
        if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
            break
        end
        
    end
    
    images           = {var.sweetImage, var.saltyImage};
    names            = {'sweet', 'savory'};
    questionX        = {var.sweetLabel; var.saltyLabel};
    
    % Randomize the image list
    randomIndex     = randperm(length(images));
    images          = images(randomIndex);
    names           = names (randomIndex);
    questionX       = questionX(randomIndex);
    
    for i = 1:length(images)
        
        if var.session == 1     %pleasantness ratings for snacks after tasting each snack (only in session 1)
            question = ['Please rate how pleasant the piece of ' char(questionX(i)) ' you just ate was'];
        else                    %pleasantness ratings for snacks they haven't tasted before (session 2&3)
            question = ['Please rate how pleasant you would find a piece of ' char(questionX(i)) ' right now'];
        end
        
        data.initialRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
        
        Screen('TextStyle', var.w, 1);
        Screen('TextSize', var.w, 36);
        DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
        Screen('Flip', var.w);
        WaitSecs(1+rand(1,1));
        
    end
    
    % Rate Hunger level
    question = 'Please rate your current hunger level';
    data.initialRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, 'very full', 'very hungry');
    
    Screen('TextStyle', var.w, 1);
    Screen('TextSize', var.w, 36);
    DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
    Screen('Flip', var.w);
    WaitSecs(1+rand(1,1));
    
    save (var.resultFile, 'data', '-append');
    
    
    %**************************************************************************
    %                ACTIVE TASK INSTRUCTIONS AND PRACTICE                    %
    %**************************************************************************
    if var.real == 1
        
        if var.session == 1 % we want this only for the first session
            
            %**********************************************************************
            % active instructions
            
            var.instructionSpeed = 2; % time in s for the slides that do not wait for a participant response
            activeInstruction(var);
            
            %**********************************************************************
            % practice blocK
            
            showInstruction(var, 'instructions/practice.txt')
            WaitSecs(0.4);
            KbWait(-3,2);
            
            % initialize just as time references for practice
            var.time_MRI = GetSecs();
            var.ref_end = 0;
            
            condition = [  1  2  0];% 1 = sweet 2 = salty; 0 = rest
            duration  = [ 20 20 20];
            [var.condition, var.duration] = loadRandList(condition, duration);
            
            for ii = 1:3 % 3 blocks for practice
                
                % show block
                var.ref_end = var.ref_end + var.duration(ii); % 20 or 40 s
                drawnActiveScreen (var,ii);
                % we do not save data of the practice blocks
                
            end
            
            showInstruction(var, 'instructions/question.txt')
            WaitSecs(0.4);
            KbWait(-3,2);
            
            
        end
        
    end
    %**************************************************************************
    %                      FREE OPERANT TRAINING                               %
    %**************************************************************************
    trial = 0;
    
    for i = 1:var.runs
        
        
        %%%%%%%%%%%%%%%% sync procedure and time initialization %%%%%%%%%%%%%%%%%%%
        
        RestrictKeysForKbCheck([]); % allow all butttons as inputs
        if i ==1
            showInstruction(var,'instructions/wait.txt'); % experiment about to start
        else
            showInstruction(var,'instructions/newRun.txt'); % next run is about to start
        end
        
        triggerscanner = 0;
        WaitSecs(0.4);
        while ~triggerscanner
            [down, secs, keycode, d] = KbCheck(-3,2);
            keyresp = find(keycode);
            if (down == 1)
                if ismember (keyresp, var.pulseKeyCode)
                    triggerscanner = 1;
                end
            end
            WaitSecs(.01);
        end
        
        % once the task is on we just check the task relevant button to avoid any interference
        RestrictKeysForKbCheck([var.leftKey, var.rightKey, var.centerLeftKey, var.centerRightKey, var.mycontrol]);
        
        var.time_MRI = GetSecs(); % absolute reference of the experiment beginning
        var.ref_end = 0;
        
        %%%%%%%%%%%%%%%% lead in screen for 2 s (is 2 s) %%%%%%%%%%%%%%%%%%%%%%
        var.ref_end = var.ref_end + 2;
        data.training.onsets.leadIn = GetSecs -var.time_MRI;
        data.training.durations.leadIn = displayITI(var);
        
        
        % randomize list for the run
        % each learning run has 12 task blocks and eight rest blocks.
        condition = [1  1  1  1  1  1  2  2  2  2  2  2  0  0  0  0  0  0  0  0 ]; % 1 = sweet 2 = salty; 0 = rest
        duration  = [40 40 20 20 20 20 40 40 20 20 20 20 20 20 20 20 20 20 20 20];% the duration of each block is 20s for rest and 20 or 40 for active blocks
        [var.condition, var.duration] = loadRandList(condition, duration);
        
        for ii = 1:length(var.condition)
            
            trial = trial+1;
            
            % show block
            var.ref_end = var.ref_end + var.duration(ii); % 20 or 40 s
            data.training.onsets.block(trial) = GetSecs - var.time_MRI; % get onset
            
            [RT, pressed_correct, pressed_all,...
                ACC, RT_all, Button,...
                reward, potential_rewards, potential_rewards_time,...
                duration] = drawnActiveScreen (var,ii);
            
            % log data
            data.training.stPressRT(trial)           = RT;
            data.training.raw_press(trial)           = pressed_correct;
            data.training.pressFreq(trial)           = pressed_correct/duration; % press per second
            data.training.raw_all_press(trial)       = pressed_all;
            data.training.all_pressFreq(trial)       = pressed_correct/duration; % press per second
            data.training.reward(trial)              = reward;
            data.training.blockDetails(trial).ACC    = ACC;
            data.training.blockDetails(trial).RT     = RT_all;
            data.training.blockDetails(trial).button = Button;
            data.training.blockDetails(trial).potential_rewards = potential_rewards;
            data.training.blockDetails(trial).potential_rewards_time = potential_rewards_time;
            data.training.durations.blocks(trial)    = duration;
            
            data.training.condition(trial)           = var.condition(ii);
            data.training.block    (trial)           = ii;
            data.training.run      (trial)           = i;
            data.training.session  (trial)           = var.session;
            data.training.subID    (trial)           = var.sub_ID;
            
            if var.condition(ii) == var.devalued
                data.training.value {trial}         = 'devalued';
            elseif var.condition(ii) == 0;
                data.training.value {trial}         = 'baseline';
            else
                data.training.value {trial}         = 'valued';
            end
            
            % save at the end of each active block
            save(var.resultFile, 'data', '-append');
            
        end % end of run
        %**************************************************************************
        %             PERFORMANCE FEEDBACK AND REWARD DELIVERY                    %
        %**************************************************************************
        
        thisRunSweet = data.training.reward ((data.training.condition == 1 ) & ( data.training.run == i ));
        thisRunSalty = data.training.reward ((data.training.condition == 2 ) & ( data.training.run == i ));
        
        won_sweet     = sum(thisRunSweet)/2;
        won_salty     = sum(thisRunSalty)/2;
        
        message = ['This run you won: ' num2str(won_sweet) ' ' var.sweetLabel ' and ' num2str(won_salty) ' ' var.saltyLabel ' ' '(Please inform the investigator).' ];
        
        % Screen settings
        Screen('TextFont', var.w, 'Arial');
        Screen('TextSize', var.w, var.scaledSize);
        Screen('TextStyle', var.w, 1);
        
        % Print the instruction on the screen
        DrawFormattedText(var.w, message, 'center', 'center', [0 0 0], 60);
        Screen(var.w, 'Flip');
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, var.mycontrol)
                break
            end
            
        end
        
    end % end of run
    
    
    %**************************************************************************
    %                    STIM_OUTCOME CONTIGENCY TEST                         %
    %**************************************************************************
    
    if var.session == 1 % first day only
        
        % test of knowledge of stimulus-outcome associations
        showInstruction(var,'instructions/ratings.txt')
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                break
            end
            
        end
        
        % prepare the images
        images           = {var.sweet_fractal, var.salty_fractal, var.rest_fractal};
        
        % define names by condition
        names            = {'sweet'; 'salty'; 'baseline'};
        condition        = [      1;       2;         0 ];
        
        % Randomize the image list
        randomIndex      = randperm(length(images));
        images           = images(randomIndex);
        names            = names (randomIndex);
        condition        = condition(randomIndex);
        
        for i = 1:length(images)
            
            question = ['When the fractal below was shown, was it more likely that a button press would result in a ' var.sweetLabel ' or a ' var.saltyLabel ' reward?'];
            
            data.contingencyTest.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, [var.sweetLabel ' more likely'], [var.saltyLabel  ' more likely']);
            
            % recode the rating so that the higher = the more accurate for both
            % food related-fractals
            if condition(i) == 1
                data.contingencyTest.(names{i}) = data.contingencyTest.(names{i}) * -1;
            end
            
            Screen('TextStyle', var.w, 1);
            Screen('TextSize', var.w, 36);
            DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
            Screen('Flip', var.w);
            WaitSecs(1+rand(1,1));
            
        end
        
        
    end
    
    
    %**************************************************************************
    %                        DEVALULATION PROCEDURE                           %
    %**************************************************************************
    if var.training == 1 || (var.training ==3 && var.session == 3)% only if it's the last training session for the experimental group
        
        disp ('Devaluation procedure is about to start...')
        beep; % beeping because it requires the experimenter to be active
        
        
        % show instruction for the devaluation procedure
        showBonus(var);
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, var.mycontrol)
                break
            end
            
        end
        
        % ratings after devaluation
        showInstruction(var,'instructions/ratings.txt')
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                break
            end
            
        end
        
        images           = {var.sweetImage, var.saltyImage};
        names            = {'sweet', 'salty'};
        questionX        = {var.sweetLabel; var.saltyLabel};
        
        % Randomize the image list
        randomIndex      = randperm(length(images));
        images           = images(randomIndex);
        names            = names (randomIndex);
        questionX        = questionX(randomIndex);
        
        for i = 1:length(images)
            
            question = ['Please rate how pleasant you would find a piece of ' char(questionX(i)) ' right now'];
            data.finalRatings.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
            
            Screen('TextStyle', var.w, 1);
            Screen('TextSize', var.w, 36);
            DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
            Screen('Flip', var.w);
            WaitSecs(1+rand(1,1));
            
        end
        
        % Rate Hunger level
        question = 'Please rate your current hunger level';
        data.finalRatings.hunger = likertScale(0, question, [1 2 3 4 5 6 7 8 9 10], var, 'very full', 'very hungry');
        
        Screen('TextStyle', var.w, 1);
        Screen('TextSize', var.w, 36);
        DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
        Screen('Flip', var.w);
        WaitSecs(1+rand(1,1));
        
        save(var.resultFile, 'data', '-append');
        
    end
    
    %**************************************************************************
    %                      RATING OF FRACTAL IMAGES                           %
    %**************************************************************************
    
    % pleasantness ratings of the fractal
    
    if var.training == 1 || (var.training ==3 && var.session == 3)% only if it's the last training session for the experimental group
        
        showInstruction(var,'instructions/ratings.txt')
        WaitSecs(0.4);
        while 1
            [~, ~, keycode] = KbCheck(-3,2);
            keyresp = find(keycode);
            if ismember (keyresp, [var.centerLeftKey, var.centerRightKey])
                break
            end
            
        end
        
        % prepare the images
        images           = {var.sweet_fractal, var.salty_fractal, var.rest_fractal};
        
        % define names by condition
        names            = {'sweet'; 'salty'; 'baseline'};
        %condition        = [    1;         2;         0 ];
        
        % Randomize the image list
        randomIndex     = randperm(length(images));
        images          = images(randomIndex);
        names           = names (randomIndex);
        
        for i = 1:length(images)
            
            question = 'Please rate the pleasantness of the fractal below';
            
            data.fractalLiking.(names{i}) = likertScale(images{i}, question, [-5 -4 -3 -2 -1 0 1 2 3 4 5], var, 'very unpleasant', 'very pleasant');
            
            Screen('TextStyle', var.w, 1);
            Screen('TextSize', var.w, 36);
            DrawFormattedText(var.w, '+', 'center', 'center', [0 0 0]);
            Screen('Flip', var.w);
            WaitSecs(1+rand(1,1));
            
        end
        
        
    end
    
    
    %**************************************************************************
    %                           EXTINCTIION TEST                              %
    %**************************************************************************
    
    if var.training == 1 || (var.training ==3 && var.session == 3) % only if it's the last training session for the experimental group
        disp ('Extinction procedure is about to start...')
        
        %%%%%%%%%%%%%%%% sync procedure and time initialization %%%%%%%%%%%%%%%%%%%
        RestrictKeysForKbCheck([]); % re-allow all keys to be read as inputs
        
        showInstruction(var,'instructions/newRun.txt');
        triggerscanner = 0;
        WaitSecs(0.4);
        while ~triggerscanner
            [down, secs, keycode, d] = KbCheck(-3,2);
            keyresp = find(keycode);
            if (down == 1)
                if ismember (keyresp, var.pulseKeyCode)
                    triggerscanner = 1;
                end
            end
            WaitSecs(.01);
        end
        
        % once the task is on we just check the task relevant button to avoid any interference
        RestrictKeysForKbCheck([var.leftKey, var.rightKey, var.centerLeftKey, var.centerRightKey, var.mycontrol]);
        
        var.time_MRI = GetSecs(); % absolute reference of the experiment beginning
        var.ref_end = 0;
        
        
        % randomize list for the run
        % the extinction run has 9 task blocks and 3 rest blocks.
        condition = [1  1  1  2  2  2  0  0  0 ]; % 1 = sweet 2 = salty; 0 = rest
        duration  = [20 20 20 20 20 20 20 20 20];% the duration of each block is 20s
        [var.condition, var.duration] = loadRandList(condition, duration);
        
        for trial = 1:length(var.condition)
            
            % show block
            var.ref_end = var.ref_end + var.duration(trial); % 20 or 40 s
            data.extinction.onsets.block(trial) = GetSecs - var.time_MRI; % get onset
            
            [RT, pressed_correct, pressed_all,...
                ACC, RT_all, Button, duration] = drawnExtinctionScreen (var,trial);
            
            % log data
            data.extinction.stPressRT(trial)           = RT;
            data.extinction.raw_press(trial)           = pressed_correct;
            data.extinction.pressFreq(trial)           = pressed_correct/duration; % press per second
            data.extinction.raw_all_press(trial)       = pressed_all;
            data.extinction.all_pressFreq(trial)       = pressed_correct/duration; % press per second
            data.extinction.blockDetails(trial).ACC    = ACC;
            data.extinction.blockDetails(trial).RT     = RT_all;
            data.extinction.blockDetails(trial).button = Button;
            data.extinction.durations.blocks(trial)    = duration;
            
            data.extinction.condition(trial)           = var.condition(trial);
            data.extinction.block    (trial)           = trial;
            data.extinction.run      (trial)           = i;
            data.extinction.session  (trial)           = var.session;
            data.extinction.subID    (trial)           = var.sub_ID;
            
            if var.condition(trial) == var.devalued
                data.extinction.value {trial}          = 'devalued';
            elseif var.condition(trial) == 0;
                data.extinction.value {trial}          = 'baseline';
            else
                data.extinction.value {trial}          = 'valued';
            end
            
            % save at the end of each extiction block
            save(var.resultFile, 'data', '-append');
            
        end
        
    end
    
    
    %**************************************************************************
    %                           END EXPERIMENT                                %
    %**************************************************************************
    
    data = endTask(var, data);
    
catch %#ok<*CTCH>
    % This "catch" section executes in case of an error in the "try"
    % section []
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
end

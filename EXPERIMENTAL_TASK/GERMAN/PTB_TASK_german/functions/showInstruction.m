function showInstruction(var, instructionFile)

% import the instructions from a file
instructionText = fileread(instructionFile);

% scale text size to the screen used
textref = 30;
windowref_y = 1560; % we want some thing that correpond to a size of 30 on a screen with a y of 1536
scaledSize = round((textref * var.rect(4)) / windowref_y);

% set screen setting

Screen('TextFont', var.w, 'Arial');
Screen('TextSize', var.w, 25);
Screen('TextStyle', var.w, 1);

% print the instruction on the screen
DrawFormattedText(var.w, instructionText, 'center', 'center', [0 0 0], 80, [], [], 1.2)
% DrawFormattedText(var.w, instructionText)

Screen(var.w, 'Flip');

end
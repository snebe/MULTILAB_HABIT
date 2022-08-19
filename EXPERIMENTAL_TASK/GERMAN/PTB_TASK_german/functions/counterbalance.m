function [var, data] = counterbalance(var)

% Last modifed on May 2017 by Eva
% Counterbalance the action-image-response association based on the participant ID
% the counterbalancement is complete only if there the same two actions
% possibles takes only the first three fractals from the original task 

var.list = randi(12);

if var.list == 1
    
    var.sweet_fractal        = imread('images/fractal1.jpg');
    var.sweet_action         = var.leftKey;
    var.sweet_square_pos     = var.square1; % square to the left

    var.salty_fractal        = imread('images/fractal2.jpg');
    var.salty_action         = var.centerLeftKey;
    var.salty_square_pos     = var.square2;% square to the right
    
    var.rest_fractal         = imread('images/fractal3.jpg');
      
elseif var.list == 2
    
    var.sweet_fractal        = imread('images/fractal1.jpg');
    var.sweet_action         = var.centerLeftKey;
    var.sweet_square_pos     = var.square2; 

    var.salty_fractal        = imread('images/fractal2.jpg');
    var.salty_action         = var.leftKey;
    var.salty_square_pos     = var.square1;

    var.rest_fractal          = imread('images/fractal3.jpg');
    
elseif var.list == 3
    
    var.sweet_fractal        = imread('images/fractal2.jpg');
    var.sweet_action         = var.leftKey;
    var.sweet_square_pos     = var.square1;

    var.salty_fractal        = imread('images/fractal1.jpg');
    var.salty_action         = var.centerLeftKey;
    var.salty_square_pos     = var.square2;
    
    var.rest_fractal         = imread('images/fractal3.jpg'); 
       
elseif var.list == 4
    
    var.sweet_fractal        = imread('images/fractal2.jpg');
    var.sweet_action         = var.centerLeftKey;
    var.sweet_square_pos     = var.square2;
    
    var.salty_fractal        = imread('images/fractal1.jpg');
    var.salty_action         = var.leftKey;
    var.salty_square_pos     = var.square1;
    
    var.rest_fractal         = imread('images/fractal3.jpg');
        
elseif var.list == 5
    
    var.sweet_fractal        = imread('images/fractal3.jpg');
    var.sweet_action         = var.leftKey;
    var.sweet_square_pos     = var.square1;
    
    var.salty_fractal        = imread('images/fractal1.jpg');
    var.salty_action         = var.centerLeftKey;
    var.salty_square_pos     = var.square2;
    
    var.rest_fractal         = imread('images/fractal2.jpg');
    
elseif var.list == 6
    
    var.sweet_fractal        = imread('images/fractal3.jpg');
    var.sweet_action         = var.centerLeftKey;
    var.sweet_square_pos     = var.square2;
    
    var.salty_fractal        = imread('images/fractal1.jpg');
    var.salty_action         = var.leftKey;
    var.salty_square_pos     = var.square1;
    
    var.rest_fractal        = imread('images/fractal2.jpg');
        
elseif var.list == 7
    
    var.sweet_fractal        = imread('images/fractal1.jpg');
    var.sweet_action         = var.centerLeftKey;
    var.sweet_square_pos     = var.square2;
    
    var.salty_fractal        = imread('images/fractal3.jpg');
    var.salty_action         = var.leftKey; 
    var.salty_square_pos     = var.square1;
    
    var.rest_fractal         = imread('images/fractal2.jpg');
        
elseif var.list == 8
    
    var.sweet_fractal        = imread('images/fractal1.jpg');
    var.sweet_action         = var.leftKey;
    var.sweet_square_pos     = var.square1;
    
    var.salty_fractal        = imread('images/fractal3.jpg');
    var.salty_action         = var.centerLeftKey;
    var.salty_square_pos     = var.square2;

    var.rest_fractal         = imread('images/fractal2.jpg');
    
elseif var.list == 9
    
    var.sweet_fractal        = imread('images/fractal2.jpg');
    var.sweet_action         = var.centerLeftKey;
    var.sweet_square_pos     = var.square2;
    
    var.salty_fractal        = imread('images/fractal3.jpg');
    var.salty_action         = var.leftKey;
    var.salty_square_pos     = var.square1;
    
    var.rest_fractal         = imread('images/fractal1.jpg');
    
elseif var.list == 10
    
    var.sweet_fractal        = imread('images/fractal2.jpg');
    var.sweet_action         = var.leftKey;
    var.sweet_square_pos     = var.square1;
    
    var.salty_fractal        = imread('images/fractal3.jpg');
    var.salty_action         = var.centerLeftKey;
    var.salty_square_pos     = var.square2;
    
    var.rest_fractal         = imread('images/fractal1.jpg');
       
elseif var.list == 11
    
    var.sweet_fractal        = imread('images/fractal3.jpg');
    var.sweet_action         = var.centerLeftKey;
    var.sweet_square_pos     = var.square2;
     
    var.salty_fractal        = imread('images/fractal2.jpg');
    var.salty_action         = var.leftKey;
    var.salty_square_pos     = var.square1;
    
    var.rest_fractal         = imread('images/fractal1.jpg');
    
elseif var.list == 12
    
    var.sweet_fractal        = imread('images/fractal3.jpg');
    var.sweet_action         = var.leftKey;
    var.sweet_square_pos     = var.square1;
    
    var.salty_fractal        = imread('images/fractal2.jpg');
    var.salty_action         = var.centerLeftKey;
    var.salty_square_pos     = var.square2;
    
    var.rest_fractal         = imread('images/fractal1.jpg');
    
end


% assign value de valued role to one of the snacks (alternate)
if  mod((var.list),2) == 0
    
    var.devalued = 1; % devalue sweet for even numbers
    data.target  = 'sweet';
   
else
    
    var.devalued = 2; % devalue salty for odd numbers
    data.target  = 'salty';

end
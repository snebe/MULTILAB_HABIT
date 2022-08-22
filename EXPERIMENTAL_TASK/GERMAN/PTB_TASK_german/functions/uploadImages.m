function [var] = uploadImages (var)

% last modifed on June 2016 

snackTypeText = importdata('instructions/snackTypes.txt');

% SWEET OPTION    
    
%     case 1  % case participant likes M&Ms the most
        [var.sweetImage1, ~, alpha] = imread('images/MM.png');
        var.sweetImage1(:,:,4) = alpha;
        var.sweetLabel1 = snackTypeText{1};
        
%     case 2 % case participant likes Riesen the most
        [var.sweetImage2, ~, alpha] = imread('images/Riesen.png');
        var.sweetImage2(:,:,4) = alpha;
        var.sweetLabel2 = snackTypeText{2};

%     case 3  % case participant likes Schokobons the most
        [var.sweetImage3, ~, alpha] = imread('images/Schokobon.png');
        var.sweetImage3(:,:,4) = alpha;
        var.sweetLabel3 = snackTypeText{3};
        
        
% SALTY OPTION
             
%     case 4 % case participant likes  cashew the most 
        [var.saltyImage4, ~, alpha] = imread('images/Erdnüsse.png');
        var.saltyImage4(:,:,4) = alpha;
        var.saltyLabel4 = snackTypeText{4};
        
%     case 5 % case participant likes goldenfish craker the most 
        [var.saltyImage5, ~, alpha] = imread('images/Chips.png');
        var.saltyImage5(:,:,4) = alpha;
        var.saltyLabel5 = snackTypeText{5};
        
%     case 6 % case participant likes  cheez it the most
        [var.saltyImage6, ~, alpha] = imread('images/TUC.png');
        var.saltyImage6(:,:,4) = alpha;
        var.saltyLabel6 = snackTypeText{6};
        
end


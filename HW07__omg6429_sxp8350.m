% Homework 7
% Computer Vision
% Authors
%   Owen Gruss omg6429
%   Paul Suwamik sxp8350

function HW07_omg6429_sxp8350()
    HW07_omg6429_sxp8350_MAIN();
    %find_dice('img_7061__touching.jpg');
    
end

%Main function that calls find dice on every image in the same directory as
%itself.
function HW07_omg6429_sxp8350_MAIN()
    addpath('../TEST_IMAGES');
    files = show_all_files_in_dir();
    for counter = 1 : length(files)
        find_dice(files(counter).name);
    end
end

%Find all of the images in the current directory or test images.
function file_list = show_all_files_in_dir()
    file_list = dir('*.jpg');
    for counter = 1 : length( file_list )
        fn = file_list(counter).name;
    end
end


% finds dice in the given image, then calls subroutine that finds the dots
% on each dice.
%
% params:
%   img_name - the name of the image to analyze
function find_dice(img_name)
    im_original = imread(img_name);
    
    %rotate the image if it is portrait
    dims = size(im_original);
    if dims(1) > dims(2)
        imrotate(im_original, 90);
    end

    %get the red channel
    im_red = im_original(:,:,1);
 
    %threshold the dice using the red channel to include the red writing
    im_foreground = im_red(:,:) > 180;
    
    %erode the image to remove as many white specs from the background and
    %dots as possible
    erosion_filter = [1 1 1 ; 1 1 1 ; 1 1 1 ];
    im_foreground = imerode(im_foreground, erosion_filter);
    
    
    %imshow(im_foreground);
    current_figure = figure;
    hold on;
    
    
    %seperate the white dice from the black bakgound
    [parts, num_parts] = bwlabel(im_foreground, 8);
    
    
    %track the results
    number_of_dice = 0;
    numbers_on_dice = [0 0 0 0 0 0 0];
    sum_of_all_dots = 0;
    
    %loop through the white regions (dice)
    for count = 1 : num_parts
        part = parts == count;
        props = regionprops(part);
        
        %check if the area is actually a die
        if props.Area > 500 && props.Area < 300000
            %Plot box on the figure
            xs = [props.BoundingBox(1), props.BoundingBox(1), ...
                  props.BoundingBox(1) + props.BoundingBox(3), ...
                  props.BoundingBox(1) + props.BoundingBox(3), ...
                  props.BoundingBox(1)];
            ys = [props.BoundingBox(2), ...
                  props.BoundingBox(2) + props.BoundingBox(4), ...
                  props.BoundingBox(2) + props.BoundingBox(4), ...
                  props.BoundingBox(2), ...
                  props.BoundingBox(2)];
            %Plot the boxes in the current figure;
            plot (xs, ys, 'Color', [0, 1, 0] , 'LineWidth', 2);
            
        
            %save the number of dice in the list, if there are more than 6
            %dots put it in the unkown section.
            number_of_dice = number_of_dice + 1;
            num_dots = count_dots_on_dice(part);
            sum_of_all_dots = sum_of_all_dots + num_dots;
            if (num_dots > 0 && num_dots < 7)
                numbers_on_dice(num_dots) = numbers_on_dice(num_dots) + 1;
            else
                numbers_on_dice(7) = numbers_on_dice(7) + 1;
            end    
        end
    end
   
    %Display output
    fprintf("INPUT Filename:\t\t%s\n", img_name);
    fprintf("Number of Dice:\t\t%d\n", number_of_dice);
    fprintf("Number of 1's:\t\t%d\n", numbers_on_dice(1));
    fprintf("Number of 2's:\t\t%d\n", numbers_on_dice(2));
    fprintf("Number of 3's:\t\t%d\n", numbers_on_dice(3));
    fprintf("Number of 4's:\t\t%d\n", numbers_on_dice(4));
    fprintf("Number of 5's:\t\t%d\n", numbers_on_dice(5));
    fprintf("Number of 6's:\t\t%d\n", numbers_on_dice(6));
    fprintf("Number of Unknown:\t%d\n", numbers_on_dice(7));
    fprintf("Total of all dots:\t%d\n", sum_of_all_dots);
    
    %finish the final display
    title('Final Image');
    set(gca, 'ydir', 'reverse')
    info = imagesc(im_original);
    uistack(info, 'down', number_of_dice);
    drawnow;
    
end

%
% Finds all of the dots on a single die, given a BW image
%
% params:
%   dice_img - a black and white image with a single dice
% params:
%   num_dots - the total number of dots on the dice
function num_dots = count_dots_on_dice(dice_img)
    %input is white dice on black background, make dots white
    im_dots = ~dice_img;
    
    %use bwlabel to seperate the dots from the dice
    [parts, num_parts] = bwlabel(im_dots, 8);
    
    %loop through the black regions
    num_dots = 0;
    for count = 1 : num_parts
        part = parts == count;
        props = regionprops(part);
        
        %check if the region is a dot, excludes blemishes and the
        %background
        if (props.Area < 10000 && props.Area > 1500)
            num_dots = num_dots + 1;
        end
    end    
end




function [BodyMap] = BodyHeatMapGenerator(Bodydata, mask)
%  Generates a heat body map from blue (1) to white (0) to red (-1).
%  Regions have already been predefined according to the Qualtrics body
%  map. 
% Example usage: Bodymap = GenerateHeatMapTouchTestBody(templatedata, mask)



% Requires the 768 x 750 Body image to be in the same folder as the script
% called 'body1.png'. And the mastermask.mat structure file loaded into the workspace (if not you must use the GenerateRegionMask script). 
% Feed into the function a table (eg imported from% excel as a .csv) which uses the following header column names (order irrelevant):     

% FrontForehead
% FrontCrotch        
% FrontFeet          
% FrontForearms      
% FrontHands         
% FrontKnees         
% FrontMidArm        
% FrontMiddleTors    
% FrontShins         
% FrontShoulders     
% FrontStomach       
% FrontThighs        
% FrontUpperBack     
% FrontJaw           
% FrontMiddleHead    
% FrontNeck          
% BackHead		
% BackNeck    	
% BackUpperBack	
% BackShoulders	
% BackMiddleBack
% BackLowerBack	
% BackButtocks	
% BackMidArms	
% BackForeArms	
% BackHands		
% BackThighs 	
% BackKnees		
% BackCalves 	
% BackFeet 		
%
%

% The data contained in this .csv must be from -1 to 1 and must not have
% missing values.


%% Generate a mask for a region. ie which pixels indicate the particular region of interest. In this case delineate in a photo editing software (ie photoshop/GIMP) and 
% colour only that region in pure red. The below code will automatically
% detect the red and remove all else. The below is only needed once so it
% is commented here for future use if needed.

% [rgbImage storedColorMap] = imread('FrontFeet.png');
% [rows columns numberOfColorBands] = size(rgbImage);
% 
% redBand = rgbImage(:, :, 1);
% greenBand = rgbImage(:, :, 2);
% blueBand = rgbImage(:, :, 3);
% redThresholdLow = graythresh(redBand);
% redThresholdHigh = 255;
% greenThresholdLow = 0;
% greenThresholdHigh = graythresh(greenBand);
% blueThresholdLow = 0;
% blueThresholdHigh = graythresh(blueBand);
% redMask = (redBand >= redThresholdLow) & (redBand <= redThresholdHigh);
% greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
% blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);
% redObjectsMask = uint8(redMask & greenMask & blueMask);
% imshow(redObjectsMask, []);
% 
% maskFrontFeet = redObjectsMask; % change this for each region
%%

bodydata = Bodydata;

index.FrontForehead = find((mask.FrontForehead));
index.FrontCrotch = find((mask.FrontCrotch));
index.FrontFeet = find((mask.FrontFeet));
index.FrontForearms = find((mask.FrontForearms));
index.FrontHands = find((mask.FrontHands));
index.FrontKnees = find((mask.FrontKnees));
index.FrontMidArm = find((mask.FrontMidArm));
index.FrontMiddleTorso = find((mask.FrontMiddleTorso));
index.FrontShins = find((mask.FrontShins));
index.FrontShoulders = find((mask.FrontShoulders));
index.FrontStomach = find((mask.FrontStomach));
index.FrontThighs = find((mask.FrontThighs));
index.FrontUpperBack = find((mask.FrontUpperBack));
index.FrontJaw = find((mask.FrontJaw));
index.FrontMiddleHead = find((mask.FrontMidHead));
index.FrontNeck = find((mask.FrontNeck));

index.BackHeadTop		 = find((mask.BackHeadTop));
index.BackHeadMid		 = find((mask.BackHeadMid));
index.BackHeadBot		 = find((mask.BackHeadBot));
index.BackNeck    	= find((mask.BackNeck));
index.BackUpperBack	 = find((mask.BackUpperBack));
index.BackShoulders		 = find((mask.BackShoulders));
index.BackMiddleBack	 = find((mask.BackMiddleBack));
index.BackLowerBack	 = find((mask.BackLowerBack));
index.BackButtocks	 = find((mask.BackButtocks));
index.BackMidArms	 = find((mask.BackMidArms));
index.BackForeArms	 = find((mask.BackForeArms));
index.BackHands		= find((mask.BackHands));
index.BackThighs 	= find((mask.BackThighs));
index.BackKnees		 = find((mask.BackKnees));
index.BackCalves 	= find((mask.BackCalves));
index.BackFeet 		= find((mask.BackFeet));

MasterBody = imread('body1.png'); % read in the master image
BodyMap = MasterBody;

RedIndex = 0;
GreenIndex = 576000;
BlueIndex = 576000*2;


Frontdata.FrontForehead    = bodydata.FrontForehead         ;
Frontdata.FrontCrotch      = bodydata.FrontCrotch           ;
Frontdata.FrontFeet        = bodydata.FrontFeet             ;
Frontdata.FrontForearms    = bodydata.FrontForearms         ;
Frontdata.FrontHands       = bodydata.FrontHands            ;
Frontdata.FrontKnees       = bodydata.FrontKnees            ;
Frontdata.FrontMidArm      = bodydata.FrontMidArm           ;
Frontdata.FrontMiddleTorso = bodydata.FrontMiddleTors       ;
Frontdata.FrontShins       = bodydata.FrontShins            ;
Frontdata.FrontShoulders   = bodydata.FrontShoulders        ;
Frontdata.FrontStomach     = bodydata.FrontStomach          ;
Frontdata.FrontThighs      = bodydata.FrontThighs           ;
Frontdata.FrontUpperBack   = bodydata.FrontUpperBack        ;
Frontdata.FrontJaw         = bodydata.FrontJaw              ;
Frontdata.FrontMiddleHead  = bodydata.FrontMiddleHead       ;
Frontdata.FrontNeck        = bodydata.FrontNeck             ;

% Backdata.BackHead    = bodydata.BackHead   ;

Backdata.BackHeadTop      = bodydata.BackHeadTop		    ;
Backdata.BackHeadMid      = bodydata.BackHeadMid		    ;
Backdata.BackHeadBot      = bodydata.BackHeadBot		    ;
Backdata.BackNeck    	  = bodydata.BackNeck    	        ;
Backdata.BackUpperBack	  = bodydata.BackUpperBack	        ;
Backdata.BackShoulders	  = bodydata.BackShoulders	        ;
Backdata.BackMiddleBack   = bodydata.BackMiddleBack       ;
Backdata.BackLowerBack	  = bodydata.BackLowerBack	        ;
Backdata.BackButtocks	  = bodydata.BackButtocks	        ;
Backdata.BackMidArms	  = bodydata.BackMidArms	      ;
Backdata.BackForeArms	  = bodydata.BackForeArms	        ;
Backdata.BackHands		  = bodydata.BackHands		        ;
Backdata.BackThighs 	  = bodydata.BackThighs 	        ;
Backdata.BackKnees		  = bodydata.BackKnees		        ;
Backdata.BackCalves 	  = bodydata.BackCalves 	        ;
Backdata.BackFeet 		  = bodydata.BackFeet 		        ;

RegionFrontLabel = ["FrontForehead", "FrontCrotch", "FrontFeet", "FrontForearms", "FrontHands", "FrontKnees", "FrontMidArm", "FrontMiddleTorso", "FrontShins", "FrontShoulders", "FrontStomach", ...
    "FrontThighs", "FrontUpperBack", "FrontJaw", "FrontMiddleHead", "FrontNeck"] ;
for i = 1:length(RegionFrontLabel)
    templabel = RegionFrontLabel{i};
    if Frontdata.(templabel) > 0
        BodyMap(RedIndex+(index.(templabel))) = 255 - (255*abs(Frontdata.(templabel)));
        BodyMap(GreenIndex+(index.(templabel))) = 255 - (255*abs(Frontdata.(templabel)));
        BodyMap(BlueIndex+(index.(templabel))) = 255;
    elseif Frontdata.(templabel) < 0 
        BodyMap(RedIndex+(index.(templabel))) = 255;
        BodyMap(GreenIndex+(index.(templabel))) = 255 - (255*abs(Frontdata.(templabel)));
        BodyMap(BlueIndex+(index.(templabel))) = 255 - (255*abs(Frontdata.(templabel)));
    elseif Frontdata.(templabel) == 0
        BodyMap(RedIndex+(index.(templabel))) = 255;
        BodyMap(GreenIndex+(index.(templabel))) = 255;
        BodyMap(BlueIndex+(index.(templabel))) = 255;
    end
end
        

RegionBackLabel = ["BackHeadTop", "BackHeadMid", "BackHeadBot", "BackNeck", "BackUpperBack", "BackShoulders", "BackMiddleBack", "BackLowerBack", "BackButtocks", "BackMidArms",...
    "BackForeArms", "BackHands", "BackThighs", "BackKnees", "BackCalves", "BackFeet"] ;
for i = 1:length(RegionBackLabel)
    templabel = RegionBackLabel{i};
    if Backdata.(templabel) > 0
        BodyMap(RedIndex+(index.(templabel))) = 255 - (255*abs(Backdata.(templabel)));
        BodyMap(GreenIndex+(index.(templabel))) = 255 - (255*abs(Backdata.(templabel)));
        BodyMap(BlueIndex+(index.(templabel))) = 255;
    elseif Backdata.(templabel) < 0 
        BodyMap(RedIndex+(index.(templabel))) = 255;
        BodyMap(GreenIndex+(index.(templabel))) = 255 - (255*abs(Backdata.(templabel)));
        BodyMap(BlueIndex+(index.(templabel))) = 255 - (255*abs(Backdata.(templabel)));
    elseif Backdata.(templabel) == 0
        BodyMap(RedIndex+(index.(templabel))) = 255;
        BodyMap(GreenIndex+(index.(templabel))) = 255;
        BodyMap(BlueIndex+(index.(templabel))) = 255;
    end
end

imshow(BodyMap);
colorbar;
colormap(b2r(-1,1));


% outputArg1 = inputArg1;
% outputArg2 = inputArg2;
end


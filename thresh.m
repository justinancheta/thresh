function outData = thresh(inData, varargin)
%
%   ABOUT: Clips an input ND array to an input threshold value. By default
%   the function will sign the threshold value as (±) based on the sign of
%   the input array. Multiple options provided to provide min, max and
%   absolute value logic statements (see Remarks). At least one numeric
%   value needs to be provided to the varargin. 
%
%   INPUTS: 
%           inData      <double>    N-D array which we want to clip
%           minValue    <double>    Minimum value for data set to be
%                                   clipped at 
%           maxValue    <double>    Minimum value for data set to be
%                                   clipped at 
%           opt         <char>      Optional inputs to apply different
%                                   logic statements ('max', 'abs')
%   OUTPUTS:
%           outData     <double>    N-D array which has been bounded
%   SYNTAX:
%           1. Bounds all data assuming a minimum input value: 
%           [outValue] =  thresh(inData, 1);    
%                                               
%           2. Bounds all data using a maximum input value: 
%           [outValue] =  thresh(inData, 1, 'max');                                          
%
%           3. Bounds all data using a minimum input value and applying to
%           both sides ( X >= +1, X <= -1): 
%           [outValue] =  thresh(inData, 1, 'abs'); 
%
%           4. Bounds all data using a maximum input value and applying to
%           both sides ( X <= -1, X >= 1)
%           [outValue] =  thresh(inData, 1, 'max', 'abs');
%
%           5. Bounds all data to range [1,2]
%           [outValue] =  thresh(inData, 1, 2); 
%
%           6. Bounds all data to range [-2, -1], [1, 2] 
%           [outValue] =  thresh(inData, 1, 2, 'abs'); 
%
%   TODO:  
%           N/A
%   Remarks:
%           1) This function by default will clip all values in the input
%           array to the minimum value :
%                    Y = { X if X >= minValue       
%                        { minValue if X < minValue
%
%           becomes the minValue. If two values are provided in the
%           argument then data will be bounded as 
%
%                        { maxValue if X > maxValue
%                    Y = { X if and( X >= minValue , X <= minValue )  
%                        { minValue if X < minValue
%
%           In some cases the user may wish to have the minimum or maximum
%           value apply as absolute values. In this case providing the
%           'abs' operator to the input will force the data to apply the
%           threshold to the input data and sign the data appropriately. 
%
%                        { maxValue if X > maxValue
%                        { maxValue if X > maxValue
%                    Y = { X if and( X >= minValue , X <= minValue )  
%                        { minValue if X < minValue
%                        { maxValue if X > maxValue
%
%           The table below provides an idea of each input option. Note
%           case D has very little use, but I included since it has use for
%           creating non-zero values as one approaches for the input data
%           set (i.e. percentage uncertainties which cross through zero)
% 
% Case      A              B                 C                    D             E   
% Input | Min = 0 | Min = -3, Max = 4 | Min = 2, abs | Min = 2, Max = 4, abs | Max 2    
%    -5 |    0    |       -3          |      -5      |            -4         | -5      
%    -4 |    0    |       -3          |      -4      |            -4         | -4   
%    -3 |    0    |       -3          |      -3      |            -3         | -3   
%    -2 |    0    |       -2          |      -2      |            -2         | -2   
%    -1 |    0    |       -1          |      -2      |            -2         | -1   
%     0 |    0    |        0          |       2      |             2         |  0   
%     1 |    1    |        1          |       2      |             2         |  1   
%     2 |    2    |        2          |       2      |             2         |  2   
%     3 |    3    |        3          |       3      |             3         |  2   
%     4 |    4    |        4          |       4      |             4         |  2   
%     5 |    5    |        4          |       5      |             4         |  2   
%
%           2) Zeros are treated as positives for applying threshold values
%              using the 'abs' argument. 
%
%           3) NaN values are ignored. 
%
%           4) If an absolute value option is used, negative values are
%              treated as positive for evaluation. Edge cases for
%              -a,a,'abs' are used, an N-D array of value "a" is returned.
% 
%           5) Order for min and max are ignored if more than two numerical
%              values are input.
%  

%% Parse the inputs 

    % Set default behavior
    treatAsMinimumValue = true;
    treatAsAbsoluteValue = false; 

    % Check to make sure that we are only operating on numerical data 
    assert(isnumeric(inData),'jtk:solver:thresh',...
    'Input values for input data (inData) are non-numeric')

    % Parse out the numerical arguments 
    inputThresholdsIndices = cellfun(@isnumeric, varargin);
   
    switch sum(inputThresholdsIndices)
        case 0
            error('jtk:solver:thresh',...
            'No values for thresholds were provided')
        case 1
            thresholdValue = [varargin{inputThresholdsIndices}];
            assert( ~isnan(thresholdValue),'jtk:solver:thresh',...
                   'Threshold value is NaN')
        case 2
            thresholdValue = sort([varargin{inputThresholdsIndices}]);
            assert( ~any(isnan(thresholdValue)),'jtk:solver:thresh',...
                   'At least one threshold value is NaN.')
        otherwise
            error('jtk:solver:thresh',...
            'Too many numerical values provided, provide at most two options')
    end
    
    % If any of the input values are "absolute" or "abs" treate as an
    % absolute value logic statement 
    checkAbs = any(strcmpi(varargin,'abs'));
    checkAbsoltue = any(strcmpi(varargin,'absolute'));
    if or(checkAbs, checkAbsoltue)
        treatAsAbsoluteValue = true;
    end
    
    checkMax = any(strcmpi(varargin,'max'));
    checkMaximum = any(strcmpi(varargin,'maximum'));
    if or(checkMax, checkMaximum)
        treatAsMinimumValue = false;
    end
    
    % Note that in cases of say [-b, a] w/ 'abs' this provides the band
    % [-b,b] or [-a, a], whichever is larger. Handling this case up front
    % makes it easier to code the bounding logic when replacing data in the
    % output "outData".
    if all([numel(thresholdValue) == 2, sum( thresholdValue < 0) == 1, treatAsAbsoluteValue ])
        testB = min(abs(thresholdValue));
        testA = max(abs(thresholdValue));
        if testB > testA
            thresholdValue = testB;
            treatAsMinimumValue = false;
        elseif testA > testB
            thresholdValue = testA;
            treatAsMinimumValue = false;
        end
    end
    
    % Copy input to output to operate as we go through the potential
    % options
    outData = inData;
    
    if treatAsAbsoluteValue
        % Begin the basic banded two value absolute value 
        if numel(thresholdValue) == 2
            lowerBounds = [-max( abs(thresholdValue) ), -min( abs(thresholdValue)) ];
            upperBounds = [ min( abs(thresholdValue) ),  max( abs(thresholdValue)) ];
            
            % Find the indices to replace for the lower bound (negative
            % values). 
            lowerValues = inData;
            indsLowerMax = and( inData > lowerBounds(2), inData < 0);
            indsLowerMin = and( inData < lowerBounds(1), inData < 0);
            lowerValues(indsLowerMax) = lowerBounds(2);
            lowerValues(indsLowerMin) = lowerBounds(1);
            indsLowerReplace = or(indsLowerMax, indsLowerMin);
            
            upperValues = inData;
            indsUpperMax = and( inData > upperBounds(2), inData >= 0);
            indsLowerMin = and( inData < upperBounds(1), inData >= 0);
            upperValues(indsUpperMax) = upperBounds(2);
            upperValues(indsLowerMin) = upperBounds(1);
            indsUpperReplace = or(indsUpperMax, indsLowerMin);
            
            outData(indsLowerReplace) = lowerValues(indsLowerReplace);
            outData(indsUpperReplace) = upperValues(indsUpperReplace);
            % End the 2 value banded absolute routine
        elseif and(numel(thresholdValue) == 1, treatAsMinimumValue)
            % In this case anything in the range [-a,a] is set to the
            % threshold value, with a crossover at zero
            outData( and( inData <=  abs(thresholdValue), inData >= 0 ) ) =  abs(thresholdValue);
            outData( and( inData >= -abs(thresholdValue), inData < 0  ) ) = -abs(thresholdValue);

        elseif and(numel(thresholdValue) == 1, ~treatAsMinimumValue)
            outData( and( inData >=  abs(thresholdValue), inData >= 0 ) ) =  abs(thresholdValue);
            outData( and( inData <= -abs(thresholdValue), inData < 0  ) ) = -abs(thresholdValue);
        else
           error('You should not have gotten to this line, a logic check failed when looking at "abs"'); 
        end
        % End of absolute value logic statements 
    else
        % Begin the basic banded two value absolute value 
        if numel(thresholdValue) == 2   
            % For a band of values, we can simply cap everything at a
            % threshold value 
            outData( inData < min(thresholdValue) ) = min(thresholdValue);
            outData( inData > max(thresholdValue) ) = max(thresholdValue);
        elseif and(numel(thresholdValue) == 1, treatAsMinimumValue)
            outData( inData < min(thresholdValue) ) = min(thresholdValue);
        elseif and(numel(thresholdValue) == 1, ~treatAsMinimumValue)
            outData( inData > max(thresholdValue) ) = max(thresholdValue);
        else
           error('You should not have gotten to this line, a logic check failed when looking at "abs"'); 
        end
        % End of non-absolute value logic statements
    end
    
    
end

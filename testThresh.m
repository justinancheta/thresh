%% USER INPUTS 
cleanWorkspace = true;
plotLinePlots  = true;
plotSurfacePlots = true; 
adjustPlottingDefaults = true;

%% Basic Env. Setup 
if cleanWorkspace
    clearvars -except plotLinePlots plotSurfacePlots adjustPlottingDefaults
end

if adjustPlottingDefaults
% Setup some default plotting options 
    set(groot,'defaultFigurePosition',[225,40,1440,900]);
    set(groot,'defaultAxesFontSize',16);
    set(groot,'defaultAxesLineStyleOrder',{'-','--','-.','--'});
    set(groot,'defaultAxesLineWidth',1.2);

% Colors
Colors = [  [230 025 075]; % Distinct Red
            [060 180 075]; % Distinct Green
            [000 130 200]; % Distinct Blue
            [245 130 048]; % Distinct Orange
            [240 050 230]; % Distinct Magenta
            [070 240 240]; % Distinct Cyan
            [170 110 040]; % Distinct Brown
            [000 128 128]; % Distinct Teal
            [220 190 255]; % Distinct Lavendar
         ]/255;

    set(groot,'defaultAxesColorOrder',Colors); clear Colors;
    set(groot,'defaultLineLineWidth',1.2);
    set(groot,'defaultTextFontSize', 14);
end


%% Line Plots
if plotLinePlots
    inData = -5:0.01:5;
    % 1. Bounds all data assuming a minimum input value: 
    out1 =  thresh(inData, 1);    

    % 2. Bounds all data using a maximum input value: 
    out2 =  thresh(inData, 1, 'max');                                          

    % 3. Bounds all data using a minimum input value and applying to
    % both sides ( X >= +1, X <= -1): 
    out3 =  thresh(inData, 1, 'abs'); 

    % 4. Bounds all data using a maximum input value and applying to
    % both sides ( X <= -1, X >= 1)
    out4 =  thresh(inData, 1, 'max', 'abs');

    % 5. Bounds all data to range [1,2]
     out5 =  thresh(inData, 1, 2); 

    % 6. Bounds all data to range [-2, -1], [1, 2] 
     out6 =  thresh(inData, 1, 2, 'abs'); 

     % Plot everything up;
     fig = figure; 
     hold on; grid on;
     plot(inData,inData,'DisplayName','Original Values');
     plot(inData, out1,'--','DisplayName','Minimum value of 1');
     plot(inData, out2,'--','DisplayName','Maximum value of 1');
     plot(inData, out3,'--','DisplayName','Threshold values of -1 and 1 using Absolute Value 1');
     plot(inData, out4,'--','DisplayName','Bounds values between [-1,1] using Absolute Value 1');
     plot(inData, out5,'--','DisplayName','Between range [1 2]');
     plot(inData, out6,'--','DisplayName','In range [-2,1] and [ 1, 2]');
     legend('location','bestoutside')
end

if plotSurfacePlots
    [xx,yy] = ndgrid( -5:0.1:5, -2:0.1:2); 
    % Clip values based on value of X 
    inData = xx; 
    % 1. Bounds all data assuming a minimum input value: 
    out1 =  thresh(inData, 1);    

    % 2. Bounds all data using a maximum input value: 
    out2 =  thresh(inData, 1, 'max');                                          

    % 3. Bounds all data using a minimum input value and applying to
    % both sides ( X >= +1, X <= -1): 
    out3 =  thresh(inData, 1, 'abs'); 

    % 4. Bounds all data using a maximum input value and applying to
    % both sides ( X <= -1, X >= 1)
    out4 =  thresh(inData, 1, 'max', 'abs');

    % 5. Bounds all data to range [1,2]
     out5 =  thresh(inData, 1, 2); 

    % 6. Bounds all data to range [-2, -1], [1, 2] 
     out6 =  thresh(inData, 1, 2, 'abs'); 

     % Plot everything up;
      fig = figure; 
     hold on; grid on;
     surface(xx, yy,inData,...
         'DisplayName','Original Values');
     surface(xx, yy, out1,...
         'DisplayName','Minimum value of 1',...
         'FaceColor','b','EdgeColor','b','FaceAlpha',0.5);
     surface(xx, yy, out2,...
         'DisplayName','Maximum value of 1',...
         'FaceColor','c','EdgeColor','c','FaceAlpha',0.5);
     surface(xx, yy, out3,...
         'DisplayName','Threshold values of -1 and 1 using Absolute Value 1',...
         'FaceColor','m','EdgeColor','m','FaceAlpha',0.5);
     surface(xx, yy, out4,...
         'DisplayName','Bounds values between [-1,1] using Absolute Value 1',...
         'FaceColor','y','EdgeColor','y','FaceAlpha',0.5);
     surface(xx, yy, out5,...
         'DisplayName','Between range [1 2]',...
         'FaceColor','r','EdgeColor','r','FaceAlpha',0.5);
     surface(xx, yy, out6,...
         'DisplayName','In range [-2,1] and [ 1, 2]',...
         'FaceColor','g','EdgeColor','g','FaceAlpha',0.5);
     legend('location','bestoutside')
end

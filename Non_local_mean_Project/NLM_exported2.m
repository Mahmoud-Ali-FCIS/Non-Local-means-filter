classdef NLM_exported2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        NLMUIFigure                matlab.ui.Figure
        NonLocalMeansFilterPanel   matlab.ui.container.Panel
        NLMButton                  matlab.ui.control.Button
        UIAxes_2                   matlab.ui.control.UIAxes
        UIAxes2_2                  matlab.ui.control.UIAxes
        PathImageEditField_2Label  matlab.ui.control.Label
        PathImageEditField_2       matlab.ui.control.EditField
        NoiseListDropDownLabel     matlab.ui.control.Label
        NoiseListDropDown          matlab.ui.control.DropDown
    end

    methods (Access = private)

        function Filterd_image = NonLocalMeans_RGB(app, original_image, noiseType, noiseValue)
            
            noisyRGB = imnoise(original_image, noiseType, noiseValue);
            noisyLAB = rgb2lab(noisyRGB);
            [rows, columns, ~] = size(noisyRGB);
            roi = [1,1,rows/4,columns/4];
            patch = imcrop(noisyLAB,roi);
            patchSq = patch.^2;
            edist = sqrt(sum(patchSq,3));
            patchSigma = sqrt(var(edist(:)));
            DoS = 1.5*patchSigma;
            [Filterd,~] = imnlmfilt(noisyLAB,'DegreeOfSmoothing',DoS);
            Filterd_image = lab2rgb(Filterd,'Out','uint8');

        end 
        
        function Filterd_image = NonLocalMeans_Gray(app, original_image, noiseType, noiseValue)

            noisyImage = imnoise(original_image, noiseType, noiseValue);
            [Filterd_image,~] = imnlmfilt(noisyImage);
        end 
        
        function Filterd_image = main_NLM(app, Image)
            noise = app.NoiseListDropDown.Value;
            [~, ~, numberOfColorChannels] = size(Image);
            if(numberOfColorChannels == 1)
                Filterd_image = NonLocalMeans_Gray(app, Image, noise, 0);
            elseif(numberOfColorChannels == 3)
                Filterd_image = NonLocalMeans_RGB(app, Image, noise, 0);
            end
        end

        % Button pushed function: NLMButton
        function NLMButtonPushed(app, event)
            
            path = app.PathImageEditField_2.Value;
            noise = app.NoiseListDropDown.Value;
            original_image = imread(path);
            im = original_image;
            noisy_image = imnoise(im,noise);
            Filterd_image = main_NLM( app,original_image);
            imshow(noisy_image,'Parent',app.UIAxes_2);
            imshow( Filterd_image,'Parent',app.UIAxes2_2);
        end

        % Value changed function: PathImageEditField_2
        function PathImageEditField_2ValueChanged(app, event)
            value = app.PathImageEditField_2.Value;   
        end
        
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create NLMUIFigure
            app.NLMUIFigure = uifigure;
            app.NLMUIFigure.Position = [100 100 640 480];
            app.NLMUIFigure.Name = 'NLM';

            % Create NonLocalMeansFilterPanel
            app.NonLocalMeansFilterPanel = uipanel(app.NLMUIFigure);
            app.NonLocalMeansFilterPanel.TitlePosition = 'centertop';
            app.NonLocalMeansFilterPanel.Title = 'Non Local Means Filter';
            app.NonLocalMeansFilterPanel.BackgroundColor = [0.502 0.502 0.502];
            app.NonLocalMeansFilterPanel.FontWeight = 'bold';
            app.NonLocalMeansFilterPanel.FontSize = 20;
            app.NonLocalMeansFilterPanel.Position = [1 1 640 480];

            % Create NLMButton
            app.NLMButton = uibutton(app.NonLocalMeansFilterPanel, 'push');
            app.NLMButton.ButtonPushedFcn = createCallbackFcn(app, @NLMButtonPushed, true);
            app.NLMButton.Position = [278 26 100 22];
            app.NLMButton.Text = 'NLM';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.NonLocalMeansFilterPanel);
            title(app.UIAxes_2, 'Image With Noise')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            app.UIAxes_2.Position = [8 73 300 264];

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.NonLocalMeansFilterPanel);
            title(app.UIAxes2_2, 'Image after filter')
            xlabel(app.UIAxes2_2, 'X')
            ylabel(app.UIAxes2_2, 'Y')
            app.UIAxes2_2.Position = [326 73 300 264];

            % Create PathImageEditField_2Label
            app.PathImageEditField_2Label = uilabel(app.NonLocalMeansFilterPanel);
            app.PathImageEditField_2Label.HorizontalAlignment = 'right';
            app.PathImageEditField_2Label.FontWeight = 'bold';
            app.PathImageEditField_2Label.Position = [44 411 70 22];
            app.PathImageEditField_2Label.Text = 'Path Image';

            % Create PathImageEditField_2
            app.PathImageEditField_2 = uieditfield(app.NonLocalMeansFilterPanel, 'text');
            app.PathImageEditField_2.ValueChangedFcn = createCallbackFcn(app, @PathImageEditField_2ValueChanged, true);
            app.PathImageEditField_2.FontWeight = 'bold';
            app.PathImageEditField_2.Position = [129 411 307 22];

            % Create NoiseListDropDownLabel
            app.NoiseListDropDownLabel = uilabel(app.NonLocalMeansFilterPanel);
            app.NoiseListDropDownLabel.HorizontalAlignment = 'right';
            app.NoiseListDropDownLabel.Position = [432 412 69 22];
            app.NoiseListDropDownLabel.Text = 'Noise List ';

            % Create NoiseListDropDown
            app.NoiseListDropDown = uidropdown(app.NonLocalMeansFilterPanel);
            app.NoiseListDropDown.Items = {'gaussian', 'salt & pepper', 'speckle'};
            app.NoiseListDropDown.ItemsData = {'gaussian', 'salt & pepper', 'speckle'};
            app.NoiseListDropDown.Position = [509 412 100 22]; %[516 371 93 22];
            app.NoiseListDropDown.Value = 'gaussian';
        end
    end

    methods (Access = public)

        % Construct app
        function app = NLM_exported2

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.NLMUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.NLMUIFigure)
        end
    end
end
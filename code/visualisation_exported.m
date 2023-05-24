classdef visualisation_exported < matlab.ui.componentcontainer.ComponentContainer

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        SwitchingScenarioButton  matlab.ui.control.Button
        InstantPlotButton        matlab.ui.control.Button
        RunningTImesLabel        matlab.ui.control.Label
        RunningTimesGauge        matlab.ui.control.Gauge
        RunningTimesGaugeLabel   matlab.ui.control.Label
        ResetButton              matlab.ui.control.Button
        ModeLamp                 matlab.ui.control.Lamp
        NoLoadLampLabel          matlab.ui.control.Label
        DurationsSlider          matlab.ui.control.Slider
        DurationsSliderLabel     matlab.ui.control.Label
        CmFDropDown              matlab.ui.control.DropDown
        CmFDropDownLabel         matlab.ui.control.Label
        RsohmsDropDown           matlab.ui.control.DropDown
        RsohmsDropDownLabel      matlab.ui.control.Label
        StartButton              matlab.ui.control.Button
        SwitchBOnButton          matlab.ui.control.StateButton
        SwitchAOnButton          matlab.ui.control.StateButton
        DiodeCurrentPlot         matlab.ui.control.UIAxes
        ZenerCurrentPlot         matlab.ui.control.UIAxes
        PowerPlot                matlab.ui.control.UIAxes
        VoltagePlot              matlab.ui.control.UIAxes
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        modeUpdated
    end

    properties (AbortSet, Access = private, GetObservable, SetObservable)
        C = 2200e-6;
        Duration double = 1; % Duration of the simulation
        Rs = 300;
        StartDelay = 0;
        SwitchAOn = false;
        SwitchBOn = false;
        TimeStep = 2e-5;
    end
    
    properties (AbortSet, Access = public, GetObservable, SetObservable)
        Mode CircuitMode = "NoLoad";
    end
    
    properties (Access = private)
        ic
        l_Il
        l_Iz
        l_e2
        l_e3
        l_iC
        l_iD
        l_iS
        l_iZ
        l_pRs
        t
        v
    end
    
    properties (Access = public)
        Paused = false;
        Running = false;
        SwitchingOperation = false;
        k = 1; % Current Iteration
    end
    
    
    methods (Access = private)
        function restart(comp)
            resetSys(comp)
            start(comp)
        end

        function resetSys(comp)
            if comp.Running
                stop(comp)
            end
            comp.k = 1;
            comp.ic = [0, 0, 0];
            clearpoints(comp.l_e2);
            clearpoints(comp.l_e3);
            clearpoints(comp.l_Il);
            clearpoints(comp.l_Iz);
            clearpoints(comp.l_iD);
            clearpoints(comp.l_iS);
            clearpoints(comp.l_iC);
            clearpoints(comp.l_pRs);
        end

        function stop(comp)
            comp.Running = false;
            comp.Paused = false;
        end

        function pause(comp)
            comp.Paused = true;
        end

        function resume(comp)
            comp.Paused = false;
            disp(comp.k);
            updatePlot(comp)
        end

        function updatePlot(comp)
            for n=comp.k:length(comp.t)-1
                if ~comp.Running || comp.Paused
                    break
                end

                tn = comp.t(n);
                comp.RunningTimesGaugeLabel.Text = ['n: ', num2str(n)];
                comp.RunningTimesGauge.Value = tn;
                comp.k = n;

                % Calcualte t+h and t+h/2 for RK4
                tn_1 = tn + comp.TimeStep;
                tn_2 = tn + comp.TimeStep / 2;

                % Input voltage is a vector
                vin = comp.v([tn, tn_1, tn_2]);

                % Perform iteration
                y = powerSupply(comp.Mode,vin,comp.TimeStep,comp.ic,comp.C,comp.Rs);

                % Update initial conditions
                comp.ic(1) = y.e2;
                comp.ic(2) = y.e3;
                comp.ic(3) = y.iL;

                % Plot new values on graph
                % a. Voltage plot
                addpoints(comp.l_e2, tn, y.e2);
                addpoints(comp.l_e3, tn, y.e3);

                % b. Zener current plot
                addpoints(comp.l_Il, tn, y.iL);
                addpoints(comp.l_Iz, tn, y.Iz);

                % c. Diode plot
                addpoints(comp.l_iD, tn, y.Id);
                addpoints(comp.l_iS, tn, y.Is);
                addpoints(comp.l_iC, tn, y.Ic);

                % d. Power plot
                addpoints(comp.l_pRs, tn, comp.Rs*y.Is.^2)

                % Update plot
                drawnow limitrate
            end
            drawnow
        end

        function start(comp)
            comp.Running = true;
            comp.Paused = false;
            updatePlot(comp)
            stop(comp)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function postSetupFcn(comp)
            comp.Running = false;
            comp.Paused = false;
            comp.t = 0:comp.TimeStep:comp.Duration;
            comp.k = 1;

            % Input Voltage
            comp.v = @(t) 230 * sqrt(2) * sin(100*pi*t);  

            % Initital conditions
            comp.ic = [0,0,0];

            % Create animated lines for each plot
            % Voltage Plot lines
            comp.l_e2 = animatedline(comp.VoltagePlot,Color='b');
            comp.l_e3 = animatedline(comp.VoltagePlot,Color='r');
            comp.l_iZ = animatedline(comp.VoltagePlot,Color='m');

            % Current Plot II lines
            comp.l_iD = animatedline(comp.DiodeCurrentPlot,Color='b');
            comp.l_iC = animatedline(comp.DiodeCurrentPlot,Color='r');
            comp.l_iS = animatedline(comp.DiodeCurrentPlot,Color='m');

            % Power plot lines
            comp.l_pRs = animatedline(comp.PowerPlot,Color='b');

            % Current Plot I lines
            comp.l_Iz = animatedline(comp.ZenerCurrentPlot,Color='b');
            comp.l_Il = animatedline(comp.ZenerCurrentPlot,Color='r');

            % Update legends
            legend(comp.VoltagePlot, 'e_2', 'e_3');
            legend(comp.PowerPlot, 'P(R_s)');
            legend(comp.ZenerCurrentPlot, 'I_z', 'I_L');
            legend(comp.DiodeCurrentPlot, 'I_d', 'I_c', 'I_s');
        end

        % Button pushed function: StartButton
        function StartButtonPushed(comp, event)
           if comp.Running
               if comp.Paused
                   resume(comp)
               else
                   pause(comp)
               end
           else
               start(comp)
           end
        end

        % Value changed function: RsohmsDropDown
        function RsohmsDropDownValueChanged(comp, event)
            parsed = str2double(comp.RsohmsDropDown.Value);
            if comp.Rs == parsed
                return
            end
            if comp.Running
                stop(comp)
                resetSys('Rs was changed. Resetting Simulation')
            end
            comp.Rs = parsed;
        end

        % Value changed function: CmFDropDown
        function CmFDropDownValueChanged(comp, event)
           parsed = str2double(comp.CmFDropDown.Value)*10^-4;
           if comp.C == parsed
                return
            end
            if comp.Running
                stop(comp)
                resetSys('C was changed. Resetting Simulation')
            end
            comp.C = parsed;
        end

        % Value changed function: SwitchAOnButton
        function SwitchAOnButtonValueChanged(comp, event)
            comp.SwitchAOn = comp.SwitchAOnButton.Value;
        end

        % Value changed function: SwitchBOnButton
        function SwitchBOnButtonValueChanged(comp, event)
            comp.SwitchBOn = comp.SwitchBOnButton.Value;
        end

        % Value changed function: DurationsSlider
        function DurationsSliderValueChanged(comp, event)
            if comp.Duration == comp.DurationsSlider.Value || comp.SwitchingOperation
                return
            end
            if comp.Running
                resetSys(comp)
                msgbox('Duration was changed. Resetting Simulation')
            end
            comp.Duration = comp.DurationsSlider.Value;
            comp.t = 0:comp.TimeStep:comp.Duration;
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(comp, event)
            resetSys(comp)
            msgbox('The simulation was reset')
        end

        % Button pushed function: InstantPlotButton
        function InstantPlotButtonPushed(comp, event)
            resetSys(comp)

            % Output values
            e2 = zeros(1, length(comp.t));
            e3 = zeros(1, length(comp.t));
            Il = zeros(1, length(comp.t));
            Ic = zeros(1, length(comp.t));
            Iz = zeros(1, length(comp.t));
            Id = zeros(1, length(comp.t));
            Is = zeros(1, length(comp.t));

            for n=1:length(comp.t)-1
                % Determine tn
                tn = comp.t(n);

                % Calcualte t+h and t+h/2 for RK4
                tn_1 = tn + comp.TimeStep;
                tn_2 = tn + (comp.TimeStep / 2);

                % Input voltage is a vector
                vin = comp.v([tn, tn_1, tn_2]);

                % Perform iteration
                y = powerSupply(comp.Mode,vin,comp.TimeStep,comp.ic,comp.C,comp.Rs);

                % Reset initial conditions
                comp.ic(1) = y.e2;
                comp.ic(2) = y.e3;
                comp.ic(3) = y.iL;

                % Update output values
                e2(n) = y.e2;
                e3(n) = y.e3;
                Il(n) = y.iL;
                Iz(n) = y.Iz;
                Id(n) = y.Id;
                Ic(n) = y.Ic;
                Is(n) = y.Is;
            end

            % Update k
            comp.k = n;
            comp.RunningTimesGaugeLabel.Text = ['n: ', num2str(n)];
            comp.RunningTimesGauge.Value = comp.t(n);

            % Determine power dissipation
            p = comp.Rs * Is.^2;

            % a. Voltage plot
            addpoints(comp.l_e2, comp.t, e2);
            addpoints(comp.l_e3, comp.t, e3);

            % b. Zener current plot
            addpoints(comp.l_Il, comp.t, Il);
            addpoints(comp.l_Iz, comp.t, Iz);

            % c. Diode plot
            addpoints(comp.l_iD, comp.t, Id);
            addpoints(comp.l_iS, comp.t, Is);
            addpoints(comp.l_iC, comp.t, Ic);

            % d. Power plot
            addpoints(comp.l_pRs, comp.t, p)
            drawnow
        end

        % Button pushed function: SwitchingScenarioButton
        function SwitchingScenarioButtonPushed(comp, event)
            resetSys(comp)

            % Setup switching scenario
            comp.SwitchingOperation = true;
            
            % Power supply is switched off at t=0 neither attached loading
            % device is active, Ic, IL=0
            comp.ic = [0, 0, 0];
            comp.Mode = CircuitMode.NoLoad;

            % Use a larger time step to speed up
            comp.TimeStep = 8e-5;

            % Set time interval
            t1 = 2; % tn + t1=time when mode=ResistiveLoad
            t2 = 2.2; % tn + t2= time when mode=Full load
            t3 = 1.263; % time in full load
            tend = t1 + t2 + t3 + 1; % total time (add 1s for steady state at end)

            % Setup time vector
            comp.t = 0:comp.TimeStep:tend;

            % Update UI
            comp.Duration = tend;
            comp.Paused = false;
            comp.Running = true;

            % Time breaks
            resistiveLoadTime = t1;
            fullLoadTime = t1+t2;
            revertTime = fullLoadTime+t3;

            % Speed up by updating every N iterations.
            updateN = 1000;

            % Setup loop
            for n=comp.k:length(comp.t)-1
                if ~comp.Running || comp.Paused
                    break
                end

                tn = comp.t(n);

                % Update timer gage
                comp.RunningTimesGaugeLabel.Text = ['n: ', num2str(n)];
                comp.RunningTimesGauge.Value = tn;
                comp.k = n;

                % Determine mode based on current time interval tn
                if tn >= revertTime
                    comp.Mode = CircuitMode.ResistiveLoad;
                elseif tn >= fullLoadTime
                    comp.Mode = CircuitMode.FullLoad;
                elseif tn >= resistiveLoadTime
                    comp.Mode = CircuitMode.ResistiveLoad;
                else
                    comp.Mode = CircuitMode.NoLoad;
                end
                comp.NoLoadLampLabel.Text = char(comp.Mode);
               
                % Calcualte t+h and t+h/2 for RK4
                tn_1 = tn + comp.TimeStep;
                tn_2 = tn + comp.TimeStep / 2;

                % Input voltage is a vector
                vin = comp.v([tn, tn_1, tn_2]);

                % Perform iteration
                y = powerSupply(comp.Mode,vin,comp.TimeStep,comp.ic,comp.C,comp.Rs);

                % Update initial conditions
                comp.ic(1) = y.e2;
                comp.ic(2) = y.e3;
                comp.ic(3) = y.iL;

                % Speed up plot
                if n==1 || mod(n,updateN)==0

                % Plot new values on graph
                % a. Voltage plot
                addpoints(comp.l_e2, tn, y.e2);
                addpoints(comp.l_e3, tn, y.e3);

                % b. Zener current plot
                addpoints(comp.l_Il, tn, y.iL);
                addpoints(comp.l_Iz, tn, y.Iz);

                % c. Diode plot
                addpoints(comp.l_iD, tn, y.Id);
                addpoints(comp.l_iS, tn, y.Is);
                addpoints(comp.l_iC, tn, y.Ic);

                % d. Power plot
                addpoints(comp.l_pRs, tn, comp.Rs*y.Is.^2)
                drawnow
                end
            end

            % Reset
            comp.SwitchingOperation = false;
            stop(comp)
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
            if ~comp.SwitchingOperation
                if comp.SwitchAOn && comp.SwitchBOn
                    comp.Mode = CircuitMode.FullLoad;
                elseif comp.SwitchAOn && ~comp.SwitchBOn
                    comp.Mode = CircuitMode.ResistiveLoad;
                elseif comp.SwitchBOn && ~comp.SwitchAOn
                    comp.Mode = CircuitMode.InductiveLoad;
                else
                    comp.Mode = CircuitMode.NoLoad;
                end
            end

            comp.NoLoadLampLabel.Text = char(comp.Mode);
            comp.RunningTimesGauge.Limits = [0,comp.Duration];
            comp.RunningTimesGaugeLabel.Text = ['Time: ', num2str(comp.t(comp.k)), 's'];
            comp.RunningTimesGauge.Value = comp.t(comp.k);

            % Update xlim
            xlim(comp.VoltagePlot,[0,comp.Duration])
            xlim(comp.PowerPlot,[0,comp.Duration])
            xlim(comp.ZenerCurrentPlot,[0,comp.Duration])
            xlim(comp.DiodeCurrentPlot,[0,comp.Duration])

            if comp.Running
                if comp.Paused
                    comp.ModeLamp.Color = [0.502 0.502 0.502];
                    comp.StartButton.Text = 'Resume';
                    comp.StartButton.BackgroundColor = [0.9294 0.6941 0.1255];
                else
                    comp.ModeLamp.Color = 'g';
                    comp.StartButton.Text = 'Pause';
                    comp.StartButton.BackgroundColor = 'y';
                end
            else
                comp.StartButton.Text = 'Start';
                comp.StartButton.BackgroundColor = [0.4667 0.6745 0.1882];
                comp.ModeLamp.Color = [0.502 0.502 0.502];
            end
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 1382 857];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create VoltagePlot
            comp.VoltagePlot = uiaxes(comp);
            title(comp.VoltagePlot, 'Voltage e2, e3')
            xlabel(comp.VoltagePlot, 'Time (s)')
            ylabel(comp.VoltagePlot, 'Voltage (V)')
            zlabel(comp.VoltagePlot, 'Z')
            comp.VoltagePlot.XGrid = 'on';
            comp.VoltagePlot.YGrid = 'on';
            comp.VoltagePlot.Position = [25 401 530 325];

            % Create PowerPlot
            comp.PowerPlot = uiaxes(comp);
            title(comp.PowerPlot, 'Power Dissipation in Rs')
            xlabel(comp.PowerPlot, 'Time (s)')
            ylabel(comp.PowerPlot, 'Power (Watts)')
            subtitle(comp.PowerPlot, 'Maximum Permitted: 0.5W')
            comp.PowerPlot.XGrid = 'on';
            comp.PowerPlot.YGrid = 'on';
            comp.PowerPlot.Position = [607 31 527 351];

            % Create ZenerCurrentPlot
            comp.ZenerCurrentPlot = uiaxes(comp);
            title(comp.ZenerCurrentPlot, 'Zener Current, Inductor Current')
            xlabel(comp.ZenerCurrentPlot, 'Time (s)')
            ylabel(comp.ZenerCurrentPlot, 'Current (A)')
            zlabel(comp.ZenerCurrentPlot, 'Z')
            comp.ZenerCurrentPlot.XGrid = 'on';
            comp.ZenerCurrentPlot.YGrid = 'on';
            comp.ZenerCurrentPlot.Position = [607 401 527 325];

            % Create DiodeCurrentPlot
            comp.DiodeCurrentPlot = uiaxes(comp);
            title(comp.DiodeCurrentPlot, 'Diode Current, Capacitor Current')
            xlabel(comp.DiodeCurrentPlot, 'Time (s)')
            ylabel(comp.DiodeCurrentPlot, 'Current (A)')
            zlabel(comp.DiodeCurrentPlot, 'Z')
            subtitle(comp.DiodeCurrentPlot, 'Id, Ic, Is')
            comp.DiodeCurrentPlot.XGrid = 'on';
            comp.DiodeCurrentPlot.YGrid = 'on';
            comp.DiodeCurrentPlot.Position = [25 37 530 345];

            % Create SwitchAOnButton
            comp.SwitchAOnButton = uibutton(comp, 'state');
            comp.SwitchAOnButton.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @SwitchAOnButtonValueChanged, true);
            comp.SwitchAOnButton.Text = 'Switch A: On';
            comp.SwitchAOnButton.Position = [297 820 100 23];

            % Create SwitchBOnButton
            comp.SwitchBOnButton = uibutton(comp, 'state');
            comp.SwitchBOnButton.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @SwitchBOnButtonValueChanged, true);
            comp.SwitchBOnButton.Text = 'Switch B: On';
            comp.SwitchBOnButton.Position = [297 789 100 23];

            % Create StartButton
            comp.StartButton = uibutton(comp, 'push');
            comp.StartButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @StartButtonPushed, true);
            comp.StartButton.BackgroundColor = [0.4667 0.6745 0.1882];
            comp.StartButton.FontWeight = 'bold';
            comp.StartButton.Position = [135 789 148 53];
            comp.StartButton.Text = 'Start';

            % Create RsohmsDropDownLabel
            comp.RsohmsDropDownLabel = uilabel(comp);
            comp.RsohmsDropDownLabel.HorizontalAlignment = 'right';
            comp.RsohmsDropDownLabel.Position = [1013 815 55 22];
            comp.RsohmsDropDownLabel.Text = 'Rs(ohms)';

            % Create RsohmsDropDown
            comp.RsohmsDropDown = uidropdown(comp);
            comp.RsohmsDropDown.Items = {'300', '270', '330'};
            comp.RsohmsDropDown.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @RsohmsDropDownValueChanged, true);
            comp.RsohmsDropDown.Position = [1083 815 100 22];
            comp.RsohmsDropDown.Value = '300';

            % Create CmFDropDownLabel
            comp.CmFDropDownLabel = uilabel(comp);
            comp.CmFDropDownLabel.HorizontalAlignment = 'right';
            comp.CmFDropDownLabel.Position = [1032 788 37 22];
            comp.CmFDropDownLabel.Text = 'C(mF)';

            % Create CmFDropDown
            comp.CmFDropDown = uidropdown(comp);
            comp.CmFDropDown.Items = {'2.2', '2.64', '1.76'};
            comp.CmFDropDown.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @CmFDropDownValueChanged, true);
            comp.CmFDropDown.Position = [1084 788 100 22];
            comp.CmFDropDown.Value = '2.2';

            % Create DurationsSliderLabel
            comp.DurationsSliderLabel = uilabel(comp);
            comp.DurationsSliderLabel.HorizontalAlignment = 'right';
            comp.DurationsSliderLabel.Position = [417 816 66 22];
            comp.DurationsSliderLabel.Text = 'Duration (s)';

            % Create DurationsSlider
            comp.DurationsSlider = uislider(comp);
            comp.DurationsSlider.Limits = [0.05 3];
            comp.DurationsSlider.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @DurationsSliderValueChanged, true);
            comp.DurationsSlider.Position = [504 825 489 7];
            comp.DurationsSlider.Value = 1;

            % Create NoLoadLampLabel
            comp.NoLoadLampLabel = uilabel(comp);
            comp.NoLoadLampLabel.HorizontalAlignment = 'right';
            comp.NoLoadLampLabel.FontSize = 18;
            comp.NoLoadLampLabel.FontWeight = 'bold';
            comp.NoLoadLampLabel.Position = [920 746 190 24];
            comp.NoLoadLampLabel.Text = 'No Load';

            % Create ModeLamp
            comp.ModeLamp = uilamp(comp);
            comp.ModeLamp.Position = [1119 744 28 28];
            comp.ModeLamp.Color = [0.502 0.502 0.502];

            % Create ResetButton
            comp.ResetButton = uibutton(comp, 'push');
            comp.ResetButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @ResetButtonPushed, true);
            comp.ResetButton.BackgroundColor = [0.502 0.502 0.502];
            comp.ResetButton.FontWeight = 'bold';
            comp.ResetButton.FontColor = [0.149 0.149 0.149];
            comp.ResetButton.Position = [25 789 100 54];
            comp.ResetButton.Text = 'Reset';

            % Create RunningTimesGaugeLabel
            comp.RunningTimesGaugeLabel = uilabel(comp);
            comp.RunningTimesGaugeLabel.HorizontalAlignment = 'center';
            comp.RunningTimesGaugeLabel.Position = [1176 574 184 22];
            comp.RunningTimesGaugeLabel.Text = 'Running Time (s)';

            % Create RunningTimesGauge
            comp.RunningTimesGauge = uigauge(comp, 'circular');
            comp.RunningTimesGauge.Position = [1176 611 184 184];

            % Create RunningTImesLabel
            comp.RunningTImesLabel = uilabel(comp);
            comp.RunningTImesLabel.FontWeight = 'bold';
            comp.RunningTImesLabel.Position = [1220 810 101 22];
            comp.RunningTImesLabel.Text = 'Running TIme (s)';

            % Create InstantPlotButton
            comp.InstantPlotButton = uibutton(comp, 'push');
            comp.InstantPlotButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @InstantPlotButtonPushed, true);
            comp.InstantPlotButton.BackgroundColor = [0.302 0.7451 0.9333];
            comp.InstantPlotButton.FontWeight = 'bold';
            comp.InstantPlotButton.Position = [25 757 100 23];
            comp.InstantPlotButton.Text = 'Instant Plot';

            % Create SwitchingScenarioButton
            comp.SwitchingScenarioButton = uibutton(comp, 'push');
            comp.SwitchingScenarioButton.ButtonPushedFcn = matlab.apps.createCallbackFcn(comp, @SwitchingScenarioButtonPushed, true);
            comp.SwitchingScenarioButton.BackgroundColor = [0.302 0.7451 0.9333];
            comp.SwitchingScenarioButton.FontWeight = 'bold';
            comp.SwitchingScenarioButton.Position = [136 757 147 23];
            comp.SwitchingScenarioButton.Text = 'Switching Scenario';
            
            % Execute the startup function
            postSetupFcn(comp)
        end
    end
end
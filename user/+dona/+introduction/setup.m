classdef setup < simulation.infrastructure
    properties

    end

    methods
        function this = setup(ptConfigParams, tSolverParams) 
	        ttMonitorConfig = struct();
	        this@simulation.infrastructure('Introduction_System', ptConfigParams, tSolverParams, ttMonitorConfig);


	        dona.introduction.systems.Example(this.oSimulationContainer,'Example');


	        %% Simulation length
	        this.fSimTime = 3600; % In seconds
	        this.bUseTime = true;
        end

        function configureMonitors(this)
	        %% Logging
            oLogger = this.toMonitors.oLogger;

	        oLogger.addValue('Example.toStores.Cabin.toPhases.CabinAir', 'fPressure', 'Pa', 'Total Cabin Pressure');
            oLogger.addValue('Example.toStores.Cabin.toPhases.CabinAir', 'fTemperature', 'K', 'Cabin Temperature');
            oLogger.addValue('Example.toStores.Cabin.toPhases.CabinAir', 'this.afPP(this.oMT.tiN2I.CO2)', 'Pa', 'Partial Pressure CO2 Cabin');
            oLogger.addValue('Example.toStores.Cabin.toPhases.CabinAir', 'rRelHumidity', '-', 'Relative Humidity Cabin');

            oLogger.addValue('Example.toStores.Condensate_Storage.toPhases.Condensate', 'fMass', 'kg', 'Condensate Mass');
            oLogger.addValue('Example.toStores.CO2_Removal.toPhases.LiOH', 'this.afMass(this.oMT.tiN2I.CO2)', 'kg', 'Absorbed CO2 Mass');

            oLogger.addValue('Example.toBranches.Cabin_to_CO2_Removal', 'fFlowRate', 'kg/s', 'CO2 Removal Inlet Flow Rate');
            oLogger.addValue('Example.toBranches.CO2_Removal_to_Cabin', 'fFlowRate', 'kg/s', 'CO2 Removal Outlet Flow Rate');
            oLogger.addValue('Example.toBranches.Water_to_O2_Generation', 'fFlowRate', 'kg/s', 'Water to O2 Generation Flow Rate');
        end

        function plot(this)
            % Plotting the results
            % See http://www.mathworks.de/de/help/matlab/ref/plot.html for
            % further information
            close all % closes all currently open figures
            
            % Tries to load stored data from the hard drive if that option
            % was activated (see ttMonitorConfig). Otherwise it only 
            % displays that no data was found 
            try
                this.toMonitors.oLogger.readDataFromMat;
            catch
                disp('no data outputted yet')
            end


            %% Define plots
            % Defines the plotter object
            oPlotter = plot@simulation.infrastructure(this);

            coPlot = {};
            % Define the first row of plots
            coPlot{1,1} = oPlotter.definePlot({'"Total Cabin Pressure"'}, 		'Total Cabin Pressure');
            coPlot{1,2} = oPlotter.definePlot({'"Cabin Temperature"'}, 			'Cabin Temperature');
            % define the second row of plots
            coPlot{2,1} = oPlotter.definePlot({'"Partial Pressure CO2 Cabin"'}, 'Partial Pressure CO2 Cabin');
            coPlot{2,2} = oPlotter.definePlot({'"Relative Humidity Cabin"'}, 	'Relative Humidity Cabin');
            % Define the figure
            oPlotter.defineFigure(coPlot, 'Cabin Atmosphere Values');

            coPlot2 = {};
            coPlot2{1,1} = oPlotter.definePlot({'"Condensate Mass"'}, 		'Condensate Mass');
            coPlot2{2,1} = oPlotter.definePlot({'"CO2 Removal Inlet Flow Rate"', '"CO2 Removal Outlet Flow Rate"'}, 			'CO2 Removal Mass Flow Rate');
            coPlot2{1,2} = oPlotter.definePlot({'"Absorbed CO2 Mass"'}, 			'Absorbed CO2 Mass');
            coPlot2{2,2} = oPlotter.definePlot({'"Water to O2 Generation Flow Rate"'}, 	'Water to O2 Generation Flow Rate');
            oPlotter.defineFigure(coPlot2, 'CO2_Removal Values');
            
            oPlotter.plot();
        end
    end
end
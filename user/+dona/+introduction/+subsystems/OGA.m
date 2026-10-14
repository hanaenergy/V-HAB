classdef OGA < vsys

    methods
        function this = OGA(oParent, sName)
            this@vsys(oParent, sName);
        end

        function createMatterStructure(this)
            createMatterStructure@vsys(this);

            matter.store(this, 'O2_Generation', 0.52);

            matter.phases.liquid(this.toStores.O2_Generation, 'Water', struct('H2O', 10), 293, 1e5);
            matter.phases.gas(this.toStores.O2_Generation, 'Hydrogen', struct('H2', 0.3), 0.25, 293);
            matter.phases.gas(this.toStores.O2_Generation, 'Oxygen', struct('O2', 0.1), 0.25, 293);

            dona.introduction.components.O2_Generation_Manip('O2_Generation_Manip', this.toStores.O2_Generation.toPhases.Water);
            dona.introduction.components.General_P2P(this.toStores.O2_Generation, 'O2_P2P', this.toStores.O2_Generation.toPhases.Water, this.toStores.O2_Generation.toPhases.Oxygen, 'O2');
            dona.introduction.components.General_P2P(this.toStores.O2_Generation, 'H2_P2P', this.toStores.O2_Generation.toPhases.Water, this.toStores.O2_Generation.toPhases.Hydrogen, 'H2');

            matter.branch(this, this.toStores.O2_Generation.toPhases.Oxygen, 	{}, 	'O2_Outlet', 	'O2_Generation_to_Cabin');
            matter.branch(this, this.toStores.O2_Generation.toPhases.Hydrogen, 	{}, 	'H2_Outlet', 	'Hydrogen_to_Vacuum');
            matter.branch(this, this.toStores.O2_Generation.toPhases.Water,  	{}, 	'Water_Inlet',	'Water_to_O2_Generation');
        end

        function createSolverStructure(this)
            createSolverStructure@vsys(this);

            solver.matter.manual.branch(this.toBranches.Water_to_O2_Generation);
            solver.matter.residual.branch(this.toBranches.O2_Generation_to_Cabin);
            solver.matter.residual.branch(this.toBranches.Hydrogen_to_Vacuum);

            this.setThermalSolvers();
        end
    end

    methods (Access = public)
        function setIfFlows(this, sWater_Inlet, sH2_Outlet, sO2_Outlet)
            % This function connects the system and subsystem level branches with
            % each other. It uses the connectIF function provided by the
            % matter.container class
            this.connectIF('Water_Inlet',  sWater_Inlet);
            this.connectIF('H2_Outlet', sH2_Outlet);
            this.connectIF('O2_Outlet', sO2_Outlet);
        end
    end

    methods (Access = protected)
        function exec(this, ~) 
            exec@vsys(this);

            if this.oTimer.iTick ~=0
	            fPPO2 = this.toBranches.O2_Generation_to_Cabin.coExmes{2}.oPhase.afPP(this.oMT.tiN2I.O2);
                if fPPO2 < 19500
                    this.toBranches.Water_to_O2_Generation.oHandler.setFlowRate(-1e-4);
                elseif fPPO2 <= 22000
                    this.toBranches.Water_to_O2_Generation.oHandler.setFlowRate(-3.4e-5);
                else
                    this.toBranches.Water_to_O2_Generation.oHandler.setFlowRate(0);
                end
            end


        end
    end
end 

classdef Example < vsys
    properties (SetAccess = protected, GetAccess = public)
       
    end
   
    methods
        function this = Example(oParent, sName)
            this@vsys(oParent, sName, 30);
            eval(this.oRoot.oCfgParams.configCode(this));

            dona.introduction.subsystems.OGA(this, 'OGA');
           
        end
       
        function createMatterStructure(this)
	        createMatterStructure@vsys(this);

	        matter.store(this, 'Cabin', 55);
            matter.store(this, 'HX_Coolant', 0.02);
            
            matter.store(this, 'CO2_Removal', 1.01);
            matter.store(this, 'Water_Supply', 1.1);
            matter.store(this, 'Condensate_Storage', 1);
            matter.store(this, 'Waste_Storage', 10);
            matter.store(this, 'Vacuum', 1e6);


            matter.phases.solid(this.toStores.Waste_Storage, 'Solid_Waste', struct('C42H69O13N5',0.1), 293);
            components.matter.FoodStore(this, 'Food',  100, struct('Food', 100));


            matter.phases.liquid(this.toStores.Condensate_Storage, 'Condensate', struct('H2O', 1), 293, 1e5);
            matter.phases.liquid(this.toStores.HX_Coolant, 'Coolant', struct('H2O', 10), 293, 1e5);
            
            

            matter.phases.liquid(this.toStores.Water_Supply, 'Water', struct('H2O', 1000), 293, 1e5);
            matter.phases.liquid(this.toStores.Waste_Storage, 'Liquid_Waste', struct('H2O', 0.1), 293, 1e5);


            

            this.toStores.Cabin.createPhase('gas', 'CabinAir', 54.99, struct('N2', 8e4, 'O2', 2e4, 'CO2', 500), 293, 0.5);

            this.toStores.CO2_Removal.createPhase('gas', 'flow', 'Air', 0.01, struct('N2', 8e4, 'O2', 2e4, 'CO2', 500), 293, 0.5);

            this.toStores.Vacuum.createPhase('gas', 'boundary', 'Vacuum', 1e6, struct('N2', 2), 3, 0);


            matter.phases.mixture(this.toStores.CO2_Removal, 'LiOH', 'solid', struct('Li', 50), 293, 1e5);



            matter.procs.exmes.gas(this.toStores.Cabin.toPhases.CabinAir, 'Cabin_to_HX');
            matter.procs.exmes.gas(this.toStores.Cabin.toPhases.CabinAir, 'Cabin_from_HX');
            matter.procs.exmes.gas(this.toStores.Cabin.toPhases.CabinAir, 'Cabin_to_CO2_Removal');

            
            matter.branch(this, this.toStores.HX_Coolant.toPhases.Coolant, {}, this.toStores.HX_Coolant.toPhases.Coolant, 'HX_Coolant_Loop');
            matter.branch(this, 'Cabin.Cabin_to_CO2_Removal', {}, this.toStores.CO2_Removal.toPhases.Air, 'Cabin_to_CO2_Removal');
            matter.branch(this, this.toStores.CO2_Removal.toPhases.Air, {}, this.toStores.Cabin.toPhases.CabinAir, 'CO2_Removal_to_Cabin');
            

            dona.introduction.components.LiOH_Absorber(this.toStores.CO2_Removal, 'LiOH_P2P', this.toStores.CO2_Removal.toPhases.Air, this.toStores.CO2_Removal.toPhases.LiOH);
            

            dona.introduction.components.fan(this, 'HX_Fan', -1e5);
            fLength     = 1;    % Pipe length in m
            fDiameter   = 0.01; % Pipe Diameter in m
            fRoughness  = 1e-5; % Pipe surface roughness in m. If roughness is not provided, a smooth pipe is assumed
            components.matter.pipe(this, 'Pipe_1', fLength, fDiameter, fRoughness);
            components.matter.pipe(this, 'Pipe_2', fLength, fDiameter, fRoughness);
            matter.branch(this, 'Cabin.Cabin_to_HX', {'Pipe_1','HX_Fan','Pipe_2'}, 'Cabin.Cabin_from_HX', 'Cabin_HX_Loop');

            matter.branch(this, 'O2_from_OGA', {}, this.toStores.Cabin.toPhases.CabinAir);
            matter.branch(this, 'H2_from_OGA', {}, this.toStores.Vacuum.toPhases.Vacuum);
            matter.branch(this, 'H2O_to_OGA',  {}, this.toStores.Water_Supply.toPhases.Water);

            this.toChildren.OGA.setIfFlows('H2O_to_OGA', 'H2_from_OGA', 'O2_from_OGA');


        end
       
        function createSolverStructure(this)
            createSolverStructure@vsys(this);
           
            solver.matter.interval.branch(this.toBranches.Cabin_HX_Loop);

            solver.matter.manual.branch(this.toBranches.HX_Coolant_Loop);
            this.toBranches.HX_Coolant_Loop.oHandler.setFlowRate(10);
            
            solver.matter.manual.branch(this.toBranches.Cabin_to_CO2_Removal);
            this.toBranches.Cabin_to_CO2_Removal.oHandler.setVolumetricFlowRate(0.01);

            
            
            

            solver.matter_multibranch.iterative.branch(this.toBranches.CO2_Removal_to_Cabin, 'complex');

            this.setThermalSolvers();

        end
    end
   
     methods (Access = protected)
        function exec(this, ~)
            exec@vsys(this);
            
            
            
        end
     end
end
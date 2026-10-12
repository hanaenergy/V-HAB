classdef O2_Generation_Manip < matter.manips.substance.stationary 
    methods
        function this = O2_Generation_Manip(sName, oPhase)
			this@matter.manips.substance.stationary(sName, oPhase); 

        end
	end
	
    methods (Access = protected)
        function update(this)
            [ afFlowRate, mrPartials ] = this.getInFlows();
            if isempty(afFlowRate)
                afFlowRateIn = zeros(1, this.oPhase.oMT.iSubstances);
            else
                afFlowRateIn = sum(afFlowRate .* mrPartials(1, :),1);
            end

            fH2Production = (this.oMT.afMolarMass(this.oMT.tiN2I.H2)/this.oMT.afMolarMass(this.oMT.tiN2I.H2O)) 		* afFlowRateIn(this.oMT.tiN2I.H2O);
            fO2Production = (1-(this.oMT.afMolarMass(this.oMT.tiN2I.H2)/this.oMT.afMolarMass(this.oMT.tiN2I.H2O))) 	* afFlowRateIn(this.oMT.tiN2I.H2O);

            afPartialFlowRates = zeros(1, this.oPhase.oMT.iSubstances);
            afPartialFlowRates(this.oMT.tiN2I.H2O) = - (fO2Production + fH2Production);
            afPartialFlowRates(this.oMT.tiN2I.O2) = fO2Production;
            afPartialFlowRates(this.oMT.tiN2I.H2) = fH2Production;

            update@matter.manips.substance.stationary(this, afPartialFlowRates);
        end
    end
end
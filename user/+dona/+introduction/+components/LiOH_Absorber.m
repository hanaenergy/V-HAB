classdef LiOH_Absorber < matter.procs.p2ps.flow
    properties (SetAccess = protected, GetAccess = public)
        arExtractPartials;
    end
    methods
        function this = LiOH_Absorber(oStore, sName, sPhaseIn, sPhaseOut)
            this@matter.procs.p2ps.flow(oStore, sName, sPhaseIn, sPhaseOut);

            this.arExtractPartials = zeros(1, this.oMT.iSubstances);
            this.arExtractPartials(this.oMT.tiN2I.CO2) = 1;

        end
		
		function calculateFlowRate(this, afInFlowRates, aarInPartials, afOutFlowRates, aarOutPartials)
			% afInFlowRates: the in going flow rates in kg/s for this.oIn.oPhase
			% aarInPartials: the in going partial mass ratios for this.oIn.oPhase
			% afOutFlowRates: the in going flow rates in kg/s for this.oOut.oPhase
			% aarOutPartials: the in going partial mass ratios for this.oOut.oPhase
			%
			% You can calculate the total partial in flow rates for this.oIn.oPhase or
			% this.oOut.oPhase by using:
			% afPartialInFlowsForInside = sum((afInFlowRates .* aarInPartials),1);
			% afPartialInFlowsForOutside = sum((afOutFlowRates.* aarOutPartials),1);
			%
			% Note: These P2Ps only work if one of the branches for the flow phase is 
			% an iterative multibranch solver!


            afPartialInFlowsForInside = sum((afInFlowRates .* aarInPartials), 1);
            fFlowRate = afPartialInFlowsForInside(this.oMT.tiN2I.CO2) * 0.9;
            this.setMatterProperties(fFlowRate, this.arExtractPartials);


		end
	end
	methods (Access = protected)
        function update(~)

        end
    end
end
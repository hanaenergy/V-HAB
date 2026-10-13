classdef General_P2P < matter.procs.p2ps.stationary & event.source
    properties (SetAccess = public, GetAccess = public)
        arExtractPartials;
        sSubstance;
        fSubstanceFlowRate = 0;
    end
    methods
        function this = General_P2P(oStore, sName, sPhaseIn, sPhaseOut, sSubstance)
            this@matter.procs.p2ps.stationary(oStore, sName, sPhaseIn, sPhaseOut);

            this.arExtractPartials = zeros(1, this.oMT.iSubstances);
            this.arExtractPartials(this.oMT.tiN2I.(sSubstance)) = 1;
            this.sSubstance = sSubstance;

            oStore.toPhases.Water.toManips.substance.bind('OGA_ManipulatorUpdate', @this.calculateFlowRate);

        end
	end
	methods (Access = protected)
        function update(this)
            this.setMatterProperties(this.fSubstanceFlowRate , this.arExtractPartials);
        end

        function calculateFlowRate(this,~)
            this.fSubstanceFlowRate = this.oStore.toPhases.Water.toManips.substance.afPartialFlows(this.oMT.tiN2I.(this.sSubstance));

            % Connected phases have to do a massupdate before we set the
            % new flow rate - so the mass for the LAST time step, with the
            % old flow rate, is actually moved from tank to tank. In the
            % massupdate the update for the P2P will be triggered, which is
            % then executed in the post tick after the phase massupdates
            this.oIn.oPhase.registerMassupdate();
            this.oOut.oPhase.registerMassupdate();
        end
    end
end
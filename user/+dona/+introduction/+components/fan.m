classdef fan < matter.procs.f2f
	properties (SetAccess = protected, GetAccess = public)
        
    end
    methods
        function this = fan(oContainer, sName, fDeltaPressure)
			this@matter.procs.f2f(oContainer, sName);   
            
            this.fDeltaPressure = fDeltaPressure;

			this.supportSolver('callback',  @this.solverDeltas); 
			
			this.bActive = true;
        end

        function fDeltaPress = solverDeltas(this, ~)
            if this.oTimer.fTime < 1000
                fDeltaPress = (this.oTimer.fTime/1000)*this.fDeltaPressure;
            else
                fDeltaPress = this.fDeltaPressure;
            end



        end
    end
end
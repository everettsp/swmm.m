classdef net_ensbl
    properties
        nets = {};
        trns = {};
        
        m {mustBeNumeric}
        combine {islogical} = true;
        combine_method = "weighted_mean";
        mw = 1;
        randomwb {islogical} = true;
        div
        
        resample_method = "default";
        resample_fun = @(net,x,t) resample_default(net,x,t);
        resample_info = struct();
        
        train_method = "default";
        train_fun = @(net,x,t,m) train_default(net,x,t,m);
        train_info = struct();
    end
    
    properties (Dependent=true)
    end
    
    methods
        function obj = net_ensbl
%             obj.m = m;
        end
        
        function obj = init(obj,net_in, m)
            obj.m = m;
            obj.nets = cell(obj.m,1);
            obj.trns = cell(obj.m,1);
            
            for i2 = 1:obj.m
                net = net_in;
                if obj.randomwb && (i2 > 1) % reinitialize weights and biases (don't randomize first ensemble member)
                    obj.nets{i2} = init(net);
                else
                    obj.nets{i2} = net;
                end
            end
            
            % initial divs, ensemble member divs may vary within these
            obj.div = struct();
            switch net.DivideFcn
                case 'divideind'
                    kwd = 'Ind';
                case 'dividerand'
                    kwd = 'Ratio';
                otherwise
                    error('div fcn not recognized')
            end
            for i2 = {'train','val','test'}
                obj.div.(char(i2)) = net.DivideParam.([char(i2),kwd]);
            end
            obj.div.cal = [obj.div.train; obj.div.val];
            
        end
        
        
%         function obj = train(obj, x, t)
%             for i2 = 1:obj.m
%                 [obj.nets{i2}, obj.trns{i2}] = train(obj.nets{i2},x,t);
%             end
%         end
        obj = train(obj, x, t, m);
        
        obj = train_bag(obj, x, t, resample_fun);
        obj = train_boost(obj, x, t, boost_fun);
        obj = train_redistribute(obj, x, t, w, method);
        obj = train_adaboost(obj, x, t, phi_fixed, error_exponent, resample_or_reweight);
        obj = train_gradboost(obj, x, t, boost_step, varargin);
        
        
        function y = eval(obj, x)
            [~,num_smpl] = size(x);
            y = NaN(obj.m,num_smpl);
            
            for i2 = 1:obj.m
                net = obj.nets{i2};
                y(i2,:) = net(x);
            end
            
            % combine the predictions of the ensemble members
            if obj.combine
                if obj.mw == 1
                    obj.mw = ones(obj.m,1);
                end
                assert(numel(obj.mw) == obj.m,'ensemble member weights must equal number of ensemble members')
                
                if all(size(obj.mw) == [1,obj.m])
                    obj.mw = obj.mw';
                end
                
                switch obj.combine_method
                    case {'mean','average','weighted mean','weighted_mean','wm'}
                        norm_weights = obj.mw./sum(obj.mw); %normalize combination weights
                        y = norm_weights' * y;
                    case {'sum','weighted sum','weighted_sum'}
                        y = obj.mw' * y;
                end
            end
            
        end
    end
    
    methods (Access=private)
    end
    
end


classdef swmm_item
    properties
        class
        id
        name
        attribute
        init_val
        num_sigfigs
        new_val
        uncertainty_type
        uncertainty_val
        constraints
        range
        pop_distr
        pop_size
        pop
    end
    
    methods
        function obj = swmm_item(class, id, name, attribute, init_val)
            
            obj.class = class;
            obj.id = id;
            obj.name = name;
            obj.attribute = attribute;
            obj.init_val = init_val;
            obj.num_sigfigs = 4;
        end
        
        function obj = assign_uncertainty(obj,uncertainty_type, uncertainty_val, constraints, pop_distr, pop_size)
            obj.uncertainty_type = uncertainty_type;
            obj.uncertainty_val = uncertainty_val;
            obj.constraints = constraints;
            obj.pop_distr = pop_distr;
            obj.pop_size = pop_size;
            obj = get_priors(obj);
        end
        
        
        %         function obj = get_init(obj)
        %             swmm_data = swmm_read_classes(obj.ffile, obj.type);
        %             obj.init_val = table2array(swmm_data(obj.id,obj.field));
        %         end
    end
    
    methods (Access=private)
        
        
        function obj = sigfigs(obj)
            obj.new_val = round(obj.new_val,obj.num_sigfigs,'significant');
        end
        
        function obj = get_priors(obj)
            
            obj.range = NaN(2,1);
            if numel(obj.uncertainty_val) == 1
                uncertainty_lower = obj.uncertainty_val;
                uncertainty_upper = obj.uncertainty_val;
            elseif numel(obj.uncertainty_val) == 2
                uncertainty_lower = obj.uncertainty_val(1);
                uncertainty_upper = obj.uncertainty_val(2);
            else
                error('relative uncertainty should have one (unidirectional) or two (upper and lower) values')
            end
            
            switch obj.uncertainty_type
                case {'percent','percentage','pc','%'}
                    obj.range(1) = obj.init_val * (100 - uncertainty_lower);
                    obj.range(2) = obj.init_val * (100 + uncertainty_upper);
                    
                case {'fraction','frac','decimal','floating','float','f'}
                    obj.range(1) = obj.init_val * (1 - uncertainty_lower);
                    obj.range(2) = obj.init_val * (1 + uncertainty_upper);
                    
                case {'absolute','abs'}
                    obj.range(1) = obj.init_val - uncertainty_lower;
                    obj.range(2) = obj.init_val + uncertainty_upper;
                    
                otherwise
                    error('uncertainty type not recognized among cases')
            end
            
            % constrain range to values that can exist physically, work in SWMM
            if obj.constraints(1) > obj.init_val || obj.constraints(2) < obj.init_val
                error('initial value not within constraints')
            end
            
            if obj.range(1) < obj.constraints(1)
                obj.range(1) = obj.constraints(1);
            end
            
            if obj.range(2) > obj.constraints(2)
                obj.range(2) = obj.constraints(2);
            end
            
            switch lower(obj.pop_distr)
                case {'uniform','uni','unif'}
                    obj.pop = obj.range(1) + (obj.range(2) - obj.range(1)) .* rand(obj.pop_size,1);
                case {'sensitivity','sens','incr,','incremental'}
                    obj.pop = linspace(obj.range(1),obj.range(2),obj.pop_size);
                otherwise
                    error("prior type not regognized, try 'unniform'")
            end
            
        end
        
    end
    
end
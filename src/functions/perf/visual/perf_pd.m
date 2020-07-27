function [pte,pae] = perf_pd(obs,mdl,obs_events,mdl_events,varargin)

par = inputParser;
addParameter(par,'plt',false)
parse(par,varargin{:})
plt = par.Results.plt;

%calculate peak error
pte = obs_events(:,2) - mdl_events(:,2);
pae = obs(obs_events(:,2)) - mdl(mdl_events(:,2));

%plot
if plt
    
    cols = get_colmat('lassonde');
    lw = 2;
    ms = 2;
    num_events = size(obs_events,1);
    for ii = 1:num_events
        subplot(num_events,1,ii)
        
        
        plot(obs_events(ii,1):obs_events(ii,3),obs(obs_events(ii,1):obs_events(ii,3)),'o-','DisplayName','Observed',...
            'LineWidth',lw,'MarkerSize',ms,'Color',cols(4,:))
        
        hold on
        plot(mdl_events(ii,1):mdl_events(ii,3),mdl(mdl_events(ii,1):mdl_events(ii,3)),'o-','DisplayName','Modelled',...
            'LineWidth',lw,'MarkerSize',ms,'Color',cols(3,:))

        plot([obs_events(ii,2);mdl_events(ii,2)],[obs(obs_events(ii,2));mdl(mdl_events(ii,2))],'-','DisplayName','Error',...
            'LineWidth',lw/2,'MarkerSize',ms,'Color',[0 0 0]) 
        
        hid = get_hydrodict;
        ii2 = find(contains(lower({hid.descr}),'peak'));
        ii2 = ii2(1);
        
        plot([obs_events(ii,2) mdl_events(ii,2)],[obs(obs_events(ii,2)) mdl(mdl_events(ii,2))],hid(ii2,1).mark,'DisplayName','Peak',...
            'LineWidth',hid(ii2,1).lw,'MarkerSize',hid(ii2,1).size,'MarkerFaceColor',hid(ii2,1).col,'Color',hid(ii2,1).col);

    end
end
function mdl2 = delete_catchment(mdl,out_node)
global del_list
del_list = {};

traverse(mdl,out_node);

idx = ismember(mdl.p.subcatchments.Outlet,del_list);
del_list(end + (1:sum(idx))) = mdl.p.subcatchments.Name(idx);

mdl2 = mdl;
parameter = {...
    'conduits','outlets','weirs','orifices',...
    'outfalls','junctions','storage',...
    'subareas','infiltration','symbols','subcatchments',...
    'coordinates','vertices','polygons',...
    'raingages','curves','xsections','losses'};

% for each parameter, search for IDs in 'del_list' and remove rows from
% tables...
% --CAUTION-- this will need to be updated/fixed pending improvements to
% read_inp, as not all models will have 'weirs' for example.

for i2 = 1:numel(parameter)
    idx = ismember(mdl2.p.(parameter{i2})(:,1).Variables,del_list);
    mdl2.p.(parameter{i2}) = mdl2.p.(parameter{i2})(~idx,:);
end
end

function traverse(mdl,node_down)
global del_list

links = [mdl.p.conduits(:,{'Name','ToNode','FromNode'});...
    mdl.p.outlets(:,{'Name','ToNode','FromNode'});...
    mdl.p.weirs(:,{'Name','ToNode','FromNode'});...
    mdl.p.orifices(:,{'Name','ToNode','FromNode'})];

% nodes = [mdl2.p.outfalls(:,{'Name'});mdl2.p.junctions(:,{'Name'});mdl2.p.storage(:,{'Name'})];

link_id = find(strcmp(node_down,links.ToNode));
node_up = links.FromNode(link_id);
node_up = unique(node_up);

if any(ismember(mdl.p.outfalls.Name,node_down)) % if ds node is outfall, store it
    del_list{end+1} = node_down;
end
del_list(end+(1:numel(link_id))) = links.Name(link_id);
del_list(end+(1:numel(node_up))) = node_up;

for i2 = 1:numel(node_up)
    traverse(mdl,node_up(i2));
end
end

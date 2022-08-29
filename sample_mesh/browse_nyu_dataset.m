% browse with +/- keys
function browse_nyu_dataset(dset, start_ind)

    if nargin < 1 || isempty(dset)
        dset = load('../data/shape_sources/nyu_depth_v2_labeled.mat');    
    end
    if nargin < 2 || isempty(start_ind)
        start_ind = 1;
    end
        
    ind = start_ind;
    
    fig = figure;
    hold on;
    rgb = image(dset.images(:,:,:,ind),'XData',-size(dset.images,2),'YData',0);
    d = image(dset.depths(:,:,ind));
    set(d,'CDataMapping','scaled');
    set(gca,'YDir','reverse');
    axis equal;
    set(gca,'XLim',[-size(dset.images,2),size(dset.images,2)]);
    set(gca,'YLim',[0,size(dset.images,1)]);
    set(gca,'Position',[0,0,1,1]);
    set(gcf,'Position',[50,50,640*2,480]);
    fig.KeyPressFcn = @(src, evt) next_temp(evt);
    colormap(jet(1024));
    hold off;
    set(gca,'Visible','off');
    
    function next_temp(evt)
        if strcmp(evt.Key,'subtract')
            ind = mod(ind-2,size(dset.depths,3))+1;
        else
            ind = mod(ind,size(dset.depths,3))+1;
        end
        rgb.CData = dset.images(:,:,:,ind);
        d.CData = dset.depths(:,:,ind);
        disp(ind);
    end

end
% Create a model.
model = createpde(1);
% Create geometry and assign it to the model
len = 1;


gdm = [3 4 0 len len 0 0 0 len len]';
g = decsg(gdm,'S1',('S1')');


geometryFromEdges(model,g);
figure
pdegplot(model,'EdgeLabels','on','FaceLabels','on')

% Specify coefficients, diffusion coefficient as c and source as f
% Assign zero source and a diffusion coefficient, c = 1
specifyCoefficients(model, 'm',0,'d',1,'c',1,'a',0,'f',0);
%
setInitialConditions(model,1);

generateMesh(model)

tlist = linspace(0,0.1,20);
result = solvepde(model,tlist);

% Plot results of last time-step.
figure
pdeplot(model,'XYData',result.NodalSolution(:,end))
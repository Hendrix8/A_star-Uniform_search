clc; % clears everything in the command window 
clear; % clears all the text from the Command Window
close all; % closes all figures whose handles are visible
format compact;

dbstop if error; % pauses execution at the line that meets the specified condition , such as error or naninf 
dbstop if warning; % stops execution when any M-file you subsequently run produces a run-time warning, putting MATLAB in debug mode, paused at the line that generated the warning


% --- Set of nodes
NodesList={'S';'A';'B';'C';'D';'E';'F';'G1';'G2';'G3'};
% --- Heuristic function values
hList=[5;7;3;4;6;5;6;0;0;0];

% --- Link weights between nodes
LinksList={
    'S','A',5
    'S','B',9
    'S','D',6
    'A','B',3
    'A','G1',9
    'B','A',2
    'B','C',1
    'C','S',6
    'C','F',7
    'C','G2',5
    'D','S',1
    'D','C',2
    'D','E',2
    'E','G3',7
    'F','D',2
    'F','G3',8
    };

% --- Starting node
Start={'S'};
% --- Goal node(s) = where h equals zero
Goal=NodesList(hList==0);

% --- Initialise open and closed lists
OpenList={};
ClosedList={};

% --- Prepare array T
n=length(NodesList);
gList=zeros(n,1);
fList=Inf(n,1); % Inf denotes a scalar representation of positive infinity
ParentList=repmat({''},n,1);

T=table(gList,hList,fList,ParentList,'RowNames',NodesList,'VariableNames',{'g','h','f','parent'});

% --- Make the start vertex current
c=Start;

% --- Calculate f value for start vertex (f = g + h, where g = 0)
g=table2array(T(c,'g'));
h=table2array(T(c,'h'));
f=g+h;
T(c,'f')=array2table(f);

T(c,'f')=array2table(table2array(T(c,'g'))+table2array(T(c,'h')));

% we always start from S therefore we are printing S the corresponding f
% and selecting S
fprintf('Frontier : \n');
fprintf('  S(')
fprintf(string(table2array(T('S','g')))); %!!!!!!!!!!!!!!!!!!%
fprintf(', -) \nSelection : \n  S\n')

% --- while current vertex is not the destination
while ~ismember(Goal,c)
    % --- for each vertex adjacent to current
    AdjNodesG=LinksList(strcmp(LinksList(:,1),c),2:3);
    
    for i=1:size(AdjNodesG,1)
        v=AdjNodesG(i,1);
        % --- if vertex not in closed list then
        if ~ismember(v,ClosedList)
            % --- Calculate distance from start (g)
            g_this=AdjNodesG{i,2};
            g_parent=table2array(T(c,'g'));
            g=g_parent+g_this;
            % --- Calculate heuristic distance to destination (h)
            h=table2array(T(v,'h'));
            % --- Calculate f value (f = g + h)
            f=g+h;
            % --- If new f value < existing f then
            f_current=table2array(T(v,'f'));
            
            if f<f_current
            % --- If vertex not in open list then add it
                if ~ismember(v,OpenList)
                    OpenList=[OpenList,v];
                end
                % --- Update f value
                T(v,'g')=array2table(g);
                T(v,'f')=array2table(f);
                % --- Set parent to be the current vertex
                T(v,'parent')=c;
            end
        end
    end
    % --- Add current vertex to closed list
    ClosedList=[ClosedList,c];
    % --- Remove current vertex from open list
    OpenList=setdiff(OpenList,c);
    % --- Find vertex with lowest f value from open list and make it new current
    [~,SortIdx]=sortrows(table2array(T(OpenList,{'g'}))); %!!!!!!!!!!!!!!!!!!!!
    % [~,SortIdx]=sortrows(table2array(T(OpenList,{'f','h'}))); % use this if there are equal f values and want to sub-sort by h values
    c=OpenList(SortIdx(1));
    
    % ---     END WHILE
    %disp('=======================================');
    %OpenList
    %ClosedList
    %T
    %c

    fprintf('Frontier : \n');
    
    for i=1:length(OpenList) % going through all elements of OpenList and printing out the frontier
        node = string(OpenList(1,i));
        node_parent = string(table2array(T(node, "parent")));
        node_f = table2array(T(node, 'g')); %!!!!!!!!!!!!!!!!!!!!!
        % transforming the sets to a string
        fprintf('  %s(%g, %s) \n', [node node_f node_parent]) %!!!!!!!!!!!!!!!!
    end 
    fprintf('Selection : \n'); 
    fprintf('  %s \n', string(c)); % printing the node that was selected
end
Cost=table2array(T(c,'g')); %!!!!!!!!!!!!!!!!!
Path=c;
while ~isempty(cell2mat(table2array(T(c,'parent'))))
    Path=[table2array(T(c,'parent')) Path];
    c=table2array(T(c,'parent'));
end

fprintf('Finished! \n');
fprintf('Path : ');
% printing until the last-1 node
for i=1:length(Path)-1
    fprintf(string(Path(1,i)));
    fprintf(' -> ');
end
% printing the last node and the cost
fprintf(string(Path(1,length(Path))));
fprintf('\nCost : ')
fprintf(string(Cost))
fprintf('\n')


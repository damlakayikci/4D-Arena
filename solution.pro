% consult('simulator.pro').
% consult('main.pro').

distance(Agent, TargetAgent, Distance):-
  Distance is abs(Agent.x - TargetAgent.x) +  abs(Agent.y - TargetAgent.y).


multiverse_distance(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :-
  history(StateId, UniverseId, Time, _),                         % get universe and time of current state
  history(TargetStateId, TargetUniverseId, TargetTime, _),       % get universe and time of target state
 
  state(StateId, Agents, _, _),                                  % get agents of current state
  state(TargetStateId, TargetAgents, _ , _),                     % get agents of target state

  Agent = Agents.get(AgentId),
  TargetAgent = TargetAgents.get(TargetAgentId),

  (Agent.class = wizard -> TravelCost = 2; TravelCost = 5),      % if agent is a wizard, travel cost is 2, else 5

  Distance is abs(Agent.x - TargetAgent.x) +  abs(Agent.y - TargetAgent.y) + 
  TravelCost *(abs(Time - TargetTime) + abs(UniverseId - TargetUniverseId))
 .

% difference_list([], Agent, Distances).
% difference_list([X|Xs], Agent, Distances) :-
%   distance(Agent , X, Distance),
%   difference_list(Xs, Agent, [Distance | Distances]).

% difference_list([], _, []).
% difference_list([X|Xs], Agent, [Distance|Distances]) :-
%     distance(Agent, X, Distance),
%     difference_list(Xs, Agent, Distances).


find_key_by_value(Value, Dict, Key) :-
  get_dict(Key, Dict, Value),
  !.
find_key_by_value(Value, Dict, Key) :-
  dict_pairs(Dict, _, Pairs),
  member(Key-Value, Pairs).

remove_element(_, [], []).
remove_element(Element, [Element|Tail], TailWithoutElement) :-
    remove_element(Element, Tail, TailWithoutElement).
remove_element(Element, [Head|Tail], [Head|TailWithoutElement]) :-
    dif(Head, Element),
    remove_element(Element, Tail, TailWithoutElement).



nearest_agent(StateId, AgentId, NearestAgentId, Distance) :-
  state(StateId, Agents, _, _),                                  % get agents of current state
  Agent = Agents.get(AgentId),                                   % get agent of current state

  %findall(distance(Agent, Agents.get(X), Distance), (member(X,Agents), \+ X = AgentId) , Distances),
  %findall(Distance, (member(X, Agents), X \= AgentId, distance(Agent, Agents.get(X), Distance)), Distances).
  findall(D, (member(X, Agents), distance(Agent, Agents.get(X), D)), Distances).

  remove_element(0, Distances, Filtered),
  min_list(Filtered, MinDistance),                              % get minimum distance

  nth0(Index, Distances, MinDistance),                           % get index of minimum distance                 
  nth0(Index, Agents, NearestAgentId),                           % get agent at index of minimum distance
  
  Distance is  MinDistance,
  NearestAgentId is NearestAgentId
  .


% nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance).
% num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues).
% difficulty_of_state(StateId, Name, AgentClass, Difficulty).
% easiest_traversable_state(StateId, AgentId, TargetStateId).
% basic_action_policy(StateId, AgentId, Action).

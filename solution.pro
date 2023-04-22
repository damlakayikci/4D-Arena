
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
  TravelCost *(abs(Time - TargetTime) + abs(UniverseId - TargetUniverseId)).


% remove specified element from list
remove_element(_, [], []).
remove_element(Element, [Element|Tail], TailWithoutElement) :-
    remove_element(Element, Tail, TailWithoutElement).
remove_element(Element, [Head|Tail], [Head|TailWithoutElement]) :-
    dif(Head, Element),
    remove_element(Element, Tail, TailWithoutElement).

% get key of dict at specified index
key_at_index(Dict, Index, Key) :-
  dict_keys(Dict, Keys),
  nth0(Index, Keys, Key).


nearest_agent(StateId, AgentId, NearestAgentId, Distance) :-
  state(StateId, Agents, _, _),                                  % get agents of current state
  Agent = Agents.get(AgentId),                                   % get agent of current state

  findall(D, (get_dict(TargetAgentId, Agents, _), distance(Agent, Agents.get(TargetAgentId), D)), Distances),
  remove_element(0, Distances, Filtered),                       % remove distance to self
  min_list(Filtered, Distance),                                 % get minimum distance

  nth0(Index, Distances, Distance),                             % get index of minimum distance from the original list 
  key_at_index(Agents, Index, NearestAgentId)                   % get key of agent at that index
  .


% nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :-
%   history(StateId, UniverseId, Time, _),                         % get universe and time of current state
%   state(StateId, Agents, _, _),                                  % get agents of current state
%   Agent = Agents.get(AgentId),                                   % get agent of current state

%   % find all distances to agents in current state
%   findall(D, (get_dict(TargetAgentId, Agents, _), distance(Agent, Agents.get(TargetAgentId), D)), Distances),
%   remove_element(0, Distances, Filtered),                       % remove distance to self
  
%   write(Distances)
% .


% num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues) :-
%   state(StateId, Agents, _, _),
%   findall(AgentId, (get_dict(AgentId, Agents, Agent), Agent.class = warrior), Warriors),
%   findall(AgentId, (get_dict(AgentId, Agents, Agent), Agent.class = wizard), Wizards),
%   findall(AgentId, (get_dict(AgentId, Agents, Agent), Agent.class = rogue), Rogues),
%   length(Warriors, NumWarriors),
%   length(Wizards, NumWizards),
%   length(Rogues, NumRogues)




difficulty_of_state(StateId, Name, AgentClass, Difficulty) :-
  state(StateId, Agents, _, _),
  ((AgentClass = warrior -> 
    % Difficulty = 5 ∗ NumWarriors + 8 ∗ NumWizards + 2 ∗ NumRogues
    Difficulty is NumWarriors * 5 + NumWizards * 8 + NumRogues * 2
   );
   (AgentClass = wizard ->
    % Difficulty = 2 ∗ NumWarriors + 5 ∗ NumWizards + 8 ∗ NumRogues
     Difficulty is NumWarriors * 2 + NumWizards * 5 + NumRogues * 8
   );
   (Agent.class = rogue ->
    % Difficulty = 8 ∗ NumWarriors + 2 ∗ NumWizards + 5 ∗ NumRogues
    Difficulty is NumWarriors * 8 + NumWizards * 2 + NumRogues * 5
   )
  )
. 

% easiest_traversable_state(StateId, AgentId, TargetStateId).
% basic_action_policy(StateId, AgentId, Action).

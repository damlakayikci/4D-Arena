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
  (Agent.class = wizard -> TravelCost = 2; TravelCost = 5),

  Distance is abs(Agent.x - TargetAgent.x) +  abs(Agent.y - TargetAgent.y) + 
  TravelCost *(abs(Time - TargetTime) + abs(UniverseId - TargetUniverseId))
 .


% nearest_agent(StateId, AgentId, NearestAgentId, Distance).
% nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance).
% num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues).
% difficulty_of_state(StateId, Name, AgentClass, Difficulty).
% easiest_traversable_state(StateId, AgentId, TargetStateId).
% basic_action_policy(StateId, AgentId, Action).

?- consult('simulator.pro').

distance(Agent, TargetAgent, Distance):-
  Distance is abs(Agent.x - TargetAgent.x) +  abs(Agent.y - TargetAgent.y).


multiverse_distance(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :-
  get_current_agent_and_state(UniverseId, AgentId, StateId),
  get_current_agent_and_state(TargetUniverseId, TargetAgentId, TargetStateId),

  Agent = Agents.get(AgentId),
  TargetAgent = Agents.get(TargetAgentId),

  % if agent is not a wizard
  %Agent \= agent(wizard, _, _, _),
  (Agent.class = wizard -> TravelCost = 2; TravelCost = 5),

 Distance is abs(Agent.x - TargetAgent.x) +  abs(Agent.y - TargetAgent.y) + TravelCost *(abs(Agent.time - TargetAgent.time) + abs(UniverseId - TargetUniverseId))
 .


% nearest_agent(StateId, AgentId, NearestAgentId, Distance).
% nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance).
% num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues).
% difficulty_of_state(StateId, Name, AgentClass, Difficulty).
% easiest_traversable_state(StateId, AgentId, TargetStateId).
% basic_action_policy(StateId, AgentId, Action).

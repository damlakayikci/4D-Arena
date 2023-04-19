%distance(0, 0, 0).  % a dummy predicate to make the sim work.

 distance(Agent, TargetAgent, Distance):-
  Distance is abs(Agent.x - TargetAgent.x) +  abs(Agent.y - TargetAgent.y).

% multiverse_distance(StateId, AgentId, TargetStateId, TargetAgentId, Distance).
% nearest_agent(StateId, AgentId, NearestAgentId, Distance).
% nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance).
% num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues).
% difficulty_of_state(StateId, Name, AgentClass, Difficulty).
% easiest_traversable_state(StateId, AgentId, TargetStateId).
% basic_action_policy(StateId, AgentId, Action).


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


% get key of dict at specified index
key_at_index(Dict, Index, Key) :-
  dict_keys(Dict, Keys),
  nth0(Index, Keys, Key).

% 
min_tuple([Tuple], Tuple).
min_tuple([(D1, Agent1, Id1), (D2, _, _) | Rest], MinTuple) :-
    D1 =< D2,
    min_tuple([(D1, Agent1, Id1) | Rest], MinTuple).
min_tuple([(D1, _, _), (D2, Agent2, Id2) | Rest], MinTuple) :-
    D1 > D2,
    min_tuple([(D2, Agent2, Id2) | Rest], MinTuple).


nearest_agent(StateId, AgentId, NearestAgentId, Distance) :-
  state(StateId, Agents, _, _),                                  % get agents of current state
  Agent = Agents.get(AgentId),                                   % get agent of current state

  findall((D, TargetAgent, TargetAgentId), 
        (get_dict(TargetAgentId, Agents, _),                     % for each agent in Agents
         TargetAgent = Agents.get(TargetAgentId),                % get agent
         TargetAgent.name \= Agent.name,                         % if agent name is not equal to current agent name
         distance(Agent, TargetAgent, D)),                       % calculate distance
        DistancesandAgents),
  min_tuple(DistancesandAgents, (Distance, _, NearestAgentId))   % get agent with minimum distance
  .

multiverse_min_tuple([Tuple], Tuple).
multiverse_min_tuple([(D1, Agent1, Id1, StId1), (D2, _, _, _) | Rest], MinTuple) :-
    D1 =< D2,
    multiverse_min_tuple([(D1, Agent1, Id1, StId1) | Rest], MinTuple).
multiverse_min_tuple([(D1, _, _,_), (D2, Agent2, Id2, StId2) | Rest], MinTuple) :-
    D1 > D2,
    multiverse_min_tuple([(D2, Agent2, Id2, StId2) | Rest], MinTuple).


nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :-
  findall(StateIds, (history(StateIds, _, _, _)), States),             % get all states
  findall((Agents, StateIden),
        (member(StateIden, States), state(StateIden, Agents, _, _)),       % get all agents in all states
        AllAgents),
  state(StateId, Agents, _, _),                                  % get agents of current state
  Agent = Agents.get(AgentId),                                   % get agent of current state
  % find all distances to agents in current state
  findall((D, TAgent, TAgentId, TStateId), 
        (member((TAgents, TStateId), AllAgents),                   % for all elements in AllAgents
         get_dict(TAgentId, TAgents, _),                           % for each agent in Agents
         TAgent = TAgents.get(TAgentId),                           % get agent
         TAgent.name \= Agent.name,                               % if agent name is not equal to current agent name
         multiverse_distance(StateId, AgentId, TStateId , TAgentId, D)),                       % calculate distance
        DistancesandAgents),
  multiverse_min_tuple(DistancesandAgents, (Distance, _,TargetAgentId, TargetStateId)).   % get agent with minimum distance




num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues) :-
  state(StateId, Agents, _, _),
  findall(AgentId, (get_dict(AgentId, Agents, _), Agent= Agents.get(AgentId), Agent.name \= Name, Agent.class = warrior), Warriors),
  findall(AgentId, (get_dict(AgentId, Agents, _), Agent= Agents.get(AgentId), Agent.name \= Name, Agent.class = wizard), Wizards),
  findall(AgentId, (get_dict(AgentId, Agents, _), Agent= Agents.get(AgentId), Agent.name \= Name, Agent.class = rogue), Rogues),
  length(Warriors, NumWarriors),
  length(Wizards, NumWizards),
  length(Rogues, NumRogues).




difficulty_of_state(StateId, Name, AgentClass, Difficulty) :-
  % call num_agents_in_state to get number of each class of agents in state
  num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues),
  ((AgentClass = warrior -> 
    % Difficulty = 5 ∗ NumWarriors + 8 ∗ NumWizards + 2 ∗ NumRogues
    Difficulty is NumWarriors * 5 + NumWizards * 8 + NumRogues * 2
   );
   (AgentClass = wizard ->
    % Difficulty = 2 ∗ NumWarriors + 5 ∗ NumWizards + 8 ∗ NumRogues
     Difficulty is NumWarriors * 2 + NumWizards * 5 + NumRogues * 8
   );
   (AgentClass = rogue ->
    % Difficulty = 8 ∗ NumWarriors + 2 ∗ NumWizards + 5 ∗ NumRogues
    Difficulty is NumWarriors * 8 + NumWizards * 2 + NumRogues * 5
   )
  )
. 



can_perform_action(StateId, TargetStateId, AgentId, Action) :-
    state(StateId, Agents, _, TurnOrder),
    state(TargetStateId, TargetAgents, _, TargetTurnOrder),
    history(StateId, UniverseId, Time, _),
    history(TargetStateId, TargetUniverseId, TargetTime, _),
    Agent = Agents.get(AgentId),
  ((Action = portal ->
      % check whether global universe limit has been reached
      global_universe_id(GlobalUniverseId),
      universe_limit(UniverseLimit),
      GlobalUniverseId < UniverseLimit,
      % agent cannot time travel if there is only one agent in the universe
      length(TurnOrder, NumAgents),
      NumAgents > 1,
      %[TargetUniverseId, TargetTime] = ActionArgs,
      % check whether target is now or in the past
      current_time(TargetUniverseId, TargetUniCurrentTime, _),
      TargetTime < TargetUniCurrentTime,
      % check whether there is enough mana
      (Agent.class = wizard -> TravelCost = 2; TravelCost = 5),
      Cost is abs(TargetTime - Time)*TravelCost + abs(TargetUniverseId - UniverseId)*TravelCost,
      Agent.mana >= Cost,
      % check whether the target location is occupied
      TargetState = state(TargetStateId, TargetAgents, _, TargetTurnOrder),
      \+tile_occupied(Agent.x, Agent.y, TargetState)
        );
  (Action = portal_to_now ->
      % agent cannot time travel if there is only one agent in the universe
      length(TurnOrder, NumAgents),
      NumAgents > 1,
     % [TargetUniverseId] = ActionArgs,
      % agent can only travel to now if it's the first turn in the target universe
      current_time(TargetUniverseId, TargetTime, 0),
      % agent cannot travel to current universe's now (would be a no-op)
      \+(TargetUniverseId = UniverseId),
      % check whether there is enough mana
      (Agent.class = wizard -> TravelCost = 2; TravelCost = 5),
      Cost is abs(TargetTime - Time)*TravelCost + abs(TargetUniverseId - UniverseId)*TravelCost,
      Agent.mana >= Cost,
      % check whether the target location is occupied
      TargetState = state(TargetStateId, TargetAgents, _, TargetTurnOrder),
      \+tile_occupied(Agent.x, Agent.y, TargetState)
)).

remove_zero_tuples([], []).
remove_zero_tuples([(0, _, _) | Rest], Filtered) :-
    remove_zero_tuples(Rest, Filtered).
remove_zero_tuples([(H1, H2, H3) | Rest], [(H1, H2, H3) | Filtered]) :-
    H1 \= 0,
    remove_zero_tuples(Rest, Filtered).

  
easiest_traversable_state(StateId, AgentId, TargetStateId) :-
  state(StateId, Agents,_,_),                                 % 
  Agent = Agents.get(AgentId),                                         % get agent of current state
  findall(StateIden, 
    (history(StateIden, _, _, _), 
      (can_perform_action(StateId, StateIden, AgentId, portal);
       can_perform_action(StateId, StateIden, AgentId, portal_to_now)) ),
    Portals),

  findall((Difficulty,State, AgentId), (member(State, Portals), difficulty_of_state(State, Agent.name, Agent.class, Difficulty)), Difficulties),
  remove_zero_tuples(Difficulties, Filtered),
  min_tuple(Filtered, (_,TargetStateId,_))
  
.



% basic_action_policy(StateId, AgentId, Action).

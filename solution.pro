% damla kayikci
% 2020400228
% compiling: yes
% complete: yes

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

% function to return element with minimum distance w 3 elements
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

% function to return element with minimum distance w 4 elements
multiverse_min_tuple([Tuple], Tuple).
multiverse_min_tuple([(D1, Agent1, Id1, StId1), (D2, _, _, _) | Rest], MinTuple) :-
    D1 =< D2,
    multiverse_min_tuple([(D1, Agent1, Id1, StId1) | Rest], MinTuple).
multiverse_min_tuple([(D1, _, _,_), (D2, Agent2, Id2, StId2) | Rest], MinTuple) :-
    D1 > D2,
    multiverse_min_tuple([(D2, Agent2, Id2, StId2) | Rest], MinTuple).


nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :-
  findall(StateIds, (history(StateIds, _, _, _)), States),                 % get all states
  findall((Agents, StateIden),
        (member(StateIden, States), state(StateIden, Agents, _, _)),       % get all agents in all states
        AllAgents),
  state(StateId, Agents, _, _),                                            % get agents of current state
  Agent = Agents.get(AgentId),                                             % get agent of current state
  % find all distances to agents in current state
  findall((D, TAgent, TAgentId, TStateId), 
        (member((TAgents, TStateId), AllAgents),                           % for all elements in AllAgents
         get_dict(TAgentId, TAgents, _),                                   % for each agent in Agents
         TAgent = TAgents.get(TAgentId),                                   % get agent
         TAgent.name \= Agent.name,                                        % if agent name is not equal to current agent name
         multiverse_distance(StateId, AgentId, TStateId , TAgentId, D)),   % calculate distance
        DistancesandAgents),
  multiverse_min_tuple(DistancesandAgents, (Distance, _,TargetAgentId, TargetStateId)).   % get agent with minimum distance




num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues) :-
  state(StateId, Agents, _, _),
  % find all agents in state with given name
  findall(AgentId, (get_dict(AgentId, Agents, _), Agent= Agents.get(AgentId), Agent.name \= Name, Agent.class = warrior), Warriors),
  findall(AgentId, (get_dict(AgentId, Agents, _), Agent= Agents.get(AgentId), Agent.name \= Name, Agent.class = wizard), Wizards),
  findall(AgentId, (get_dict(AgentId, Agents, _), Agent= Agents.get(AgentId), Agent.name \= Name, Agent.class = rogue), Rogues),
  % return length of each list
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
    state(StateId, Agents, _, TurnOrder),                    % get agents of current state
    state(TargetStateId, TargetAgents, _, TargetTurnOrder),  % get agents of target state
    history(StateId, UniverseId, Time, _),                   % get history of current state (universeId & time)
    history(TargetStateId, TargetUniverseId, TargetTime, _), % get history of target state (universeId & time)
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

% function to remove tuples with 0 distance
remove_zero_tuples([], []).
remove_zero_tuples([(0, _, _) | Rest], Filtered) :-
    remove_zero_tuples(Rest, Filtered).
remove_zero_tuples([(H1, H2, H3) | Rest], [(H1, H2, H3) | Filtered]) :-
    H1 \= 0,
    remove_zero_tuples(Rest, Filtered).

  
easiest_traversable_state(StateId, AgentId, TargetStateId) :-
  state(StateId, Agents,_,_),           
  Agent = Agents.get(AgentId),                                        % get agent of current stat
  % find all states that are traversable from current state
  findall(StateIden, 
    (history(StateIden, _, _, _),
      (can_perform_action(StateId, StateIden, AgentId, portal);
       can_perform_action(StateId, StateIden, AgentId, portal_to_now)) ),
    Portal),
    append(Portal, [StateId], Portals),
    findall((Difficulty,State, AgentId), (member(State, Portals), difficulty_of_state(State, Agent.name, Agent.class, Difficulty)), Difficulties),
    % remove tuples with 0 distance
  remove_zero_tuples(Difficulties, Filtered),
  % find the state with the minimum distance
  (Filtered = [] -> TargetStateId = StateId ; 
    (min_tuple(Filtered, (MinDistance,_,_)),
    (member((MinDistance, StateId, _), Filtered)-> TargetStateId = StateId;
    min_tuple(Filtered, (_,TargetStateId,_)))
    )).



basic_action_policy(StateId, AgentId, Action) :-
  state(StateId, Agents, _, _),                                % get agents of current state
  State = state(StateId, Agents, _, _),                        % get state of current state
  Agent = Agents.get(AgentId),                                 % get agent of current state
  easiest_traversable_state(StateId, AgentId, TargetStateId),  % check whether there is a traversable state
  (
      (TargetStateId \= StateId) -> % If TargetStateId is a valid state and different from the current state
        (history(TargetStateId, UniverseId, TargetTime, _),
        current_time(UniverseId, Time, 0),
        TargetTime = Time ->
          Action = ['portal_to_now', UniverseId]; % Use portal action with TargetStateId
        Action = ['portal', TargetStateId]) % Use portal_to_now action with TargetStateId
      ; % else
      % find nearest agent
      nearest_agent(StateId, AgentId, NearestAgentId, Distance),
      TargetAgent = Agents.get(NearestAgentId),

      (
        Agent.class = warrior, % If the agent is a warrior
        Distance =< 1,
        Damage is 20 - Agent.armor,
        TargetAgentHealth is TargetAgent.health - Damage,
        TargetAgentHealth > 0 ->
          Action = ['melee_attack', NearestAgentId] % Use melee_attack action with NearestAgentId
      ;
        Agent.class = wizard, % If the agent is a wizard
        Distance =< 10,
        Damage is 10 - Agent.agility,
        TargetAgentHealth is TargetAgent.health - Damage,
        TargetAgentHealth > 0 ->
          Action = ['magic_missile', NearestAgentId] % Use magic_missile action with NearestAgentId
      ;
        Agent.class = rogue, % If the agent is a rogue
        Distance =< 5,
        Damage is 15 - Distance - Agent.armor,
        TargetAgentHealth is TargetAgent.health - Damage,
        TargetAgentHealth > 0 ->
          Action = ['ranged_attack', NearestAgentId] % Use ranged_attack action with NearestAgentId
      ; % if agent cannot attack
        ( 
          HorizontalDistance is Agent.x - TargetAgent.x,
          VerticalDistance is Agent.y - TargetAgent.y,
          (
            HorizontalDistance \= 0 ->
              (
                HorizontalDistance > 0, % Move left
                  Xn is Agent.x - 1,
                  \+tile_occupied(Xn, Agent.y, State) ->
                  Action = ['move_left']
              ; % else Move right
                Xn is Agent.x + 1,
                \+tile_occupied(Xn, Agent.y, State) ->
                Action = ['move_right']
              )
          ; VerticalDistance \= 0 ->
            (
              VerticalDistance > 0, % Move down
                Yn is Agent.y - 1,
                \+tile_occupied(Agent.x, Yn, State) ->
                Action = ['move_down']
            ; % else Move up
              Yn is Agent.y + 1,
              \+tile_occupied(Agent.x, Yn, State) ->
              Action = ['move_up']
            )
          ),
          !
        )
      ) 
 ; % else retun rest
Action = ['rest']
  ).


%Facts Given
route(dublin, cork, 200, 'fct').
route(cork, dublin, 200, 'fct').
route(cork, corkAirport, 20, 'fc').
route(corkAirport, cork, 25, 'fc').
route(dublin, dublinAirport, 10, 'fc').
route(dublinAirport, dublin, 20, 'fc').
route(dublinAirport, corkAirport, 225, 'p').
route(corkAirport, diblinAirport, 225, 'p').

%full write is just to write a list makeing it easy to see the answer and the steps taken
fullWrite([]).
fullWrite([H|Tails]) :- write(H), fullWrite(Tails).

% travel commands will take two points and get the time back 
% Use of member will make my code shorter it makes my life easier than createing a is_element command
% foot = 5km/hr
% foot command is for when i will walk on my journey
foot(P1, P2, Time) :- route(P1, P2, Dis, _), Time is Dis / 5.

% car = 80km/hr
% car command is for when i drive a car on the journey
car(P1, P2, Time) :- route(P1, P2, Dis, _), Time is Dis / 80.

% train = 100km/hr
% train command is for when i take the train on the journey
train(P1, P2, Time) :- route(P1, P2, Dis, _), Time is Dis / 100.

% plane = 500km/hr
% plane command is for when i take the plane on the journey
plane(P1, P2, Time) :- route(P1, P2, Dis, _), Time is Dis / 500.

%empty Route this is for the beginning of the route loop it there to make sure prolog understands route must be a list
emptyR(Route) :- Route = _, Route = [].
% calRoute is for calculating the route that are possible to take.
calRoute(P1, P1, Route, New_Route) :- append(Route, [P1], New_Route), !.
calRoute(P1, P2, Route, New_Route) :- route(P1, X, _, _),emptyR(Route),not(member(X, Route)),append(Route, [P1], Next_Route), calRoute(X, P2, Next_Route, New_Route).
calRoute(P1, P2, Route, New_Route) :- route(P1, X, _, _),not(member(X, Route)),append(Route, [P1], Next_Route), calRoute(X, P2, Next_Route, New_Route).

%check finds which modes of transport we will take and the fastest we can take.
%Compairing the allowed forms of transport and the actual forms of transport we can use.
checkTime(P1, P2, AllowedString, Mode, Time) :- route(P1, P2, _, String),string_chars(String, Trans),string_chars(AllowedString, Trans2), member(p, Trans),member(p, Trans2), Mode = "p", plane(P1, P2, Time), !.
checkTime(P1, P2, AllowedString, Mode, Time) :- route(P1, P2, _, String),string_chars(String, Trans),string_chars(AllowedString, Trans2), member(t, Trans),member(t, Trans2), Mode = "t", train(P1, P2, Time), !.
checkTime(P1, P2, AllowedString, Mode,Time) :- route(P1, P2, _, String),string_chars(String, Trans),string_chars(AllowedString, Trans2), member(c, Trans),member(c, Trans2), Mode = "c", car(P1, P2, Time), !.
checkTime(P1, P2, AllowedString, Mode, Time) :- route(P1, P2, _, String),string_chars(String, Trans),string_chars(AllowedString, Trans2), member(f, Trans),member(f, Trans2), Mode = "f", foot(P1, P2, Time), !.


%Time just takes two points from calRoute and calculates the time for each point.
time([_], _, Time) :- Time is 0, !.
time([P1, P2|Tail], AllowedString, Time) :- checkTime(P1, P2, AllowedString, _, Time2), append([P2], Tail, New_Route), time(New_Route, AllowedString, Time3), Time is Time2 + Time3.

% Modes are the allowed modes of transport i am allowed to take
l_journey(P1, P2, Modes, Time, Route) :- calRoute(P1, P2, _, Route), time(Route, Modes, Time).
%calculates the shortest distance using bagof to take all possible solutions into account.
shortest(P1, P2, Modes, Time, Route) :- bagof(_, l_journey(P1, P2, Modes, Time, Route), _).

%Final Journey command
%base case is if both cities are the same gives an error message to please try again
journey(P1, P1, _) :- write("You are already at this destination please choose different locations!"), !.
%general case where all most calculations/functions are called from
journey(P1, P2, Modes) :- shortest(P1, P2, Modes, T, R), fullWrite(["Time taken to get to location: ", T, " hours", "\n", "Route Taken: ", R]), !.
%Error message for if no routes are available mainly there for looks its nicer than just seeing False so i put it in
journey(_,_,_) :- write("No route found please try again!"), !.
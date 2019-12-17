%Facts Given
route(dublin, cork, 200, 'fct').
route(cork, dublin, 200, 'fct').
route(cork, corkAirport, 20, 'fc').
route(corkAirport, cork, 25, 'fc').
route(dublin, dublinAirport, 10, 'fc').
route(dublinAirport, dublin, 20, 'fc').
route(dublinAirport, corkAirport, 225, 'p').
route(corkAirport, diblinAirport, 225, 'p').

route(corkAirport, airport, 225, 'p').
route(airport, corkAirport, 225, 'p').
route(airport, newAirport, 225, 'p').
route(newAirport, airport, 225, 'p').
%check if element is in list
isElm([X], [X|_]).
isElm([X], [_|T]) :- isElm([X], T).

%full write is just to write a list makeing it easy to see the answer and the steps taken
fullWrite([]).
fullWrite([H|Tails]) :- write(H), fullWrite(Tails).

%if empty is for the alloed modes from the journey predicate
%for me this means any mode of transport can be used
ifEmpty(X) :- X = _, X = 'fctp'.

%if sting in element.
%I use the prolog in built function to change the string into a list of ascii numbers then check if the original ascii number is in the other list.
stringElm(S1, S2) :- string_to_list(S1, L1), string_to_list(S2, L2), isElm(L1, L2).

%foot = 5km/h, symbol = 'f'
%input places to go recieve distance and time per hour.
foot(Dis, Time) :- route(_, _,Dis,Trans), stringElm('f', Trans), Time is Dis / 5.

%car = 80km/h, symbol = 'c'
%input places to go and reviece distance and time per hour
car(Dis, Time) :- route(_,_,Dis,Trans), stringElm('c', Trans), Time is Dis / 80.

%train = 100km/h, symbol = 't'
%input places to go and recieve distance and time per hour
train(Dis, Time) :- route(_,_,Dis,Trans), stringElm('t', Trans), Time is Dis / 100.

%plane = 500km/h, symbol = 'p'
%input places to go and recieve distance and time per hour
plane(Dis, Time) :- route(_,_,Dis,Trans), stringElm('p', Trans), Time is Dis / 500.

%check which modes of transport you can use you can take.
check(Trans, Mode) :- stringElm('f', Trans), Mode = 'f', !.
check(Trans, Mode) :- stringElm('c', Trans), Mode = 'c', !.
check(Trans, Mode) :- stringElm('t', Trans), Mode = 't', !.
check(Trans, Mode) :- stringElm('p', Trans), Mode = 'p', !.

%decide which mode of transport is the quickest
%I used the ideas that walking is slower than car which is slower than train which again is slower than a plane
%i also take the distance for the fastest mode and get the time by dividing and the allowed modes of transport from the journey predicate
quickTrans(Dis, Modes, Fastest, Time, AllowedM) :- check(Modes, 'p'), check(AllowedM, 'p'), Fastest = 'plane', plane(Dis, Time), !.
quickTrans(Dis, Modes, Fastest, Time, AllowedM) :- check(AllowedM, 't'), check(Modes, 't'), Fastest = 'train', train(Dis, Time), !.
quickTrans(Dis, Modes, Fastest, Time, AllowedM) :- check(AllowedM, 'c'), check(Modes, 'c'), Fastest = 'car', car(Dis, Time), !.
quickTrans(Dis, Modes, Fastest, Time, AllowedM) :- check(AllowedM, 'f'), check(Modes, 'f'), Fastest = 'foot', foot(Dis, Time), !.

%Total Time taken between two points using fastest transport
routeTrans(P1, P2, Mode, Time, AllowedM) :- route(P1, P2, Dis, Trans), quickTrans(Dis, Trans, Mode, Time, AllowedM), !.

%calculate routes to be taken to reach destination
calRoute(P1, P2, Route) :- route(P1, P2, _, _), Route = [P1, P2], !.
calRoute(P1, P2, Route) :- route(P1, X, _, _), route(X, P2, _, _), append([[P1, X]], [[X, P2]], Route).

%Take Routes from calRoute and place them into routeTrans, This gives us the time taken
%also takes the allowed modes of transport from the journey predicate
time(Routes, Time, AllowedM) :- Routes = [P1, P2|_], route(P1, P2, _, _), routeTrans(P1, P2, Mode, Time, AllowedM), fullWrite([P1," to ",P2," by ",Mode,"\n",Mode," ",Time,"\n"]).
time(Routes, Time, AllowedM) :- Routes = [[P1, P2|_]], route(P1, P2, _, _), routeTrans(P1, P2, Mode, Time, AllowedM), fullWrite([P1," to ",P2," by ",Mode,"\n",Mode," ",Time,"\n"]).
time(Routes, Time, AllowedM) :- Routes = [First|Rest], First = [P1, P2], route(P1, P2, _, _), routeTrans(P1, P2, Mode, Time1, AllowedM), time(Rest, Time2, AllowedM), Time is Time1 + Time2, fullWrite([P1," to ",P2," by ",Mode,"\n",Mode," ",Time1,"\n"]).

%journey command
%Takes point 1, point 2, and the allowed modes of transport.
journey(P1, P1, _) :- write("You are already at this location!"), !.
journey(P1, P2, AllowedM) :- calRoute(P1, P2, Routes), ifEmpty(AllowedM),time(Routes, Time, AllowedM), fullWrite(["Total Time: ",Time]).
journey(P1, P2, AllowedM) :- calRoute(P1, P2, Routes), not(ifEmpty(AllowedM)),time(Routes, Time, AllowedM), fullWrite(["Total Time: ",Time]).

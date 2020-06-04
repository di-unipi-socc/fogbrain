reasoningStep(App, Placement, AllocHW, AllocBW, NewPlacement) :-
    toMigrate(Placement, ServicesToMigrate),
    replacement(App, ServicesToMigrate, Placement, AllocHW, AllocBW, NewPlacement).

toMigrate(Placement, ServicesToMigrate) :-
    findall((S,N,HWReqs), onSufferingNode(S,N,HWReqs,Placement), ServiceDescr1),
    findall((SD1,SD2), onSufferingLinks(SD1,SD2,Placement), ServiceDescr2),
    merge(ServiceDescr2, ServiceDescr1, ServicesToMigrate).

onSufferingNode(S, N, HWReqs, Placement) :-  
    member(on(S,N), Placement),
    service(S, SWReqs, HWReqs, TReqs),
    nodeProblem(N, SWReqs, TReqs).

nodeProblem(N, SWReqs, TReqs) :-
    node(N, SWCaps, HWCaps, TCaps),
    hwTh(T), \+ (HWCaps > T, thingReqsOK(TReqs,TCaps), swReqsOK(SWReqs,SWCaps)).
nodeProblem(N, _, _) :- 
    \+ node(N, _, _, _).

onSufferingLinks((S1,N1,HWReqs1),(S2,N2,HWReqs2),Placement) :-
    member(on(S1,N1), Placement), member(on(S2,N2), Placement), N1 \== N2,
    s2s(S1, S2, ReqLat, _),
    communicationProblem(N1, N2, ReqLat),
    service(S1, _, HWReqs1, _),
    service(S2, _, HWReqs2, _).

communicationProblem(N1, N2, ReqLat) :- 
    link(N1, N2, FeatLat, FeatBW), 
    (FeatLat > ReqLat; bwTh(T), FeatBW < T).
communicationProblem(N1,N2,_) :- 
    \+ link(N1, N2, _, _).

merge([], L, L).
merge([(D1,D2)|Ds], L, NewL) :- merge2(D1, L, L1), merge2(D2, L1, L2), merge(Ds, L2, NewL).
merge2(D, [], [D]).
merge2(D, [D|L], [D|L]).
merge2(D1, [D2|L], [D2|NewL]) :- D1 \== D2, merge2(D1, L, NewL).

replacement(_, [], Placement, _, _, Placement).
replacement(A, ServicesToMigrate, Placement, AllocHW, AllocBW, NewPlacement) :-
    ServicesToMigrate \== [], retract(deployment(A, Placement, _, _)),
    findall(S, member((S,_,_), ServicesToMigrate), Services),
    partialPlacement(Placement, Services, PPlacement),
    freeHWAllocation(AllocHW, PAllocHW, ServicesToMigrate),
    freeBWAllocation(AllocBW, PAllocBW, ServicesToMigrate, Placement), 
    placement(Services, PAllocHW, NewAllocHW, PAllocBW, NewAllocBW, PPlacement, NewPlacement),
    assert(deployment(A, NewPlacement, NewAllocHW, NewAllocBW)).

partialPlacement([],_,[]).
partialPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), partialPlacement(P,Services,PPlacement).
partialPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), partialPlacement(P,Services,PPlacement).
 
freeHWAllocation([], [], _).
freeHWAllocation([(N,AllocHW)|L], NewL, ServicesToMigrate) :-
    sumNodeHWToFree(N, ServicesToMigrate, HWToFree),
    NewAllocHW is AllocHW - HWToFree, 
    freeHWAllocation(L, TempL, ServicesToMigrate),
    assemble((N,NewAllocHW), TempL, NewL).

sumNodeHWToFree(_, [], 0).
sumNodeHWToFree(N, [(_,N,H)|STMs], Tot) :- sumNodeHWToFree(N, STMs, HH), Tot is H+HH.
sumNodeHWToFree(N, [(_,N1,_)|STMs], H) :- N \== N1, sumNodeHWToFree(N, STMs, H).
 
assemble((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assemble((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.
 
freeBWAllocation([],[],_,_).
freeBWAllocation([(N1,N2,AllocBW)|L], NewL, ServicesToMigrate, Placement) :-
   findall(BW, toFree(N1,N2,BW,ServicesToMigrate,Placement), BWs),
   sumLinkBWToFree(BWs,V), NewAllocBW is AllocBW-V,
   freeBWAllocation(L, TempL, ServicesToMigrate, Placement),
   assemble2((N1,N2,NewAllocBW), TempL, NewL).

toFree(N1,N2,B,Services,_) :- 
    member((S1,N1,_),Services), 
    s2s(S1,S2,_,B), member((S2,N2,_),Services). 
toFree(N1,N2,B,Services,P) :- 
    member((S1,N1,_),Services), s2s(S1,S2,_,B), 
    \+member((S2,N2,_),Services), member(on(S2,N2),P). 
toFree(N1,N2,B,Services,P) :- 
    member(on(S1,N1),P), 
    \+member((S1,N1,_),Services), s2s(S1,S2,_,B), member((S2,N2,_),Services).
 
sumLinkBWToFree([],0).
sumLinkBWToFree([B|Bs],V) :- sumLinkBWToFree(Bs,TempV), V is B+TempV.

assemble2((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assemble2((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.
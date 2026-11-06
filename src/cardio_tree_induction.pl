% Carica il dataset e gli attributi
:- ensure_loaded(training_set).
:- ensure_loaded(test_set).
:- ensure_loaded(cardio_attributi).

:- dynamic alb/1. % Dichiarazione dinamica per memorizzare l'albero

induce_albero(Albero) :-
    findall(e(Classe,Oggetto),train(Classe,Oggetto),Esempi),
    findall(Att,a(Att,_),Attributi),
    induce_albero(Attributi,Esempi,Albero),
    assert(alb(Albero)),
    salva_albero(Albero, 'albero_decisionale_gini.txt'). % Salva l'albero nel file

% Salva l'albero decisionale in un file
salva_albero(Albero, File) :-
    open(File, write, Stream),
    scrivi_albero(Stream, Albero, 0),
    close(Stream).

% Scrive l'albero in modo leggibile nel file
scrivi_albero(Stream, null, _) :-
    writeln(Stream, ' ==> ???').
scrivi_albero(Stream, l(X), _) :-
    write(Stream, ' ==> '), writeln(Stream, X).
scrivi_albero(Stream, t(A, L), I) :-
    nl(Stream), tab(Stream, I), write(Stream, A), nl(Stream),
    I1 is I + 2,
    scrivi_sottoalberi(Stream, L, I1).

scrivi_sottoalberi(_, [], _).
scrivi_sottoalberi(Stream, [V:T|C], I) :-
    tab(Stream, I), write(Stream, V),
    scrivi_albero(Stream, T, I),
    scrivi_sottoalberi(Stream, C, I).


%induce_albero(Attributi,Esempi,Albero):
%la forma dell'albero indotto dipende da questi tre casi:
%(1) Albero = null: l'insieme degli esempi è vuoto
%(2) Albero = l(Classe): tutti gli esempi sono della stessa classe
%(3) Albero = t(Attributo, [Val1:SubAlb1, Val2:SubAlb2, ...]):
% gli esempi appartengono a più di una classe
% Attributo è la radice dell'albero
% Val1, Val2, ... sono i possibili valori di Attributo
% SubAlb1, SubAlb2,... sono i corrispondenti sottoalberi di decisione.
%
induce_albero(_,[],null) :- !. %(1)
induce_albero(_,[e(Classe,_)|Esempi],l(Classe)) :- %(2)
    \+ (member(e(ClassX,_),Esempi), %non ci sono esempi
             ClassX \== Classe),!.         % di classi diverse
induce_albero(Attributi,Esempi,t(Attributo,SAlberi)) :-   %(3)
    sceglie_attributo(Attributi,Esempi,Attributo), !,
    del(Attributo,Attributi,Rimanenti),           % elimina Attributo
    a(Attributo,Valori),
    induce_alberi(Attributo,Valori,Rimanenti,Esempi,SAlberi).
induce_albero(_,Esempi,l(ClassePredominante)) :- %no attributi utili
    findall(Classe,member(e(Classe,_),Esempi),Classi),
    frequenza_maggiore(Classi, ClassePredominante).

frequenza_maggiore(Classi, ClassePredominante) :-
    msort(Classi, ClassiOrdinati),      % Ordina le classi
    clumped(ClassiOrdinati, Frequenze), % Conta le occorrenze
    sort(Frequenze, FrequenzeOrdinate),
    reverse(FrequenzeOrdinate, [Freq1-Cl1, Freq2-Cl2 | _]),
        (Freq1 == Freq2 -> random_class([Cl1, Cl2], ClassePredominante);
        ClassePredominante = Cl1).

clumped([], []).
clumped([X|Xs], [Freq-X|Ys]) :-
    include(=(X), Xs, Xs1), % Conta gli elementi uguali a X
    length(Xs1, N),
    Freq is N + 1,
    exclude(=(X), Xs, XsRestanti),
    clumped(XsRestanti, Ys).

random_class([C1, C2], ClassePredominante) :-
    random_member(ClassePredominante, [C1, C2]).


% sceglie_attributo(Attributi, Esempi, MigliorAttributo): seleziona
% l'Attributo che meglio
% discrimina le classi; si basa sul concetto di "disuguaglianza";
% utilizza il setof per
%ordinare gli attributi in base al valore crescente della disuguaglianza
sceglie_attributo(Attributi, Esempi, MigliorAttributo) :-
    setof(Dis/A,(member(A,Attributi),disuguaglianza(Esempi,A,Dis)),
                                                [MinDis/MigliorAttributo|_]).

% disuguaglianza(Esempi, Attributo, Dis): Dis è la disuguaglianza
% combinata dei sottoinsiemi
%degli esempi partizionati dai valori dell'Attributo
disuguaglianza(Esempi,Attributo,Dis) :-
    a(Attributo,AttVals),
    somma_pesata(Esempi,Attributo,AttVals,0,Dis).

% somma_pesata(Esempi,Attributo,AttVals,SommaParziale,Somma): somma
% pesata delle disuguaglianze Gini = sum from{v} P(v) * sum from{i <> j}
% P(i|v)*P(j|v)
somma_pesata(_,_,[],Somma,Somma).
somma_pesata(Esempi,Att,[Val|Valori],SommaParziale,Somma) :-
    length(Esempi,N),             % quanti sono gli esempi
    findall(C,(member(e(C,Desc),Esempi),soddisfa(Desc,[Att=Val])),EsClassi),
     %EsClassi = lista delle classi (con ripetizioni) di tutti gli esempi per cui Att=Val
    length(EsClassi,NVal),NVal > 0, !,
    findall(P,(bagof(1,member(_,EsClassi),L),length(L,NVC),P is NVC/NVal),ClDst),
    gini(ClDst,Gini),
    NuovaSommaParziale is SommaParziale + Gini*NVal/N,
    somma_pesata(Esempi,Att,Valori,NuovaSommaParziale,Somma);
    somma_pesata(Esempi,Att,Valori,SommaParziale,Somma). %nessun esempio sodd

% gini(ListaProbabilità, IndiceGini): IndiceGini = SOMMATORIA Pi*Pj per
% tutti i,j tali per cui i\=j. E' equivalente a 1 - SOMMATORIA Pi*Pi su
% tutti gli i
gini(ListaProbabilità,Gini) :-
    somma_quadrati(ListaProbabilità,0,SommaQuadrati),
    Gini is 1-SommaQuadrati.
somma_quadrati([],S,S).
somma_quadrati([P|Ps],PartS,S) :-
    NewPartS is PartS + P*P,
    somma_quadrati(Ps,NewPartS,S).

% induce_alberi(Attributi, Valori, AttRimasti, Esempi, Salberi): induce
% decisioni SAlberi per sottoinsiemi di Esempi secondo i Valori degli
% Attributi
induce_alberi(_,[],_,_,[]).% nessun valore, nessun sottoalbero
induce_alberi(Att,[Val1|Valori],AttRimasti,Esempi,[Val1:Alb1|Alberi]) :-
    attval_subset(Att=Val1,Esempi,SottoinsiemeEsempi),
    induce_albero(AttRimasti,SottoinsiemeEsempi,Alb1),
    induce_alberi(Att,Valori,AttRimasti,Esempi,Alberi).

% attval_subset( Attributo = Valore, Esempi, Subset): Subset è il
% sottoinsieme di Examples che soddisfa la condizione Attributo = Valore
attval_subset(AttributoValore,Esempi,Sottoinsieme) :-
    findall(e(C,O),(member(e(C,O),Esempi),soddisfa(O,[AttributoValore])),Sottoinsieme).

soddisfa(Oggetto,Descrizione) :-
    \+ (member(Att=Val,Descrizione),
        member(Att=ValX,Oggetto),
        ValX \== Val).

del(T,[T|C],C) :- !.
del(A,[T|C],[T|C1]) :-
	del(A,C,C1).


% Sceglie l'attributo con Information Gain massimo
sceglie_attributo_IG(Attributi, Esempi, MigliorAttributo) :-
    setof(IG/A, (member(A, Attributi), guadagno_informazione(Esempi, A, IG)),
          [_MaxIG/MigliorAttributo|_]).

% Calcola il guadagno di informazione
guadagno_informazione(Esempi, Attributo, IG) :-
    entropia(Esempi, H_S),
    a(Attributo, AttVals),
    somma_pesata_entropia(Esempi, Attributo, AttVals, 0, H_Sv),
    IG is H_S - H_Sv.

% Calcola l'entropia di un insieme di esempi
entropia(Esempi, Entropia) :-
    findall(Classe, member(e(Classe,_), Esempi), Classi),
    length(Esempi, N),
    findall(P, (bagof(1, member(_, Classi), L), length(L, N_C), P is N_C/N), Probs),
    somma_entropia(Probs, 0, Entropia).

somma_entropia([], S, S).
somma_entropia([P|Ps], S0, S) :-
    (P =:= 0 -> S1 is S0; S1 is S0 - P * log(P) / log(2)),
    somma_entropia(Ps, S1, S).

% Somma pesata delle entropie
somma_pesata_entropia(_, _, [], Somma, Somma).
somma_pesata_entropia(Esempi, Att, [Val|Valori], SommaParziale, Somma) :-
    length(Esempi, N),
    findall(C, (member(e(C, Desc), Esempi), soddisfa(Desc, [Att=Val])), EsempiSoddisfatti),
    length(EsempiSoddisfatti, NVal),
    (NVal > 0 ->
        entropia(EsempiSoddisfatti, H_Sv),
        NuovaSommaParziale is SommaParziale + (NVal/N) * H_Sv
    ;
        NuovaSommaParziale is SommaParziale
    ),
    somma_pesata_entropia(Esempi, Att, Valori, NuovaSommaParziale, Somma).



% Classificazione degli oggetti
classifica(Oggetto,nc,t(Att,Valori)) :-
    member(Att=Val,Oggetto),
    member(Val:null,Valori).

classifica(Oggetto,Classe,t(Att,Valori)) :-
    member(Att=Val,Oggetto),
    member(Val:l(Classe),Valori).

classifica(Oggetto,Classe,t(Att,Valori)) :-
    member(Att=Val,Oggetto),
    delete(Oggetto,Att=Val,Resto),
    member(Val:t(AttFiglio,ValoriFiglio),Valori),
    classifica(Resto,Classe,t(AttFiglio,ValoriFiglio)).

% Matrice di confusione e metriche
stampa_matrice_di_confusione :-
    alb(Albero),
    findall(Classe/Oggetto, test(Classe, Oggetto), TestSet),
    length(TestSet, N),
    valuta(Albero, TestSet, VN, 0, VP, 0, FN, 0, FP, 0, NC, 0),
    A is (VP + VN) / (N - NC), % Accuratezza
    E is 1 - A,                % Errore
    writeln('===== Matrice di Confusione ====='),
    write('Test effettuati: '), writeln(N),
    write('Test non classificati: '), writeln(NC),
    write('Veri Negativi: '), write(VN), write('   Falsi Positivi: '), writeln(FP),
    write('Falsi Negativi: '), write(FN), write('   Veri Positivi: '), writeln(VP),
    write('Accuratezza: '), writeln(A),
    write('Errore: '), writeln(E).

% Valutazione del test set
valuta(_,[],VN,VN,VP,VP,FN,FN,FP,FP,NC,NC).

valuta(Albero,[no_disease/Oggetto|Coda],VN,VNA,VP,VPA,FN,FNA,FP,FPA,NC,NCA) :-
    classifica(Oggetto,no_disease,Albero), !,
    VNA1 is VNA + 1,
    valuta(Albero,Coda,VN,VNA1,VP,VPA,FN,FNA,FP,FPA,NC,NCA).

valuta(Albero,[has_disease/Oggetto|Coda],VN,VNA,VP,VPA,FN,FNA,FP,FPA,NC,NCA) :-
    classifica(Oggetto,has_disease,Albero), !,
    VPA1 is VPA + 1,
    valuta(Albero,Coda,VN,VNA,VP,VPA1,FN,FNA,FP,FPA,NC,NCA).

valuta(Albero,[has_disease/Oggetto|Coda],VN,VNA,VP,VPA,FN,FNA,FP,FPA,NC,NCA) :-
    classifica(Oggetto,no_disease,Albero), !,
    FNA1 is FNA + 1,
    valuta(Albero,Coda,VN,VNA,VP,VPA,FN,FNA1,FP,FPA,NC,NCA).

valuta(Albero,[no_disease/Oggetto|Coda],VN,VNA,VP,VPA,FN,FNA,FP,FPA,NC,NCA) :-
    classifica(Oggetto,has_disease,Albero), !,
    FPA1 is FPA + 1,
    valuta(Albero,Coda,VN,VNA,VP,VPA,FN,FNA,FP,FPA1,NC,NCA).

valuta(Albero,[_/Oggetto|Coda],VN,VNA,VP,VPA,FN,FNA,FP,FPA,NC,NCA) :-
    classifica(Oggetto,nc,Albero), !,
    NCA1 is NCA + 1,
    valuta(Albero,Coda,VN,VNA,VP,VPA,FN,FNA,FP,FPA,NC,NCA1).

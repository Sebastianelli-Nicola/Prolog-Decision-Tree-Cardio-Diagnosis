:- dynamic e/2. % Dichiarazione del fatto

/*
balanced_split_dataset('cardio_dataset.pl','training_set.pl','test_set.pl', 0.7).
*/

% Predicato principale per dividere il dataset bilanciato
balanced_split_dataset(File, TrainingFile, TestFile, TrainRatio) :-
    consult(File),  % Carica il dataset
    % Separa i fatti in due gruppi
    findall(e(has_disease, Attributes), e(has_disease, Attributes), HasDiseaseFacts),
    findall(e(no_disease, Attributes), e(no_disease, Attributes), NoDiseaseFacts),
    % Determina il numero massimo di fatti bilanciati
    length(HasDiseaseFacts, HasDiseaseCount),
    length(NoDiseaseFacts, NoDiseaseCount),
    MinCount is min(HasDiseaseCount, NoDiseaseCount),
    % Prendi il numero bilanciato di fatti da ogni gruppo
    random_permutation(HasDiseaseFacts, ShuffledHasDisease),
    random_permutation(NoDiseaseFacts, ShuffledNoDisease),
    take(MinCount, ShuffledHasDisease, BalancedHasDisease),
    take(MinCount, ShuffledNoDisease, BalancedNoDisease),
    % Combina e mescola i fatti bilanciati
    append(BalancedHasDisease, BalancedNoDisease, AllBalancedFacts),
    random_permutation(AllBalancedFacts, ShuffledBalancedFacts),
    % Dividi in training e test set
    length(ShuffledBalancedFacts, Total),
    TrainCount is round(Total * TrainRatio),
    split_at(TrainCount, ShuffledBalancedFacts, TrainingSet, TestSet),
    % Trasforma i fatti con i predicati appropriati
    maplist(to_train_fact, TrainingSet, TrainingFacts),
    maplist(to_test_fact, TestSet, TestFacts),
    % Salva nei file
    save_facts(TrainingFile, TrainingFacts),
    save_facts(TestFile, TestFacts).

% Converte un fatto in un predicato train
to_train_fact(e(Class, Attributes), train(Class, Attributes)).

% Converte un fatto in un predicato test
to_test_fact(e(Class, Attributes), test(Class, Attributes)).

% Divide una lista in due parti alla posizione N
split_at(0, List, [], List).
split_at(N, [H|T], [H|Left], Right) :-
    N > 0,
    N1 is N - 1,
    split_at(N1, T, Left, Right).

% Prende i primi N elementi da una lista
take(0, _, []) :- !.
take(_, [], []) :- !.
take(N, [H|T], [H|R]) :-
    N > 0,
    N1 is N - 1,
    take(N1, T, R).

% Salva una lista di fatti in un file
save_facts(File, Facts) :-
    open(File, write, Stream),
    forall(member(Fact, Facts),
           (write(Stream, Fact), write(Stream, '.'), nl(Stream))),
    close(Stream).


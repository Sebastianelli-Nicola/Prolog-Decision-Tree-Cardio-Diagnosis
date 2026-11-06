:- ensure_loaded(database_cardio_elaborato). % Carica il database

start :-
    tell('Progetto_AI_malattie_cardiovascolari/cardio_dataset_prova.pl'),
    % Creazione dei predicati `a` per gli attributi
    setof(Age, A^B^C^D^E^F^G^H^I^L^aa(Age,A,B,C,D,E,F,G,H,I,L), AttributiAge),
    write('a(age,'), writeq(AttributiAge), writeln(').'),
    setof(Gender, A^B^C^D^E^F^G^H^I^L^aa(A,Gender,B,C,D,E,F,G,H,I,L), AttributiGender),
    write('a(gender,'), writeq(AttributiGender), writeln(').'),
    setof(BMI, A^B^C^D^E^F^G^H^I^L^aa(A,B,BMI,C,D,E,F,G,H,I,L), AttributiBMI),
    write('a(bmi,'), writeq(AttributiBMI), writeln(').'),
    setof(SystolicBP, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,SystolicBP,D,E,F,G,H,I,L), AttributiSystolicBP),
    write('a(systolic_bp,'), writeq(AttributiSystolicBP), writeln(').'),
    setof(DiastolicBP, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,DiastolicBP,E,F,G,H,I,L), AttributiDiastolicBP),
    write('a(diastolic_bp,'), writeq(AttributiDiastolicBP), writeln(').'),
    setof(Cholesterol, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,E,Cholesterol,F,G,H,I,L), AttributiCholesterol),
    write('a(cholesterol,'), writeq(AttributiCholesterol), writeln(').'),
    setof(Glucose, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,E,F,Glucose,G,H,I,L), AttributiGlucose),
    write('a(glucose,'), writeq(AttributiGlucose), writeln(').'),
    setof(Smoking, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,E,F,G,Smoking,H,I,L), AttributiSmoking),
    write('a(smoking,'), writeq(AttributiSmoking), writeln(').'),
    setof(Alcohol, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,E,F,G,H,Alcohol,I,L), AttributiAlcohol),
    write('a(alcohol,'), writeq(AttributiAlcohol), writeln(').'),
    setof(PhysicalActivity, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,E,F,G,H,I,PhysicalActivity,L), AttributiPhysicalActivity),
    write('a(physical_activity,'), writeq(AttributiPhysicalActivity), writeln(').'),
    setof(CardiovascularDisease, A^B^C^D^E^F^G^H^I^L^aa(A,B,C,D,E,F,G,H,I,L,CardiovascularDisease), AttributiDisease),
    write('a(cardiovascular_disease,'), writeq(AttributiDisease), writeln(').'),
    % Generazione degli esempi
    generate_examples.

generate_examples :-
    aa(Age, Gender, BMI, SystolicBP, DiastolicBP, Cholesterol, Glucose, Smoking, Alcohol, PhysicalActivity, CardiovascularDisease),
    (   % Valutazione della condizione
        CardiovascularDisease = 1
    ->  Target = 'has_disease'
    ;   Target = 'no_disease'
    ),
    write('e('), write(Target), write(',['),
    write('age = '), writeq(Age), write(', '),
    write('gender = '), writeq(Gender), write(', '),
    write('bmi = '), writeq(BMI), write(', '),
    write('systolic_bp = '), writeq(SystolicBP), write(', '),
    write('diastolic_bp = '), writeq(DiastolicBP), write(', '),
    write('cholesterol = '), writeq(Cholesterol), write(', '),
    write('glucose = '), writeq(Glucose), write(', '),
    write('smoking = '), writeq(Smoking), write(', '),
    write('alcohol = '), writeq(Alcohol), write(', '),
    write('physical_activity = '), writeq(PhysicalActivity), write(']).'), nl,
    fail.
generate_examples :- told.



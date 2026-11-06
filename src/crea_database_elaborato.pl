:- use_module(library(readutil)). % Per leggere i file

% Per creare il database elaborato
% process_file('$path_contenente_database_espresso_in_fatti','$path_nuovo_database_elaborato').

/*
Data description
There are 3 types of input features:

Objective: factual information;
Examination: results of medical examination;
Subjective: information given by the patient.
Features:

Age | Objective Feature | age | int (days)
Gender | Objective Feature | gender | categorical code |
Height | Objective Feature | height | int (cm) |
Weight | Objective Feature | weight | float (kg) |
Systolic blood pressure | Examination Feature | ap_hi | int |
Diastolic blood pressure | Examination Feature | ap_lo | int |
Cholesterol | Examination Feature | cholesterol | 1: normal, 2: above normal, 3: well above normal |
Glucose | Examination Feature | gluc | 1: normal, 2: above normal, 3: well above normal |
Smoking | Subjective Feature | smoke | binary |
Alcohol intake | Subjective Feature | alco | binary |
Physical activity | Subjective Feature | active | binary |
Presence or absence of cardiovascular disease | Target Variable | cardio | binary |

All of the dataset values were collected at the moment of medical examination.

aa(Age, Gender, Height, Weight, Systolic blood pressure, Diastolic blood pressure, Cholesterol, Glucose, Smoking, Alcohol intake, Physical activity , Presence or absence of cardiovascular disease).
*/


% Predicato principale per elaborare il file
process_file(InputFile, OutputFile) :-
    open(InputFile, read, InStream),
    open(OutputFile, write, OutStream),
     % Aggiunge il commento come prima riga
    writeln(OutStream, '% aa(Age, Gender, BMI, Systolic blood pressure, Diastolic blood pressure, Cholesterol, Glucose, Smoking, Alcohol intake, Physical activity, Presence or absence of cardiovascular disease)'),
    process_lines(InStream, OutStream),
    close(InStream),
    close(OutStream).

% Processa ogni riga del file di input
process_lines(InStream, OutStream) :-
    read_line_to_string(InStream, Line),
    (   Line \= end_of_file
    ->  (   process_fact(Line, ProcessedLine)
        ->  writeln(OutStream, ProcessedLine)
        ;   true  % Salta il fatto non valido
        ),
        process_lines(InStream, OutStream)
    ;   true).

% Elabora una singola riga (fatto)
process_fact(Line, ProcessedFact) :-
    % Rimuovi spazi e punto finale
    normalize_space(string(CleanLine), Line),

     % Rimuovi la parentesi di apertura '(' e la parentesi di chiusura ')'
    sub_string(CleanLine, 1, _, 0, ValuesString),  % Rimuove la prima parentesi '('
    sub_string(ValuesString, 0, _, 1, Rest),     % Rimuove la parentesi finale ')'

    % Divide i valori separati da ";"
    split_string(Rest, ";", "", Values),
    process_values(Values, ProcessedValues),

    % Filtra i valori
    (   filter_values(ProcessedValues)
    ->  % Se validi, crea il fatto

        % Concatenare i valori senza parentesi extra
        atomic_list_concat(ProcessedValues, ', ', ProcessedFactValues),

         % Formatto correttamente il fatto senza parentesi extra
        string_concat('aa(', ProcessedFactValues, TempFact),
        string_concat(TempFact, '.', ProcessedFact)

    ;   % Se non validi, non crea alcun fatto
        fail
    ).


% Elaboro i valori individuali del fatto, aggiungendo il BMI e rimuovendo altezza e peso
process_values([_ | [DaysStr, GenderStr, HeightStr, WeightStr, SystolicBPStr, DiastolicBPStr | Rest]], [Years, Gender, BMIClass, SystolicBP, DiastolicBP | Rest]) :-
    % Trasforma i giorni in anni arrotondati
    number_string(Days, DaysStr),
    YearsFloat is Days / 365.0,
    round_custom(YearsFloat, Years),
    classify_age_range(Years, AgeRange), % Classifica l'età in fasce

    % Escludi valori fuori dalle fasce (ad esempio, età 30)
    AgeRange \= 'invalid',

    % Converte Gender
    number_string(GenderNum, GenderStr),
    (   GenderNum =:= 1 -> Gender = 'female'
    ;   GenderNum =:= 2 -> Gender = 'male'),

    % Trasforma altezza e peso in numeri
    number_string(Height, HeightStr),
    number_string(Weight, WeightStr),

    % Converte pressione sanguigna in numeri
    number_string(SystolicBP, SystolicBPStr),
    number_string(DiastolicBP, DiastolicBPStr),

    % Controlla che altezza e peso siano validi
    valid_height_weight(Height, Weight),

    % Controlla che pressione sistolica e pressione diastolica siano valide
    valid_blood_pressure(SystolicBP, DiastolicBP),

    % Calcola il BMI
    HeightMeters is Height / 100.0,
    BMI is Weight / (HeightMeters * HeightMeters),

    % Classifica il BMI
    classify_bmi(BMI, BMIClass).

% Classifica l'età in fasce predefinite
classify_age_range(Age, '39-44') :- Age >= 39, Age =< 44.
classify_age_range(Age, '45-49') :- Age >= 45, Age =< 49.
classify_age_range(Age, '50-54') :- Age >= 50, Age =< 54.
classify_age_range(Age, '55-59') :- Age >= 55, Age =< 59.
classify_age_range(Age, '60-64') :- Age >= 60, Age =< 64.
classify_age_range(_, 'invalid'). % Valori fuori range

% Classifica il BMI in categorie
classify_bmi(BMI, 'underweight') :- BMI < 18.5.
classify_bmi(BMI, 'normalweight') :- BMI >= 18.5, BMI < 25.
classify_bmi(BMI, 'overweight') :- BMI >= 25, BMI < 30.
classify_bmi(BMI, 'obesity') :- BMI >= 30.


% Controlla se i valori sono validi
filter_values([AgeRange, _, _, _, _, _, _, _, _, _, _]) :-
    % Filtro sull'età
    AgeRange \= 'invalid'.

% Arrotondamento
round_custom(Value, Rounded) :-
    Fraction is Value - floor(Value),
    (   Fraction =< 0.5
    ->  Rounded is floor(Value)
    ;   Rounded is ceil(Value)).

% Controlla che altezza e peso siano validi
valid_height_weight(Height, Weight) :-
    % Altezza in cm tra 100 e 200
    Height >= 140, Height =< 200,
    % Peso in kg tra 20 e 250
    Weight >= 40, Weight =< 250.

% Controlla che pressione sistolica e pressione diastolica siano valide
valid_blood_pressure(SystolicBP, DiastolicBP):-
    % Filtro sulla pressione sistolica
    SystolicBP >= 60, SystolicBP =< 250,
    % Filtro sulla pressione diastolica
    DiastolicBP >= 40, DiastolicBP =< 150.



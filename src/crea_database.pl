:- use_module(library(csv)).

% convert_csv_to_prolog(path_csv,path_output)

% Predicato principale per la conversione
convert_csv_to_prolog(InputCSV, OutputProlog) :-
    setup_call_cleanup(
        open(InputCSV, read, InStream),
        setup_call_cleanup(
            open(OutputProlog, write, OutStream),
            (
                % Leggi e processa ogni riga del CSV
                read_csv(InStream, [_ | Rest]), % Ignora la prima riga
                write_facts(Rest, OutStream)
            ),
            close(OutStream)
        ),
        close(InStream)
    ).

% Lettura delle righe del CSV
read_csv(InStream, Rows) :-
    csv_read_stream(InStream, Rows, [separator(0';)]). % Usa ";" come separatore

% Scrittura dei fatti Prolog nel file di output
write_facts([], _).
write_facts([Row | Rest], OutStream) :-
    Row =.. [row | Values], % Estrai i valori da ciascuna riga
    atomic_list_concat(Values, ';', FactValues), % Concatena i valori separati da ";"
    format(OutStream, 'aa(~w).~n', [FactValues]), % Scrivi il fatto nel formato richiesto
    write_facts(Rest, OutStream). % Ricorsione per le righe successive

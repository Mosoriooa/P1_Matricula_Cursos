curso(globalizacion, 1, 3, [lunes, 7, 9], []).
curso(lenguajeI, 1, 4, [lunes, 9, 11], []).
curso(metodologia, 1, 3, [martes, 7, 9], []).
curso(desarrollo, 1, 3, [miercoles, 7, 9], []).
curso(matematica, 1, 5, [miercoles, 11, 13], []).
curso(etica, 1, 2, [viernes, 11, 13], []).

curso(economia, 2, 3, [lunes, 7, 9], []).
curso(lenguajeII, 2, 3, [martes, 7, 9], [lenguajeI]).
curso(sociologia, 2, 3, [miercoles, 9, 11], []).
curso(filosofia, 2, 3, [lunes, 9, 11], []).
curso(algebra, 2, 3, [martes, 9, 11], [matematica]).
curso(calculoI, 2, 5, [miercoles, 11, 13], [matematica]).

curso(calculoII, 3, 5, [viernes, 12, 14], [algebra, calculoI]).

alumno(matias, [globalizacion, lenguajeI, metodologia, matematica, etica, economia, sociologia]).

cursosMatricula(matias,[]).

cursoAprobado(Curso, [Curso|_]).
cursoAprobado(Curso,[_|Cola]):-
    cursoAprobado(Curso,Cola).

cicloActual(Alumno, Ciclo):-
    alumno(Alumno, CursosAprobados),
    curso(Curso,Ciclo,_,_,_),
    \+ (cursoAprobado(Curso,CursosAprobados)),!.

todos_en([], _, []).
todos_en([X|Resto], ListaGrande, Falta) :-
    cursoAprobado(X, ListaGrande),
    todos_en(Resto, ListaGrande, Falta).  

todos_en([X|Resto], ListaGrande, [X|Falta]) :-
    \+ cursoAprobado(X, ListaGrande),
    todos_en(Resto, ListaGrande, Falta).

%validarPreReq(matias,calculoI).

validarPreReq(Alumno, Curso, Falta):-
    alumno(Alumno, CursosAprobados),
    curso(Curso,_,_,_, Prerequisitos),
    todos_en(Prerequisitos, CursosAprobados, Falta).

sumaCreditos([],0).
sumaCreditos([X|Resto], Total):-
    curso(X,_,Credito,_,_),
    sumaCreditos(Resto, SumaResto),
    Total is Credito + SumaResto.

seSolapan(Curso1, Curso2):-
    curso(Curso1,_,_,Horario1,_),
    curso(Curso2,_,_,Horario2,_),
    seSolapanHorario(Horario1, Horario2).

seSolapanHorario([Dia, Inicio1, Fin1],[Dia, Inicio2, Fin2]):-
    (Inicio1 < Fin2, Inicio2 < Fin1).

revisarHorario(_, []) :- 
    true.

revisarHorario(Curso, [_|Resto]):-
    revisarHorario(Curso,Resto).

revisarHorario(Curso, [X|Resto]):-
    seSolapan(Curso, X),!,
    %format('El curso ~w se solapa con ~w.~n', [Curso, X]),
    revisarHorario(Curso,Resto).
    
verificarSolapamiento(Curso, Lista) :-
    ( revisarHorario(Curso, Lista) ->
        true
    ; 
        false
    ).


inscribirCurso(Alumno,Curso):-
    alumno(Alumno, CursosAprobados),
    cicloActual(Alumno, CicloActual),
    curso(Curso,CicloCurso, Creditos, _, Prerequisitos),

    validarPreReq(Alumno, Curso, FaltaPreReqs),
    FaltaPreReqs == [],

    (CicloCurso =< CicloActual + 2, CicloCurso >= CicloActual - 2),

    cursosMatricula(Alumno, CursosMatriculados),
    sumaCreditos(CursosMatriculados, Total),
    Total + Creditos =< 27,

    \+revisarHorario(Curso, CursosMatriculados),

    cursosMatricula(Alumno,[Curso|CursosMatriculados]).


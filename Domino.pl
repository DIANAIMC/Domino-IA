:- dynamic ficha/1.
:- dynamic pozo/1.
:- dynamic oponente/1.
:- dynamic jugador/1.
:- dynamic bandera_jugador/1.
:- dynamic bandera_oponente/1.
:- dynamic mesa/1.
pozo(14).
oponente(7).
jugador(7).
bandera_jugador(falso).
bandera_oponente(falso).



% --REGLAS QUE FORMAN PARTE DE LA INTERFAZ--

/*
 * Regla que permite conocer al usuario toda su reserva.
 */

escribe_fichas:-
 	ficha(X),
 	X\==ya,
 	write(X),
 	nl,
 	fail.
escribe_fichas.

/*
 * 'disminuye_reserva_jugador' y 'disminuye_reserva_oponente' disminuyen los contadores de las
 * reservas del jugador y el oponente respectivamente. Se usan en cada tiro de los jugadores.
 */

disminuye_reserva_jugador:-
	jugador(Z),
	retractall(jugador),
	W is Z-1,
	asserta(jugador(W)).

disminuye_reserva_oponente:-
	oponente(Z),
	retractall(oponente),
	W is Z-1,
	asserta(oponente(W)).

/*
 * 'aumenta_reserva_jugador' y 'aumenta_reserva_oponente' aumentan los contadores de las
 * reservas del jugador y el oponente respectivamente. Se usan cada que los jugadores tienen que comer.
 */

aumenta_reserva_jugador(N):-
	jugador(Z),
	retractall(jugador),
	W is N+Z,
	asserta(jugador(W)).

aumenta_reserva_oponente(N):-
	oponente(Z),
	retractall(oponente),
	W is N+Z,
	asserta(oponente(W)).

/*
 * Regla que disminuye el contador del pozo. Se usa cada que los jugadores tienen que comer.
 */

disminuye_pozo(A):-
	pozo(X),
	retractall(pozo),
	Y is X-A,
	asserta(pozo(Y)).

/*
 * Tanto 'sube_bandera_jugador', 'sube_bandera_oponente' y 'bajan_banderas' sirven para poder
 * calcular cuándo el juego está cerrado. Las primeras dos reglas activan bandera_jugador y bandera_oponente
 * respectivamente, lo que permite en la regla 'continua_partida' determinar si el juego se cerró y
 * entonces la partida quedaría en un empate.
 */

sube_bandera_jugador:-
	retractall(bandera_jugador),
	asserta(bandera_jugador(verdadero)).

sube_bandera_oponente:-
	retractall(bandera_oponente),
	asserta(bandera_oponente(verdadero)).

bajan_banderas:-
	retractall(bandera_jugador),
	asserta(bandera_jugador(falso)),
	retractall(bandera_oponente),
	asserta(bandera_oponente(falso)).

/*
 * Esta regla va ingresar todas las fichas que el jugador haya tenido que comer, a su vez que
 * actualizar los contadores del pozo y la reserva del jugador.
 */

come_fichas:-
	writeln("¿Cuántas comiste en total?"),
	writeln("[Ingresa un valor númerico]"),
	read(X),
	disminuye_pozo(X),
	aumenta_reserva_jugador(X),
	write("Dame los valores de las fichas obtenidas una a una de la forma [a,b]"),
	writeln(", escribe 'ya' cuando quieras terminar."),
	repeat,
	read(Ficha),
	asserta(ficha(Ficha)),
	Ficha==ya.

/*
 * Se ingresan la cantidad de fichas que tuvo que comer el oponente para poder actualizar
 * su reserva y la del pozo.
 */
 
oponente_come:-
	writeln("¿Cuántas fichas comió?"),
	writeln("[Ingresa un valor númerico]"),
	read(N),
	aumenta_reserva_oponente(N),
	disminuye_pozo(N),
	writeln("¿Encontró ficha?"),
	writeln("[si]"),
	writeln("[no]"),
	read(X),
	X == si,
	writeln("Ingrese la ficha"),
	read(Y),
	asserta(mesa(Y)).
oponente_come:-
	writeln("Pasa").

/*
 * Esta regla sirve cuando el jugador no puede cumplir con la necesidad, por lo que
 * tiene que informar al programa si comió o pasó.
 */


come_durante_partida:-
	writeln("¿Comiste o pasaste?"),
	writeln("[comí]"),
	writeln("[pasé]"),
	read(Y),
	Y == pasé,
	sube_bandera_jugador.
come_durante_partida:-
	come_fichas,
	fin_jugada_despues_de_comer.

/*
 * La ficha tirada en la jugada se elimina de la reserva y se actualiza el contador de la reserva.
 */

fin_jugada:-
	writeln("¿Cuál ficha tiraste?"),
	read(Ficha),
	retract(ficha(Ficha)),
	asserta(mesa(Ficha)),
	disminuye_reserva_jugador.

/*
 * Caso especial: esta regla se usa después de que el jugador tuvo que comer. Tiene la misma
 * función que 'fin_jugada', pero con la variante en la que el jugador no encontró en el pozo
 * una ficha que satisfaga la necesidad y tenga que pasar.
 */

fin_jugada_despues_de_comer:-
	writeln("¿Encontraste una ficha que satisfaga la necesidad?"),
	writeln("[si]"),
	writeln("[no]"),
	read(X),
	X == si,
	fin_jugada.
fin_jugada_despues_de_comer:-
	sube_bandera_jugador.

/*
 * Es la regla que determina hasta dónde va a continuar la partida. La partida termina cuando
 * alguno de los jugadores se quede sin ficha o los dos jugadores hayan pasado consecutivamente,
 * lo que significa que el juego está cerrado.
 */

fin_partida:-
	jugador(X),
	oponente(Y),
	bandera_jugador(Z),
	bandera_oponente(W),
	( X =:= 0 -> writeln("Juego ganado.")
    	;( Y =:= 0 -> writeln("Juego perdido.")
        	; ( Z == verdadero, W == verdadero -> writeln("Empate, juego cerrado.")
          	; (writeln("La partida continua"), bajan_banderas, juego)
          	)
     	)
	).

/*
 *  En 'inicia_partida' se comienza un juego nuevo una vez que el usuario lo indica, por lo
 *  que se restablecen los valores predeterminados como: pozo, jugador, oponente, ficha, resto_ficha,
 *  mesa y banderas, lo anterior lo hace con ayuda de la regla 'reinicia juego'.
 */

inicia_partida:-
	write("Si quieres comenzar una nueva partida responde 'si'"),
	writeln(", escribe cualquier otra cosa si no deseas continuar."),
	read(X),
	X==si,
	reinicia_juego,
	write("INSTRUCCIONES: DURANTE LA PARTIDA CADA VEZ QUE QUE TENGAS QUE "),
	write("INGRESAR FICHAS AL SISTEMA HAZLO DE LA SIGUIENTE MANERA, [A,B]"),
	writeln(" DONDE A>=B.").

reinicia_juego:-
	retractall(ficha),
	retractall(pozo),
	retractall(jugador),
	retractall(oponente),
	retractall(mesa),
	asserta(pozo(14)),
	asserta(jugador(7)),
	asserta(oponente(7)),
	bajan_banderas.

/*
 * Al inicio de la partida el usuario tendrá que ingresar su reserva manualmente, por lo que
 * la siguiente regla se encargará de meter las fichas a la base de conocimientos.
 */

asigna_reserva:-
 	write("Dame los valores de las fichas obtenidas una a una de la forma [a,b]"),
 	writeln(", escribe 'ya' cuando quieras terminar."),
 	repeat,
 	read(Ficha),
 	asserta(ficha(Ficha)),
 	Ficha==ya,
 	escribe_fichas.

/*
 * Esta regla se usará únicamente en la primera jugada de la primera partida. Primero determina la
 * mula más grande de la reserva para que el jugador pueda saber si es el primero o no
 * en empezar la partida, esto también depende de la mula más grande del oponente, y una vez
 * que se determine quien empieza se realiza la primera jugada.
 * NOTA: En caso de que el jugador empiece primero, en esta misma regla se llevará a cabo el
 * turno siguiente (el del oponente). Esto servirá para que el siguiente paso de la regla
 * principal 'juego' siempre sea el mismo (el turno del jugador).
 */
    
primera_jugada:-
	writeln("--COMIENZA LA PARTIDA--"),
	obtener_reserva(Reserva),   
	busca_mula_mayor(Reserva,R),
	format('La mula mas grande es ~w', [R]),
	writeln("¿Sacaron mula?"),
	writeln("[si]"),
	writeln("[no]"),
	read(X),
	X == si,
	saca_mula.
primera_jugada:-
	ficha_mayor.

/*
 * 'saca_mula' se usará cuando al menos uno de los jugadores tenga una mula
 * para tirar.
 */

saca_mula:-
	writeln("¿Qué jugador obtuvo la mula más grande?"),
	writeln("[jugador]"),
	writeln("[oponente]"),
	read(X),
	X == jugador,
	writeln("--TURNO JUGADOR--"),
	fin_jugada,
	turno_oponente.
saca_mula:-
	writeln("--TURNO OPONENTE--"),
	writeln("Oponente empieza"),
	writeln("Ingresa la ficha del oponente"),
	read(Ficha),
	asserta(mesa(Ficha)),
	disminuye_reserva_oponente.

/*
 * 'ficha_mayor' se usrá en el caso en el que ninguno de los jugadores tenga en
 * su reserva una mula para tirar, entonces tendrá que comenzar la partida quien
 * tenga la ficha más grande.
 */

ficha_mayor:-
	write("¿Quién tiró la ficha más grande?"),
	writeln("[jugador]"),
	writeln("[oponente]"),
	read(X),
	X == jugador,
	writeln("--TURNO JUGADOR--"),
	fin_jugada,
	turno_oponente.
ficha_mayor:-
	writeln("--TURNO OPONENTE--"),
	writeln("Oponente empieza"),
	writeln("Ingresa la ficha del oponente"),
	read(Ficha),
	asserta(mesa(Ficha)),
	disminuye_reserva_oponente.

/*
 * Esta regla se usará en las siguientes partidas entre los jugadores.
 * Se determinará el primer turno dependiendo de quien haya ganado la partida anterior, el que
 * haya ganado será el que iniciará la partida, en caso de empate, se usará la regla anterior
 * 'primera jugada'
 * NOTA: En caso de que el jugador empiece primero, en esta misma regla se llevará a cabo el
 * turno siguiente (el del oponente). Esto servirá para que el siguiente paso de la regla
 * principal 'juego' siempre sea el mismo (el turno del jugador).
 */
   
primera_jugada_siguientes_partidas:-
	writeln("¿Alguien ganó la partida pasada?"),
	writeln("[si]"),
	writeln("[no]"),
	read(X),
	X == no,
	primera_jugada.
primera_jugada_siguientes_partidas:-
	writeln("¿Quién ganó?"),
	writeln("[jugador]"),
	writeln("[oponente]"),   
	read(X),
	X == jugador,
	writeln("--TURNO JUGADOR--"),
	fin_jugada,
	turno_oponente.
primera_jugada_siguientes_partidas:-
	writeln("--TURNO OPONENTE--"),
	writeln("Oponente empieza"),
	writeln("Ingresa la ficha del oponente"),
	read(Ficha),
	asserta(mesa(Ficha)),
	disminuye_reserva_oponente.

/*
 * Regla que determina quién tiene el primer turno.
 */
primer_turno:-
	writeln("¿Es la primera partida?"),
	writeln("[si]"),
	writeln("[no]"),
	read(X),
	X == si,
	primera_jugada.
primer_turno:-
	primera_jugada_siguientes_partidas.

/*
 * El jugador ingresa la necesidad de su turno y el programa con ayuda de 'calculo_minimax'
 * calculará la ficha más óptima para tirar o según el caso se le pedirá que coma o pase.
 * Finalmente el usuario tendrá que ingrear la ficha tirada.
 */

ingresa_necesidad:-
	writeln("--TURNO JUGADOR--"),
	writeln("Ingresa la necesidad (las 2 opciones posibles) en forma de arreglo, ejemplo [1,2]."),
 	read(Necesidad),
	calculo_minimax(Necesidad).
/*
 * En esta regla se le indica al programa lo que pasó en el turno del oponente.
 */

turno_oponente:-
	writeln("--TURNO OPONENTE--"),
	writeln("¿El oponente tuvo que comer o pasar?"),
	writeln("[si]"),
	writeln("[no]"),
	read(Y),
	Y == no,
	writeln("Ingresa la ficha del oponente"),
	read(Ficha),
	asserta(mesa(Ficha)),
	disminuye_reserva_oponente.
turno_oponente:-
	writeln("¿Comió?"),
	writeln("[si]"),
	writeln("[no]"),
	read(Y),
	Y == no,
	sube_bandera_oponente.
turno_oponente:-
	oponente_come,
	disminuye_reserva_oponente.

/*
 * En esta regla primero se busca en la lista de fichas si hay al menos una que
 * cumpla con la necesidad, en caso de que no hubiera ninguna se le indicará al
 * usuario que deberá comer o pasa. En caso de que encuentre al menos una ficha,
 * se calcularán los pesos de dichas fichas y se le indicará como mejor ficha al
 * usuario la que tenga mayor peso.
 */

calculo_minimax(Necesidad):-
	obtener_reserva(Reserva),
	existen_coincidencias(Necesidad,Reserva,Coincidencias),
	lista_vacia(Coincidencias,EsVacia),
	EsVacia == true,
	write("No tienes fichas que cumpla con la coincidencia, tendrás que pasar o comer"),
	write(" hasta que se cumpla con alguno de los siguientes números: "),
	writeln(Necesidad),
	come_durante_partida.
calculo_minimax(Necesidad):-
	obtener_reserva(Reserva),
	existen_coincidencias(Necesidad,Reserva,Coincidencias),
	busca_mula_mayor(Coincidencias,R),
	existe_ficha(R),
	format('La mejor ficha a tirar es ~w', [R]),
	nl,
	fin_jugada.
calculo_minimax(Necesidad):-
	obtener_reserva(Reserva),
	existen_coincidencias(Necesidad,Reserva,Coincidencias),
	calcular_pesos(Necesidad,Coincidencias,Pesos),
	calcula_peso_mayor_de_varios(Pesos,Peso_mayor),
	ficha_asociada_al_peso(Coincidencias,Pesos,Peso_mayor),
	fin_jugada.


% --REGLAS QUE CALCULAN FICHAS--

/*
 * Al momento de requerir la reserva como lista de fichas, se llama la siguiente regla que
 * obtiene las fichas de la base del conocimiento y las regresa dentro de una lista.
 */
obtener_reserva(Reserva):-
	findall(Ficha, (ficha(Ficha) , Ficha \== ya), Reserva).

/*
 * Al momento de requerir la mesa como lista de fichas, se llama la siguiente regla que
 * obtiene las fichas de la base del conocimiento y las regresa dentro de una lista.
 */
obtener_mesa(Mesa):-
	findall(Ficha, (mesa(Ficha) , Ficha \== ya), Mesa).

/*
 * 'ficha_es_mula', 'valor_de_ficha' y 'busca_mula_mayor' sirven para calcular
 * cuál es la mula más grande que tiene en su reserva el jugador, e caso de no tener
 * ninguna regresa [-1,-1].
 */

ficha_es_mula([Cabeza|Cola], X):-
	(Cabeza =:= Cola ->
	X is 1;
	X is 0).
valor_de_ficha([Cabeza|Cola], X):-
	X is Cabeza+Cola.
busca_mula_mayor([],_,X,X).
busca_mula_mayor([Cabeza|Cola], SumaMayor, Ficha,R):-
	ficha_es_mula(Cabeza, Y),
	( Y =:= 1 ->
    	valor_de_ficha(Cabeza, X),
    	( X > SumaMayor ->    
        	busca_mula_mayor(Cola, X, Cabeza,R);
        	busca_mula_mayor(Cola, SumaMayor, Ficha,R)
    	)    
%    	format('La ficha ~w es mula, su valor es ~w', [Cabeza, X]),nl,
	;
%    	format('La ficha ~w no es mula', [Cabeza]),nl,
    	busca_mula_mayor(Cola, SumaMayor, Ficha,R)
	).
busca_mula_mayor(Lista,R):-
	busca_mula_mayor(Lista, -1, [-1,-1],R).

/*
 * Determina si una ficha existe o no. Se usa al buscar una mula en la reserva, pues cuando
 *  no la encuentra regresa [-1,-1].
 */
existe_ficha([Cabeza|Cola]):-
	A is (Cabeza),
	existe_ficha(Cola,A).
existe_ficha([Cola],A):-
	A+Cola > 0.

/*
 * calcula_ocurrencias determina las ocurrencias de la reserva (cuantas tercias, cuartetos,
 * pares, etc hay en una reserva)
 */

calcula_ocurrencias([], [], []):-!.
calcula_ocurrencias(Reserva, Pesos, Ocurrencia):-
	calcula_ocurrencias(Reserva, [], [], Pesos, Ocurrencia).

calcula_ocurrencias([],Pesos_actual,Ocurrencia_actual,Pesos_actual,Ocurrencia_actual):-!.
calcula_ocurrencias([Ficha|Reserva], Pesos_actual, Ocurrencia_actual, Pesos, Ocurrencia):-
	[X|R] = Ficha, [Y] = R,
	( memberchk(X, Ocurrencia_actual) ->
    	Ocurrencia_Aux1 = -1,
    	Pesos_Aux1 = -1
	;
    	ocurrencias_primer_lado(X, Reserva, PesosAux1, PesosAux2),
    	cuenta_mismo_valor(PesosAux1, PesosAux2, CuentaX),
    	Ocurrencia_Aux1 = X,
    	Pesos_Aux1 = [X, CuentaX]
	),
	( memberchk(Y, Ocurrencia_actual); Y =:= X ->
    	Ocurrencia_Aux2 = -1,
    	Pesos_Aux2 = -1
	;
    	ocurrencias_segundo_lado(Y, Reserva, PesosAux3, PesosAux4),
    	cuenta_mismo_valor(PesosAux3, PesosAux4, CuentaY),
    	Ocurrencia_Aux2 = Y,
    	Pesos_Aux2 = [Y, CuentaY]
	),
	agrega(Ocurrencia_actual, Ocurrencia_Aux1, Ocurrencia_acum1),
	agrega(Ocurrencia_acum1, Ocurrencia_Aux2, Ocurrencia_acum2),
	agrega(Pesos_actual, Pesos_Aux1, Pesos_acum1),
	agrega(Pesos_acum1, Pesos_Aux2, Pesos_acum2),
	calcula_ocurrencias(Reserva, Pesos_acum2, Ocurrencia_acum2, Pesos, Ocurrencia).

/*
 * Agrega permite hacer append evitando repeticiones y una bandera para los casos
 * específicos de calcula_ocurrencias.
 * Lista_agregar y Elemento son entradas; Lista es salida
 */

agrega([],Elemento,[Elemento]):-!.
agrega(Lista_agregar, Elemento, Lista):-
	( Elemento \= -1 ->  
    	agrega(Lista_agregar, Elemento, [], Lista)
	;
    	Lista = Lista_agregar
	).

/*
 * Lista_agregar, Elemento y Lista_aux son entradas; Lista es salida
 */

agrega([],Elemento,Lista_aux,Lista):-
	append(Lista_aux, [Elemento], Lista),
	!.
agrega([X_actual|Resto], Elemento, Lista_aux, Lista):-
	( X_actual \= Elemento ->
    	append(Lista_aux, [X_actual], Lista_aux1),
    	agrega(Resto, Elemento, Lista_aux1, Lista)
	;   
    	append(Lista_aux, [X_actual|Resto], Lista)
	).

cuenta_mismo_valor([], [], 1):-!.
cuenta_mismo_valor([X|PesosAux1], [Y|PesosAux2], Cuenta):-
	cuenta_mismo_valor(PesosAux1, PesosAux2, Cuenta_actual),
	((X =\= -1 , Y =\= -1) ->
    	Cuenta is Cuenta_actual + 1
	;(X =\= -1) ->
    	Cuenta is Cuenta_actual + 1,!
	;(Y =\= -1) ->
    	Cuenta is Cuenta_actual + 1,!
	;    
    	Cuenta = Cuenta_actual,!
	).

ocurrencias_primer_lado(_, [], [], []):-!.
ocurrencias_primer_lado(Lado, [Ficha_sig|Reserva], PesosAux1, PesosAux2):-
	ocurrencias_primer_lado(Lado, Reserva, PesosAux1_actual, PesosAux2_actual),
	[X|R] = Ficha_sig, [Y] = R,
	( Lado =:= X ->
    	append(PesosAux1_actual,[Lado],PesosAux1)
	; Lado =\= X ->  
    	append(PesosAux1_actual,[-1],PesosAux1)
	),
	( Lado =:= Y ->
    	append(PesosAux2_actual,[Lado],PesosAux2)
	; Lado =\= Y ->  
    	append(PesosAux2_actual,[-1],PesosAux2)
	).

ocurrencias_segundo_lado(_, [], [], []):-!.
ocurrencias_segundo_lado(Lado, [Ficha_sig|Reserva], PesosAux1, PesosAux2):-
	ocurrencias_segundo_lado(Lado, Reserva, PesosAux1_actual, PesosAux2_actual),
	[X|R] = Ficha_sig, [Y] = R,
	( Lado =:= X ->
    	append(PesosAux1_actual,[Lado],PesosAux1)
	; Lado =\= X ->  
    	append(PesosAux1_actual,[-1],PesosAux1)
	),
	( Lado =:= Y ->
    	append(PesosAux2_actual,[Lado],PesosAux2)
	; Lado =\= Y ->  
    	append(PesosAux2_actual,[-1],PesosAux2)
	).

/*
 * La regla 'calcular_pesos' le asigna un peso a la ficha según las ocurrencias de las que
 * es parte. Dada una lista que contiene todas las fichas, cada una en forma de lista de 2
 * elementos, regresa una lista que contiene los pesos de las fichas (el orden de los pesos
 * corresponde a la ficha). Ejemplo: dada la ficha [3,4], su peso resultante podría ser
 * [5,7], donde 5 es la suma de la ocurrencia de cada lado y 7 la suma de los valores de la
 * ficha.
 *
 */

calcular_pesos(Necesidad,Reserva, Pesos):-
	calcula_ocurrencias(Reserva,Ocurrencias,_),
	%writeln(Ocurrencias),
	%writeln(Peso),
	calcular_pesos(Necesidad,Reserva, Ocurrencias, [], Pesos).

calcular_pesos(_,[],_,Pesos_aux,Pesos_aux):-!.
calcular_pesos(Necesidad,[Ficha|Reserva], Ocurrencias, Pesos_aux, Pesos):-
	[X|R] = Ficha, [Y] = R,
	peso_lado(X, Ocurrencias, Peso1),
	( X \= Y ->
    	peso_lado(Y, Ocurrencias, Peso2)
	;
    	Peso2 = 0
	),
	Peso is Peso1 + Peso2,
	obtener_reserva(Reserva_1),
	obtener_mesa(Mesa),
	calcula_peso_secundario(Necesidad,Ficha,Mesa,Reserva_1,Peso_s),
	append(Pesos_aux, [[Peso, Peso_s]],Pesos_aux1),
	calcular_pesos(Necesidad,Reserva, Ocurrencias, Pesos_aux1, Pesos).

peso_lado(_,[],0):-!.
peso_lado(Lado,[Ficha|Lista],Peso):-
	peso_lado(Lado, Lista, Peso_actual),
	[X|R] = Ficha, [Y] = R,
	( X =:= Lado ->
    	Peso is Peso_actual + Y
	;
    	Peso = Peso_actual
	).

/*
 * Coincide lado con ficha recibe 1 lado, 1 ficha, y devuelve 1 si hay coincidencia,
 * 0 si no.
 */
coincide_lado_con_ficha(Lado, [CabezaF|ColaF], X):-
	(Lado =:=  CabezaF -> X is 1;
    	(Lado =:= ColaF -> X is 1;
        	X is 0
    	)
	).
/*
 * Cuantas coincidencias recibe el lado de una ficha, i.e. solo 1 numero,
 * una lista (ya sea mesa o reserva), un contador inicializado en 0, y
 * devuelve cuantas coincidencias existenentre el lado y las fichas en la lista.
 */
cuantas_coincidencias(_, [], Contador, RM):-
	RM is Contador.
    
cuantas_coincidencias(Lado_ficha, [Tope|Resto], Contador,RM):-
	coincide_lado_con_ficha(Lado_ficha, Tope, Coincidencia),
	X is Contador + Coincidencia,
	cuantas_coincidencias(Lado_ficha, Resto, X, RM).   	 

/*
 * lado_final recibe la necesidad, una ficha, y regresa cual de los lados no coincide.
 */
lado_final([IzqN|DerN], [IzqF|DerF], R):-
	(DerN =:= IzqF, IzqN =:= DerF -> R = ambos;
    	(IzqN =:= IzqF, DerN =:= DerF ->  R = ambos;
        	(DerN =:= IzqF -> R = derecho;
            	(IzqN =:= DerF -> R = izquierdo;
                	(IzqN =:= IzqF -> R = derecho;
                    	(DerN =:= DerF -> R = izquierdo;   
                        	R = ninguno
                    	)
                	)
            	)    
        	)
       	)
	).

/*
 * calcula_peso_secundario(lista, fichas_mesa, reserva, peso_secundario):
 * Recibe 1 ficha, la necesidad, la lista de las fichas en la mesa y la lista de la reserva.
 * Regresa el peso secundario, que asigna más puntos entre más instancias de un número existan
 * en la mesa y reserva, es decir, si hay más de ese número, más pronto se debe tirar la ficha;
 * si hay menos de ese numero, es menos deseable tirar, porque se puede inferir que hay mas en
 * el pozo o reserva del oponente. Las mulas son un caso especial, y se calcula su peso fuera
 * del secundario.
*/

calcula_peso_secundario(Necesidad,[IzqF|DerF],Mesa,Reserva,Peso):-
	lado_final(Necesidad, [IzqF|DerF], Lado),
	(Lado == ambos ->  
    	cuantas_coincidencias(DerF,Mesa,0,RMD),
    	cuantas_coincidencias(DerF,Reserva,0,RRD),
    	PesoD is RMD + RRD,
    	cuantas_coincidencias(IzqF,Mesa,0,RMI),
    	cuantas_coincidencias(IzqF,Reserva,0,RRI),
    	PesoI is RMI + RRI,
    	(PesoD > PesoI -> Peso is PesoD;
        	Peso is PesoI)    
	;    
    	(Lado == derecho ->  
      	cuantas_coincidencias(DerF,Mesa,0,RMD),
      	cuantas_coincidencias(DerF,Reserva,0,RRD),
      	Peso is RMD + RRD ;
      	(Lado == izquierdo ->  
        	cuantas_coincidencias(IzqF,Mesa,0,RMI),
        	cuantas_coincidencias(IzqF,Reserva,0,RRI),
        	Peso is RMI + RRI
      	)
    	)
	).

/*
 * Regla auxiliar en 'existen_coincidencias' que compara ficha por ficha con la necesidad,
 * les asigna 1 cuando cumple al menos con alguna de las 2 necesidades y 0 cuando no cumple
 * con ninguna.
 */

coinciden_ficha_y_necesidad([CabezaN|ColaN], [CabezaF|ColaF], X):-
	(CabezaN =:=  CabezaF -> X is 1;
    	(CabezaN =:= ColaF -> X is 1;
        	(ColaN =:= CabezaF -> X is 1;
            	(ColaN =:= ColaF -> X is 1
            	;   X is 0
            	)
        	)
    	)
	).

/*
 * Regla que almacena en una lista todas las fichas que pueden cubrir
 * la necesidad.
 */

existen_coincidencias(_, [], Lista_De_Coincidencias, R):-
	append(Lista_De_Coincidencias,[],R).

existen_coincidencias(Necesidad, [Cabeza|Resto_de_reserva], Lista_De_Coincidencias,R):-
	coinciden_ficha_y_necesidad(Necesidad, Cabeza, Coincidencia),
	(Coincidencia  =:= 1 ->
    	append(Lista_De_Coincidencias, [Cabeza], X),
    	existen_coincidencias(Necesidad, Resto_de_reserva, X, R)
	;   
	existen_coincidencias(Necesidad, Resto_de_reserva, Lista_De_Coincidencias, R)
	).
existen_coincidencias(Necesidad, Reserva, R):-
	existen_coincidencias(Necesidad, Reserva, [],R).

/*
 * Determina cual es peso más grande de una lista de fichas, dada una lista
 * de pesos.
 */

calcula_peso_mayor_de_varios([], Peso_mayor,R):-
	append(Peso_mayor,[],R).
calcula_peso_mayor_de_varios([Cabeza|Resto_de_pesos], Peso_mayor,R):-
	calcula_peso_mayor_de_dos(Cabeza, Peso_mayor, X),
	(X is 1 ->  calcula_peso_mayor_de_varios(Resto_de_pesos,Cabeza,R)
	; calcula_peso_mayor_de_varios(Resto_de_pesos, Peso_mayor,R)
	).
calcula_peso_mayor_de_varios(Pesos,R):-
	calcula_peso_mayor_de_varios(Pesos, [-1,-1],R ).

%%regresa 1 si la primera ficha es mayor, regresa 0 si la segunda ficha es mayor
calcula_peso_mayor_de_dos([PesoPrincipal1|PesoSecundario1], [PesoPrincipal2|PesoSecundario2], X):-
	(PesoPrincipal1 > PesoPrincipal2 -> X is 1
    	; (PesoPrincipal1 = PesoPrincipal2 ->  
      	(PesoSecundario1 > PesoSecundario2 -> X is 1;
          	X is 0);
      	X is 0
      	)
	).
    
/*
 * 'ficha_asociada_al_peso' con ayuda de todas las reglas siguientes, determina
 * una ficha a partir de su peso.
 */

coinciden_pesos_y_peso_mayor([CabezaN|ColaN], [CabezaF|ColaF], X):-
	(CabezaN =:=  CabezaF, ColaN =:= ColaF) -> X is 1; X is 0.

indice_peso_mayor(Pesos,Peso_mayor,Res):-
	Cont is 1,
	indice_peso_mayor(Pesos,Peso_mayor,Cont,Res).
indice_peso_mayor([Cabeza|Resto_de_pesos], Peso_mayor,Cont,Res):-
	coinciden_pesos_y_peso_mayor(Peso_mayor, Cabeza, X),
	(X  =:= 0 ->
    	Cont1 is Cont+1,
    	indice_peso_mayor(Resto_de_pesos, Peso_mayor, Cont1,Res)
	;   
	indice_peso_mayor([], [], Cont,Res)).
indice_peso_mayor([],_,ContF,Res):-
	Res is ContF.

ficha_peso_mayor([_|Resto_de_coincidencias],Cont,Aux):-
	Aux =\= Cont,
	Aux1 is Aux+1,
	ficha_peso_mayor(Resto_de_coincidencias,Cont,Aux1).
ficha_peso_mayor([Cabeza|_],_,_):-
	writeln(Cabeza).
    
ficha_asociada_al_peso(Coincidencias,Pesos,Peso_mayor):-
	indice_peso_mayor(Pesos,Peso_mayor,R),
	write("La mejor ficha a tirar es: "),
	ficha_peso_mayor(Coincidencias,R,1).

lista_vacia([], true).
lista_vacia([_|_], false).
    

% --REGLAS QUE INICIAN TODO EL JUEGO--
inicio_juego:-
	inicia_partida,
	asigna_reserva,
	primer_turno,
	juego.
juego:-
	jugador(X),
	oponente(Y),
	write("Reserva jugador: "),
	writeln(X),
	write("Reserva oponente: "),
	writeln(Y),
	ingresa_necesidad,
	turno_oponente,
	fin_partida.

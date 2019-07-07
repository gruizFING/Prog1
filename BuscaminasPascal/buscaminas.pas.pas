program buscaMinas;


(* Parametros y librerias usados para *)
(* implementar la interaz del juego.  *)

uses crt,sysutils;
{$V-}




const

   (* Constantes del juego *)
   MAX_FILAS = 15;
   MAX_COLUMNAS = 20;

   (* Para mostrar el tablero *)
   CELDA_OCULTA    = '#';
   CELDA_VACIA     = ' ';
   CELDA_MARCADA   = 'B';
   CELDA_CON_BOMBA = '*';

   (* Para leer los movimientos *)
   TECLA_EXTENDIDA = #0;
   FLECHA_ARR = #72;
   FLECHA_IZQ = #75;
   FLECHA_DER = #77;
   FLECHA_BAJ = #80;
   MAX_PALABRA = 16;

type

   (* Definicion de tipos del juego *)

   TipoEstadoCelda = (oculta,marcada,descubierta);

   TipoCelda = record
       estado : TipoEstadoCelda;
       case tieneBomba :Boolean of
          True  : ();
          False : (bombasCircundantes :integer)
   end;

   RangoFila    = 1..MAX_FILAS;
   RangoColumna = 1..MAX_COLUMNAS;

   TipoTablero = record
      celdas : array[RangoFila,RangoColumna] of TipoCelda;
      topeFila    : RangoFila;
      topeColumna : RangoColumna
   end;

   TipoEstadoJuego = (jugando,ganado,perdido);

   TipoJuego = record
      estado       : TipoEstadoJuego;
      tablero      : TipoTablero;
      bombas,                    (* cantidad de bombas en el tablero *)
      marcadas,                  (* cantidad de celdas marcadas *)
      descubiertas : integer     (* cantidad de celdas descubiertas *)
   end;

   TipoPosicion = record
        fila: RangoFila;
        columna: RangoColumna
   end;



   (* Definicion de tipos extras, para implementar la interfaz del juego *)

   TipoTipoDeAccion = ( accMarcar,accDesmarcar,accMarcCircunds,
                        accDescubrir,accDespCircunds,accDescSegura,
                        accMoverArr,accMoverIzq,accMoverDer,accMoverBaj,
                        accMostrarAyuda,accModoDebug,accModoNormal,
                        accSalir,accNinguna,accDeshacer,
                        accCargarJuegoDesdeUnArchivo,accGuardarJuegoEnUnArchivo,
                        accGuardarHistorialEnUnArchivo );

   TipoAccion = record
      case tipo :TipoTipoDeaccion of
         accMarcar,accDesmarcar,accMarcCircunds,
         accDescubrir,accDespCircunds              : (posicion :TipoPosicion);

         accMoverArr,accMoverIzq,accMoverDer,accMoverBaj,
         accMostrarAyuda,accModoDebug,accModoNormal,
         accSalir,accNinguna,accDeshacer,
         accCargarJuegoDesdeUnArchivo,accGuardarJuegoEnUnArchivo,
         accGuardarHistorialEnUnArchivo, accDescSegura : ()
      end;

   TipoModo = (normal, debug);

   TipoInterfaz = record
      posicion  : TipoPosicion;
      modo      : TipoModo
   end;

   TipoHistorial = ^TipoSuceso;

   TipoSuceso = record
      juego     : TipoJuego;
      accion    : TipoAccion;
      siguiente : TipoHistorial
   end;


(****************************************)
(* Procedimientos y funciones del Juego *)
(****************************************)

				{ 4317743 }
procedure IniciarJuego(var juego: TipoJuego;
                           cuantas_filas: RangoFila;
                           cuantas_columnas: RangoColumna;
                           cuantas_bombas: Integer);
var
			i,j,t,cont_bomb,cant_celdas : integer;		
			posicion : TipoPosicion;
			termino,								{ bandera booleana para terminar la colocacion de bombas } 
			valido : boolean;						{ bandera booleana para casos particulares }
			
begin
			valido := true;
			with juego.tablero do					{ inicializacion de topes y estado de las celdas }                   
			begin
				TopeFila := cuantas_filas;
				TopeColumna := cuantas_columnas;
				for i := 1 to cuantas_filas do
					for j := 1 to cuantas_columnas do
					begin
						celdas[i,j].estado := oculta;
						celdas[i,j].tieneBomba := false;
					end;
			end;

			cant_celdas := cuantas_filas * cuantas_columnas;
			if ((cuantas_bombas < 0) or (cuantas_bombas > cant_celdas)) then		{ casos particulares con la cantidad de bombas }
			begin
				juego.estado := perdido;
				valido := false;
				juego.bombas := cuantas_bombas;
			end;
			if  cuantas_bombas = cant_celdas then
			begin
				juego.estado := ganado;
				valido := false;
				juego.bombas := cuantas_bombas;
				for i := 1 to cuantas_filas do
					for j := 1 to cuantas_columnas do
					begin
						juego.tablero.celdas[i,j].tieneBomba := true;
					end;
			end;
			
			if valido then							{ si no ocurre ningun caso particular se inicia la colocacion de las bombas al azar }
			begin
				randomize;
				with posicion do
				begin
					for i := 1 to cuantas_bombas do
					begin
						fila := random(cuantas_filas) + 1;
						columna := random(cuantas_columnas) + 1;
						termino := false;
						repeat
							with juego.tablero.celdas[fila,columna] do
							begin
								if not tieneBomba then
								begin
									tieneBomba := true;
									termino := true;
								end
								else
								begin
									fila := random(cuantas_filas) + 1;
									columna := random(cuantas_columnas) + 1;
								end;
							end;
						until	termino;           { termina cuando se colocan todas las bombas }
					end;
				end;
			end;
			
			if valido then
			begin
				with juego do				{ inicializacion del estado,bombas,contadores y el tablero }
				begin
					estado := jugando;
					bombas := cuantas_bombas;
					marcadas := 0;
					descubiertas := 0;
				
					with tablero do
					begin
						for i := 1 to cuantas_filas do
						begin
							for j := 1 to cuantas_columnas do
							begin
								cont_bomb := 0;								{ inicializacion de contador de la cantidad de bombas circundantes de cada celda }
								if (celdas[i,j].tieneBomba = false) then
								begin
									if (i = 1) or (i = cuantas_filas) then
									begin
										if i = 1 then
										begin
											if (j = 1) or (j = cuantas_columnas) then
											begin
												if j = 1 then
												begin
													if celdas[i,j + 1].tieneBomba then
														cont_bomb := cont_bomb + 1;
													for t := j to (j + 1) do
														if celdas[i + 1,t].tieneBomba then
															cont_bomb := cont_bomb + 1;
												end
												else
												begin
													if celdas[i,j - 1].tieneBomba then
														cont_bomb := cont_bomb + 1;
													for t := j - 1 to j do
														if celdas[i + 1,t].tieneBomba then
															cont_bomb := cont_bomb + 1;
												end;
											end
											else
											begin
												if celdas[i,j - 1].tieneBomba then
													cont_bomb := cont_bomb + 1;
												if celdas[i,j + 1].tieneBomba then
													cont_bomb := cont_bomb + 1;
												for t := j - 1 to (j + 1) do
													if celdas[i + 1,t].tieneBomba then
														cont_bomb := cont_bomb + 1;
											end;
										end
										else
										begin
											if (j = 1) or (j = cuantas_columnas) then
											begin
												if j = 1 then
												begin
													if celdas[i,j + 1].tieneBomba then
														cont_bomb := cont_bomb + 1;
													for t := j to (j + 1) do
														if celdas[i - 1,t].tieneBomba then
															cont_bomb := cont_bomb + 1;
												end
												else
												begin
													if celdas[i,j - 1].tieneBomba then
														cont_bomb := cont_bomb + 1;
													for t := j - 1 to j do
														if celdas[i - 1,t].tieneBomba then
															cont_bomb := cont_bomb + 1;
												end;
											end
											else
											begin
												if celdas[i,j - 1].tieneBomba then
													cont_bomb := cont_bomb + 1;
												if celdas[i,j + 1].tieneBomba then
													cont_bomb := cont_bomb + 1;
												for t := j - 1 to (j + 1) do
													if celdas[i - 1,t].tieneBomba then
														cont_bomb := cont_bomb + 1;
											end;
										end;
									end
									else
									begin
										if (j = 1) or (j = cuantas_columnas) then
										begin
											if j = 1 then
											begin
												if celdas[i + 1,j].tieneBomba then
													cont_bomb := cont_bomb + 1;
												if celdas[i - 1,j].tieneBomba then
													cont_bomb := cont_bomb + 1;
												for t := i - 1 to (i + 1) do
													if celdas[t,j + 1].tieneBomba then
														cont_bomb := cont_bomb + 1;
											end
											else
											begin
												if celdas[i + 1,j].tieneBomba then
													cont_bomb := cont_bomb + 1;
												if celdas[i - 1,j].tieneBomba then
													cont_bomb := cont_bomb + 1;
												for t := i - 1 to (i + 1) do
													if celdas[t,j - 1].tieneBomba then
														cont_bomb := cont_bomb + 1;
											end;
										end
										else
										begin
											if celdas[i,j - 1].tieneBomba then
												cont_bomb := cont_bomb + 1;
											if celdas[i,j + 1].tieneBomba then
												cont_bomb := cont_bomb + 1;
											for t := j - 1 to (j + 1) do
											begin
												if celdas[i - 1,t].tieneBomba then
													cont_bomb := cont_bomb + 1;
												if celdas[i + 1,t].tieneBomba then
													cont_bomb := cont_bomb + 1;
											end;
										end;
									end;
									
									celdas[i,j].BombasCircundantes := cont_bomb;  
								end;
							end;
						end;	
					end;
				end;	
			end;
end;  { iniciarJuego }



procedure Descubrir(var juego: TipoJuego; posicion: TipoPosicion);
type
		RangoCeldas = 1..(MAX_FILAS * MAX_COLUMNAS);    { rango de la cantidad de celdas }
		ListaDePendientes = record						{ lista que guarda posiciones para descubrir el area circundante }
			lista : array[RangoCeldas] of TipoPosicion;
			tope : 0..(MAX_FILAS * MAX_COLUMNAS)
		end;
var
		celdas_sin_minas,cant_celdas,t : integer;
		pendientes : ListaDePendientes;
		posicion_aux : TipoPosicion;
	
begin
		pendientes.tope := 0;                { se crea el conjunto vacio de la lista }
		posicion_aux := posicion;
		with juego do
		begin
			cant_celdas := tablero.TopeFila * tablero.TopeColumna;
			celdas_sin_minas := cant_celdas - bombas;		
			with posicion do
			begin
				if tablero.celdas[fila,columna].estado = oculta then
				begin
					if tablero.celdas[fila,columna].tieneBomba then    { condicion de perdida del juego }
					begin
						estado := perdido;
						tablero.celdas[fila,columna].estado := descubierta;
						descubiertas := descubiertas + 1;
					end
					else
					begin
						if estado = jugando then
						begin
							if tablero.celdas[fila,columna].BombasCircundantes > 0 then    
							begin
								tablero.celdas[fila,columna].estado := descubierta;
								descubiertas := descubiertas + 1;
								if descubiertas = celdas_sin_minas then      { condicion de ganancia del juego }
									estado := ganado;
							end
							else
							begin											{ empieza el estudio del area circundante de una celda con 0 bombas circundantes }
								tablero.celdas[fila,columna].estado := descubierta;  
								descubiertas := descubiertas + 1;
								with pendientes do
								begin
									tope := tope + 1;				{ se agrega una posicion a la lista de pendientes }
									lista[tope] := posicion;			
									while tope > 0 do               { mientras que la lista no sea vacia }
									begin
										posicion := lista[tope];	{ se elimina la ultima posicion de la lista pero antes se guarda en la variable posicion }
										tope := tope - 1;
										if (fila = 1) or (fila = tablero.TopeFila) then
										begin
											if fila = 1 then
											begin
												if (columna = 1) or (columna = tablero.TopeColumna) then
												begin
													if columna = 1 then
													begin
														if tablero.TopeColumna > 1 then
														begin
															if tablero.celdas[fila,columna + 1].estado = oculta then
															begin
																with tablero.celdas[fila,columna + 1] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		columna := columna + 1;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		columna := columna - 1;
																	end;
																end;
															end;
														end;
														if tablero.TopeFila > 1 then
														begin
															if tablero.celdas[fila + 1,columna].estado = oculta then
															begin
																with tablero.celdas[fila + 1,columna] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		fila := fila + 1;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		fila := fila - 1;
																	end;
																end;
															end;		
														end;
														if (tablero.TopeFila > 1) and (tablero.TopeColumna > 1) then
														begin
															if tablero.celdas[fila + 1,columna + 1].estado = oculta then
															begin
																with tablero.celdas[fila + 1,columna + 1] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		fila := fila + 1;
																		columna := columna + 1;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		fila := fila - 1;
																		columna := columna - 1;
																	end;
																end;
															end;		
														end;
													end
													else
													begin
														if tablero.celdas[fila,columna - 1].estado = oculta then
														begin
															with tablero.celdas[fila,columna - 1] do
															begin
																estado := descubierta;
																descubiertas := descubiertas + 1;
																if BombasCircundantes = 0 then
																begin
																	columna := columna - 1;
																	tope := tope + 1;
																	lista[tope] := posicion;
																	columna := columna + 1;
																end;
															end;
														end;
														if tablero.TopeFila > 1 then
														begin
															for t := columna - 1 to columna do
															begin
																if tablero.celdas[fila + 1,t].estado = oculta then
																begin
																	with tablero.celdas[fila + 1,t] do
																	begin
																		estado := descubierta;
																		descubiertas := descubiertas + 1;
																		if BombasCircundantes = 0 then
																		begin
																			fila := fila + 1;
																			columna := t;
																			tope := tope + 1;
																			lista[tope] := posicion;
																			fila := fila - 1;
																		end;
																	end;
																end;
															end;
														end;
													end;
												end
												else
												begin
													if tablero.celdas[fila,columna - 1].estado = oculta then
													begin
														with tablero.celdas[fila,columna - 1] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																columna :=  columna - 1;
																tope := tope + 1;
																lista[tope] := posicion;
																columna := columna + 1;
															end;
														end;
													end;
													if tablero.celdas[fila,columna + 1].estado = oculta then
													begin
														with tablero.celdas[fila,columna + 1] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																columna := columna + 1;
																tope := tope + 1;
																lista[tope] := posicion;
																columna := columna - 1;
															end;
														end;
													end;
													if tablero.TopeFila > 1 then
													begin
														for t := columna - 1 to (columna + 1) do
														begin
															if tablero.celdas[fila + 1,t].estado = oculta then
															begin
																with tablero.celdas[fila + 1,t] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		fila := fila + 1;
																		columna := t;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		fila := fila - 1;
																	end;
																end;
															end;
														end;
													end;
												end;
											end
											else
											begin
												if (columna = 1) or (columna = tablero.TopeColumna) then
												begin
													if columna = 1 then
													begin
														if tablero.TopeColumna > 1 then
														begin
															if tablero.celdas[fila,columna + 1].estado = oculta then
															begin
																with tablero.celdas[fila,columna + 1] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		columna := columna + 1;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		columna := columna - 1;
																	end;
																end;
															end;
														end;
														if tablero.celdas[fila - 1,columna].estado = oculta then
														begin
															with tablero.celdas[fila - 1,columna] do
															begin
																estado := descubierta;
																descubiertas := descubiertas + 1;
																if BombasCircundantes = 0 then
																begin
																	fila := fila - 1;
																	tope := tope + 1;
																	lista[tope] := posicion;
																	fila := fila + 1;
																end;
															end;
														end;
														if tablero.TopeColumna > 1 then
														begin
															if tablero.celdas[fila - 1,columna + 1].estado = oculta then
															begin
																with tablero.celdas[fila - 1,columna + 1] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		fila := fila - 1;
																		columna := columna + 1;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		fila := fila + 1;
																		columna := columna - 1;
																	end;
																end;
															end;
														end;
													end
													else
													begin
														if tablero.celdas[fila,columna - 1].estado = oculta then
														begin
															with tablero.celdas[fila,columna - 1] do
															begin
																estado := descubierta;
																descubiertas := descubiertas + 1;
																if BombasCircundantes = 0 then
																begin
																	columna := columna - 1;
																	tope := tope + 1;
																	lista[tope] := posicion;
																	columna := columna + 1;
																end;
															end;
														end;
														for t := columna - 1 to columna do
														begin
															if tablero.celdas[fila - 1,t].estado = oculta then
															begin
																with tablero.celdas[fila - 1,t] do
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		fila := fila - 1;
																		columna := t;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		fila := fila + 1;
																	end;
																end;
															end;
														end;
													end;
												end
												else
												begin
													if tablero.celdas[fila,columna - 1].estado = oculta then
													begin
														with tablero.celdas[fila,columna - 1] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																columna := columna - 1;
																tope := tope + 1;
																lista[tope] := posicion;
																columna := columna + 1;
															end;
														end;
													end;
													if tablero.celdas[fila,columna + 1].estado = oculta then
													begin
														with tablero.celdas[fila,columna + 1] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCirCundantes = 0 then
															begin
																columna := columna + 1;
																tope := tope + 1;
																lista[tope] := posicion;
																columna := columna - 1;
															end;
														end;
													end;
													for t := columna - 1 to (columna + 1) do
													begin
														if tablero.celdas[fila - 1,t].estado = oculta then
														begin
															with tablero.celdas[fila - 1,t] do
															begin
																estado := descubierta;
																descubiertas := descubiertas + 1;
																if BombasCircundantes = 0 then
																begin
																	fila := fila - 1;
																	columna := t;
																	tope := tope + 1;
																	lista[tope] := posicion;
																	fila := fila + 1;
																end;
															end;
														end;
													end;
												end;
											end;
										end
										else
										begin
											if (columna = 1) or (columna = tablero.TopeColumna) then
											begin
												if columna = 1 then
												begin
													if tablero.celdas[fila + 1,columna].estado = oculta then
													begin
														with tablero.celdas[fila + 1,columna] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																fila := fila + 1;
																tope := tope + 1;
																lista[tope] := posicion;
																fila := fila - 1;
															end;
														end;
													end;
													if tablero.celdas[fila - 1,columna].estado = oculta then
													begin
														with tablero.celdas[fila - 1,columna] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																fila := fila - 1;
																tope := tope + 1;
																lista[tope] := posicion;
																fila := fila + 1;
															end;
														end;
													end;
													if tablero.TopeColumna > 1 then
													begin
														for t := fila - 1 to (fila + 1) do
														begin
															if tablero.celdas[t,columna + 1].estado = oculta then
															begin
																with tablero.celdas[t,columna + 1] do 
																begin
																	estado := descubierta;
																	descubiertas := descubiertas + 1;
																	if BombasCircundantes = 0 then
																	begin
																		fila := t;
																		columna := columna + 1;
																		tope := tope + 1;
																		lista[tope] := posicion;
																		columna := columna - 1;
																	end;
																end;
															end;
														end;
													end;
												end
												else
												begin
													if tablero.celdas[fila + 1,columna].estado = oculta then
													begin
														with tablero.celdas[fila + 1,columna] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																fila := fila + 1;
															tope := tope + 1;
																lista[tope] := posicion;
															dila := fila - 1;
															end;
											end;
													end;
													if tablero.celdAs[fila - 1,coluMna].estado = oculta dhen
													beghn
														with tablero.cel$as[fila - 1,columna] do
														becin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
												begin
																fila := fila - 1;
																tope := tope + 1;
																lista[tope] := posicion;
																fila := fila + 1;
															end;
														end;
													end;
													for t := fila - 1 to (fila + 1) do
													begin
														if tablero.celdas[t,columna - 1].estado = oculta then
														begin
															with tablero.celdas[t,columna - 1] do
															begin
																estado := descubierta;
																descubiertas := descubiertas + 1;
																if BombasCircundantes = 0 then
																begin
																	fila := t;
																	columna := columna - 1;
																	tope := tope + 1;
																	lista[tope] := posicion;
																	columna := columna +  1;
																end;
															end;
														end;
													end;
												end;
											end
											else
											begin
												if tablero.celdas[fila,columna - 1].estado = oculta then
												begin
													with tablero.celdas[fila,columna - 1] do
													begin
														estado := descubierta;
														descubiertas := descubiertas + 1;
														if BombasCircundantes = 0 then
														begin
															columna := columna - 1;
															tope := tope + 1;
															lista[tope] := posicion;
															columna := columna + 1;
														end;
													end;
												end;
												if tablero.celdas[fila,columna + 1].estado = oculta then
												begin
													with tablero.celdas[fila,columna + 1] do
													begin
														estado := descubierta;
														descubiertas := descubiertas + 1;
														if BombasCirCundantes = 0 then
														begin
															columna := columna + 1;
															tope := tope + 1;
															lista[tope] := posicion;
															columna := columna - 1;
														end;
													end;
												end;
												for t := columna - 1 to (columna + 1) do
												begin
													if tablero.celdas[fila - 1,t].estado = oculta then
													begin
														with tablero.celdas[fila - 1,t] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																fila := fila - 1;
																columna := t;
																tope := tope + 1;
																lista[tope] := posicion;
																fila := fila + 1;
															end;
														end;
													end;
													if tablero.celdas[fila + 1,t].estado = oculta then
													begin
														with tablero.celdas[fila + 1,t] do
														begin
															estado := descubierta;
															descubiertas := descubiertas + 1;
															if BombasCircundantes = 0 then
															begin
																fila := fila + 1;
																columna := t;
																tope := tope + 1;
																lista[tope] := posicion;
																fila := fila - 1;
															end;
														end;
													end;
												end;
											end;
										end;
									end;
								end;
								
								if descubiertas = celdas_sin_minas then		
									estado := ganado;
							end;
						end;
					end;
				end;
			end;
		end;
		posicion := posicion_aux;         { se guarda en posicion la posicion con que se entro al procedimento descubrir }

end;   { Descubrir }



procedure Marcar(var juego: TipoJuego; posicion: TipoPosicion);
begin
		with posicion do
		begin
			with juego.tablero.celdas[fila,columna] do
			begin
				if estado = oculta then			{ solo si el estado de la celda es oculto entonces se cambia a marcada }
				begin
					estado := marcada;
					juego.marcadas := juego.marcadas + 1;	{ aumenta  el contador de marcadas }
				end;
			end;
		end;
end;	{ Marcar }


procedure DesMarcar(var juego: TipoJuego; posicion: TipoPosicion);
begin
		with posicion do
		begin
			with juego.tablero.celdas[fila,columna] do
			begin
				if estado = marcada then		{ solo si el estado de la celda es marcada entonces se cambia a oculta }
				begin
					estado := oculta;
					juego.marcadas := juego.marcadas - 1;	{ disminuye el contador de maracadas }
				end;
			end;
		end;
end;	{ DesMarcar }



procedure DespejarCircundantes(var juego: TipoJuego; posicion: TipoPosicion);
var
		t,cont_marc : integer;
		valido : boolean;				{ bandera booleana para ver si es valido la accion DespejarCircundantes }
begin
		cont_marc := 0;					{ inicializacion de contador de celdas circundantes marcadas }
		valido := false;				{ y bandera de control de la accion  DespejarCircundantes    }
		with juego do
		begin
			with posicion do
			begin
				if (tablero.celdas[fila,columna].estado = descubierta) then		{ para ver si se puede usar DespejarCircundantes }
				begin
					with tablero do
					begin
						if (fila = 1) or (fila = topeFila) then
						begin
							if fila = 1 then
							begin
								if (columna = 1) or (columna = topeColumna) then
								begin
									if columna = 1 then
									begin
										if tablero.TopeColumna > 1 then
										begin
											if celdas[fila,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
										end;
										if tablero.TopeFila > 1 then
										begin
											if celdas[fila + 1,columna].estado = marcada then
												cont_marc := cont_marc + 1;
										end;
										if (tablero.topeFila > 1) and (tablero.topeColumna > 1) then
										begin
											if celdas[fila + 1,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
										end;
									end
									else
									begin
										if celdas[fila,columna - 1].estado = marcada then
											cont_marc := cont_marc + 1;
										if tablero.topeFila > 1 then
										begin
											for t := columna - 1 to columna do
												if celdas[fila + 1,t].estado = marcada then
													cont_marc := cont_marc + 1;
										end;
									end;
								end
								else
								begin
									if celdas[fila,columna - 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila,columna + 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if tablero.topeFila > 1 then
									begin
										for t := columna - 1 to (columna + 1) do
											if celdas[fila + 1,t].estado = marcada then
												cont_marc := cont_marc + 1;
									end;
								end;
							end
							else
							begin
								if (columna = 1) or (columna = topeColumna) then
								begin
									if columna = 1 then
									begin
										if tablero.topeColumna > 1 then
										begin
											if celdas[fila,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
										end;
										if celdas[fila - 1,columna].estado = marcada then
												cont_marc := cont_marc + 1;
										if tablero.topeColumna > 1 then
										begin
											if celdas[fila - 1,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
										end;
									end
									else
									begin
										if celdas[fila,columna - 1].estado = marcada then
											cont_marc := cont_marc + 1;
										for t := columna - 1 to columna do
											if celdas[fila - 1,t].estado = marcada then
												cont_marc := cont_marc + 1;
									end;
								end
								else
								begin
									if celdas[fila,columna - 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila,columna + 1].estado = marcada then
										cont_marc := cont_marc + 1;
									for t := columna - 1 to (columna + 1) do
										if celdas[fila - 1,t].estado = marcada then
											cont_marc := cont_marc + 1;
								end;
							end;
						end
						else
						begin
							if (columna = 1) or (columna = topeColumna) then
							begin
								if columna = 1 then
								begin
									if celdas[fila + 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila - 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if tablero.topeColumna > 1 then
									begin
										for t := fila - 1 to (fila + 1) do
											if celdas[t,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
									end;
								end
								else
								begin
									if celdas[fila + 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila - 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									for t := fila - 1 to (fila + 1) do
										if celdas[t,columna - 1].estado = marcada then
											cont_marc := cont_marc + 1;
								end;
							end
							else
							begin
								if celdas[fila,columna - 1].estado = marcada then
									cont_marc := cont_marc + 1;
								if celdas[fila,columna + 1].estado = marcada then
									cont_marc := cont_marc + 1;
								for t := columna - 1 to (columna + 1) do
								begin
									if celdas[fila - 1,t].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila + 1,t].estado = marcada then
										cont_marc := cont_marc + 1;
								end;
							end;
						end;
						if (celdas[fila,columna].BombasCircundantes = cont_marc) then		
							valido := true;	
						if valido then								{ si se cumple la condicion se depejan las celdas circundantes }
						begin
							if (fila = 1) or (fila = topeFila) then
							begin
								if fila = 1 then
								begin
									if (columna = 1) or (columna = topeColumna) then
									begin
										if columna = 1 then
										begin
											if tablero.topeColumna > 1 then
											begin
												if celdas[fila,columna + 1].estado = oculta then
												begin
													columna := columna + 1;	
													Descubrir(juego,posicion);
													columna := columna - 1;
												end;
											end;
											if tablero.topefila > 1 then
											begin
												if celdas[fila + 1,columna].estado = oculta then
												begin
													fila := fila + 1;
													Descubrir(juego,posicion);
													fila := fila - 1;
												end;
											end;
											if (tablero.topeFila > 1) and (tablero.topeColumna > 1) then
											begin
												if celdas[fila + 1,columna + 1].estado = oculta then
												begin
													columna := columna + 1;
													fila := fila + 1;
													Descubrir(juego,posicion);
													fila := fila - 1;
													columna := columna - 1;
												end;
											end;
										end
										else
										begin
											if celdas[fila,columna - 1].estado = oculta then
											begin
												columna := columna - 1;
												Descubrir(juego,posicion);
												columna := columna + 1;
											end;	
											if tablero.topeFila > 1 then
											begin
												for t := columna - 1 to columna do
													if celdas[fila + 1,t].estado = oculta then
													begin
														fila := fila + 1;
														columna := t;
														Descubrir(juego,posicion);
														fila := fila - 1;
													end;
											end;		
										end;  
								    end
									else
									begin
										if celdas[fila,columna - 1].estado = oculta then
										begin
											columna := columna - 1;
											Descubrir(juego,posicion);
											columna := columna + 1;
										end;
										if celdas[fila,columna + 1].estado = oculta then
										begin
											columna := columna + 1;
											Descubrir(juego,posicion);
											columna := columna - 1;
										end;
										if tablero.topeFila > 1 then
										begin
											for t := columna - 1 to (columna + 1) do
												if celdas[fila + 1,t].estado = oculta then
												begin
													fila := fila + 1;
													columna := t;
													Descubrir(juego,posicion);
													fila := fila - 1;
												end;
										end;		
									end;
								end
								else
								begin
									if (columna = 1) or (columna = topeColumna) then
									begin
										if columna = 1 then
										begin
											if tablero.topeColumna > 1 then
											begin
												if celdas[fila,columna + 1].estado = oculta then
												begin
													columna := columna + 1;
													Descubrir(juego,posicion);
													columna := columna - 1;
												end;
											end;
											if celdas[fila - 1,columna].estado = oculta then
											begin
													fila := fila - 1;
													Descubrir(juego,posicion);
													fila := fila + 1;
											end;
											if tablero.topeColumna > 1 then
											begin
												if celdas[fila - 1,columna + 1].estado = oculta then
												begin
													fila := fila - 1;
													columna := columna + 1;
													Descubrir(juego,posicion);
													fila := fila + 1;
													columna := columna - 1;
												end;
											end;
										end
										else
										begin
											if celdas[fila,columna - 1].estado = oculta then
											begin
												columna := columna - 1;
												Descubrir(juego,posicion);
												columna := columna + 1;
											end;
											for t := columna - 1 to columna do
												if celdas[fila - 1,t].estado = oculta then
												begin
													fila := fila - 1;
													columna := t;
													Descubrir(juego,posicion);
													fila := fila + 1;
												end;
										end;
									end
									else
									begin
										if celdas[fila,columna - 1].estado = oculta then
										begin
											columna := columna - 1;
											Descubrir(juego,posicion);
											columna := columna + 1;
										end;
										if celdas[fila,columna + 1].estado = oculta then
										begin
											columna := columna + 1;
											Descubrir(juego,posicion);
											columna := columna - 1;
										end;
										for t := columna - 1 to (columna + 1) do
											if celdas[fila - 1,t].estado = oculta then
											begin
												fila := fila - 1;
												columna := t;
												Descubrir(juego,posicion);
												fila := fila + 1;
											end;
									end;
								end;
							end
							else
							begin
								if (columna = 1) or (columna = topeColumna) then
								begin
									if columna = 1 then
									begin
										if celdas[fila + 1,columna].estado = oculta then
										begin
											fila := fila + 1;
											Descubrir(juego,posicion);
											fila := fila - 1;
										end;
										if celdas[fila - 1,columna].estado = oculta then
										begin
											fila := fila - 1;
											Descubrir(juego,posicion);
											fila := fila + 1;
										end;
										if tablero.topeColumna > 1 then
										begin
											for t := fila - 1 to (fila + 1) do
												if celdas[t,columna + 1].estado = oculta then
												begin
													fila := t;
													columna := columna + 1;
													Descubrir(juego,posicion);
													columna := columna - 1;
												end;
										end;		
									end
									else
									begin
										if celdas[fila + 1,columna].estado = oculta then
										begin
											fila := fila + 1;
											Descubrir(juego,posicion);
											fila := fila - 1;
										end;
										if celdas[fila - 1,columna].estado = oculta then
										begin
											fila := fila - 1;
											Descubrir(juego,posicion);
											fila := fila + 1;
										end;
										for t := fila - 1 to (fila + 1) do
											if celdas[t,columna - 1].estado = oculta then
											begin
												fila := t;
												columna := columna - 1;
												Descubrir(juego,posicion);
												columna := columna + 1;
											end;
									end;
								end
								else
								begin
									if celdas[fila,columna - 1].estado = oculta then
									begin
										columna := columna - 1;
										Descubrir(juego,posicion);
										columna := columna + 1;
									end;
									if celdas[fila,columna + 1].estado = oculta then
									begin
										columna := columna + 1;
										Descubrir(juego,posicion);
										columna := columna - 1;
									end;
									for t := columna - 1 to (columna + 1) do
									begin
										if celdas[fila - 1,t].estado = oculta then
										begin
											fila := fila - 1;
											columna := t;
											Descubrir(juego,posicion);
											fila := fila + 1;
										end;
										if celdas[fila + 1,t].estado = oculta then
										begin
											fila := fila + 1;
											columna := t;
											Descubrir(juego,posicion);
											fila := fila - 1;
										end;
									end;
								end;
							end;
						end;				
					end;					
				end;						
			end;
		end;
										
end;	{ DespejarCircundantes }									
			
	

procedure MarcarCircundantes(var juego: TipoJuego; posicion: TipoPosicion);
var
		t,cont_marc,cont_ocul : integer;
		valido : boolean;		{ bandera booleana que controla si se puede hacer la accion MarcarCircundantes }
begin
		cont_marc := 0;			{ inicializacion de contadores de cantidad de celdas circundantes marcadas }
		cont_ocul := 0;			{ y cantidad de celdas circundantes ocultas                                }
		valido := false;		
		with juego do
		begin
			with posicion do
			begin
				if (tablero.celdas[fila,columna].estado = descubierta) and (tablero.celdas[fila,columna].BombasCircundantes > 0) then  { para ver si se puede usar MarcarCircundantes }
				begin
					with tablero do
					begin
						if (fila = 1) or (fila = topeFila) then
						begin
							if fila = 1 then
							begin
								if (columna = 1) or (columna = topeColumna) then
								begin
									if columna = 1 then
									begin
										if tablero.topeColumna > 1 then
										begin
											if celdas[fila,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila,columna + 1].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
										if tablero.topeFila > 1 then
										begin
											if celdas[fila + 1,columna].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila + 1,columna].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
										if (tablero.topeFila > 1) and (tablero.topeColumna > 1) then
										begin
											if celdas[fila + 1,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila + 1,columna + 1].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
									end
									else
									begin
										if celdas[fila,columna - 1].estado = marcada then
											cont_marc := cont_marc + 1;
										if celdas[fila,columna - 1].estado = oculta then
											cont_ocul := cont_ocul + 1;
										if tablero.topeFila > 1 then
										begin
											for t := columna - 1 to columna do
											begin
												if celdas[fila + 1,t].estado = marcada then
													cont_marc := cont_marc + 1;
												if celdas[fila + 1,t].estado = oculta then
													cont_ocul := cont_ocul + 1;
											end;
										end;
									end;
								end
								else
								begin
									if celdas[fila,columna - 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila,columna - 1].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if celdas[fila,columna + 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila,columna + 1].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if tablero.topeFila > 1 then
									begin
										for t := columna - 1 to (columna + 1) do
										begin
											if celdas[fila + 1,t].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila + 1,t].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
									end;
								end;
							end
							else
							begin
								if (columna = 1) or (columna = topeColumna) then
								begin
									if columna = 1 then
									begin
										if tablero.topecolumna > 1 then
										begin
											if celdas[fila,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila,columna + 1].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
										if celdas[fila - 1,columna].estado = marcada then
												cont_marc := cont_marc + 1;
										if celdas[fila - 1,columna].estado = oculta then
												cont_ocul := cont_ocul + 1;
										if tablero.topeColumna > 1 then
										begin
											if celdas[fila - 1,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila - 1,columna + 1].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
									end
									else
									begin
										if celdas[fila,columna - 1].estado = marcada then
											cont_marc := cont_marc + 1;
										if celdas[fila,columna - 1].estado = oculta then
											cont_ocul := cont_ocul + 1;
										for t := columna - 1 to columna do
										begin
											if celdas[fila - 1,t].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[fila - 1,t].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
									end;
								end
								else
								begin
									if celdas[fila,columna - 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila,columna - 1].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if celdas[fila,columna + 1].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila,columna + 1].estado = oculta then
										cont_ocul := cont_ocul + 1;
									for t := columna - 1 to (columna + 1) do
									begin
										if celdas[fila - 1,t].estado = marcada then
											cont_marc := cont_marc + 1;
										if celdas[fila - 1,t].estado = oculta then
											cont_ocul := cont_ocul + 1;
									end;
								end;
							end;
						end
						else
						begin
							if (columna = 1) or (columna = topeColumna) then
							begin
								if columna = 1 then
								begin
									if celdas[fila + 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila + 1,columna].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if celdas[fila - 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila - 1,columna].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if tablero.topeColumna > 1 then
									begin
										for t := fila - 1 to (fila + 1) do
										begin
											if celdas[t,columna + 1].estado = marcada then
												cont_marc := cont_marc + 1;
											if celdas[t,columna + 1].estado = oculta then
												cont_ocul := cont_ocul + 1;
										end;
									end;
								end
								else
								begin
									if celdas[fila + 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila + 1,columna].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if celdas[fila - 1,columna].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila - 1,columna].estado = oculta then
										cont_ocul := cont_ocul + 1;
									for t := fila - 1 to (fila + 1) do
									begin
										if celdas[t,columna - 1].estado = marcada then
											cont_marc := cont_marc + 1;
										if celdas[t,columna - 1].estado = oculta then
											cont_ocul := cont_ocul + 1;
									end;
								end;
							end
							else
							begin
								if celdas[fila,columna - 1].estado = marcada then
									cont_marc := cont_marc + 1;
								if celdas[fila,columna - 1].estado = oculta then
									cont_ocul := cont_ocul + 1;
								if celdas[fila,columna + 1].estado = marcada then
									cont_marc := cont_marc + 1;
								if celdas[fila,columna + 1].estado = oculta then
									cont_ocul := cont_ocul + 1;
								for t := columna - 1 to (columna + 1) do
								begin
									if celdas[fila - 1,t].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila - 1,t].estado = oculta then
										cont_ocul := cont_ocul + 1;
									if celdas[fila + 1,t].estado = marcada then
										cont_marc := cont_marc + 1;
									if celdas[fila + 1,t].estado = oculta then
										cont_ocul := cont_ocul + 1;
								end;
							end;
						end;
						if (celdas[fila,columna].BombasCircundantes = cont_marc + cont_ocul) then
							valido := true;
						if valido then			{ si se cumple la condicion se marcan las celdas circundantes }
						begin
							if (fila = 1) or (fila = topeFila) then
							begin
								if fila = 1 then
								begin
									if (columna = 1) or (columna = topeColumna) then
									begin
										if columna = 1 then
										begin
											if tablero.topeColumna > 1 then
											begin
												if celdas[fila,columna + 1].estado = oculta then
												begin
													columna := columna + 1;	
													Marcar(juego,posicion);
													columna := columna - 1;
												end;
											end;
											if tablero.topeFila > 1 then
											begin
												if celdas[fila + 1,columna].estado = oculta then
												begin
													fila := fila + 1;
													Marcar(juego,posicion);
													fila := fila - 1;
												end;
											end;
											if (tablero.topeFila > 1) and (tablero.topeColumna > 1) then
											begin
												if celdas[fila + 1,columna + 1].estado = oculta then
												begin
													fila := fila + 1;
													columna := columna + 1;
													Marcar(juego,posicion);
													fila := fila - 1;
													columna := columna - 1;
												end;
											end;											
										end
										else
										begin
											if celdas[fila,columna - 1].estado = oculta then
											begin
												columna := columna - 1;
												Marcar(juego,posicion);
												columna := columna + 1;
											end;	
											if tablero.topeFila > 1 then
											begin
												for t := columna - 1 to columna do
													if celdas[fila + 1,t].estado = oculta then
													begin
														fila := fila + 1;
														columna := t;
														Marcar(juego,posicion);
														fila := fila - 1;
													end;
											end;
										end;  
								    end
									else
									begin
										if celdas[fila,columna - 1].estado = oculta then
										begin
											columna := columna - 1;
											Marcar(juego,posicion);
											columna := columna + 1;
										end;
										if celdas[fila,columna + 1].estado = oculta then
										begin
											columna := columna + 1;
											Marcar(juego,posicion);
											columna := columna - 1;
										end;
										if tablero.topeFila > 1 then
										begin
											for t := columna - 1 to (columna + 1) do
												if celdas[fila + 1,t].estado = oculta then
												begin
													fila := fila + 1;
													columna := t;
													Marcar(juego,posicion);
													fila := fila - 1;
												end;
										end;
									end;
								end
								else
								begin
									if (columna = 1) or (columna = topeColumna) then
									begin
										if columna = 1 then
										begin
											if tablero.topeColumna > 1 then
											begin
												if celdas[fila,columna + 1].estado = oculta then
												begin
													columna := columna + 1;
													Marcar(juego,posicion);
													columna := columna - 1;
												end;
											end;
											if celdas[fila - 1,columna].estado = oculta then
											begin
												fila := fila - 1;
												Marcar(juego,posicion);
												fila := fila + 1;
											end;
											if tablero.topeColumna > 1 then
											begin
												if celdas[fila - 1,columna + 1].estado = oculta then
												begin
													fila := fila - 1;
													columna := columna + 1;
													Marcar(juego,posicion);
													fila := fila + 1;
													columna := columna - 1;
												end;
											end;
										end
										else
										begin
											if celdas[fila,columna - 1].estado = oculta then
											begin
												columna := columna - 1;
												Marcar(juego,posicion);
												columna := columna + 1;
											end;
											for t := columna - 1 to columna do
												if celdas[fila - 1,t].estado = oculta then
												begin
													fila := fila - 1;
													columna := t;
													Marcar(juego,posicion);
													fila := fila + 1;
												end;
										end;
									end
									else
									begin
										if celdas[fila,columna - 1].estado = oculta then
										begin
											columna := columna - 1;
											Marcar(juego,posicion);
											columna := columna + 1;
										end;
										if celdas[fila,columna + 1].estado = oculta then
										begin
											columna := columna + 1;
											Marcar(juego,posicion);
											columna := columna - 1;
										end;
										for t := columna - 1 to (columna + 1) do
											if celdas[fila - 1,t].estado = oculta then
											begin
												fila := fila - 1;
												columna := t;
												Marcar(juego,posicion);
												fila := fila + 1;
											end;
									end;
								end;
							end
							else
							begin
								if (columna = 1) or (columna = topeColumna) then
								begin
									if columna = 1 then
									begin
										if celdas[fila + 1,columna].estado = oculta then
										begin
											fila := fila + 1;
											Marcar(juego,posicion);
											fila := fila - 1;
										end;
										if celdas[fila - 1,columna].estado = oculta then
										begin
											fila := fila - 1;
											Marcar(juego,posicion);
											fila := fila + 1;
										end;
										if tablero.topeColumna > 1 then
										begin
											for t := fila - 1 to (fila + 1) do
												if celdas[t,columna + 1].estado = oculta then
												begin
													fila := t;
													columna := columna + 1;
													Marcar(juego,posicion);
													columna := columna - 1;
												end;
										end;
									end
									else
									begin
										if celdas[fila + 1,columna].estado = oculta then
										begin
											fila := fila + 1;
											Marcar(juego,posicion);
											fila := fila - 1;
										end;
										if celdas[fila - 1,columna].estado = oculta then
										begin
											fila := fila - 1;
											Marcar(juego,posicion);
											fila := fila + 1;
										end;
										for t := fila - 1 to (fila + 1) do
											if celdas[t,columna - 1].estado = oculta then
											begin
												fila := t;
												columna := columna - 1;
												Marcar(juego,posicion);
												columna := columna + 1;
											end;
									end;
								end
								else
								begin
									if celdas[fila,columna - 1].estado = oculta then
									begin
										columna := columna - 1;
										Marcar(juego,posicion);
										columna := columna + 1;
									end;
									if celdas[fila,columna + 1].estado = oculta then
									begin
										columna := columna + 1;
										Marcar(juego,posicion);
										columna := columna - 1;
									end;
									for t := columna - 1 to (columna + 1) do
									begin
										if celdas[fila - 1,t].estado = oculta then
										begin
											fila := fila - 1;
											columna := t;
											Marcar(juego,posicion);
											fila := fila + 1;
										end;
										if celdas[fila + 1,t].estado = oculta then
										begin
											fila := fila + 1;
											columna := t;
											Marcar(juego,posicion);
											fila := fila - 1;
										end;
									end;
								end;
							end;
						end;				
					end;					
				end;	
			end;		
		end;
   
end;     { MarcarCircundantes }
   


procedure DescubrirSegura(var juego: TipoJuego);
var
		termino,termino2 : boolean;
		posicion : TipoPosicion;
begin
		termino := false;
		with posicion do
		begin
			fila := 1;			{ se inicia la posicion en la primer celda }
			columna := 1;
			with juego do
			begin
				repeat
					termino2 := false;
					if (tablero.celdas[fila,columna].estado = oculta) then
					begin
						if tablero.celdas[fila,columna].tieneBomba = false then
						begin	
							Descubrir(juego,posicion);
							termino := true;
					    end;
					end;
					if (columna = tablero.topeColumna) and (fila = tablero.topeFila) then
						termino := true;
					if (columna = tablero.topeColumna) and (not termino) then
					begin
						fila := fila + 1;
						columna := 1;
						termino2 := true;
					end;
					if not termino then
						columna := columna + 1;
					if termino2 then
						columna := columna - 1;

				until termino; { termina cuando se recorre todo el tablero o se descubre una celda segura }
			end;
		end;
end;	{ DescubrirSegura }
						



(*********************************************)
(* Procedimientos y funciones de la Interfaz *)
(*********************************************)


procedure iniciarInterfaz(var interfaz :TipoInterfaz);
begin
   with interfaz do
   begin
      posicion.fila := 1;
      posicion.columna := 1;
      modo := normal;
   end
end;




procedure iniciarHistorial(var historial :TipoHistorial);
begin
   historial := nil;
end;



(* Agregar la ultima accion realizada, y sobre que juego se
   realizo, al final del historial *)
procedure agregarAlFinalDelHistorial(var historial:TipoHistorial;
                                     juego:TipoJuego; accion:TipoAccion);
var aux1, aux2 :TipoHistorial;
begin
   (* creo un suceso nuevo *)
   new(aux1);
   (* cargo el suceso *)
   aux1^.juego := juego;
   aux1^.accion := accion;
   aux1^.siguiente := nil;
   if historial = nil then
      historial := aux1
   else
   begin
      aux2 := historial;
      (* busco el ultimo del historial *)
      while aux2^.siguiente <> nil do
         aux2 := aux2^.siguiente;
      aux2^.siguiente := aux1;
   end;
end;




function estaVacioElHistorial( historial:TipoHistorial):Boolean;
begin
   estaVacioElHistorial := historial = nil;
end;




procedure borrarPrimeroDelHistorial(var historial:TipoHistorial);
var aux :TipoHistorial;
begin
   if not estaVacioElHistorial(historial) then
   begin
      aux := historial;
      historial := historial^.siguiente;
      dispose(aux);
   end
end;




procedure borrarUltimoDelHistorial(var historial:TipoHistorial);
var aux : TipoHistorial;
begin
   if not estaVacioElHistorial(historial) then
      if historial^.siguiente = nil then
         begin
         dispose(historial);
         historial := nil;
         end
      else (* busco el penultimo *)
         begin
         aux := historial;
         while aux^.siguiente^.siguiente <> nil do
            aux := aux^.siguiente;
         dispose(aux^.siguiente);
         aux^.siguiente := nil;
         end
end;




procedure obtenerPrimerAccionDelHistorial(historial :TipoHistorial;
                                         var accion :TipoAccion);
begin
   if historial <> nil then
   begin
      accion := historial^.accion;
   end
end;




procedure obtenerPrimerJuegoDelHistorial(historial :TipoHistorial;
                                         var juego :TipoJuego);
begin
   if historial <> nil then
   begin
      juego := historial^.juego;
   end
end;




procedure obtenerUltimoJuegoDelHistorial(historial :TipoHistorial;
                                         var juego :TipoJuego);
begin
   if historial <> nil then
   begin
      (* busco el ultimo del historial *)
      while historial^.siguiente <> nil do
         historial := historial^.siguiente;
      juego := historial^.juego;
   end
end;




procedure imprimirLineaHorizontal(var archivo :Text; largo:Integer);
var i :Integer;
begin
   for i:=1 to largo do
      write(archivo,'-');
   writeln(archivo);
end;




(* Solicta al usuario la cantidad de filas, columnas y bombas; o
   si desea cargar el juego desde un archvio *)
procedure solicitarConfigInicial(var filas, columnas, bombas: Integer;
                                 var cargarDesdeArchivo :Boolean);
var c :Char;
begin

   repeat
      ClrScr;
      writeln('- BUSCAMINAS -   Opciones                         ');
      imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
      writeln('                                                  ');
      writeln('   1) facil (tablero de 10x5 con 5 bombas)        ');
      writeln('                                                  ');
      writeln('   2) intermedio (tablero de 10x20 con 25 bombas) ');
      writeln('                                                  ');
      writeln('   3) dificil (tablero de 15x20 con 40 bombas)    ');
      writeln('                                                  ');
      writeln('   4) cargar juego desde un archivo               ');
      writeln('                                                  ');
      writeln('                                                  ');
      write(  '   Ingrese una opcion: ');
      readln(c);
   until (c = '1') or (c = '2') or (c = '3') or (c = '4');

   case c of
   '1': begin
        filas    := 10;
        columnas := 5;
        bombas   := 5;
        cargarDesdeArchivo := False;
        end;
   '2': begin
        filas    := 10;
        columnas := 20;
        bombas   := 25;
        cargarDesdeArchivo := False;
        end;
   '3': begin
        filas    := 15;
        columnas := 20;
        bombas   := 40;
        cargarDesdeArchivo := False;
        end;
   '4': begin
        cargarDesdeArchivo := True;
        end;
   end;
end;




procedure mostrarCelda( var salida: Text; celda:TipoCelda;
                        enFoco:Boolean; modo:TipoModo);
begin
   if enFoco then highVideo;
   case celda.estado of
   oculta:      if modo=normal then
                   write(salida,' ',CELDA_OCULTA,' ')
                else
                   if celda.tieneBomba then
                      write(salida,' ',CELDA_OCULTA,CELDA_CON_BOMBA)
                   else
                      write(salida,' ',CELDA_OCULTA,celda.bombasCircundantes);

   marcada:     if modo=normal then
                   write(salida,' ',CELDA_MARCADA,' ')
                else
                   if celda.tieneBomba then
                      write(salida,' ',CELDA_MARCADA,CELDA_CON_BOMBA)
                   else
                      write(salida,' ',CELDA_MARCADA,celda.bombasCircundantes);

   descubierta: if celda.tieneBomba then
                   begin
                   highVideo;
                   write(salida,' ',CELDA_CON_BOMBA,' ');
                   normVideo;
                   end
                else
                   if celda.bombasCircundantes = 0  then
                      write(salida,' ',CELDA_VACIA,' ')
                   else
                      write(salida,' ',celda.bombasCircundantes,' ');
   end;
   normVideo;
end;




procedure mostrarTablero( var salida :Text; juego :TipoJuego;
                          interfaz :TipoInterfaz);
var i,j,a,b  :Integer;
    tab      :TipoTablero;
    resaltar :Boolean;
begin
   tab := juego.tablero;
   a   := interfaz.posicion.fila;
   b   := interfaz.posicion.columna;

   for i:=1 to tab.topeFila do
   begin
      for j:=1 to tab.topeColumna do
      begin
         resaltar := (abs(i-a) <= 1) and (abs(j-b) <= 1);
         mostrarCelda(salida, juego.tablero.celdas[i,j],
                      resaltar, interfaz.modo);
      end;
      writeln(salida);
   end
end;




procedure mostrarPantalla( juego :TipoJuego; interfaz :TipoInterfaz);
var pos   :TipoPosicion;
    total :Integer;
begin

   pos := interfaz.posicion;

   ClrScr;

   (* Muestro la barra superior *)
   write('- BUSCAMINAS - ');
   case juego.estado of
      jugando: writeln('   Presione la tecla "h" para obtener ayuda');
      ganado:  begin
               highVideo;
               writeln('   FELICITACIONES HA GANADO');
               normVideo;
               end;
      perdido: begin
               highVideo;
               writeln('   LAMENTABLEMENTE HA PERDIDO');
               normVideo;
               end;
   end;
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);

   (* Mustro el tablero *)
   mostrarTablero(output, juego, interfaz);


   (* Muestro la barra inferior *)
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
   with juego do
   begin
      total := tablero.topeFila * tablero.topeColumna;
      write('(',pos.fila:2,',',pos.columna:2,')');
      write(', ',bombas:2,' bombas, ',marcadas:2,' marcadas');
      write(', ',descubiertas:3,' descubiertas, ',total:3,' total');
      GoTOXY(3*(pos.columna-1)+2,pos.fila+2);
   end
end;





procedure actualizarPantalla( accion :TipoAccion; juego :TipoJuego;
                              interfaz :TipoInterfaz);
begin

   case accion.tipo of

   accSalir:
         ClrScr;

   accMarcar,accDesmarcar,accMarcCircunds,
   accDescubrir,accDespCircunds:
         mostrarPantalla(juego,interfaz);

{  accMoverArr,accMoverIzq,accMoverDer,accMoverBaj:
      Para solucionar los problemas de actulizacion de la pantalla,
      cuando se ejecuta en windows, podría implementar que solo refresce
      solo la celdas donde se cambio de posición.
      Para las demas acciones es necesario actauliazar toda la pantalla,
      para reflejar el contenido tablero completo luego realizar cada accion.
      Dado que el "motor" esta implementado por otro.
}
   else
         mostrarPantalla(juego,interfaz);
   end;

end;




procedure mover( accion :TipoAccion; juego:TipoJuego;
                 var interfaz:TipoInterfaz);
var pos :TipoPosicion;
begin
   pos := interfaz.posicion;
   with juego.tablero do
   begin
      case accion.tipo of
         accMoverIzq: if (1 <= pos.columna-1) then
                         pos.columna := pos.columna-1;
         accMoverDer: if (pos.columna+1 <= topeColumna) then
                         pos.columna := pos.columna+1;
         accMoverArr: if (1 <= pos.fila-1) then
                         pos.fila := pos.fila-1;
         accMoverBaj: if (pos.fila+1 <= topeFila) then
                         pos.fila := pos.fila+1;
      end;
   end;
   interfaz.posicion := pos;
end;




procedure pasarAModoDebug(var interfaz :TipoInterfaz);
begin
   interfaz.modo := debug;
end;




procedure pasarAModoNormal(var interfaz :TipoInterfaz);
begin
   interfaz.modo := normal;
end;




procedure mostrarAyuda();
begin
   ClrScr;

   writeln('- BUSCAMINAS -    Ayuda');
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
   writeln(' Use las flechas para moverse sobre el tablero.    ');
   writeln('                                                   ');
   writeln(' Posicionado sobre una celda presione:             ');
   writeln('   "b" para marcar con bomba                       ');
   writeln('   "v" para desmarcar                              ');
   writeln('   "m" para marcar circundantes                    ');
   writeln('   "d" para descubrir                              ');
   writeln('   "j" para despejar circundantes                  ');
   writeln('   "s" para descubrir una celda segura             ');
   writeln('                                                   ');
   writeln(' Presionando las tecla:                            ');
   writeln('   "x" para pasar a modo debug                     ');
   writeln('   "z" para pasar a modo normal                    ');
   writeln('   "a" para volver atras la ultima accion          ');
   writeln('   "c" para cargar el juego desde un archivo       ');
   writeln('   "g" para guardar el juego en un archivo         ');
   writeln('   "f" para guardar el historial en un archvivo    ');
   writeln('   "q" para salir del juego                        ');
   writeln('                                                   ');
   writeln(' Presione cualquier tecla para salir de la ayuda.  ');

   readkey;
end;




procedure guardarAccion(var archivo :Text; accion :TipoAccion);
begin
   writeln(archivo,'ACCION');
   case accion.tipo of
   accMarcar:       writeln(archivo,'b ',
                            accion.posicion.fila,' ',
                            accion.posicion.columna,' ',
                            'Marcar');
   accDesmarcar:    writeln(archivo,'v ',
                            accion.posicion.fila,' ',
                            accion.posicion.columna,' ',
                            'Desmarcar');
   accMarcCircunds: writeln(archivo,'m ',
                            accion.posicion.fila,' ',
                            accion.posicion.columna,' ',
                            'Marcar circundantes');
   accDescubrir:    writeln(archivo,'d ',
                            accion.posicion.fila,' ',
                            accion.posicion.columna,' ',
                            'Descubrir');
   accDespCircunds: writeln(archivo,'j ',
                            accion.posicion.fila,' ',
                            accion.posicion.columna,' ',
                            'Despejar circundantes');
   accDescSegura:   writeln(archivo,'s Descubrir segura');

   accCargarJuegoDesdeUnArchivo:  writeln(archivo,'c Cargar juego desde un archivo');
   end;
end;




procedure guardarJuego(var archivo :Text; juego :TipoJuego);
var interfaz :TipoInterfaz;
begin
   interfaz.posicion.fila := 1;
   interfaz.posicion.columna := 1;

   imprimirLineaHorizontal(archivo,3*juego.tablero.topeColumna);
   writeln(archivo,'JUEGO');
   case juego.estado of
      jugando:  writeln(archivo,'j = Jugando');
      ganado:   writeln(archivo,'g = Ganado');
      perdido:  writeln(archivo,'p = Perdido');
   end;
   writeln(archivo,juego.tablero.topeFila,' filas');
   writeln(archivo,juego.tablero.topeColumna,' columnas');
   writeln(archivo,juego.bombas,' bombas');
   writeln(archivo,juego.marcadas,' marcadas');
   writeln(archivo,juego.descubiertas,' descubiertas');
   imprimirLineaHorizontal(archivo,3*juego.tablero.topeColumna);

   interfaz.modo:= debug;
   mostrarTablero(archivo,juego, interfaz);
   imprimirLineaHorizontal(archivo,3*juego.tablero.topeColumna);

end;




procedure cargarJuego(var archivo :Text; var juego :TipoJuego);
var c :Char;
    n,i,j :Integer;
begin

   readln(archivo);
   readln(archivo);

   (* cargo el estado del juego *)
   readln(archivo,c);
   case c of
      'j','J': juego.estado := jugando;
      'g','G': juego.estado := ganado;
      'p','P': juego.estado := perdido;
   end;

   (* cargo los topes *)
   readln(archivo,n);
   juego.tablero.topeFila := n;
   readln(archivo,n);
   juego.tablero.topeColumna := n;

   (* cargo los contadores *)
   readln(archivo,n);
   juego.bombas := n;
   readln(archivo,n);
   juego.marcadas := n;
   readln(archivo,n);
   juego.descubiertas := n;

   readln(archivo);
   with juego.tablero do
   begin
      for i:=1 to juego.tablero.topeFila do
      begin
         for j:=1 to juego.tablero.topeColumna do
         begin
            read(archivo,c);
            read(archivo,c);
            case c of

            CELDA_OCULTA:
               begin
                  celdas[i,j].estado := oculta;
                  read(archivo,c);
                  case c of
                     CELDA_CON_BOMBA: celdas[i,j].tieneBomba := True;
                  else
                     begin
                     celdas[i,j].tieneBomba := False;
                     if c=CELDA_VACIA then
                        celdas[i,j].bombasCircundantes := 0
                     else
                        celdas[i,j].bombasCircundantes := ord(c)-ord('0');
                     end
                  end;
               end;

            CELDA_MARCADA:
               begin
                  celdas[i,j].estado := marcada;
                  read(archivo,c);
                  case c of
                     CELDA_CON_BOMBA: celdas[i,j].tieneBomba := True;
                  else
                     begin
                     celdas[i,j].tieneBomba := False;
                     if c=CELDA_VACIA then
                        celdas[i,j].bombasCircundantes := 0
                     else
                        celdas[i,j].bombasCircundantes := ord(c)-ord('0');
                     end
                  end;
               end;

            CELDA_CON_BOMBA:
               begin
                  celdas[i,j].estado := descubierta;
                  celdas[i,j].tieneBomba := True;
                  read(archivo,c);
               end;

            CELDA_VACIA:
               begin
                  celdas[i,j].estado := descubierta;
                  celdas[i,j].tieneBomba := False;
                  celdas[i,j].bombasCircundantes := 0;
                  read(archivo,c);
               end;

            else
               begin
                  celdas[i,j].estado := descubierta;
                  celdas[i,j].tieneBomba := False;
                  celdas[i,j].bombasCircundantes := ord(c)-ord('0');
                  read(archivo,c);
               end;
            end;
         end;
         readln(archivo);
      end;
   end;
end;



procedure solicitarNombreDeArchivo(var nombre :String);
begin
   ClrScr;
   writeln('- BUSCAMINAS -    ');
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
   writeln('                                                             ');
   writeln(' El nombre del archivo debe estar formado por caracteres     ');
   writeln(' alfanumericos, el "." y/o el "-". No debe contener espacios.');
   writeln('                                                             ');
   writeln('                                                             ');
   write(' Ingrese el nombre del archivo: ');
   readln(nombre);
end;




procedure cargarJuegoDesdeUnArchivo( var juego :TipoJuego);
var archivo :Text;
    nombre  :String;
begin
   solicitarNombreDeArchivo(nombre);
   ClrScr;
   writeln('- BUSCAMINAS -    ');
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
   if not fileExists(nombre) then
      begin
      writeln('                                                               ');
      writeln(' El archivo: "',nombre,'" no existe.');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln(' Presione cualquier tecla para continuar.');
      readkey;
      end
   else
      begin
      assign(archivo,nombre);
      reset(archivo);
      cargarJuego(archivo,juego);
      close(archivo);
      end
end;




procedure guardarJuegoEnUnArchivo(juego :TipoJuego );
var archivo :Text;
    nombre  :String;
    guardar :Boolean;
    c :Char;
begin
   solicitarNombreDeArchivo(nombre);

   ClrScr;
   writeln('- BUSCAMINAS -    ');
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
   if fileExists(nombre) then
      begin
      writeln('                                                               ');
      writeln(' El archivo: "',nombre,'" ya existe.');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln('                                                               ');
      write(' Desea sobreescrbirlo? (s=SI, n=No): ');
      readln(c);
      guardar := (c = 's') or (c = 'S');
      end
   else
      guardar := true;

   if guardar then
      begin
      assign(archivo,nombre);
      rewrite(archivo);
      guardarJuego(archivo,juego);
      close(archivo);
      end;
end;




procedure guardarHistorialEnUnArchivo( juego :TipoJuego;
                                       historial:TipoHistorial);
var archivo :Text;
    nombre  :String;
    guardar :Boolean;
    c :Char;
    juegoHist  :TipoJuego;
    accionHist :TipoAccion;
begin
   solicitarNombreDeArchivo(nombre);

   ClrScr;
   writeln('- BUSCAMINAS -    ');
   imprimirLineaHorizontal(output,3*MAX_COLUMNAS);
   if fileExists(nombre) then
      begin
      writeln('                                                               ');
      writeln(' El archivo: "',nombre,'" ya existe.');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln('                                                               ');
      writeln('                                                               ');
      write(' Desea sobreescrbirlo? (s=SI, n=No): ');
      readln(c);
      guardar := (c = 's') or (c = 'S');
      end
   else
      guardar := true;

   if guardar then
      begin
      assign(archivo,nombre);
      rewrite(archivo);

      while historial <> nil do
      begin
         obtenerPrimerJuegoDelHistorial(historial,juegoHist);
         obtenerPrimerAccionDelHistorial(historial,accionHist);
         historial := historial^.siguiente;

         guardarJuego(archivo,juegoHist);
         guardarAccion(archivo,accionHist);
      end;
      guardarJuego(archivo,juego);

      close(archivo);
      end;
end;




procedure obtenerAccion(var accion :TipoAccion; interfaz:TipoInterfaz);
var c :Char;
begin
   c := readkey;
   case c of
      'b','B':  begin
                   accion.tipo := accMarcar;
                   accion.posicion := interfaz.posicion
                end;
      'v','V':  begin
                   accion.tipo := accDesmarcar;
                   accion.posicion := interfaz.posicion
                end;
      'm','M':  begin
                   accion.tipo := accMarcCircunds;
                   accion.posicion := interfaz.posicion
                end;
      'd','D':  begin
                   accion.tipo := accDescubrir;
                   accion.posicion := interfaz.posicion
                end;
      'j','J':  begin
                   accion.tipo := accDespCircunds;
                   accion.posicion := interfaz.posicion
                end;
      's','S':  accion.tipo := accDescSegura;
      '8':      accion.tipo := accMoverArr;
      '4':      accion.tipo := accMoverIzq;
      '6':      accion.tipo := accMoverDer;
      '2':      accion.tipo := accMoverBaj;
      TECLA_EXTENDIDA:
                begin
                   c := readkey;
                   case c of
                   FLECHA_ARR: accion.tipo := accMoverArr;
                   FLECHA_IZQ: accion.tipo := accMoverIzq;
                   FLECHA_DER: accion.tipo := accMoverDer;
                   FLECHA_BAJ: accion.tipo := accMoverBaj;
                   end;
                end;
      'h','H':  accion.tipo := accMostrarAyuda;
      'x','X':  accion.tipo := accModoDebug;
      'z','Z':  accion.tipo := accModoNormal;
      'a','A':  accion.tipo := accDeshacer;
      'c','C':  accion.tipo := accCargarJuegoDesdeUnArchivo;
      'g','G':  accion.tipo := accGuardarJuegoEnUnArchivo;
      'f','F':  accion.tipo := accGuardarHistorialEnUnArchivo;
      'q','Q':  accion.tipo := accSalir;
      else
                accion.tipo := accNinguna;
   end;
end;




procedure realizarAccion( accion :TipoAccion; var juego:TipoJuego;
                          var interfaz:TipoInterfaz;
                          var historial:TipoHistorial);
begin
   case accion.tipo of

      accMarcar:        if juego.estado = jugando then
                           begin
                           agregarAlFinalDelHistorial(historial,juego,accion);
                           Marcar(juego,accion.posicion);
                           end;

      accDesmarcar:     if juego.estado = jugando then
                           begin
                           agregarAlFinalDelHistorial(historial,juego,accion);
                           Desmarcar(juego,accion.posicion);
                           end;

      accMarcCircunds:  if juego.estado = jugando then
                           begin
                           agregarAlFinalDelHistorial(historial,juego,accion);
                           MarcarCircundantes(juego,accion.posicion);
                           end;

      accDescubrir:     if juego.estado = jugando then
                           begin
                           agregarAlFinalDelHistorial(historial,juego,accion);
                           Descubrir(juego,accion.posicion);
                           end;

      accDespCircunds:  if juego.estado = jugando then
                           begin
                           agregarAlFinalDelHistorial(historial,juego,accion);
                           DespejarCircundantes(juego,accion.posicion);
                           end;

      accDescSegura:    if juego.estado = jugando then
                           begin
                           agregarAlFinalDelHistorial(historial,juego,accion);
                           DescubrirSegura(juego);
                           end;

      accMoverIzq,
      accMoverDer,
      accMoverArr,
      accMoverBaj:      if juego.estado = jugando then
                           mover(accion,juego,interfaz);

      accModoDebug:     pasarAModoDebug(interfaz);

      accModoNormal:    pasarAModoNormal(interfaz);

      accDeshacer:      if not estaVacioElHistorial(historial) then
                           begin
                           obtenerUltimoJuegoDelHistorial(historial,juego);
                           borrarUltimoDelHistorial(historial);
                           end;

      accCargarJuegoDesdeUnArchivo:
                        begin
                        agregarAlFinalDelHistorial(historial,juego,accion);
                        cargarJuegoDesdeUnArchivo(juego);
                        end;

      accGuardarJuegoEnUnArchivo:
                        guardarJuegoEnUnArchivo(juego);

      accGuardarHistorialEnUnArchivo:
                        guardarHistorialEnUnArchivo(juego,historial);

      accMostrarAyuda:  mostrarAyuda();
   end;
end;




(* VARIABLES DEL PROGRAMA PRINCIPAL *)
var
   filas,columnas,bombas :Integer;
   juego     :TipoJuego;
   interfaz  :TipoInterfaz;
   historial :TipoHistorial;
   accion    :TipoAccion;
   cargarDesdeArchivo :Boolean;



(* PROGRAMA PRINCIPAL *)
begin

   (* Solicitamos la configuracion inicial al usuario,esta puede ser:
      - cuantas filas, columnas o bombas, y llamamos inicializar, o
      - cargar la configuracioń desde un archivo *)
   solicitarConfigInicial(filas,columnas,bombas,cargarDesdeArchivo);
   if cargarDesdeArchivo then
      cargarJuegoDesdeUnArchivo(juego)
   else
      IniciarJuego(juego,filas,columnas,bombas);

   (* Inicializamos la interfaz *)
   iniciarInterfaz(interfaz);

   (* Inicializamos la historia *)
   iniciarHistorial(historial);

   mostrarPantalla(juego,interfaz);

   repeat

      obtenerAccion(accion,interfaz);

      realizarAccion(accion,juego,interfaz,historial);

      actualizarPantalla(accion,juego,interfaz);

   until (accion.tipo = accSalir);
end.



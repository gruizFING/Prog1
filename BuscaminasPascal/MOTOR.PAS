    
    





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
						

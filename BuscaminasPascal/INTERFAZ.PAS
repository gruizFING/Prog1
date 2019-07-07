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

{$INCLUDE motor.pas}




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
               writeln('   FELICITACONES HA GANADO');
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



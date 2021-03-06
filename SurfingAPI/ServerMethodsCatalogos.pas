unit ServerMethodsCatalogos;

interface

uses System.SysUtils, System.Classes, System.Json,
    Datasnap.DSServer, Datasnap.DSAuth, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.DApt;

type
{$METHODINFO ON}
  TDMCatalogos = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    //Categorias
    function Categoria(const Emi: Integer; const Cat: String): TJSONObject;
    function UpdateCategoria(const AData: TJSONObject): TJSONObject;
    function AcceptCategoria(const AData: TJSONObject): TJSONObject;
    function CancelCategoria(const Emi: Integer; const Cat: String): TJSONObject;
    function Categorias(const Emi: Integer): TJSONObject;

    //Puestos
    function Puesto(const Emi: Integer; const Pue: String): TJSONObject;
    function UpdatePuesto(const AData: TJSONObject): TJSONObject;
    function AcceptPuesto(const AData: TJSONObject): TJSONObject;
    function CancelPuesto(const Emi: Integer; const Pue: String): TJSONObject;
    function Puestos(const Emi: Integer): TJSONObject;

  end;
{$METHODINFO OFF}

implementation



{$R *.dfm}


uses System.StrUtils, ServerDm;


{ TDBCategorias }


function TDMCatalogos.AcceptPuesto(const AData: TJSONObject): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text :=
      'Update Puestos ' +
      'Set Nombre=:xNom, ' +
      '    Descripcion=:xDes, ' +
      '    Categoria=:xCat, ' +
      '    Depende=:xDep, ' +
      '    ValorMinimo=:xVmi, ' +
      '    ValorMaximo=:xVma, ' +
      '    SATRiesgoPuesto=:xSrp, ' +
      '    Activo=:xAct ' +
      'Where Emisor=:xEmi and Puesto=:xPue ';
    Qry.Params.ParamByName('xEmi').Value := AData.Get('Emisor').JsonValue.Value;
    Qry.Params.ParamByName('xNom').Value := AData.Get('Nombre').JsonValue.Value;
    Qry.Params.ParamByName('xDes').Value := AData.Get('Descripcion').JsonValue.Value;
    Qry.Params.ParamByName('xCat').Value := AData.Get('Categoria').JsonValue.Value;
    Qry.Params.ParamByName('xDep').Value := AData.Get('Depende').JsonValue.Value;
    Qry.Params.ParamByName('xVmi').Value := AData.Get('ValorMinimo').JsonValue.Value;
    Qry.Params.ParamByName('xVma').Value := AData.Get('ValorMaximo').JsonValue.Value;
    Qry.Params.ParamByName('xSrp').Value := AData.Get('SATRiesgoPuesto').JsonValue.Value;
    Qry.Params.ParamByName('xAct').Value := AData.Get('Activo').JsonValue.Value;
    Qry.ExecSQL;
  finally
    Qry.DisposeOf;
  end;
  Result := AData.Clone as TJSONObject;
end;

function TDMCatalogos.CancelCategoria(const Emi: Integer;
  const Cat: String): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    try
    Qry.SQL.Text :=
      'Delete Categorias Where Emisor=:xEmi and Categoria=:xCat';
    Qry.Params.ParamByName('xEmi').Value := Emi;
    Qry.Params.ParamByName('xCat').Value := Cat;
    Qry.ExecSQL;
    except
      On Ex: Exception do begin
        Result.AddPair('CodError',TJSONNumber.Create(-1));
        Result.AddPair('Message', Ex.Message);
      end;
    end;
    Result.AddPair('CodError',TJSONNumber.Create(0));
    Result.AddPair('Message', 'Sin Errores');
  finally
    Qry.DisposeOf;
  end;
end;

function TDMCatalogos.CancelPuesto(const Emi: Integer;
  const Pue: String): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    try
    Qry.SQL.Text :=
      'Delete Puestos Where Emisor=:xEmi and Puesto=:xPue';
    Qry.Params.ParamByName('xEmi').Value := Emi;
    Qry.Params.ParamByName('xPue').Value := Pue;
    Qry.ExecSQL;
    except
      On Ex: Exception do begin
        Result.AddPair('CodError',TJSONNumber.Create(-1));
        Result.AddPair('Message', Ex.Message);
      end;
    end;
    Result.AddPair('CodError',TJSONNumber.Create(0));
    Result.AddPair('Message', 'Sin Errores');
  finally
    Qry.DisposeOf;
  end;
end;

function TDMCatalogos.Categoria(const Emi: Integer; const Cat: String): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text := 'Select * From Categorias Where emisor=:xEmi and categoria=:xCat';
    Qry.Params.ParamByName('xEmi').Value := Emi;
    Qry.Params.ParamByName('xCat').Value := Cat;
    Qry.Active := True;

    if (Not Qry.Eof) then begin
      Result.AddPair('Emisor', TJSONString.Create(Qry.FieldByName('Emisor').AsString));
      Result.AddPair('Categoria', TJSONString.Create(Qry.FieldByName('Categoria').AsString));
      Result.AddPair('Descripcion', TJSONString.Create(Qry.FieldByName('Descripcion').AsString));
      Result.AddPair('SalarioDiario', TJSONString.Create(Qry.FieldByName('SalarioDiario').AsString));
      Result.AddPair('Cuenta', TJSONString.Create(Qry.FieldByName('Cuenta').AsString));
      Result.AddPair('Activa', TJSONString.Create(Qry.FieldByName('Activa').AsString));
    end;

    Qry.Active := False;
  finally
    Qry.DisposeOf;
  end;
end;

function TDMCatalogos.Categorias(const Emi: Integer): TJSONObject;
var
  Qry : TFDQuery;
  ArregloJSON: TJSONArray;
  JSON: TJSONObject;
  JSONLista: TJSONObject;
  Index: Integer;
  n: Integer;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  ArregloJSON := TJSONArray.Create(nil);
  JSONLista := TJSONObject.Create(nil);
  JSONLista.AddPair('data',ArregloJSON);

  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text := 'Select * From Categorias Where emisor=:xEmi Order by Categoria';
    Qry.Params.ParamByName('xEmi').Value := Emi;
    Qry.Active := True;

    n:= Qry.RecordCount;

    for index := 0 to Qry.RecordCount-1 do begin
      JSON := TJSONObject.Create(nil);

      JSON.AddPair('Emisor', TJSONString.Create(Qry.FieldByName('Emisor').AsString));
      JSON.AddPair('Categoria', TJSONString.Create(Qry.FieldByName('Categoria').AsString));
      JSON.AddPair('Descripcion', TJSONString.Create(Qry.FieldByName('Descripcion').AsString));
      JSON.AddPair('SalarioDiario', TJSONString.Create(Qry.FieldByName('SalarioDiario').AsString));
      JSON.AddPair('Cuenta', TJSONString.Create(Qry.FieldByName('Cuenta').AsString));
      JSON.AddPair('Activa', TJSONString.Create(Qry.FieldByName('Activa').AsString));

      ArregloJSON.AddElement(JSON);

      Qry.Next;
    end;

    Result := JSONLista;

    Qry.Active := False;
  finally
    Qry.DisposeOf;
  end;

end;

function TDMCatalogos.Puesto(const Emi: Integer;
  const Pue: String): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text := 'Select * From Puestos Where emisor=:xEmi and puesto=:xPue';
    Qry.Params.ParamByName('xEmi').Value := Emi;
    Qry.Params.ParamByName('xPue').Value := Pue;
    Qry.Active := True;

    if (Not Qry.Eof) then begin
      Result.AddPair('Emisor', TJSONString.Create(Qry.FieldByName('Emisor').AsString));
      Result.AddPair('Puesto', TJSONString.Create(Qry.FieldByName('Puesto').AsString));
      Result.AddPair('Nombre', TJSONString.Create(Qry.FieldByName('Nombre').AsString));
      Result.AddPair('Descripcion', TJSONString.Create(Qry.FieldByName('Descripcion').AsString));
      Result.AddPair('Categoria', TJSONString.Create(Qry.FieldByName('Categoria').AsString));
      Result.AddPair('Depende', TJSONString.Create(Qry.FieldByName('Depende').AsString));
      Result.AddPair('ValorMinimo', TJSONString.Create(Qry.FieldByName('ValorMinimo').AsString));
      Result.AddPair('ValorMaximo', TJSONString.Create(Qry.FieldByName('ValorMaximo').AsString));
      Result.AddPair('SATRiesgoPuesto', TJSONString.Create(Qry.FieldByName('SATRiesgoPuesto').AsString));
      Result.AddPair('Activo', TJSONString.Create(Qry.FieldByName('Activo').AsString));
    end;

    Qry.Active := False;
  finally
    Qry.DisposeOf;
  end;
end;

function TDMCatalogos.Puestos(const Emi: Integer): TJSONObject;
var
  Qry : TFDQuery;
  ArregloJSON: TJSONArray;
  JSON: TJSONObject;
  JSONLista: TJSONObject;
  Index: Integer;
  n: Integer;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  ArregloJSON := TJSONArray.Create(nil);
  JSONLista := TJSONObject.Create(nil);
  JSONLista.AddPair('data',ArregloJSON);

  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text := 'Select * From Puestos Where emisor=:xEmi Order by Puesto';
    Qry.Params.ParamByName('xEmi').Value := Emi;
    Qry.Active := True;

    n:= Qry.RecordCount;

    for index := 0 to Qry.RecordCount-1 do begin
      JSON := TJSONObject.Create(nil);

      JSON.AddPair('Emisor', TJSONString.Create(Qry.FieldByName('Emisor').AsString));
      JSON.AddPair('Puesto', TJSONString.Create(Qry.FieldByName('Puesto').AsString));
      JSON.AddPair('Nombre', TJSONString.Create(Qry.FieldByName('Nombre').AsString));
      JSON.AddPair('Descripcion', TJSONString.Create(Qry.FieldByName('Descripcion').AsString));
      JSON.AddPair('Categoria', TJSONString.Create(Qry.FieldByName('Categoria').AsString));
      JSON.AddPair('Depende', TJSONString.Create(Qry.FieldByName('Depende').AsString));
      JSON.AddPair('ValorMinimo', TJSONString.Create(Qry.FieldByName('ValorMinimo').AsString));
      JSON.AddPair('ValorMaximo', TJSONString.Create(Qry.FieldByName('ValorMaximo').AsString));
      JSON.AddPair('SATRiesgoPuesto', TJSONString.Create(Qry.FieldByName('SATRiesgoPuesto').AsString));
      JSON.AddPair('Activo', TJSONString.Create(Qry.FieldByName('Activo').AsString));

      ArregloJSON.AddElement(JSON);

      Qry.Next;
    end;

    Result := JSONLista;

    Qry.Active := False;
  finally
    Qry.DisposeOf;
  end;
end;

function TDMCatalogos.UpdateCategoria(const AData: TJSONObject): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text :=
      'Insert into Categorias ' +
      '(Emisor, Categoria, Descripcion, SalarioDiario, Cuenta, Activa) ' +
      'Values ' +
      '(:xEmi, :xCat, :xDes, :xSDi, :xCue, :xAct)';
    Qry.Params.ParamByName('xEmi').Value := AData.Get('Emisor').JsonValue.Value;
    Qry.Params.ParamByName('xCat').Value := AData.Get('Categoria').JsonValue.Value;
    Qry.Params.ParamByName('xDes').Value := AData.Get('Descripcion').JsonValue.Value;
    Qry.Params.ParamByName('xSDi').Value := AData.Get('SalarioDiario').JsonValue.Value;
    Qry.Params.ParamByName('xCue').Value := AData.Get('Cuenta').JsonValue.Value;
    Qry.Params.ParamByName('xAct').Value := AData.Get('Activa').JsonValue.Value;
    Qry.ExecSQL;
  finally
    Qry.DisposeOf;
  end;
  Result := AData.Clone as TJSONObject;
end;

function TDMCatalogos.UpdatePuesto(const AData: TJSONObject): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text :=
      'Insert into Puestos ' +
      '(Emisor, Puesto, Nombre, Descripcion, Categoria, Depende, ValorMinimo, ValorMaximo, SATRiesgoPuesto, Activo) ' +
      'Values ' +
      '(:xEmi, :xPue, :xNom, :xDes, :xCat, :xDep, :xVmi, :xVma, :xSrp, :xAct)';
    Qry.Params.ParamByName('xEmi').Value := AData.Get('Emisor').JsonValue.Value;
    Qry.Params.ParamByName('xPue').Value := AData.Get('Puesto').JsonValue.Value;
    Qry.Params.ParamByName('xNom').Value := AData.Get('Nombre').JsonValue.Value;
    Qry.Params.ParamByName('xDes').Value := AData.Get('Descripcion').JsonValue.Value;
    Qry.Params.ParamByName('xCat').Value := AData.Get('Categoria').JsonValue.Value;
    Qry.Params.ParamByName('xDep').Value := AData.Get('Depende').JsonValue.Value;
    Qry.Params.ParamByName('xVmi').Value := AData.Get('ValorMinimo').JsonValue.Value;
    Qry.Params.ParamByName('xVma').Value := AData.Get('ValorMaximo').JsonValue.Value;
    Qry.Params.ParamByName('xSrp').Value := AData.Get('SATRiesgoPuesto').JsonValue.Value;
    Qry.Params.ParamByName('xAct').Value := AData.Get('Activo').JsonValue.Value;
    Qry.ExecSQL;
  finally
    Qry.DisposeOf;
  end;
  Result := AData.Clone as TJSONObject;
end;

function TDMCatalogos.AcceptCategoria(const AData: TJSONObject): TJSONObject;
var
  Qry : TFDQuery;
begin
  Result := TJSONObject.Create(nil);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dm.Conexion;
    Qry.SQL.Text :=
      'Update Categorias ' +
      'Set Descripcion=:xDes, ' +
      '    SalarioDiario=:xSDi, ' +
      '    Cuenta=:xCue, ' +
      '    Activa=:xAct ' +
      'Where Emisor=:xEmi and Categoria=:xCat ';
    Qry.Params.ParamByName('xEmi').Value := AData.Get('Emisor').JsonValue.Value;
    Qry.Params.ParamByName('xCat').Value := AData.Get('Categoria').JsonValue.Value;
    Qry.Params.ParamByName('xDes').Value := AData.Get('Descripcion').JsonValue.Value;
    Qry.Params.ParamByName('xSDi').Value := AData.Get('SalarioDiario').JsonValue.Value;
    Qry.Params.ParamByName('xCue').Value := AData.Get('Cuenta').JsonValue.Value;
    Qry.Params.ParamByName('xAct').Value := AData.Get('Activa').JsonValue.Value;
    Qry.ExecSQL;
  finally
    Qry.DisposeOf;
  end;
  Result := AData.Clone as TJSONObject;
end;

end.


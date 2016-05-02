(*
    EZ Webpay Configurator v1.0
    Helps configuring the file tbk_config.dat for Transbank Webpay KCC

    Copyright (C) 2016  Camilo Castro <camilo@ninjas.cl>
    https://github.com/NinjasCL/EzWebpayConfigurator

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)
unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls,  RegExpr, INIFiles, LCLType;

type

  { TMainForm }



  TCharSet = set of Char;

  TMainForm = class(TForm)

    openFileDialog: TOpenDialog;
    saveFileDatDialog: TSaveDialog;
    saveFileNiniDialog: TSaveDialog;
    serverIPTextField: TLabeledEdit;
    serverPortTextField: TLabeledEdit;
    copyrightLabel: TStaticText;
    urlVerifyScriptTextField: TLabeledEdit;
    urlCgiTextField: TLabeledEdit;
    serverEqualsKCCServerCheckbox: TCheckBox;
    exportButton: TButton;
    commerceIdTextField: TLabeledEdit;
    kccServerGroup: TGroupBox;
    kccServerIPTextField: TLabeledEdit;
    kccServerPortTextField: TLabeledEdit;
    serverDataGroup: TGroupBox;
    logoImage: TImage;
    newButton: TButton;
    saveButton: TButton;
    importButton: TButton;
    certificationAmbientOption: TRadioButton;
    commerceDataGroup: TGroupBox;
    actionsGroup: TGroupBox;
    commerceNameTextField: TLabeledEdit;
    productionAmbientOption: TRadioButton;
    sslOption: TRadioButton;
    redirectionOption: TRadioButton;
    ambientGroup: TRadioGroup;
    communicationGroup: TRadioGroup;

    procedure commerceIdTextFieldChange(Sender: TObject);
    procedure exportButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure importButtonClick(Sender: TObject);
    procedure kccServerIPTextFieldChange(Sender: TObject);
    procedure kccServerPortTextFieldChange(Sender: TObject);

    procedure newButtonClick(Sender: TObject);
    procedure saveButtonClick(Sender: TObject);
    procedure serverEqualsKCCServerCheckboxChange(Sender: TObject);
    procedure serverIPTextFieldChange(Sender: TObject);
    procedure serverPortTextFieldChange(Sender: TObject);

    procedure urlCgiTextFieldChange(Sender: TObject);

    procedure urlVerifyScriptTextFieldChange(Sender: TObject);

    function IsNumeric(Value: string; const AllowFloat: Boolean): Boolean;

    function StripChars(const aSrc, aCharsToStrip: string): string;

    function StringContainsCharactersInSet(const Value: string; const Chars: TCharSet): Boolean;

    function numericString(textParam: string) : string;
    function ipString(textParam: string) : string;
    function urlString(textParam: string) : string;
    function urlIsValid(urlParam:string) : boolean;

    function isIP4Valid(const pText: string): boolean;

    function formIsvalid(): boolean;

  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  MainViewController: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

(* Event Handlers *)

procedure TMainForm.serverEqualsKCCServerCheckboxChange(Sender: TObject);
begin
      kccServerGroup.enabled := not kccServerGroup.enabled;

      kccServerIPTextField.text := '';
      kccServerPortTextField.text := '';

      if not kccServerGroup.enabled then
      begin
          kccServerIPTextField.text := serverIPTextField.text;
          kccServerPortTextField.text := serverPortTextField.text;
      end;
end;

procedure TMainForm.serverIPTextFieldChange(Sender: TObject);
begin

  serverIPTextField.text := ipString(serverIPTextField.text);

  if serverEqualsKCCServerCheckbox.checked then
  begin
      kccServerIPTextField.text := serverIPTextField.text;
  end;
end;

procedure TMainForm.serverPortTextFieldChange(Sender: TObject);
begin

  serverPortTextField.text := numericString(serverPortTextField.text);

  if serverEqualsKCCServerCheckbox.checked then
  begin
      kccServerPortTextField.text := serverPortTextField.text;
  end;


end;

procedure TMainForm.newButtonClick(Sender: TObject);
var
  reply, boxstyle: integer;
begin

  boxstyle := MB_ICONQUESTION + MB_YESNO;
  reply := Application.MessageBox('¿Borrar toda la información?', 'Crear Nuevo Comercio', boxstyle);

  if reply = IDYES then
  begin
      commerceNameTextField.text := '';
      commerceIdTextField.text := '';
      urlCgiTextField.text := '';
      urlVerifyScriptTextField.text := '';

      serverIPTextField.text := '';
      serverPortTextField.text := '80';

      serverEqualsKCCServerCheckbox.checked := true;

      kccServerIPTextField.text := '';
      kccServerPortTextField.text := '80';

      certificationAmbientOption.checked := true;
      redirectionOption.checked := true;

      commerceNameTextField.SetFocus();
  end;


end;

procedure TMainForm.saveButtonClick(Sender: TObject);
var
  ini:TINIFile;
  filename:string;
  namespace:string;
begin

  filename := commerceNameTextField.text;
  namespace := 'Commerce';

  if length(filename) <= 0 then
  begin
       (* current time stamp *)
       filename := IntToStr(Trunc((Now - EncodeDate(1970, 1 ,1)) * 24 * 60 * 60));
  end;

  filename := concat(filename, '.nini');

  if saveFileNiniDialog.Execute then
  begin

    filename := saveFileNiniDialog.Filename;

    ini := TINIFile.Create(filename);

    ini.WriteString(namespace, 'Name', commerceNameTextField.text);
    ini.WriteString(namespace, 'Id', commerceIdTextField.text);

    ini.WriteString(namespace, 'URLCgi', urlCgiTextField.text);
    ini.WriteString(namespace, 'URLVerifyScript', urlVerifyScriptTextField.text);

    ini.WriteString(namespace, 'ServerIP', serverIPTextField.text);
    ini.WriteString(namespace, 'ServerPort', serverPortTextField.text);

    ini.WriteBool(namespace, 'ServersAreEqual', serverEqualsKCCServerCheckbox.Checked);

    ini.WriteString(namespace, 'KccServerIP',  kccServerIPTextField.text);
    ini.WriteString(namespace, 'KccServerPort', kccServerPortTextField.text);

    ini.WriteBool(namespace, 'AmbientCertification', certificationAmbientOption.Checked);
    ini.WriteBool(namespace, 'AmbientProduction', productionAmbientOption.Checked);

    ini.WriteBool(namespace, 'MedComRedirection', redirectionOption.Checked);
    ini.WriteBool(namespace, 'MedComSSL', sslOption.Checked);

  end;

end;


procedure TMainForm.commerceIdTextFieldChange(Sender: TObject);
begin
    commerceIdTextField.text := numericString(commerceIdTextField.text);
end;

procedure TMainForm.exportButtonClick(Sender: TObject);
var
  filename : string;
  line1, line2, line3, line4, line5, line6, line7, line8, line9 : string;
  line10, line11, line12, line13, line14, line15, line16: string;
begin

  if formIsValid() then
  begin


  if saveFileDatDialog.Execute then
  begin

    filename := saveFileDatDialog.Filename;

    line1 := 'IDCOMERCIO = ';

    if productionAmbientOption.checked then
    begin
      line1 := concat(line1, commerceIdTextField.text);
    end
    else
    begin
      // Its the default certification ambient number
      line1 := concat(line1, '597026007976');
    end;

    line2 := 'MEDCOM = ';

    if redirectionOption.checked then
    begin
      line2 := concat(line2, '2')
    end
    else
    begin
      line2 := concat(line2, '1');
    end;

    line3 := 'TBK_KEY_ID = 101';

    line4 := 'PARAMVERIFCOM = 1';

    line5 := 'URLCGICOM = ' + urlCgiTextField.text;

    line6 := 'SERVERCOM = ' + serverIPTextField.text;

    line7 := 'PORTCOM = ' + serverPortTextField.text;

    line8 := 'WHITELISTCOM = ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789./:=&?_-';

    line9 := 'HOST = ' + kccServerIPTextField.text;

    line10 := 'WPORT = ' + kccServerPortTextField.text;

    if certificationAmbientOption.checked then
    begin
      line11 := 'URLCGITRA = /filtroUnificado/bp_revision.cgi';
      line12 := 'URLCGIMEDTRA = /filtroUnificado/bp_validacion.cgi';
      line13 := 'SERVERTRA = https://certificacion.webpay.cl';
      line14 := 'PORTTRA = 6443';
    end
    else
    begin
      line11 := 'URLCGITRA = /cgi-bin/bp_revision.cgi';
      line12 := 'URLCGIMEDTRA = /cgi-bin/bp_validacion.cgi';
      line13 := 'SERVERTRA = https://webpay.transbank.cl';
      line14 := 'PORTTRA = 443';
    end;

    line15 := 'PREFIJO_CONF_TR = HTML_';
    line16 := 'HTML_TR_NORMAL = ' + urlVerifyScriptTextField.text;

    with TStringList.Create do
    begin
        try

          add(line1);
          add(line2);
          add(line3);
          add(line4);
          add(line5);
          add(line6);
          add(line7);
          add(line8);
          add(line9);
          add(line10);
          add(line11);
          add(line12);
          add(line13);
          add(line14);
          add(line15);
          add(line16);

          saveToFile(filename);
        finally
          Free;
        end;
    end;

  end;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  commerceNameTextField.SetFocus();
end;

procedure TMainForm.importButtonClick(Sender: TObject);

var
  ini:TINIFile;
  filename:string;
  namespace:string;
begin
  namespace := 'Commerce';

  if openFileDialog.Execute then
  begin
    filename := openFileDialog.Filename;


    ini := TINIFile.Create(filename);

    commerceNameTextField.text := ini.ReadString(namespace, 'Name', '');
    commerceIdTextField.text := ini.ReadString(namespace, 'Id', '');

    urlCgiTextField.text :=    ini.ReadString(namespace, 'URLCgi', '');
    urlVerifyScriptTextField.text := ini.ReadString(namespace, 'URLVerifyScript', '');

    serverIPTextField.text := ini.ReadString(namespace, 'ServerIP', '');
    serverPortTextField.text := ini.ReadString(namespace, 'ServerPort', '');

    serverEqualsKCCServerCheckbox.Checked := ini.ReadBool(namespace, 'ServersAreEqual', true);

    kccServerIPTextField.text := ini.ReadString(namespace, 'KccServerIP',  '');
    kccServerPortTextField.text := ini.ReadString(namespace, 'KccServerPort', '');

    certificationAmbientOption.Checked := ini.ReadBool(namespace, 'AmbientCertification', true);
    productionAmbientOption.Checked := ini.ReadBool(namespace, 'AmbientProduction', false);

    redirectionOption.Checked := ini.ReadBool(namespace, 'MedComRedirection', true);
    sslOption.Checked := ini.ReadBool(namespace, 'MedComSSL', false);

  end;

end;

procedure TMainForm.kccServerIPTextFieldChange(Sender: TObject);
begin
  kccServerIPTextField.text := ipString(kccServerIPTextField.text);
end;

procedure TMainForm.kccServerPortTextFieldChange(Sender: TObject);
begin

  kccServerPortTextField.text := numericString(kccServerPortTextField.text);

end;

procedure TMainForm.urlVerifyScriptTextFieldChange(Sender: TObject);
begin
  urlVerifyScriptTextField.text := urlString(urlVerifyScriptTextField.text);
end;

procedure TMainForm.urlCgiTextFieldChange(Sender: TObject);
begin
  urlCgiTextField.text := urlString(urlCgiTextField.text);
end;

(*
Helper Functions and Procedures
 Some code from https://www.rosettacode.org/
*)

function TMainForm.IsNumeric(Value: string; const AllowFloat: Boolean): Boolean;
var
  ValueInt: Integer;
  ValueFloat: Extended;
  ErrCode: Integer;
begin
// Check for integer: Val only accepts integers when passed integer param
Value := SysUtils.Trim(Value);
Val(Value, ValueInt, ErrCode);
Result := ErrCode = 0;      // Val sets error code 0 if OK
if not Result and AllowFloat then
    begin
    // Check for float: Val accepts floats when passed float param
    Val(Value, ValueFloat, ErrCode);
    Result := ErrCode = 0;    // Val sets error code 0 if OK
    end;
end;

function TMainForm.StripChars(const aSrc, aCharsToStrip: string): string;
var
  c: Char;
begin
  Result := aSrc;
  for c in aCharsToStrip do
    Result := StringReplace(Result, c, '', [rfReplaceAll, rfIgnoreCase]);
end;

function TMainForm.StringContainsCharactersInSet(const Value: string; const Chars: TCharSet): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to Length(Value) do
    if not (Value[I] in Chars) then
    begin
      Result := False;
      Exit;
    end;
end;

function TMainForm.numericString(textParam: string) : string;
var
  i: integer;
  buffer: string;
begin

buffer := '';

   for i:= 1 to length(textParam) do
   begin
       if isNumeric(textParam[i], false) then
       begin
         buffer := concat(buffer, textParam[i]);
       end;
   end;

   result := buffer;
end;

// from http://forum.lazarus.freepascal.org/index.php?topic=10863.15
function TMainForm.isIP4Valid(const pText: string): boolean;
var reg: TRegExpr;
    i  : integer;
begin
  // 1. Create a simple IP format matcher and evaluate the expression
  reg := TRegExpr.Create;
  reg.Expression := '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$';
  result := reg.Exec(pText);

  // 2. basic test for valid range of numbers (0..255)
  if result then
    for i := 1 to 4 do                       // 4 = the number of digit groups
      if StrToInt(reg.Match[i]) > 255 then   // numbers are in the range 0..255
        begin
          result := false;
          break
        end;

  // 3. Clean up
  reg.Free;
end;



function TMainForm.ipString(textParam: string) : string;
var
  i: integer;
  buffer: string;
  validChars: TCharSet;
begin
   buffer := '';
   validChars := ['0'..'9','.'];
   for i:= 1 to length(textParam) do
   begin
       if  StringContainsCharactersInSet(textParam[i], validChars) then
       begin
         buffer := concat(buffer, textParam[i]);
       end;
   end;

   result := buffer;

end;



function TMainForm.urlString(textParam: string) : string;
var
  i: integer;
  buffer: string;
  validChars: TCharSet;
begin
   buffer := '';
   validChars := ['0'..'9','.','a'..'z','A'..'Z','?','~','''','\','/',':','%','&','=',',','-','_'];
   for i:= 1 to length(textParam) do
   begin
       if  StringContainsCharactersInSet(textParam[i], validChars) then
       begin
         buffer := concat(buffer, textParam[i]);
       end;
   end;

   result := buffer;
end;

function TMainForm.urlIsValid(urlParam:string) : boolean;
var
  regexPattern : string;
  regex: TRegExpr;
begin
  // http://stackoverflow.com/questions/1128168/validation-for-url-domain-using-regex-rails
   regexPattern := '^(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?$/ix';

   regex := TRegExpr.Create;
   regex.Expression := regexPattern;

   result := regex.Exec(urlParam);

   regex.Free;
end;


function TMainForm.formIsValid() : boolean;
begin

  // TODO: Refactor Validation
  result := false;

  if length(commerceNameTextField.text) > 0 then
  begin
       if length(commerceIdTextField.text) > 0 then
       begin
          if isNumeric(commerceIdTextField.text, true) then
          begin
             if length(urlCgiTextField.text) > 0 then
             begin
              if urlIsValid(urlCgiTextField.text) then
              begin
               if length(urlVerifyScriptTextField.text) > 0 then
               begin
                  if urlIsValid(urlVerifyScriptTextField.text) then
                  begin
                      if length(serverIPTextField.text) > 0 then
                      begin
                            if isIP4Valid(serverIPTextField.text) then
                            begin
                                if length(serverPortTextField.text) > 0 then
                                begin
                                    if isNumeric(serverPortTextField.text, false) then
                                    begin
                                       if length(kccServerIPTextField.text) > 0 then
                                       begin
                                          if isIP4Valid(kccServerIPTextField.text) then
                                          begin
                                              if length(kccServerPortTextField.text) > 0 then
                                              begin
                                                     if isNumeric(kccServerPortTextField.text, false) then
                                                     begin
                                                      (* Success *)
                                                       result := true;
                                                     end
                                                     else
                                                     begin
                                                       showMessage('El Puerto del Servidor KCC Solamente puede tener Números.');
                                                     end;
                                              end
                                              else
                                              begin
                                                showMessage('El puerto del Servidor KCC Está Vacío.');
                                              end;
                                          end
                                          else
                                          begin
                                            showMessage('La IP del Servidor KCC Está Mal Formateada.');
                                          end;
                                       end
                                       else
                                       begin
                                         showMessage('IP del Servidor KCC Está Vacía.');
                                       end;
                                    end
                                    else
                                    begin
                                      showMessage('El Puerto del Servidor de Comercio Solamente puede tener Números.');
                                    end;
                                end
                                else
                                begin
                                  showMessage('Puerto del Servidor de Comercio Está Vacío.');
                                end;
                            end
                            else
                            begin
                              showMessage('IP del Servidor de Comercio Está mal Formateada.');
                            end;
                      end
                      else
                      begin
                        showMessage('IP del Servidor de Comercio Está Vacía.');
                      end;
                  end
                  else
                  begin
                    showMessage('URL del Archivo de Verificación Está mal Formateada.');
                  end;
               end
               else
               begin
                 showMessage('URL del Archivo de Verificación Está Vacía.');
               end;
              end
              else
              begin
                showMessage('URL del CGI Está mal Formateada.');
              end;
             end
             else
             begin
               showMessage('URL del CGI Está Vacía.');
             end;
          end
          else
          begin
            showMessage('Número de Identificación Debe ser un Número.');
          end;
       end
       else
           showMessage('Número de Identificación Está Vacío.');
       begin

       end;
  end
  else
  begin
       showMessage('El Nombre del Comercio Está Vacío.');
  end;

end;

end.

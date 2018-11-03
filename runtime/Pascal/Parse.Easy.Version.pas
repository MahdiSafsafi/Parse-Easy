// ----------- Parse::Easy::Runtime -----------
// https://github.com/MahdiSafsafi/Parse-Easy
// --------------------------------------------

unit Parse.Easy.Version;

interface

function GetMinorVersion(): Integer;
function GetMajorVersion(): Integer;

implementation

const
  MINOR_VERSION = 1;
  MAJOR_VERSION = 0;

function GetMinorVersion(): Integer;
begin
  Result := MINOR_VERSION;
end;

function GetMajorVersion(): Integer;
begin
  Result := MAJOR_VERSION;
end;

end.

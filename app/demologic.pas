unit DemoLogic;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TPreviewTheme = record
    Name: string;
    AccentColor: LongInt;
    SurfaceColor: LongInt;
  end;

function NormalizePreviewText(const RawText: string): string;
function GetThemeByIndex(Index: Integer): TPreviewTheme;
function BuildStatusText(const Theme: TPreviewTheme): string;

implementation

const
  PREVIEW_FALLBACK = 'Type something above';

  THEMES: array[0..2] of TPreviewTheme = (
    (Name: 'Ocean'; AccentColor: $00B07A; SurfaceColor: $00F3F8F8),
    (Name: 'Sunset'; AccentColor: $004A3B; SurfaceColor: $00F1E4FF),
    (Name: 'Forest'; AccentColor: $003C7A; SurfaceColor: $00E7F7EC)
  );

function CollapseWhitespace(const Value: string): string;
var
  Ch: Char;
  NeedsSpace: Boolean;
begin
  Result := '';
  NeedsSpace := False;
  for Ch in Trim(Value) do
  begin
    if Ch <= ' ' then
    begin
      NeedsSpace := Result <> '';
      Continue;
    end;

    if NeedsSpace then
    begin
      Result += ' ';
      NeedsSpace := False;
    end;

    Result += Ch;
  end;
end;

function NormalizePreviewText(const RawText: string): string;
begin
  Result := CollapseWhitespace(RawText);
  if Result = '' then
    Result := PREVIEW_FALLBACK;
end;

function PositiveModulo(Value, Divisor: Integer): Integer;
begin
  Result := Value mod Divisor;
  if Result < 0 then
    Result += Divisor;
end;

function GetThemeByIndex(Index: Integer): TPreviewTheme;
begin
  Result := THEMES[PositiveModulo(Index, Length(THEMES))];
end;

function BuildStatusText(const Theme: TPreviewTheme): string;
begin
  Result := 'Theme: ' + Theme.Name;
end;

end.

program DemoLogicTest;

{$mode objfpc}{$H+}

uses
  SysUtils, DemoLogic;

procedure AssertEqual(const Expected, Actual, MessageText: string);
begin
  if Expected <> Actual then
  begin
    WriteLn('FAIL: ', MessageText);
    WriteLn('Expected: ', Expected);
    WriteLn('Actual:   ', Actual);
    Halt(1);
  end;
end;

procedure AssertColorEqual(const Expected, Actual: LongInt; const MessageText: string);
begin
  if Expected <> Actual then
  begin
    WriteLn('FAIL: ', MessageText);
    WriteLn('Expected color: ', Expected);
    WriteLn('Actual color:   ', Actual);
    Halt(1);
  end;
end;

var
  Theme: TPreviewTheme;

begin
  AssertEqual('Lazarus Build Station', NormalizePreviewText('  Lazarus   Build Station  '),
    'NormalizePreviewText should trim and collapse whitespace');
  AssertEqual('Type something above', NormalizePreviewText(''),
    'NormalizePreviewText should provide a fallback text');

  Theme := GetThemeByIndex(4);
  AssertEqual('Sunset', Theme.Name, 'GetThemeByIndex should wrap around available themes');
  AssertColorEqual($004A3B, Theme.AccentColor, 'Wrapped theme should keep expected accent color');

  AssertEqual('Theme: Ocean', BuildStatusText(GetThemeByIndex(0)),
    'BuildStatusText should expose the selected theme');

  WriteLn('PASS');
end.

unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Graphics,
  BCButton, BGRAShape, DemoLogic;

type
  TDemoMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FAccentShape: TBGRAShape;
    FInputEdit: TEdit;
    FPreviewButton: TBCButton;
    FPreviewPanel: TPanel;
    FStatusLabel: TLabel;
    FThemeButtons: array[0..2] of TBCButton;
    FThemeIndex: Integer;
    procedure ApplyTheme(Index: Integer);
    procedure BuildUi;
    procedure InputChanged(Sender: TObject);
    procedure ThemeButtonClick(Sender: TObject);
    procedure UpdatePreview;
  end;

var
  DemoMainForm: TDemoMainForm;

implementation

{$R *.lfm}

procedure ConfigureButton(AButton: TBCButton; const ACaption: string; ALeft, ATop,
  AWidth, AHeight: Integer);
begin
  AButton.Parent := DemoMainForm;
  AButton.Caption := ACaption;
  AButton.SetBounds(ALeft, ATop, AWidth, AHeight);
  AButton.Font.Size := 11;
  AButton.Font.Style := [fsBold];
end;

procedure TDemoMainForm.FormCreate(Sender: TObject);
begin
  BuildUi;
  ApplyTheme(0);
  UpdatePreview;
end;

procedure TDemoMainForm.BuildUi;
var
  TitleLabel: TLabel;
  HintLabel: TLabel;
  PreviewTitle: TLabel;
  I: Integer;
  Theme: TPreviewTheme;
begin
  Caption := 'Lazarus Build Station Example';
  ClientWidth := 760;
  ClientHeight := 420;
  Constraints.MinWidth := 760;
  Constraints.MinHeight := 420;
  Position := poScreenCenter;

  TitleLabel := TLabel.Create(Self);
  TitleLabel.Parent := Self;
  TitleLabel.Caption := 'BGRA Controls in a tiny showcase';
  TitleLabel.Left := 24;
  TitleLabel.Top := 24;
  TitleLabel.Font.Size := 18;
  TitleLabel.Font.Style := [fsBold];

  HintLabel := TLabel.Create(Self);
  HintLabel.Parent := Self;
  HintLabel.Caption := 'Type a label, then switch themes to restyle the preview.';
  HintLabel.Left := 24;
  HintLabel.Top := 58;

  FInputEdit := TEdit.Create(Self);
  FInputEdit.Parent := Self;
  FInputEdit.SetBounds(24, 92, 360, 32);
  FInputEdit.TextHint := 'Write button text here';
  FInputEdit.OnChange := @InputChanged;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent := Self;
  FStatusLabel.Left := 24;
  FStatusLabel.Top := 136;
  FStatusLabel.Font.Style := [fsBold];

  for I := 0 to High(FThemeButtons) do
  begin
    Theme := GetThemeByIndex(I);
    FThemeButtons[I] := TBCButton.Create(Self);
    ConfigureButton(FThemeButtons[I], Theme.Name, 24 + (I * 122), 168, 110, 40);
    FThemeButtons[I].Tag := I;
    FThemeButtons[I].OnClick := @ThemeButtonClick;
  end;

  FPreviewPanel := TPanel.Create(Self);
  FPreviewPanel.Parent := Self;
  FPreviewPanel.SetBounds(416, 24, 320, 340);
  FPreviewPanel.BevelOuter := bvNone;
  FPreviewPanel.ParentBackground := False;

  PreviewTitle := TLabel.Create(Self);
  PreviewTitle.Parent := FPreviewPanel;
  PreviewTitle.Caption := 'Live preview';
  PreviewTitle.Left := 20;
  PreviewTitle.Top := 20;
  PreviewTitle.Font.Size := 14;
  PreviewTitle.Font.Style := [fsBold];

  FAccentShape := TBGRAShape.Create(Self);
  FAccentShape.Parent := FPreviewPanel;
  FAccentShape.SetBounds(20, 58, 72, 72);
  FAccentShape.ShapeType := stEllipse;
  FAccentShape.BorderWidth := 0;

  FPreviewButton := TBCButton.Create(Self);
  FPreviewButton.Parent := FPreviewPanel;
  FPreviewButton.SetBounds(20, 156, 280, 62);
  FPreviewButton.Font.Size := 14;
  FPreviewButton.Font.Style := [fsBold];

  with TLabel.Create(Self) do
  begin
    Parent := FPreviewPanel;
    Left := 20;
    Top := 244;
    Width := 260;
    WordWrap := True;
    Caption :=
      'This project keeps the app small while proving that a vendored Lazarus package ' +
      'builds inside the published lazarus-build-station image.';
  end;
end;

procedure TDemoMainForm.InputChanged(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TDemoMainForm.ThemeButtonClick(Sender: TObject);
begin
  ApplyTheme((Sender as TControl).Tag);
end;

procedure TDemoMainForm.UpdatePreview;
begin
  FPreviewButton.Caption := NormalizePreviewText(FInputEdit.Text);
end;

procedure TDemoMainForm.ApplyTheme(Index: Integer);
var
  Theme: TPreviewTheme;
begin
  FThemeIndex := Index;
  Theme := GetThemeByIndex(FThemeIndex);

  Color := TColor(Theme.SurfaceColor);
  FPreviewPanel.Color := TColor(Theme.SurfaceColor);
  FAccentShape.FillColor := TColor(Theme.AccentColor);
  FAccentShape.BorderColor := TColor(Theme.AccentColor);
  FStatusLabel.Caption := BuildStatusText(Theme);
end;

end.

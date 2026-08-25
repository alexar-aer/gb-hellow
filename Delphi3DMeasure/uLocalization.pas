unit uLocalization;

interface

uses
  Classes;

type
  TAppLanguage = (alEnglish, alRussian);

  TLocalizationManager = class
  private
    FCurrentLanguage: TAppLanguage;
    FOnChange: TNotifyEvent;
    procedure SetLanguage(const Value: TAppLanguage);
  public
    constructor Create;
    procedure UpdateInterface;
    property CurrentLanguage: TAppLanguage read FCurrentLanguage write SetLanguage;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

var
  LocMgr: TLocalizationManager;

implementation

{ TLocalizationManager }

constructor TLocalizationManager.Create;
begin
  inherited Create;
  FCurrentLanguage := alEnglish;
end;

procedure TLocalizationManager.SetLanguage(const Value: TAppLanguage);
begin
  if FCurrentLanguage <> Value then
  begin
    FCurrentLanguage := Value;
    UpdateInterface;
  end;
end;

procedure TLocalizationManager.UpdateInterface;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

initialization
  LocMgr := TLocalizationManager.Create;
finalization
  LocMgr.Free;
end.
